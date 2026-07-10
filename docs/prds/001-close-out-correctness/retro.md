# Retro: Close-out correctness for the Personal workflow

## Problem — Exact match

The framing held to the point of self-demonstration: ticket 001's own close-out tripped the dirty-tree condition its script had just been built to catch, and no ticket surfaced a close-time failure the review hadn't already named. The problem statement needed no revision during execution.

## Goals — Extended

All eight goals shipped, and the re-enterability goal grew a ticket-scope mirror the PRD only claimed for `/retro`: `/done`'s already-`Done` refusal became merge-aware too (ticket 002), so both lifecycle scopes now re-offer rather than orphan. Recovery went deeper than "completes without a git refusal" — the interrupted-close discriminators at both closes (tickets 002, 004) made crash states derivable from git alone.

## Non-goals — Exact match

The Work workflow, notion hardening, and the remaining contract repairs all stayed out. The one touch near the boundary — rescoping CONTEXT.md's Knowledge-layer clause from "must not assume" to "must not perform" (ticket 008) — reconciled vocabulary with advisory git reads rather than moving scope.

## Approach — Extended

Every approach bullet landed as written, but the "three synced copies change together" plan for the close-out recipe didn't survive contact: copies drifted twice within one ticket, and ticket 003 extracted `_shared/CLOSE-OUT.md` as the single home with per-skill bindings instead. Unplanned authorities followed the same pattern — STORE.md grew the branch-link state tests (ticket 006), their enumeration rule and two-tier observation policy (ticket 008), and the config read contract (ticket 007) — the PRD prescribed conventions; execution kept discovering they needed single homes.

## Modules touched — Extended

All five listed module groups were touched as planned, plus growth the list didn't name: CLOSE-OUT.md as a second new convention doc, TICKET-FORMAT.md's `### Deferred steers` subsection (ticket 003), and the repo's first executable surface — the script plus its bats suite (ticket 001).

## Refactor — Extended

Twenty-six `(refactor)` deviations across all eight tickets, dominated by one move: extract a drifting or uncited copy into a citable authority (CLOSE-OUT.md in ticket 003, the stash-aside resume recipe into DIFF-MATERIALIZATION.md in 004, the branch-link tests and observation tiers into STORE.md in 006/008, the config read contract in 007). The rest were hardening passes the plans didn't name — the script's symlink refusal and format pinning (001), exhaustive interrupted-close discriminators (002, 004), positive closure verification replacing deleted-branch⇒merged inference (004), and the number-collision recheck (008).

## Cross-cutting

- The `in progress` vs `in-progress` encoding drift shipped twice (tickets 003, 006) — the second time with the corrective steer sitting unread in the very ticket being started. Only executed skill prose prevents a failure mode; flip steps now quote literal encodings.
- Comments that enumerate their consumers rot silently: ticket 007 found the merge-key comment misattributing a reader at the very moment of correction. Point at the seam that owns the list, or re-verify the enumeration at every edit.
- The fact-checker's useful surface is wider than diff↔record mapping: it caught a transient cross-skill contradiction (ticket 005), a false rationale inside a deviation entry (ticket 006), and encoding drift in planning hunks it was told not to code-review (ticket 003).
- `### Deferred steers` emerged mid-PRD as the carrier for cross-ticket obligations (formalized in ticket 003, consumed in 004, 006, 008) — serial slicing across a shared seam works when the front-runner records the end-state contract and the steer routes the follow-through.
