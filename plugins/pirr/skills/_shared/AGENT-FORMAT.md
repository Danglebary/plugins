# AGENT.md format

Plugin-shipped agents live at `agents/<name>.md` at the plugin root. Repo-specific agents follow the same format at `.claude/agents/<name>.md`.

Auto-discovered by Claude Code's plugin loader. Plugin agents are namespaced at invocation time as `<plugin-name>:<agent-name>` (e.g. `pirr:qa-engineer`); repo-specific agents are referenced by bare name.

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

Whatever shape the body takes, a claim-making agent's `## Output format` ends with the **Partial verdict** register: contents gap-only, emission mandatory (`_Full._` when there is no gap), placed so that no halt instruction precedes it. A return carrying no register is off-contract. The rule lives in [EVIDENCE-PRINCIPLE.md](./EVIDENCE-PRINCIPLE.md) — an agent author inherits it by following this shape.

## Two classes of `pirr` agents

The plugin ships two kinds at `agents/`:

- **Reviewer agents** (e.g. `qa-engineer`, `software-architect`, `security-engineer`, plus specialized like `rust-expert`) — invoked by `/refactor` per the Reviewers manifest (`docs/reviewers.md` or the Reviewers database — see [STORE.md](./STORE.md)). Each provides a candidate-finding lens on a code diff.
- **Workflow agents** (e.g. `deviation-fact-checker`) — invoked by specific workflow skills (`/done`, `/retro`) for structured analytical tasks. Not in the Reviewers manifest.

Same AGENT.md format in either case. The distinction is which skill invokes them and whether they're listed in the Reviewers manifest.

## Output contracts for workflow agents

Workflow agents typically have a **structured output contract** that calling skills depend on. Document it explicitly in the agent's body so future-you can refine the agent without breaking callers.

Example contract from `deviation-fact-checker`:

```markdown
## Output format

Three finding sections, each may be empty (output `_None._` when so), followed by the Partial verdict register:

### Deviation gaps
[unrecorded changes from the diff that should be captured in `## Deviations`]

### Misrepresented deviations
[entries in `## Deviations` that don't match what the diff shows]

### ADR candidates
[architectural choices in the diff that may warrant an ADR per the three-gate test]

### Partial verdict
[surfaces within the lens that went unread — unavailable, denied, or unconsulted — each naming the surface and what checking it would have confirmed; `_Full._` when there is no gap]
```

Each finding cites the specific diff hunk(s) that support it (file path + line range), so the calling skill can verify cheaply. The **finding** sections are the parse contract — calling skills read them by exact heading; the register sits outside that contract, and a surface reported there is never also a finding ([EVIDENCE-PRINCIPLE.md](./EVIDENCE-PRINCIPLE.md)).

## Anti-patterns

- **Don't put `agents/` inside `.claude-plugin/`.** The loader looks at the plugin root only.
- **Don't use non-standard frontmatter fields.** Stick to `name`, `description`, `tools`, `model`.
- **Don't make agents broad or generalist.** Narrow expertise is what makes dispatch reliable and output trustworthy.
- **Don't list workflow agents in the Reviewers manifest.** That manifest is for reviewer agents only.
