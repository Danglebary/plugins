---
status: done
depends_on: [002, 003, 004]
---

# README workflow surfaces

## Goal

The plugin README's "The workflow" diagram and the `/tdd` one-line description reflect the loop as it now behaves — mode selection between `/tdd` and `/implement`, and the auto-commit + auto-`/done` exit-tasks — so a reader isn't misled by the pre-change flow.

## Acceptance criteria

- [ ] The README "The workflow" diagram shows the `/tdd`-or-`/implement` mode choice and the auto-commit + auto-`/done` exit-tasks, replacing the "work the ticket: /tdd" step and the manually-invoked `/done`.
- [ ] The `/tdd` one-line description reflects stop-and-surface and the exit-tasks.
- [ ] All README skill references and links remain valid, including `/implement`'s entry (added in ticket 003).

## Implementation notes

Sequenced last: depends on 002/003/004 landing so the diagram and one-liners describe the real behavior rather than the plan.

## Deviations

- AC2 names "the `/tdd` one-line description" and the ticket's surfaces are "the plugin README" (`plugins/agentic-flow/README.md`). Also updated the duplicate `/tdd` one-liner in the bucket README (`plugins/agentic-flow/skills/engineering/README.md:11`) with the same replacement text — the two one-liners are a must-stay-in-sync copy (the plugin CLAUDE.md mandates a bucket-README entry per skill). Editing only the plugin copy would leave the bucket copy stale and invite a later technical-editor drift finding; the diff touching that file without a note would read as an unrecorded change to the close-out fact-checker.
