---
name: to-tickets
description: Break a drafting spec into dependency-ordered vertical-slice tickets, validating acyclicity; serialized, ending at the gated spec-branch bootstrap. Use when breaking a spec into tickets.
---

# To tickets

Take a `Drafting` spec and break it into vertical-slice tickets, ending at the **spec-branch bootstrap** (see State contract). **Ticket creation is one-shot per spec** (frozen-scope principle) — but the bootstrap is **re-enterable until it succeeds**, re-offering only the missing pieces (see Bootstrap re-entry).

Store artifact paths: [STORE.md](../../_shared/STORE.md). Format references: [TICKET-FORMAT.md](../../_shared/TICKET-FORMAT.md), [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md) (ticket voice).

## State contract

- **Spec state required**: `Drafting`; or `Open` with tickets whose bootstrap hasn't fully landed — the bootstrap re-entry arm, which re-offers only the missing pieces and nothing else
- **Ticket state required**: n/a
- **Transition**: spec `Drafting → Open`; marks this spec active (writes the spec directory name — `<NNN>-<slug>` — to `docs/specs/.active`); ends at the gated bootstrap — cut `spec-<NNN>-<slug>` from the resolved default branch, plus the planning commit

**The bootstrap has landed** when the linked branch — `spec-<NNN>-<slug>`, or its legacy `prd-` twin per STORE.md's branch-link fallback — exists (local or remote) *and* its follow-through did too — the planning commit is on the branch. (The landed test — inline copy of STORE.md's branch-link state tests, kept inline per its placement test.) The discriminator checks the follow-through, not just the cut — a crash between them must route to re-entry, not refusal.

Refuses on `Open` with tickets and a landed bootstrap (frozen scope — adding tickets violates lock; do new work as a new spec or by manually creating a ticket) and on `Done` (closed chapter).

## Serialize-ticketing preconditions

Ticketing is serialized; drafting is not — `/to-spec` and `/grill-me` stay runnable from any checkout (a draft spec is untracked, surviving branch switches). `/to-tickets`' ending is the serialization point; it requires all three:

1. **No other spec is active.** The active pointer is absent or already names this spec. On refusal: finish the active spec (`/retro`), or deliberately clear/repoint the pointer if context-switching.
2. **No unmerged spec branch** — none (`spec-*` or legacy `prd-*`) whose tip (local or remote) is not an ancestor of the resolved default branch. This precondition is a sweep: enumerate and filter both patterns per STORE.md's branch-link enumeration rule, observing live. In the re-entry arm, this spec's own half-landed branch is exempt (the branch being resumed). On refusal: land it (`/retro` re-offers the merge for a `Done`-but-unmerged spec), or abandon that spec per [SPEC-FORMAT.md](../../_shared/SPEC-FORMAT.md)'s "Abandoned specs" recipe — never a bare branch delete: the branch carries the spec's planning artifacts.
3. **The session is on a clean checkout of the default branch**, resolved per [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md)'s default-branch procedure — never a guess, never a fallback to the current branch. *Clean* means no tracked modifications outside the store-artifact paths (`docs/specs/**`, `docs/adr/**`, `docs/spikes/**`, `docs/reviewers.md`, `CONTEXT.md`, `.agentic-flow/settings.toml` — STORE.md's artifact map): grill-minted Glossary/ADR edits are legitimate planning dirt the bootstrap will commit; implementation dirt refuses. On refusal: commit or stash implementation modifications first, *then* switch to the default branch — switching first carries the dirt.

Verify these when the spec is identified (fail fast beats a proposal that cannot land) and re-verify at the bootstrap, since a long proposal can stale the first check. A refusal names **every** failing precondition and its instructions at once — they commonly fail together, and reporting one per round-trip means serial refusals. There is no partial proceed.

## Process

1. **Identify the spec.** If the user hasn't specified, ask; default to the most recent `Drafting` spec if there's an obvious one. If the spec is `Open` with tickets, check whether the bootstrap has landed (see State contract): any missing piece — no branch, or a branch without its planning commit — routes to **Bootstrap re-entry** (below); fully landed refuses (frozen scope). Otherwise refuse if the spec's status isn't `Drafting`. For a `Drafting` spec, re-verify its number: the `<NNN>` must be unique across the planning directories and `spec-<NNN>-*` plus legacy `prd-<NNN>-*` branch names, observed live. On collision, renumber the `Drafting` spec before proceeding.

2. **Verify the serialize-ticketing preconditions** (above). Refuse with the matching instructions if any fail.

3. **Read the spec** and identify vertical slices. Each ticket should:
   - Deliver end-to-end behavior across whatever layers it touches.
   - Small enough for an agent to implement without further breakdown.
   - Be independently verifiable via observable acceptance criteria.
   - Read in **behavioral voice** (see ABSTRACTION-LEVELS-PRINCIPLE.md).

4. **Determine dependencies** between tickets. Ticket B depends on A if B can't start until A is done — B needs an interface, schema, or data structure A creates.

5. **Validate acyclicity in skill code** — the store doesn't enforce it. Check the dependency graph for cycles via topological sort or DFS. If a cycle is detected, refuse with a clear message: *"Dependency cycle: 003 → 004 → 003. Revise the graph and re-propose."*

