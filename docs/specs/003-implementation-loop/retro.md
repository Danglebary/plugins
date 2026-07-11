## Ticket 001 — Loop contract doc

**Outcome**: Exact match

The spec's choice to delegate the verification-source resolution to this doc ("owns the resolution") surfaced the one genuinely open design decision — the precedence order — for explicit ratification, instead of letting it hide as an assumption baked into the prose. Validating a contract doc that has no consumers yet is a cross-doc coherence problem, not a test problem: a technical-editor coherence pass — not TDD — is what caught an overloaded term and confirmed the always-stop list stayed a faithful subset of the deviation threshold.

## Ticket 002 — TDD loop adoption

**Outcome**: Extended

Adopting a shared contract into a skill isn't finished when the AC-named section is fixed — the Goal's skill-wide "no contradictory in-flight instruction" claim was the real bar, and it exposed a second contradicting site (`refactoring.md`'s seam-move routing) that satisfying the AC alone would have shipped. That contradiction only had teeth because auto-commit removes the human diff-review that had been silently masking it: automating a ceremony gate can surface latent contradictions the manual review was quietly absorbing.

## Ticket 003 — Implement skill

**Outcome**: Exact match

Building the plan-then-execute skill *in* plan-then-execute mode fit precisely because a Markdown skill has no runtime unit to drive red-green — and closing it exercised the contract's own graceful-degradation path: with no repo verification configured, "green" had no positive signal, so the honest close was to surface for a manual commit rather than auto-exit. The `/tdd` peer's ticket-section carried most of the design; the cite-not-restate boundary — not fresh prose — is what kept `/implement` from silently re-deriving the shared contract and drifting from it.

## Ticket 004 — Mode recommendation

**Outcome**: Exact match

Codifying a "no new gate/knob" requirement lands better as a positive clause naming the gate the recommendation rides than as silence — an absent statement reads as oversight, an explicit "ratified at the existing plan-approval gate" reads as a decision, echoing the store's own materialized-`_None._`-vs-absent distinction. The close caught a self-inflicted near-miss: a cwd-drifted shell check briefly "refuted" a correct research finding, and only re-verifying against source — the close-out pair's own standing discipline — kept a true fact from being discarded.

## Ticket 005 — Doctrine prose

**Outcome**: Exact match

Retiring a blanket doctrine phrase across the corpus is a classification task, not search-and-replace: the canonical source (ADR 0004) must *keep* the retired "offered, never automatic" wording to name what it corrects, and a homonym site (`done/SKILL.md`'s refactor-fork "never automatic", itself a consent gate) legitimately shares the words — so verifying the refinement means telling sync-set site from quotation-by-source from homonym, which a grep-for-zero would have failed three ways. Because ADR 0004's §Consequences had already enumerated the sync-set, this close mostly verified agreement rather than making decisions — the design was front-loaded into the ADR, leaving wording fidelity (state the test, cite rather than re-derive) as the only live risk.

## Ticket 006 — README workflow surfaces

**Outcome**: Extended

Reflecting landed behavior in a flow diagram is a fidelity task, not a paraphrase: the diagram had to preserve the contract's exact distinctions — un-gated ceremony vs. the still-gated close-out, graceful degradation when verification isn't green, and auto-`/done` being explicitly *not* auto-merge — because a looser rendering misleads a reader more than the stale pre-change flow did, and sequencing this ticket last is what let the prose describe the real loop instead of the plan. A corpus that keeps duplicate skill one-liners (plugin README + `engineering/` bucket README) turns a "single surface" ticket into a two-file edit — scoping strictly to the ticket's named surface would have shipped a stale sync-copy, so the honest close records the second file as the Extended scope rather than hiding it.
