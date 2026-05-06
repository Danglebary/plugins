# Ticket format

A ticket is a single unit of work nested under a PRD. Lives at `docs/prds/<NNN>-<slug>/tickets/<NNN>-<slug>.md`.

Tickets are vertical slices: end-to-end behavior across whatever layers they touch, not horizontal layers across many features.

Tickets are written in **behavioral voice**: Goal and Acceptance criteria describe what changes for a user or caller, not how the code is shaped. Implementation prescription belongs only when load-bearing — see [ABSTRACTION-LEVELS-PRINCIPLE.md](./ABSTRACTION-LEVELS-PRINCIPLE.md).

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

**Optional.** An escape hatch for *load-bearing* implementation constraints surfaced during grilling — typically seam-level constraints surfacing as hints (e.g. *"use the existing SessionStore, don't introduce a new one"*, *"must integrate with the existing feature flag system"*, *"no new dependencies"*). Not a place for code-shape directives, design preferences, or general gotchas — those either belong in inline comments next to the code (when implementation lands) or shouldn't be in the ticket at all. Omit the section entirely when there's no load-bearing constraint to capture.

### 4. Deviations

Appended during implementation. Captures **behavioral or seam-level** divergence from the ticket's planned approach. The bridge between ticket-level execution and PRD-level retro.

Threshold: a deviation is captured when implementation diverges from spec at the *behavioral* or *seam* level. Below-threshold changes (internal control flow, private renames, formatting, idiomatic refactors inside a module) are noise. For tickets entirely inside one module that touch no seams, the criterion collapses to behavioral divergence; if neither behavior nor seams diverged from spec, leave the section at `_None._`. See [ABSTRACTION-LEVELS-PRINCIPLE.md](./ABSTRACTION-LEVELS-PRINCIPLE.md) for the full in/out lists.

Format: free-form prose, one item per deviation, ideally referencing the PRD section it touches. Loose structure because the agent appends as work happens.

**Refactor marker.** Seam-level changes from `/improve-codebase-architecture` (the per-ticket refactor pass recommended by `/done`) are captured in this same section, with a `(refactor)` prefix on the line — e.g. `(refactor) Extracted Session validation into a deep module to consolidate cookie-vs-DB checks.` The marker lets `/retro`'s synthesis distinguish refactor deviations from feature deviations and group them into the retro's optional `## Refactor` section. The same threshold applies: refactor entries capture seam-level moves, not internal cleanups.

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

Session lookups must go through the existing `db.session` module (do not introduce a parallel raw-SQL path) — keeps session access on a single seam for future caching and audit work.

## Deviations

- Approach (PRD §4): Used signed cookies instead of plain session IDs. IO surface change: cookie format gained an HMAC. Rationale: prevents trivial cookie tampering even if the DB lookup catches invalid IDs. No PRD change needed; safer default.
- Acceptance: Concurrent requests sharing a session previously raced on the validation path; fixed and covered with a new test case. (Behavior added beyond the original four acceptance criteria.)
- (refactor) Extracted `validateSession` from middleware into its own deep module — middleware now just calls one entry point, validation logic is testable in isolation.
```

## Anti-patterns

- **Don't make horizontal-slice tickets.** ("Set up routing", "Add types", "Wire up middleware") — these don't deliver behavior. Reframe as vertical slices that include the layers needed. A ticket should make the answer to "what new behavior does this give us?" obvious in one sentence.
- **Don't write tickets in implementation voice.** ("Change this function call to use map instead of forEach", "add an `if` check here", "rename `parseFoo` to `parseInput`") — these are code-shape directives, not behavioral specs. Reframe as the behavior the change should produce, or drop the line entirely. See [ABSTRACTION-LEVELS-PRINCIPLE.md](./ABSTRACTION-LEVELS-PRINCIPLE.md).
- **Don't capture implementation noise in `## Deviations`.** ("Renamed a private helper", "ran the formatter", "extracted an internal function for clarity") — below threshold. If the seam didn't move and observable behavior didn't change, it isn't a deviation.
- **Don't add status values not in the spec.** No `blocked`, `review`, `abandoned`, etc. — keep the state machine minimal.
- **Don't put deviation rationales in the implementation notes.** Notes are written before impl. Deviations are appended after.
- **Don't reference tickets in other PRDs.** Tickets are PRD-scoped. Cross-PRD work means a new PRD, not a ticket linkage.
