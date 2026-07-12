---
status: done
depends_on: [001]
---

# TDD loop adoption

## Goal

`/tdd` adopts the shared loop contract so that a TDD ticket, on clean green completion, auto-commits the completed implementation and auto-invokes `/done` with no per-completion prompt, and stops-and-surfaces to the user on the hard always-stop list or an undecidable unplanned decision instead of committing past it. Its existing "append divergences as they emerge" guidance is narrowed so the always-stop subset stops rather than record-and-continues, leaving no contradictory in-flight instruction in the skill.

## Acceptance criteria

- [ ] After a `/tdd` run reaches all-green completion, the completed work is committed on the ticket branch and `/done` is invoked, with no "commit?" or "run `/done`?" prompt in between.
- [ ] The commit stages the implementation paths plus the ticket file (the riding `In progress` flip and any recorded Deviations) by explicit paths; the auto-invoked `/done` sees a clean tree and does not misroute to its interrupted-close-out path.
- [ ] Confirmed in a real ticket flow (not a stub): the actual `/done` is autonomously invoked on clean green completion.
- [ ] When the repo's verification is absent or red, or an undesigned decision/problem surfaces, `/tdd` surfaces the manual prompt and does **not** auto-commit.
- [ ] `/tdd` stops and surfaces on the always-stop list; its existing "append divergences as they emerge" prose is narrowed so the always-stop subset stops rather than continuing.
- [ ] `/tdd` cites the shared Convention doc for the contract rather than restating it.
- [ ] The red-green-refactor cycle is otherwise unchanged.

## Implementation notes

Cite the Convention doc from ticket 001; don't restate the contract. The narrowed prose is `/tdd`'s "Working within an pirr ticket" section.

## Deviations

- Goal / spec §Approach (spec.md:39): extended the narrowing beyond the AC-named "Working within an pirr ticket" section into `refactoring.md`. AC 5 scoped the edit to that one section, but the Goal's "no contradictory in-flight instruction in the skill" was left partial — `refactoring.md`'s "what gets captured where" still routed always-stop-list seam moves (module split/merge, public-API change, IO-surface change) to record-and-continue. Under the auto-commit-on-green exit task this ticket installs, a refactor-discovered always-stop move would auto-commit past its gate. Split that guidance so the always-stop subset stops-and-surfaces (citing the contract) while dependency-edge and plan-covered moves still record-and-continue. Surfaced by the spec-conformance close-out pass; fixed with user approval.
