# Engineering

Skills for daily code work.

- **[done](./done/SKILL.md)** — Close the current ticket. Invokes the deviation-fact-checker against the ticket diff, flips status, appends a retro entry, recommends `/improve-codebase-architecture` for a per-ticket refactor pass.
- **[grill-me](./grill-me/SKILL.md)** — Interview the user relentlessly about a plan or design. Updates CONTEXT.md inline and offers ADRs via the three-gate test.
- **[improve-codebase-architecture](./improve-codebase-architecture/SKILL.md)** — Per-ticket refactor pass. Dispatches reviewer agents listed in `docs/reviewers.md` against the just-closed ticket's diff, merges findings through the deepening framework, captures refactor changes in the ticket's `## Deviations` with a `(refactor)` marker.
- **[next-prd](./next-prd/SKILL.md)** — Exploration of what to work on next. Reads PRDs, retros, CONTEXT.md, ADRs; surfaces gaps and priorities as a conversation.
- **[next-ticket](./next-ticket/SKILL.md)** — Recommend the next ready ticket within the current PRD. Computes blocked from `depends_on`.
- **[retro](./retro/SKILL.md)** — Synthesize the running retro into the structured PRD-close form. Flips PRD `open → done`.
- **[setup-agentic-flow](./setup-agentic-flow/SKILL.md)** — Idempotent per-repo bootstrap. Scaffolds `docs/prds/`, `docs/adr/`, populates `docs/reviewers.md` from default + heuristic-detected reviewer agents, scaffolds `CONTEXT.md` and `docs/agentic-flow.toml`.
- **[tdd](./tdd/SKILL.md)** — Test-driven development with a red-green-refactor loop. Builds features or fixes bugs one vertical slice at a time.
- **[to-prd](./to-prd/SKILL.md)** — Synthesize the current conversation into a frozen `prd.md` (status: drafting). Does not interview.
- **[to-tickets](./to-tickets/SKILL.md)** — Break a PRD into dependency-ordered vertical-slice tickets. Flips PRD `drafting → open`.
