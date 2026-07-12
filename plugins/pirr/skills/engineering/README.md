# Engineering

Skills for daily code work. Planning artifacts live in the store — in-repo markdown files, per [STORE.md](../_shared/STORE.md).

- **[setup](./setup/SKILL.md)** — Idempotent per-repo bootstrap. Asks whether `.pirr/` is committed or ignored, writes `.pirr/settings.toml`, and provisions the store (`docs/specs/`, `docs/adr/`, `docs/reviewers.md`, `CONTEXT.md`); populates the Reviewers manifest from default + heuristic-detected reviewer agents.
- **[next-spec](./next-spec/SKILL.md)** — Exploration of what to work on next. Reads specs, retros, the Glossary, and ADRs; surfaces gaps and priorities as a conversation. Hands off to a high-level `/grill-me`.
- **[grill-me](./grill-me/SKILL.md)** — Interview the user relentlessly about a plan or design. Updates the Glossary inline and offers ADRs via the three-gate test.
- **[to-spec](./to-spec/SKILL.md)** — Synthesize the current conversation into a frozen spec (Status: Drafting). Does not interview.
- **[to-tickets](./to-tickets/SKILL.md)** — Break a spec into dependency-ordered vertical-slice tickets. Flips spec `Drafting → Open` and ends at the gated spec-branch bootstrap — cut from the default branch, planning artifacts committed as its first commit.
- **[next-ticket](./next-ticket/SKILL.md)** — Recommend the next ready ticket within the current spec. Computes blocked from dependencies.
- **[tdd](./tdd/SKILL.md)** — Test-driven development with a red-green-refactor loop. Inside a ticket, stops and surfaces the decisions the loop can't safely make, then auto-commits and invokes `/done` on clean-green completion.
- **[implement](./implement/SKILL.md)** — Plan-then-execute implementation. Builds features or fixes bugs from an approved plan when TDD doesn't fit.
- **[done](./done/SKILL.md)** — Close the current ticket. Dispatches the deviation-fact-checker and spec-conformance agents against the ticket diff — two reports, separate headings, never merged — flips status, appends a retro entry, commits the close-out edits at one gated offer, then forks: run `/refactor`'s refactor pass, or merge now — one arm recommended from the diff's nature.
- **[refactor](./refactor/SKILL.md)** — Per-ticket multi-reviewer review-and-improve pass — broader than a rename-level cleanup. Dispatches reviewer agents listed in the Reviewers manifest against the just-closed ticket's diff, merges findings through the deepening framework, captures refactor changes in the ticket's `## Deviations` with a `(refactor)` marker. Every pass ends at the gated close-out (merge offered when a ticket branch is live); outside-spec deferrals bank as Ideas.
- **[retro](./retro/SKILL.md)** — Synthesize the running retro into the structured spec-close form. Fact-checks the full spec diff, flips spec `Open → Done`, commits the close-out edits at one gated offer, and ends with the gated spec → default-branch merge — re-enterable until it lands.
