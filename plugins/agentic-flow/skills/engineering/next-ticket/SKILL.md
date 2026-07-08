---
name: next-ticket
description: Recommend the next ready ticket to work on within the active PRD. Reads tickets from the store, computes blocked from dependencies (with defensive cycle detection), suggests an ordering. Optionally flips ticket Open → In progress and cuts the appropriate git branch (creating PRD branch lazily on first ticket). Use when starting work on a PRD or finishing a ticket.
---

# Next ticket

Pick the next ready ticket from the active PRD. Tickets live in the store; the code and its branches live in git.

A ticket is **ready** when:
- Its status is `Open` (not `In progress` or `Done`).
- All its dependencies are `Done`.

Resolve the store first — see [STORE.md](../../_shared/STORE.md). Format reference: [TICKET-FORMAT.md](../../_shared/TICKET-FORMAT.md).

## State contract

- **PRD state required**: `Open` (the active PRD per the store's active pointer)
- **Ticket state required**: at least one `Open` ticket should exist
- **Transition**: optional `Open → In progress` for the recommended ticket (asks user first); cuts ticket branch on transition

If no PRD is active, prompts the user to specify a PRD or run `/next-prd`. If the active pointer names a `Done` PRD, prompts the user to clear or update it.

## Process

1. **Identify the active PRD** via the store's active pointer (files: `docs/prds/.active`; notion: the `Active = true` row). If missing or it names a `Done` PRD, prompt the user.

2. **Read all the PRD's tickets** from the store. Build a map of `id → status` and `id → dependencies`.

3. **Detect dependency cycles defensively** (DFS with recursion stack). If a cycle is found, warn with the cycle path and continue: list any tickets *not* part of the cycle that are still ready, and recommend the user fix the dependencies to unblock the rest. Don't refuse outright.

4. **Compute readiness.** For each `Open` ticket, check if every dependency is `Done`. Those that pass are **ready**; those that don't are **blocked**.

5. **Recommend.** Present the ready tickets ordered by ticket number. Recommend the lowest-numbered ready ticket as the default. If only one is ready, just say so. If none are ready, see "No ready tickets" below.

6. **Optional flip and branch creation.** If the user accepts the recommendation:
   - Cut the appropriate git branch (see "Git branch creation" below), after the dependency-reachability check passes.
   - Flip the ticket's status from `Open` to `In progress` (files: read the ticket file → edit the frontmatter, a working-tree edit that rides along with the ticket's first real commit, never its own commit; notion: `notion-update-page` on the row, independent of git). **Store edit and git commands stay sequential — never batched in parallel** (see STORE.md; a failed edit inside a parallel batch once cascaded into ~20 cancelled git calls).
   - Otherwise, leave status unchanged and let the user pick differently.

7. **Standing ticket-start step (config-driven).** Read the config (`.agentic-flow/settings.toml` — both stores). If `ticket_start.research_opener` is true, dispatch a research sub-agent as part of ticket start — no per-ticket confirm needed; the config *is* the standing consent. The sub-agent's brief: map the code and docs relevant to this ticket's Goal and Acceptance criteria, verify any external-toolchain assumptions the ticket or PRD makes (stdlib APIs, build semantics, library behavior) against the installed toolchain, and assess whether `/tdd` fits the work. Relay its findings before implementation starts. If the key is absent or false, skip silently.

## Git branch creation

When flipping a ticket to `In progress`, also cut its branch. Branch naming: `prd-<NNN>/ticket-<NNN>-<slug>` (slash separator gives git-friendly hierarchy). The PRD branch name `prd-<NNN>-<slug>` comes from the store's branch link (files: the PRD directory name; notion: the PRD row's `Branch` property).

**First ticket of a PRD:**
- Cut the **PRD branch** lazily from `main` (or repo's default branch): `prd-<NNN>-<slug>`.
- Cut the ticket branch from the PRD branch.

**Second-and-later ticket of a PRD:**
- Read the config's `branching.strategy` value.
- If `serial`: cut the ticket branch from the PRD branch.
- If `stacked`: cut the ticket branch from the previous ticket's branch (typically the most recently `Done` ticket).

**Dependency-reachability check (before cutting, both strategies):** for every dependency of the new ticket, verify its work is reachable from the intended cut point — find the dependency's close commit (or its branch tip if the branch still exists) and check ancestry with `git merge-base --is-ancestor`. If a `Done` ticket's branch was never merged back, **stop and offer the close-out merge** (`--no-ff` per the repo convention, verify green, delete branch) before cutting. Cutting from a stale parent silently builds the new ticket on a tree missing its dependency's work — this happened and shipped a real defect.
- If the config doesn't have the strategy set yet (this is the second ticket of the *first* PRD in this repo), ask the user once: *"Use serial or stacked branching for tickets in this repo?"* Write the choice back to the config.

If the repo uses non-traditional branching (trunk-based with feature flags, stacked-diff tooling like Graphite), degrade gracefully — ask the user which branch to cut from rather than refusing.

## No ready tickets

If no tickets are ready, this means one of:
- **All tickets are `Done`** — recommend `/retro` to close the PRD.
- **All `Open` tickets are blocked** — surface the dependency graph and ask the user to investigate (a dependency is wrong, or an in-progress ticket needs to finish first).
- **One or more tickets are `In progress`** and none others are ready — recommend finishing in-progress work first.

## Anti-patterns

- **Don't auto-start the recommended ticket.** Recommend, don't act. The user might want to skip ahead or pick differently.
- **Don't reorder by anything other than dependencies and ticket number.** Don't try to be clever about "which is easier" — that's the user's call.
- **Don't read ticket bodies unless asked.** This is about the queue, not the content — keep it fast (notion: query properties, don't `notion-fetch` full bodies).
- **Don't refuse on cycle detection.** Warn and show productive work that's unblocked. Refusing is too strict when only a subset of tickets are affected.
- **Don't cut a branch silently.** Tell the user the branch name and the parent it was cut from; they may want to verify before starting work.
- **Don't batch the status flip in parallel with git commands.**
