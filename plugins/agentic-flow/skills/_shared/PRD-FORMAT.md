# PRD format

A PRD is the frozen multi-ticket scope document. It is written in a `Drafting` state, locked when `/to-tickets` runs (transitioning to `Open`), and marked `Done` when `/retro` synthesizes the retro.

**Storage.** The section structure, lifecycle, and anti-patterns here apply in both stores (see [STORE.md](./STORE.md)). The file path and frontmatter below are the **files store** encoding; in the **notion store** a PRD is a row in the PRDs database (`Kind = PRD`) whose properties replace the frontmatter and whose body holds the same five sections — see [NOTION-RESOLVER.md](./NOTION-RESOLVER.md).

## File path (files store)

`docs/prds/<NNN>-<slug>/prd.md`

`<NNN>` is repo-global, three-digit zero-padded, chronological. `<slug>` is kebab-case.

## Frontmatter (files store)

```yaml
---
status: drafting | open | done
---
```

(Notion store: the `Status` select — `Drafting` / `Open` / `Done` / `Abandoned`.)

State transitions:

- `drafting → open` — set by `/to-tickets` when it runs (ticket creation is one-shot; an already-`open` PRD refuses — unless its branch bootstrap hasn't landed, which re-offers only the bootstrap; the landed test's home is [STORE.md](./STORE.md)'s branch-link state tests, and the refuse-vs-re-offer routing is `/to-tickets`' State contract's).
- `open → done` — set by `/retro` when it synthesizes.

`/grill-me` and `/to-prd` may edit a `drafting` PRD freely. `/grill-me` refuses on `open` (frozen scope) and `done` (closed chapter). `/to-tickets`' ticket creation is one-shot per PRD — it refuses on `open` with a landed bootstrap (already locked) and on `done`; an `open` PRD whose bootstrap hasn't landed re-offers only the bootstrap. Re-opening a PRD is not supported by skills.

Per-skill state contracts are documented in each skill's `## State contract` subsection.

## Abandoned PRDs

Abandoned PRDs are moved to `docs/prds/_abandoned/<NNN>-<slug>/` (preserving the full PRD directory; notion store: flip `Status = Abandoned`). Numbers stay immutable across both the active and `_abandoned/` directories — numbering algorithms (e.g. `/to-prd`'s "highest existing prefix + 1") glob both locations (notion store: the max-`Number` query includes `Abandoned` rows).

Preserving abandoned PRDs is intentional: what didn't pan out is often as informative as what shipped.

## Sibling vehicles — ideas and spikes

Not every captured thought is PRD-weight. Two lighter vehicles sit alongside the PRD tier (`/to-prd` asks the fit question at capture time):

- **Ideas** — `docs/prds/ideas/<slug>.md` (notion store: a PRDs row with `Kind = Idea`), un-numbered. A banked thought not ready to commit to. Promoted to a numbered PRD when it's time to build; it gets its number then, never before. Ideas don't participate in numbering.
- **Spikes** — `docs/spikes/<slug>.md` (notion store: a PRDs row with `Kind = Spike`). An investigation whose deliverable is *findings*, not behavior. No tickets, no retro, no status lifecycle. Findings that justify building feed a new PRD. Spike docs are also the defined relocation home for findings-type deliverables that `/retro`'s synthesis would otherwise drop.

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

Which parts of the codebase this PRD will touch. High-signal — feeds `/improve-codebase-architecture` later. Use the language from the Glossary (`CONTEXT.md` in the files store).

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
