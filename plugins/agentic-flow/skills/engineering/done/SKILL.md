---
name: done
description: "Close the current ticket. Materializes the ticket diff via the shared convention (refusing while implementation is uncommitted), invokes the deviation-fact-checker sub-agent to compare it against ## Deviations, surfaces gaps and ADR candidates for review, appends a retro entry, flips ticket status to Done, commits the close-out edits at one gated offer, then forks: run /improve-codebase-architecture's refactor pass or merge now, recommending one arm from the diff's nature. Use when finishing a ticket."
---

# Done

Close a ticket using **store-as-primary-signal**: fact-check the captured `## Deviations` against the actual git diff via a sub-agent, then write the retro entry. Works the same way from a fresh session as from one with full impl context. The code and its diff stay in git; the ticket state and retro live in the store.

Store artifact paths: [STORE.md](../../_shared/STORE.md). Format references: [TICKET-FORMAT.md](../../_shared/TICKET-FORMAT.md), [RETRO-FORMAT.md](../../_shared/RETRO-FORMAT.md), [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md) (deviation threshold).

## State contract

- **Spec state required**: `Open` (the active spec per the store's active pointer — files: `docs/specs/.active`, one line, the spec directory name `<NNN>-<slug>`)
- **Ticket state required**: `In progress` (typical) or `Open` (warned)
- **Transition**: ticket `In progress → Done`

Warns rather than refuses on `Open → Done` (a user who did the work without flipping status mid-pairing shouldn't be blocked; warn and confirm). Refuses on already-`Done` tickets — but an interrupted close-out is not one (see Refusing to run).

## Process

1. **Identify the ticket.** Default to the active spec's ticket with status `In progress`. If none is `In progress` but a ticket reads `done` in the working tree with uncommitted store-artifact dirt, that ticket is an interrupted close-out — identify it and proceed (step 2 classifies the state). Otherwise, if multiple or none, ask.

2. **Materialize the ticket diff via the shared convention.** Resolve the refs per [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md): `<base>` is the spec branch, `<head>` is the ticket branch (non-standard branching: ask the user for the refs). Run the script:

   ```
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/materialize-diff.sh" <base> <head>
   ```

   On success the diff is at `.agentic-flow/diff.patch` — the fact-checker has no git access; this artifact is its only view of the diff. On any non-zero exit, follow the shared doc's exit-code table: relay stderr and stop — never fall back to a hand-rolled `git diff`. Exit 5 (dirty tree) is the one exit `/done` interprets before stopping. Classify the dirty paths first — **store-artifact paths per STORE.md's artifact map** (`docs/specs/**`, `docs/adr/**`, `docs/spikes/**`, `docs/reviewers.md`, `CONTEXT.md`, `.agentic-flow/settings.toml`); everything else is implementation:
   - **Any implementation path is dirty** — refuse, naming the convention: *implementation is committed on the ticket branch before `/done` runs*. Print the implementation paths; the user commits *those paths only* — co-present store-artifact dirt stays in the tree (a resume signal; the rule is the implementation-dirt row of [RECOVERY.md](../../_shared/RECOVERY.md#resting-states)). Then re-run `/done`.
   - **Only store-artifact paths are dirty** — `/done`'s own interrupted close-out. Don't refuse: open [RECOVERY.md](../../_shared/RECOVERY.md#done-interrupted-close-out) and resume per its walkthrough.

3. **Invoke `agentic-flow:deviation-fact-checker`** with, at minimum:
   - The diff artifact path (`.agentic-flow/diff.patch`)
   - The ticket's Goal + Acceptance criteria + existing `## Deviations`
   - The spec's Approach section (for context on the intended approach)
   - The Glossary contents (so the agent uses domain vocabulary)
   - Existing ADR titles + statuses (so it doesn't propose duplicates)
   - A reminder that it has Read/Grep over the working tree and must verify claims against current source, not stale comments — every recorded fact-checker false positive traced to diff-only briefing
   - The planning-artifact label per [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md)'s "Diffs contain planning artifacts" section, carried whole — copy the section's two-sided contract into the brief, never a paraphrase of it

   The fact-checker returns three sections (each may be `_None._`):
   - **Deviation gaps** — diff changes at or above the behavioral/seam threshold not captured in `## Deviations`
   - **Misrepresented deviations** — entries in `## Deviations` that don't match the diff
   - **ADR candidates** — choices in the diff that may warrant an ADR per the three-gate test

   The fact-checker is briefed against the threshold in [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md). Below-threshold diff content (private renames, formatting, internal refactors, idiomatic changes inside a module) is **not** flagged as gaps — those are noise, not deviations. `_None._` across all three sections is a valid, common outcome on small in-module tickets.

4. **Adversarially review the findings.** The fact-checker's drafts are *drafts* — review each finding against cited diff hunks, drop noise (below-threshold gaps the fact-checker shouldn't have flagged), surface high-signal items.

5. **Apply confirmed updates** to the ticket's `## Deviations` section (append gaps, fix misrepresentations). The section is always materialized at close: if nothing was captured and the fact-check found nothing, write `_None._` (replacing `_None yet._`). An absent section reads as "nobody checked"; an explicit `_None._` reads as "checked, clean" — and the spec-scope fact-check at `/retro` relies on the distinction.

6. **Surface ADR candidates to the user** for explicit decision: each candidate gets a yes/no/defer. This is a blocking checkpoint — present the candidates and end the turn; don't proceed to the label step in the same breath. On yes, hand off to ADR creation per [ADR-FORMAT.md](../../_shared/ADR-FORMAT.md).

   **Toolchain-fact gate:** before writing any ADR, every load-bearing claim about an external system must be verified against the installed toolchain — the gate's verification recipe and the incident behind it live in [ADR-FORMAT.md](../../_shared/ADR-FORMAT.md)'s "Toolchain-fact gate" section.

7. **Determine the outcome label.**
   - **Exact match** — implemented exactly as the ticket and spec specified.
   - **Extended** — implemented as specified, plus extra scope that proved necessary or valuable.
   - **Divergence** — implemented something different (different approach, different acceptance) than specified.
   - **Omitted** — ticket abandoned or merged into another. (If selecting this, prefer abandoning the ticket per the store — the `tickets/_abandoned/` move, [TICKET-FORMAT.md](../../_shared/TICKET-FORMAT.md)'s rule — rather than running `/done`.)

   Propose the label with reasoning, anchored in the captured deviations — and **name the strongest alternative label with why it loses**. This is a blocking confirm: present the proposal and wait for the user's confirm or override. (The runs that named the alternative got fast, informed sign-off; the runs that declared unilaterally got audited later. Skipping the alternative makes skipped elicitation self-evident.)

8. **Append the retro entry** to the spec's running retro (`docs/specs/<NNN>-<slug>/retro.md`, creating the file if it doesn't exist):

   ```markdown
   ## Ticket NNN — <ticket title>

   **Outcome**: <label>

   <1-3 sentences on what was learned>
   ```

   The 1-3 sentences capture *what was learned*, not *what was done* (the ticket already has that).

9. **Flip the ticket** status from `In progress` to `Done`. Ordering is strict: **read the ticket → apply the status edit → only then run git commands** — never batch the store edit in parallel with git (see STORE.md).

10. **Commit the close-out edits (gated).** Run the gated close-out commit per [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md). `/done`'s bindings:
    - **The edit set**: every store edit this invocation made — the ticket file (materialized deviations + the `done` flip), the running retro, any ADR minted at step 6. Offer: *"Commit the close-out edits (`<paths>`) on the ticket branch?"*
    - **Re-entry**: when step 2 detected an interrupted close-out, resume *here* once every close-out artifact is in place — the convention's show-content rule applies in full, since the resumed run didn't author these edits.
    - On accept: commit; the tree is clean for whichever arm of step 11 follows. On decline: the convention's wedge statement, naming this skill — re-running `/done` resumes at this commit.

11. **Fork: run the refactor pass, or don't (gated).** The question is whether this ticket gets its per-ticket refactor pass before merging; the merge follows from the answer. Present exactly two paths and **recommend one from the nature of the just-materialized diff — never without the reasoning**: code touching seams or multiple modules recommends the pass (architectural rot is caught while context is fresh); doc-only or output-capture work recommends skipping straight to the merge (no code shape for reviewers to deepen). Then wait:
    - **Run the refactor pass — `/improve-codebase-architecture`.** Nothing merges now; its refactor commits land on the ticket branch, and the merge belongs to that pass's own close-out offer.
    - **Merge now — explicitly skipping the refactor pass.** Say so in the offer: accepting means no `/improve-codebase-architecture` pass runs for this ticket before the merge — though the pass stays recoverable afterward via that skill's post-merge ad-hoc arm, which reviews the merged range. On accept: run the gated merge per [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md) — convention read from config / the repo's CLAUDE.md, ticket branch → spec branch `--no-ff`, verify green, delete the ticket branch only after green.
    - **Offer, never auto-merge.** The merge is the user's control point; an unanswered offer blocks — it is not consent (the convention pins this too).

## Refusing to run

- If the ticket's status is already `Done` *and that flip is committed*, check the merge before refusing — `Done`-but-unmerged is the *normal* resting state of step 11's refactor-pass arm, not a closed chapter. Walk the closed-ticket states — branch merged, branch deleted, branch alive but unmerged — per [RECOVERY.md](../../_shared/RECOVERY.md#done-closed-ticket-states).
- An uncommitted `done` flip plus store-artifact-path dirt is **not** an already-closed ticket — it's an interrupted close-out (step 2's store-artifact-only case). Resume at the gated close-out commit (step 10) instead of refusing.

## Anti-patterns

- **Don't restructure the running retro.** This skill appends only. Restructuring is `/retro`'s job at spec close.
- **Don't write what was done in the retro entry.** That's redundant with the ticket. Capture *insight*, not *log*.
- **Don't trust the fact-checker's drafts blindly.** Review each finding against the cited diff. Drop noise — particularly any "gap" that's actually below threshold (private rename, formatting, internal refactor inside a module).
- **Don't pad `## Deviations` to look thorough.** If nothing seam-level moved and behavior matched spec, the section reads `_None._` at close (step 5) — never invent entries to fill it. A clean ticket is a clean ticket; manufactured deviations turn retros into commentary on noise.
- **Don't auto-invoke `/improve-codebase-architecture`.** The fork recommends an arm with reasoning; the user chooses. Accepting the refactor-pass arm is the user invoking it — never an automatic consequence of the recommendation.
- **Don't skip the fact-check step even when impl just happened in this session.** Store-as-primary means the fact-checker runs every time, regardless of conversation context.
- **Don't merge without an explicit yes.** The close-out fork is a gate, not a notification — silence or an unanswered question means stop, not proceed.
- **Don't stage the close-out commit with `-A` or `git add .`.** Enumerate the paths this invocation edited; blanket staging sweeps unrelated working-tree state into the close-out commit.
- **Don't treat a passing fact-check as truth-checked findings.** The fact-checker audits diff↔deviation mapping and cited justifications, but a clean run doesn't validate domain claims in spike findings or analysis docs — those need their own review.
