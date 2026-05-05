# Ticket format

A ticket is a single unit of work nested under a PRD. Lives at `docs/prds/<NNN>-<slug>/tickets/<NNN>-<slug>.md`.

Tickets are vertical slices: end-to-end behavior across whatever layers they touch, not horizontal layers across many features.

## File path

`docs/prds/<NNN>-<slug>/tickets/<NNN>-<slug>.md`

`<NNN>` is PRD-scoped, three-digit zero-padded (each PRD restarts at `001`). `<slug>` is kebab-case.

## Frontmatter

```yaml
---
status: open | in-progress | done
depends_on: [001, 002]
---
```

`depends_on` lists ticket IDs (the numeric prefix only, not the full slug). Empty list (`[]`) when no dependencies.

`blocked` is **not** a stored state — it is computed by `/next-ticket` from `depends_on` against other tickets' statuses.

The dependency graph must be acyclic. `/to-tickets` validates acyclicity at write time and refuses to write on a cycle. `/next-ticket` validates defensively at read time (since users may edit `depends_on` manually) and warns if a cycle is detected, listing any tickets still ready outside the cycle.

ID and title are encoded in the filename — never duplicated in frontmatter.

Abandoned tickets are moved to `tickets/_abandoned/`. They do not get a status value. Numbers stay immutable across both the active and `_abandoned/` directories.

## Body sections

### 1. Goal

One paragraph: what this ticket achieves and why. In/out scope folded in here when relevant. Keep tight — anything more belongs in implementation notes or in the parent PRD.

### 2. Acceptance criteria

A checklist of observable, testable conditions for "done". Each item should be something the implementing agent can verify objectively (test passes, endpoint returns expected response, UI shows expected element).

### 3. Implementation notes

**Optional.** An escape hatch for context surfaced during grilling that doesn't fit elsewhere — design hints, gotchas, references to specific files. Omit when there's nothing useful to say.

### 4. Deviations

Appended during implementation. Captures any divergence from the ticket's planned approach. The bridge between ticket-level execution and PRD-level retro.

Format: free-form prose, one item per deviation, ideally referencing the PRD section it touches. Loose structure because the agent appends as work happens.

**Refactor marker.** Architectural changes from `/improve-codebase-architecture` (the per-ticket refactor pass recommended by `/done`) are captured in this same section, with a `(refactor)` prefix on the line — e.g. `(refactor) Extracted Session validation into a deep module to consolidate cookie-vs-DB checks.` The marker lets `/retro`'s synthesis distinguish refactor deviations from feature deviations and group them into the retro's optional `## Refactor` section.

Initial placeholder body (written by `/to-tickets`): `_None yet._`

## Example

```markdown
---
status: done
depends_on: [001]
---

# Add session middleware

## Goal

Add HTTP middleware that validates session cookies on every request to protected routes. Out of scope: the signin/signup flow itself (handled by ticket 001).

## Acceptance criteria

- [x] Middleware reads `session_id` cookie and looks up the session in Postgres.
- [x] Expired sessions return 401 with `WWW-Authenticate: Session` header.
- [x] Valid sessions attach `user` to the request context.
- [x] Test coverage for expired, invalid, and valid session paths.

## Implementation notes

The session table schema landed in ticket 001's migration. Use `db.session.findById` rather than raw SQL.

## Deviations

- Approach (PRD §4): Used signed cookies instead of plain session IDs. Rationale: prevents trivial cookie tampering even if the DB lookup catches invalid IDs. No PRD change needed; safer default.
- Acceptance: Added a 5th test case (concurrent requests with same session) after discovering a race in initial impl.
- (refactor) Extracted `validateSession` from middleware into its own deep module — middleware now just calls one entry point, validation logic is testable in isolation.
```

## Anti-patterns

- **Don't make horizontal-slice tickets.** ("Set up routing", "Add types", "Wire up middleware") — these don't deliver behavior. Reframe as vertical slices that include the layers needed.
- **Don't add status values not in the spec.** No `blocked`, `review`, `abandoned`, etc. — keep the state machine minimal.
- **Don't put deviation rationales in the implementation notes.** Notes are written before impl. Deviations are appended after.
- **Don't reference tickets in other PRDs.** Tickets are PRD-scoped. Cross-PRD work means a new PRD, not a ticket linkage.
