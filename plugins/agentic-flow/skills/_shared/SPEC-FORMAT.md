# Spec format

A spec is the frozen multi-ticket scope document. It is written in a `Drafting` state, locked when `/to-tickets` runs (transitioning to `Open`), and marked `Done` when `/retro` synthesizes the retro.

**Storage.** The file path and frontmatter below are the encoding; the artifact map is [STORE.md](./STORE.md)'s.

## File path

`docs/specs/<NNN>-<slug>/spec.md`

`<NNN>` is repo-global, three-digit zero-padded, chronological. `<slug>` is kebab-case.

## Frontmatter

```yaml
---
status: drafting | open | done
---
```

State transitions:

- `drafting → open` — set by `/to-tickets` when it runs (ticket creation is one-shot; an already-`open` spec refuses — unless its branch bootstrap hasn't landed, which re-offers only the bootstrap; the landed test's home is [STORE.md](./STORE.md)'s branch-link state tests, and the refuse-vs-re-offer routing is `/to-tickets`' State contract's).
- `open → done` — set by `/retro` when it synthesizes.

`/grill-me` and `/to-spec` may edit a `drafting` spec freely. `/grill-me` refuses on `open` (frozen scope) and `done` (closed chapter). `/to-tickets`' ticket creation is one-shot per spec — it refuses on `open` with a landed bootstrap (already locked) and on `done`; an `open` spec whose bootstrap hasn't landed re-offers only the bootstrap. Re-opening a spec is not supported by skills.

Per-skill state contracts are documented in each skill's `## State contract` subsection.

## Abandoned specs

Abandoning a spec is a manual recipe — no skill performs it, and this section is its one home; skills and docs that mention abandonment cite here:

1. Move the full spec directory to `docs/specs/_abandoned/<NNN>-<slug>/` (`spec.md`, `tickets/`, any `retro.md` — everything moves together).
2. Clear the active pointer if it names this spec (delete `docs/specs/.active`).
3. If the spec has a branch (`spec-<NNN>-<slug>`, or its legacy `prd-<NNN>-<slug>` twin), commit the relocation on that branch and merge it into the default branch, so the abandoned spec lands in preserved form. **Never a bare branch delete** — the branch carries the spec's planning artifacts, and a deleted unmerged branch leaves them recoverable only from the reflog, which expires.
4. A spec with no branch yet (abandoned while `Drafting`) has nothing to merge: commit the relocation on the branch that carries the draft.

Numbers stay immutable across both the active and `_abandoned/` directories — numbering algorithms (e.g. `/to-spec`'s "highest existing prefix + 1") glob both locations and also scan `spec-<NNN>-<slug>` and legacy `prd-<NNN>-<slug>` branch names, local and remote, so a spec in flight on its branch keeps its number reserved from any checkout (the enumeration rule in [STORE.md](./STORE.md)'s branch-link state tests).

Preserving abandoned specs is intentional: what didn't pan out is often as informative as what shipped. (Tickets abandoned individually move to `tickets/_abandoned/` — [TICKET-FORMAT.md](./TICKET-FORMAT.md)'s rule; this recipe is spec-level.)

## Sibling vehicles — ideas and spikes

Not every captured thought is spec-weight. Two lighter vehicles sit alongside the spec tier (`/to-spec` asks the fit question at capture time):

- **Ideas** — `docs/specs/ideas/<slug>.md`, un-numbered. A banked thought not ready to commit to. Promoted to a numbered spec when it's time to build; it gets its number then, never before. Ideas don't participate in numbering.
- **Spikes** — `docs/spikes/<slug>.md`. An investigation whose deliverable is *findings*, not behavior. No tickets, no retro, no status lifecycle. Findings that justify building feed a new spec. Spike docs are also the defined relocation home for findings-type deliverables that `/retro`'s synthesis would otherwise drop.

## Body sections

Five required sections, each a meaningful unit to retrospect on. The synthesized retro mirrors these sections with outcome labels.

### 1. Problem

What we're solving and why. Anchor in user-facing or business need where applicable; otherwise in the technical pain being addressed.

### 2. Goals

What success looks like. Observable outcomes when the spec is done.

### 3. Non-goals

Explicit out-of-scope. Captures the boundary decisions surfaced during grilling.

### 4. Approach

High-level technical direction. Spec-local decisions live here. Cross-spec decisions go to ADRs (created inline during `/grill-me` via the three-gate test), not into this section.

### 5. Modules touched

Which parts of the codebase this spec will touch. High-signal — feeds `/improve-codebase-architecture` later. Use the language from the Glossary (`CONTEXT.md`).

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

- OAuth / social login (planned for a later spec).
- Password reset flow (a follow-up spec will handle this).

## Approach

Email/password using bcrypt for hashing. Sessions stored in Postgres `sessions` table with HTTP-only cookies. Session middleware validates on every request to protected routes.

## Modules touched

- `src/auth/` — new module for signup, signin, session validation
- `src/middleware/` — new session middleware
- `src/db/migrations/` — new migration for `users` and `sessions` tables
```

## Anti-patterns

- **Don't write a `## Decisions` section.** Decisions either belong inline in Approach (spec-local) or in ADRs (cross-spec).
- **Don't write a `## Open questions` section.** Open questions are a grilling artifact and must be resolved before lock. The locked spec has answers, not questions.
- **Don't write a `## Next steps` or `## Future work` section.** Forward-looking work goes into a new spec.
- **Don't size beyond ~10 tickets.** If `/to-tickets` would produce more than ~10 tickets, the spec is epic-sized and should be split.
