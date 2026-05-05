---
name: next-prd
description: Exploration of what the project should work on next. Reads existing PRDs, retros, CONTEXT.md, and ADRs, then has a conversation about gaps and priorities. Output is conversation, not a document. Use when starting a new body of work and unsure what to build, or when the user asks "what's next".
---

# Next PRD

Exploration skill at the front of the agentic-flow workflow. Output is a *conversation*, not a document. The next skill in the chain (`/to-prd`) captures the conversation as a draft PRD.

## State contract

- **PRD state required**: any (reads only)
- **Ticket state required**: n/a
- **Transition**: none

## Process

1. **Read the existing state.**
   - List PRDs in `docs/prds/`, noting statuses (`drafting`, `open`, `done`).
   - Skim retros from the most recent 2–3 `done` PRDs for cross-cutting lessons.
   - Read `CONTEXT.md` for current domain vocabulary — use it throughout the conversation.
   - Skim `docs/adr/` for cross-PRD durable decisions.
   - Explore the codebase only if a candidate idea calls for it. Don't survey upfront.

2. **Surface 2–4 candidate next priorities.** Ground each one in what you read. Examples:
   - "PRD 003's retro flagged auth-flow terminology drift. Worth a small PRD to consolidate?"
   - "ADR-0002 said we'd revisit caching once write load justified it. Worth checking now?"
   - "There's a TODO in `src/billing/` left over from PRD 002 that wasn't a ticket — worth a small PRD to sweep it up?"
   - "If you're starting fresh, what's the next user-facing capability you want?"

3. **Have a conversation.** Ask the user to react to candidates, propose their own, or steer differently. Use vocabulary from `CONTEXT.md`. This is *not* `/grill-me` — figure out *what* to work on, not *how* to build it. Design comes later.

4. **End by recommending `/to-prd`.** When the user signals alignment ("yes, let's do that", "let's write that up"), say: "Want me to run `/to-prd` to capture this as a draft PRD?"

## Empty-state handling

If the repo has no PRDs (just-bootstrapped or first PRD), skip the survey and ask the user directly: "What do you want to build first?"

## Anti-patterns

- **Don't write a PRD here.** That's `/to-prd`'s job. Stay in conversation.
- **Don't drill into design or implementation.** That's `/grill-me`'s job after `/to-prd` writes the draft.
- **Don't enumerate more than 3–4 candidates.** Survey, don't list everything.
- **Don't read every retro and every ADR.** Sample the recent ones; the goal is signal, not coverage.
