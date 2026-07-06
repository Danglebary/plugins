---
name: to-tickets
description: Break a drafting PRD into dependency-ordered vertical-slice tickets in the store. Validates the dependency graph is acyclic. Proposes the ticket list to the user before writing, then flips PRD Drafting → Open and marks it active. One-shot per PRD. Use when the user wants to break a PRD into actionable tickets.
---

# To tickets

Take a `Drafting` PRD and break it into vertical-slice tickets. **One-shot per PRD**: refuses on `Open` or `Done` PRDs (frozen-scope principle).

Resolve the store first — see [STORE.md](../../_shared/STORE.md). Format references: [TICKET-FORMAT.md](../../_shared/TICKET-FORMAT.md), [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md) (ticket voice).

## State contract

- **PRD state required**: `Drafting`
- **Ticket state required**: n/a
- **Transition**: PRD `Drafting → Open`; marks this PRD active (files: writes the slug to `docs/prds/.active`; notion: clears any other row's `Active` first, then sets this one — single-active discipline per STORE.md)

Refuses on `Open` (frozen scope — adding tickets violates lock; do new work as a new PRD or by manually creating a ticket) and `Done` (closed chapter).

## Process

1. **Identify the PRD.** If the user hasn't specified, ask. Default to the most recent `Drafting` PRD if there's an obvious one. Refuse if the PRD's status isn't `Drafting`.

2. **Read the PRD** and identify vertical slices. Each ticket should:
   - Deliver end-to-end behavior across whatever layers it touches.
   - Be small enough that an agent can implement it without further breakdown.
   - Be independently verifiable via observable acceptance criteria.
   - Read in **behavioral voice** (see ABSTRACTION-LEVELS-PRINCIPLE.md, linked above).

3. **Determine dependencies** between tickets. Ticket B depends on ticket A if B can't start until A is done — typically because B needs an interface, schema, or data structure A creates.

4. **Validate acyclicity in skill code** — neither store enforces it. Check the proposed dependency graph for cycles via topological sort or DFS. If a cycle is detected, refuse with a clear message: *"Dependency cycle: 003 → 004 → 003. Revise the graph and re-propose."*

5. **Number and slug.** PRD-scoped numbering starting at `001`. Abandoned tickets keep their numbers reserved, so include them (files: glob both `tickets/` and `tickets/_abandoned/` for the highest prefix; notion: include `Status = Abandoned` rows). Kebab-case slugs, descriptive but short. Numbers are immutable.

6. **Propose the ticket list to the user** with dependencies. Describe each ticket's Goal in one sentence. Wait for user confirmation or revision. **Don't write anything yet** — the proposal step is the user's chance to revise before the PRD locks.

7. **On user confirmation, write each ticket** (files: `docs/prds/<NNN>-<slug>/tickets/<NNN>-<slug>.md` with `status: open` and `depends_on: [...]` frontmatter; notion: a Tickets row with `Status = Open`, the `PRD` relation, and `Depends on` relations — if the tool can't self-reference rows created in the same batch, create the rows first, then set relations in a second pass). Body:
   - `## Goal` — required, one paragraph in behavioral voice.
   - `## Acceptance criteria` — required, checklist of observable conditions (each item is something a caller or user of the system could verify).
   - `## Implementation notes` — optional; omit the section header if there's nothing useful to say. Use this only for *load-bearing* implementation constraints (e.g. *"use the existing SessionStore"*, *"no new dependencies"*) — i.e. seam-level constraints surfacing as hints, not code-shape directives.
   - `## Deviations` — placeholder body: `_None yet._`.

8. **Record the branch link.** The PRD branch is `prd-<NNN>-<slug>`. Files: implicit — the PRD directory name already encodes it; nothing to write. Notion: write `Branch = prd-<NNN>-<slug>` and `Diff base = main` (or the repo default) on the PRD row — this is what `/done` and `/retro` read to find the git diff range; with directories gone, the link must be explicit.

9. **Flip the PRD status** from `Drafting` to `Open`.

10. **Mark this PRD active.** Files: write the PRD slug to `docs/prds/.active`. Notion: first clear any `Active = true` rows, then set this row's `Active` (clear-then-set — see STORE.md).

11. **Offer the PRD-branch bootstrap.** The planning artifacts exist but the git branch doesn't; offer: *"Cut the PRD branch (`prd-<NNN>-<slug>`) now?"* (In the files store the just-written planning docs are untracked — include committing prd.md + tickets/ as one planning commit on the new branch in the offer.) On accept, cut the branch from the default branch. On decline, `/next-ticket` falls back to its lazy branch creation. (Offered, not automatic — same convention as every other git mutation in this workflow.)

12. **Report** the final ticket list to the user. Recommend `/next-ticket` to start.

## PRD too big

If you'd produce more than ~10 tickets, the PRD is epic-sized. Stop and tell the user: *"This PRD would produce N tickets, which is too big. Split it into multiple PRDs first."*

## Anti-patterns

- **Don't write the implementation.** Tickets are specs of *behavior*, not code. *"Change this function call to use map instead of forEach"*, *"add an `if` check here"*, *"rename this to that"* — these are code-shape directives, not behavioral specs. If the choice is genuinely load-bearing (must use an existing module, must not add a dependency), surface it as a seam-level constraint in `## Implementation notes`. Otherwise leave implementation silent so the implementing agent can match the codebase as it actually exists.
- **Don't write tickets the implementing agent can't deviate from without "violating" them.** A ticket that prescribes implementation locks the agent into choices that may not fit how the library actually works or how the codebase is shaped — which produces poor code and noisy retros. Behavioral specs leave room for the right implementation to emerge.
- **Don't carry over PRD section text verbatim.** Each ticket is a focused slice; the PRD stays the parent.
- **Don't depend on tickets in other PRDs.** Tickets are PRD-scoped. Cross-PRD work means a new PRD.
- **Don't create the retro here.** `/done` creates it lazily on first append.
- **Don't write tickets before the user confirms the list.** The proposal step is essential — once written, the PRD locks and `/to-tickets` won't run again on this PRD.
- **Don't run on an `Open` PRD to "add a few more tickets."** That violates the frozen-scope principle. Either a new PRD or a manual ticket.
- **Don't leave two PRDs active.** Always clear the existing active before setting the new one.
