---
name: next-prd
description: Exploration of what to work on next. Reads existing PRDs, retros, the Glossary, and ADRs from Notion, then has a conversation about gaps and priorities. Output is conversation, not a document. Use when starting a new body of work or when the user asks what is next.
---

# Next PRD (Notion)

Exploration skill at the front of the workflow. Output is a *conversation*, not a document. The next skill (`/to-prd`) captures it as a draft PRD row.

Resolve databases first — see [NOTION-RESOLVER.md](../../_shared/NOTION-RESOLVER.md).

## State contract

- **PRD state required**: any (reads only)
- **Ticket state required**: n/a
- **Transition**: none

## Process

1. **Read the existing state from Notion.**
   - Query the **PRDs** database for rows where `Kind = PRD`, noting `Status` (`Drafting`, `Open`, `Done`). Also skim `Kind = Idea` rows — parked ideas are candidate priorities.
   - `notion-fetch` the retros of the 2–3 most recent `Done` PRDs (retro lives in the PRD row's body or its linked retro) for cross-cutting lessons.
   - Query the **Glossary** database for current domain vocabulary — use it throughout the conversation.
   - Skim the **ADRs** database for cross-PRD durable decisions.
   - Explore the codebase (in git) only if a candidate idea calls for it. Don't survey upfront.

2. **Surface 2–4 candidate next priorities.** Ground each in what you read:
   - "PRD-003's retro flagged auth-flow terminology drift. Worth a small PRD to consolidate?"
   - "ADR *Cache-on-write* said we'd revisit once write load justified it. Time to check?"
   - "There's an `Idea` row *sweep billing TODOs* parked three weeks ago — promote it?"
   - "Starting fresh — what's the next user-facing capability you want?"

3. **Have a conversation.** Ask the user to react, propose their own, or steer. Use Glossary vocabulary. This is *not* `/grill-me` — figure out *what* to work on, not *how*.

4. **End by recommending `/to-prd`.** When the user aligns, say: "Want me to run `/to-prd` to capture this as a draft PRD?"

## Empty-state handling

If the PRDs database has no `Kind = PRD` rows (just-bootstrapped), skip the survey and ask directly: "What do you want to build first?"

## Anti-patterns

- **Don't write a PRD here.** That's `/to-prd`'s job. Stay in conversation.
- **Don't drill into design or implementation.** That's `/grill-me`, after `/to-prd`.
- **Don't enumerate more than 3–4 candidates.** Survey, don't list everything.
- **Don't fetch every retro and ADR.** Sample the recent ones; the goal is signal, not coverage.
- **Don't re-search the databases mid-skill.** Resolve once at the start (see resolver doc).
