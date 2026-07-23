# Retro: 006 — the close-out evidence path

## Ticket 001 — Untracked implementation files stop a close-out

**Outcome**: Extended

Designing the preflight against the repo's actual resting state rather than the ticket's imagined one changed the answer: six untracked banked ideas sat in the tree the whole time, which killed the stash-widening approach (ceremony plus a crash window on every routine close-out) in favor of a report-then-acknowledge round trip. A preflight added to a shared mechanism acquires callers nobody enumerated — the new exit fired inside `RECOVERY.md`'s resume recipe, and the deviation entry declaring that file "untouched" recorded the non-edit while missing its consequence, which is the shape a non-edit's blast radius always takes. The close-out pair earned its keep here: four real defects, two of them leaving an acceptance criterion partial, none of which the implementing session saw.

## Ticket 002 — A guarded section is compared in full and in isolation

**Outcome**: Extended

Chasing a bats line number that contradicted a hand trace found the larger bug: on bash 3.2 a failing `[[ ]]` inside a function trips neither `errexit` nor the ERR trap, so only a test's final command decides pass/fail and 26 of 67 assertions across both suites never ran — the guard-that-reports-all-clear failure this spec exists to close, sitting in the tests that were supposed to be checking for it. The lesson generalizes past bats: an assertion is infrastructure, and infrastructure that has never been observed failing is unverified regardless of how many times it has "passed". Two fence defects collapsed into one fix once fence state gated the start condition as well as the stop, which is why AC1 and AC2 needed no separate mechanism; and the close-out pair caught a narrowing the plan gate had approved but neither the deviations nor any fixture recorded — approval at plan time does not survive as evidence, only a test does.

## Ticket 003 — The evidence rules get one home

**Outcome**: Exact match

An ADR fully settled during grilling turned implementation into transcription: the plan gate carried only naming and inclusion decisions, and the diff produced zero deviations — the cheapest close in the spec so far, which is what front-loading design into the ADR buys. The deferred resolve-by-phrase steer proved itself immediately: two of the six anchors it covered had shifted *again* since the steer was written, confirming that a line number cited across a spec branch's lifetime is stale the moment a sibling ticket lands, and only the quoted phrase survives. Homing the rules ahead of their application leaves the format doc deliberately leading the live agent bodies — a planned drift window the sequencing (003 before 004/005) prices in rather than avoids.
