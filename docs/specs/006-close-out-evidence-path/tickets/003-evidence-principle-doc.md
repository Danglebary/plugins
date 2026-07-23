---
status: done
depends_on: []
---

# The evidence rules get one home

## Goal

The rules governing what counts as having checked something are stated nowhere, except once inside `/done` for one section — and that statement justifies itself by naming a consumer that does not read it. Agents and dispatching skills need a single authority to cite before either can be changed. This ticket writes it. Out of scope: applying it — the agents are ticket 004, the skills ticket 005; nothing else in the corpus is edited to cite this doc yet.

## Acceptance criteria

- [ ] A new doc under `skills/_shared/` states the honesty rule, the partial-verdict register, the empty-read corollary, and the dispatch record.
- [ ] The register is specified as gap-only in contents but mandatory in emission, with a named sentinel for the no-gap case.
- [ ] The doc states that a return carrying no register is off-contract, and that silence is therefore not a clean result.
- [ ] The doc requires the register to sit ahead of any instruction that would halt output.
- [ ] The empty-read rule binds only where absence is the claim, and requires the searched pattern, the searched paths, and a control match proving the search resolved.
- [ ] The doc states that a surface reported in the register is never also reported as a finding, and that findings keep their own verification caveats.
- [ ] The dispatch record is described as an attestation that nothing downstream can audit, with its weight resting on the pre-dispatch resolution check.
- [ ] `AGENT-FORMAT.md`'s documented output-contract shape carries the register, so an author writing a new agent inherits it without reading this doc.
- [ ] The doc cites ADR 0006 as its source rather than restating the decision's rationale.

## Implementation notes

This is a Principle doc, not a Format doc — it binds skills as well as agents, which is precisely why ADR 0006 rejected homing the rule in `AGENT-FORMAT.md`. Name it accordingly.

### Deferred steers

- From ticket 001's refactor pass: **`spec.md`'s `file:line` citations into the corpus are stale — re-resolve every anchor by its quoted phrase, never by the number.** Ticket 001's diff shifted the lines the spec points at: `DIFF-MATERIALIZATION.md:52` → the "Three semantics guarantees" block at `:55-:56`, `:62` → `:66`, `:66` → `:70`; `/refactor:62` → `:66`; `/done:65` → `:71`; and `IMPLEMENTATION-LOOP.md:26` still exists but no longer contains the sentence the spec quotes from it (deleted and superseded at `:28`). `spec.md` is frozen *and* a `contract-tamper.sh` guarded target, so correcting the numbers in place would trip a Consent gate on the very document this ticket is judged against — the anchors get re-resolved at implementation time instead.

## Deviations

_None._
