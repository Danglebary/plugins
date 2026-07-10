---
status: in-progress
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

- Goal (store paths): extended the store migration to the artifact filename — `prd.md` → `spec.md` in both spec directories, and the migration note's step 1 tells consuming repos to do the same. AC #6 named only the directories, `ideas/`, and the pointer, but STORE.md's artifact map now encodes `docs/specs/<NNN>-<slug>/spec.md`, so leaving `prd.md` would break resolution at the new paths.
- Goal (branch convention): codified the ticket-branch prefix rule in `/next-ticket` — `spec-<NNN>/ticket-…` follows the parent spec branch's name, so tickets under a legacy `prd-<NNN>-<slug>` branch cut `prd-<NNN>/ticket-…`. Extends the Goal's "birth name" rule from the spec branch to its ticket branches, keeping this spec's remaining tickets on one prefix.
- Touched one accepted ADR: ADR-0003's citation of the banked Obsidian idea now reads `docs/specs/ideas/` — pure reference-rot repair after the store move; the decision text is untouched. ADR-0002's `docs/prds/**` narrative was left as-is (accurate history of what ticket 004 flagged).
- Added a legacy-store routing sentence to `/setup-agentic-flow`'s re-run detection and STORE.md's not-set-up check: a repo with `docs/prds/` and no `docs/specs/` predates the rename and routes to the migration note instead of being scaffolded a parallel store — new behavior no AC named, required so the rename doesn't turn legacy repos into false "first runs".
