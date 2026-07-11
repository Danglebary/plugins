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
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/materialize-diff.sh" <base> <head>
   ```

   On success the diff is at `.agentic-flow/diff.patch` — the close-out agents have no git access; this artifact is their only view of the diff. On any non-zero exit, follow the shared doc's exit-code table: relay stderr and stop — never fall back to a hand-rolled `git diff`. Exit 5 (dirty tree) is the one exit `/done` interprets before stopping. Classify the dirty paths first — **store-artifact paths per STORE.md's artifact map** (`docs/specs/**`, `docs/adr/**`, `docs/spikes/**`, `docs/reviewers.md`, `CONTEXT.md`, `.agentic-flow/settings.toml`); everything else is implementation:
   - **Any implementation path is dirty** — refuse, naming the convention: *implementation is committed on the ticket branch before `/done` runs*. Print the implementation paths; the user commits *those paths only* — co-present store-artifact dirt stays in the tree (a resume signal — [RECOVERY.md](../../_shared/RECOVERY.md#resting-states), implementation-dirt row). Then re-run `/done`.
   - **Only store-artifact paths are dirty** — `/done`'s own interrupted close-out. Don't refuse: open [RECOVERY.md](../../_shared/RECOVERY.md#done-interrupted-close-out) and resume per its walkthrough.

3. **Dispatch the close-out pair — `agentic-flow:deviation-fact-checker` and `agentic-flow:spec-conformance` — in one parallel batch**, both against the same materialized diff. The axes are deliberately split: the fact-checker audits bookkeeping and never editorializes; correctness judgment lives in the conformance agent. The shared brief carries, at minimum:
   - The diff artifact path (`.agentic-flow/diff.patch`)
   - The ticket's Goal + Acceptance criteria + existing `## Deviations`
   - The spec's Approach section — briefing context for the fact-checker; part of the conformance agent's spec source
   - The Glossary contents (so both use domain vocabulary)
   - A reminder that they have Read/Grep over the working tree and must verify claims against current source, not stale comments — every recorded fact-checker false positive traced to diff-only briefing
   - The planning-artifact label per [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md)'s "Diffs contain planning artifacts" section, carried whole — copy the section's two-sided contract into the brief, never a paraphrase of it

   The fact-checker additionally receives existing ADR titles + statuses (so it doesn't propose duplicates) and returns three sections (each may be `_None._`):
   - **Deviation gaps** — diff changes at or above the behavioral/seam threshold not captured in `## Deviations`
   - **Misrepresented deviations** — entries in `## Deviations` that don't match the diff
   - **ADR candidates** — choices in the diff that may warrant an ADR per the three-gate test

   The conformance agent judges the diff against its spec source — the ticket's Goal and Acceptance criteria plus the spec's Approach — and returns three sections (each may be `_None._`):
   - **Missing or partial requirements** — spec-source requirements the diff doesn't satisfy, or satisfies only partially
   - **Scope creep** — diff changes serving no spec-source requirement
   - **Implemented but looks wrong** — requirements whose implementation contradicts the spec source, each finding citing the spec line and the diff hunk

   The fact-checker is briefed against the threshold in [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md). Below-threshold diff content (private renames, formatting, internal refactors) is **not** flagged as gaps — noise, not deviations. `_None._` across all three sections is a valid, common outcome on small in-module tickets.

4. **Adversarially review both reports, then present them separately.** Check each finding against its cited diff hunks — and, for conformance findings, the cited spec lines — and drop what the citations don't support (below-threshold gaps, findings the working tree refutes). Render the two reports under separate headings, the fact-check then the conformance report, never merged into one list, never reranked against each other: the axes answer different questions (is the bookkeeping accurate; does the implementation satisfy the spec source), and a merged ranking would bury one answer under the other.

5. **Apply confirmed updates** to the ticket's `## Deviations` section (append gaps, fix misrepresentations). The section is always materialized at close: if nothing was captured and the fact-check is clean, write `_None._` (replacing `_None yet._`). An absent section reads "nobody checked", an explicit `_None._` reads "checked, clean" — `/retro`'s spec-scope fact-check relies on the distinction.

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

   <1-3 sentences on what was learned>
   ```

   The 1–3 sentences capture *what was learned*, not *what was done*.

9. **Flip the ticket** status from `In progress` to `Done`. Ordering is strict: **read the ticket → apply the status edit → only then run git commands** — never batch the store edit in parallel with git (see [STORE.md](../../_shared/STORE.md)).

10. **Commit the close-out edits (gated).** Run the gated close-out commit per [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md). `/done`'s bindings:
    - **The edit set**: every store edit this invocation made — the ticket file (materialized deviations + the `done` flip), the running retro, any ADR minted at step 6. Offer: *"Commit the close-out edits (`<paths>`) on the ticket branch?"*
    - **Re-entry**: when step 2 detected an interrupted close-out, resume *here* once every close-out artifact is in place — the convention's show-content rule applies in full.
    - On accept: commit; the tree is clean for step 11. On decline: the convention's wedge statement, naming this skill — re-running `/done` resumes at this commit.

11. **Fork: run the refactor pass, or don't (gated).** The question is whether this ticket gets its per-ticket refactor pass before merging; the merge follows from the answer. Present exactly two paths and **recommend one from the nature of the just-materialized diff — never without the reasoning**: code touching seams or multiple modules recommends the pass (architectural rot is caught while context is fresh); doc-only or output-capture work recommends skipping straight to the merge (no code shape for reviewers to deepen). Then wait:
    - **Run the refactor pass — `/improve-codebase-architecture`.** Nothing merges now; its refactor commits land on the ticket branch, and the merge belongs to that pass's own close-out offer.
    - **Merge now — explicitly skipping the refactor pass.** Say so in the offer: accepting means no `/improve-codebase-architecture` pass runs before the merge — though the pass stays recoverable afterward via that skill's post-merge ad-hoc arm. On accept: run the gated merge per [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md) — convention read from config / the repo's CLAUDE.md, ticket branch → spec branch `--no-ff`, verify green, delete the ticket branch only after green.
    - **Offer, never auto-merge.** An unanswered offer blocks — it is not consent.

## Refusing to run

- If the ticket's status is already `Done` *and that flip is committed*, check the merge before refusing — `Done`-but-unmerged is step 11's *normal* refactor-pass resting state, not a closed chapter. Walk the closed-ticket states — branch merged, branch deleted, branch alive but unmerged — per [RECOVERY.md](../../_shared/RECOVERY.md#done-closed-ticket-states).
- An uncommitted `done` flip plus store-artifact-path dirt is **not** an already-closed ticket — it's an interrupted close-out (step 2's store-artifact-only case). Resume at the gated close-out commit (step 10) instead of refusing.

## Anti-patterns

- **Don't restructure the running retro.** This skill appends only; restructuring is `/retro`'s job at spec close.
- **Don't write what was done in the retro entry.** Capture *insight*, not *log*.
- **Don't trust either agent's drafts blindly.** Review each finding against its citations; drop below-threshold "gaps" and conformance findings the working tree refutes.
- **Don't pad `## Deviations` to look thorough.** If nothing seam-level moved and behavior matched spec, it reads `_None._` at close (step 5) — never invent entries to fill it.
- **Don't auto-invoke `/improve-codebase-architecture`.** The fork recommends an arm with reasoning; the user chooses — accepting the refactor-pass arm is never automatic.
- **Don't skip the close-out pair even when impl just happened this session.** Store-as-primary: the fact-checker and the conformance agent run every time, regardless of conversation context.
- **Don't merge without an explicit yes.** The close-out fork is a gate, not a notification — silence or an unanswered question means stop.
- **Don't stage the close-out commit with `-A` or `git add .`.** Enumerate the paths this invocation edited; blanket staging sweeps unrelated tree state into the commit.
- **Don't treat a passing fact-check as truth-checked findings.** It audits diff↔deviation mapping and cited justifications; a clean run doesn't validate domain claims in spike or analysis docs — those need their own review.
