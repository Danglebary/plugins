---
name: next-ticket
description: Recommend the next ready ticket to work on within the active PRD. Reads tickets, computes blocked from depends_on (with defensive cycle detection), suggests an ordering. Optionally flips ticket open → in-progress and cuts the appropriate git branch (creating PRD branch lazily on first ticket). Use when starting work on a PRD or finishing a ticket.
---

# Next ticket

Pick the next ready ticket from the active PRD.

A ticket is **ready** when:
- Its `status` is `open` (not `in-progress` or `done`).
- All tickets in its `depends_on` have `status: done`.

Format reference: [TICKET-FORMAT.md](../../_shared/TICKET-FORMAT.md).

## State contract

- **PRD state required**: `open` (the active PRD per `docs/prds/.active`)
- **Ticket state required**: at least one `open` ticket should exist
- **Transition**: optional `open → in-progress` for the recommended ticket (asks user first); cuts ticket branch on transition

If `.active` is missing, prompts the user to specify a PRD or run `/next-prd`. If `.active` points to a `done` PRD, prompts the user to clear or update it.

## Process

1. **Identify the active PRD.** Read `docs/prds/.active`. If missing or points to a `done` PRD, prompt the user.

2. **Read all tickets** in the PRD's `tickets/` directory. Build a map of `id → status` and `id → depends_on`.

3. **Detect dependency cycles defensively** (DFS with recursion stack). If a cycle is found, warn with the cycle path and continue: list any tickets *not* part of the cycle that are still ready, and recommend the user fix `depends_on` to unblock the rest. Don't refuse outright.

4. **Compute readiness.** For each `open` ticket, check if every ticket in its `depends_on` has `status: done`. Those that pass are **ready**; those that don't are **blocked**.

5. **Recommend.** Present the ready tickets ordered by ticket number. Recommend the lowest-numbered ready ticket as the default. If only one is ready, just say so. If none are ready, see "No ready tickets" below.

6. **Optional flip and branch creation.** If the user accepts the recommendation:
   - Flip the ticket's `status` from `open` to `in-progress`.
   - Cut the appropriate git branch (see "Git branch creation" below).
   - Otherwise, leave status unchanged and let the user pick differently.

## Git branch creation

When flipping a ticket to `in-progress`, also cut its branch. Branch naming: `prd-<NNN>/ticket-<NNN>-<slug>` (slash separator gives git-friendly hierarchy).

**First ticket of a PRD:**
- Cut the **PRD branch** lazily from `main` (or repo's default branch): `prd-<NNN>-<slug>`.
- Cut the ticket branch from the PRD branch.

**Second-and-later ticket of a PRD:**
- Read `docs/agentic-flow.toml`'s `[branching] strategy` value.
- If `serial`: cut the ticket branch from the PRD branch (assumes the previous ticket has merged).
- If `stacked`: cut the ticket branch from the previous ticket's branch (typically the most recently `done` ticket).
- If `agentic-flow.toml` doesn't have the strategy set yet (this is the second ticket of the *first* PRD in this repo), ask the user once: *"Use serial or stacked branching for tickets in this repo?"* Write the choice to `docs/agentic-flow.toml`.

If the repo uses non-traditional branching (trunk-based with feature flags, stacked-diff tooling like Graphite), degrade gracefully — ask the user which branch to cut from rather than refusing.

## No ready tickets

If no tickets are ready, this means one of:
- **All tickets are `done`** — recommend `/retro` to close the PRD.
- **All `open` tickets are blocked** — surface the dependency graph and ask the user to investigate (something in `depends_on` is wrong, or an in-progress ticket needs to finish first).
- **One or more tickets are `in-progress`** and none others are ready — recommend finishing in-progress work first.

## Anti-patterns

- **Don't auto-start the recommended ticket.** Recommend, don't act. The user might want to skip ahead or pick differently.
- **Don't reorder by anything other than dependencies and ticket number.** Don't try to be clever about "which is easier" — that's the user's call.
- **Don't read ticket bodies unless asked.** This is about the queue, not the content — keep it fast.
- **Don't refuse on cycle detection.** Warn and show productive work that's unblocked. Refusing is too strict when only a subset of tickets are affected.
- **Don't cut a branch silently.** Tell the user the branch name and the parent it was cut from; they may want to verify before starting work.
