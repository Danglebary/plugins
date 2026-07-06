# Shared

Reference documents shared across multiple skills. Not skills themselves — these files do not appear in `plugin.json` and are not invoked directly.

Skills reference these via `../../_shared/<filename>.md` (two `..` — SKILL.md sits two levels below `skills/`). Three kinds of reference doc: **store docs** define where planning artifacts live; **format docs** (`<NAME>-FORMAT.md`) define the canonical shape of a document type; **principle docs** (`<NAME>-PRINCIPLE.md`) capture cross-cutting rules applying across multiple skills.

## Store docs

- [STORE.md](./STORE.md) — the store contract: the two backends (files / notion), resolution order, the artifact map, single-active discipline. **Skills are store-neutral; this is where their vocabulary resolves to concrete storage.**
- [NOTION-RESOLVER.md](./NOTION-RESOLVER.md) — the notion backend: pure-search resolution protocol, the five database schemas, root-page-body config, search-lag guards

## Format docs

Format docs define each artifact's *content shape* (sections, voice, thresholds), which applies in both stores, plus its files-store encoding (paths, frontmatter). The notion-store encodings live in [NOTION-RESOLVER.md](./NOTION-RESOLVER.md).

- [PRD-FORMAT.md](./PRD-FORMAT.md) — frozen multi-ticket scope document
- [TICKET-FORMAT.md](./TICKET-FORMAT.md) — single unit of work nested under a PRD
- [RETRO-FORMAT.md](./RETRO-FORMAT.md) — running and synthesized retrospective formats
- [ADR-FORMAT.md](./ADR-FORMAT.md) — cross-PRD architectural decision record
- [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md) — living domain glossary
- [REVIEWERS-FORMAT.md](./REVIEWERS-FORMAT.md) — list of reviewer agents applicable to a repo
- [AGENT-FORMAT.md](./AGENT-FORMAT.md) — plugin-shipped and repo-specific subagent definitions

## Principle docs

- [ABSTRACTION-LEVELS-PRINCIPLE.md](./ABSTRACTION-LEVELS-PRINCIPLE.md) — three levels (behavioral, seam-level, code-shape) and the rules that fall out: ticket voice, deviation threshold, rationale placement
