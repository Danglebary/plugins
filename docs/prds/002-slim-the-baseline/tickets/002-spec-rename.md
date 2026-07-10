---
status: open
depends_on: [001]
---

# Rename PRD to spec

## Goal

The frozen scope artifact is called a spec everywhere the plugin speaks: skill names (`/to-spec`, `/next-spec`), shared docs (SPEC-FORMAT.md), the branch convention (`spec-<NNN>-<slug>`, `spec-<NNN>/ticket-…`), store paths (`docs/specs/**`), frontmatter, and prose. This repo's own planning store migrates to the new paths in the same change so the renamed skills keep working against it, and consuming repos get a short migration note. The branch this work rides on keeps its birth name — the new convention applies from the next spec onward.

## Acceptance criteria

- [ ] `grep -ri prd plugins/agentic-flow/` matches only the migration note and any deliberate legacy-branch handling prose — nowhere else.
- [ ] Skill directories, names, and frontmatter renamed (`to-prd`→`to-spec`, `next-prd`→`next-spec`); plugin.json, READMEs, and cross-references resolve; the renamed slash commands work.
- [ ] PRD-FORMAT.md is SPEC-FORMAT.md; status lifecycle and section structure are unchanged, vocabulary is spec.
- [ ] New specs cut `spec-<NNN>-<slug>` branches; numbering and unmerged sweeps scan both `spec-*` and legacy `prd-*` patterns, so live legacy branches stay visible to preconditions and number reservation.
- [ ] The branch link resolves the in-flight legacy-named branch: with the store migrated, `/next-ticket` and `/done` still find `prd-002-slim-the-baseline` from the `002-slim-the-baseline` directory without the branch being renamed.
- [ ] This repo's store is migrated with history (`git mv`): `docs/prds/` → `docs/specs/` including both spec directories, `ideas/`, and the active pointer; skills resolve the store at the new paths.
- [ ] A migration note covers consuming repos: move `docs/prds` → `docs/specs`, land or rename live `prd-*` branches, and do it between specs, not mid-flight.

## Implementation notes

- The branch sweeps must not go blind to legacy branches mid-transition — scan both patterns rather than requiring immediate renames.

## Deviations

_None yet._
