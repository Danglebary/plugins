---
status: in-progress
depends_on: [003]
---

# Slimming fleet

## Goal

The corpus is slimmed by the verified fleet workflow — recovery procedures relocated to one on-demand home, contracts deduplicated to their authorities, meaning-preserving compression, and description trims — with every normative clause accounted for by verification independent of the writers, and every protected span byte-identical. After this ticket, each of the four heaviest skill closures loads at most two-thirds of its measured baseline, and no recovery semantics have been removed.

## Acceptance criteria

- [ ] Per-invocation closure loads (SKILL.md plus every unconditionally-instructed doc): improve-codebase-architecture ≤ 7,932 words; done ≤ 6,843; retro ≤ 6,405; to-tickets ≤ 5,900 — one-third under the measured baselines.
- [ ] Protected spans (state contracts, gate declarations, protected-behavior blocks, the exit-code table) are hash-identical before and after, verified by script, not judgment.
- [ ] Every clause in the stage-0 ledger is accounted for: present at a mapped location, or explicitly deleted/relocated with justification; blind re-derivation reports zero unmapped clauses; adversarial hunters report zero unresolved modal weakenings.
- [ ] Executor simulation on the four heaviest closures reports identical routing at every decision point against the pre-slim skills.
- [ ] Recovery procedures live in one single-homed on-demand doc entered when a discriminator fires; the discriminators stay inline at their decision points.
- [ ] Each incident citation appears exactly once, at the rule it justifies.
- [ ] Frontmatter descriptions total ≤ ~300 words with model-invocation trigger phrases intact; setup-agentic-flow carries `disable-model-invocation: true`; no other skill gains it.
- [ ] The style charter (carrying the recommendation-with-reasoning rule) was presented and user-approved before any rewriting; the post-fleet corpus word count is reported.

## Implementation notes

- Execute as one workflow per the spec's Approach: quality-max shape, mixed model tiers, ~4M token budget against a 5M cap; writers own write-disjoint clusters; sync-set copies are stamped from stage-0 canonical cards, never authored; the voice pass precedes final verification and files it touches re-enter verification.

## Deviations

_None yet._
