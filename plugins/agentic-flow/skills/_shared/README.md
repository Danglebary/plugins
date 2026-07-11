# Shared

Reference documents shared across multiple skills. Not skills themselves — these files do not appear in `plugin.json` and are not invoked directly.

Skills reference these via `../../_shared/<filename>.md` (two `..` — SKILL.md sits two levels below `skills/`). Four kinds of reference doc: **store docs** define where planning artifacts live; **format docs** (`<NAME>-FORMAT.md`) define the canonical shape of a document type; **principle docs** (`<NAME>-PRINCIPLE.md`) capture cross-cutting rules applying across multiple skills; **convention docs** define a shared procedure consumed by multiple skills — some with a plugin-shipped mechanism at their core, some pure procedure.

## Store docs

- [STORE.md](./STORE.md) — the store contract: the artifact map, config read contract, branch-link state tests, single-active discipline. **This is where skill vocabulary resolves to concrete paths and encodings.**

## Format docs

Format docs define each artifact's *content shape* (sections, voice, thresholds) plus its encoding (paths, frontmatter).

- [SPEC-FORMAT.md](./SPEC-FORMAT.md) — frozen multi-ticket scope document
- [TICKET-FORMAT.md](./TICKET-FORMAT.md) — single unit of work nested under a spec
- [RETRO-FORMAT.md](./RETRO-FORMAT.md) — running and synthesized retrospective formats
- [ADR-FORMAT.md](./ADR-FORMAT.md) — cross-spec architectural decision record
- [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md) — living domain glossary
- [REVIEWERS-FORMAT.md](./REVIEWERS-FORMAT.md) — list of reviewer agents applicable to a repo
- [AGENT-FORMAT.md](./AGENT-FORMAT.md) — plugin-shipped and repo-specific subagent definitions

## Principle docs

- [ABSTRACTION-LEVELS-PRINCIPLE.md](./ABSTRACTION-LEVELS-PRINCIPLE.md) — three levels (behavioral, seam-level, code-shape) and the rules that fall out: ticket voice, deviation threshold, rationale placement

## Convention docs

- [DIFF-MATERIALIZATION.md](./DIFF-MATERIALIZATION.md) — the diff-materialization contract: the invoking skill resolves `<base>`/`<head>` per scope; the plugin-shipped script (`scripts/materialize-diff.sh`) owns the git mechanics, preflights, and the `.agentic-flow/diff.patch` artifact
- [CLOSE-OUT.md](./CLOSE-OUT.md) — the close-out contract: the gated store-edits commit (enumerated paths, show-content-on-resume), the gated merge (convention read, verify green before branch delete), and the resting-state/interrupted-close discriminator every closing skill routes on
- [IMPLEMENTATION-LOOP.md](./IMPLEMENTATION-LOOP.md) — the implementation-loop contract shared by `/tdd` and `/implement`: the stop-and-surface / record-and-continue split, the auto-commit + auto-`/done` exit tasks and their staging contract, and how "the repo's verification" resolves
