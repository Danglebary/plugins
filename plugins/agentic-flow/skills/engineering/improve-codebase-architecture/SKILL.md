---
name: improve-codebase-architecture
description: Find deepening opportunities post-/done by dispatching reviewer agents listed in docs/reviewers.md against the just-closed ticket's diff. Merges results through the deepening framework, presents candidates, drops into a grilling loop on accepted ones. Refactor changes get captured in the ticket's ## Deviations with (refactor) marker. Use after /done for a per-ticket refactor pass.
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

In the agentic-flow workflow, this skill runs **per ticket** after `/done`, before the next ticket starts. Architectural rot accumulates ticket-by-ticket; catching it while context is fresh beats end-of-PRD reckoning.

## State contract

- **PRD state required**: `open` (typical, post-`/done`)
- **Ticket state required**: `done` (typical: just-closed ticket whose diff is the review target)
- **Transition**: none (may create ADRs inline; appends `(refactor)` entries to ticket's `## Deviations`)

May also run ad-hoc at any PRD/ticket state for general architecture review, but the per-ticket pattern is the typical use.

## Glossary

Use these terms exactly in every suggestion. Consistent language is the point — don't drift into "component," "service," "API," or "boundary." Full definitions in [LANGUAGE.md](LANGUAGE.md).

- **Module** — anything with an interface and an implementation (function, class, package, slice).
- **Interface** — everything a caller must know to use the module: types, invariants, error modes, ordering, config. Not just the type signature.
- **Implementation** — the code inside.
- **Depth** — leverage at the interface: a lot of behaviour behind a small interface. **Deep** = high leverage. **Shallow** = interface nearly as complex as the implementation.
- **Seam** — where an interface lives; a place behaviour can be altered without editing in place. (Use this, not "boundary.")
- **Adapter** — a concrete thing satisfying an interface at a seam.
- **Leverage** — what callers get from depth.
- **Locality** — what maintainers get from depth: change, bugs, knowledge concentrated in one place.

Key principles (see [LANGUAGE.md](LANGUAGE.md) for the full list):

- **Deletion test**: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

This skill is _informed_ by the project's domain model. The domain language gives names to good seams; ADRs record decisions the skill should not re-litigate.

## Process

1. **Read `CONTEXT.md` and any ADRs in the area you're touching.** Domain naming should come from `CONTEXT.md`; ADRs constrain what's already settled.

2. **Read `docs/reviewers.md`.** Each entry is a namespaced agent name (e.g. `agentic-flow:qa-engineer` for plugin-shipped, bare names for repo-specific in `.claude/agents/`). **Verify each name resolves.** If any listed agent isn't registered, refuse with a clear list of missing names. Silent skipping is the trap to avoid (incomplete review presented as complete). Format references: [REVIEWERS-FORMAT.md](../../_shared/REVIEWERS-FORMAT.md), [AGENT-FORMAT.md](../../_shared/AGENT-FORMAT.md).

3. **Determine the diff range.** Default: the just-closed ticket's branch diff vs its parent (PRD branch in `serial` mode, previous ticket's branch in `stacked` mode per `docs/agentic-flow.toml`). Ad-hoc invocation: ask the user for the scope (specific files, full repo walk, etc.).

4. **Dispatch each reviewer in parallel** via the Agent tool, passing the diff (or scope) and a short steering prompt: *"Review the following changes through your area of expertise. Identify deepening opportunities or architectural concerns per your lens. Output structured findings with file/line citations."*

5. **Merge findings through the deepening framework.** Classify each candidate by whether it represents a shallow module, leaky seam, missing locality, or untestable interface. Apply the **deletion test** to anything you suspect is shallow — would deleting it concentrate complexity, or just move it? "Concentrates" is the signal you want.

   If `docs/reviewers.md` is missing or empty, fall back to a generic exploration looking for the same kinds of friction:
   - Where does understanding one concept require bouncing between many small modules?
   - Where are modules **shallow** — interface nearly as complex as the implementation?
   - Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
   - Where do tightly-coupled modules leak across their seams?
   - Which parts of the codebase are untested, or hard to test through their current interface?

6. **Present candidates** as a numbered list. For each:
   - **Files** — which files/modules are involved
   - **Problem** — why the current architecture is causing friction (cite which reviewer surfaced it, when applicable)
   - **Solution** — plain English description of what would change
   - **Benefits** — explained in terms of locality and leverage, and how tests would improve

   **Use CONTEXT.md vocabulary for the domain, and [LANGUAGE.md](LANGUAGE.md) vocabulary for the architecture.** If `CONTEXT.md` defines "Order," talk about "the Order intake module" — not "the FooBarHandler," and not "the Order service."

   **ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant revisiting the ADR. Mark it clearly (e.g. _"contradicts ADR-0007 — but worth reopening because…"_). Don't list every theoretical refactor an ADR forbids.

   If no candidates surface, report that and offer to skip. A no-op refactor pass is a valid outcome.

   Do NOT propose interfaces yet. Ask the user: *"Which of these would you like to explore?"*

7. **Grilling loop.** Once the user picks a candidate, walk the design tree with them — constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive. Side effects happen inline as decisions crystallize:
   - **Naming a deepened module after a concept not in `CONTEXT.md`?** Add the term to `CONTEXT.md` — same discipline as `/grill-me` (see [CONTEXT-FORMAT.md](../../_shared/CONTEXT-FORMAT.md)). Create the file lazily if it doesn't exist.
   - **Sharpening a fuzzy term during the conversation?** Update `CONTEXT.md` right there.
   - **User rejects the candidate with a load-bearing reason?** Offer an ADR, framed as: _"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"_ Only offer when the reason would actually be needed by a future explorer to avoid re-suggesting the same thing — skip ephemeral reasons ("not worth it right now") and self-evident ones. See [ADR-FORMAT.md](../../_shared/ADR-FORMAT.md).
   - **Need to classify dependencies before deepening?** See [DEEPENING.md](DEEPENING.md) for the four dependency categories.
   - **Want to explore alternative interfaces for the deepened module?** See [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md) for the parallel sub-agent pattern.

8. **Capture refactor work.** When refactor changes land (commits to the ticket branch), append to the just-closed ticket's `## Deviations` section with a `(refactor)` prefix:

   ```markdown
   - (refactor) <one-line description of what was deepened/extracted/consolidated and the locality benefit>
   ```

   This is the bridge to `/retro` synthesis — `(refactor)`-marked entries across all tickets aggregate into the retro's optional `## Refactor` section.

## Anti-patterns

- **Don't run before `/done`.** The fact-check + deviation capture sequence depends on the ticket being in a "done" state. Running mid-implementation conflates feature changes with refactor changes.
- **Don't propose more than 3-5 candidates per ticket.** A ticket-scoped refactor pass shouldn't be a full audit. If reviewers surface many candidates, narrow to the highest-leverage ones tied to the ticket's diff.
- **Don't let reviewers' raw output through unfiltered.** Adversarially review their candidates against the deepening framework — drop noise, surface signal.
- **Don't skip the `(refactor)` marker on deviations.** That marker is what makes retro synthesis work.
- **Don't run reviewer dispatch silently if `docs/reviewers.md` lists agents that don't exist.** Fail loudly with a clear list.
