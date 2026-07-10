---
name: to-prd
description: Synthesize the current conversation into a frozen PRD in the store (docs/prds/ file or Notion PRDs row) with status Drafting. Does not interview — just captures what's already been discussed. Also handles spikes and banked ideas. Use when the user wants to write up the current conversation as a PRD.
---

# To PRD

Take the current conversation context and synthesize it into a `Drafting` PRD. **Do NOT interview the user** — just synthesize what's already been discussed. Interviewing is `/grill-me`'s job.

Resolve the store first — see [STORE.md](../../_shared/STORE.md). Format reference: [PRD-FORMAT.md](../../_shared/PRD-FORMAT.md).

## State contract

- **PRD state required**: n/a (creates new)
- **Ticket state required**: n/a
- **Transition**: writes a new PRD with Status `Drafting`; the spike/idea path instead writes the banked file and (files store) ends with a gated offer to commit it on the current branch. Does **not** touch the active pointer — active represents what's actively being *implemented*, not what's being designed.

## Fit check — PRD-weight, spike-weight, or idea?

Before numbering anything, ask the fit question once: **"Is this PRD-weight work, a spike, or an idea to bank?"** Three vehicles, by readiness (see STORE.md's artifact map for where each lives per store):

- **PRD** — scoped buildable work with known goals. Gets a number, `Drafting` status, and the five-section body. The process below.
- **Spike** — an open question needing investigation, where the deliverable is *findings*, not behavior. Write a single findings artifact (files: `docs/spikes/<slug>.md`; notion: a PRDs row with `Kind = Spike`) and skip PRD ceremony entirely — no number, no tickets, no retro, no status lifecycle. (A spike that went through full PRD ceremony once burned ~20 turns of pure overhead.) If a spike's findings later justify building, *that* becomes a PRD.
- **Idea** — not ready to commit. Bank it un-numbered (files: `docs/prds/ideas/<slug>.md`; notion: a PRDs row with `Kind = Idea`). Numbers are assigned when an idea is promoted to a real PRD, never before. One paragraph to a page; enough to re-find the thought, no more.

When the conversation's shape makes the answer obvious, say which vehicle you're choosing and why rather than asking.

After writing a spike or idea (files store), offer to commit it: *"Commit the banked file (`<path>`) on the current branch?"* (Notion store: rows need no commit.)

## Process

1. **Determine the next PRD number.** Abandoned PRDs keep their numbers reserved, so include them: files — highest `<NNN>-` prefix across `docs/prds/` AND `docs/prds/_abandoned/` (the un-numbered `ideas/` tier doesn't participate); notion — max `Number` across `Kind = PRD` rows including `Abandoned`. Both stores: take the max against `prd-<NNN>-<slug>` branch names too, local and remote — a PRD in flight on its branch keeps its number reserved from any checkout. Enumerate, filter, and observe per [STORE.md](../../_shared/STORE.md)'s branch-link state tests (the enumeration rule; the remote-observation rule's advisory tier — a degraded view's staleness is said aloud, and the number is re-verified at `/to-tickets` before the PRD locks). Use `<N+1>`, three-digit zero-padded. PRD numbers are immutable (never reused).

2. **Pick a slug.** Kebab-case, descriptive, short (3–5 words). Should match the PRD topic — e.g. `add-user-authentication`, not `auth-stuff`. The slug is one component: it feeds the PRD directory name `<NNN>-<slug>` (files store) and the branch name `prd-<NNN>-<slug>` (both stores); notion: store the bare slug in the `Slug` property.

3. **Sketch the major modules** the PRD will touch. Look for opportunities to surface deep modules — small interfaces hiding complex behavior. These populate the **Modules touched** section.

4. **Write the PRD** with the five-section structure below. Files: `docs/prds/<NNN>-<slug>/prd.md` with `status: drafting` frontmatter. Notion: a PRDs row (`notion-create-pages`) with `Kind = PRD`, `Status = Drafting`, `Number`, `Slug`; leave `Active` unchecked and `Branch`/`Diff base` blank (set later by `/to-tickets`); the five sections go in the row body, headings byte-identical across PRDs so `/retro` can locate them. Use vocabulary from the Glossary. Respect any ADRs in the area you're touching.

5. **Do NOT create tickets or a retro.** Those are downstream skills' responsibilities (`/to-tickets`, `/done`).

6. **Status is `Drafting`, never `Open`.** The lock transition is `/to-tickets`'s job.

## PRD structure

```markdown
---
status: drafting
---

# <PRD title>

## Problem

What we're solving and why. Anchor in user-facing or business need where applicable; otherwise in the technical pain.

## Goals

What success looks like. Observable outcomes when the PRD is done.

## Non-goals

Explicit out-of-scope.

## Approach

High-level technical direction. PRD-local decisions live here. Cross-PRD decisions go to ADRs.

## Modules touched

Which parts of the codebase, using Glossary vocabulary.
```

(Notion: no frontmatter — properties carry it — and the title is the row's `Name`, not repeated as a body heading.)

## After writing

Suggest the user run `/grill-me` to refine the draft before `/to-tickets` locks it.

## Anti-patterns

- **Don't interview the user.** Synthesize from existing context only. If the conversation hasn't covered something the PRD needs, leave it out — `/grill-me` will surface the gap.
- **Don't include specific file paths or code snippets.** Modules-level granularity only. Specific paths go stale fast.
- **Don't write `Decisions`, `Open questions`, or `Next steps` sections.** See PRD-FORMAT.md anti-patterns.
- **Don't auto-invoke `/to-tickets`.** That's a separate user decision after grilling refines the PRD.
- **Don't number a spike or idea.** Numbers are for committed PRDs, assigned on promotion.
- **Don't set the active pointer.** `to-prd` designs; it never marks a PRD as the one being implemented.
