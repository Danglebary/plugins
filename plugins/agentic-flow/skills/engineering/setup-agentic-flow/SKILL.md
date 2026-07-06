---
name: setup-agentic-flow
description: Idempotent bootstrap and refresh for agentic-flow. Asks which store to use (in-repo files or Notion databases), provisions it — docs/prds/, docs/adr/, reviewers manifest, glossary, config for the files store; the private Agentic-Flow root page and its five databases for the notion store — and populates reviewers from defaults + heuristic detection. Use when initializing a repo or refreshing the reviewer manifest after plugin updates.
---

# Setup agentic-flow

Bootstrap a repo to use the agentic-flow workflow. Idempotent — safe to re-run any time. On first run, asks which **store** the planning artifacts should live in (see [STORE.md](../../_shared/STORE.md)) and provisions it. On subsequent runs, surfaces diffs in the Reviewers manifest and applies confirmed updates.

Reviewer *detection* always reads repo files (`Cargo.toml`, `go.mod`, …) — that reads the code, which never leaves git. Only where the planning artifacts live differs by store.

## State contract

- **PRD state required**: n/a
- **Ticket state required**: n/a
- **Transition**: none

Idempotent re-run is the way to refresh the Reviewers manifest after plugin updates ship new always-on reviewers, or after repo content has changed enough to re-run heuristic detection.

## Choosing the store (first run only)

Detect existing state first, per STORE.md's resolution order: an existing `docs/agentic-flow.toml` means the files store is already set up; an existing `Agentic-Flow` Notion root page means the notion store is. If either exists, this is a re-run — skip to refresh mode. If both exist, refuse and ask the user to remove one (the stale toml is usually the leftover).

Otherwise ask once: **"Where should planning artifacts live — in-repo files, or Notion databases?"** Briefly characterize the trade: files keep everything in git and reviewable in PRs; Notion gives databases, relations, and a UI, and requires the Notion MCP connection.

## What this creates (first run)

These are structural-marker artifacts — the explicit exception to the lazy-creation principle. All other artifacts (PRDs, tickets, retros, ADRs) are created lazily by the skills that produce them.

**Files store:**

| Path | Purpose |
|---|---|
| `docs/prds/` | PRD directories |
| `docs/adr/` | Architectural decision records |
| `docs/reviewers.md` | Reviewer agent manifest, populated with defaults + heuristic-detected |
| `CONTEXT.md` | Living domain glossary skeleton |
| `docs/agentic-flow.toml` | Repo config with commented defaults — also the store's structural marker |

**Notion store** — the private root page and its five databases, per the schemas in [NOTION-RESOLVER.md](../../_shared/NOTION-RESOLVER.md):

| Child | Holds |
|---|---|
| `PRDs` database | PRDs, spikes, ideas (by `Kind`); status, numbering, active flag, branch link |
| `Tickets` database | tickets, `PRD` relation, `Depends on` self-relation |
| `Glossary` database | domain terms |
| `ADRs` database | decision records |
| `Reviewers` database | reviewer agent manifest |

Config (branching strategy, ticket-start research opener) lives in the **body of the root page**, not a `.toml` — no local planning files at all in this store.

## Process — files store

### First run

1. Create empty directories: `docs/prds/`, `docs/adr/`.
2. Scaffold `CONTEXT.md` skeleton (asks user for project name).
3. Scaffold `docs/agentic-flow.toml` with all options present and defaults uncommented (commented-out alternatives included for discoverability).
4. Run reviewer detection (see below). Propose the list to the user, allow revision, then write `docs/reviewers.md`.
5. Suggest the user consider mentioning agentic-flow in their repo's `CLAUDE.md`.

### Re-run (refresh mode)

1. Skip directory creation (exist already). Skip `CONTEXT.md` and `docs/agentic-flow.toml` if they exist.
2. Re-run reviewer detection. Diff against current `docs/reviewers.md` and surface adds/removes (see refresh rules below). Apply confirmed changes. If nothing differs, report "All up to date."

## Process — notion store

### First run

1. **Collision guard.** `notion-search` for `Agentic-Flow`. If an exact-title root already exists, this isn't a fresh setup — switch to re-run mode. If two+ exist, refuse and ask the user which to keep.
2. **Create the root page.** `create-pages` with no parent → workspace-level private page titled `Agentic-Flow`. Write the config section into its body (all options present, defaults stated, alternatives noted — same discoverability intent the `.toml` serves in the files store).
3. **Create databases in dependency order** (`create-database`, `parent` = root page id):
   - `PRDs` first.
   - `Tickets` second, with the `PRD` relation pointing at the PRDs `data_source_id`; then `update-data-source` to add the `Depends on` self-relation once the Tickets `data_source_id` is known (two-step — see resolver doc).
   - `Glossary`, `ADRs`, `Reviewers` (order-independent).
4. **Verify by ID.** `notion-fetch` each created database by its returned id to confirm it exists. Do not rely on search here — search may lag (see resolver doc). Warn the user that the *next* skill may need a moment for search to index the new databases.
5. **Reviewer detection** (below). Propose the list, allow revision, then write rows into the `Reviewers` database.
6. Suggest the user mention agentic-flow in the repo's `CLAUDE.md` — suggest, don't write it.

### Re-run (refresh mode)

