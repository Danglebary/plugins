---
status: done
depends_on: []
---

# Branch-aware banking and store visibility

## Goal

Banked thoughts and in-flight PRDs survive any checkout: spikes and ideas get a gated commit at bank time, PRD numbering can never collide with a PRD that lives only on its branch, and skills warn about unmerged PRD branches instead of concluding the store is empty.

## Acceptance criteria

- [ ] After writing a spike or idea (files store), `/to-prd` offers to commit the banked file on the current branch — a bare gated offer; no checkout ceremony and no workflow rationale in the skill prose.
- [ ] PRD numbering resolves the highest number across planning directories *and* `prd-*` branch names (local and remote), so a PRD in flight on its branch can never have its number reissued from another checkout.
- [ ] `/next-prd` and `/next-ticket`, before concluding that no PRDs exist or none is active, check for unmerged `prd-*` branches and name them ("PRD 001 appears in flight on `prd-001-…` — you may be on the wrong checkout") instead of proceeding on the empty view.

## Implementation notes

### Deferred steers

- From ticket 005's refactor pass: the unmerged-`prd-*` warning makes this ticket's skills the third consumer of the unmerged-`prd-*`/bootstrap-landed check. Consume the citable authority ticket 006's steer mints rather than inlining another uncited copy.

## Deviations

- The bare commit offer consumes none of CLOSE-OUT.md's machinery (no enumeration, no show-content-on-resume, no decline-wedge) and doesn't cite it — a single-file offer in house voice; citing the gate doc would import exactly the ceremony the criterion excludes.
- Offline degradation for the new sweeps: the warning consumers (`/next-prd`, `/next-ticket`) and numbering fall back to local + remote-tracking refs with a stale-view caveat instead of refusing — advisory checks shouldn't wedge offline sessions. STORE.md's live remote-observation rule is untouched; `/to-tickets`' serialize gate keeps strict live observation.
- STORE.md's branch-link state tests gained an **enumeration rule**: the shape gate's pattern applied as a filter (not a refusal), plus the `/`-glob divergence — `for-each-ref` patterns stop at `/`, `git branch --list` and `ls-remote` patterns cross it and pick up ticket branches. PRD numbering is recorded as a consumer of that rule only — branch names, never the predicates — and the consumers inventory adds both skills' unmerged sweeps.
