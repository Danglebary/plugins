---
name: next-ticket
description: Recommend the next ready ticket to work on within the active spec. Reads tickets from the store, computes blocked from dependencies (with defensive cycle detection), suggests an ordering. Optionally flips ticket Open → In progress and cuts the ticket branch from the spec branch — never creating the spec branch; a missing one refuses with /to-tickets' re-enterable bootstrap as the fix. Use when starting work on a spec or finishing a ticket.
---

# Next ticket

Pick the next ready ticket from the active spec. Tickets live in the store; the code and its branches live in git.

A ticket is **ready** when:
- Its status is `Open` (not `In progress` or `Done`).
- All its dependencies are `Done`.

Store artifact paths: [STORE.md](../../_shared/STORE.md). Format reference: [TICKET-FORMAT.md](../../_shared/TICKET-FORMAT.md).

## State contract

- **Spec state required**: `Open` (the active spec per the store's active pointer), with its bootstrap landed — the landed test, whose one full copy in this skill lives at the spec-branch precondition under "Git branch creation"; checked at step 1
- **Ticket state required**: at least one `Open` ticket should exist
- **Transition**: optional `Open → In progress` for the recommended ticket (asks user first); cuts ticket branch on transition. A missing or half-landed spec branch refuses the transition — `/to-tickets`' re-enterable bootstrap is the fix; this skill never creates the spec branch

If the active pointer is missing or names a `Done` spec, sweeps for unmerged spec branches (step 1) — an in-flight spec may be visible only from its own checkout — then prompts the user: specify a spec or run `/next-spec` (pointer missing), or clear/update the pointer (`Done`).

## Process

1. **Identify the active spec** via the store's active pointer (`docs/specs/.active`, whose one line is the spec directory name, `<NNN>-<slug>`). If missing or it names a `Done` spec, sweep for unmerged spec branches (`spec-*` and legacy `prd-*`) before prompting — a spec in flight on its branch can be invisible from another checkout. A branch is unmerged when its tip (local or remote) is not an ancestor of the resolved default branch (the unmerged test — inline copy of STORE.md's branch-link state tests, kept inline per its placement test; enumerate, filter, and observe per its enumeration rule — both patterns — and the remote-observation rule's advisory tier). Name any found — *"Spec 001 appears in flight on `spec-001-…` — you may be on the wrong checkout"* — offer to switch to (or fetch) the named branch instead, then prompt the user. Then run the landed test (the spec-branch precondition under "Git branch creation"). On failure, still present the read-only queue (steps 2–5) but say up front that starting any ticket will refuse until `/to-tickets`' re-enterable bootstrap lands — failing fast beats a recommendation conversation that cannot land.

2. **Read all the spec's tickets** from the store. Build a map of `id → status` and `id → dependencies`.

3. **Detect dependency cycles defensively** (DFS with recursion stack). If a cycle is found, warn with the cycle path and continue: list any tickets *not* part of the cycle that are still ready, and recommend the user fix the dependencies to unblock the rest. Don't refuse outright.

4. **Compute readiness.** For each `Open` ticket, check if every dependency is `Done`. Those that pass are **ready**; those that don't are **blocked**.

5. **Recommend.** Present the ready tickets ordered by ticket number. Recommend the lowest-numbered ready ticket as the default. If only one is ready, just say so. If none are ready, see "No ready tickets" below.

6. **Optional flip and branch creation.** If the user accepts the recommendation:
   - Cut the ticket branch (see "Git branch creation" below), after both the spec-branch precondition and the dependency-reachability check pass.
   - Flip the ticket's status from `Open` to `In progress` (read the ticket file → edit the frontmatter `status:` to the **literal encoding** — the value set is `open | in-progress | done` per STORE.md and TICKET-FORMAT.md, so the flip writes `in-progress`, never a prose rendering like `in progress`. The flip is a mid-lifecycle working-tree edit, never its own commit — it rides along with the ticket's next real commit; end-of-lifecycle `→ Done` flips have no next commit to ride and are instead committed in the closing skill's gated close-out commit, per STORE.md). **Store edit and git commands stay sequential — never batched in parallel** (see STORE.md; a failed edit inside a parallel batch once cascaded into ~20 cancelled git calls).
   - Otherwise, leave status unchanged and let the user pick differently.

7. **Standing ticket-start step.** Dispatch a research sub-agent as part of ticket start — a standing step, no per-ticket confirm. The sub-agent's brief: map the code and docs relevant to this ticket's Goal and Acceptance criteria, verify any external-toolchain assumptions the ticket or spec makes (stdlib APIs, build semantics, library behavior) against the installed toolchain, and assess whether `/tdd` fits the work. Relay its findings before implementation starts.

## Git branch creation

When flipping a ticket to `In progress`, also cut its branch. Branch naming: `spec-<NNN>/ticket-<NNN>-<slug>` (slash separator gives git-friendly hierarchy). The prefix follows the spec branch's own name: under a legacy `prd-<NNN>-<slug>` branch (the branch link's legacy fallback), ticket branches are `prd-<NNN>/ticket-<NNN>-<slug>` — the hierarchy tracks its parent, and a mid-flight spec never mixes prefixes. The spec branch name comes from the store's branch link (the spec directory name, resolved per STORE.md's branch link row).

