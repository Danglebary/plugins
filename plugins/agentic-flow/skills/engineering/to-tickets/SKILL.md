---
name: to-tickets
description: Break a drafting PRD into dependency-ordered vertical-slice tickets. Validates the dependency graph is acyclic. Proposes the ticket list to the user before writing, then flips PRD drafting → open and sets .active. One-shot per PRD. Use when the user wants to break a PRD into actionable tickets.
---

# To tickets

Take a `drafting` PRD and break it into vertical-slice tickets. **One-shot per PRD**: refuses on `open` or `done` PRDs (frozen-scope principle).

Format reference: [TICKET-FORMAT.md](../../_shared/TICKET-FORMAT.md).

## State contract

- **PRD state required**: `drafting`
- **Ticket state required**: n/a
- **Transition**: PRD `drafting → open`; sets `docs/prds/.active` to this PRD's slug

Refuses on `open` (frozen scope — adding tickets violates lock; do new work as a new PRD or by manually creating a ticket file) and `done` (closed chapter).

## Process

1. **Identify the PRD.** If the user hasn't specified, ask. Default to the most recent `drafting` PRD if there's an obvious one. Refuse if the PRD's status isn't `drafting`.

2. **Read the PRD** and identify vertical slices. Each ticket should:
   - Deliver end-to-end behavior across whatever layers it touches.
   - Be small enough that an agent can implement it without further breakdown.
   - Be independently verifiable via observable acceptance criteria.

3. **Determine dependencies** between tickets. Ticket B depends on ticket A if B can't start until A is done — typically because B needs an interface, schema, or data structure A creates.

4. **Validate acyclicity.** Check the proposed dependency graph for cycles via topological sort or DFS. If a cycle is detected, refuse with a clear message: *"Dependency cycle: 003 → 004 → 003. Revise the graph and re-propose."*

5. **Number and slug.** PRD-scoped numbering starting at `001`. Kebab-case slugs, descriptive but short. Globs both `tickets/` and `tickets/_abandoned/` when finding the highest existing prefix (numbers are immutable).

6. **Propose the ticket list to the user** with dependencies. Describe each ticket's Goal in one sentence. Wait for user confirmation or revision. **Don't write files yet** — the proposal step is the user's chance to revise before the PRD locks.

7. **On user confirmation, write each ticket** at `docs/prds/<NNN>-<slug>/tickets/<NNN>-<slug>.md` with:
   - Frontmatter: `status: open`, `depends_on: [<list>]` (empty `[]` if none).
   - `## Goal` — required, one paragraph.
   - `## Acceptance criteria` — required, checklist of observable conditions.
   - `## Implementation notes` — optional; omit the section header if there's nothing useful to say.
   - `## Deviations` — placeholder body: `_None yet._`.

8. **Flip the PRD status** from `drafting` to `open`.

9. **Set `.active`** by writing the PRD slug to `docs/prds/.active`.

10. **Report** the final ticket list to the user. Recommend `/next-ticket` to start.

## Vertical slice anti-patterns

- **"Set up routing"** — no behavior. Reframe: a route that delivers something specific.
- **"Add types"** — no behavior. Types are part of whatever ticket needs them.
- **"Wire up middleware"** — no behavior unless paired with a route that uses it. Combine with the route ticket.

A ticket should make the answer to "what new behavior does this give us?" obvious in one sentence.

## PRD too big

If you'd produce more than ~10 tickets, the PRD is epic-sized. Stop and tell the user: *"This PRD would produce N tickets, which is too big. Split it into multiple PRDs first."*

## Anti-patterns

- **Don't write the implementation.** Tickets are specs, not code.
- **Don't carry over PRD section text verbatim.** Each ticket is a focused slice; the PRD stays the parent.
- **Don't depend on tickets in other PRDs.** Tickets are PRD-scoped. Cross-PRD work means a new PRD.
- **Don't create `retro.md` here.** Lazy creation by `/done` on first append.
- **Don't write files before the user confirms the ticket list.** The proposal step is essential — once written, the PRD locks and `/to-tickets` won't run again on this PRD.
- **Don't run on an `open` PRD to "add a few more tickets."** That violates the frozen-scope principle. Either a new PRD or a manual ticket file.
