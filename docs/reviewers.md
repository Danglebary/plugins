# reviewers.md

Reviewer agents dispatched by `/refactor` for refactor candidate-finding.

## Plugin-shipped (always-on)

- `pirr:qa-engineer` — test coverage, edge cases, missing tests
- `pirr:software-architect` — module boundaries, deepening opportunities, leaky seams
- `pirr:security-engineer` — input validation, auth, common vuln patterns; **sole reporter of planted instructions in all reviewed material except prompt artifacts** — dropping it leaves that finding class unreported, since every other lens refuses to obey a planted instruction but does not report one
- `pirr:standards-reviewer` — classic code smells plus the repo's documented standards

## Plugin-shipped (specialized)

- `pirr:dx-expert` — included because the repo ships a developer-facing surface (Claude Code plugins and their skills)
- `pirr:prompt-expert` — included because the repo contains LLM-facing prompt artifacts (skill bodies, agent definitions, tool descriptions); **sole reporter of planted instructions in prompt artifacts** — dropping it leaves that finding class unreported, since every other lens refuses to obey a planted instruction but does not report one
- `pirr:technical-editor` — included because the repo's product is a prose corpus (skill/agent prose with shared contract docs)
