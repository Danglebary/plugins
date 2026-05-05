# ADR format

An ADR (Architectural Decision Record) captures a cross-PRD durable decision. Lives at `docs/adr/<NNNN>-<slug>.md`.

ADRs are rare by design. Created inline by `/grill-me` (and by `/improve-codebase-architecture`'s grilling loop, when a load-bearing reason emerges for rejecting a refactor candidate) only when **all three gates** of the three-gate test pass.

## Three-gate test

A decision warrants an ADR if and only if all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful.
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons.

If any of the three is missing, the decision belongs in the PRD's Approach section (PRD-local), or nowhere at all.

## File path

`docs/adr/<NNNN>-<slug>.md`

`<NNNN>` is repo-global, four-digit zero-padded, chronological. `<slug>` is kebab-case.

## Frontmatter

```yaml
---
status: accepted | superseded
---
```

ADRs are written `accepted`. The only other state is `superseded`, applied when a later ADR replaces this one (and references the superseding ADR by ID in the body).

## Body sections

### 1. Context

The situation that called for this decision. Two-three paragraphs. Anchor in concrete constraints — what was true about the codebase, the team, the technology, or the goals at the time.

### 2. Decision

The decision itself, in declarative form. One sentence to one paragraph. State *what* was chosen, not *why*.

### 3. Consequences

What follows from this decision. Both intended and trade-off consequences. What gets easier, what gets harder, what remains uncertain.

### 4. Alternatives considered

The genuine alternatives that were on the table and why they were rejected. This is what makes an ADR an ADR rather than a fiat declaration.

## Example

```markdown
---
status: accepted
---

# 0001 — Postgres for the write model

## Context

We need durable storage for user data and session state. The team is small (one engineer + AI agents); operational simplicity matters more than scale headroom. We will not exceed 10k QPS in any reasonable horizon.

## Decision

Use a single Postgres instance as the write model for all persistent state.

## Consequences

- Schema migrations are first-class; we adopt a migration tool from the start.
- Cross-entity transactions are trivial; no distributed-systems reasoning needed for the foreseeable future.
- A single instance is a single point of failure; backup discipline is required from day one.
- Read scaling will require replicas if we exceed write-instance capacity, but that is years away.

## Alternatives considered

- **SQLite** — rejected because of multi-process write contention and no managed-hosting story for prod.
- **DynamoDB** — rejected because schema flexibility costs more than it gives us at our scale, and cross-entity transactions become awkward.
- **Postgres + Redis** — deferred. Postgres alone is sufficient until session-lookup load justifies a cache tier.
```

## Anti-patterns

- **Don't write ADRs for reversible decisions.** A decision you can change cheaply doesn't need a record — change it when wrong.
- **Don't write ADRs for obvious decisions.** "We use TypeScript" doesn't need an ADR if no one would ask "why TypeScript?"
- **Don't skip the Alternatives section.** Without alternatives, the ADR is a declaration, not a decision.
- **Don't edit accepted ADRs.** Supersede them — write a new ADR that references the old one and flip the old one's status to `superseded`.
