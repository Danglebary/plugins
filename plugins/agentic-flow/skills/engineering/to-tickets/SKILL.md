---
name: to-tickets
description: Break a drafting PRD into dependency-ordered vertical-slice tickets in the store. Validates the dependency graph is acyclic. Proposes the ticket list to the user before writing, then flips PRD Drafting → Open, marks it active, and ends at the gated PRD-branch bootstrap — the branch cut from the default branch plus the planning commit. Ticketing is serialized — refuses when another PRD is active or unmerged, or the session isn't on a clean default-branch checkout. Ticket creation is one-shot per PRD; the bootstrap re-offers until it lands. Use when the user wants to break a PRD into actionable tickets.
---

# To tickets

Take a `Drafting` PRD and break it into vertical-slice tickets, ending at the **PRD-branch bootstrap** that cuts `prd-<NNN>-<slug>` and lands the planning artifacts in git. **Ticket creation is one-shot per PRD** (frozen-scope principle) — but the bootstrap is **re-enterable until it succeeds**: an `Open` PRD with tickets whose bootstrap hasn't fully landed re-offers only the missing pieces (see Bootstrap re-entry).

Store artifact paths: [STORE.md](../../_shared/STORE.md). Format references: [TICKET-FORMAT.md](../../_shared/TICKET-FORMAT.md), [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md) (ticket voice).

## State contract

- **PRD state required**: `Drafting`; or `Open` with tickets whose bootstrap hasn't fully landed — the bootstrap re-entry arm, which re-offers only the missing pieces and nothing else
- **Ticket state required**: n/a
- **Transition**: PRD `Drafting → Open`; marks this PRD active (writes the PRD directory name — `<NNN>-<slug>` — to `docs/prds/.active`); ends at the gated bootstrap — cut `prd-<NNN>-<slug>` from the resolved default branch, plus the planning commit

**The bootstrap has landed** when the branch `prd-<NNN>-<slug>` exists (local or remote) *and* its follow-through did too — the planning commit is on the branch. (The landed test — inline copy of STORE.md's branch-link state tests, cited per ADR-0002.) The discriminator checks the follow-through, not just the cut — a crash between them must route to re-entry, not refusal.

Refuses on `Open` with tickets and a landed bootstrap (frozen scope — adding tickets violates lock; do new work as a new PRD or by manually creating a ticket) and on `Done` (closed chapter).

## Serialize-ticketing preconditions

Ticketing is serialized; drafting is not. `/to-prd` and `/grill-me` stay runnable from any checkout — a draft PRD is untracked and survives branch switches. `/to-tickets`' ending is the serialization point; it requires all three of:

1. **No other PRD is active.** The active pointer is absent or already names this PRD. On refusal: finish the active PRD (`/retro`), or deliberately clear/repoint the pointer if context-switching.
2. **No unmerged `prd-*` branch**, local or remote — none whose tip isn't an ancestor of the resolved default branch (the unmerged test — inline copy of STORE.md's branch-link state tests, cited per ADR-0002; this precondition is a sweep, so it enumerates and filters per that section's enumeration rule, observing live per its gating tier). (In the re-entry arm, this PRD's own half-landed branch is exempt — it is the branch being resumed.) On refusal: land it (`/retro` re-offers the merge for a `Done`-but-unmerged PRD), or abandon that PRD per STORE.md's abandoning row — the `_abandoned/` relocation commits on its branch and merges in preserved form. Never a bare branch delete: the branch carries the PRD's planning artifacts.
3. **The session is on a clean checkout of the default branch**, resolved per [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md)'s default-branch procedure — never a guess, never a fallback to the current branch. *Clean* means no tracked modifications outside the store-artifact paths (`docs/prds/**`, `docs/adr/**`, `docs/spikes/**`, `docs/reviewers.md`, `CONTEXT.md` — STORE.md's artifact map): grill-minted Glossary/ADR edits are legitimate planning dirt the bootstrap will commit; implementation dirt refuses. On refusal: commit or stash the implementation modifications first, *then* switch to the default branch — switching first carries the dirt with you.

