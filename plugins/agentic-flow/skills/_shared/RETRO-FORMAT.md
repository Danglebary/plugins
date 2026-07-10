# Retro format

The retro is a two-pass document paired to each spec. It accumulates per-ticket entries during the spec's lifecycle, then is restructured in place at spec close.

**Storage.** The file path below is the encoding; the artifact map is [STORE.md](./STORE.md)'s.

## File path

`docs/specs/<NNN>-<slug>/retro.md`

## Running form (per-ticket entries)

Appended by `/done` when a ticket closes.

### Per-ticket entry format

```markdown
## Ticket NNN — <ticket title>

**Outcome**: Exact match | Extended | Divergence | Omitted

<1-3 sentences on what was learned>
```

### Outcome labels

- **Exact match** — implemented as the ticket and spec specified.
- **Extended** — landed what was specified, plus extra scope that proved necessary or valuable.
- **Divergence** — implemented something different (different approach, different acceptance) than specified, with rationale.
- **Omitted** — ticket was abandoned or merged into another. Note where the work went (or didn't).

The same labels appear in the synthesized form, applied per spec section instead of per ticket.

## Synthesized form (at spec close)

Written by `/retro` (no args), which **restructures `retro.md` in place**. The running form is preserved in git history; the live file becomes the structured synthesis.

**Committed-running-retro precondition.** Git history is the *only* place the running form survives the rewrite, so `/retro` refuses to synthesize while the running retro has uncommitted content — a modified `retro.md`, or an untracked one (which has no history at all). `/done`'s gated close-out commit is what normally guarantees this; uncommitted running-retro content at spec close means one of those gates was declined or interrupted — commit the retro directly on the spec branch (or, when the ticket's `done` flip is also uncommitted, resume that `/done` close and let its commit gate carry the retro), then re-run `/retro`.

### Sections

One section per spec section (Problem / Goals / Non-goals / Approach / Modules touched), each labeled with an outcome and with commentary.

Plus two optional appendices:

- **`## Refactor`** — appears when one or more tickets had `(refactor)`-marked entries in their `## Deviations` section (i.e., `/improve-codebase-architecture` ran and produced changes during the spec's lifecycle). Captures *cumulative* refactor work across all tickets, with the same outcome-label vocabulary. Omitted when no `(refactor)` deviations exist.
- **`## Cross-cutting`** — for lessons that don't fit any single spec section (e.g. terminology issues spanning multiple sections, Glossary updates that landed mid-spec). Omitted when empty.

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

All three goals shipped. Added a fourth goal during execution: signed cookies (see Approach). Worth noting because it shifted the security posture without a spec edit.

## Non-goals — Exact match

OAuth and password reset stayed out of scope as planned.

## Approach — Divergence

Signed cookies replaced plain session IDs (ticket 002). Justified by defense-in-depth — DB lookup still catches invalid IDs, but cookie tampering is now visible. No ADR needed; localized change.

## Modules touched — Exact match

`src/auth/`, `src/middleware/`, `src/db/migrations/` all landed as planned.

## Refactor — Extended

Extracted `validateSession` into a deep module (ticket 002) and pulled cookie-signing out of middleware into its own helper (ticket 003). Both went beyond the originally-planned scope but kept the deepening framework consistent — middleware became thinner, validation testable in isolation.

## Cross-cutting

- "Session" appeared in code as both `Session` (the DB model) and `session` (the cookie value). Added to the Glossary mid-spec to disambiguate.
```

## Anti-patterns

- **Don't write `## Next steps`, `## Future work`, or `## Roadmap`.** Strictly backward-looking. Forward-looking work goes into a new spec.
- **Don't restructure prematurely.** The running form lives until `/retro` is invoked at spec close. Don't reorganize partway.
- **Don't drop the running form without git committing it.** The running entries are the raw material for synthesis; git history is the only place they survive after restructure. `/retro` enforces this as a precondition — it refuses to synthesize over an uncommitted running retro.
