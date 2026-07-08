---
status: open
depends_on: [002, 005]
---

# /next-ticket branch preconditions

## Goal

`/next-ticket` operates only on real branch state: it never creates the PRD branch, refuses with a pointer to the re-runnable bootstrap when the branch is missing, and its recovery and ride-along prose match the canonical copies established by tickets 002 and 005.

## Acceptance criteria

- [ ] Starting a ticket when the PRD branch doesn't exist refuses and names `/to-tickets`' re-enterable bootstrap as the fix; no lazy PRD-branch creation path remains anywhere in the skill.
- [ ] The ticket branch is still cut from the PRD branch on accept, citing the shared base-resolution convention.
- [ ] The dependency-reachability recovery mirrors `/done`'s canonical close-out recipe (commit close-out edits, then merge) rather than a merge-only recipe.
- [ ] The skill's copy of the ride-along rule matches the store doc's amended text (start-of-lifecycle flips ride; end-of-lifecycle flips are committed at close-out).

## Deviations

_None yet._
