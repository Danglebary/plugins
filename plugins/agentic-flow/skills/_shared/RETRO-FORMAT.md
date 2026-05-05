# Retro format

The retro is a two-pass document paired to each PRD at `docs/prds/<NNN>-<slug>/retro.md`. It accumulates per-ticket entries during the PRD's lifecycle, then is restructured in place at PRD close.

## File path

`docs/prds/<NNN>-<slug>/retro.md`

## Running form (per-ticket entries)

Appended by `/done` when a ticket closes.

### Per-ticket entry format

```markdown
## Ticket NNN — <ticket title>

**Outcome**: Exact match | Extended | Divergence | Omitted

<1-3 sentences on what was learned>
```

### Outcome labels

- **Exact match** — implemented as the ticket and PRD specified.
- **Extended** — landed what was specified, plus extra scope that proved necessary or valuable.
- **Divergence** — implemented something different (different approach, different acceptance) than specified, with rationale.
- **Omitted** — ticket was abandoned or merged into another. Note where the work went (or didn't).

The same labels appear in the synthesized form, applied per PRD section instead of per ticket.

## Synthesized form (at PRD close)

Written by `/retro` (no args), which **restructures `retro.md` in place**. The running form is preserved in git history; the live file becomes the structured synthesis.

### Sections

One section per PRD section (Problem / Goals / Non-goals / Approach / Modules touched), each labeled with an outcome and with commentary.

Plus two optional appendices:

- **`## Refactor`** — appears when one or more tickets had `(refactor)`-marked entries in their `## Deviations` section (i.e., `/improve-codebase-architecture` ran and produced changes during the PRD's lifecycle). Captures *cumulative* refactor work across all tickets, with the same outcome-label vocabulary. Omitted when no `(refactor)` deviations exist.
- **`## Cross-cutting`** — for lessons that don't fit any single PRD section (e.g. terminology issues spanning multiple sections, CONTEXT.md updates that landed mid-PRD). Omitted when empty.

### Section format

```markdown
## Problem — Exact match

<commentary on whether the problem framing held up, what we learned about the problem during execution>
```

```markdown
## Approach — Divergence

<commentary on what we changed about the approach and why; reference specific tickets where the divergence surfaced>
```

## Example synthesized retro

```markdown
# Retro: Add user authentication

## Problem — Exact match

The framing held up. Returning users do want session persistence; nothing in implementation challenged the problem statement.

## Goals — Extended

All three goals shipped. Added a fourth goal during execution: signed cookies (see Approach). Worth noting because it shifted the security posture without a PRD edit.

## Non-goals — Exact match

OAuth and password reset stayed out of scope as planned.

## Approach — Divergence

Signed cookies replaced plain session IDs (ticket 002). Justified by defense-in-depth — DB lookup still catches invalid IDs, but cookie tampering is now visible. No ADR needed; localized change.

## Modules touched — Exact match

`src/auth/`, `src/middleware/`, `src/db/migrations/` all landed as planned.

## Refactor — Extended

Extracted `validateSession` into a deep module (ticket 002) and pulled cookie-signing out of middleware into its own helper (ticket 003). Both went beyond the originally-planned scope but kept the deepening framework consistent — middleware became thinner, validation testable in isolation.

## Cross-cutting

- "Session" appeared in code as both `Session` (the DB model) and `session` (the cookie value). Added to CONTEXT.md mid-PRD to disambiguate.
```

## Anti-patterns

- **Don't write `## Next steps`, `## Future work`, or `## Roadmap`.** Strictly backward-looking. Forward-looking work goes into a new PRD.
- **Don't restructure prematurely.** The running form lives until `/retro` is invoked at PRD close. Don't reorganize partway.
- **Don't drop the running form without git committing it.** The running entries are the raw material for synthesis; git history is the only place they survive after restructure.
