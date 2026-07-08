---
name: improve-codebase-architecture
description: "Find deepening opportunities post-/done by dispatching reviewer agents listed in the Reviewers manifest against the just-closed ticket's diff. Merges results through the deepening framework, presents candidates, drops into a grilling loop on accepted ones. Refactor changes get captured in the ticket's ## Deviations with (refactor) marker. Use after /done for a per-ticket refactor pass."
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability. The code and its diff stay in git; the Reviewers manifest, Glossary, ADRs, and ticket deviations live in the store.

In the agentic-flow workflow, this skill runs **per ticket** after `/done`, before the next ticket starts. Architectural rot accumulates ticket-by-ticket; catching it while context is fresh beats end-of-PRD reckoning.

Resolve the store first — see [STORE.md](../../_shared/STORE.md).

## State contract

- **PRD state required**: `Open` (typical, post-`/done`)
- **Ticket state required**: `Done` (typical: just-closed ticket whose diff is the review target)
- **Transition**: none (may create ADRs inline; appends `(refactor)` entries to ticket's `## Deviations`)

May also run ad-hoc at any PRD/ticket state for general architecture review, but the per-ticket pattern is the typical use.

## Glossary

Use the vocabulary in [LANGUAGE.md](LANGUAGE.md) — module, interface, implementation, depth, seam, adapter, leverage, locality. Don't drift to "component," "service," "API," or "boundary."

Three principles you'll apply repeatedly:

- **Deletion test**: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

This skill is _informed_ by the project's domain model. The domain language gives names to good seams; ADRs record decisions the skill should not re-litigate.

## Process

1. **Read the Glossary and any ADRs in the area you're touching.** Domain naming should come from the Glossary; ADRs constrain what's already settled.

2. **Read the Reviewers manifest.** Each entry is a namespaced agent name (e.g. `agentic-flow:qa-engineer` for plugin-shipped, bare names for repo-specific in `.claude/agents/`). **Verify each name resolves.** If any listed agent isn't registered, refuse with a clear list of missing names. Silent skipping is the trap to avoid (incomplete review presented as complete). Format references: [REVIEWERS-FORMAT.md](../../_shared/REVIEWERS-FORMAT.md), [AGENT-FORMAT.md](../../_shared/AGENT-FORMAT.md).

3. **Determine the diff range.** *(Git.)* Default: the just-closed ticket's branch diff vs its parent (PRD branch in `serial` mode, previous ticket's branch in `stacked` mode per the config). Ad-hoc invocation: ask the user for the scope (specific files, full repo walk, etc.).

4. **Dispatch each reviewer in parallel** via the Agent tool. Reviewer agents have no store access — `Read/Grep/Glob` over the working tree only — so the brief must carry every planning input they need: resolve each from the store (step 1) and inline it. Every reviewer brief contains:
   - The diff (or scope) and the steering prompt: *"Review the following changes through your area of expertise. Identify deepening opportunities or architectural concerns per your lens. Output structured findings with file/line citations."*
   - **The closed ticket's `## Goal` and `## Acceptance criteria`** — the contract the change was meant to satisfy (the qa lens tests against it).
   - **The closed ticket's `## Deviations`** — already-settled divergences are not findings.
   - **The Glossary's domain vocabulary** (terms + one-line definitions) — so findings name concepts in the project's language, not generic placeholders like "the OrderHandler."
   - **Settled ADR titles + their one-line decision**, marked *"do not re-litigate"*.
   - **The PRD's open-ticket list** — work already scheduled is not a finding.
   - **Deferred candidates from previous passes** (see step 7) — already deferred is not a new finding.
   - Two output requirements: *"verify any severity-determining claim about an external system (stdlib, build APIs, language semantics) against the installed toolchain before asserting it"*, and *"for each area of your lens you examined and found clean, say 'checked, clean' — silence is indistinguishable from not-looked."*

5. **Merge findings through the deepening framework.** Classify each candidate by whether it represents a shallow module, leaky seam, missing locality, or untestable interface. Apply the **deletion test** to anything you suspect is shallow — would deleting it concentrate complexity, or just move it? "Concentrates" is the signal you want.

   Two merge-layer contracts:
   - **Adversarially verify reviewer factual claims against source before relaying them.** Reviewers argue from the diff and their own priors; a finding built on a false premise must die here, not in front of the user.
   - **Convergence count is a ranking input.** Independent reviewers converging on the same finding is a severity oracle — surface convergence explicitly ("4 of 5 reviewers flagged this").

   If the Reviewers manifest is missing or empty, fall back to a generic exploration looking for the same kinds of friction:
   - Where does understanding one concept require bouncing between many small modules?
   - Where are modules **shallow** — interface nearly as complex as the implementation?
   - Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
   - Where do tightly-coupled modules leak across their seams?
   - Which parts of the codebase are untested, or hard to test through their current interface?

