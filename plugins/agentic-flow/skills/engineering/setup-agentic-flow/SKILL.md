---
name: setup-agentic-flow
description: Idempotent bootstrap for agentic-flow: writes settings.toml, provisions the store, populates the Reviewers manifest. Use when initializing a repo or refreshing the manifest after plugin updates.
disable-model-invocation: true
---

# Setup agentic-flow

Bootstrap a repo to use the agentic-flow workflow. Idempotent — safe to re-run any time. On first run, asks the setup question below, writes `.agentic-flow/settings.toml` (the workflow config — see [STORE.md](../../_shared/STORE.md)), and provisions the store. On subsequent runs, surfaces diffs in the Reviewers manifest and applies confirmed updates.

## State contract

- **Spec state required**: n/a
- **Ticket state required**: n/a
- **Transition**: none

Idempotent re-run is the way to refresh the Reviewers manifest after plugin updates ship new always-on reviewers, or after repo content has changed enough to re-run heuristic detection.

## First run vs re-run

Detect existing state: `.agentic-flow/settings.toml` present, or `docs/specs/` exists (a shared repo where `.agentic-flow/` wasn't committed) → re-run; neither → first run. A repo with a legacy `docs/prds/` store instead predates the spec rename — point at the migration note in the plugin README rather than scaffolding a parallel `docs/specs/`.

A re-run never rewrites an existing `settings.toml` — even one carrying keys the current template no longer ships (e.g. a stale `strategy` from an older template). Stale keys and their leftover comments are inert per STORE.md's config read contract; a refresh over them succeeds, never refuses.

**One first-run question:**

1. **Commit or ignore** — *"Commit agentic-flow's local files (`.agentic-flow/`) to this repo, or keep them out of git? Personal repo → commit; shared repo where others don't use this → ignore."* The answer decides whether `.agentic-flow/` is appended to the **root** `.gitignore`.

## What this creates (first run)

These are structural-marker artifacts — the explicit exception to the lazy-creation principle. All other artifacts (specs, tickets, retros, ADRs) are created lazily by the skills that produce them.

| Path | Purpose |
|---|---|
| `.agentic-flow/settings.toml` | Workflow config |
| `.agentic-flow/.gitignore` | Deny-by-default guard so scratch (`diff.patch`, handoffs) can never be committed |
| `docs/specs/` | Spec directories |
| `docs/adr/` | Architectural decision records |
| `docs/reviewers.md` | Reviewer agent manifest, populated with defaults + heuristic-detected |
| `CONTEXT.md` | Living domain glossary skeleton |

## Process

### First run

1. Ask the first-run question.
2. Write `.agentic-flow/settings.toml` (template below).
3. Scaffold `.agentic-flow/.gitignore` (template below).
4. If the user chose **ignore**: append `.agentic-flow/` to the root `.gitignore` (create it if missing). If **commit**: leave the root `.gitignore` alone.
5. Create empty directories: `docs/specs/`, `docs/adr/`.
6. Scaffold `CONTEXT.md` skeleton (asks user for project name).
7. Run reviewer detection (see below). Propose the list to the user, allow revision, then write `docs/reviewers.md`.
8. Suggest the user consider mentioning agentic-flow in their repo's `CLAUDE.md` — suggest, don't write it.

### Re-run (refresh mode)

1. Skip anything that exists (`settings.toml`, directories, `CONTEXT.md`); create only what's missing (an existing `settings.toml` is never rewritten — see "First run vs re-run").
2. Re-run reviewer detection. Diff against current `docs/reviewers.md` and surface adds/removes (see refresh rules below). Apply confirmed changes. If nothing differs, report "All up to date."

## Refresh rules

Surface each of these as a proposal, never a silent change:

- **New default reviewers** added in plugin updates → propose to add.
- **Removed reviewers** (no longer in plugin) → propose to remove.
- **Newly-detected specialized reviewers** (repo content changed) → propose to add.
- **Newly-undetected specialized reviewers** (signal removed from repo) → propose to remove.

## Reviewer detection

### Default (always-on) reviewers

Always included regardless of repo content:

- `agentic-flow:qa-engineer` — test coverage, edge cases, missing tests
- `agentic-flow:software-architect` — module boundaries, deepening opportunities, leaky seams
- `agentic-flow:security-engineer` — input validation, auth, common vuln patterns
- `agentic-flow:standards-reviewer` — classic code smells plus the repo's documented standards

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
| `agentic-flow:dx-expert` | Repo ships a developer-facing surface: a CLI (`bin/`, `cmd/`, clap/cobra/commander/argparse deps), a library or SDK with a public API, a plugin or extension, or a config-driven tool. Ask the user if unclear. |
| `agentic-flow:prompt-expert` | Repo contains LLM-facing prompt artifacts: Claude Code plugins or skills (`.claude-plugin/`, `SKILL.md`, `agents/*.md`), instruction files (`CLAUDE.md`, `.claude/`), system prompts or prompt templates assembled in code, or LLM pipeline definitions. |
| `agentic-flow:technical-editor` | Repo's product or spec surface is a substantial prose corpus: multi-document specs or contracts, RFC/ADR sets, documentation-as-product, or plugin/skill prose. Ask the user if unclear. |

(Detection rules expand as new specialized reviewers ship in plugin updates.)

### Empty-repo case

If no signal files exist (truly empty / fresh project), skip heuristic detection. Show the user the full available specialized list with descriptions and ask which (if any) apply to the planned project.

## Templates

### `.agentic-flow/settings.toml`

```toml
# agentic-flow per-repo configuration
# Generated by /setup-agentic-flow

[branching]
# Merge convention for ticket → spec and spec → main merges — read by whichever
# skill runs CLOSE-OUT.md's gated merge; that doc's Consumers section owns the
# reader list. Never guessed.
# merge = "no-ff"
```

Every knob ships in the template — present but commented, each comment naming its effect and readers. Presence in the file is the discoverability mechanism for what knobs exist.

### `.agentic-flow/.gitignore`

Write the deny-by-default template of record from [STORE.md](../../_shared/STORE.md) verbatim (`scripts/materialize-diff.sh` is the other scaffolder of the same block — keep the two in sync via STORE.md):

```gitignore
# deny by default, whitelist durable files
*
!.gitignore
!settings.toml
```

Scratch (`diff.patch`, handoffs) can never be committed by accident; future durable files are whitelisted one `!` line at a time. (Under `*`, whitelisting a file in a future *subdirectory* needs the directory un-ignored first: `!subdir/`, then `!subdir/file`.)

### `CONTEXT.md` skeleton

```markdown
# <project-name>

<one-paragraph project summary, anchored in the Language terms below as they accumulate>

## Language

<terms will be added here as `/grill-me` sharpens them>

## Relationships

<relationships will be added here as terms accumulate>
```

Format references: [CONTEXT-FORMAT.md](../../_shared/CONTEXT-FORMAT.md), [REVIEWERS-FORMAT.md](../../_shared/REVIEWERS-FORMAT.md), [AGENT-FORMAT.md](../../_shared/AGENT-FORMAT.md).

## Anti-patterns

- **Don't auto-edit `CLAUDE.md`.** Each repo's CLAUDE.md is the user's territory; suggest, don't write.
- **Don't pre-populate the Glossary.** It's grown lazily by `/grill-me` as terms get sharpened. Bulk-adding upfront produces stale entries.
- **Don't fail on partial state.** If some directories exist already, just create what's missing and report.
- **Don't list workflow agents in the Reviewers manifest.** That manifest is for refactor-time reviewers only. Workflow agents like `agentic-flow:deviation-fact-checker` are invoked by their owning skills.
- **Don't omit commented alternatives from `settings.toml`.** They're how the user discovers what options are configurable.
- **Don't append `.agentic-flow/` to the root `.gitignore` unconditionally.** That's the commit-vs-ignore question's answer — a personal repo commits it.
