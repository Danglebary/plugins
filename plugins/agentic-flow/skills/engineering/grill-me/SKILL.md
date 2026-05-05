---
name: grill-me
description: Interview the user relentlessly about a plan or design until shared understanding is reached, resolving each branch of the decision tree. Updates CONTEXT.md inline as terms sharpen and offers ADRs when decisions are durable. Use when user wants to stress-test a plan, refine a draft PRD, or says "grill me".
---

# Grill me

Interview the user relentlessly about every aspect of the current plan until you reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer with reasoning.

Ask **one question at a time**. Wait for the user's response before continuing.

If a question can be answered by exploring the codebase, explore the codebase instead of asking.

## State contract

- **PRD state required**: `drafting` (when operating on a PRD); refuses on `done` PRDs
- **Ticket state required**: n/a
- **Transition**: none

When invoked outside any PRD context (e.g. generic design conversation with no `prd.md` involved), state-gating doesn't apply.

## Two stages in the agentic-flow workflow

- **High-level**: after `/next-prd`, before `/to-prd`. Sharpen *what we're trying to do* and the broad approach.
- **Detail**: after `/to-prd` writes a draft PRD. Sharpen the specifics — non-goals, approach trade-offs, modules.

The skill behaves the same way in both stages — only the depth of questioning changes.

## Domain awareness

Look for existing documentation during grilling:

- `CONTEXT.md` at repo root — the living domain glossary.
- `docs/adr/` — cross-PRD durable decisions.

Create files lazily — only when you have something to write. If `CONTEXT.md` doesn't exist, create it when the first term is resolved. If `docs/adr/` doesn't exist, create it when the first ADR is needed.

Format references: [CONTEXT-FORMAT.md](../../_shared/CONTEXT-FORMAT.md), [ADR-FORMAT.md](../../_shared/ADR-FORMAT.md).

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with `CONTEXT.md`, call it out immediately. *"Your glossary defines `Cancellation` as X, but you seem to mean Y — which is it?"*

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. *"You're saying 'account' — do you mean the **Customer** or the **User**? Those are different things."*

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: *"Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"*

### Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` right there. Don't batch these up — capture them as they happen. Use the format in [CONTEXT-FORMAT.md](../../_shared/CONTEXT-FORMAT.md).

Don't couple `CONTEXT.md` to implementation details. Only include terms that are meaningful to domain experts.

### Offer ADRs sparingly — three-gate test

Only offer to create an ADR when **all three** gates pass:

1. **Hard to reverse** — the cost of changing your mind later is meaningful.
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons.

If any of the three is missing, skip the ADR — let the decision live in the PRD's Approach section instead. Use the format in [ADR-FORMAT.md](../../_shared/ADR-FORMAT.md).

## Refusing to run

If grilling is being requested for a `done` PRD, refuse and suggest a new PRD instead. The PRD is a closed chapter; re-litigation goes through a fresh PRD.

## Anti-patterns

- **Don't ask more than one question at a time.** Multi-question prompts collapse the decision tree — the user can't engage with each branch on its own merit.
- **Don't accept the first answer if it doesn't actually resolve the branch.** Probe further when the answer is hedged, vague, or sidesteps the question. The point is to reach shared understanding, not check off questions.
- **Don't propose ADRs that fail any of the three gates.** Easy-to-reverse, unsurprising, or no-real-trade-off decisions belong in the PRD's `## Approach` section, not in `docs/adr/`.
- **Don't write implementation details into `CONTEXT.md`.** Only domain-meaningful terms belong there. If a term is only useful to people reading the code, it doesn't go in the glossary.
- **Don't batch CONTEXT.md updates until end-of-session.** Capture each term as it resolves — batching loses precision and risks losing entries entirely.
- **Don't grill in a vacuum.** Read `CONTEXT.md` and existing ADRs before starting; cross-reference against actual code when the user makes claims about how it works.
