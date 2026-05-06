# Abstraction levels

Each artifact in agentic-flow operates at a specific abstraction level. Content stays at that level — content above or below the level rots faster than it informs, and ends up orphaned from the thing it was meant to justify. This doc names the three levels and the rules that fall out of them.

## The three levels

**Behavioral.** What the system does for a user or caller — the level a product person or external integrator would describe the system at. Lives in PRDs (Problem, Goals, Approach), tickets (Goal, Acceptance criteria), and retros. Documentation at this level tracks *how the system works* over time.

**Seam-level.** Where module boundaries are drawn, what their public APIs look like, how logical domains compose. This is where software engineers actually design — boundaries between modules and logical domains are the load-bearing surface for codebase evolution; without careful design here, codebases stop scaling and end up needing rewrites. Lives in ticket Deviations (when seams shift during implementation) and ADRs (when seam choices are consequential enough to record as decisions).

**Code-shape.** Why a specific function, module, or block is structured the way it is. Lives in inline comments next to the code, gated on non-obvious WHY (a hidden constraint, a subtle invariant, a workaround for a specific bug, behavior that would surprise a reader). If removing the comment wouldn't confuse a future reader, don't write it. Comments at this level track *why the code is written the way it is*, co-located with the code they justify.

## Rules that fall out

### Ticket voice — behavioral, not implementation

Tickets describe behavior the system gains, loses, or has fixed. A well-written ticket reads as *"here's a behavior that's missing — let's add it"*, *"this behavior isn't working — fix it"*, or *"remove this behavior"*. The Goal and Acceptance criteria stay at this level; the implementing agent decides what code shape best fits the codebase as it actually exists.

Implementation prescription belongs in a ticket only when the prescription is itself the load-bearing constraint — *"use the existing SessionStore, don't introduce a new one"*, *"must integrate with the existing feature flag system"*, *"no new dependencies"*. Those are seam-level constraints surfacing as implementation hints, not code-shape directives. Default to leaving implementation silent so the implementing agent can match the codebase as it actually exists rather than as the ticket-writer imagined it.

### Deviation threshold — seam-level and behavioral only

A deviation is captured when implementation diverges from spec at the behavioral or seam level. Anything below that threshold is noise — it crowds out the deviations that matter and turns retros into commentary on formatting choices.

In-scope (capture as a deviation):
- behavioral divergence from any Acceptance criterion (changed, added, dropped)
- new module created, deleted, split, or merged
- public/exported API of a module changed (added or removed export, signature change at the boundary)
- a data structure that crosses a module boundary changed
- IO surface changed (network, filesystem, database, external service)
- dependency edges between modules added or removed
- a seam change that produces a caller-visible behavior change

Out-of-scope (don't capture):
- internal control flow within a module's private code
- private helper renames, signature changes, refactors that don't surface at the boundary
- formatting, naming, or idiomatic refactors inside a module
- test internals (vs. what the test asserts about behavior)
- comment additions or edits (code-shape rationale lives in comments by design — see *Rationale placement* below)

For tickets entirely inside one module that touch no seams (e.g. *"add validation to the user signup flow"*), the criterion collapses to behavioral divergence only. If neither behavior nor seams diverged from spec, `## Deviations` stays at `_None._`. The deviation-fact-checker should not manufacture filler — empty is the correct outcome when nothing seam-level or behavioral diverged.

### Rationale placement — comments for code-shape, docs for behavior over time

Code-shape rationale goes in inline comments, co-located with the code it justifies. *Why this module is overloaded this way, why this pattern is used here, why this private function returns what it returns, why we use approach X over Y in this spot* — comments. Not tickets, not PRDs, not retros. Code-shape rationale in docs is orphaned from the thing it justifies, and the future maintainer reading the function won't have the doc in scope when they need it.

Behavioral evolution goes in docs. *What the system used to do, what it does now, why we changed it* — that's PRD, ticket, and retro material. Comments are not the place to write project history; they should explain the shape of the code in front of the reader, not narrate how the project got there.

## Anti-patterns

- **Implementation prescription in ticket Goals or Acceptance criteria.** *"Change this function call to use map instead of forEach"*, *"add an `if` check here"* — these are code-shape directives, not behavioral specs. Reframe as the behavior the change should produce, or drop the line entirely if no behavior changes.
- **Code-shape rationale in tickets, PRDs, or retros.** Belongs in comments. Docs are not the place for *"we picked this pattern because…"* — that rationale rots away from the code that needs it.
- **Implementation noise in `## Deviations`.** *"Renamed `parseFoo` to `parseInput`"*, *"ran the formatter"*, *"extracted a private helper for clarity"* are below threshold. If the seam didn't move and observable behavior didn't change, it isn't a deviation.
- **Behavioral history buried in code comments.** *"We used to validate on the client; moved to the server in PRD 003"* is doc material, not comment material. Comments are about the code's shape, not the project's timeline.
