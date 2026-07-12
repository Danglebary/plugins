---
status: open
depends_on: []
---

# /done surfaces contract tampering via a base/head compare script

## Goal

Give `/done` a mechanical alarm when a ticket branch rewrites the contract it will be judged against. A new dispatcher-side script compares the base and head versions of the guarded sections and reports which changed; `/done` runs it at close-out and surfaces a confirmation the user must acknowledge when the ticket's Goal/Acceptance or the spec's Approach moved base→head, with `## Deviations` exempt. The same script also emits the line-numbered base contract that ticket 003 consumes. Governed by ADR 0005; script placement per ADR 0002.

## Acceptance criteria

- [ ] A script under `plugins/agentic-flow/scripts/`, given base and head refs, reports per guarded section (`## Goal`, `## Acceptance criteria`, `## Approach`) whether it changed base→head — reading each version directly via `git show <ref>:<path>` and comparing by canonical heading (from that heading to the next `## ` or EOF).
- [ ] `## Deviations` is never compared or reported — the exemption falls out of extracting only the guarded sections.
- [ ] A renamed or removed guarded heading surfaces as changed (fails safe); an unrelated section inserted between guarded sections does not false-positive.
- [ ] The script also emits each guarded section's base text with absolute base line numbers prefixed (consumed by ticket 003).
- [ ] bats fixtures cover at least: unchanged section, edited section, renamed heading, removed heading, `## Deviations`-only edit, base-file-absent, and inserted-unrelated-section.
- [ ] `/done` runs the script during close-out and surfaces a confirm the user must acknowledge when any guarded section changed base→head; an untampered close-out surfaces no such confirm.
- [ ] git mechanics stay in the script and dispatcher; no reviewer agent gains git access. The script and the `/done` step cite ADR 0005 (and ADR 0002 for the placement).

## Implementation notes

Place the script alongside `scripts/materialize-diff.sh` and follow DIFF-MATERIALIZATION.md's division of labor — git-deterministic checks in the script; the skill resolves store-dependent inputs and routes the confirm. Reuse the base the diff-materialization convention already resolves (the spec branch for ticket scope) — no new base concept. The `/done` surface lands in step 3's close-out-brief area of `skills/engineering/done/SKILL.md`.

## Deviations

_None yet._