Verify these when the PRD is identified — failing fast beats a proposal conversation that cannot land — and re-verify at the bootstrap, since a long proposal conversation can stale the first check. A refusal names **every** failing precondition and its instructions at once — they commonly fail together (an active PRD usually also has an unmerged branch), and reporting one per round-trip walks the user through serial refusals. There is no partial proceed.

## Process

1. **Identify the PRD.** If the user hasn't specified, ask. Default to the most recent `Drafting` PRD if there's an obvious one. If the PRD is `Open` with tickets, check whether the bootstrap has landed (see State contract): any missing piece — no branch, or a branch without its planning commit — routes to **Bootstrap re-entry** (below); fully landed refuses (frozen scope). Otherwise refuse if the PRD's status isn't `Drafting`. For a `Drafting` PRD, also re-verify its number while renumbering is still cheap: the `<NNN>` must be unique across the planning directories and `prd-<NNN>-*` branch names (the branch-aware scan of `/to-prd` step 1, observed live here — an offline-minted number can collide with a PRD in flight elsewhere, and a locked number is immutable). On collision, renumber the `Drafting` PRD before proceeding.

2. **Verify the serialize-ticketing preconditions** (above). Refuse with the matching instructions if any fail.

3. **Read the PRD** and identify vertical slices. Each ticket should:
   - Deliver end-to-end behavior across whatever layers it touches.
   - Be small enough that an agent can implement it without further breakdown.
   - Be independently verifiable via observable acceptance criteria.
   - Read in **behavioral voice** (see ABSTRACTION-LEVELS-PRINCIPLE.md, linked above).

4. **Determine dependencies** between tickets. Ticket B depends on ticket A if B can't start until A is done — typically because B needs an interface, schema, or data structure A creates.

5. **Validate acyclicity in skill code** — the store doesn't enforce it. Check the proposed dependency graph for cycles via topological sort or DFS. If a cycle is detected, refuse with a clear message: *"Dependency cycle: 003 → 004 → 003. Revise the graph and re-propose."*

6. **Number and slug.** PRD-scoped numbering starting at `001`. Abandoned tickets keep their numbers reserved, so include them (glob both `tickets/` and `tickets/_abandoned/` for the highest prefix). Kebab-case slugs, descriptive but short. Numbers are immutable.

7. **Propose the ticket list to the user** with dependencies. Describe each ticket's Goal in one sentence. Wait for user confirmation or revision. **Don't write anything yet** — the proposal step is the user's chance to revise before the PRD locks.

8. **On user confirmation, write each ticket** (`docs/prds/<NNN>-<slug>/tickets/<NNN>-<slug>.md` with `status: open` and `depends_on: [...]` frontmatter). Body:
   - `## Goal` — required, one paragraph in behavioral voice.
   - `## Acceptance criteria` — required, checklist of observable conditions (each item is something a caller or user of the system could verify).
   - `## Implementation notes` — optional; omit the section header if there's nothing useful to say. Use this only for *load-bearing* implementation constraints (e.g. *"use the existing SessionStore"*, *"no new dependencies"*) — i.e. seam-level constraints surfacing as hints, not code-shape directives.
   - `## Deviations` — placeholder body: `_None yet._`.

9. **Flip the PRD status** from `Drafting` to `Open`.

10. **Mark this PRD active.** Write the PRD directory name (`<NNN>-<slug>`) to `docs/prds/.active`.

