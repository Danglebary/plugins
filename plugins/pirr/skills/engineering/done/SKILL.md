---
name: done
description: "Close a ticket: fact-check `## Deviations`, judge spec conformance, surface ADR candidates, append the retro, flip to Done, fork to refactor pass or merge. Use when finishing a ticket."
---

# Done

Close a ticket using **store-as-primary-signal**: fact-check captured `## Deviations` and judge spec conformance against the git diff via paired sub-agents, then write the retro entry. Works identically from a fresh session or one with full impl context. Code and its diff stay in git; ticket state and retro live in the store.

## State contract

- **Spec state required**: `Open` (the active spec per the store's active pointer — files: `docs/specs/.active`, one line, the spec directory name `<NNN>-<slug>`)
- **Ticket state required**: `In progress` (typical) or `Open` (warned)
- **Transition**: ticket `In progress → Done`

Warns rather than refuses on `Open → Done` (a user who did the work without flipping status mid-pairing shouldn't be blocked; warn and confirm). Refuses on already-`Done` tickets — but an interrupted close-out is not one (see Refusing to run).

## Process

1. **Identify the ticket.** Default to the active spec's ticket with status `In progress`. If none is `In progress` but a ticket reads `done` in the working tree with uncommitted store-artifact dirt, it's an interrupted close-out — identify it and proceed. Otherwise, if multiple or none, ask.

2. **Materialize the ticket diff via the shared convention.** Resolve the refs per [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md): `<base>` is the spec branch, `<head>` is the ticket branch (non-standard branching: ask the user for the refs). Run the script:

   ```
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/materialize-diff.sh" <base> <head> [--allow-untracked <path>...]
   ```

   On success the diff is at `.pirr/diff.patch` — the close-out agents have no git access; this artifact is their only view of the diff. On any non-zero exit, follow the shared doc's exit-code table: relay stderr and stop — never fall back to a hand-rolled `git diff`. Exits 5 and 8 are the two `/done` interprets before stopping. Both classify their paths against the same division — **store-artifact paths per STORE.md's artifact map** (`docs/specs/**`, `docs/adr/**`, `docs/spikes/**`, `docs/reviewers.md`, `CONTEXT.md`, `.pirr/settings.toml`); everything else is implementation. Exit 8 sees one population exit 5 cannot — a path that is neither, such as a scratch note, an editor backup, or un-ignored build output. Refuse on it as well (refusing is the safe side of an unrecognized path), but say only that it can't be classified and point at `.gitignore`; the never-staged-work sentence below is false about it.

   **Exit 5 (tracked dirt)** — two arms:
   - **Any implementation path is dirty** — refuse, naming the convention: *implementation is committed on the ticket branch before `/done` runs*. Print the implementation paths; the user commits *those paths only* — co-present store-artifact dirt stays in the tree (a resume signal — [RECOVERY.md](../../_shared/RECOVERY.md#resting-states), implementation-dirt row). Then re-run `/done`.
   - **Only store-artifact paths are dirty** — `/done`'s own interrupted close-out. Don't refuse: open [RECOVERY.md](../../_shared/RECOVERY.md#done-interrupted-close-out) and resume per its walkthrough.

   **Exit 8 (untracked paths).** Classify **per path, never by the set as a whole** — [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md)'s enumeration is per-entry, and a mixed set (this run's own artifacts alongside a foreign banked idea) is the ordinary resumed-close state, not an edge case. A whole-set test leaves the mixed case matching no arm:
   - **Any reported path is implementation** — refuse, same convention as above, and say plainly what the exit prevented: *a never-staged file is absent from the diff and from the close-out commit's enumeration — closing now would ship nothing of it*. Print the implementation paths; the user stages or removes them, then re-runs `/done`. This arm fires even when legitimate planning artifacts are reported alongside — one unstaged implementation file refuses the whole close.
   - **No reported path is implementation** — proceed: re-invoke the script with `--allow-untracked` naming **every** reported path. Then split them by authorship in what you tell the user, exactly as CLOSE-OUT.md's enumeration does. **Authorship is scoped to the close, not to the invocation** ([ADR 0007](../../../../../docs/adr/0007-authorship-is-scoped-to-the-close.md)) — on a resume, a crashed predecessor run's edits are this close's own, not foreign ([CLOSE-OUT.md](../../_shared/CLOSE-OUT.md)'s show-content-on-resume rule commits exactly those). So: paths this close authored (a minted ADR, a first `retro.md` — including ones a run this invocation is resuming created) are its own in-flight edits and pass without comment; paths belonging to no run of this close — another spec's draft, a banked idea, the ordinary resting state of a working store — are **named to the user** as excluded from it. Read the split the session-scoped way and a resumed close names its own minted ADR excluded, then CLOSE-OUT.md's authorship-scoped enumeration drops it from the commit — the silent non-ship this exit exists to prevent, one layer up. That visibility is what CLOSE-OUT.md owes them, applied one step earlier so nothing is silently acknowledged.

3. **Surface contract tampering, then dispatch the close-out pair.**

   **Contract-tamper surface (before dispatch).** A ticket branch can rewrite the very Goal/Acceptance criteria it will be judged conformant against — or the spec's Approach — and be judged against the rewritten bar ([ADR 0005](../../../../../docs/adr/0005-reviewers-distrust-diff-touched-authority.md)). Before dispatching, run the shipped tamper script over the refs step 2 already resolved (`<base>` = spec branch, `<head>` = ticket branch); it is a shipped script rather than inline prose because the check is a section-aware, multi-step hot-path procedure that must not skip a step ([ADR 0002](../../../../../docs/adr/0002-hot-path-classifications-stay-inlined.md)):

   ```
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/contract-tamper.sh" <base> <head> \
     <ticket-path> Goal <ticket-path> "Acceptance criteria" <spec-path> Approach
   ```

   where `<ticket-path>` and `<spec-path>` are the ticket file and `spec.md` named below. On any non-zero exit, relay stderr and stop — never dispatch (the discipline step 2 applies to `materialize-diff.sh`; the script's exit codes are documented in its header). On exit 0 it prints, per guarded target, a `SECTION\t<path>\t<heading>\t<changed|unchanged>` line (followed by that section's line-numbered base text); read the fourth tab-field for the flag, and **retain each target's line-numbered base body — it is the frozen contract the shared brief inlines** (the dispatch list below). If every target reads `unchanged`, proceed silently — no confirm. **If any target reads `changed`, this is a blocking Consent gate: name the moved section(s), then end the turn and wait for the user's explicit acknowledgment.** Where the cause is a real rewrite — or a guarded heading present at one ref and absent at the other, which is the loudest tamper the guard produces — it *is* visible in the step-2 diff `.pirr/diff.patch`: point at it there. Only two causes are the script's fail-safe verdict, and those leave nothing to point at: a heading matching more than once outside fences at either ref (ambiguous, so which text is the contract is unknowable), or a target resolving to nothing at **both** refs. Absence at a single ref is not one of them — it reaches `changed` through the ordinary text comparison, so don't call it a fail-safe and send the user looking for nothing. Do not dispatch the pair in the same turn — an unacknowledged tamper is a "no", not a "proceed"; it stops the close-out, never a notification to glide past. `## Deviations` is never a guarded target, so a deviation legitimately authored on the ticket branch never trips it.

   **A `changed` verdict can arrive with no base body — refuse rather than dispatch.** The script emits a target's line-numbered base text only when that target resolved at `<base>`, so a target absent or ambiguous *there* prints its `SECTION` line alone. That base text is the frozen contract the brief below inlines, and it has no substitute: the head ticket file is the very text ADR 0005 exists to keep out of the bar. Name the target, say its base contract could not be resolved and why, and stop — dispatching the conformance agent against an absent bar buys a clean judgment made against nothing, which is worse than no judgment because it reads the same as a real one.

   **Compose the dispatch record first — before the preflight, and so before any result arrives.** The intended lens list is fixed and known here: `pirr:deviation-fact-checker` and `pirr:spec-conformance`. Enter both, unsettled, and settle each as its result lands or fails to, per the shared doc's four states (`returned`, `degraded`, `refused`, `unresolved`). **Composing it after the preflight would put the record behind the refusal below, leaving `unresolved` — the one state that exists only on a preflight failure — unreachable in exactly the case it describes.** Composing it from the returns instead would make a lens that never ran invisible. Both are the same failure: the record must exist before the thing it records can go wrong.

   **Resolution preflight (before dispatch).** Verify **both** close-out agent names resolve against the available agent types before dispatching *either*. If either does not resolve, settle **both** entries `unresolved` per the shared doc's definition of that state — the preflight refuses before either lens runs, so a mixed returned/unresolved close is not a state it can produce — and name which of the two failed to resolve, since that is the only one the user can act on. Then **refuse, emitting the record as part of the refusal**. Name the unresolved lens and what its absence costs (the bookkeeping audit, or the conformance judgment): the lens did not run, and a close-out judged by one axis is not a close-out judged by two. The usual cause is a newly authored or renamed agent that isn't a registered dispatch type until the plugin reloads; say so, and that re-running `/done` after the reload passes this check. A refusal ends the close before step 8, so the refusal message *is* the record's emission here — there is no retro entry to persist it into. The rule and its rationale live in [EVIDENCE-PRINCIPLE.md](../../_shared/EVIDENCE-PRINCIPLE.md)'s Dispatch record section; this is `/refactor`'s manifest check bound to a fixed two-name list.

   **Anti-substitution.** A `subagent_type` that does not resolve means *that lens did not run* — **never recover it by inlining the agent's body into a general-purpose agent**, the way the exit-code discipline above never falls back to a hand-rolled `git diff`. An inlined agent reproduces the output contract, so the degraded return looks on-contract and nothing downstream can tell: the recovery is forbidden rather than detected. Report the lens as not having run; don't manufacture its output shape.

   **Dispatch the close-out pair — `pirr:deviation-fact-checker` and `pirr:spec-conformance` — in one parallel batch**, both against the same materialized diff. **Pin the exact agent type on each dispatch** — pass `subagent_type: pirr:deviation-fact-checker` and `subagent_type: pirr:spec-conformance` explicitly; the field is optional at the tool boundary and an omitted type silently resolves to a general-purpose agent, which is the anti-substitution failure arrived at by omission rather than by choice. The axes are deliberately split: the fact-checker audits bookkeeping and never editorializes; correctness judgment lives in the conformance agent. The shared brief carries, at minimum:
   - The diff artifact path (`.pirr/diff.patch`)
   - The ticket's Goal + Acceptance criteria **as the line-numbered base text the tamper script emitted above** — the frozen contract from the spec branch, not the head ticket file — plus the existing `## Deviations` and the ticket file's path (`docs/specs/<NNN>-<slug>/tickets/<NNN>-<slug>.md`). The conformance agent cites its spec-source findings at `file:line` using those base line numbers as-is (ADR 0005); `## Deviations` stays head-sourced, being legitimately diff-authored and exempt from the swap
   - The spec's Approach section **as the line-numbered base text from the same script**, with the spec file's path (`docs/specs/<NNN>-<slug>/spec.md`) — the conformance agent's base spec source and the citation target for any Approach-derived finding. For the `deviation-fact-checker` this stays briefing context only: the base-for-head swap is inert for it, since it audits `## Deviations` against the diff and never cites the Goal/Acceptance/Approach line numbers as a bar
   - The Glossary contents (so both use domain vocabulary)
   - A reminder that they have Read/Grep over the working tree and must verify claims against current source, not stale comments — every recorded fact-checker false positive traced to diff-only briefing
   - The planning-artifact label per [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md)'s "Diffs contain planning artifacts" section, carried whole — copy the section's two-sided contract into the brief, never a paraphrase of it

   The fact-checker additionally receives existing ADR titles + statuses (so it doesn't propose duplicates) and returns three finding sections (each may be `_None._`), followed by its Partial verdict register:
   - **Deviation gaps** — diff changes at or above the behavioral/seam threshold not captured in `## Deviations`
   - **Misrepresented deviations** — entries in `## Deviations` that don't match the diff
   - **ADR candidates** — choices in the diff that may warrant an ADR per the three-gate test

   The conformance agent judges the diff against its spec source — the ticket's Goal and Acceptance criteria plus the spec's Approach — and returns three finding sections (each may be `_None._`), followed by its Partial verdict register:
   - **Missing or partial requirements** — spec-source requirements the diff doesn't satisfy, or satisfies only partially
   - **Scope creep** — diff changes serving no spec-source requirement
   - **Implemented but looks wrong** — requirements whose implementation contradicts the spec source, each finding citing the spec line and the diff hunk

   The fact-checker is briefed against the threshold in [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md). Below-threshold diff content (private renames, formatting, internal refactors) is **not** flagged as gaps — noise, not deviations. `_None._` across all three finding sections is a valid, common outcome on small in-module tickets.

4. **Adversarially review both reports, then present them separately.** Check each finding against its cited diff hunks — and, for conformance findings, the cited spec lines — and drop what the citations don't support (below-threshold gaps, findings the working tree refutes). Render the two reports under separate headings, the fact-check then the conformance report, never merged into one list, never reranked against each other: the axes answer different questions (is the bookkeeping accurate; does the implementation satisfy the spec source), and a merged ranking would bury one answer under the other.

   **Check each return for its Partial verdict register — presence only, never contents** ([EVIDENCE-PRINCIPLE.md](../../_shared/EVIDENCE-PRINCIPLE.md), [AGENT-FORMAT.md](../../_shared/AGENT-FORMAT.md)). A return arriving without one is **degraded, not returned**: settle its dispatch-record entry that way and say so when presenting that report. The missing register is the one post-hoc signal available that a return degraded — an attested lens with no gap check is not a clean lens.

   Presenting each return in full is also what delivers a planted-instruction callout when one is present — it rides the report it came with, needing no parse and no separate step ([ADR 0008](../../../../../docs/adr/0008-planted-instruction-reporting-follows-convergence.md)). Don't summarize a return down to its finding sections; the callout sits outside them.

5. **Apply confirmed updates** to the ticket's `## Deviations` section (append gaps, fix misrepresentations). The section is always materialized at close: if nothing was captured and the fact-check is clean, write `_None._` (replacing the `_None yet._` placeholder). The three states that distinction rests on — absent, placeholder, explicit sentinel — are the honesty rule's, stated once in [EVIDENCE-PRINCIPLE.md](../../_shared/EVIDENCE-PRINCIPLE.md) and not restated here. Leaving the placeholder in place is the failure this step exists to prevent: it reads "not yet", so a closed ticket still carrying it claims nothing at all. `/retro`'s synthesis read is the consumer that relies on the distinction (its step 6), not its spec-scope fact-check.

6. **Surface ADR candidates to the user** for explicit decision: each candidate gets a yes/no/defer. Blocking checkpoint — present the candidates and end the turn; don't proceed to the label step in the same breath. On yes, hand off to ADR creation per [ADR-FORMAT.md](../../_shared/ADR-FORMAT.md).

   **Toolchain-fact gate:** before writing any ADR, verify every load-bearing external-system claim against the installed toolchain — recipe and incident live in [ADR-FORMAT.md](../../_shared/ADR-FORMAT.md)'s "Toolchain-fact gate" section.

7. **Determine the outcome label.**
   - **Exact match** — implemented exactly as the ticket and spec specified.
   - **Extended** — implemented as specified, plus extra scope that proved necessary or valuable.
   - **Divergence** — implemented something different (approach or acceptance) than specified.
   - **Omitted** — ticket abandoned or merged into another. (If so, prefer abandoning the ticket per the store — the `tickets/_abandoned/` move, [TICKET-FORMAT.md](../../_shared/TICKET-FORMAT.md)'s rule — not running `/done`.)

   Propose the label with reasoning, anchored in both step-4 reports — the fact-checked deviations and the conformance findings — and **name the strongest alternative label with why it loses**. Blocking confirm: present the proposal and wait for confirm or override. (The runs that named the alternative got fast, informed sign-off; the runs that declared unilaterally got audited later.)

8. **Append the retro entry** to the spec's running retro (`docs/specs/<NNN>-<slug>/retro.md`, creating the file if it doesn't exist) per [RETRO-FORMAT.md](../../_shared/RETRO-FORMAT.md)'s running form:

   ```markdown
   ## Ticket NNN — <ticket title>

   **Outcome**: <label>

   **Dispatch**: <the record composed at step 3>

   <1-3 sentences on what was learned>
   ```

   The 1–3 sentences capture *what was learned*, not *what was done*.

   **The `**Dispatch**` line persists the step-3 record** — emission is mandatory, detail is gap-only, and the clean case is one line (`close-out pair — both returned.`). Any lens that degraded, refused, or went unresolved is named with what its absence cost. A record left in chat evaporates at the session boundary; a record written only when something breaks makes its absence meaningless. Field format: [RETRO-FORMAT.md](../../_shared/RETRO-FORMAT.md).

9. **Flip the ticket** status from `In progress` to `Done`. Ordering is strict: **read the ticket → apply the status edit → only then run git commands** — never batch the store edit in parallel with git (see [STORE.md](../../_shared/STORE.md)).

10. **Commit the close-out edits (gated).** Run the gated close-out commit per [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md). `/done`'s bindings:
    - **The edit set**: every store edit this invocation made — the ticket file (materialized deviations + the `done` flip), the running retro, any ADR minted at step 6. Offer: *"Commit the close-out edits (`<paths>`) on the ticket branch?"*
    - **Re-entry**: when step 2 detected an interrupted close-out, resume *here* once every close-out artifact is in place — the convention's show-content rule applies in full.
    - On accept: commit; the tree is clean for step 11. On decline: the convention's wedge statement, naming this skill — re-running `/done` resumes at this commit.

11. **Fork: run the refactor pass, or don't (gated).** The question is whether this ticket gets its per-ticket refactor pass before merging; the merge follows from the answer. Present exactly two paths and **recommend one from the nature of the just-materialized diff — never without the reasoning**: code touching seams or multiple modules recommends the pass (architectural rot is caught while context is fresh); doc-only or output-capture work recommends skipping straight to the merge (no code shape for reviewers to deepen). Then wait:
    - **Run the refactor pass — `/refactor`.** Nothing merges now; its refactor commits land on the ticket branch, and the merge belongs to that pass's own close-out offer.
    - **Merge now — explicitly skipping the refactor pass.** Say so in the offer: accepting means no `/refactor` pass runs before the merge — though the pass stays recoverable afterward via that skill's post-merge ad-hoc arm. On accept: run the gated merge per [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md) — convention read from config / the repo's CLAUDE.md, ticket branch → spec branch `--no-ff`, verify green, delete the ticket branch only after green.
    - **Offer, never auto-merge.** An unanswered offer blocks — it is not consent.

## Refusing to run

- If the ticket's status is already `Done` *and that flip is committed*, check the merge before refusing — `Done`-but-unmerged is step 11's *normal* refactor-pass resting state, not a closed chapter. Walk the closed-ticket states — branch merged, branch deleted, branch alive but unmerged — per [RECOVERY.md](../../_shared/RECOVERY.md#done-closed-ticket-states).
- An uncommitted `done` flip plus store-artifact-path dirt is **not** an already-closed ticket — it's an interrupted close-out (step 2's store-artifact-only case). Resume at the gated close-out commit (step 10) instead of refusing.

## Anti-patterns

- **Don't restructure the running retro.** This skill appends only; restructuring is `/retro`'s job at spec close.
- **Don't write what was done in the retro entry.** Capture *insight*, not *log*.
- **Don't trust either agent's drafts blindly.** Review each finding against its citations; drop below-threshold "gaps" and conformance findings the working tree refutes.
- **Don't pad `## Deviations` to look thorough.** If nothing seam-level moved and behavior matched spec, it reads `_None._` at close (step 5) — never invent entries to fill it.
- **Don't auto-invoke `/refactor`.** The fork recommends an arm with reasoning; the user chooses — accepting the refactor-pass arm is never automatic.
- **Don't skip the close-out pair even when impl just happened this session.** Store-as-primary: the fact-checker and the conformance agent run every time, regardless of conversation context.
- **Don't recover an unresolved lens by inlining its body into a general-purpose agent.** The lens did not run; producing its output shape anyway manufactures evidence of a judgment that never happened — and it is undetectable after the fact. This is on record: a first live close-out ran a newly authored agent inlined because it wasn't yet a registered type.
- **Don't dispatch either close-out agent without pinning `subagent_type`.** An omitted type is not a neutral default — it silently resolves to a general-purpose agent.
- **Don't write the dispatch record only when something broke.** If the clean case writes nothing, an absent record carries no meaning.
- **Don't merge without an explicit yes.** The close-out fork is a gate, not a notification — silence or an unanswered question means stop.
- **Don't stage the close-out commit with `-A` or `git add .`.** Enumerate the paths this invocation edited; blanket staging sweeps unrelated tree state into the commit.
- **Don't treat a passing fact-check as truth-checked findings.** It audits diff↔deviation mapping and cited justifications; a clean run doesn't validate domain claims in spike or analysis docs — those need their own review.
