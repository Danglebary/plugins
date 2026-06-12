---
name: retro
description: Close a PRD by synthesizing the running retro into the structured form. Invokes the deviation-fact-checker against the full PRD branch diff for a final fact-check pass. Mirrors PRD sections with outcome labels, synthesizes a Refactor section from cumulative (refactor)-marked deviations, optionally adds a Cross-cutting appendix. Flips PRD open → done and clears .active. Use when all tickets in a PRD are complete.
---

# Retro

Close a PRD by synthesizing the running retro into structured form, with one final fact-check pass against the full PRD-branch diff.

Format references: [RETRO-FORMAT.md](../../_shared/RETRO-FORMAT.md), [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md) (deviation threshold).

## State contract

- **PRD state required**: `open` (with all tickets `done`)
- **Ticket state required**: n/a (verifies all tickets are `done` before proceeding)
- **Transition**: PRD `open → done`; clears `docs/prds/.active` if it points to this PRD

Refuses if any ticket isn't `done` (lists outstanding tickets) or if PRD is already `done` (closed chapter).

## Process

1. **Identify the PRD.** Default: the active PRD (per `docs/prds/.active`) if all its tickets are `done`. If `.active` is missing or its tickets aren't all done, look for any other `open` PRD with all tickets `done`. If multiple match or none match, ask.

2. **Verify all tickets are done.** Read every ticket file in `tickets/`. If any has `status: open` or `in-progress`, refuse with a list of outstanding tickets.

3. **Determine the PRD-branch diff range.** PRD branch (`prd-<NNN>-<slug>`) vs `main` (or repo default). If non-standard branching, ask the user for the range.
   
   **Verify the diff is complete before fact-checking it:** every `done` ticket's work must be reachable from the PRD branch tip. If a ticket branch was never merged back, the PRD diff is silently missing that ticket — stop and offer the close-out merge (`--no-ff`, verify green) before proceeding. Materialize the diff to `.agentic-flow/diff.patch`, same convention as `/done`.

4. **Invoke `agentic-flow:deviation-fact-checker`** with:
   - The PRD (`prd.md`)
   - All ticket files in `tickets/`
   - The PRD-branch diff
   - `CONTEXT.md`
   - Existing ADR titles + statuses
   
   The fact-checker returns the same three sections it does for `/done`, but at PRD scope. Same threshold applies (see [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md)) — below-threshold churn doesn't accumulate into deviations at PRD scope; don't surface it.
   
   Adversarially review findings against cited diff hunks. PRD-scope gaps tend to be cross-cutting things ticket-level diffs missed (a seam that shifted across multiple tickets but no single ticket captured it cleanly), not new instances of below-threshold churn.

5. **Apply confirmed late-stage updates.** Append any newly-discovered deviations to the relevant ticket's `## Deviations` (it's late, but better than missing them). Surface ADR candidates for explicit decision. If the fact-check returns `_None._` across the board, that's a clean PRD — proceed to synthesis.

6. **Read inputs for synthesis:**
   - `prd.md` — section structure and intent.
   - `retro.md` — running per-ticket entries with outcome labels.
   - Each ticket's `## Deviations` section — granular divergences (including `(refactor)`-marked entries).

7. **Synthesize per PRD section.** For each of the PRD's five sections (Problem, Goals, Non-goals, Approach, Modules touched):
   - Determine the dominant outcome label across the tickets that touched this section. If the section had no real activity (e.g. Non-goals usually doesn't change), label it `Exact match` and say so briefly.
   - Write 1–3 sentences of commentary anchored in concrete tickets and deviations. Reference tickets by number when a lesson is anchored in one.

8. **Synthesize the Refactor section** if any `(refactor)`-marked deviations exist across tickets. Aggregate into one section with an outcome label and 1–3 sentences. Reference specific tickets where the refactor work landed. Omit the section entirely if no `(refactor)` deviations exist.

9. **Optional Cross-cutting appendix.** If lessons don't fit any PRD section or the Refactor section (e.g. terminology issues that spanned multiple sections, CONTEXT.md updates that landed mid-PRD), capture them here. Omit when empty.

10. **Restructure `retro.md` in place — non-destructively.** Before writing, **inventory every section of the current `retro.md` that the synthesized form will not carry forward** — anything beyond the running per-ticket entries: findings notes, analysis writeups, co-resident deliverables from tickets or spikes. For each, either fold it into the synthesis or relocate it to its defined home (`docs/spikes/` for findings-type deliverables, the relevant ticket file, or wherever the user directs). **Present the drop-list and destinations to the user and wait for confirmation before rewriting** — this checkpoint is blocking. Only the running per-ticket entries are fair game to consume silently; they're what the synthesis is *made of*. The running form is preserved in git history, but git history is where content goes to be forgotten — relocation, not history, is the recovery path. (A synthesis pass once silently deleted a ticket's entire findings deliverable; this gate exists because of it.)

11. **Flip the PRD** `status` from `open` to `done`. Same ordering discipline as `/done`: read the file → edit the status → only then any git commands, never batched in parallel.

12. **Clear `.active`** by deleting `docs/prds/.active` *if it points to this PRD*. (If the user has manually set `.active` to a different PRD, leave it alone.)

## Synthesized structure

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

`## Refactor` and `## Cross-cutting` are both optional — omit when no relevant content exists.

## Refusing to run

- If the PRD is already `done`, refuse. The retro is closed.
- If any ticket isn't `done`, refuse with a list of outstanding tickets.

## Anti-patterns

- **Don't write `## Next steps`, `## Future work`, or `## Roadmap`.** Strictly backward-looking. Forward-looking lessons go into a new PRD.
- **Don't fabricate outcomes.** If you can't tell from the running retro, deviations, and fact-checker output what happened in a section, ask the user.
- **Don't lose ticket-level granularity.** Reference specific tickets by number when a lesson is anchored in one.
- **Don't include `## Refactor` or `## Cross-cutting` if there are no entries.** Omit them entirely.
- **Don't pad sections with below-threshold deviations to look thorough.** Internal refactors, private renames, formatting churn — none of that belongs in a synthesized retro. If a section's tickets had no above-threshold divergence, label it `Exact match` and move on.
- **Don't skip the fact-check step even if every `/done` already fact-checked cleanly.** PRD-level diff often surfaces things ticket-level diffs miss — particularly seams that shifted gradually across tickets where no single ticket captured the cumulative move.
- **Don't clear `.active` if it points to a different PRD than the one being closed.** The user may have switched context manually.
- **Don't drop content the synthesis didn't write.** Anything in `retro.md` beyond the running per-ticket entries gets inventoried and relocated with user confirmation, never silently consumed by the rewrite.
- **Don't apply a different deviation threshold than `/done` did.** The threshold (including its tooling-surface ruling) lives in [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md) alone — a change that passed the per-ticket fact-check must not flag at PRD scope under a stricter reading.