11. **Offer the PRD-branch bootstrap (gated).** Re-verify the serialize-ticketing preconditions, then run the gated store commit per [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md) — enumeration, named paths in the offer, paths-only staging, unanswered-offer-blocks, show-content-on-resume all come from there. The bootstrap's bindings:
    - **The edit set** (authorship-scoped per the convention): *this PRD's* planning artifacts only — its directory (`prd.md`, `tickets/`), the active pointer, and grill-minted Glossary/ADR edits from this PRD's planning — enumerated from `git status` over the store-artifact paths (`docs/prds/**`, `docs/adr/**`, `docs/spikes/**`, `docs/reviewers.md`, `CONTEXT.md` — STORE.md's artifact map) **including untracked files**. A store-path entry this planning run didn't author — another PRD's draft, a banked idea — is excluded and named, never silently swept.
    - **The offer** — one spelling, so re-entry re-runs it verbatim: *"Cut `prd-<NNN>-<slug>` from `<default branch>` and commit the planning artifacts (`<paths>`) as its first commit?"*
    - **On accept**: cut `prd-<NNN>-<slug>` at the resolved default branch's HEAD (precondition 3 already put the session on it), then stage the enumerated paths and commit — the planning artifacts land as the branch's first commit.
    - **On decline**: state the stakes loudly: *the PRD, its tickets, the active pointer, and any grill-minted Glossary/ADR edits are untracked (or uncommitted) and ride only the working tree until the bootstrap commit lands — nothing in git protects them.* Re-invoking `/to-tickets` on this PRD re-offers the bootstrap and nothing else.

12. **Report — forked on the bootstrap outcome.** Accepted: confirm what landed (the branch name and the planning commit), report the final ticket list, and recommend `/next-ticket` to start. Declined: report the ticket list, but recommend only re-invoking `/to-tickets` to re-offer the bootstrap — per step 11's own stakes, ticket work can't start without the branch; recommending `/next-ticket` here would contradict them. An accepted re-entry ends the same way as an accepted bootstrap, minus the ticket-list report.

## Bootstrap re-entry

An `Open` PRD with tickets whose bootstrap hasn't fully landed (see State contract) is, by construction, an interrupted or declined bootstrap. Re-invoking `/to-tickets` on it re-offers **only the missing pieces** — no re-ticketing, no re-proposal; ticket creation stays one-shot. Two states route here:

- **No `prd-<NNN>-<slug>` branch, local or remote** — declined, or crashed before the cut. Verify the serialize-ticketing preconditions, idempotently repair the pre-bootstrap edits if the interruption swallowed one (the `Open` flip is present by construction — it is the discriminator; rewrite the active pointer if it's missing), then run step 11's offer in full.
- **Branch exists, planning commit absent from it** — crashed between cut and commit. Preconditions 1 and 3 apply; precondition 2 exempts this PRD's own branch. Switch to the PRD branch (the untracked planning artifacts ride the switch), then run step 11's commit half only — and because this session didn't author the edits, CLOSE-OUT.md's show-content rule applies: show the enumerated paths' content with the offer, not just their names.

## PRD too big

If you'd produce more than ~10 tickets, the PRD is epic-sized. Stop and tell the user: *"This PRD would produce N tickets, which is too big. Split it into multiple PRDs first."*

## Anti-patterns

- **Don't write the implementation.** Tickets are specs of *behavior*, not code. *"Change this function call to use map instead of forEach"*, *"add an `if` check here"*, *"rename this to that"* — these are code-shape directives, not behavioral specs. If the choice is genuinely load-bearing (must use an existing module, must not add a dependency), surface it as a seam-level constraint in `## Implementation notes`. Otherwise leave implementation silent so the implementing agent can match the codebase as it actually exists.
- **Don't write tickets the implementing agent can't deviate from without "violating" them.** A ticket that prescribes implementation locks the agent into choices that may not fit how the library actually works or how the codebase is shaped — which produces poor code and noisy retros. Behavioral specs leave room for the right implementation to emerge.
- **Don't carry over PRD section text verbatim.** Each ticket is a focused slice; the PRD stays the parent.
- **Don't depend on tickets in other PRDs.** Tickets are PRD-scoped. Cross-PRD work means a new PRD.
- **Don't create the retro here.** `/done` creates it lazily on first append.
- **Don't write tickets before the user confirms the list.** The proposal step is essential — once written, the PRD locks; re-invocation only ever re-offers the bootstrap, never re-ticketing.
- **Don't run on an `Open` PRD to "add a few more tickets."** That violates the frozen-scope principle. Either a new PRD or a manual ticket. The only sanctioned `Open`-PRD invocation is the bootstrap re-entry — tickets exist, the bootstrap didn't fully land.
- **Don't leave two PRDs active.** Always clear the existing active before setting the new one.
