# Evidence

A coverage claim is made by the layer that can attest to it, and by no other. This doc is the single home for the rules governing what counts as having *checked* something — the honesty rule, the **Partial verdict** register, the **Empty read** corollary, and the **Dispatch record**. The plugin's claim-making agents and the skills that dispatch them (`/refactor`, `/done`, `/retro`) cite this doc; the decision behind it is [ADR 0006](../../../../docs/adr/0006-coverage-claims-split-by-attestability.md), which holds the rationale and the rejected alternatives — neither is restated here.

Two layers make claims, and each attests only to what it can observe. The **dispatch layer** — the skill invoking agents — can observe whether a lens *ran*: it checks every named `subagent_type` before dispatch (the **Resolution preflight**), refuses on an unresolved name rather than improvising, and records what was dispatched. The **agent layer** can observe only its own reading: it reports the surfaces it could not check, and nothing else. Neither layer claims the other's half.

## The honesty rule

A checked-clean claim is made positively or not at all — silence is never a clean result, because silence is indistinguishable from not-looked.

The same rule materialized in a store artifact has three states, not two: an **absent** section reads "nobody checked"; the scaffold placeholder (`_None yet._`, per [TICKET-FORMAT.md](./TICKET-FORMAT.md)) reads "not yet"; the explicit sentinel (`_None._`) reads "checked, clean". Only the third is a claim, and only because it is explicit.

## The Partial verdict register

Every claim-making agent ends its output with a register of the surfaces *within the lens it ran* that it could not resolve — unavailable, denied, simply not consulted, or read-but-unresolved (an empty search whose positive control failed, per the **Empty read** corollary below) — naming each surface and what resolving it would have confirmed. **Claim-making** has an operational test: the agent's return asserts findings, verdicts, or absences about material it examined, rather than only producing an artifact. Both shipped classes ([AGENT-FORMAT.md](./AGENT-FORMAT.md)'s Reviewer and Workflow agents) qualify, and so does any future agent meeting the test — the qualifier scopes the rule; it is not an opt-out.

- **Contents are gap-only.** The register never enumerates what *was* checked — the enumerated form is rejected (ADR 0006).
- **Emission is mandatory.** When there is no gap, the register is the sentinel `_Full._` — one token, recording that the gap check ran. `_Full._` is not itself a coverage claim.
- **A return carrying no register is off-contract.** Silence is not an available outcome, and is therefore never a clean result; the missing register is the one post-hoc signal the dispatch layer has that a return degraded. The signal has an assigned receiver: the dispatch layer checks every return for the register's *presence* — never its contents — and a register-less return is recorded in the dispatch record as degraded, not as returned.
- **The register sits ahead of any instruction that would halt output.** A register placed after a halt ("output `_No candidates._` and stop") is unreachable in exactly the case it exists for — an unread surface and an empty candidate list correlate.

The register is copied into every shipped agent body (`plugins/pirr/agents/*.md`) as a deliberate sync-set — a change to its wording here fans out to every copy, and to the `work-plugins` fork's copies by hand.

A worked example: an agent instructed to verify a claim against the installed toolchain, holding a tool grant of `Read, Grep, Glob`, cannot execute anything — that check is a register entry (the surface, and what running it would have confirmed), never a silent skip and never a fabricated pass.

### Findings and the register never overlap

A surface reported in the register is never also reported as a finding, and a finding is never moved to the register to soften it. Findings keep their own verification caveats ("couldn't verify against X") inside the finding; the register records **surfaces**, never findings.

## The Empty read corollary

An empty search is evidence of absence only when the agent can name the **pattern** it searched, the **paths** it searched, and a **positive control** — the same tool over the same paths with a pattern known to be present, matching it, proving the search resolved.

The rule binds only where absence is the claim — a *missing* or *dropped* finding. An empty read can never be evidence *for* presence, so no other claim needs it. The control is run **before** the classification, never in place of it: an empty result whose control was never attempted is an unfinished search, not a gap. Only a control that was attempted and failed to match makes the empty result an unresolved surface — it goes in the register, not in a findings section.

## The Dispatch record

