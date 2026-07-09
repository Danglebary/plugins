---
name: to-tickets
description: Break a drafting PRD into dependency-ordered vertical-slice tickets in the store. Validates the dependency graph is acyclic. Proposes the ticket list to the user before writing, then flips PRD Drafting → Open, marks it active, and ends at the gated PRD-branch bootstrap — the branch cut from the default branch plus (files store) the planning commit. Ticketing is serialized — refuses when another PRD is active or unmerged, or the session isn't on a clean default-branch checkout. Ticket creation is one-shot per PRD; the bootstrap re-offers until it lands. Use when the user wants to break a PRD into actionable tickets.
---

# To tickets

Take a `Drafting` PRD and break it into vertical-slice tickets, ending at the **PRD-branch bootstrap** that cuts `prd-<NNN>-<slug>` and lands the planning artifacts in git. **Ticket creation is one-shot per PRD** (frozen-scope principle) — but the bootstrap is **re-enterable until it succeeds**: an `Open` PRD with tickets but no branch re-offers only the cut-plus-planning-commit (see Bootstrap re-entry).

Resolve the store first — see [STORE.md](../../_shared/STORE.md). Format references: [TICKET-FORMAT.md](../../_shared/TICKET-FORMAT.md), [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md) (ticket voice).

## State contract

- **PRD state required**: `Drafting`; or `Open` with tickets but no PRD branch — the bootstrap re-entry arm, which re-offers the bootstrap and nothing else
- **Ticket state required**: n/a
- **Transition**: PRD `Drafting → Open`; marks this PRD active (files: writes the PRD directory name — `<NNN>-<slug>` — to `docs/prds/.active`; notion: clears any other row's `Active` first, then sets this one — single-active discipline per STORE.md); ends at the gated bootstrap — cut `prd-<NNN>-<slug>` from the resolved default branch, plus the planning commit (files) / the `Branch` + `Diff base` property writes (notion)

Refuses on `Open` with tickets and an existing PRD branch (frozen scope — adding tickets violates lock; do new work as a new PRD or by manually creating a ticket) and on `Done` (closed chapter).

## Serialize-ticketing preconditions

Ticketing is serialized; drafting is not. `/to-prd` and `/grill-me` stay runnable from any checkout — a draft PRD is untracked and survives branch switches. `/to-tickets`' ending is the serialization point; it requires all three of:

1. **No other PRD is active.** The active pointer is absent or already names this PRD. On refusal: finish the active PRD (`/retro`), or deliberately clear/repoint the pointer if context-switching.
2. **No unmerged `prd-*` branch**, local or remote — none whose tip isn't an ancestor of the resolved default branch. On refusal: land it (`/retro` re-offers the merge for a `Done`-but-unmerged PRD) or abandon it.
3. **The session is on a clean checkout of the default branch**, resolved per [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md)'s default-branch procedure — never a guess, never a fallback to the current branch. *Clean* means no tracked modifications outside the store-artifact paths (the files-store column of STORE.md's artifact map): grill-minted Glossary/ADR edits are legitimate planning dirt the bootstrap will commit; implementation dirt refuses. On refusal: switch to the default branch, and commit or stash the implementation modifications.

Verify these when the PRD is identified — failing fast beats a proposal conversation that cannot land — and re-verify at the bootstrap, since a long proposal conversation can stale the first check. A refusal names the failing precondition and its instructions; there is no partial proceed.

## Process

1. **Identify the PRD.** If the user hasn't specified, ask. Default to the most recent `Drafting` PRD if there's an obvious one. If the PRD is `Open` with tickets but no `prd-<NNN>-<slug>` branch, route to **Bootstrap re-entry** (below). Otherwise refuse if the PRD's status isn't `Drafting`.

2. **Verify the serialize-ticketing preconditions** (above). Refuse with the matching instructions if any fail.

3. **Read the PRD** and identify vertical slices. Each ticket should:
   - Deliver end-to-end behavior across whatever layers it touches.
   - Be small enough that an agent can implement it without further breakdown.
   - Be independently verifiable via observable acceptance criteria.
   - Read in **behavioral voice** (see ABSTRACTION-LEVELS-PRINCIPLE.md, linked above).

4. **Determine dependencies** between tickets. Ticket B depends on ticket A if B can't start until A is done — typically because B needs an interface, schema, or data structure A creates.

5. **Validate acyclicity in skill code** — neither store enforces it. Check the proposed dependency graph for cycles via topological sort or DFS. If a cycle is detected, refuse with a clear message: *"Dependency cycle: 003 → 004 → 003. Revise the graph and re-propose."*

6. **Number and slug.** PRD-scoped numbering starting at `001`. Abandoned tickets keep their numbers reserved, so include them (files: glob both `tickets/` and `tickets/_abandoned/` for the highest prefix; notion: include `Status = Abandoned` rows). Kebab-case slugs, descriptive but short. Numbers are immutable.

7. **Propose the ticket list to the user** with dependencies. Describe each ticket's Goal in one sentence. Wait for user confirmation or revision. **Don't write anything yet** — the proposal step is the user's chance to revise before the PRD locks.

