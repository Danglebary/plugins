# agentic-flow

A Claude Code plugin: a small, composable set of skills for AI-augmented software development. Built on a four-phase workflow:

```
Plan  →  Implement  →  Refactor / Cleanup  →  Retro
```

Two ideas anchor the system:

- **In-repo document tracking** — PRDs, tickets, and retros live in the repo as markdown files. No external issue tracker.
- **PRD/ticket/retro hierarchy** — a frozen-intent (PRD) + living-retro pair captures the durable record of each body of work.

## Setup

In a new repo, run:

```
/setup-agentic-flow
```

This scaffolds the directories `agentic-flow` uses (`docs/prds/`, `docs/adr/`), populates `docs/reviewers.md` from default + heuristic-detected reviewer agents, and creates a `CONTEXT.md` skeleton and `docs/agentic-flow.toml` config file.

## The workflow

```
0. /setup-agentic-flow                          (once per repo)

1. /next-prd                                    → conversation: what to build next
2. /grill-me                                    → high-level: what are we trying to do
3. /to-prd                                      → writes prd.md (status: drafting)
4. /grill-me                                    → detail: sharpen; updates CONTEXT.md, may create ADRs
5. /to-tickets                                  → creates tickets/, flips PRD → open

LOOP per ticket:
  6. /next-ticket                               → recommends next ready ticket
  7. (work the ticket: /tdd)
  8. /done                                      → fact-checks deviations, flips status, appends retro entry
  9. /improve-codebase-architecture (recommended) → per-ticket refactor pass with reviewer subagents

10. /retro                                      → synthesize retro.md, flips PRD → done
```

## Skills

### Engineering

- **[done](./skills/engineering/done/SKILL.md)** — Close the current ticket. Invokes the deviation-fact-checker against the ticket diff, flips status, appends a retro entry, recommends `/improve-codebase-architecture` for a per-ticket refactor pass.
- **[grill-me](./skills/engineering/grill-me/SKILL.md)** — Interview the user relentlessly about a plan or design. Updates CONTEXT.md inline and offers ADRs via the three-gate test.
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)** — Per-ticket refactor pass. Dispatches reviewer agents listed in `docs/reviewers.md` against the just-closed ticket's diff, merges findings through the deepening framework, captures refactor changes in the ticket's `## Deviations` with a `(refactor)` marker.
- **[next-prd](./skills/engineering/next-prd/SKILL.md)** — Exploration of what to work on next. Reads PRDs, retros, CONTEXT.md, ADRs; surfaces gaps and priorities as a conversation.
- **[next-ticket](./skills/engineering/next-ticket/SKILL.md)** — Recommend the next ready ticket within the current PRD. Computes blocked from `depends_on`.
- **[retro](./skills/engineering/retro/SKILL.md)** — Synthesize the running retro into the structured PRD-close form. Flips PRD `open → done`.
- **[setup-agentic-flow](./skills/engineering/setup-agentic-flow/SKILL.md)** — Idempotent per-repo bootstrap and refresh. Scaffolds `docs/prds/`, `docs/adr/`, `docs/reviewers.md`, `CONTEXT.md`.
- **[tdd](./skills/engineering/tdd/SKILL.md)** — Test-driven development with a red-green-refactor loop. Builds features or fixes bugs one vertical slice at a time.
- **[to-prd](./skills/engineering/to-prd/SKILL.md)** — Synthesize the current conversation into a frozen `prd.md` (status: drafting). Does not interview.
- **[to-tickets](./skills/engineering/to-tickets/SKILL.md)** — Break a PRD into dependency-ordered vertical-slice tickets. Flips PRD `drafting → open`.

### Productivity

- **[new](./skills/productivity/new/SKILL.md)** — Distill the current session and project context into a bootstrap prompt for a fresh agent — for handing off mid-flight work to a new conversation without losing momentum.

## Design notes

The canonical vocabulary used by `agentic-flow` itself lives in [`CONTEXT.md`](./CONTEXT.md). A few load-bearing rules to know before modifying skills:

- **Frozen artifacts never edit.** Once a PRD flips to `open`, `prd.md` is immutable. Once it flips to `done`, the synthesized `retro.md` is immutable too. `/to-tickets` only runs on a `drafting` PRD; mid-flight scope additions are deliberate, manual exceptions.
- **Forward-looking work always lives in a new PRD.** No "follow-ups" or "future work" sections on PRDs or retros — forward-looking lessons motivate the *next* PRD.
- **ADRs only when all three gates pass:** hard to reverse, surprising without context, the result of a real trade-off. Strictness keeps ADRs rare and high-signal.
- **Vertical slicing.** Tickets are end-to-end thin slices, not horizontal layers.
- **Lazy file creation.** PRDs, tickets, retros, ADRs are created by the skills that produce them — not in advance, not by bootstrap. The exception is structural-marker files (`CONTEXT.md`, `docs/reviewers.md`, `docs/agentic-flow.toml`), which `/setup-agentic-flow` scaffolds eagerly.
- **Immutable IDs.** PRD numbers and ticket numbers are never renumbered — references in retros, ADRs, and commits would rot. Abandoned work moves to `_abandoned/` rather than being deleted; numbering globs both directories when assigning the next ID.
- **`(refactor)` marker on deviations.** Architectural changes from `/improve-codebase-architecture` land in the same ticket's `## Deviations` section with a `(refactor)` prefix, so `/retro` can group them into the synthesized retro's optional `## Refactor` section.
- **Disk is the primary signal.** `agentic-flow:deviation-fact-checker` compares ticket diffs against `## Deviations` from a fresh session — conversation context is bonus, not load-bearing. Skills are designed to work the same way without prior context.
