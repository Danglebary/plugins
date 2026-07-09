---
status: done
depends_on: [002, 005]
---

# /next-ticket branch preconditions

## Goal

`/next-ticket` operates only on real branch state: it never creates the PRD branch, refuses with a pointer to the re-runnable bootstrap when the branch is missing, and its recovery and ride-along prose match the canonical copies established by tickets 002 and 005.

## Acceptance criteria

- [ ] Starting a ticket when the PRD branch doesn't exist refuses and names `/to-tickets`' re-enterable bootstrap as the fix; no lazy PRD-branch creation path remains anywhere in the skill.
- [ ] The ticket branch is still cut from the PRD branch on accept, citing the shared base-resolution convention.
- [ ] The dependency-reachability recovery mirrors `/done`'s canonical close-out recipe (commit close-out edits, then merge) rather than a merge-only recipe.
- [ ] The skill's copy of the ride-along rule matches the store doc's amended text (start-of-lifecycle flips ride; end-of-lifecycle flips are committed at close-out).

## Implementation notes

### Deferred steers

- From ticket 003's close-out: `/next-ticket`'s `Open → In progress` flip executed as `status: in progress` where STORE.md and TICKET-FORMAT.md pin the files-store encoding `in-progress` — a strict frontmatter reader would not match the ticket as `In progress`. The flip step should quote the literal encodings (`open | in-progress | done`) rather than naming the transition in prose, so execution can't drift from spec.
- From ticket 003's refactor pass: the canonical close-out recipe now lives in `_shared/CLOSE-OUT.md` — the dependency-reachability recovery's AC ("mirrors `/done`'s canonical close-out recipe") resolves to consuming that doc (commit gate, then merge gate), not to copying `/done`'s inline prose.
- From ticket 005's refactor pass: the missing-branch refusal makes this skill the second consumer of the unmerged-`prd-*`/bootstrap-landed check (`/to-tickets`' serialize-ticketing precondition 2 and its State contract's "landed" definition are currently the only home). Mint a citable authority — natural home: DIFF-MATERIALIZATION.md beside the default-branch procedure, or STORE.md's branch-link row — so the inline copies become ADR-0002-shaped cite-the-authority members instead of uncited mirrors.

## Deviations

- Beyond the surfaces the ticket names: CLOSE-OUT.md's Consumers section gained a one-sentence `/next-ticket` clause (a router-only consumer — reachability recovery sends an unfinished dependency close through the gates before cutting). The recovery AC makes this skill a consumer of that doc, and its consumer inventory would otherwise have gone stale.
- Steer 3 offered two homes for the minted authority; chose STORE.md (new `## Branch-link state tests` section) over DIFF-MATERIALIZATION.md — both tests are predicates over the branch link, which is STORE.md's domain, and the landed test is backend-differentiated (planning commit vs `Branch`/`Diff base` writes); the unmerged test is store-neutral git ancestry and cites DIFF-MATERIALIZATION.md's default-branch procedure from there.
