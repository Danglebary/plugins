---
name: to-tickets
description: Break a drafting PRD into dependency-ordered vertical-slice tickets. Validates the dependency graph is acyclic. Proposes the ticket list to the user before writing, then flips PRD drafting → open and sets .active. One-shot per PRD. Use when the user wants to break a PRD into actionable tickets.
---

# To tickets

Take a `drafting` PRD and break it into vertical-slice tickets. **One-shot per PRD**: refuses on `open` or `done` PRDs (frozen-scope principle).

Format references: [TICKET-FORMAT.md](../../_shared/TICKET-FORMAT.md), [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md) (ticket voice).

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
   - Read in **behavioral voice** (see ABSTRACTION-LEVELS-PRINCIPLE.md, linked above).

3. **Determine dependencies** between tickets. Ticket B depends on ticket A if B can't start until A is done — typically because B needs an interface, schema, or data structure A creates.

4. **Validate acyclicity.** Check the proposed dependency graph for cycles via topological sort or DFS. If a cycle is detected, refuse with a clear message: *"Dependency cycle: 003 → 004 → 003. Revise the graph and re-propose."*

5. **Number and slug.** PRD-scoped numbering starting at `001`. Kebab-case slugs, descriptive but short. Globs both `tickets/` and `tickets/_abandoned/` when finding the highest existing prefix (numbers are immutable).

6. **Propose the ticket list to the user** with dependencies. Describe each ticket's Goal in one sentence. Wait for user confirmation or revision. **Don't write files yet** — the proposal step is the user's chance to revise before the PRD locks.

7. **On user confirmation, write each ticket** at `docs/prds/<NNN>-<slug>/tickets/<NNN>-<slug>.md` with:
   - Frontmatter: `status: open`, `depends_on: [<list>]` (empty `[]` if none).
   - `## Goal` — required, one paragraph in behavioral voice.
   - `## Acceptance criteria` — required, checklist of observable conditions (each item is something a caller or user of the system could verify).
   - `## Implementation notes` — optional; omit the section header if there's nothing useful to say. Use this only for *load-bearing* implementation constraints (e.g. *"use the existing SessionStore"*, *"no new dependencies"*) — i.e. seam-level constraints surfacing as hints, not code-shape directives.
   - `## Deviations` — placeholder body: `_None yet._`.

8. **Flip the PRD status** from `drafting` to `open`.

9. **Set `.active`** by writing the PRD slug to `docs/prds/.active`.

10. **Report** the final ticket list to the user. Recommend `/next-ticket` to start.

## PRD too big

If you'd produce more than ~10 tickets, the PRD is epic-sized. Stop and tell the user: *"This PRD would produce N tickets, which is too big. Split it into multiple PRDs first."*

## Anti-patterns

- **Don't write the implementation.** Tickets are specs of *behavior*, not code. *"Change this function call to use map instead of forEach"*, *"add an `if` check here"*, *"rename this to that"* — these are code-shape directives, not behavioral specs. If the choice is genuinely load-bearing (must use an existing module, must not add a dependency), surface it as a seam-level constraint in `## Implementation notes`. Otherwise leave implementation silent so the implementing agent can match the codebase as it actually exists.
- **Don't write tickets the implementing agent can't deviate from without "violating" them.** A ticket that prescribes implementation locks the agent into choices that may not fit how the library actually works or how the codebase is shaped — which produces poor code and noisy retros. Behavioral specs leave room for the right implementation to emerge.
- **Don't carry over PRD section text verbatim.** Each ticket is a focused slice; the PRD stays the parent.
- **Don't depend on tickets in other PRDs.** Tickets are PRD-scoped. Cross-PRD work means a new PRD.
- **Don't create `retro.md` here.** `/done` creates it lazily on first append.
- **Don't write files before the user confirms the ticket list.** The proposal step is essential — once written, the PRD locks and `/to-tickets` won't run again on this PRD.
- **Don't run on an `open` PRD to "add a few more tickets."** That violates the frozen-scope principle. Either a new PRD or a manual ticket file.
