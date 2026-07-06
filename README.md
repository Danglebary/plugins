# danglebary/plugins

A [Claude Code](https://docs.claude.com/en/docs/claude-code) plugin marketplace.

## Plugins

- **[agentic-flow](./plugins/agentic-flow/)** — A small, composable set of skills for AI-augmented software development. PRD/ticket/retro hierarchy with plugin-shipped reviewer agents.
- **[agentic-flow-notion](./plugins/agentic-flow-notion/)** — Notion-backed variant of the same workflow: PRDs, tickets, glossary, ADRs, and reviewers live as Notion databases. Install alongside `agentic-flow`, which provides the shared agents and the `tdd` skill.

## Install

Add this marketplace to Claude Code, then install the plugin you want:

```
/plugin marketplace add danglebary/plugins
/plugin install agentic-flow@danglebary/plugins
```

## License

[MIT](./LICENSE)
