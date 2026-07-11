## Ticket 001 — Loop contract doc

**Outcome**: Exact match

The spec's choice to delegate the verification-source resolution to this doc ("owns the resolution") surfaced the one genuinely open design decision — the precedence order — for explicit ratification, instead of letting it hide as an assumption baked into the prose. Validating a contract doc that has no consumers yet is a cross-doc coherence problem, not a test problem: a technical-editor coherence pass — not TDD — is what caught an overloaded term and confirmed the always-stop list stayed a faithful subset of the deviation threshold.

## Ticket 002 — TDD loop adoption

**Outcome**: Extended

Adopting a shared contract into a skill isn't finished when the AC-named section is fixed — the Goal's skill-wide "no contradictory in-flight instruction" claim was the real bar, and it exposed a second contradicting site (`refactoring.md`'s seam-move routing) that satisfying the AC alone would have shipped. That contradiction only had teeth because auto-commit removes the human diff-review that had been silently masking it: automating a ceremony gate can surface latent contradictions the manual review was quietly absorbing.
