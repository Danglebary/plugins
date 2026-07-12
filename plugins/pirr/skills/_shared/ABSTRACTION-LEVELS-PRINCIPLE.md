# Abstraction levels

Each pirr artifact operates at a specific abstraction level. Content stays at that level — off-level content rots faster than it informs and ends up orphaned.

## The three levels

**Behavioral.** What the system does for a user or caller. Lives in specs (Problem, Goals, Approach), tickets (Goal, Acceptance criteria), and retros. Docs at this level track *how the system works* over time.

**Seam-level.** Where module boundaries are drawn, what their public APIs look like, how logical domains compose — the load-bearing surface for codebase evolution; without careful design here, codebases stop scaling and need rewrites. Lives in ticket Deviations (when seams shift during implementation) and ADRs (when seam choices are consequential enough to record as decisions).

**Code-shape.** Why a specific function, module, or block is structured the way it is. Lives in inline comments next to the code, gated on non-obvious WHY (a hidden constraint, a subtle invariant, a bug workaround, surprising behavior). If removing the comment wouldn't confuse a future reader, don't write it.

## Rules that fall out

### Ticket voice — behavioral, not implementation

Tickets describe behavior the system gains, loses, or has fixed. The Goal and Acceptance criteria stay at this level; the implementing agent decides what code shape best fits the codebase as it actually exists.

Implementation prescription belongs in a ticket only when the prescription is itself the load-bearing constraint (*"no new dependencies"*). Default to leaving implementation silent so the agent matches the real codebase.

### Deviation threshold — seam-level and behavioral only

A deviation is captured when implementation diverges from spec at the behavioral or seam level. Anything below that threshold is noise.

This threshold gates what gets *documented* as a deviation — not what gets *done*. "Below threshold" means "doesn't earn a `## Deviations` entry," never "not worth doing." Worth making and worth recording are independent judgments: make the cleanup on its merits; just don't write a Deviation line for it.

In-scope (capture as a deviation):
- behavioral divergence from any Acceptance criterion (changed, added, dropped)
- new module created, deleted, split, or merged
- public/exported API of a module changed (export added or removed, boundary signature change)
- a data structure that crosses a module boundary changed
- IO surface changed (network, filesystem, database, external service)
- dependency edges between modules added or removed
- a seam change that produces a caller-visible behavior change
- shared tooling surface changed (build graph wiring, benchmark or test-harness entry points, developer-facing scripts) — anything a contributor outside the ticket's module depends on

Tooling-surface changes internal to one module's own tests or scaffolding stay below threshold. This ruling is scope-independent: the same change gets the same verdict at `/done` and `/retro` — if it passed one, it must not flag at the other.

Out-of-scope (don't capture):
- internal control flow within a module's private code
- private helper renames, signature changes, refactors that don't surface at the boundary
- formatting, naming, or idiomatic refactors inside a module
- test internals (vs. what the test asserts about behavior)
- comment additions or edits (code-shape rationale lives in comments by design — see *Rationale placement* below)

For tickets inside one module touching no seams, the criterion collapses to behavioral divergence only. If neither behavior nor seams diverged from spec, `## Deviations` stays at `_None._` — the deviation-fact-checker should not manufacture filler; empty is the correct outcome.

### Rationale placement — comments for code-shape, docs for behavior over time

Code-shape rationale goes in inline comments, co-located with the code it justifies. Not tickets, not specs, not retros — in docs it is orphaned from the thing it justifies.

Behavioral evolution goes in docs — spec, ticket, and retro material. Comments are not the place to write project history; they explain the shape of the code in front of the reader.

## Anti-patterns

- **Implementation prescription in ticket Goals or Acceptance criteria.** Reframe as the behavior the change should produce, or drop the line if no behavior changes.
- **Code-shape rationale in tickets, specs, or retros.** Belongs in comments — it rots away from the code that needs it.
- **Implementation noise in `## Deviations`.** If the seam didn't move and observable behavior didn't change, it isn't a deviation.
- **Behavioral history buried in code comments.** Doc material, not comment material.
- **Treating the deviation threshold as a do/don't gate.** The threshold gates documentation, not worth. Do the change; skip the entry.
