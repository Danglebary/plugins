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

### Deferred steers

- From ticket 001's refactor pass: **re-resolve `spec.md`'s anchors by quoted phrase, not by line number.** Three of this ticket's own anchors moved in ticket 001's diff: `DIFF-MATERIALIZATION.md:62` (the two-agent artifact contract this ticket's Implementation notes rest on) → `:66`; `/refactor:62` (the per-area "checked, clean" requirement this ticket removes) → `:66`; `/done:65` (the sentinel sentence this ticket rehomes) → `:71`. `spec.md` is frozen and a `contract-tamper.sh` guarded target, so the numbers stay and the anchors get re-resolved here.
- From ticket 001's refactor pass: **`/refactor`'s brief requires a toolchain verification no agent can perform** — all fifteen are `tools: [Read, Grep, Glob]`. This ticket already edits that brief line to drop "checked, clean"; decide at the same time whether the toolchain-verification half survives unchanged, since it is currently an instruction every dispatched lens must decline. Paired steer on ticket 004, which owns the register side of the same gap.

## Deviations

_None yet._
