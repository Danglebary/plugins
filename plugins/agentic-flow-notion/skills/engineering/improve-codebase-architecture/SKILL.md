---
name: improve-codebase-architecture
description: Find deepening opportunities post-/done by dispatching reviewer agents listed in the Notion Reviewers database against the just-closed ticket's git diff. Merges results through the deepening framework, presents candidates, drops into a grilling loop on accepted ones. Refactor changes get captured in the ticket row's ## Deviations with a (refactor) marker. Use after /done for a per-ticket refactor pass.
---

# Improve Codebase Architecture (Notion)

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability. The code and its diff stay in git; the reviewer manifest, glossary, ADRs, and ticket deviations live in Notion.

Runs **per ticket** after `/done`, before the next ticket starts. Architectural rot accumulates ticket-by-ticket; catching it while context is fresh beats end-of-PRD reckoning.

Resolve databases first — see [NOTION-RESOLVER.md](../../_shared/NOTION-RESOLVER.md).

## State contract

- **PRD state required**: `Status = Open` (typical, post-`/done`)
- **Ticket state required**: `Done` (typical: just-closed ticket whose diff is the review target)
- **Transition**: none (may create ADR rows inline; appends `(refactor)` entries to the ticket row's `## Deviations`)

May also run ad-hoc at any state for general architecture review, but the per-ticket pattern is typical.

## Glossary

Use the vocabulary in [LANGUAGE.md](LANGUAGE.md) — module, interface, implementation, depth, seam, adapter, leverage, locality. Don't drift to "component," "service," "API," or "boundary."

Three principles you'll apply repeatedly:

- **Deletion test**: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it earned its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

This skill is *informed* by the project's domain model. The Glossary database gives names to good seams; ADR rows record decisions the skill should not re-litigate.

## Process

1. **Read the Glossary database and any ADR rows in the area you're touching.** Domain naming comes from the Glossary; ADRs constrain what's already settled.

2. **Read the Reviewers database.** Each row's `Agent` is a namespaced agent name (e.g. `agentic-flow:qa-engineer` for plugin-shipped, bare names for repo-specific in `.claude/agents/`). **Verify each name resolves.** If any listed agent isn't registered, refuse with a clear list of missing names — silent skipping is the trap (incomplete review presented as complete). Agent file format: [AGENT-FORMAT.md](../../_shared/AGENT-FORMAT.md).

3. **Determine the diff range.** *(Git.)* Default: the just-closed ticket's branch diff vs its parent (PRD branch in `serial`, previous ticket's branch in `stacked`, per the root page body config). Ad-hoc: ask the user for scope.

4. **Dispatch each reviewer in parallel** via the Agent tool. Every brief contains:
   - The diff (or scope) and the steering prompt: *"Review the following changes through your area of expertise. Identify deepening opportunities or architectural concerns per your lens. Output structured findings with file/line citations."*
   - **The closed ticket row's `## Deviations`** — already-settled divergences are not findings.
   - **Settled ADR titles** (from the ADRs database), marked *"do not re-litigate."*
   - **The PRD's open-ticket list** (query the Tickets database) — scheduled work is not a finding.
   - **Deferred candidates from previous passes** — already deferred is not a new finding.
   - Two output requirements: *"verify any severity-determining claim about an external system against the installed toolchain before asserting it"*, and *"for each area of your lens you examined and found clean, say 'checked, clean' — silence is indistinguishable from not-looked."*

5. **Merge findings through the deepening framework.** Classify each candidate (shallow module, leaky seam, missing locality, untestable interface). Apply the **deletion test** to suspected-shallow modules — would deleting it concentrate complexity, or just move it? "Concentrates" is the signal.
   - **Adversarially verify reviewer factual claims against source before relaying them.** A finding built on a false premise dies here, not in front of the user.
   - **Convergence count is a ranking input.** Surface it explicitly ("4 of 5 reviewers flagged this").

   If the Reviewers database is empty, fall back to generic exploration for the same friction: where understanding one concept requires bouncing between many small modules; shallow modules; pure functions extracted for testability while real bugs hide in how they're called; tightly-coupled modules leaking across seams; untested or hard-to-test-through-their-interface code.

