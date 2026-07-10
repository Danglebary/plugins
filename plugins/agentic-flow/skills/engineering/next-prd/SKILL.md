---
name: next-prd
description: Exploration of what the project should work on next. Reads existing PRDs, retros, the Glossary, and ADRs from the store, then has a conversation about gaps and priorities. Output is conversation, not a document; ends by recommending a high-level /grill-me, never /to-prd directly. Use when starting a new body of work and unsure what to build, or when the user asks "what's next".
---

# Next PRD

Exploration skill at the front of the agentic-flow workflow. Output is a *conversation*, not a document. The next skill in the chain is a **high-level `/grill-me`** that stress-tests the chosen direction; only after that does `/to-prd` capture it as a draft PRD. The full planning chain: `/next-prd` → `/grill-me` (high-level) → `/to-prd` → `/grill-me` (detail) → `/to-tickets`.

Resolve the store first — see [STORE.md](../../_shared/STORE.md).

## State contract

- **PRD state required**: any (reads only)
- **Ticket state required**: n/a
- **Transition**: none

## Process

1. **Read the existing state from the store.**
   - List PRDs, noting statuses (`Drafting`, `Open`, `Done`). Also skim banked ideas — parked ideas are candidate priorities.
   - Sweep for unmerged `prd-*` branches — a PRD in flight on its branch can be invisible to the store read from another checkout. A branch is unmerged when its tip (local or remote) is not an ancestor of the resolved default branch (the unmerged test — inline copy of [STORE.md](../../_shared/STORE.md)'s branch-link state tests, cited per ADR-0002; enumerate, filter, and observe per its enumeration rule and the remote-observation rule's advisory tier). Any found join the survey as in-flight work.
   - Skim retros from the most recent 2–3 `Done` PRDs for cross-cutting lessons.
   - Read the Glossary for current domain vocabulary — use it throughout the conversation.
   - Skim the ADRs for cross-PRD durable decisions.
   - Explore the codebase (in git) only if a candidate idea calls for it. Don't survey upfront.

2. **Surface 2–4 candidate next priorities.** Ground each one in what you read. Examples:
   - "PRD 003's retro flagged auth-flow terminology drift. Worth a small PRD to consolidate?"
   - "ADR-0002 said we'd revisit caching once write load justified it. Worth checking now?"
   - "There's an idea *sweep billing TODOs* parked three weeks ago — promote it?"
   - "If you're starting fresh, what's the next user-facing capability you want?"

3. **Have a conversation.** Ask the user to react to candidates, propose their own, or steer differently. Use Glossary vocabulary. This is *not* `/grill-me` — figure out *what* to work on, not *how* to build it. Design comes later.

4. **End by recommending a high-level `/grill-me` — never `/to-prd` directly.** When the user signals alignment ("yes, let's do that", "let's write that up"), say: *"Want me to run `/grill-me` to stress-test this direction before we write it up?"* The high-level grill is where the premise gets challenged before `/to-prd` freezes it into a draft.

## Empty-state handling

If the store has no PRDs (just-bootstrapped or first PRD) but step 1's sweep found in-flight branches, name them — *"PRD 001 appears in flight on `prd-001-…` — you may be on the wrong checkout"* — and offer the fork: switch to (or fetch) the named branch to resume it, or confirm continuing on this checkout's view. Only when the sweep is empty too, skip the survey and ask the user directly: "What do you want to build first?"

## Anti-patterns

- **Don't write a PRD here.** That's `/to-prd`'s job. Stay in conversation.
- **Don't hand off to `/to-prd` directly.** The chain routes through a high-level `/grill-me` first — a premise nobody stress-tested shouldn't freeze into a draft PRD.
- **Don't drill into design or implementation.** That's the detail-stage `/grill-me`'s job after `/to-prd` writes the draft.
- **Don't enumerate more than 3–4 candidates.** Survey, don't list everything.
- **Don't read every retro and every ADR.** Sample the recent ones; the goal is signal, not coverage.
- **Don't re-resolve the store mid-skill.** Resolve once at the start (see STORE.md).
