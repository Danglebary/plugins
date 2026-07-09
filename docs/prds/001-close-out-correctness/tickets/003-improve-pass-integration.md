---
status: open
depends_on: [001, 002]
---

# /improve pass integration

## Goal

`/improve-codebase-architecture` never strands a ticket branch or a deviation capture: every `(refactor)` entry gets a commit carrier, every pass — including a no-op — ends at the close-out merge offer, a post-merge invocation degrades to a deliberate ad-hoc pass with a named range, and outside-PRD deferrals are banked instead of evaporating.

## Acceptance criteria

- [ ] A `(refactor)` deviation entry is always committed: the capture is appended before or with the refactor commit that carries it, and a pending-store-edits check at the merge offer commits any straggler.
- [ ] A pass with no candidates, or none accepted, still ends at the close-out merge offer — no stranded ticket branches.
- [ ] Invoked after a merge-now close (ticket branch deleted), the skill routes to its ad-hoc scope arm and names the recoverable range (`<merge-commit>^1...<merge-commit>`, the `--no-ff` merge commit found by branch name); refactor commits land on the PRD branch and captures still append to the `Done` ticket.
- [ ] A deferral that belongs to no ticket in the active PRD is banked as an Idea, and idea-banked deferrals are included in the next pass's brief inputs so reviewers don't re-propose them.
- [ ] `/improve` materializes its diff via the shared convention and carries no stacked-mode or self-authored diff prose.

## Implementation notes

### Deferred steers

- From ticket 002's refactor pass: DIFF-MATERIALIZATION.md mandates the planning-artifact hunk label for *every* brief that hands a files-store diff to a reviewer agent — `/improve`'s step-4 reviewer briefs must carry it (ticket 002 added it to `/done`'s fact-checker brief only; the label's path boundary is now pinned in the shared doc).

## Deviations

_None yet._
