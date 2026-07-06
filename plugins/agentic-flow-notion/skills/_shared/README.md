# Shared

Reference documents shared across multiple skills. Not skills themselves — these files are not in `plugin.json` and are not invoked directly. Skills reference them via `../../_shared/<filename>.md` (two `..` — a `SKILL.md` sits at `skills/<category>/<name>/`, two levels below `skills/`).

## Canonical schema (Notion-only workflow)

- [NOTION-RESOLVER.md](./NOTION-RESOLVER.md) — the pure-search resolution protocol, the five database schemas, the file-to-Notion mapping, single-active enforcement, root-page-body config, and the template limitation. **This is the source of truth for where and how planning artifacts are stored.**

## Live reference docs

- [ADR-FORMAT.md](./ADR-FORMAT.md) — the three-gate test and ADR body shape, mapped onto the ADRs database row.
- [AGENT-FORMAT.md](./AGENT-FORMAT.md) — plugin-shipped and repo-specific subagent definition format (agents are still files; this plugin shares them from the base `agentic-flow` plugin's `agents/`).
- [ABSTRACTION-LEVELS-PRINCIPLE.md](./ABSTRACTION-LEVELS-PRINCIPLE.md) — the three levels (behavioral, seam-level, code-shape) and the rules that fall out: ticket voice, deviation threshold, rationale placement. World-agnostic; identical copy of the base plugin's file (kept local because skills reference it by relative path).

The pre-Notion file formats (`PRD-FORMAT.md`, `TICKET-FORMAT.md`, `RETRO-FORMAT.md`, `CONTEXT-FORMAT.md`, `REVIEWERS-FORMAT.md`) live in the base `agentic-flow` plugin; their Notion equivalents are the database schemas in `NOTION-RESOLVER.md`.
