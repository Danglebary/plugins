---
status: open
depends_on: [001]
---

# Planning chain and bootstrap gate

## Goal

The planning phase is one codified chain that ends with the PRD branch cut and the planning artifacts landed: `/next-prd` hands off to a high-level `/grill-me`, and `/to-tickets` — under serialize-ticketing preconditions — ends at a gated, re-enterable bootstrap. Out of scope: `/next-ticket`'s side of the hand-off (ticket 006).

## Acceptance criteria

- [ ] `/next-prd` ends by recommending a high-level `/grill-me`, never `/to-prd` directly, and the README's workflow chain shows the full sequence (`/next-prd` → `/grill-me` → `/to-prd` → `/grill-me` → `/to-tickets`).
- [ ] `/to-tickets`' ending refuses with instructions when another PRD is active or has an unmerged `prd-*` branch, or when the session is not on a clean default-branch checkout; drafting skills remain runnable from any checkout.
- [ ] The accepted bootstrap cuts `prd-<NNN>-<slug>` from the default branch resolved per the shared base-resolution convention, and (files store) commits all planning artifacts — PRD, tickets, active pointer, grill-minted Glossary/ADR edits — as the branch's first commit; the notion bootstrap is the cut plus the existing `Branch`/`Diff base` property writes, no commit.
- [ ] Declining the bootstrap states loudly that the planning artifacts are untracked and ride only the working tree until that commit.
- [ ] Re-invoking `/to-tickets` on an `Open` PRD that has tickets but no branch re-offers only the cut-plus-planning-commit — no re-ticketing; ticket creation stays one-shot.
- [ ] The active pointer's content is the PRD directory name (`<NNN>-<slug>`), stated identically at every site that writes or reads it.

## Deviations

_None yet._
