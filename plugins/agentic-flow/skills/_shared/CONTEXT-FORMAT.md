# CONTEXT.md format

`CONTEXT.md` is a living glossary of domain terms used in the codebase. It lives at the repo root (single-context repos) or per-context per `CONTEXT-MAP.md` (multi-context repos).

It is updated inline by `/grill-me` (and any other skill where a term gets sharpened). It does not represent a snapshot in time — it is the *current* canonical vocabulary.

## File path

`CONTEXT.md` at repo root.

For multi-context repos, see `CONTEXT-MAP.md` at the root pointing to per-context `CONTEXT.md` files.

## Structure

A header, a `## Language` section with term definitions, a `## Relationships` section, and an optional `## Flagged ambiguities` section recording resolved ambiguities.

### Header

A one-paragraph project summary, anchored in the **Language** terms below. Sets context for any agent loading the file.

### `## Language`

Each term is a definition block:

```markdown
**Term name**:
One-paragraph definition, anchored in concrete distinctions from related terms.
_Avoid_: list of synonyms or near-terms not to use, with brief reason if non-obvious.
```

The `_Avoid_` line is critical — it tells agents what *not* to say, preventing drift back to fuzzy language.

Terms should be capitalized when referenced from other definitions (signaling "this is a defined term"), e.g. "an **Order** is held by a **Customer**".

### `## Relationships`

Bullet list of how terms relate. One relationship per bullet.

```markdown
- A **PRD** contains many **Tickets**
- A **PRD** is paired with one **Retro**
```

### `## Flagged ambiguities`

Records of ambiguities the team encountered and how they were resolved. Helps future-you avoid re-litigating the same naming arguments.

```markdown
- "issue" was overloaded with GitHub Issues — collapsed into **Ticket**.
```

## Worked example

See `agentic-flow`'s own `CONTEXT.md` at the repo root.

## What does NOT belong in CONTEXT.md

- **Implementation details.** "The User table has an `email` column." — that's code; CONTEXT.md is about domain language.
- **Decisions.** Decisions go to ADRs (cross-PRD) or PRD Approach sections (PRD-local).
- **Process documentation.** "We do code reviews on Tuesdays." — that's CLAUDE.md territory.
- **Anything that would only be meaningful to a developer, not a domain expert.** CONTEXT.md is the shared vocabulary between humans and agents about *what the system models*, not *how it's built*.

## Anti-patterns

- **Don't define every term.** Only terms that are domain-meaningful and have been the source of confusion. A defined term is a commitment.
- **Don't bulk-add terms upfront.** Add lazily — when grilling sharpens a term, add it then. Bulk adds get stale because they're not anchored in real ambiguity.
- **Don't update silently.** When a term changes meaningfully, mention it in the next retro's `## Cross-cutting` so the change is traceable.
