---
name: done
description: Close the current ticket. Invokes the deviation-fact-checker sub-agent to compare the ticket diff against ## Deviations, surfaces gaps and ADR candidates for review, appends a retro entry, and flips ticket status to done. Recommends /improve-codebase-architecture next for a per-ticket refactor pass. Use when finishing a ticket.
---

# Done

Close a ticket using **disk-as-primary-signal**: fact-check the captured `## Deviations` against the actual diff via a sub-agent, then write the retro entry. Works the same way from a fresh session as from one with full impl context.

Format references: [TICKET-FORMAT.md](../../_shared/TICKET-FORMAT.md), [RETRO-FORMAT.md](../../_shared/RETRO-FORMAT.md), [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md) (deviation threshold).

## State contract

- **PRD state required**: `open` (the active PRD per `docs/prds/.active`)
- **Ticket state required**: `in-progress` (typical) or `open` (warned)
- **Transition**: ticket `in-progress → done`

Warns rather than refuses on `open → done` (a user who did the work without flipping status mid-pairing shouldn't be blocked; warn and confirm). Refuses on already-`done` tickets.

## Process

1. **Identify the ticket.** Default to the ticket with `status: in-progress` in the active PRD. If multiple or none, ask.

2. **Determine the diff range and materialize the diff artifact.**
   - Default: the ticket branch's diff vs its parent (the PRD branch in `serial` mode, the previous ticket's branch in `stacked` mode per `docs/agentic-flow.toml`).
   - Fallback (non-standard branching): ask the user for the diff range.
   - Write the diff to the standard artifact path: `git diff <range> > .agentic-flow/diff.patch` (create `.agentic-flow/` if needed; it's git-ignored). The fact-checker has no git access — this file is its only view of the diff, so don't improvise a different handoff per run.

3. **Invoke `agentic-flow:deviation-fact-checker`** with, at minimum:
   - The diff artifact path (`.agentic-flow/diff.patch`)
   - The ticket file (Goal + Acceptance + existing `## Deviations`)
   - The PRD's Approach section (for context on the intended approach)
   - `CONTEXT.md` (so the agent uses domain vocabulary)
   - Existing ADR titles + statuses (so it doesn't propose duplicates)
   - A reminder that it has Read/Grep over the working tree and must verify claims against current source, not stale comments — every recorded fact-checker false positive traced to diff-only briefing
   
   The fact-checker returns three sections (each may be `_None._`):
   - **Deviation gaps** — diff changes at or above the behavioral/seam threshold not captured in `## Deviations`
   - **Misrepresented deviations** — entries in `## Deviations` that don't match the diff
   - **ADR candidates** — choices in the diff that may warrant an ADR per the three-gate test
   
   The fact-checker is briefed against the threshold in [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md). Below-threshold diff content (private renames, formatting, internal refactors, idiomatic changes inside a module) is **not** flagged as gaps — those are noise, not deviations. `_None._` across all three sections is a valid, common outcome on small in-module tickets.

4. **Adversarially review the findings.** The fact-checker's drafts are *drafts* — review each finding against cited diff hunks, drop noise (below-threshold gaps the fact-checker shouldn't have flagged), surface high-signal items.

5. **Apply confirmed updates** to the ticket's `## Deviations` section (append gaps, fix misrepresentations). The section is always materialized at close: if nothing was captured and the fact-check found nothing, write `_None._` (replacing `_None yet._`). An absent section reads as "nobody checked"; an explicit `_None._` reads as "checked, clean" — and the PRD-scope fact-check at `/retro` relies on the distinction.

6. **Surface ADR candidates to the user** for explicit decision: each candidate gets a yes/no/defer. This is a blocking checkpoint — present the candidates and end the turn; don't proceed to the label step in the same breath. On yes, hand off to ADR creation per [ADR-FORMAT.md](../../_shared/ADR-FORMAT.md).
   
   **Toolchain-fact gate:** before writing any ADR, every load-bearing claim about an external system (stdlib behavior, build-system APIs, language defaults, third-party semantics) must be verified against the installed toolchain — by reading its source, running a probe program, or dispatching a research sub-agent. An ADR frozen on an unverified external fact is the recorded failure shape: four ADRs in one project rotted this way, all foreseeably.

7. **Determine the outcome label.**
   - **Exact match** — implemented exactly as the ticket and PRD specified.
   - **Extended** — implemented as specified, plus extra scope that proved necessary or valuable.
   - **Divergence** — implemented something different (different approach, different acceptance) than specified.
   - **Omitted** — ticket abandoned or merged into another. (If selecting this, prefer moving the ticket file to `tickets/_abandoned/` rather than running `/done`.)
   
   Propose the label with reasoning, anchored in the captured deviations — and **name the strongest alternative label with why it loses**. This is a blocking confirm: present the proposal and wait for the user's confirm or override. (The runs that named the alternative got fast, informed sign-off; the runs that declared unilaterally got audited later. Skipping the alternative makes skipped elicitation self-evident.)

8. **Append the retro entry** to `docs/prds/<NNN>-<slug>/retro.md` (creating the file if it doesn't exist):

   ```markdown
   ## Ticket NNN — <ticket title>
   
   **Outcome**: <label>
   
   <1-3 sentences on what was learned>
   ```

   The 1-3 sentences capture *what was learned*, not *what was done* (the ticket file already has that).

9. **Flip the ticket** `status` from `in-progress` to `done`. Ordering is strict: **read the ticket file → edit the status → only then run git commands** — never batch the frontmatter edit in parallel with git. (A failed Edit inside a parallel batch once cascaded into ~20 cancelled git calls and an abandoned session.)

10. **Recommend `/improve-codebase-architecture`** as the next step for a per-ticket refactor pass. Phrase as a suggestion: *"Recommend running `/improve-codebase-architecture` next for a refactor pass on this ticket. Optional but catches architectural rot while context is fresh."*

11. **Offer the close-out merge (gated).** Read the merge convention from `docs/agentic-flow.toml` / the repo's CLAUDE.md (don't improvise it), then offer: *"Merge the ticket branch back (`--no-ff`), verify the build/tests are green on the parent, and delete the ticket branch?"* Rules:
    - **Offer, never auto-merge.** The merge is the user's control point; an unanswered offer blocks — it is not consent.
    - If the user is taking the `/improve` recommendation, the merge waits until after that pass (its refactor commits belong on the ticket branch).
    - On accept: merge `--no-ff`, run the repo's verification (build + tests), and delete the ticket branch only after green. If verification fails, stop and surface it — don't delete the branch.

## Refusing to run

- If the ticket's status is already `done`, refuse. Suggest checking git history if the user wants to know what happened.

## Anti-patterns

- **Don't restructure the running retro.** This skill appends only. Restructuring is `/retro`'s job at PRD close.
- **Don't write what was done in the retro entry.** That's redundant with the ticket file. Capture *insight*, not *log*.
- **Don't trust the fact-checker's drafts blindly.** Review each finding against the cited diff. Drop noise — particularly any "gap" that's actually below threshold (private rename, formatting, internal refactor inside a module).
- **Don't pad `## Deviations` to look thorough.** If nothing seam-level moved and behavior matched spec, leave the section empty (or at `_None yet._`). A clean ticket is a clean ticket; manufactured deviations turn retros into commentary on noise.
- **Don't auto-invoke `/improve-codebase-architecture`.** Recommend it; let the user choose to invoke (or defer if no refactor seems needed).
- **Don't skip the fact-check step even when impl just happened in this session.** Disk-as-primary means the fact-checker runs every time, regardless of conversation context.
- **Don't merge without an explicit yes.** The close-out merge offer is a gate, not a notification — silence or an unanswered question means stop, not proceed.
- **Don't treat a passing fact-check as truth-checked findings.** The fact-checker audits diff↔deviation mapping and cited justifications, but a clean run doesn't validate domain claims in spike findings or analysis docs — those need their own review.
