---
status: open
depends_on: [002]
---

# spec-conformance judges against the frozen base contract

## Goal

Close the `spec-conformance` half of the reviewer trust boundary: the agent renders its verdict against the frozen base contract, not a diff-rewritten one. `/done` inlines the line-numbered base Goal/Acceptance/Approach (from ticket 002's script) into the shared close-out brief, and the agent inverts its citation-grounding to treat that inlined base copy as authoritative for the three guarded sections — citing their base line numbers rather than re-grounding against the possibly-rewritten head ticket file or head `spec.md`. Code verification still uses Read/Grep over the working tree. Governed by ADR 0005.

## Acceptance criteria

- [ ] `/done`'s shared close-out brief inlines the base Goal/Acceptance (ticket) and Approach (`spec.md`) with absolute base line numbers, sourced from ticket 002's script, replacing the current head-sourced inline.
- [ ] `spec-conformance` treats the inlined base copy as authoritative for the three guarded sections and cites `file:line` resolved against the base version, inverting today's "open the file to ground the line number rather than citing the inline copy" instruction for those sections only.
- [ ] The agent's `looks-wrong` verification and pre-existing-code checks still use Read/Grep over the working tree (head); only the spec-source citation grounding of the guarded sections flips.
- [ ] A diff built to rewritten Acceptance criteria but not the base criteria surfaces through the existing sections (missing/partial or scope creep), judged against the base.
- [ ] No new citation syntax and no change to the agent's output sections or fields; the `deviation-fact-checker` is unaffected by the base-for-head swap in the shared brief.
- [ ] Cites ADR 0005.

## Implementation notes

The agent change is the citation-grounding inversion in `plugins/agentic-flow/agents/spec-conformance.md`'s "Inputs and verification scope" — scoped to Goal/Acceptance/Approach only. The base line-numbered text comes from ticket 002's script; do not add git access to the agent. The inline lands in the same shared brief both close-out agents receive (`skills/engineering/done/SKILL.md` step 3).

## Deviations

_None yet._
