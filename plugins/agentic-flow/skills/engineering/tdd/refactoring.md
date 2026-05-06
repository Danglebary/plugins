# Refactor candidates

After the TDD cycle, take a critical second pass at the code you just wrote. The behavior is correct (the tests prove it); now check whether the *shape* holds up.

## Lenses

- **Duplication** → extract function/class, or absorb into an existing one if the duplication crosses a module boundary that no longer makes sense.
- **Long methods** → break into private helpers (keep tests on the public interface).
- **Shallow modules** → combine or deepen. A module whose interface is roughly the same size as its implementation isn't earning its boundary; either deepen it (push more behavior behind the same interface) or inline it into a neighbor.
- **Module shape** → now that this behavior exists, does the boundary still fit? A module that's grown two responsibilities wants to split. A module whose seam with a neighbor has stopped paying for itself wants to merge.
- **Logic / IO coupling** → pure logic tangled with side-effecting code is a smell. Pull pure logic inward (functional core), push IO to the edges (imperative shell). Mocking is a sign you got this wrong; if a test needs to mock an internal collaborator, the seam is in the wrong place.
- **Feature envy** → move logic to where the data lives.
- **Primitive obsession** → introduce value objects when a primitive is being passed around with implicit invariants.
- **What the new code reveals about existing code** → the new behavior often surfaces problems in the code it touches. A function that wanted a different signature, a module that wanted a different boundary. Address what surfaces; don't pretend you didn't see it.

## What gets captured where

- **Seam-level moves** (module split/merge, public API change, dependency edge change, IO surface change) → ticket's `## Deviations` section, with a `(refactor)` prefix.
- **Internal cleanups** (private renames, dedup inside a module, control-flow tidy-up, idiomatic refactors) → not captured. Below threshold.
- **Why a specific code shape was chosen** (when the WHY is non-obvious) → inline comment next to the code. Not in deviations, not in the ticket.

See [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md) for the full threshold.

## Stop conditions

Run the tests after each refactor step. If a refactor breaks tests:
- The refactor is wrong (you changed observable behavior unintentionally), or
- The tests were testing implementation, not behavior. See [tests.md](tests.md).

Stop refactoring when the lenses above stop surfacing things. Don't keep going for the sake of it — a clean second pass is a successful second pass.
