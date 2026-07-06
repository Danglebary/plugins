---
name: grill-me
description: Interview the user relentlessly about a plan or design until shared understanding is reached, resolving each branch of the decision tree. Updates the Notion Glossary inline as terms sharpen and offers ADRs when decisions are durable. Use when the user wants to stress-test a plan, refine a draft PRD, or says grill me.
---

# Grill me (Notion)

Interview the user relentlessly about every aspect of the current plan until you reach shared understanding. Walk down each branch of the design tree, resolving dependencies one by one. For each question, provide your recommended answer with reasoning.

Ask **one question at a time**. Wait for the response before continuing.

If a question can be answered by exploring the codebase, explore the code (in git) instead of asking.

> **Protected behaviors — do not weaken in any rewrite.** Code-grounding (explore instead of asking; cross-reference user claims against code) and the per-question recommendation are this skill's two load-bearing mechanics — each has overturned a PRD's central premise before tickets were cut. Any edit keeps both mandatory. **These do not move to Notion** — code stays in git and grilling is grounded against it.

Resolve databases first — see [NOTION-RESOLVER.md](../../_shared/NOTION-RESOLVER.md).

## Recommendation discipline

Every recommendation carries three marks:

1. **Derivation** — state whether it derives from first principles for *this* problem, or from precedent/diff-minimization. "Smallest change" is not an argument on its own; argue from the repo's recorded design philosophy (its CLAUDE.md, ADRs). If your first instinct was the lowest-lift option, say so and check it against the long-term shape.
2. **Constraint provenance** — mark each load-bearing constraint **user-stated** or **assumed**. An assumed constraint silently narrowing the design is how non-goals get smuggled in; surfacing it lets the user strike it.
3. **Counterargument** — present the strongest case *against* your recommendation. Without it, grilling degrades into ratification.

## State contract

- **PRD state required**: `Drafting` (when operating on a PRD); refuses on `Open` and `Done`
- **Ticket state required**: n/a
- **Transition**: none

When invoked outside any PRD context (generic design conversation, no PRD row involved), state-gating doesn't apply.

## Two stages

- **High-level**: after `/next-prd`, before `/to-prd`. Sharpen *what we're trying to do*.
- **Detail**: after `/to-prd` writes the draft. Sharpen non-goals, approach trade-offs, modules.

Same behavior in both — only depth changes.

## During the session

### Challenge against the Glossary
When a term conflicts with a Glossary row, call it out: *"Your glossary defines `Cancellation` as X, but you seem to mean Y — which is it?"*

### Sharpen fuzzy language
Propose a precise canonical term for vague/overloaded words: *"You say 'account' — the **Customer** or the **User**? Different things."*

### Discuss concrete scenarios
Stress-test domain relationships with specific scenarios that probe edge cases and force precision about boundaries.

### Cross-reference with code
When the user states how something works, check the code agrees. On contradiction: *"Your code cancels entire Orders, but you said partial cancellation is possible — which is right?"*

### Update the Glossary inline
When a term resolves, write it to the Glossary database right then (`create-pages`, or `update-page` to revise an existing `Term` row) — don't batch. Only domain-meaningful terms; never implementation details.

### Offer ADRs sparingly — three-gate test
Offer an ADR only when all three gates pass (hard to reverse, surprising without context, real trade-off). If any gate fails, the decision lives in the PRD's Approach section. Write accepted ADRs as rows in the ADRs database (`Status = Accepted`), minting inline as decisions land.

**Toolchain-fact gate:** before freezing an ADR, verify every load-bearing claim about an external system (stdlib behavior, build APIs, language defaults, third-party semantics) against the installed toolchain — read its source, run a probe, or dispatch a research sub-agent. "The docs say so" and "I recall" are not verification.

### End-of-grill self-check
Before declaring the grill complete, run and report:
- **Deferred ADRs?** Any decision that passed the gates but wasn't minted — mint it now (ADRs row).
- **Invalidated early answers?** Any early resolution made stale by a later answer — surface and re-resolve.
- **Unverified toolchain facts?** Any external-system claim that slipped in without verification.

## Refusing to run

If grilling is requested for a `Done` PRD, refuse and suggest a new PRD. The chapter is closed; re-litigation goes through a fresh PRD.

## Anti-patterns

- **Don't ask more than one question at a time.** Multi-question prompts collapse the decision tree.
- **Don't accept the first answer if it doesn't resolve the branch.** Probe hedged or evasive answers.
- **Don't propose ADRs that fail any gate.** Easy-to-reverse or no-trade-off decisions go in `## Approach`.
- **Don't write implementation details into the Glossary.** Domain-meaningful terms only.
- **Don't batch Glossary updates.** Capture each term as it resolves.
- **Don't grill in a vacuum.** Read the Glossary and ADRs first; cross-reference against actual code.
