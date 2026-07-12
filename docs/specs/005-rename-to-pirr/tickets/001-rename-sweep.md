---
status: open
depends_on: []
---

# Rename the plugin from agentic-flow to pirr across its committed surface

## Goal

Rename the plugin from `agentic-flow` to `pirr` across its entire committed surface, as one atomic change. After this ticket the plugin installs and loads as `pirr`; its skills invoke as `pirr:setup` and `pirr:refactor` (formerly `setup-agentic-flow` and `improve-codebase-architecture`); its plugin-shipped agents resolve under the `pirr:` namespace; its per-repo config lives at `.pirr/`; and no tracked file names the old identity except where a migration note documents the change. The rename is a meaning-preserving relabel — same referents, new token — so it reaches frozen artifacts (closed specs, tickets, retros, ADRs) too, leaving the corpus with a single canonical name. The diff-materialization mechanism operates on `.pirr/` with its bats suite green.

## Acceptance criteria

- [ ] The plugin manifest and the marketplace entry name `pirr`; the marketplace `source` points at `plugins/pirr/`.
- [ ] Skills invoke as `pirr:setup` and `pirr:refactor`; no `setup-agentic-flow` or `improve-codebase-architecture` token remains in any tracked file.
- [ ] Every plugin-shipped agent resolves under the `pirr:` namespace; the Reviewers manifest and every agent description cite `/refactor`, not `/improve-codebase-architecture`.
- [ ] The per-repo config directory is `.pirr/`; `/setup`'s generator emits the `pirr` header and `.pirr/` layout, so a fresh setup run produces no `agentic-flow` residue.
- [ ] The diff-materialization script and its bats suite operate on `.pirr/`, and the bats suite passes.
- [ ] A repo-wide search for `agentic-flow`, `setup-agentic-flow`, and `improve-codebase-architecture` over tracked files returns no matches, except where the token is the explicit old→new subject of a migration note.
- [ ] The plugin README and `CONTEXT.md` opening line record the `pirr` backronym (Plan · Implement · Refactor · Retro); the name renders lowercase `pirr` everywhere else.
- [ ] The README "Frozen artifacts never edit" design note carries a one-line clause marking relabeling as the one sanctioned exception, with scope and decision edits still forbidden.
- [ ] The `refactor` skill's one-line listing description is reframed so the shorter name does not undersell its multi-reviewer review-and-improve scope.
- [ ] A README migration note documents the `.agentic-flow/` → `.pirr/` path for existing consumer repos, mirroring the PRD→spec migration note.
- [ ] Frozen artifacts — closed specs, tickets, retros, the ADRs that name the product, and the historical review doc — use `pirr`; ADR 0003's filename slug is renamed with its number and every by-number cross-reference intact.

## Implementation notes

Apply the replacement most-specific-first: `setup-agentic-flow` → `setup` and `.agentic-flow` → `.pirr` before bare `agentic-flow` → `pirr`, so the substring swap cannot corrupt the more-specific tokens; `improve-codebase-architecture` → `refactor` is independent (no shared substring). Match only the full tokens — the common words "setup" and "refactor" already in prose must not be touched. The plugin-directory rename (which redefines the invocation namespace) and the `agentic-flow:` → `pirr:` prose swap must land together, so no committed state has `pirr:` prose against an `agentic-flow`-loaded plugin. Path-level renames use `git mv`: `plugins/agentic-flow/`, `.agentic-flow/`, the two skill directories, `agentic-flow-review.md`, and ADR 0003's file. The bats suite passing is the acceptance signal for the one behavioral surface; everything else is prose verified by the zero-residual search. The untracked scratch tree (`fleet-*`, `diff.patch`) carries the old name but is not committed — leave it out of scope. When writing the migration note, ground its steps against a real consumer (`~/Documents/CODE/zig/pronghorn`) so they match an actual repo's surface.

## Deviations

_None yet._
