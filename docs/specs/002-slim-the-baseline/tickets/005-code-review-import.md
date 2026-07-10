---
status: open
depends_on: [004]
---

# Code-review import

## Goal

Ticket close-out judges implementation correctness against the spec, and refactor passes carry a standards baseline. `/done` dispatches a spec-conformance sub-agent alongside the deviation-fact-checker — two reports, presented separately, never merged or reranked, surfaced before the outcome label — and the default Reviewers manifest gains an always-on standards/smell reviewer dispatched by `/improve-codebase-architecture`. All new prose reads in the charter voice, and the spec's corpus target is audited at close.

## Acceptance criteria

- [ ] A spec-conformance agent definition exists; `/done` dispatches it in the same step as the deviation-fact-checker, against the same materialized diff, with the ticket's Goal and Acceptance criteria plus the spec's Approach as its spec source.
- [ ] Its brief covers requirements missing or partial, scope creep, and implemented-but-looks-wrong — each finding citing the spec line and the diff hunk.
- [ ] The two reports render under separate headings with no merged ranking; the outcome-label proposal references both.
- [ ] The deviation-fact-checker's no-editorializing boundary is textually unchanged.
- [ ] A standards/smell reviewer exists in the manifest defaults: the twelve-smell baseline plus repo-standards discovery, a documented repo standard overriding the baseline, findings always labeled judgment calls, tooling-enforced rules skipped.
- [ ] `/improve-codebase-architecture`'s convergence-based merge is unchanged.
- [ ] Final audit: the plugin corpus is at or below ~40,000 words; a miss is reported with its cause rather than closed by forcing cuts — meaning-preserving verification outranks the count.
- [ ] New prose conforms to the style charter, including recommendation-with-reasoning.

## Implementation notes

- Adapted from mattpocock/skills' code-review (two-axis, no-rerank); its fixed-point and spec-discovery machinery collapses away here — the shared diff convention provides the diff, and the ticket is the spec.

## Deviations

_None yet._
