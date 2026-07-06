---
name: to-tickets
description: Break a drafting PRD into dependency-ordered vertical-slice ticket rows in the Notion Tickets database. Validates the dependency graph is acyclic. Proposes the list before writing, then flips the PRD Status Drafting to Open and marks it Active. One-shot per PRD. Use when the user wants to break a PRD into actionable tickets.
---

# To tickets (Notion)

Take a `Drafting` PRD and break it into vertical-slice ticket rows in the **Tickets** database. **One-shot per PRD**: refuses on `Open` or `Done` PRDs (frozen-scope principle).

Resolve databases first — see [NOTION-RESOLVER.md](../../_shared/NOTION-RESOLVER.md). Ticket voice is behavioral, not code-shape (see the anti-patterns).

## State contract

- **PRD state required**: `Status = Drafting`, `Kind = PRD`
- **Ticket state required**: n/a
- **Transition**: PRD `Status` Drafting → Open; sets this PRD's `Active = true` (and clears any other row's `Active` — see single-active enforcement in the resolver doc)

Refuses on `Open` (frozen scope — new work is a new PRD or a manually-created ticket row) and `Done` (closed chapter).

## Process

1. **Identify the PRD.** If unspecified, default to the most recent `Drafting`/`Kind = PRD` row. Refuse if `Status` isn't `Drafting`.

2. **Read the PRD** (`notion-fetch` the row + body) and identify vertical slices. Each ticket should deliver end-to-end behavior, be small enough to implement without further breakdown, be independently verifiable via observable acceptance criteria, and read in **behavioral voice**.

3. **Determine dependencies.** Ticket B depends on A if B can't start until A is done — typically because B needs an interface, schema, or data structure A creates.

4. **Validate acyclicity in skill code.** Notion's relation won't enforce this. Run a topological sort / DFS over the proposed graph. On a cycle, refuse with a clear message: *"Dependency cycle: 003 → 004 → 003. Revise and re-propose."*

5. **Number and slug.** PRD-scoped ticket numbering starting at `001`. Query the Tickets database for existing tickets related to this PRD (including `Status = Abandoned`) and take the highest `Ticket ID`/number — numbers are immutable. Kebab-case slugs, short.

6. **Propose the ticket list to the user** with dependencies, each Goal in one sentence. **Don't write rows yet** — this is the user's chance to revise before the PRD locks.

7. **On confirmation, create each ticket row** (`create-pages` into the Tickets data source) with properties `Name`, `Status = Open`, `PRD` (relation to this PRD row), `Depends on` (relation to prerequisite ticket rows; empty if none). Write the body as:
   - `## Goal` — one paragraph, behavioral voice.
   - `## Acceptance criteria` — checklist of observable conditions a caller/user could verify.
   - `## Implementation notes` — optional; omit if nothing useful. Only *load-bearing* seam constraints (e.g. "use the existing SessionStore", "no new dependencies") — not code-shape directives.
   - `## Deviations` — placeholder: `_None yet._`

   Depends-on relations reference rows that may be created in the same batch; if the tool can't self-reference within one call, create the rows first, then a second pass sets the `Depends on` relations.

8. **Set the branch link.** Write `Branch = prd-<NNN>-<slug>` on the PRD row (from its `Number` and `Slug`) and `Diff base = main` (or the repo default). This is what `/done` and `/retro` read to find the git diff range — with directories gone, the branch link must be explicit.

9. **Flip the PRD** `Status` Drafting → Open (`update-page`).

10. **Mark this PRD Active.** First query PRDs for any `Active = true` rows and clear them, then set this row's `Active = true` (single-active enforcement — clear before set; see resolver doc).

11. **Offer the PRD-branch bootstrap.** The Notion planning rows exist but the git branch doesn't: *"Cut the PRD branch (`prd-<NNN>-<slug>`) now?"* On accept, cut it from the default branch. On decline, `/next-ticket` falls back to lazy branch creation. Offered, not automatic.

12. **Report** the final ticket list. Recommend `/next-ticket` to start.

## PRD too big

If you'd produce more than ~10 tickets, the PRD is epic-sized. Stop: *"This PRD would produce N tickets — too big. Split it into multiple PRDs first."*

## Anti-patterns

- **Don't write the implementation.** Tickets specify *behavior*, not code. "Change forEach to map", "add an if here", "rename X to Y" are code-shape directives. Load-bearing seam constraints go in `## Implementation notes`; otherwise leave implementation silent so it can match the codebase as it actually is.
- **Don't write tickets the implementing agent can't deviate from without "violating" them.** Prescribed implementation locks in choices that may not fit; behavioral specs leave room for the right implementation to emerge.
- **Don't carry over PRD section text verbatim.** Each ticket is a focused slice; the PRD row stays the parent.
- **Don't set `Depends on` across PRDs.** Tickets are PRD-scoped. Cross-PRD work is a new PRD.
- **Don't create a retro here.** `/done` creates it lazily on first append.
- **Don't write rows before the user confirms the list.** Once written, the PRD locks and this skill won't run again on it.
- **Don't run on an `Open` PRD to "add a few more tickets."** Violates frozen scope — new PRD or a manual ticket row.
- **Don't set two PRDs `Active`.** Always clear existing actives before setting the new one.
