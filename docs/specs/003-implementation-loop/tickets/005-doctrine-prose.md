---
status: open
depends_on: []
---

# Doctrine prose

## Goal

The plugin's confirm-gate doctrine prose no longer reads as a blanket "git mutations are offered, never automatic." The README design note states the Consent-vs-Ceremony test (consistent with ADR 0004), and `CLOSE-OUT.md` notes that its own commit and merge gates are Consent under that test — so a reader applying the test to the corpus doesn't mistake a deliberately-kept gate for an automatable one.

## Acceptance criteria

- [ ] The README design note that stated the blanket "offered, never automatic" is refined to state the Consent-vs-Ceremony test, consistent with ADR 0004 and without re-deriving it.
- [ ] `CLOSE-OUT.md` gains at most a one-line pointer that its own commit/merge gates are Consent under the ADR-0004 test; no `CLOSE-OUT.md` gate is described as automatable.
- [ ] No behavioral change to any existing gate; the refined prose and ADR 0004 agree.

## Implementation notes

This is the doctrine sync-set — keep the README note in agreement with ADR 0004. Do **not** add the "ceremony gates may be automated" rule into `CLOSE-OUT.md`; whether any `CLOSE-OUT.md` gate is itself ceremony is out of scope for this spec.

## Deviations

_None yet._
