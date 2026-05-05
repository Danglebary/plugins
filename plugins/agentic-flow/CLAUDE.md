Skills are organized into bucket folders under `skills/`:

- `engineering/` — daily code work
- `productivity/` — daily non-code workflow tools
- `_shared/` — format reference docs shared across skills (not skills themselves)

Every skill in `engineering/` or `productivity/` must have a reference in the top-level `README.md` and an entry in `.claude-plugin/plugin.json`.

Each skill entry in the top-level `README.md` must link the skill name to its `SKILL.md`.

Each bucket folder has a `README.md` that lists every skill in the bucket with a one-line description, with the skill name linked to its `SKILL.md`.

Format docs in `skills/_shared/` are referenced from individual skills via `../../_shared/<NAME>-FORMAT.md` (two `..` — SKILL.md sits two levels below `skills/`). They are not skills and do not appear in `plugin.json`.

Load-bearing design rules live in the "Design notes" section of the top-level `README.md`. Skills should not silently deviate from them.
