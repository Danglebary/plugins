---
status: open
depends_on: [001]
---

# Implement skill

## Goal

A new `/implement` skill exists as a peer to `/tdd`, codifying the non-TDD path as plan-then-execute: it produces a plan the user approves, executes it, and on clean green completion runs the same exit-tasks — stopping-and-surfacing per the shared contract when it hits the always-stop list or an undecidable decision. It is discoverable alongside the other engineering skills.

## Acceptance criteria

- [ ] `/implement` exists as an `engineering/`-bucket skill and runs a plan-then-execute flow with a plan-approval gate before execution begins.
- [ ] It cites the shared Convention doc (ticket 001) for the stop/record contract and the exit-tasks, not restating them.
- [ ] On clean green completion it auto-commits and auto-invokes `/done` identically to `/tdd`; on the always-stop list or an undecidable decision it stops and surfaces.
- [ ] It is listed in the plugin top-level README and the `engineering/` bucket README, each linking the skill name to its `SKILL.md`.
- [ ] Its frontmatter leaves it model-invocable, so mode selection (ticket 004) and the workflow chain can reach it.

## Implementation notes

Follow the skill authoring rules in the plugin `CLAUDE.md` (top-level README reference, bucket README, model-invocability). The plan-approval gate mirrors `/tdd`'s plan-gate discipline (recommendation carries its three marks; approval blocks).

## Deviations

_None yet._
