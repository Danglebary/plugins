---
status: accepted
---

# 0002 — Hot-path classifications stay inlined in LLM-executed prose

## Context

This corpus is executed by an LLM: a skill's executor holds one SKILL.md plus whatever it deliberately opens. Ticket 004's refactor pass flagged the files-store artifact-path list (`docs/prds/**`, `docs/adr/**`, `docs/spikes/**`, `docs/reviewers.md`, `CONTEXT.md`) as a leaky seam — inlined at four seams beyond its authority in STORE.md's artifact map, each copy citing the authority and then restating it — and proposed consolidating to a single home, the same shape as the CLOSE-OUT.md extraction.

But the list is consulted *mid-step, on the hot path*: every close-out invocation classifies dirty paths against it while routing an exit-5 refusal. The repo's recorded #1 failure mode is procedure fidelity — the whole-plugin review that motivated PRD 001 traced its defects to skipped preflights and mis-executed git prose, and a mid-execution hop to a second document at a decision point is exactly where prose execution skips steps. The list itself is coarse and stable: the globs have not changed since setup.

## Decision

Classifications consulted mid-step on the hot path stay inlined at each decision point, citing their authority. Single-homing is reserved for rarely-executed procedures entered deliberately — the CLOSE-OUT.md gate mechanics, DIFF-MATERIALIZATION.md's stash-aside resume recipe — where a consumer binds variables and cites.

## Consequences

- The inlined copies are a deliberate sync-set: a change to STORE.md's artifact map must fan out to every copy. Accepted because the list is stable; drift protection, if wanted, is a sync-note on the authority listing where copies live — not de-inlining.
- Reviewer passes will keep surfacing the copies as duplication; this ADR is the do-not-re-litigate record.
- The rule gives future conventions a placement test: consulted per-run at a decision point → inline with citation; entered rarely and deliberately → single home, consumers cite.
- Agent briefs are unaffected — they already carry content wholesale, because agents cannot read the store at all.

## Alternatives considered

- **Single-home the path list in STORE.md (the reviewer's proposal).** Rejected: trades a rare, cheap sync cost for a per-run execution-fidelity risk on the corpus's documented weakest axis. A wrong dirty-path classification mis-routes a close-out; a stale copy of a stable list has never yet occurred.
- **Inline everything, including rare procedures.** Rejected: that is the mirror-drift failure the corpus keeps recording (tickets 002 and 003 both caught drifted inline copies of the close-out recipe). Rare procedures don't pay the hot-path fidelity cost — they are read start-to-finish when entered — so they take the single home.
