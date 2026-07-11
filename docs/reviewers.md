# reviewers.md

Reviewer agents dispatched by `/improve-codebase-architecture` for refactor candidate-finding.

## Plugin-shipped (always-on)

- `agentic-flow:qa-engineer` — test coverage, edge cases, missing tests
- `agentic-flow:software-architect` — module boundaries, deepening opportunities, leaky seams
- `agentic-flow:security-engineer` — input validation, auth, common vuln patterns
- `agentic-flow:standards-reviewer` — classic code smells plus the repo's documented standards

## Plugin-shipped (specialized)

- `agentic-flow:dx-expert` — included because the repo ships a developer-facing surface (Claude Code plugins and their skills)
- `agentic-flow:prompt-expert` — included because the repo contains LLM-facing prompt artifacts (skill bodies, agent definitions, tool descriptions)
- `agentic-flow:technical-editor` — included because the repo's product is a prose corpus (skill/agent prose with shared contract docs)
