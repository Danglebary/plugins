# Engineering

Skills for daily code work, in workflow order. All planning artifacts are Notion database rows — every skill starts by resolving the databases per [NOTION-RESOLVER.md](../_shared/NOTION-RESOLVER.md).

- **[setup-agentic-flow](./setup-agentic-flow/SKILL.md)** — Idempotent bootstrap. Provisions the private `Agentic-Flow` root page and its PRDs, Tickets, Glossary, ADRs, and Reviewers databases; populates Reviewers from default + heuristic-detected reviewer agents.
- **[next-prd](./next-prd/SKILL.md)** — Exploration of what to work on next. Reads PRDs, retros, the Glossary, and ADRs from Notion; surfaces gaps and priorities as a conversation.
- **[grill-me](./grill-me/SKILL.md)** — Interview the user relentlessly about a plan or design. Updates the Glossary inline and offers ADR rows via the three-gate test.
- **[to-prd](./to-prd/SKILL.md)** — Synthesize the current conversation into a frozen PRDs row (Status: Drafting). Does not interview.
- **[to-tickets](./to-tickets/SKILL.md)** — Break a drafting PRD into dependency-ordered vertical-slice Tickets rows. Flips PRD `Drafting → Open`, marks it Active.
- **[next-ticket](./next-ticket/SKILL.md)** — Recommend the next ready ticket within the active PRD. Computes blocked from the `Depends on` relation.
- **tdd** — shared from the base `agentic-flow` plugin; storage-agnostic.
- **[done](./done/SKILL.md)** — Close the current ticket. Invokes `agentic-flow:deviation-fact-checker` against the ticket diff, flips Status, appends a retro entry to the PRD row, recommends `/improve-codebase-architecture`.
- **[improve-codebase-architecture](./improve-codebase-architecture/SKILL.md)** — Per-ticket refactor pass. Dispatches reviewer agents listed in the Reviewers database against the just-closed ticket's diff, merges findings through the deepening framework, captures refactor changes in the ticket row's `## Deviations` with a `(refactor)` marker.
- **[retro](./retro/SKILL.md)** — Synthesize the running retro into the structured PRD-close form in the PRD row body. Flips PRD `Open → Done`, clears Active.
