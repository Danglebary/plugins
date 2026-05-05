# reviewers.md format

`docs/reviewers.md` is the per-repo manifest of reviewer agents that `/improve-codebase-architecture` dispatches when surfacing deepening opportunities.

Populated by `/setup-agentic-flow` during bootstrap based on default-on rules + heuristic detection of repo content. The user reviews and confirms the list. Re-running `/setup-agentic-flow` refreshes the manifest if the plugin ships new reviewers or repo content has changed enough to re-run detection.

## File path

`docs/reviewers.md` at the repo root (alongside other `docs/` content).

## Structure

A simple list of reviewer agent names, with optional brief notes. Each entry is one bullet:

- **Plugin-shipped reviewers** are namespaced as `<plugin-name>:<agent-name>` (e.g. `agentic-flow:qa-engineer`).
- **Repo-specific reviewers** are bare names corresponding to files in `.claude/agents/<name>.md`.

Recommended grouping into "Plugin-shipped (always-on)", "Plugin-shipped (specialized)", and "Repo-specific" sections, but the only required structure is the list itself.

## Example

```markdown
# reviewers.md

Reviewer agents dispatched by `/improve-codebase-architecture` for refactor candidate-finding.

## Plugin-shipped (always-on)

- `agentic-flow:qa-engineer` — test coverage, edge cases, missing tests
- `agentic-flow:software-architect` — module boundaries, deepening opportunities, leaky seams
- `agentic-flow:security-engineer` — input validation, auth, common vuln patterns

## Plugin-shipped (specialized)

- `agentic-flow:rust-expert` — included because `Cargo.toml` is present
- `agentic-flow:ux-ui-expert` — included because the repo ships a user-facing UI surface

## Repo-specific

- `payment-flow-reviewer` — deep payment domain knowledge (lives in `.claude/agents/`)
```

## What `/improve-codebase-architecture` does with this

1. Reads the manifest.
2. Verifies each listed agent name resolves to a registered agent (plugin-shipped or repo-specific). If any don't, refuses with a clear list of missing names — silent skipping is the trap to avoid (incomplete review presented as complete).
3. Dispatches all listed reviewers in parallel against the relevant diff (typically the just-closed ticket's diff, post-`/done`).
4. Merges their findings through the deepening framework before presenting candidates.

## Maintenance

- **Re-run `/setup-agentic-flow`** to refresh the manifest when plugin updates ship new always-on reviewers or when repo content has changed enough that specialized-reviewer detection should re-run. Idempotent — surfaces diffs and applies confirmed changes.
- **Edit manually** to add or remove specific reviewers. The list is plain markdown.
- **Repo-specific reviewers** are added by hand: create the `.md` file in `.claude/agents/`, then add the bare name to this manifest.

## Anti-patterns

- **Don't list non-reviewer agents here.** Workflow agents like `agentic-flow:deviation-fact-checker` are invoked by their owning skills, not via this manifest.
- **Don't list an agent that doesn't exist.** `/improve-codebase-architecture` will refuse to run with a clear error.
- **Don't add long-form descriptions per reviewer.** Keep entries to one bullet with a brief note. The reviewer's own AGENT.md carries the detail.
