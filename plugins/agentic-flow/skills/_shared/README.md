# Shared

Reference documents shared across multiple skills. Not skills themselves — these files do not appear in `plugin.json` and are not invoked directly.

Skills reference these via `../../_shared/<filename>.md` (two `..` — SKILL.md sits two levels below `skills/`). Two kinds of reference doc, distinguished by filename suffix: **format docs** (`<NAME>-FORMAT.md`) define the canonical shape of a document type; **principle docs** (`<NAME>-PRINCIPLE.md`) capture cross-cutting rules applying across multiple skills.

## Format docs

- [PRD-FORMAT.md](./PRD-FORMAT.md) — frozen multi-ticket scope document
- [TICKET-FORMAT.md](./TICKET-FORMAT.md) — single unit of work nested under a PRD
- [RETRO-FORMAT.md](./RETRO-FORMAT.md) — running and synthesized retrospective formats
- [ADR-FORMAT.md](./ADR-FORMAT.md) — cross-PRD architectural decision record
- [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md) — living domain glossary
- [REVIEWERS-FORMAT.md](./REVIEWERS-FORMAT.md) — list of reviewer agents applicable to a repo
- [AGENT-FORMAT.md](./AGENT-FORMAT.md) — plugin-shipped and repo-specific subagent definitions

## Principle docs

- [ABSTRACTION-LEVELS-PRINCIPLE.md](./ABSTRACTION-LEVELS-PRINCIPLE.md) — three levels (behavioral, seam-level, code-shape) and the rules that fall out: ticket voice, deviation threshold, rationale placement