6. **Number and slug.** Spec-scoped numbering starting at `001`. Abandoned tickets keep their numbers reserved, so include them (glob both `tickets/` and `tickets/_abandoned/` for the highest prefix). Kebab-case slugs, descriptive but short. Numbers are immutable.

7. **Propose the ticket list to the user** with dependencies. Describe each ticket's Goal in one sentence. Wait for user confirmation or revision. **Don't write anything yet** — the proposal is the user's chance to revise before the spec locks.

8. **On user confirmation, write each ticket** (`docs/specs/<NNN>-<slug>/tickets/<NNN>-<slug>.md` with `status: open` and `depends_on: [...]` frontmatter). Body:
   - `## Goal` — required, one paragraph in behavioral voice.
   - `## Acceptance criteria` — required, checklist of observable conditions (each verifiable by a caller or user).
   - `## Implementation notes` — optional; omit the header if nothing useful to say. Use only for *load-bearing* implementation constraints (e.g. *"use the existing SessionStore"*, *"no new dependencies"*) — seam-level constraints surfacing as hints, not code-shape directives.
   - `## Deviations` — placeholder body: `_None yet._`.

9. **Flip the spec status** from `Drafting` to `Open`.

10. **Mark this spec active.** Write the spec directory name (`<NNN>-<slug>`) to `docs/specs/.active`.

11. **Offer the spec-branch bootstrap (gated).** Re-verify the serialize-ticketing preconditions, then run the gated store commit per [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md). The bootstrap's bindings:
    - **The edit set** (authorship-scoped): *this spec's* planning artifacts only — its directory (`spec.md`, `tickets/`), the active pointer, and this spec's grill-minted Glossary/ADR edits — enumerated from `git status` over the store-artifact paths (`docs/specs/**`, `docs/adr/**`, `docs/spikes/**`, `docs/reviewers.md`, `CONTEXT.md`, `.agentic-flow/settings.toml` — STORE.md's artifact map) **including untracked files**. A store-path entry this run didn't author (another spec's draft, a banked idea) is excluded and named, never silently swept.
    - **The offer** — one spelling, so re-entry re-runs it verbatim: *"Cut `spec-<NNN>-<slug>` from `<default branch>` and commit the planning artifacts (`<paths>`) as its first commit?"*
    - **On accept**: cut `spec-<NNN>-<slug>` at the resolved default branch's HEAD, then stage the enumerated paths and commit — the planning artifacts land as the branch's first commit.
    - **On decline**: state the stakes loudly: *the spec, its tickets, the active pointer, and any grill-minted Glossary/ADR edits ride only the working tree until the bootstrap commit lands — nothing in git protects them.* Re-invoking `/to-tickets` on this spec re-offers the bootstrap and nothing else.

12. **Report — forked on the bootstrap outcome.** Accepted: confirm what landed (branch name and planning commit), report the final ticket list, recommend `/next-ticket`. Declined: report the ticket list, but recommend only re-invoking `/to-tickets` to re-offer the bootstrap — ticket work can't start without the branch (per step 11's stakes), so recommending `/next-ticket` would contradict them. An accepted re-entry ends the same way as an accepted bootstrap, minus the ticket-list report.

## Bootstrap re-entry

An `Open` spec with tickets whose bootstrap hasn't fully landed (see State contract) routes here from step 1. The two-state walkthrough — no linked branch; branch without its planning commit — lives in [RECOVERY.md](../../_shared/RECOVERY.md#to-tickets-bootstrap-re-entry).

## Spec too big

If you'd produce more than ~10 tickets, the spec is epic-sized. Stop and tell the user: *"This spec would produce N tickets, which is too big. Split it into multiple specs first."*

## Anti-patterns

- **Don't write the implementation.** Tickets are specs of *behavior*, not code — *"change this call to use map instead of forEach"*, *"add an `if` check here"*, *"rename this to that"* are code-shape directives, not behavioral specs. If a choice is genuinely load-bearing (must use an existing module, must not add a dependency), surface it as a seam-level constraint in `## Implementation notes`; otherwise leave implementation silent so the agent can match the codebase as it actually exists.
- **Don't write tickets the implementing agent can't deviate from without "violating" them.** Prescribing implementation locks the agent into choices that may not fit the library or codebase — poor code and noisy retros. Behavioral specs leave room for the right implementation to emerge.
- **Don't carry over spec section text verbatim.** Each ticket is a focused slice; the spec stays the parent.
- **Don't depend on tickets in other specs.** Tickets are spec-scoped. Cross-spec work means a new spec.
- **Don't create the retro here.** `/done` creates it lazily on first append.
- **Don't write tickets before the user confirms the list.** Once written, the spec locks; re-invocation only ever re-offers the bootstrap, never re-ticketing.
- **Don't run on an `Open` spec to "add a few more tickets."** That violates the frozen-scope principle — use a new spec or a manual ticket. The only sanctioned `Open`-spec invocation is bootstrap re-entry (tickets exist, the bootstrap didn't fully land).
- **Don't leave two specs active.** Always clear the existing active before setting the new one.