6. **Present candidates** as a numbered list. **Candidate inclusion and deviation recording are two different bars — don't conflate them.** The seam-level threshold in [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md) gates what gets *documented* in `## Deviations` (step 8); it does **not** gate what gets *proposed or fixed*. Cheap below-seam cleanups a reviewer surfaced — a sharpened test, a clearer helper, a deduplicated block — are valid candidates; include them (grouped as minor cleanups, distinct from the deepening candidates). For each candidate:
   - **Files** — which files/modules are involved
   - **Problem** — why the current architecture is causing friction (cite which reviewer surfaced it, and the convergence count when more than one did)
   - **Solution** — plain English description of what would change, argued from the repo's recorded design philosophy (CLAUDE.md weighting, ADRs) — not from generic churn or diff-size caution. State whether it derives from first principles or precedent, and mark load-bearing constraints as user-stated vs assumed.
   - **Benefits** — explained in terms of locality and leverage, and how tests would improve

   **Use Glossary vocabulary for the domain, and [LANGUAGE.md](LANGUAGE.md) vocabulary for the architecture.** If the Glossary defines "Order," talk about "the Order intake module" — not "the FooBarHandler," and not "the Order service."

   **ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant revisiting the ADR. Mark it clearly (e.g. _"contradicts ADR-0007 — but worth reopening because…"_). Don't list every theoretical refactor an ADR forbids.

   If no candidates surface, report that and offer to skip. A no-op refactor pass is a valid outcome.

   Do NOT propose interfaces yet. Ask the user: *"Which of these would you like to explore?"*

7. **Grilling loop.** Once the user picks a candidate, walk the design tree with them — constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive. Side effects happen inline as decisions crystallize:
   - **User defers a candidate to a named future ticket?** Append it to that ticket's `## Implementation notes` (or a `### Deferred steers` subsection there) immediately. A deferral that lives only in chat evaporates at the session boundary — reviewers re-proposed exactly such items in past runs.
   - **Naming a deepened module after a concept not in the Glossary?** Add the term to the Glossary — same discipline as `/grill-me` (see [CONTEXT-FORMAT.md](../../_shared/CONTEXT-FORMAT.md)).
   - **Sharpening a fuzzy term during the conversation?** Update the Glossary right there.
   - **User rejects the candidate with a load-bearing reason?** Offer an ADR, framed as: _"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"_ Only offer when the reason would actually be needed by a future explorer to avoid re-suggesting the same thing — skip ephemeral reasons ("not worth it right now") and self-evident ones. See [ADR-FORMAT.md](../../_shared/ADR-FORMAT.md).
   - **Need to classify dependencies before deepening?** See [DEEPENING.md](DEEPENING.md) for the four dependency categories.
   - **Want to explore alternative interfaces for the deepened module?** See [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md) for the parallel sub-agent pattern.

8. **Capture refactor work.** When refactor changes land (commits to the ticket branch), append to the just-closed ticket's `## Deviations` section with a `(refactor)` prefix:

   ```markdown
   - (refactor) <one-line description of what was deepened/extracted/consolidated and the locality benefit>
   ```

   Threshold same as any deviation — only seam-level moves get captured (see [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md)). If the refactor pass produced no seam-level moves (e.g. all candidates were rejected, or the work was purely internal cleanup), append nothing — that's the correct outcome. (This is the *recording* bar, not the *inclusion* bar of step 6 — below-seam cleanups were worth doing; they just don't get an entry.)

9. **End state — pinned.** The pass ends with refactor commits on the **ticket branch**, the merge **offered, not performed** (the same gated offer as `/done`; the merge is the user's control point), and an **end-of-pass ADR check**: did any accepted refactor embody a choice that passes the three-gate test and isn't recorded? Offer it.

   **Ratification questions block.** If the pass surfaced a question the user must answer — a new caller-facing contract, a changed public default, a widened public surface — and the answer hasn't come, the work does not merge and the contract does not ship. End the turn and wait. An unanswered question is a "no", not a "proceed". (This pass once self-merged an unratified caller-facing contract; that is the failure this rule exists to prevent.)

## Anti-patterns

- **Don't run before `/done`.** The fact-check + deviation capture sequence depends on the ticket being in a "done" state. Running mid-implementation conflates feature changes with refactor changes.
- **Don't propose more than 3-5 candidates per ticket.** A ticket-scoped refactor pass shouldn't be a full audit. If reviewers surface many candidates, narrow to the highest-leverage ones tied to the ticket's diff.
- **Don't let reviewers' raw output through unfiltered.** Adversarially review their candidates against the deepening framework — drop noise, surface signal.
- **Don't skip the `(refactor)` marker on deviations.** That marker is what makes retro synthesis work.
- **Don't capture below-threshold cleanups as `(refactor)` entries.** Internal renames, control-flow tidy-up, dedup that doesn't cross a module boundary — none of that belongs in `## Deviations`. The threshold is the seam, not the line. If the refactor pass produced no seam-level moves, append nothing.
- **Don't run reviewer dispatch silently if the Reviewers manifest lists agents that don't exist.** Fail loudly with a clear list.
- **Don't filter candidates by the deviation-recording threshold.** Dropping a worthwhile cheap cleanup because it "wouldn't be a recordable deviation" conflates the two bars — inclusion is about worth, recording is about seams.
- **Don't merge the pass's work yourself.** Offer the merge; the user owns it. And never ship a contract the user was asked about but didn't answer.
