---
name: to-prd
description: Synthesize the current conversation into a frozen PRD row in the Notion PRDs database with Status Drafting. Does not interview — just captures what has already been discussed. Also handles spikes and banked ideas. Use when the user wants to write up the current conversation as a PRD.
---

# To PRD (Notion)

Take the current conversation and synthesize it into a `Drafting` PRD **row in the Notion PRDs database**. **Do NOT interview the user** — synthesize what's already been discussed. Interviewing is `/grill-me`'s job.

Resolve databases first — see [NOTION-RESOLVER.md](../../_shared/NOTION-RESOLVER.md). All three vehicles below are rows in the **PRDs** database, distinguished by `Kind`.

## State contract

- **PRD state required**: n/a (creates new)
- **Ticket state required**: n/a
- **Transition**: creates a PRDs row with `Status = Drafting`. Does **not** set the `Active` checkbox — Active represents what's actively being *implemented*, not designed.

## Fit check — PRD-weight, spike-weight, or idea?

Before assigning any number, ask once: **"Is this PRD-weight work, a spike, or an idea to bank?"** Three vehicles, by readiness — all rows in PRDs, differing by `Kind`:

- **PRD** (`Kind = PRD`) — scoped buildable work with known goals. Gets a `Number`, `Status = Drafting`, and the five-section body. The process below.
- **Spike** (`Kind = Spike`) — an open question needing investigation; the deliverable is *findings*, not behavior. Create the row, put findings in the body, and skip PRD ceremony entirely: no `Number`, no `Status`, no tickets, no retro. (A spike dragged through full PRD ceremony once burned ~20 turns of pure overhead.) If its findings later justify building, promote it.
- **Idea** (`Kind = Idea`) — not ready to commit. Create the row with one paragraph in the body, no `Number`. Numbers are assigned only on promotion to a PRD, never before.

When the conversation's shape makes the answer obvious, say which vehicle you're choosing and why rather than asking.

## Process (Kind = PRD)

1. **Assign the next Number.** Query the PRDs database for the max `Number` across `Kind = PRD` rows — **including `Status = Abandoned`**, so retired numbers stay reserved. Use max + 1. Numbers are immutable and never reused. (This replaces the file workflow's directory glob.)

2. **Pick a slug.** Kebab-case, descriptive, short (3–5 words), matching the topic — e.g. `add-user-authentication`, not `auth-stuff`. Store it in the `Slug` property; `/to-tickets` uses it to build the branch name `prd-NNN-slug`.

3. **Sketch the major modules** the PRD will touch. Look for deep modules — small interfaces hiding complex behavior. These populate the **Modules touched** section.

4. **Create the row** via `create-pages` into the PRDs data source, with properties `Name`, `Kind = PRD`, `Status = Drafting`, `Number`, `Slug`, and any `Tags`. Leave `Active` unchecked and `Branch`/`Diff base` blank (set later by `/to-tickets`). Write the five-section body as page **content** (see below). Use vocabulary from the Glossary database; respect relevant ADRs.

5. **Do NOT create tickets or a retro.** Those are `/to-tickets` and `/done`'s responsibilities.

6. **Status is `Drafting`, never `Open`.** The lock transition is `/to-tickets`'s job.

## PRD body (written as page content)

The MCP has no template-creation tool, so these five headings are written as content, not enforced by a Notion template. **Keep the headings byte-identical across PRDs** so `/retro` can locate each section by heading.

```markdown
## Problem
What we're solving and why. Anchor in user-facing or business need where applicable; otherwise the technical pain.

## Goals
Observable outcomes when the PRD is done.

## Non-goals
Explicit out-of-scope.

## Approach
High-level technical direction. PRD-local decisions live here; cross-PRD decisions go to the ADRs database.

## Modules touched
Which parts of the codebase, using Glossary vocabulary.
```

(The PRD title is the row's `Name` property — do not repeat it as a heading in the body.)

## After writing

Suggest the user run `/grill-me` to refine the draft before `/to-tickets` locks it.

## Anti-patterns

- **Don't interview the user.** Synthesize from existing context only. Gaps are `/grill-me`'s to surface.
- **Don't set the `Active` checkbox.** `to-prd` designs; it never marks a PRD as the one being implemented.
- **Don't assign a `Number` to a Spike or Idea.** Numbers are for committed PRDs, assigned on promotion.
- **Don't use `UNIQUE_ID` for the number.** It would auto-increment on every idea and spike; numbering is skill-managed (see resolver doc).
- **Don't include specific file paths or code snippets.** Modules-level granularity only — paths go stale fast.
- **Don't write `Decisions`, `Open questions`, or `Next steps` sections.** Decisions live in Approach or the ADRs database; forward-looking items belong in a later PRD.
- **Don't auto-invoke `/to-tickets`.** That's a separate user decision after grilling.
- **Don't repeat the title as a body heading.** The title is the `Name` property.
