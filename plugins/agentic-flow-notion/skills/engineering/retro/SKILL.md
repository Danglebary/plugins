---
name: retro
description: Close a PRD by synthesizing the running retro into structured form. Invokes the deviation-fact-checker against the full PRD-branch git diff for a final pass. Mirrors PRD sections with outcome labels, synthesizes a Refactor section, optionally a Cross-cutting appendix. Flips PRD Status Open to Done and clears Active. Use when all tickets in a PRD are complete.
---

# Retro (Notion)

Close a PRD by synthesizing the running retro into structured form, with one final fact-check pass against the full PRD-branch **git diff**. The code and its diff stay in git; only the spec text and status move to Notion.

Resolve databases first — see [NOTION-RESOLVER.md](../../_shared/NOTION-RESOLVER.md). Deviation threshold: [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md).

## State contract

- **PRD state required**: `Status = Open` (all related tickets `Done`)
- **Ticket state required**: verifies all related tickets are `Done` before proceeding
- **Transition**: PRD `Status` Open → Done; clears `Active` if it's this PRD

Refuses if any ticket isn't `Done` (lists outstanding) or the PRD is already `Done`.

## Process

1. **Identify the PRD.** Default: the `Active = true` PRD if all its tickets are `Done`. Else any `Open` PRD with all tickets `Done`. If multiple or none match, ask.

2. **Verify tickets.** Query the Tickets database for rows related to this PRD. If any is `Open` or `In progress`, refuse with the list.

3. **Determine the git diff range.** Read the PRD row's `Branch` (e.g. `prd-003-auth`) and `Diff base` (default `main`). Diff `Branch` vs `Diff base`.

   **Verify the diff is complete before fact-checking:** every `Done` ticket's work must be reachable from the PRD branch tip. If a ticket branch was never merged back, the diff silently misses it — stop and offer the close-out merge (`--no-ff`, verify green) first. Materialize the diff to `.agentic-flow/diff.patch`. *(This step is unchanged from the file workflow — it operates on git, not Notion.)*

4. **Invoke `agentic-flow:deviation-fact-checker`** with the PRD (row + body), all related ticket rows, the PRD-branch diff, the Glossary, and existing ADR titles + statuses. It returns the same three sections it does for `/done`, at PRD scope. Same threshold — below-threshold churn doesn't accumulate; don't surface it. Adversarially review findings against cited diff hunks; PRD-scope gaps tend to be cross-cutting seams no single ticket captured.

5. **Apply confirmed late-stage updates.** Append newly-discovered deviations to the relevant ticket row's `## Deviations` (`update-page`). Surface ADR candidates for explicit decision (new rows in the ADRs database). If the fact-check is `_None._` across the board, proceed.

6. **Read inputs for synthesis:** the PRD body (section structure and intent), the running retro entries, and each ticket's `## Deviations` (including `(refactor)`-marked entries).

7. **Synthesize per PRD section.** For each of Problem, Goals, Non-goals, Approach, Modules touched: determine the dominant outcome label across the tickets that touched it; if a section had no real activity, label it `Exact match`. Write 1–3 sentences anchored in concrete tickets and deviations, referencing tickets by number.

8. **Synthesize the Refactor section** if any `(refactor)`-marked deviations exist — aggregate into one section with an outcome label and 1–3 sentences. Omit entirely if none.

9. **Optional Cross-cutting appendix** for lessons that fit no section (terminology that spanned sections, Glossary updates mid-PRD). Omit when empty.

10. **Restructure the retro in place — non-destructively.** The running retro lives in the PRD row body (or a linked retro page). Before writing, **inventory every part the synthesized form won't carry forward** — findings notes, analysis, co-resident deliverables. Fold each into the synthesis or relocate it to its home (a Spike row for findings-type deliverables, the relevant ticket row, or wherever the user directs). **Present the drop-list and destinations and wait for confirmation before rewriting** — this checkpoint is blocking. Only the running per-ticket entries are fair game to consume silently. Notion page history preserves the old body, but relocation, not history, is the recovery path. (A synthesis pass once silently deleted a ticket's entire findings deliverable; this gate exists because of it.)

11. **Flip the PRD** `Status` Open → Done (`update-page`). Read the row → edit status → then any git commands, never batched in parallel.

12. **Clear `Active`** on this PRD *if it's set*. (If the user manually set `Active` on a different PRD, leave it.)

## Synthesized structure (written to the PRD row body)

```markdown
# Retro: <PRD title>

## Problem — <outcome label>
<commentary>

## Goals — <outcome label>
<commentary>

## Non-goals — <outcome label>
<commentary>

## Approach — <outcome label>
<commentary>

## Modules touched — <outcome label>
<commentary>

## Refactor — <outcome label>
<commentary; aggregates (refactor)-marked deviations across tickets>

## Cross-cutting
- <bullet per cross-cutting lesson>
```

`## Refactor` and `## Cross-cutting` are optional — omit when empty.

## Refusing to run

- PRD already `Done` → refuse; the retro is closed.
- Any ticket not `Done` → refuse with the outstanding list.

## Anti-patterns

- **Don't write `## Next steps`, `## Future work`, or `## Roadmap`.** Strictly backward-looking; forward lessons go into a new PRD.
- **Don't fabricate outcomes.** If the running retro, deviations, and fact-check don't tell you what happened, ask.
- **Don't lose ticket-level granularity.** Reference specific tickets by number.
- **Don't include `## Refactor`/`## Cross-cutting` with no entries.**
- **Don't pad sections with below-threshold deviations.** Internal refactors, private renames, formatting churn don't belong. No above-threshold divergence → label `Exact match`.
- **Don't skip the fact-check even if every `/done` fact-checked cleanly.** PRD-level diff surfaces seams that shifted gradually across tickets.
- **Don't clear `Active` if it points to a different PRD.**
- **Don't drop content the synthesis didn't write.** Inventory and relocate with user confirmation; never silently consume.
