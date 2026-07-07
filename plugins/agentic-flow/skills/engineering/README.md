# Engineering

Skills for daily code work. Planning artifacts live in the store — in-repo files or Notion databases, per [STORE.md](../_shared/STORE.md); each workflow skill resolves the store at the start of its run.

- **[setup-agentic-flow](./setup-agentic-flow/SKILL.md)** — Idempotent per-repo bootstrap. Asks which store to use and whether `.agentic-flow/` is committed or ignored, writes `.agentic-flow/settings.toml`, and provisions the store (files: `docs/prds/`, `docs/adr/`, `docs/reviewers.md`, `CONTEXT.md`; notion: the `Agentic-Flow` root page and its five databases); populates the Reviewers manifest from default + heuristic-detected reviewer agents.
- **[next-prd](./next-prd/SKILL.md)** — Exploration of what to work on next. Reads PRDs, retros, the Glossary, and ADRs; surfaces gaps and priorities as a conversation.
- **[grill-me](./grill-me/SKILL.md)** — Interview the user relentlessly about a plan or design. Updates the Glossary inline and offers ADRs via the three-gate test.
- **[to-prd](./to-prd/SKILL.md)** — Synthesize the current conversation into a frozen PRD (Status: Drafting). Does not interview.
- **[to-tickets](./to-tickets/SKILL.md)** — Break a PRD into dependency-ordered vertical-slice tickets. Flips PRD `Drafting → Open`.
- **[next-ticket](./next-ticket/SKILL.md)** — Recommend the next ready ticket within the current PRD. Computes blocked from dependencies.
- **[tdd](./tdd/SKILL.md)** — Test-driven development with a red-green-refactor loop. Builds features or fixes bugs one vertical slice at a time.
- **[done](./done/SKILL.md)** — Close the current ticket. Invokes the deviation-fact-checker against the ticket diff, flips status, appends a retro entry, recommends `/improve-codebase-architecture` for a per-ticket refactor pass.
- **[improve-codebase-architecture](./improve-codebase-architecture/SKILL.md)** — Per-ticket refactor pass. Dispatches reviewer agents listed in the Reviewers manifest against the just-closed ticket's diff, merges findings through the deepening framework, captures refactor changes in the ticket's `## Deviations` with a `(refactor)` marker.
- **[retro](./retro/SKILL.md)** — Synthesize the running retro into the structured PRD-close form. Flips PRD `Open → Done`.
