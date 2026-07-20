---
status: open
depends_on: [003]
---

# A lens that cannot resolve refuses instead of being improvised

## Goal

An unresolvable `subagent_type` hard-errors at the tool boundary, but nothing stops the dispatching skill from recovering by inlining the agent's body into a general-purpose agent — which is how a lens that never ran once produced output indistinguishable from one that did. `/refactor` already verifies its manifest names resolve; `/done` does not, and `/done` is where that happened. This ticket closes the dispatch layer and rehomes the one rule the corpus already had about checked-versus-not-looked. Out of scope: the agents' own output contracts, which are ticket 004.

## Acceptance criteria

- [ ] `/done` verifies that both close-out agent names resolve before dispatching either, and refuses naming any that do not.
- [ ] Both skills refuse to substitute a general-purpose agent for a named lens, and report that the lens did not run.
- [ ] Both skills pin an exact agent type on every dispatch, never leaving it unspecified.
- [ ] The dispatch record is composed from the intended lens list before any result arrives, and records each as returned, refused, or unresolved.
- [ ] The record is emitted in every case, carrying detail only where a lens did not return.
- [ ] The record is persisted in the ticket's running-retro entry rather than left in the session.
- [ ] `RETRO-FORMAT.md`'s per-ticket entry documents the field.
- [ ] `/refactor`'s reviewer brief no longer requires per-area "checked, clean" lines.
- [ ] `/refactor`'s brief states that the diff reaches reviewers as inlined content.
- [ ] `/done`'s checked-versus-not-looked rule cites the principle doc instead of restating itself, and distinguishes all three states of the deviations section rather than two.
- [ ] `/retro` reads that distinction and reports any ticket whose deviations section was never materialized.

## Implementation notes

The record is an attestation, not a verification — a successful dispatch's return carries no agent identity and the subagent cannot self-identify, so nothing downstream can check it. Word it as what was dispatched and what came back, never as a claim that a lens was correct.

Do not pass `.pirr/diff.patch`'s path to reviewer agents: exactly two agent bodies name that artifact and that is a published contract. Making the inlining explicit is the fix.

The anti-substitution rule has a shape to match in both skills — the existing refusal to fall back to a hand-rolled diff.

## Deviations

_None yet._