**Spec-branch precondition (checked at step 1, re-checked before anything is cut):** the spec's bootstrap must have landed — the linked branch exists (local or remote) *and* its follow-through did too: the planning commit is on the branch. The linked branch is `spec-<NNN>-<slug>`, or its legacy `prd-<NNN>-<slug>` twin per STORE.md's branch-link fallback — a store migrated from the PRD era resolves its in-flight branches without renaming them. (The landed test — inline copy of STORE.md's branch-link state tests, kept inline per its placement test; this paragraph is the skill's one full copy, and the State contract and anti-patterns point here.) If the branch is missing or half-landed, **refuse the flip and the cut**, naming the finding and the fix: which state the test found — branch absent entirely, or half-landed with the planning commit missing — and that re-invoking `/to-tickets` on this spec re-offers its re-enterable bootstrap: only the missing pieces, nothing else. This skill never creates the spec branch: a locally-minted branch would skip the bootstrap's serialize-ticketing preconditions and leave the planning artifacts without their first commit.

**Cut point:** cut the ticket branch from the spec branch — the same base the ticket's eventual diff resolves against (the ticket-scope row of [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md)), so the cut point and the diff base cannot disagree. The cut is unconditional: a stale `strategy` key or comment lingering in an older repo's config is inert per STORE.md's config read contract and never selects a different parent — a repo that genuinely wants another topology is the non-traditional-branching case below.

**Dependency-reachability check (before cutting):** for every dependency of the new ticket, verify its work is reachable from the intended cut point — find the dependency's close commit (or its branch tip if the branch still exists) and check ancestry with `git merge-base --is-ancestor`. This check stays this skill's own single-command prose; DIFF-MATERIALIZATION.md's script is single-purpose and not invoked here. If a `Done` dependency's work isn't reachable, **refuse the cut and name the dependency's resting state** per the resting-state table ([RECOVERY.md](../../_shared/RECOVERY.md#resting-states)) — most often a deferred merge (flip committed, branch unmerged, tree clean), sometimes an interrupted close (the flip uncommitted in the tree). This skill routes; it never walks the gates itself: point at re-running `/done` for that dependency, whose recovery owns both states — an interrupted close resumes at the gated store commit, a deferred merge re-presents the merge fork — on the right branch, with the full show-content machinery. The one forbidden shortcut is merging while close-out edits sit uncommitted (a tree that contradicts its own status); a clean deferred merge is legitimately merge-only. Once the dependency's close lands, re-running `/next-ticket` passes this check and cuts. Cutting from a stale parent silently builds the new ticket on a tree missing its dependency's work — this happened and shipped a real defect.

If the repo uses non-traditional branching (trunk-based with feature flags, stacked-diff tooling like Graphite), degrade gracefully — ask the user which branch to cut from rather than refusing.

## No ready tickets

If no tickets are ready, this means one of:
- **All tickets are `Done`** — recommend `/retro` to close the spec.
- **All `Open` tickets are blocked** — surface the dependency graph and ask the user to investigate (a dependency is wrong, or an in-progress ticket needs to finish first).
- **One or more tickets are `In progress`** and none others are ready — recommend finishing in-progress work first.

## Anti-patterns

- **Don't auto-start the recommended ticket.** Recommend, don't act. The user might want to skip ahead or pick differently.
- **Don't reorder by anything other than dependencies and ticket number.** Don't try to be clever about "which is easier" — that's the user's call.
- **Don't read ticket bodies unless asked.** This is about the queue, not the content — keep it fast (frontmatter only).
- **Don't refuse on cycle detection.** Warn and show productive work that's unblocked. Refusing is too strict when only a subset of tickets are affected.
- **Don't cut a branch silently.** Tell the user the branch name and the parent it was cut from; they may want to verify before starting work.
- **Don't create the spec branch.** A missing linked branch means the bootstrap never landed — refuse per the spec-branch precondition and point at `/to-tickets`' re-enterable bootstrap.
- **Don't batch the status flip in parallel with git commands.**
