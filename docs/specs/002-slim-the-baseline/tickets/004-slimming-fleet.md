---
status: done
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

- **STORE.md budget sacrifice, partially reversed (stage 3, further reversed stage 5).** The 1,100-word budget conflicted with full clause conservation (ledger floor ~1,340): rationale-only or restated-elsewhere rows were dropped with per-row justification in the fleet's conservation TSV (recoverable verbatim from the frozen ledger). Two drops were later reversed: the runtime-visible missing-`settings.toml` regenerate offer (restored by the orchestrator post-stage-3) and the branch-sweep `for-each-ref` mechanism with its git-glob caveat (restored by the stage-5 fixer after the weak-executor simulation probe showed a naive sweep would leak ticket branches). Five documented drops stand.
- **Voice pass scoped to fleet-touched files, not whole-corpus (stage 4).** The spec's Approach says whole-corpus; the pass ran over the 14 files the fleet rewrote. Reasoning: untouched files retain their original voice by definition, and the trim reduced the fleet's token spend. User-approved at the stage-3 gate.
- **Model tiering shifted toward Opus (user-directed at ticket start).** The spec's Approach assigns the top tier to cartography, the charter, all writers, half the hunters, most simulation seats, the voice pass, and the final gate; with the user at 70% of weekly top-tier budget, the fleet ran Opus for cartography, the skill/format writers, the voice pass, and most simulation seats — keeping the top tier for the four multiplier-doc writers, the relocation/dedup planners, hunter seats over Opus-written files, the multiplier-ledger spot-audits, and the final audit. Writer/verifier tier decorrelation was preserved in both directions. Approved with the tier plan before the fleet started.
- **Token cap exceeded (~5.6M vs the spec's ≈4M target / 5M cap).** Stage totals: cartography 1.03M + ledger fixes 0.15M + relocate 0.53M + dedup 0.74M + compress 1.30M + voice/verify/audit 1.79M, plus the ticket-start research opener. The verification stage ran ~40% over estimate; nothing was thinned to compensate, per the spec's rule that meaning-preserving verification outranks the count — and it caught 13 real defects, three of them semantic.
