# Retro: Slim the baseline

## Problem — Exact match

The framing held: every named passenger and defect proved real and removable as diagnosed. Notion was a pure passenger — ticket 001 deleted it with no remaining consumer; the PRD misname warranted the full vocabulary change (ticket 002); the comparison's cross-document defects were all reproducible and fixable (ticket 003); and the close-out chain's missing correctness judge was a genuine gap worth importing (ticket 005). Nothing in implementation challenged the problem statement.

## Goals — Extended

All nine goals landed, several needing scope the goal statements didn't enumerate — removing notion took the whole `[store]` config block with it (ticket 001), and the four heaviest closures dropped 27–35% per invocation, clearing the one-third bar (ticket 004). The one miss was the explicitly-subordinate corpus target: 43,826 words against ~40,000 (ticket 005), missed for exactly the reason the goal's own safety carve-out anticipated — ticket 004's meaning-preserving floor was already 41,815, and the code-review import necessarily added ~2,000 words of agents and wiring. The miss was reported with its cause rather than forced away, honoring "meaning-preserving verification outranks the count."

## Non-goals — Exact match

The non-goals held under pressure rather than by neglect. PRD 001's recovery machinery moved without weakening — ticket 004's tier-decorrelated verification actively defended the guarantee, its Sonnet weak-executor probe catching a dropped branch-sweep mechanism every stronger seat read past and restoring it. ADR 0002's hot-path copies stayed inlined with the config-file path fanned out to every copy rather than re-litigated (ticket 003), and no gate or model-invocation reduction landed beyond the single sanctioned setup disable.

## Approach — Divergence

The ordering (notion → rename → defects → fleet → import) executed exactly, but the slimming fleet diverged from the Approach's stated envelope on three user-approved axes: the voice pass ran over the 14 fleet-touched files rather than the whole corpus, model tiering shifted toward Opus under a weekly-budget constraint, and the run spent ~5.6M tokens against the ≈4M target and 5M cap — the verification stage alone ran ~40% over estimate and nothing was thinned to compensate, per the safety-outranks-count rule that surfaced 13 real defects, three semantic (ticket 004). The code-review import then landed as designed (ticket 005), reconstructing mattpocock/skills' two-axis design from prose descriptions alone because the repo's own agent corpus was pattern-dense enough to stand in for the missing upstream.

## Modules touched — Extended

The module enumeration was the floor, not the ceiling: store-contract couplings and marketplace-facing surfaces the list didn't name surfaced as necessary work mid-flight — the artifact filename `prd.md`→`spec.md` and the ticket-branch prefix rule (ticket 002), and the repo-root README, `marketplace.json`, and root CONTEXT headlines that carried the two-backend framing outside the enumerated set (ticket 001). Each was reachable only by following the contract couplings outward from the named modules.

## Refactor — Extended

Ticket 005's refactor pass landed two deepenings beyond the ticket's core scope: it grounded the spec-conformance agent's `file:line` citations by having `/done`'s brief pass the ticket and `spec.md` paths for the agent to read to source line numbers, closing an instruction-capability gap where the required citation had no findable target; and it deduped the always-on reviewer default set toward its authority, pointing `REVIEWERS-FORMAT.md`'s example at `/setup` instead of mirroring the live list.

## Cross-cutting

- **The enumerating list is the floor, not the definition of done** — it recurred in three forms: a zero-matches grep under-scoped notion removal (ticket 001), the enumerated ACs missed the rename's store-contract couplings (ticket 002), and a deviation entry recording a fan-out missed one of its own sites (ticket 003). Each miss was caught downstream by diverse verification — the close-out fact-check (tickets 001, 003) and ticket 004's Sonnet weak-executor probe that read differently from every stronger seat — arguing the real safeguard is grep-verified enumerations plus tier-decorrelated checking, never the list alone.
- **A new plugin-shipped agent carries a one-reload deployment seam** — an agent file created mid-session isn't a registered dispatch type until the plugin reloads, so the first live `/done` ran the new spec-conformance agent inlined into a generic agent (ticket 005); new-agent tickets should expect one degraded-dispatch close before the reload lands.
