# PRD format

A PRD is the frozen multi-ticket scope document at `docs/prds/<NNN>-<slug>/prd.md`. It is written in a `drafting` state, locked when `/to-tickets` runs (transitioning to `open`), and marked `done` when `/retro` synthesizes the retro.

## File path

`docs/prds/<NNN>-<slug>/prd.md`

`<NNN>` is repo-global, three-digit zero-padded, chronological. `<slug>` is kebab-case.

## Frontmatter

```yaml
---
status: drafting | open | done
---
```

State transitions:

- `drafting → open` — set by `/to-tickets` when it runs (one-shot; refuses on already-`open` PRDs).
- `open → done` — set by `/retro` when it synthesizes.

`/grill-me` and `/to-prd` may edit a `drafting` PRD freely. `/grill-me` and `/to-tickets` refuse to run on a `done` PRD. Re-opening a PRD is not supported by skills.

Per-skill state contracts are documented in each skill's `## State contract` subsection.

## Abandoned PRDs

Abandoned PRDs are moved to `docs/prds/_abandoned/<NNN>-<slug>/` (preserving the full PRD directory). They do not get a status value. Numbers stay immutable across both the active and `_abandoned/` directories — numbering algorithms (e.g. `/to-prd`'s "highest existing prefix + 1") glob both locations.

Preserving abandoned PRDs is intentional: what didn't pan out is often as informative as what shipped.

## Body sections

Five required sections, each a meaningful unit to retrospect on. The synthesized retro mirrors these sections with outcome labels.

### 1. Problem

What we're solving and why. Anchor in user-facing or business need where applicable; otherwise in the technical pain being addressed.

### 2. Goals

What success looks like. Observable outcomes when the PRD is done.

### 3. Non-goals

Explicit out-of-scope. Captures the boundary decisions surfaced during grilling.

### 4. Approach

High-level technical direction. PRD-local decisions live here. Cross-PRD decisions go to ADRs (created inline during `/grill-me` via the three-gate test), not into this section.

### 5. Modules touched

Which parts of the codebase this PRD will touch. High-signal — feeds `/improve-codebase-architecture` later. Use the language from CONTEXT.md.

## Example

```markdown
---
status: open
---

# Add user authentication

## Problem

Visitors cannot save preferences across sessions. We want to introduce email/password auth so returning users see their saved state.

## Goals

- Users can sign up with email + password.
- Users can sign in and remain signed in across sessions.
- Sessions expire after 30 days of inactivity.

## Non-goals

- OAuth / social login (planned for a later PRD).
- Password reset flow (a follow-up PRD will handle this).

## Approach

Email/password using bcrypt for hashing. Sessions stored in Postgres `sessions` table with HTTP-only cookies. Session middleware validates on every request to protected routes.

## Modules touched

- `src/auth/` — new module for signup, signin, session validation
- `src/middleware/` — new session middleware
- `src/db/migrations/` — new migration for `users` and `sessions` tables
```

## Anti-patterns

- **Don't write a `## Decisions` section.** Decisions either belong inline in Approach (PRD-local) or in ADRs (cross-PRD).
- **Don't write a `## Open questions` section.** Open questions are a grilling artifact and must be resolved before lock. The locked PRD has answers, not questions.
- **Don't write a `## Next steps` or `## Future work` section.** Forward-looking work goes into a new PRD.
- **Don't size beyond ~10 tickets.** If `/to-tickets` would produce more than ~10 tickets, the PRD is epic-sized and should be split.
