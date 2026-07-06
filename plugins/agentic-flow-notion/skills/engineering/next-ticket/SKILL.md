---
name: next-ticket
description: Recommend the next ready ticket within the active PRD, reading ticket rows from the Notion Tickets database. Computes blocked from the Depends on relation (with defensive cycle detection), suggests an ordering. Optionally flips a ticket Open to In progress and cuts the git branch (creating the PRD branch lazily on first ticket). Use when starting work on a PRD or finishing a ticket.
---

# Next ticket (Notion)

Pick the next ready ticket from the active PRD. Ticket rows live in the **Tickets** database; the code and its branches live in git.

A ticket is **ready** when its `Status` is `Open` (not `In progress`/`Done`/`Abandoned`) and every ticket in its `Depends on` relation has `Status = Done`.

Resolve databases first — see [NOTION-RESOLVER.md](../../_shared/NOTION-RESOLVER.md). Ticket voice and thresholds: [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md).

## State contract

- **PRD state required**: `Status = Open`, `Active = true` (the active PRD is the row with the `Active` checkbox set)
- **Ticket state required**: at least one `Open` ticket should exist
- **Transition**: optional `Open -> In progress` for the recommended ticket (asks first); cuts the ticket branch on transition

If no PRD has `Active = true`, prompt the user to specify one or run `/next-prd`. If the `Active` PRD is `Done`, prompt to clear or update it.

## Process

1. **Identify the active PRD.** Query the PRDs database for `Active = true`. If none, or it's `Done`, prompt the user. (This replaces reading `docs/prds/.active`.)

2. **Read all tickets.** Query the Tickets database for rows whose `PRD` relation is the active PRD. Build maps `id -> Status` and `id -> Depends on`.

3. **Detect dependency cycles defensively** (DFS with recursion stack). On a cycle, warn with the cycle path and continue: list tickets *not* in the cycle that are still ready, and recommend fixing `Depends on`. Don't refuse outright.

4. **Compute readiness.** For each `Open` ticket, check every ticket in its `Depends on` is `Done`. Passing = **ready**; otherwise **blocked**.

5. **Recommend.** Present ready tickets ordered by ticket number; recommend the lowest-numbered as default. If one is ready, say so. If none, see "No ready tickets".

6. **Optional flip and branch creation.** If the user accepts:
   - Cut the git branch (see below), after the dependency-reachability check passes.
   - Flip the ticket row's `Status` `Open -> In progress` via `update-page`.
   - **The flip is a Notion property update, independent of git — not a commit, and it creates none.** The only git this skill runs is branch creation and read-only checks (status, merge-base). Keep the `update-page` call and git commands sequential — never batch them in parallel (a failed call inside a parallel batch once cascaded into ~20 cancelled git calls).
   - Otherwise leave `Status` unchanged and let the user pick differently.

7. **Standing ticket-start step (config-driven).** Read the config in the `Agentic-Flow` root page body (see resolver doc). If `ticket_start.research_opener` is true, dispatch a research sub-agent as part of ticket start — the config *is* the standing consent, no per-ticket confirm. Brief: map the code and docs relevant to this ticket's Goal and Acceptance criteria, verify external-toolchain assumptions against the installed toolchain, assess whether `/tdd` fits. Relay findings before implementation. If absent/false, skip silently.

## Git branch creation

Branch naming: `prd-<NNN>/ticket-<NNN>-<slug>`. Take the PRD number and PRD branch name from the active PRD row's `Number` and `Branch` properties; take the ticket slug from the ticket row.

**First ticket of a PRD:**
- Cut the **PRD branch** lazily from `main` (or the repo default): `prd-<NNN>-<slug>` (the value already written to the PRD row's `Branch` by `/to-tickets`).
- Cut the ticket branch from the PRD branch.

**Second-and-later ticket:**
- Read `branching.strategy` from the root page body config.
- `serial`: cut the ticket branch from the PRD branch.
- `stacked`: cut from the previous ticket's branch (typically the most recently `Done` ticket).

**Dependency-reachability check (before cutting, both strategies):** for every ticket in `Depends on`, verify its work is reachable from the intended cut point — find the dependency's close commit (or branch tip) and check ancestry with `git merge-base --is-ancestor`. If a `Done` ticket's branch was never merged back, **stop and offer the close-out merge** (`--no-ff` per repo convention, verify green, delete branch) before cutting. Cutting from a stale parent silently builds on a tree missing the dependency's work — this shipped a real defect once.

- If `branching.strategy` isn't set yet (second ticket of the *first* PRD), ask once: *"serial or stacked branching for this repo?"* Write the choice back into the root page body config.

If the repo uses non-traditional branching (trunk-based, stacked-diff tooling), degrade gracefully — ask which branch to cut from rather than refusing.

## No ready tickets

- **All tickets `Done`** -> recommend `/retro` to close the PRD.
- **All `Open` tickets blocked** -> surface the dependency graph and ask the user to investigate.
- **One or more `In progress`, none else ready** -> recommend finishing in-progress work first.

## Anti-patterns

- **Don't auto-start the recommended ticket.** Recommend, don't act.
- **Don't reorder by anything but dependencies and ticket number.** "Which is easier" is the user's call.
- **Don't read ticket bodies unless asked.** This is about the queue, not the content — keep it fast (query properties, not full `notion-fetch` bodies).
- **Don't refuse on cycle detection.** Warn and show unblocked work.
- **Don't cut a branch silently.** Tell the user the branch name and its parent.
- **Don't batch the `update-page` status flip in parallel with git commands.**
