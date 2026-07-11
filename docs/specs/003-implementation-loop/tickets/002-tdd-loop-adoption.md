---
status: in-progress
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

Cite the Convention doc from ticket 001; don't restate the contract. The narrowed prose is `/tdd`'s "Working within an agentic-flow ticket" section.

## Deviations

_None yet._
