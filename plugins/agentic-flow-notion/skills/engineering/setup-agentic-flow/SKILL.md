---
name: setup-agentic-flow
description: Idempotent bootstrap for agentic-flow on a Notion-backed workspace. Provisions the private "Agentic-Flow" root page and its PRDs, Tickets, Glossary, ADRs, and Reviewers databases; populates Reviewers from defaults + heuristic detection against repo files. Use when initializing a project or refreshing the reviewer manifest after plugin updates.
---

# Setup agentic-flow (Notion)

Bootstrap a project to use agentic-flow with **Notion as the only store** — no `docs/prds/`, no local config. Idempotent: on first run it provisions the root page and databases; on re-run it refreshes the Reviewers database and reports diffs.

Reviewer *detection* still reads repo files (`Cargo.toml`, `go.mod`, …) — that reads the code, which never leaves git. Only the planning artifacts live in Notion.

## State contract

- **PRD state required**: n/a
- **Ticket state required**: n/a
- **Transition**: none

## What this creates (first run)

The private root page and its five databases, per the schemas in [NOTION-RESOLVER.md](../../_shared/NOTION-RESOLVER.md):

| Child | Replaces |
|---|---|
| `PRDs` database | `docs/prds/` + `status:` frontmatter + `.active` |
| `Tickets` database | `tickets/*.md` + `depends_on` + `_abandoned/` |
| `Glossary` database | `CONTEXT.md` |
| `ADRs` database | `docs/adr/` |
| `Reviewers` database | `docs/reviewers.md` |

Repo config (branching strategy, ticket-start research opener) lives in the **body of the root page**, not a `.toml`. These are the structural-marker artifacts — the explicit exception to lazy creation. PRDs, tickets, retros, and ADRs are still created lazily by the skills that produce them.

## Process

### First run

1. **Collision guard.** `notion-search` for `Agentic-Flow`. If an exact-title root already exists, this isn't a fresh setup — switch to re-run mode. If two+ exist, refuse and ask the user which to keep.
2. **Create the root page.** `create-pages` with no parent → workspace-level private page titled `Agentic-Flow`. Write the config section into its body (all options present, defaults stated, alternatives noted for discoverability — same discoverability intent the old `.toml` served).
3. **Create databases in dependency order** (`create-database`, `parent` = root page id):
   - `PRDs` first.
   - `Tickets` second, with the `PRD` relation pointing at the PRDs `data_source_id`; then `update-data-source` to add the `Depends on` self-relation once the Tickets `data_source_id` is known (two-step — see resolver doc).
   - `Glossary`, `ADRs`, `Reviewers` (order-independent).
4. **Verify by ID.** `notion-fetch` each created database by its returned id to confirm it exists. Do not rely on search here — search may lag (see resolver doc). Warn the user that the *next* skill may need a moment for search to index the new databases.
5. **Reviewer detection** (below). Propose the list, allow revision, then write rows into the `Reviewers` database.
6. Suggest the user mention agentic-flow in the repo's `CLAUDE.md` — suggest, don't write it.

### Re-run (refresh mode)

1. Resolve the root and databases (see resolver doc). Skip anything that exists.
2. Re-run reviewer detection. Diff against current `Reviewers` rows and surface:
   - New default reviewers from plugin updates → propose add.
   - Removed defaults → propose remove.
   - Newly-detected specialized reviewers (repo changed) → propose add.
   - Newly-undetected specialized reviewers (signal gone) → propose remove.
3. Apply confirmed changes via `create-pages` / `update-page` on the `Reviewers` database. If nothing differs, report "All up to date."

## Reviewer detection

### Default (always-on)
- `agentic-flow:qa-engineer` — test coverage, edge cases, missing tests
- `agentic-flow:software-architect` — module boundaries, deepening opportunities, leaky seams
- `agentic-flow:security-engineer` — input validation, auth, common vuln patterns

### Specialized (heuristic-detected from repo files)

| Reviewer | Signal |
|---|---|
| `agentic-flow:rust-expert` | `Cargo.toml` exists |
| `agentic-flow:elixir-expert` | `mix.exs` exists |
| `agentic-flow:go-expert` | `go.mod` exists |
| `agentic-flow:typescript-expert` | `tsconfig.json` exists |
| `agentic-flow:zig-expert` | `build.zig` exists |
| `agentic-flow:ux-ui-expert` | Repo ships a user-facing UI surface (web/TUI/native, any language). Ask if unclear. |

Each row stores `Agent`, `Kind` (default/specialized), and `Signal`. Detection rules expand as new reviewers ship.

### Empty-repo case
If no signal files exist, skip heuristic detection. Show the full specialized list and ask which apply to the planned project.

## Anti-patterns

- **Don't skip the collision guard.** Two `Agentic-Flow` roots make every downstream resolver ambiguous. Search before creating.
- **Don't create Tickets before PRDs.** The `PRD` relation needs the PRDs `data_source_id`; the self-relation needs a second `update-data-source` pass.
- **Don't trust search immediately after creating.** Verify databases by fetching their IDs; warn about index lag for the next skill.
- **Don't pre-populate the Glossary.** Terms are grown lazily by `/grill-me`. Bulk-adding upfront produces stale entries.
- **Don't list workflow agents in `Reviewers`.** That database is refactor-time reviewers only; workflow agents like `deviation-fact-checker` are invoked by their owning skills.
- **Don't auto-edit `CLAUDE.md`.** Suggest, don't write.
- **Don't fail on partial state.** If some databases exist, create only what's missing and report.
