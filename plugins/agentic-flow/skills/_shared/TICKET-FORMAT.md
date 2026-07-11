# Ticket format

A ticket is a single unit of work nested under a spec.

Tickets are vertical slices: end-to-end behavior across the layers they touch, not horizontal layers across many features.

Tickets are written in **behavioral voice**: Goal and Acceptance criteria describe what changes for a user or caller, not how the code is shaped. Implementation prescription belongs only when load-bearing — see [ABSTRACTION-LEVELS-PRINCIPLE.md](./ABSTRACTION-LEVELS-PRINCIPLE.md).

**Storage.** The file path and frontmatter below are the encoding; the artifact map is [STORE.md](./STORE.md)'s.

## File path

`docs/specs/<NNN>-<slug>/tickets/<NNN>-<slug>.md`

`<NNN>` is spec-scoped, three-digit zero-padded (each spec restarts at `001`). `<slug>` is kebab-case.

## Frontmatter

```yaml
---
status: open | in-progress | done
depends_on: [001, 002]
---
```

`depends_on` lists ticket IDs (the numeric prefix only, not the full slug). Empty list (`[]`) when no dependencies.

`blocked` is **not** a stored state — it is computed by `/next-ticket` from `depends_on` against other tickets' statuses.

The dependency graph must be acyclic. `/to-tickets` validates acyclicity at write time and refuses to write on a cycle. `/next-ticket` validates defensively at read time (users may hand-edit `depends_on`) and warns if a cycle is detected, listing any tickets still ready outside the cycle.

ID and title are encoded in the filename — never duplicated in frontmatter.

Abandoned tickets are moved to `tickets/_abandoned/`. Numbers stay immutable across both the active and `_abandoned/` directories.

## Body sections

### 1. Goal

One paragraph: what this ticket achieves and why. In/out scope folded in here when relevant. Keep tight — anything more belongs in implementation notes or the parent spec.

### 2. Acceptance criteria

A checklist of observable, testable conditions for "done". Each item should be objectively verifiable by the implementing agent.

### 3. Implementation notes

**Optional.** An escape hatch for *load-bearing* implementation constraints — typically seam-level hints (e.g. *"use the existing SessionStore, don't introduce a new one"*). Not a place for code-shape directives, design preferences, or general gotchas — those belong in inline comments next to the code, or not in the ticket at all. Omit the section entirely when there's no load-bearing constraint to capture.

**`### Deferred steers`** — an optional subsection appended *after* ticket creation: other tickets' close-outs and `/improve-codebase-architecture` passes park deferrals targeting this ticket here, each entry naming its provenance (*"From ticket NNN's refactor pass: …"*). Steers are pre-impl constraint material for *this* ticket — the same load-bearing bar applies. `/improve`'s reviewer briefs feed them back as already-deferred candidates so reviewers don't re-propose them.

### 4. Deviations

Appended during implementation. A deviation is captured when implementation diverges from the ticket's planned approach at the **behavioral or seam** level (the threshold). Below-threshold changes (internal control flow, private renames, formatting, idiomatic refactors inside a module) are noise. For single-module, no-seam tickets the criterion collapses to behavioral divergence; if neither behavior nor seams diverged from spec, leave the section at `_None._` See [ABSTRACTION-LEVELS-PRINCIPLE.md](./ABSTRACTION-LEVELS-PRINCIPLE.md) for the full in/out lists.

Format: free-form prose, one item per deviation, ideally referencing the spec section it touches.

**Refactor marker.** Seam-level changes from `/improve-codebase-architecture` (the per-ticket refactor pass) are captured in this same section with a `(refactor)` prefix on the line. The marker lets `/retro`'s synthesis distinguish refactor deviations from feature deviations and group them into the retro's optional `## Refactor` section. The same threshold applies: refactor entries capture seam-level moves, not internal cleanups.

Initial placeholder body (written by `/to-tickets`): `_None yet._`

## Example

```markdown
---
status: done
depends_on: [001]
---

# Add session middleware

## Goal

Add HTTP middleware that validates session cookies on protected routes. Out of scope: the signin/signup flow (ticket 001).

## Acceptance criteria

- [x] Middleware reads `session_id` cookie and looks up the session in Postgres.
- [x] Expired sessions return 401 with `WWW-Authenticate: Session`; valid sessions attach `user` to the request context.
- [x] Tests cover expired, invalid, and valid paths.

## Implementation notes

Session lookups must go through the existing `db.session` module (no parallel raw-SQL path) — keeps session access on a single seam for future caching/audit.

## Deviations

- Approach (spec §4): signed cookies instead of plain session IDs — cookie format gained an HMAC. Prevents trivial tampering; no spec change needed.
- (refactor) Extracted `validateSession` from middleware into its own deep module — validation is now testable in isolation.
```

## Anti-patterns

- **Don't make horizontal-slice tickets.** ("Set up routing", "Add types") — these don't deliver behavior. Reframe as vertical slices that include the layers needed. A ticket should make the answer to "what new behavior does this give us?" obvious in one sentence.
- **Don't write tickets in implementation voice.** ("rename `parseFoo` to `parseInput`") — code-shape directives, not behavioral specs. Reframe as the behavior the change should produce, or drop the line entirely. See [ABSTRACTION-LEVELS-PRINCIPLE.md](./ABSTRACTION-LEVELS-PRINCIPLE.md).
- **Don't capture implementation noise in `## Deviations`.** ("Renamed a private helper", "ran the formatter") — below threshold. If the seam didn't move and observable behavior didn't change, it isn't a deviation.
- **Don't add status values not in this format.** No `blocked`, `review`, etc. (`Abandoned` is structural — the `_abandoned/` move — never a frontmatter value.)
- **Don't put deviation rationales in the implementation notes.** Notes are written before impl. Deviations are appended after.
- **Don't reference tickets in other specs.** Tickets are spec-scoped. Cross-spec work means a new spec, not a ticket linkage.
