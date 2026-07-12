# Retro: Reviewer trust boundary

## Problem — Exact match

The framing held: a single post-diff state letting one diff both trip a rule and rewrite the authority that would catch it was exactly the weakness all three tickets hardened, and nothing in execution pushed back on it. Ticket 003's own close-out re-confirmed the latency the Problem described — base and head were identical, so judging conformance against base changed nothing — which is precisely why the weakness is harmless in the Personal workflow yet worth extracting from the shared surface the Work plugin will inherit.

## Goals — Exact match

All six goals shipped as written. Both agents stayed toolless (`tools: [Read, Grep, Glob]` unchanged in each), git mechanics stayed in the dispatcher-side `contract-tamper.sh`, and neither agent's output contract moved — ticket 001's security flip rode the Source `baseline:` arm and the mandatory Judgment-call field that already existed, and ticket 003's base-for-head swap reused the existing `file:line` citation shape. The `## Deviations` exemption held structurally rather than by a guard (ticket 002), and the Work plugin was never touched.

## Non-goals — Exact match

Every fence held: no base-tree snapshot, worktree, or git tool for the agents — the base contract is built dispatcher-side from targeted `git show <base>:<path>` reads (ticket 002) and handed to the toolless agents inline; no new output section or heading in either agent; no new principle doc, with each site citing ADR 0005 for the shared rationale; and the Work plugin's own dispatch-layer defenses were left to that plugin.

## Approach — Extended

The load-bearing design landed as written — the two-agent split (findings vs verdict), the `standards-reviewer` precedence caveat (ticket 001), the `spec-conformance` base-contract-plus-dispatcher-alarm (ticket 003), section-granular extract-and-compare over `git show` versions, and fail-safe heading drift all matched the spec. The one edge the Approach left open — the tamper script's exact interface — execution filled at ticket 002's plan gate: the script takes generic `(path, heading)` target pairs rather than hardcoding the three guarded sections (keeping the "what is guarded and where" policy in `/done` per the diff-materialization division of labor, which made the `## Deviations` exemption structural), and emits its tamper flag as exit-0 stdout data so the base contract stays consumable regardless of tamper and a caller's `set -e` cannot misread "tampered" as a script failure.

## Modules touched — Exact match

Every enumerated module landed and no others: the `standards-reviewer` and `spec-conformance` agent bodies, `/done`'s close-out brief and tamper step (`SKILL.md`), the new `scripts/contract-tamper.sh` plus its bats fixtures as `/done`'s only consumer, and the *Reviewer trust boundary* Glossary term in `CONTEXT.md`.

## Refactor — Extended

Both `(refactor)` passes landed in ticket 002 and both deepened the security posture past the original scope. The reviewer pass (software-architect + security-engineer + qa-engineer) closed a fail-open — `contract-tamper.sh` now fails safe to `changed` when a guarded section is absent at *both* refs, which a heading typo, case/whitespace mismatch, path typo, or an untracked format-doc rename would otherwise trip into a silently-empty base contract feeding ticket 003's conformance grounding. The second pass (prompt-expert; standards-reviewer + dx-expert) hardened `/done`'s step-3 surface into an explicit turn-ending Consent gate that relays stderr and stops on any non-zero script exit, so the acknowledgment can no longer degrade into a notification the executor glides past, and gave the script a documented exit-code taxonomy matching `materialize-diff.sh`.

## Cross-cutting

- Bolting the trust-boundary mechanic onto `standards-reviewer` phrased its check against "the diff" and its `+` hunk lines rather than naming `.pirr/diff.patch` literally (ticket 001) — a deliberate choice to stay off DIFF-MATERIALIZATION.md's "exactly two agents name the artifact" invariant, and a standing reminder that adding a mechanic to an agent can quietly introduce cross-doc drift with a shared reference doc.
