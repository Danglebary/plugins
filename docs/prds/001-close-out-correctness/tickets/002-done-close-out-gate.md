---
status: done
depends_on: [001]
---

# /done close-out commit gate

## Goal

`/done` closes a ticket on the files store without a git refusal: it refuses at start when implementation isn't committed, commits every store edit its invocation makes at one gated close-out step, and forks between merging now (explicitly skipping the refactor pass) and deferring the merge to `/improve`. This ticket's close-out recipe is the canonical copy that tickets 004 and 006 mirror.

## Acceptance criteria

- [ ] `/done` materializes the ticket diff via the shared convention at start; a dirty tree refuses with a message that names the implementation-committed-before-close convention and prints the offending paths.
- [ ] All store edits made during the close (materialized deviations, retro entry, Done flip, any ADR minted at the candidate gate) are committed on the ticket branch by one gated offer, staged as enumerated paths — never `-A`.
- [ ] The gate forks: "merge now" merges per the configured convention and explicitly states the per-ticket refactor pass is being skipped; "defer" leaves the merge to `/improve`'s close-out offer.
- [ ] Re-running `/done` after a crash between the store edits and the commit resumes at the gated commit — it is not misread as an already-`Done` ticket or as uncommitted implementation.
- [ ] Declining the gate states the wedged intermediate state plainly (uncommitted close-out edits; what to do before switching branches).
- [ ] `/done` carries no stacked-mode branching prose and no self-authored diff/git procedure.
- [ ] The store doc's ride-along rule states that end-of-lifecycle flips are committed as part of close-out.
- [ ] The commit gates are files-store-only: on the notion store the skill performs its store edits without a commit step and proceeds directly to the merge gate.

## Deviations

- Extended `/done`'s fact-checker brief with the planning-artifact hunk label — [DIFF-MATERIALIZATION.md](../../../../plugins/agentic-flow/skills/_shared/DIFF-MATERIALIZATION.md) mandates it for every brief that hands over a files-store diff, so consuming the convention without it would breach the shared contract; the criteria list didn't name the brief.
- Synced the plugin README's workflow chain and both README one-liners for `/done` to the new ending (gated close-out commit, merge-now/defer fork) per the repo's README rules — not named by the criteria.
- (refactor) Deepened `/done`'s interrupted-close-out recovery seam: the exit-5 interpretation is now exhaustive over dirt-class × flip-state (pre-flip interruptions resume idempotently via artifact presence; mixed dirt commits implementation only, preserving the resume signal), re-entry enumerates from `git status` including untracked store paths (a minted ADR or first-ticket retro.md was silently droppable), the store-artifact classifier is pinned to STORE.md's artifact map at every decision point, and DIFF-MATERIALIZATION's exit-5 contract now delegates the carve-out it can't own instead of contradicting its first consumer.
- (refactor) `/done`'s already-`Done` refusal became merge-aware: a `Done`-but-unmerged ticket (the defer arm's normal resting state) re-presents the close-out fork instead of dead-ending at "check git history" — the ticket-scope mirror of the PRD's re-enterable-last-gate rule for `/retro`.
