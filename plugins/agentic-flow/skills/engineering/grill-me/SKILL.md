---
name: grill-me
description: Interview the user relentlessly about a plan or design until shared understanding is reached, resolving each branch of the decision tree. Updates the Glossary inline as terms sharpen and offers ADRs when decisions are durable. Use when user wants to stress-test a plan, refine a draft spec, or says "grill me".
---

# Grill me

Interview the user relentlessly about every aspect of the current plan until you reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer with reasoning.

Ask **one question at a time**. Wait for the user's response before continuing.

If a question can be answered by exploring the codebase, explore the codebase instead of asking.

> **Protected behaviors — do not weaken in any rewrite of this skill.** Code-grounding (explore instead of asking; cross-reference user claims against code) and the per-question recommendation are this skill's two demonstrably load-bearing mechanics — each has overturned a spec's central premise before tickets were cut. Any future edit to this file keeps both mandatory. These behaviors are store-independent — code stays in git and grilling is grounded against it.

Store artifact paths: [STORE.md](../../_shared/STORE.md).

## Recommendation discipline

Every recommendation you present carries three marks:

1. **Derivation** — state whether it derives from first principles for *this* problem, or from precedent/diff-minimization. "Smallest change" and "least churn" are not arguments on their own; argue from the repo's recorded design philosophy (its CLAUDE.md weighting, ADRs), not generic caution. If your first instinct was the lowest-lift option, say so and check it against the long-term shape before presenting.
2. **Constraint provenance** — mark each load-bearing constraint as **user-stated** or **assumed**. An assumed constraint silently narrowing the design space is how non-goals get smuggled in; surfacing it lets the user strike it.
3. **Counterargument** — present the strongest case *against* your recommendation, not just for it. The recommendation-plus-counterargument shape is what lets the user's pushback land productively; without it, grilling degrades into ratification.

## State contract

- **Spec state required**: `Drafting` (when operating on a spec); refuses on `Open` and `Done` specs
- **Ticket state required**: n/a
- **Transition**: none

When invoked outside any spec context (e.g. generic design conversation with no spec involved), state-gating doesn't apply.

## Two stages in the agentic-flow workflow

- **High-level**: after `/next-spec`, before `/to-spec`. Sharpen *what we're trying to do* and the broad approach.
- **Detail**: after `/to-spec` writes a draft spec. Sharpen the specifics — non-goals, approach trade-offs, modules.

The skill behaves the same way in both stages — only the depth of questioning changes.

## Domain awareness

Look for existing documentation during grilling: the **Glossary** (the living domain vocabulary) and the **ADRs** (cross-spec durable decisions) — both live in the store.

Create artifacts lazily — only when you have something to write: if `CONTEXT.md` doesn't exist, create it when the first term is resolved; if `docs/adr/` doesn't exist, create it when the first ADR is needed.

Format references: [CONTEXT-FORMAT.md](../../_shared/CONTEXT-FORMAT.md), [ADR-FORMAT.md](../../_shared/ADR-FORMAT.md).

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the Glossary, call it out immediately. *"Your glossary defines `Cancellation` as X, but you seem to mean Y — which is it?"*

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. *"You're saying 'account' — do you mean the **Customer** or the **User**? Those are different things."*

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: *"Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"*

### Update the Glossary inline

When a term is resolved, update the Glossary right there. Don't batch these up — capture them as they happen. Use the format in [CONTEXT-FORMAT.md](../../_shared/CONTEXT-FORMAT.md).

Don't couple the Glossary to implementation details. Only include terms that are meaningful to domain experts.

### Offer ADRs sparingly — three-gate test

Only offer an ADR when all three gates pass (hard to reverse, surprising without context, real trade-off) — see [ADR-FORMAT.md](../../_shared/ADR-FORMAT.md). If any gate is missing, the decision lives in the spec's Approach section instead.

**Toolchain-fact gate:** before freezing an ADR, verify every load-bearing claim about an external system against the installed toolchain — the gate's verification recipe and the incident behind it live in [ADR-FORMAT.md](../../_shared/ADR-FORMAT.md)'s "Toolchain-fact gate" section. Mint ADRs inline as decisions land — don't defer them to end-of-grill.

### End-of-grill self-check

Before declaring the grill complete, run and report a self-check:

- **Deferred ADRs?** Any decision that passed the three gates but wasn't minted inline — mint it now.
- **Invalidated early answers?** Any early-grill resolution contradicted or made stale by a later answer — surface it and re-resolve rather than leaving the record inconsistent.
- **Unverified toolchain facts?** Any external-system claim that slipped into a decision without the verification above.

## Refusing to run

If grilling is being requested for a `Done` spec, refuse and suggest a new spec instead. The spec is a closed chapter; re-litigation goes through a fresh spec.

## Anti-patterns

- **Don't ask more than one question at a time.** Multi-question prompts collapse the decision tree — the user can't engage with each branch on its own merit.
- **Don't accept the first answer if it doesn't actually resolve the branch.** Probe further when the answer is hedged, vague, or sidesteps the question. The point is to reach shared understanding, not check off questions.
- **Don't propose ADRs that fail any of the three gates.** Easy-to-reverse, unsurprising, or no-real-trade-off decisions belong in the spec's `## Approach` section, not in the ADRs.
- **Don't write implementation details into the Glossary.** Only domain-meaningful terms belong there. If a term is only useful to people reading the code, it doesn't go in the glossary.
- **Don't batch Glossary updates until end-of-session.** Capture each term as it resolves — batching loses precision and risks losing entries entirely.
- **Don't grill in a vacuum.** Read the Glossary and existing ADRs before starting; cross-reference against actual code when the user makes claims about how it works.
