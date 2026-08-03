# Reviewers manifest format

The Reviewers manifest is the per-repo list of reviewer agents that `/refactor` dispatches when surfacing deepening opportunities.

Populated by `/setup` during bootstrap based on default-on rules + heuristic detection of repo content. The user reviews and confirms the list. Re-running `/setup` refreshes the manifest if the plugin ships new reviewers or repo content has changed enough to re-run detection.

**Storage.** `docs/reviewers.md`, structured as below; the artifact map is [STORE.md](./STORE.md)'s.

## File path

`docs/reviewers.md` at the repo root (alongside other `docs/` content).

## Structure

A simple list of reviewer agent names, with optional brief notes. Each entry is one bullet:

- **Plugin-shipped reviewers** are namespaced as `<plugin-name>:<agent-name>` (e.g. `pirr:qa-engineer`).
- **Repo-specific reviewers** are bare names corresponding to files in `.claude/agents/<name>.md`.

Recommended grouping into "Plugin-shipped (always-on)", "Plugin-shipped (specialized)", and "Repo-specific" sections, but the only required structure is the list itself.

## Example

```markdown
# reviewers.md

Reviewer agents dispatched by `/refactor` for refactor candidate-finding.

## Plugin-shipped (always-on)

- `pirr:qa-engineer` — test coverage, edge cases, missing tests
- `pirr:software-architect` — module boundaries, deepening opportunities, leaky seams
- … (the authoritative default set lives in `/setup`'s reviewer detection — this example is illustrative, not the list to keep in sync)

## Plugin-shipped (specialized)

- `pirr:rust-expert` — included because `Cargo.toml` is present
- `pirr:ux-ui-expert` — included because the repo ships a user-facing UI surface

## Repo-specific

- `payment-flow-reviewer` — deep payment domain knowledge (lives in `.claude/agents/`)
```

## What `/refactor` does with this

1. Reads the manifest.
2. Composes its **Dispatch record** from these names — before the check below, and before any result arrives ([EVIDENCE-PRINCIPLE.md](./EVIDENCE-PRINCIPLE.md)). Every entry here becomes a record entry, so a name listed is a name accounted for.
3. Verifies each listed agent name resolves to a registered agent (plugin-shipped or repo-specific). If any don't, refuses with a clear list of missing names — silent skipping is the trap to avoid (incomplete review presented as complete).
4. Dispatches all listed reviewers in parallel against the relevant diff (typically the just-closed ticket's diff, post-`/done`), **passing each name here as `subagent_type` verbatim**. An entry's spelling *is* the dispatch, not a label for one — which is why a typo refuses at step 3 rather than silently reviewing with a general-purpose agent.
5. Merges their findings through the deepening framework before presenting candidates.

## Maintenance

- **Re-run `/setup`** to refresh the manifest when plugin updates ship new always-on reviewers or when repo content has changed enough that specialized-reviewer detection should re-run. Idempotent — surfaces diffs and applies confirmed changes.
- **Edit manually** to add or remove specific reviewers. The list is plain markdown.
- **Repo-specific reviewers** are added by hand: create the `.md` file in `.claude/agents/` following [AGENT-FORMAT.md](./AGENT-FORMAT.md) — a claim-making reviewer inherits the **Partial verdict** register and the **content channel** rule from that shape — then add the bare name to this manifest.

## Anti-patterns

- **Don't list non-reviewer agents here.** Workflow agents like `pirr:deviation-fact-checker` are invoked by their owning skills, not via this manifest.
- **Don't list an agent that doesn't exist.** `/refactor` will refuse to run with a clear error.
- **Don't add long-form descriptions per reviewer.** Keep entries to one bullet with a brief note. The reviewer's own AGENT.md carries the detail.
