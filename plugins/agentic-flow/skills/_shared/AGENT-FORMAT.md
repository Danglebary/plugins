# AGENT.md format

Plugin-shipped agents live at `agents/<name>.md` at the plugin root. Repo-specific agents follow the same format at `.claude/agents/<name>.md`.

Auto-discovered by Claude Code's plugin loader. Plugin agents are namespaced at invocation time as `<plugin-name>:<agent-name>` (e.g. `agentic-flow:qa-engineer`); repo-specific agents are referenced by bare name.

## File paths

- **Plugin-shipped:** `agents/<name>.md` at the plugin root. **Not** inside `.claude-plugin/` — that's a common mistake; agents won't be discovered there.
- **Repo-specific:** `.claude/agents/<name>.md` in the consuming repo.

## Frontmatter

```yaml
---
name: <agent-name>           # required; matches the filename
description: <one-line description of the agent's purpose>
tools: [Tool1, Tool2]        # optional; restricts available tools
model: <model-id>            # optional; override default
---
```

The `description` is what the dispatcher sees when deciding whether to invoke this agent. Be specific enough to distinguish from other agents.

**Don't add custom frontmatter fields** like `default: true` or `applies_to: [...]`. The plugin spec accepts only `name`, `description`, `tools`, `model`. Knowledge about which agents are default-on or how to detect applicability lives in the bootstrap skill, not in agent frontmatter.

## Body

The Markdown body is the agent's system prompt. Structure freely, but a typical shape:

```markdown
# <Role>

<one-paragraph framing — who this agent is, what it specializes in>

## Process

<step-by-step approach when invoked>

## Output format

<structured shape the agent produces; calling skills depend on this>

## Anti-patterns

<what NOT to do; reliability traps>
```

## Two classes of `agentic-flow` agents

The plugin ships two kinds at `agents/`:

- **Reviewer agents** (e.g. `qa-engineer`, `software-architect`, `security-engineer`, plus specialized like `rust-expert`) — invoked by `/improve-codebase-architecture` per the manifest in `docs/reviewers.md`. Each provides a candidate-finding lens on a code diff.
- **Workflow agents** (e.g. `deviation-fact-checker`) — invoked by specific workflow skills (`/done`, `/retro`) for structured analytical tasks. Not in `docs/reviewers.md`.

Same AGENT.md format in either case. The distinction is which skill invokes them and whether they're listed in `docs/reviewers.md`.

## Output contracts for workflow agents

Workflow agents typically have a **structured output contract** that calling skills depend on. Document it explicitly in the agent's body so future-you can refine the agent without breaking callers.

Example contract from `deviation-fact-checker`:

```markdown
## Output format

Three sections, each may be empty (output `_None._` when so):

### Deviation gaps
[unrecorded changes from the diff that should be captured in `## Deviations`]

### Misrepresented deviations
[entries in `## Deviations` that don't match what the diff shows]

### ADR candidates
[architectural choices in the diff that may warrant an ADR per the three-gate test]
```

Each finding cites the specific diff hunk(s) that support it (file path + line range), so the calling skill can verify cheaply.

## Anti-patterns

- **Don't put `agents/` inside `.claude-plugin/`.** The loader looks at the plugin root only.
- **Don't use non-standard frontmatter fields.** Stick to `name`, `description`, `tools`, `model`.
- **Don't make agents broad or generalist.** Narrow expertise is what makes dispatch reliable and output trustworthy.
- **Don't list workflow agents in `docs/reviewers.md`.** That manifest is for reviewer agents only.
