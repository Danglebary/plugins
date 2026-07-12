---
status: done
depends_on: [004]
---

# Code-review import

## Goal

Ticket close-out judges implementation correctness against the spec, and refactor passes carry a standards baseline. `/done` dispatches a spec-conformance sub-agent alongside the deviation-fact-checker — two reports, presented separately, never merged or reranked, surfaced before the outcome label — and the default Reviewers manifest gains an always-on standards/smell reviewer dispatched by `/refactor`. All new prose reads in the charter voice, and the spec's corpus target is audited at close.

## Acceptance criteria

- [ ] A spec-conformance agent definition exists; `/done` dispatches it in the same step as the deviation-fact-checker, against the same materialized diff, with the ticket's Goal and Acceptance criteria plus the spec's Approach as its spec source.
- [ ] Its brief covers requirements missing or partial, scope creep, and implemented-but-looks-wrong — each finding citing the spec line and the diff hunk.
- [ ] The two reports render under separate headings with no merged ranking; the outcome-label proposal references both.
- [ ] The deviation-fact-checker's no-editorializing boundary is textually unchanged.
- [ ] A standards/smell reviewer exists in the manifest defaults: the twelve-smell baseline plus repo-standards discovery, a documented repo standard overriding the baseline, findings always labeled judgment calls, tooling-enforced rules skipped.
- [ ] `/refactor`'s convergence-based merge is unchanged.
- [ ] Final audit: the plugin corpus is at or below ~40,000 words; a miss is reported with its cause rather than closed by forcing cuts — meaning-preserving verification outranks the count.
- [ ] New prose conforms to the style charter, including recommendation-with-reasoning.

## Implementation notes

- Adapted from mattpocock/skills' code-review (two-axis, no-rerank); its fixed-point and spec-discovery machinery collapses away here — the shared diff convention provides the diff, and the ticket is the spec.

## Deviations

- Extended CONTEXT.md's Knowledge-layer enumeration with the spec-conformance agent (as "the close-out pair" alongside the deviation fact-checker) — the layer is the cross-plugin API surface (ADR 0001), and the Work plugin must invoke the new close-out analyzer rather than fork it; the ticket named only the agent and its /done wiring, not the layer membership.
- (refactor) Grounded the spec-conformance agent's `file:line` citations: `/done`'s brief now passes the ticket and `spec.md` paths, and the agent reads them to source line numbers rather than citing the inline copy — closing an instruction-capability gap where the required citation had no findable target.
- (refactor) Deduped the always-on reviewer default set toward its authority: `REVIEWERS-FORMAT.md`'s example stops mirroring the live list (now points at `/setup` as the source of truth), leaving the setup skill as authority and `docs/reviewers.md` as a generated per-repo instance.
