# ADR format (Notion)

An ADR (Architectural Decision Record) captures a cross-PRD durable decision. ADRs are **rows in the ADRs database** (see [NOTION-RESOLVER.md](./NOTION-RESOLVER.md)), not files.

ADRs are rare by design. Created inline by `/grill-me` (and by `/improve-codebase-architecture`'s grilling loop, when a load-bearing reason emerges for rejecting a refactor candidate) only when **all three gates** pass.

## Three-gate test

A decision warrants an ADR if and only if all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful.
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons.

If any gate is missing, the decision belongs in the PRD's Approach section (PRD-local), or nowhere.

## Row mapping

| Old (file) | Now (ADRs database) |
|---|---|
| `docs/adr/<NNNN>-<slug>.md` | a row in the ADRs database |
| `<NNNN>` repo-global number | the `ADR ID` (`UNIQUE_ID PREFIX 'ADR'`) |
| Title heading | the `Title` property |
| `status: accepted \| superseded` frontmatter | the `Status` select (`Proposed` / `Accepted` / `Superseded`) |
| Context / Decision / Consequences / Alternatives | the row **body**, one `##` heading each; a one-line summary may go in the `Decision` property |

ADRs are written `Accepted`. `Superseded` is applied when a later ADR replaces this one (reference the superseding ADR by title/ID in the body).

## Body sections

1. **Context** — the situation that called for the decision. 2–3 paragraphs, anchored in concrete constraints.
2. **Decision** — what was chosen, declarative. One sentence to one paragraph. *What*, not *why*.
3. **Consequences** — what follows, intended and trade-off. What gets easier, harder, uncertain.
4. **Alternatives considered** — the genuine alternatives and why they were rejected. This is what makes it an ADR rather than a fiat declaration.

## Anti-patterns

- **Don't write ADRs for reversible decisions.** Change them when wrong.
- **Don't write ADRs for obvious decisions.** "We use TypeScript" needs none if no one would ask why.
- **Don't skip the Alternatives section.** Without alternatives it's a declaration, not a decision.
- **Don't edit an `Accepted` ADR row.** Supersede it — write a new row that references the old one and flip the old one's `Status` to `Superseded`.
