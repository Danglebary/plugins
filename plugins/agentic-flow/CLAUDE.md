Skills are organized into bucket folders under `skills/`:

- `engineering/` — daily code work
- `productivity/` — daily non-code workflow tools
- `_shared/` — reference docs shared across skills (not skills themselves): store docs (`STORE.md`), format docs (`<NAME>-FORMAT.md`), principle docs (`<NAME>-PRINCIPLE.md`), and convention docs (shared procedures consumed by multiple skills — some with a plugin-shipped mechanism at their core, e.g. `DIFF-MATERIALIZATION.md` + `scripts/materialize-diff.sh`; some pure procedure, e.g. `CLOSE-OUT.md`)

Every skill in `engineering/` or `productivity/` must have a reference in the top-level `README.md`.

Each skill entry in the top-level `README.md` must link the skill name to its `SKILL.md`.

Each bucket folder has a `README.md` that lists every skill in the bucket with a one-line description, with the skill name linked to its `SKILL.md`.

Reference docs in `skills/_shared/` are referenced from individual skills via `../../_shared/<filename>.md` (two `..` — SKILL.md sits two levels below `skills/`). They are not skills and do not appear in `plugin.json`. Format docs use the `<NAME>-FORMAT.md` naming convention; principle docs (cross-cutting rules applying across multiple skills) use `<NAME>-PRINCIPLE.md`.

Load-bearing design rules live in the "Design notes" section of the top-level `README.md`. Skills should not silently deviate from them.