The record is kept by the per-ticket dispatchers — `/refactor` and `/done` (ADR 0006); `/retro` cites this doc for the agent-layer rules and the honesty rule's three states, and keeps no record of its own. The keeper composes the record from its intended lens list — the names the **Resolution preflight** checked: the Reviewers manifest for `/refactor`, the close-out pair for `/done` — before any result arrives, and settles each entry as its result lands (or fails to) in one of four states, and persists it in the ticket's running-retro entry rather than leaving it in chat. Emission is mandatory and detail is gap-only, mirroring `_Full._`: the clean case is one line, and a record written only when something breaks makes absence meaningless.

- **returned** — a return arrived carrying its Partial verdict register.
- **degraded** — a return arrived without the register. The presence check above assigns this state; a register-less return is never recorded as returned.
- **refused** — the lens declined or errored after dispatch.
- **unresolved** — the lens did not run because the **Resolution preflight** refused. Two causes reach this state, and a refusal settles the **whole** composed list with it: the name that failed to resolve, and every other lens, which resolved cleanly but was never dispatched because the refusal precedes all dispatch. Leaving the resolvable entries unsettled would blank most of the record in the one emission that is its only record. The record names *which* names failed to resolve — that is the actionable half, and without it the reader re-derives it by hand or hunts for a second broken name that does not exist.

Only `returned` carries no detail. The other three name the lens and what its absence cost — which question went unanswered, not merely that a slot is empty. A persisted record never pairs `returned` with `unresolved`: the preflight refuses before any lens is dispatched, so an unresolved name means nothing ran.

**Two cases have no retro entry to persist into, and in both the emission is the record.** A **refusal** — the preflight found an unresolved name — ends the close or pass before its retro step, so the refusal message carries the record. And a `/refactor` pass scoped to no ticket (its general ad-hoc arm) has no per-ticket entry at all, so the record is emitted to the user and stated as unpersisted. Neither is the leave-it-in-chat failure this rule forbids: that failure is a *completed* dispatch whose record was never written down. Emission stays mandatory in every case; persistence binds wherever a ticket entry exists to receive it.

The record is an **attestation, not a verification**. Nothing downstream can audit it: a successful dispatch's return carries no agent identity, and the subagent cannot self-identify — detection of a degraded dispatch is available only *before* dispatch, never reconstructible after it. The record's weight therefore rests on the pre-dispatch resolution check and the rule beside it, both external to any executor's self-report:

- **Resolution preflight.** Before any lens is dispatched, every named `subagent_type` is checked against the available agent types; an unresolved name refuses, naming it.
- **Anti-substitution.** A `subagent_type` that does not resolve means *that lens did not run*. It is never recovered by inlining the agent's body into a general-purpose agent — an inlined agent reproduces the output contract, so the degraded return looks on-contract, which is why the recovery is forbidden rather than detected.
- **Pinned dispatch type.** Every dispatch names its `subagent_type` explicitly. The field is optional at the tool boundary and an omitted type resolves silently to a general-purpose agent with no error and no marker — the same substitution as above, reached by omission rather than by choice. This binds the record keepers and the design explorers `/refactor` spawns — the latter pinned `general-purpose` rather than left unspecified, because carrying no coverage claim is not a licence to be silently redirected. Whether it also binds dispatchers that keep no record (`/retro`'s fact-checker invocation, `/next-ticket`'s research sub-agent) is **open**: ADR 0006's Decision scopes the dispatch layer to the two keepers, while its Consequences state the hazard generally.

## Anti-patterns

- **Enumerated coverage.** Per-area "checked, clean" lines are the rejected form — the register lists gaps, never inventory.
- **Treating an empty read as a clean read.** The two are distinguishable only by the positive control.
- **Treating the register as optional.** Silence was the rejected arm; no register means off-contract, not clean.
- **A register behind a halt instruction.** Unreachable precisely when a gap exists.
- **A gap promoted twice.** A surface is never reported as both a register entry and a *finding*; a finding's caveat referencing a registered surface is the same gap in two roles, not a double report.
- **Recovering an unresolved lens by inlining.** The lens did not run; producing its output shape anyway manufactures evidence of a review that never happened.
- **A dispatch record written only on failure.** If the clean case writes nothing, absence carries no meaning.
