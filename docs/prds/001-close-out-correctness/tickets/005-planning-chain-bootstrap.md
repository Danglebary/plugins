---
status: done
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

- The serialize-ticketing preconditions are verified twice, not only at the ending: once when the PRD is identified (failing fast beats a proposal conversation that cannot land) and re-verified at the bootstrap, which stays the authoritative gate per the acceptance criterion.
- "Clean default-branch checkout" is pinned to *no tracked modifications outside the store-artifact paths*: a fully-clean demand would refuse the very grill-minted Glossary/ADR edits the bootstrap must commit (tracked modifications whenever `CONTEXT.md` or an ADR pre-exists).
- The bootstrap re-entry arm idempotently restores a missing active pointer before re-offering the cut-plus-planning-commit — a crash between the `Open` flip and the pointer write would otherwise re-enter an ending that commits one artifact short.
- The decline arm front-runs ticket 006's side of the seam: replacing the removed decline→lazy-creation edge, it states the end-state contract ("no PRD branch exists, so ticket work can't start"), which transiently contradicts `/next-ticket`'s still-lazy prose until ticket 006 lands — chosen over scope-dodging wording that 006 would only have to rewrite.
- (refactor) CLOSE-OUT.md's commit gate generalized from close-only to the gated store commit — enumeration is now authorship-scoped (foreign store-path entries excluded and named, never swept) — and `/to-tickets`' bootstrap became its fourth listed consumer, binding-and-citing instead of restating: named paths in the offer, show-content on the resumed commit half.
- (refactor) The bootstrap discriminator checks the follow-through, not the cut: "landed" pinned to branch (local or remote) *plus* planning commit (files) / `Branch`+`Diff base` writes (notion), so a crash between cut and follow-through routes to re-entry's resume arm instead of the frozen-scope refusal; precondition 2 exempts the PRD's own half-landed branch on resume.
- (refactor) The bootstrap's store fork made explicit: per-store offer wording so consent matches effect (notion's offer no longer promises a commit that arm never performs), and notion's *clean* pinned to fully clean — the store-artifact-path exemption is files-only.
- (refactor) The ending forks on the bootstrap outcome — a declined bootstrap recommends re-invoking `/to-tickets`, never `/next-ticket` against its own stakes — and refusals harden: every failing precondition named at once, "abandon" routed through STORE.md's abandoning row (never a bare branch delete), commit-or-stash ordered before the branch switch.
- (refactor) Contract copies reconciled to the new `/to-tickets` contract: PRD-FORMAT's two state-transition sentences, the README's frozen-artifacts Design note, both README one-liners' files-store qualifier, `/to-prd`'s slug-vs-directory-name conflation, STORE.md's branch-link row, and the pointer-encoding clause at `/retro`'s comparing site and `/done`'s identify site.
