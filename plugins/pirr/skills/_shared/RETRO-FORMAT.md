# Retro format

The retro is a two-pass document paired to each spec: it accumulates per-ticket entries during the spec's lifecycle, then is restructured in place at spec close.

## File path

`docs/specs/<NNN>-<slug>/retro.md` — this path is the encoding; the artifact map is [STORE.md](./STORE.md)'s.

## Running form (per-ticket entries)

Appended by `/done` when a ticket closes, then by `/refactor`'s close-out, which adds its own `**Dispatch** (refactor):` line to the entry `/done` already wrote. Two writers, so a modified running-form `retro.md` does not identify which one left it dirty — see the precondition below.

### Per-ticket entry format

```markdown
## Ticket NNN — <ticket title>

**Outcome**: Exact match | Extended | Divergence | Omitted

**Dispatch**: <lenses dispatched and how each resolved>

<1-3 sentences on what was learned>
```

This template is a two-member sync set with `/done`'s step-8 copy — a change here fans out to that skill.

### The `**Dispatch**` field

The **Dispatch record** ([EVIDENCE-PRINCIPLE.md](./EVIDENCE-PRINCIPLE.md)) — which lenses the close dispatched and how each resolved, so a lens that never ran is legible after the session ends. Written by `/done` from the close-out pair; `/refactor` appends its own from the Reviewers manifest, marked `**Dispatch** (refactor):` to distinguish the two keepers in one entry. `/retro` keeps no record and adds no line.

Emission is mandatory, detail is gap-only. The clean case is one line; only the three non-clean states (`degraded`, `refused`, `unresolved`) carry detail, naming the lens and what its absence cost:

```markdown
**Dispatch**: close-out pair — both returned.
**Dispatch** (refactor): 7 reviewers — all returned.
```

```markdown
**Dispatch** (refactor): 7 reviewers — `pirr:qa-engineer` degraded (returned findings with no
Partial verdict register, so its gap check is unaccounted for); the other 6 returned.
```

A persisted record never pairs `returned` with `unresolved`. The **Resolution preflight** refuses before *any* lens is dispatched, so an unresolved name means nothing ran and the close or pass ends there — the refusal message carries that record, and no retro entry receives it. `degraded` and `refused` are the states that legitimately sit beside `returned` in a persisted line.

The record is an **attestation, not a verification**: it states what was dispatched and what came back, never that a lens was correct. Nothing downstream can audit it, which is why the pre-dispatch **Resolution preflight** carries its weight.

### Outcome labels

- **Exact match** — implemented as the ticket and spec specified.
- **Extended** — landed what was specified, plus extra scope that proved necessary or valuable.
- **Divergence** — implemented something different (approach or acceptance) than specified, with rationale.
- **Omitted** — ticket abandoned or merged into another; note where the work went (or didn't).

The same labels appear in the synthesized form, applied per spec section instead of per ticket.

## Synthesized form (at spec close)

Written by `/retro` (no args), which **restructures `retro.md` in place**. The running form is preserved in git history; the live file becomes the structured synthesis.

**Committed-running-retro precondition.** Git history is the *only* place the running form survives the rewrite, so `/retro` refuses to synthesize while the running retro has uncommitted content — a modified `retro.md`, or an untracked one. Fix: commit the retro directly on the spec branch — or resume whichever writer left it dirty and let that skill's commit gate carry it. The ticket's `done` flip discriminates: **uncommitted** alongside the retro dirt means an interrupted `/done` close (resume `/done`); **already committed** means an interrupted `/refactor` pass, which writes the retro at step 9 before its gates (re-run `/refactor`, whose gate 2 commits the record). Then re-run `/retro`.

### Sections

One section per spec section (Problem / Goals / Non-goals / Approach / Modules touched), each labeled with an outcome and commentary.

Plus two optional appendices:

- **`## Refactor`** — appears when one or more tickets had `(refactor)`-marked entries in their `## Deviations` section. Captures *cumulative* refactor work across all tickets, with the same outcome-label vocabulary. Omitted when no `(refactor)` deviations exist.
- **`## Cross-cutting`** — lessons that don't fit any single spec section (e.g. terminology spanning sections, mid-spec Glossary updates). Omitted when empty.

### Section format

```markdown
## Approach — Divergence

<commentary on what changed and why; reference specific tickets where the divergence surfaced>
```

## Example synthesized retro

```markdown
# Retro: Add user authentication

## Problem — Exact match

The framing held up. Nothing in implementation challenged the problem statement.

## Goals — Extended

All three goals shipped, plus a fourth during execution: signed cookies (see Approach).

## Non-goals — Exact match

OAuth and password reset stayed out of scope as planned.

## Approach — Divergence

Signed cookies replaced plain session IDs (ticket 002). Defense-in-depth; no ADR needed, localized change.

## Modules touched — Exact match

`src/auth/`, `src/middleware/`, `src/db/migrations/` all landed as planned.

## Refactor — Extended

Extracted `validateSession` into a deep module (ticket 002) and pulled cookie-signing into its own helper (ticket 003) — beyond planned scope but kept the deepening framework consistent.

## Cross-cutting

- "Session" appeared as both `Session` (DB model) and `session` (cookie value); added to the Glossary mid-spec to disambiguate.
```

## Anti-patterns

- **Don't write `## Next steps`, `## Future work`, or `## Roadmap`** — strictly backward-looking; forward-looking work goes into a new spec.
- **Don't restructure prematurely** — the running form lives until `/retro` at spec close; don't reorganize partway.
- **Don't drop the running form without git committing it** — the committed-running-retro precondition above refuses to synthesize otherwise.
