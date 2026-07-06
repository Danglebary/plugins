# agentic-flow-notion

The Notion-backed variant of [`agentic-flow`](../agentic-flow/README.md). Same four-phase workflow:

```
Plan  →  Implement  →  Refactor / Cleanup  →  Retro
```

The difference is **where planning artifacts live**. `agentic-flow` tracks PRDs, tickets, retros, ADRs, the glossary, and the reviewer manifest as markdown files in the repo. This plugin moves all of them into Notion:

```
Agentic-Flow                (private root page; config lives in its body)
├── PRDs        (database)   ← replaces docs/prds/
├── Tickets     (database)   ← replaces docs/prds/<prd>/tickets/
├── Glossary    (database)   ← replaces CONTEXT.md
├── ADRs        (database)   ← replaces docs/adr/
└── Reviewers   (database)   ← replaces docs/reviewers.md
```

There are no local planning files and no config file — every skill resolves the databases by searching Notion at the start of each run. The full protocol, database schemas, and file-to-Notion mapping live in [NOTION-RESOLVER.md](./skills/_shared/NOTION-RESOLVER.md).

## Requires `agentic-flow`

Install this plugin **alongside** `agentic-flow`, not instead of it. Shared pieces are not duplicated here; they come from the base plugin:

- **All agents** — the reviewer agents (`agentic-flow:qa-engineer`, `agentic-flow:software-architect`, `agentic-flow:security-engineer`, and the language specialists) and the workflow agent `agentic-flow:deviation-fact-checker`. The skills here invoke them by their `agentic-flow:` namespaced names, and `/setup-agentic-flow` writes those names into the Reviewers database.
- **[tdd](../agentic-flow/skills/engineering/tdd/SKILL.md)** — world-agnostic; the red-green-refactor loop doesn't care where tickets are stored.
- **[new](../agentic-flow/skills/productivity/new/SKILL.md)** — session handoff, also storage-agnostic.

Both plugins define the workflow skills (`/done`, `/retro`, `/to-prd`, …) under their own namespace. If you run both workflows side by side, disambiguate with the namespaced form (`agentic-flow-notion:done` vs `agentic-flow:done`); if you only use the Notion workflow, consider disabling the base plugin's duplicate skills while keeping its agents.

## Setup

Connect the Notion MCP server, then in a new repo run:

```
/setup-agentic-flow
```

This provisions the private `Agentic-Flow` root page and its five databases, populates `Reviewers` from default + heuristic-detected reviewer agents, and writes the config block into the root page body.

## The workflow

```
0. /setup-agentic-flow                          (once per workspace/repo)

1. /next-prd                                    → conversation: what to build next
2. /grill-me                                    → high-level: what are we trying to do
3. /to-prd                                      → creates a PRDs row (Status: Drafting)
4. /grill-me                                    → detail: sharpen; updates Glossary, may create ADR rows
5. /to-tickets                                  → creates Tickets rows, flips PRD → Open, marks Active

LOOP per ticket:
  6. /next-ticket                               → recommends next ready ticket
  7. (work the ticket: /tdd)
  8. /done                                      → fact-checks deviations, flips Status, appends retro entry
  9. /improve-codebase-architecture (recommended) → per-ticket refactor pass with reviewer subagents
     (accept the gated close-out offer)         → merge ticket branch --no-ff, verify green, delete branch

10. /retro                                      → synthesizes the retro into the PRD row, flips PRD → Done
```

## Design notes

The workflow rules are the same as the base plugin's — see the Design notes in [`agentic-flow`'s README](../agentic-flow/README.md). The Notion-specific rules layered on top:

- **Pure search resolution.** The root page title `Agentic-Flow` is the only search-stable anchor; child databases are found by fetching the root, never by searching for them directly.
- **Single-active enforcement lives in skill code.** Notion has no cross-row "only one true" constraint — skills clear existing `Active` checkboxes before setting a new one, always clear-first.
- **PRD numbers are skill-assigned**, via a max-`Number` query over `Kind = PRD` rows (including `Abandoned`), not `UNIQUE_ID` — so ideas and spikes never burn a number.
- **`.agentic-flow/diff.patch` stays local.** It's a git-ignored view of the diff for the fact-checker, about the code, not a planning artifact.