6. **Present candidates** as a numbered list. **Candidate inclusion and deviation recording are two different bars — don't conflate them.** The seam-level threshold in [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md) gates what gets *documented* in `## Deviations` (step 8); it does **not** gate what gets *proposed or fixed*. Cheap below-seam cleanups are valid candidates; include them (grouped as minor cleanups, distinct from deepening candidates). For each:
   - **Files** — which files/modules
   - **Problem** — why the current architecture causes friction (cite the reviewer, and convergence count when more than one)
   - **Solution** — plain-English change, argued from the repo's recorded design philosophy (CLAUDE.md weighting, ADRs), not generic churn caution. State whether it derives from first principles or precedent; mark load-bearing constraints user-stated vs assumed.
   - **Benefits** — in terms of locality and leverage, and how tests improve

   **Use Glossary vocabulary for the domain, [LANGUAGE.md](LANGUAGE.md) for the architecture.** If the Glossary defines "Order," say "the Order intake module" — not "the FooBarHandler," not "the Order service."

   **ADR conflicts**: if a candidate contradicts an ADR row, surface it only when the friction warrants revisiting the ADR, marked clearly (*"contradicts ADR *Cache-on-write* — but worth reopening because…"*). Don't list every theoretical refactor an ADR forbids.

   If no candidates surface, report that and offer to skip. A no-op pass is valid. Do NOT propose interfaces yet — ask: *"Which of these would you like to explore?"*

7. **Grilling loop.** Once the user picks a candidate, walk the design tree — constraints, dependencies, the deepened module's shape, what sits behind the seam, what tests survive. Side effects inline as decisions crystallize:
   - **Defers a candidate to a named future ticket?** Append it to that ticket row's `## Implementation notes` (or a `### Deferred steers` subsection) immediately via `update-page`. A deferral living only in chat evaporates at the session boundary.
   - **Naming a deepened module after a concept not in the Glossary?** Add the term to the Glossary database — same discipline as `/grill-me`.
   - **Sharpening a fuzzy term?** Update the Glossary row right there.
   - **Rejects the candidate with a load-bearing reason?** Offer an ADR row, framed as: *"Want me to record this as an ADR so future reviews don't re-suggest it?"* Only when the reason would actually be needed by a future explorer. See [ADR-FORMAT.md](../../_shared/ADR-FORMAT.md).
   - **Classify dependencies before deepening?** See [DEEPENING.md](DEEPENING.md).
   - **Explore alternative interfaces?** See [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md).

8. **Capture refactor work.** When refactor changes land (commits to the ticket branch), append to the just-closed ticket row's `## Deviations` (via `update-page`) with a `(refactor)` prefix:

   ```markdown
   - (refactor) <one-line description of what was deepened/extracted/consolidated and the locality benefit>
   ```

   Threshold same as any deviation — only seam-level moves get captured. If the pass produced no seam-level moves, append nothing — that's correct. (This is the *recording* bar, not the *inclusion* bar of step 6.)

9. **End state — pinned.** The pass ends with refactor commits on the **ticket branch**, the merge **offered, not performed** (same gated offer as `/done`), and an **end-of-pass ADR check**: did any accepted refactor embody a three-gate-passing choice that isn't recorded? Offer it.

   **Ratification questions block.** If the pass surfaced a question the user must answer — a new caller-facing contract, a changed public default, a widened public surface — and the answer hasn't come, the work does not merge and the contract does not ship. End the turn and wait. An unanswered question is a "no." (This pass once self-merged an unratified caller-facing contract; that is the failure this rule prevents.)

## Anti-patterns

- **Don't run before `/done`.** The fact-check + deviation capture sequence depends on the ticket being `Done`.
- **Don't propose more than 3-5 candidates per ticket.** Narrow to the highest-leverage ones tied to the ticket's diff.
- **Don't let reviewers' raw output through unfiltered.** Adversarially review against the deepening framework.
- **Don't skip the `(refactor)` marker on deviations.** That marker is what makes retro synthesis work.
- **Don't capture below-threshold cleanups as `(refactor)` entries.** The threshold is the seam, not the line.
- **Don't run reviewer dispatch silently if the Reviewers database lists agents that don't exist.** Fail loudly with a clear list.
- **Don't filter candidates by the deviation-recording threshold.** Inclusion is about worth, recording is about seams.
- **Don't merge the pass's work yourself.** Offer the merge; the user owns it. Never ship a contract the user was asked about but didn't answer.
