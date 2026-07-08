---
status: open
depends_on: []
---

# Branch-aware banking and store visibility

## Goal

Banked thoughts and in-flight PRDs survive any checkout: spikes and ideas get a gated commit at bank time, PRD numbering can never collide with a PRD that lives only on its branch, and skills warn about unmerged PRD branches instead of concluding the store is empty.

## Acceptance criteria

- [ ] After writing a spike or idea (files store), `/to-prd` offers to commit the banked file on the current branch — a bare gated offer; no checkout ceremony and no workflow rationale in the skill prose.
- [ ] PRD numbering resolves the highest number across planning directories *and* `prd-*` branch names (local and remote), so a PRD in flight on its branch can never have its number reissued from another checkout.
- [ ] `/next-prd` and `/next-ticket`, before concluding that no PRDs exist or none is active, check for unmerged `prd-*` branches and name them ("PRD 001 appears in flight on `prd-001-…` — you may be on the wrong checkout") instead of proceeding on the empty view.

## Deviations

_None yet._