8. **On user confirmation, write each ticket** (files: `docs/prds/<NNN>-<slug>/tickets/<NNN>-<slug>.md` with `status: open` and `depends_on: [...]` frontmatter; notion: a Tickets row with `Status = Open`, the `PRD` relation, and `Depends on` relations — if the tool can't self-reference rows created in the same batch, create the rows first, then set relations in a second pass). Body:
   - `## Goal` — required, one paragraph in behavioral voice.
   - `## Acceptance criteria` — required, checklist of observable conditions (each item is something a caller or user of the system could verify).
   - `## Implementation notes` — optional; omit the section header if there's nothing useful to say. Use this only for *load-bearing* implementation constraints (e.g. *"use the existing SessionStore"*, *"no new dependencies"*) — i.e. seam-level constraints surfacing as hints, not code-shape directives.
   - `## Deviations` — placeholder body: `_None yet._`.

9. **Flip the PRD status** from `Drafting` to `Open`.

10. **Mark this PRD active.** Files: write the PRD directory name (`<NNN>-<slug>`) to `docs/prds/.active`. Notion: first clear any `Active = true` rows, then set this row's `Active` (clear-then-set — see STORE.md).

11. **Offer the PRD-branch bootstrap (gated).** Re-verify the serialize-ticketing preconditions, then offer: *"Cut `prd-<NNN>-<slug>` from `<default branch>` and land the planning artifacts?"* An unanswered offer blocks — it is never consent (same gate discipline as [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md)).
    - **On accept**: cut `prd-<NNN>-<slug>` at the resolved default branch's HEAD (precondition 3 already put the session on it). Then, **files store**: commit all planning artifacts as the branch's first commit — enumerate from `git status` over the store-artifact paths **including untracked files** (the PRD directory with `prd.md` and `tickets/`, the active pointer, grill-minted Glossary/ADR edits), staging the enumerated paths explicitly, never `-A` (CLOSE-OUT.md owns this staging discipline). **Notion store**: no commit — write `Branch = prd-<NNN>-<slug>` and `Diff base` (the resolved default branch) on the PRD row; `/done` and `/retro` read these to find the git diff range.
    - **On decline**: state the stakes loudly. Files store: *the PRD, its tickets, the active pointer, and any grill-minted Glossary/ADR edits are untracked (or uncommitted) and ride only the working tree until the bootstrap commit lands — nothing in git protects them.* Both stores: no PRD branch exists, so ticket work can't start; re-invoking `/to-tickets` on this PRD re-offers the bootstrap and nothing else.

12. **Report** the final ticket list to the user. Recommend `/next-ticket` to start.

## Bootstrap re-entry

An `Open` PRD with tickets but no `prd-<NNN>-<slug>` branch is, by construction, an interrupted or declined bootstrap. Re-invoking `/to-tickets` on it re-offers **only** the cut-plus-planning-commit — no re-ticketing, no re-proposal; ticket creation stays one-shot. Verify the serialize-ticketing preconditions, idempotently repair the pre-bootstrap edits if the interruption swallowed one (the `Open` flip is present by construction — it is the discriminator; rewrite the active pointer if it's missing), then run step 11's offer verbatim. Notion: the re-offer is the cut plus the `Branch`/`Diff base` writes, idempotent if they already landed.

## PRD too big

If you'd produce more than ~10 tickets, the PRD is epic-sized. Stop and tell the user: *"This PRD would produce N tickets, which is too big. Split it into multiple PRDs first."*

## Anti-patterns

- **Don't write the implementation.** Tickets are specs of *behavior*, not code. *"Change this function call to use map instead of forEach"*, *"add an `if` check here"*, *"rename this to that"* — these are code-shape directives, not behavioral specs. If the choice is genuinely load-bearing (must use an existing module, must not add a dependency), surface it as a seam-level constraint in `## Implementation notes`. Otherwise leave implementation silent so the implementing agent can match the codebase as it actually exists.
- **Don't write tickets the implementing agent can't deviate from without "violating" them.** A ticket that prescribes implementation locks the agent into choices that may not fit how the library actually works or how the codebase is shaped — which produces poor code and noisy retros. Behavioral specs leave room for the right implementation to emerge.
- **Don't carry over PRD section text verbatim.** Each ticket is a focused slice; the PRD stays the parent.
- **Don't depend on tickets in other PRDs.** Tickets are PRD-scoped. Cross-PRD work means a new PRD.
- **Don't create the retro here.** `/done` creates it lazily on first append.
- **Don't write tickets before the user confirms the list.** The proposal step is essential — once written, the PRD locks; re-invocation only ever re-offers the bootstrap, never re-ticketing.
- **Don't run on an `Open` PRD to "add a few more tickets."** That violates the frozen-scope principle. Either a new PRD or a manual ticket. The only sanctioned `Open`-PRD invocation is the bootstrap re-entry — tickets exist, the branch doesn't.
- **Don't leave two PRDs active.** Always clear the existing active before setting the new one.
