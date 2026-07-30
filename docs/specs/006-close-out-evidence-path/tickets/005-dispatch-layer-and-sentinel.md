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
- From ticket 002's refactor pass: **`/done`'s tamper-changed Consent gate over-promises that a `changed` verdict is always a diff-visible rewrite.** At the tamper-output read, `/done` instructs the executor to name the moved section(s), parenthesizing that "their head rewrite is visible in the step-2 diff `.pirr/diff.patch`" — false for the fail-safe `changed` causes: an ambiguous duplicate heading, or a target absent at both refs, reports `changed` without the file being a diff-visible rewrite (it may not appear in the diff at all). Ticket 002 widened that set by adding the repeated-heading ambiguity case; the imprecision pre-dates it via the absent-at-both-refs case. When this ticket reworks `/done`'s tamper read and sentinel region, soften the parenthetical so it admits the fail-safe/ambiguity causes rather than promising the moved text is always locatable in the diff. Re-resolve the `/done` anchor by quoted phrase ("their head rewrite is visible in the step-2 diff"), not by line number.
- From ticket 003's refactor pass: **the Dispatch record's keeper set is settled as `/refactor` and `/done`** (EVIDENCE-PRINCIPLE.md, matching ADR 0006 and the Glossary); `/retro` cites the doc for the agent-layer and sentinel rules and keeps no record of its own. `spec.md`'s Modules-touched line assigns `/retro` "the dispatch record" — the spec is frozen and tamper-guarded, so the line stays as written; record the divergence as a deviation on this ticket when it lands. Also settled there: a return carrying no register is recorded as **degraded, not returned** — the record's "returned" category requires the register's presence (the off-contract bullet's assigned receiver).
- From ticket 003's refactor pass: **the Resolution preflight's refusal arm has never been observed firing in a dispatching skill.** When this ticket lands, dispatch once with a deliberately unresolvable `subagent_type`, observe the named refusal, and confirm the dispatch record marks the lens unresolved; record the observation in the running retro. Paired with ticket 004's forced-gap steer — infrastructure never observed failing is unverified.
- From ticket 004's refactor pass: **the planted-instruction reporting doctrine (ADR 0008) has never been observed firing.** Ticket 004's pass discharged the *register* observation (seven post-reload reviewers fired the failure arm with real gap entries — recorded in this spec's retro), but the content-channel reporting behavior it shipped is untested. Fire a behavioral fixture — one planted instruction in reviewed material — and confirm the four arms: a non-owning reviewer stays silent, the owning lens (`security-engineer` for non-prompt material, `prompt-expert` for a prompt artifact) reports it as a candidate, the close-out pair emit the flagged callout, and ordinary imperative prose addressed to a programmer is *not* flagged by anyone. Retires the qa-engineer "no behavioral fixture" finding from that pass. Pair it with the preflight-refusal observation above — same post-reload dispatch batch.

## Deviations

_None yet._
