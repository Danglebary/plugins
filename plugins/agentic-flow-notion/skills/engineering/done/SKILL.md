---
name: done
description: Close the current ticket. Invokes the deviation-fact-checker sub-agent to compare the ticket git diff against the ticket row's Deviations, surfaces gaps and ADR candidates for review, appends a retro entry to the PRD row, and flips the ticket Status to Done. Recommends /improve-codebase-architecture next for a per-ticket refactor pass. Use when finishing a ticket.
---

# Done (Notion)

Close a ticket using **Notion-as-primary-signal**: fact-check the captured `## Deviations` (in the ticket row body) against the actual git diff via a sub-agent, then write the retro entry. Works the same from a fresh session as from one with full impl context. The code and its diff stay in git; the ticket state and retro live in Notion.

Resolve databases first — see [NOTION-RESOLVER.md](../../_shared/NOTION-RESOLVER.md). Deviation threshold: [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md). ADR shape + three-gate: [ADR-FORMAT.md](../../_shared/ADR-FORMAT.md).

## State contract

- **PRD state required**: `Status = Open`, `Active = true`
- **Ticket state required**: `In progress` (typical) or `Open` (warned)
- **Transition**: ticket `In progress -> Done`

Warns rather than refuses on `Open -> Done` (a user who did the work without flipping status shouldn't be blocked; warn and confirm). Refuses on already-`Done` tickets.

## Process

1. **Identify the ticket.** Default to the Tickets-database row with `Status = In progress` whose `PRD` relation is the active PRD. If multiple or none, ask.

2. **Determine the diff range and materialize the diff artifact.** *(Git — unchanged from the file workflow.)*
   - Default: the ticket branch's diff vs its parent (the PRD branch in `serial` mode, the previous ticket's branch in `stacked` mode per the root page body config).
   - Fallback (non-standard branching): ask the user for the range.
   - Write the diff to `.agentic-flow/diff.patch` (`git diff <range> > .agentic-flow/diff.patch`; create `.agentic-flow/` if needed — it's git-ignored). The fact-checker has no git access; this file is its only view of the diff, so don't improvise a different handoff per run.

3. **Invoke `agentic-flow:deviation-fact-checker`** with, at minimum:
   - The diff artifact path (`.agentic-flow/diff.patch`)
   - The ticket row's Goal + Acceptance criteria + existing `## Deviations` (`notion-fetch` the ticket row body)
   - The PRD row's Approach section (for intended-approach context)
   - The Glossary database contents (so the agent uses domain vocabulary — replaces `CONTEXT.md`)
   - Existing ADR titles + statuses from the ADRs database (so it doesn't propose duplicates)
   - A reminder that it has Read/Grep over the working tree and must verify claims against current source, not stale comments — every recorded false positive traced to diff-only briefing

   It returns three sections (each may be `_None._`): **Deviation gaps**, **Misrepresented deviations**, **ADR candidates**. Briefed against the threshold in [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md). Below-threshold diff content (private renames, formatting, internal refactors) is **not** a gap. `_None._` across all three is a valid, common outcome on small in-module tickets.

4. **Adversarially review the findings.** The drafts are drafts — review each against cited diff hunks, drop noise, surface high-signal items.

5. **Apply confirmed updates** to the ticket row's `## Deviations` (via `update-page`). The section is always materialized at close: if nothing was captured and the fact-check found nothing, write `_None._` (replacing `_None yet._`). An absent section reads as "nobody checked"; explicit `_None._` reads as "checked, clean" — and the PRD-scope fact-check at `/retro` relies on the distinction.

6. **Surface ADR candidates to the user** for explicit decision: each gets yes/no/defer. This is a blocking checkpoint — present and end the turn; don't proceed to the label step in the same breath. On yes, create an ADRs-database row per [ADR-FORMAT.md](../../_shared/ADR-FORMAT.md).

   **Toolchain-fact gate:** before writing any ADR, every load-bearing claim about an external system (stdlib behavior, build APIs, language defaults, third-party semantics) must be verified against the installed toolchain — read its source, run a probe, or dispatch a research sub-agent. Four ADRs in one project rotted on unverified external facts, all foreseeably.

7. **Determine the outcome label.**
   - **Exact match** — implemented exactly as the ticket and PRD specified.
   - **Extended** — as specified, plus extra scope that proved necessary or valuable.
   - **Divergence** — something different (approach or acceptance) than specified.
   - **Omitted** — abandoned or merged into another ticket. (If selecting this, prefer setting the ticket row's `Status = Abandoned` rather than running `/done`.)

   Propose the label with reasoning anchored in the captured deviations, and **name the strongest alternative label with why it loses**. Blocking confirm: present and wait for confirm or override.

8. **Append the retro entry** to the running retro in the active PRD row body (creating the retro section if absent — replaces `docs/prds/NNN-slug/retro.md`):

   ```markdown
   ## Ticket NNN — <ticket title>

   **Outcome**: <label>

   <1-3 sentences on what was learned>
   ```

   Capture *what was learned*, not *what was done* (the ticket row already has that).

9. **Flip the ticket** `Status` `In progress -> Done` via `update-page`. Ordering is strict: **fetch the ticket row -> update the Status property -> only then run git commands** — never batch the `update-page` call in parallel with git. (A failed edit inside a parallel batch once cascaded into ~20 cancelled git calls and an abandoned session.)

10. **Recommend `/improve-codebase-architecture`** for a per-ticket refactor pass: *"Recommend running `/improve-codebase-architecture` next for a refactor pass on this ticket. Optional but catches architectural rot while context is fresh."*

11. **Offer the close-out merge (gated).** *(Git — unchanged.)* Read the merge convention from the root page body config / the repo's CLAUDE.md, then offer: *"Merge the ticket branch back (`--no-ff`), verify green on the parent, delete the ticket branch?"*
    - **Offer, never auto-merge.** An unanswered offer blocks — it is not consent.
    - If the user is taking the `/improve` recommendation, the merge waits until after that pass (its refactor commits belong on the ticket branch).
    - On accept: merge `--no-ff`, run the repo's verification (build + tests), delete the ticket branch only after green. On failure, stop and surface it — don't delete the branch.

## Refusing to run

- If the ticket's `Status` is already `Done`, refuse. Suggest checking git history if the user wants to know what happened.

## Anti-patterns

- **Don't restructure the running retro.** This skill appends only. Restructuring is `/retro`'s job at PRD close.
- **Don't write what was done in the retro entry.** Capture *insight*, not *log*.
- **Don't trust the fact-checker's drafts blindly.** Review each finding against the cited diff; drop below-threshold noise.
- **Don't pad `## Deviations` to look thorough.** If nothing seam-level moved and behavior matched spec, leave it `_None._`.
- **Don't auto-invoke `/improve-codebase-architecture`.** Recommend it; let the user choose.
- **Don't skip the fact-check even when impl just happened in this session.** Notion-as-primary means it runs every time.
- **Don't merge without an explicit yes.** The close-out merge offer is a gate, not a notification.
- **Don't batch the `update-page` status flip in parallel with git commands.**
- **Don't treat a passing fact-check as truth-checked findings.** It audits diff-to-deviation mapping, not domain claims in findings docs — those need their own review.