1. Resolve the root and databases (see resolver doc). Skip anything that exists; create only what's missing.
2. Re-run reviewer detection. Diff against current `Reviewers` rows and surface adds/removes (below). Apply confirmed changes via `create-pages` / `update-page`. If nothing differs, report "All up to date."

## Refresh rules (both stores)

Surface each of these as a proposal, never a silent change:

- **New default reviewers** added in plugin updates → propose to add.
- **Removed reviewers** (no longer in plugin) → propose to remove.
- **Newly-detected specialized reviewers** (repo content changed) → propose to add.
- **Newly-undetected specialized reviewers** (signal removed from repo) → propose to remove.

## Reviewer detection

### Default (always-on) reviewers

Always included regardless of repo content. v1 set:

- `agentic-flow:qa-engineer` — test coverage, edge cases, missing tests
- `agentic-flow:software-architect` — module boundaries, deepening opportunities, leaky seams
- `agentic-flow:security-engineer` — input validation, auth, common vuln patterns

### Specialized reviewers (heuristic-detected)

Activated when specific signals are present. Initial set (extends as the reviewer fleet grows):

| Reviewer | Signal |
|---|---|
| `agentic-flow:rust-expert` | `Cargo.toml` exists |
| `agentic-flow:elixir-expert` | `mix.exs` exists |
| `agentic-flow:go-expert` | `go.mod` exists |
| `agentic-flow:typescript-expert` | `tsconfig.json` exists |
| `agentic-flow:zig-expert` | `build.zig` exists |
| `agentic-flow:ux-ui-expert` | Repo ships a user-facing UI surface, regardless of language: web (React/Vue/Svelte/Angular/Solid in `package.json`; Phoenix LiveView in `mix.exs`; Elm; Gleam Lustre; Rust Yew/Leptos/Dioxus in `Cargo.toml`; Go Templ in `go.mod`; Django/Rails/server-rendered templates), TUI (ratatui, bubbletea, textual, Ink, brick), or native (SwiftUI, Jetpack Compose, Qt, GTK, Tauri, Electron, Flutter). Ask the user if unclear. |

(Detection rules expand as new specialized reviewers ship in plugin updates.)

### Empty-repo case

If no signal files exist (truly empty / fresh project), skip heuristic detection. Show the user the full available specialized list with descriptions and ask which (if any) apply to the planned project.

## Templates (files store)

### `CONTEXT.md` skeleton

```markdown
# <project-name>

<one-paragraph project summary, anchored in the Language terms below as they accumulate>

## Language

<terms will be added here as `/grill-me` sharpens them>

## Relationships

<relationships will be added here as terms accumulate>
```

Format reference: [CONTEXT-FORMAT.md](../../_shared/CONTEXT-FORMAT.md).

### `docs/agentic-flow.toml`

```toml
# agentic-flow per-repo configuration
# Generated by /setup-agentic-flow

[branching]
# How tickets relate to each other within a PRD branch.
# - "serial":  each ticket branch cuts from the PRD branch, merges back before next.
# - "stacked": each ticket branch cuts from the previous ticket's branch.
# Default is "serial". /next-ticket may prompt to confirm at the start of the
# second ticket of the first PRD; the choice is then persisted here.
strategy = "serial"
# Merge convention for ticket → PRD and PRD → main merges. /done's close-out
# offer and /next-ticket's reachability recovery read this instead of guessing.
# merge = "no-ff"

[ticket_start]
# When true, /next-ticket dispatches a research sub-agent as a standing
# ticket-start step: map relevant code/docs, verify external-toolchain
# assumptions, assess whether /tdd fits. The config is the standing consent —
# no per-ticket prompt.
# research_opener = true
```

All options ship with defaults uncommented and alternatives in comments — this is the discoverability mechanism for what knobs exist. The notion store writes the same options (same discoverability rule) into the root page body instead.

In **both stores**, ensure `.agentic-flow/` is in the repo's `.gitignore` (append if missing). It's the workflow's scratch directory — diff artifacts for the fact-checker, session handoff files — never a committed artifact.

Format references: [REVIEWERS-FORMAT.md](../../_shared/REVIEWERS-FORMAT.md), [AGENT-FORMAT.md](../../_shared/AGENT-FORMAT.md).

## Anti-patterns

- **Don't auto-edit `CLAUDE.md`.** Each repo's CLAUDE.md is the user's territory; suggest, don't write.
- **Don't pre-populate the Glossary.** It's grown lazily by `/grill-me` as terms get sharpened. Bulk-adding upfront produces stale entries.
- **Don't fail on partial state.** If some directories or databases exist already, just create what's missing and report.
- **Don't list workflow agents in the Reviewers manifest.** That manifest is for refactor-time reviewers only. Workflow agents like `agentic-flow:deviation-fact-checker` are invoked by their owning skills.
- **Don't omit commented alternatives from the config.** They're how the user discovers what options are configurable — in either store.
- **Don't set up both stores.** One store per repo; a stale `agentic-flow.toml` next to a Notion root makes resolution ambiguous (STORE.md resolves toml-first).
- **Notion: don't skip the collision guard.** Two `Agentic-Flow` roots make every downstream resolver ambiguous. Search before creating.
- **Notion: don't create Tickets before PRDs.** The `PRD` relation needs the PRDs `data_source_id`; the self-relation needs a second `update-data-source` pass.
- **Notion: don't trust search immediately after creating.** Verify databases by fetching their IDs; warn about index lag for the next skill.
