---
name: to-prd
description: Synthesize the current conversation into a frozen PRD document at docs/prds/<NNN>-<slug>/prd.md with status drafting. Does not interview — just captures what's already been discussed. Use when the user wants to write up the current conversation as a PRD.
---

# To PRD

Take the current conversation context and synthesize it into a `drafting` PRD document. **Do NOT interview the user** — just synthesize what's already been discussed. Interviewing is `/grill-me`'s job.

Format reference: [PRD-FORMAT.md](../../_shared/PRD-FORMAT.md).

## State contract

- **PRD state required**: n/a (creates new)
- **Ticket state required**: n/a
- **Transition**: writes new PRD as `status: drafting`. Does **not** touch `docs/prds/.active` — that pointer represents what's actively being implemented, not what's being designed.

## Process

1. **Determine the next PRD number.** Look in `docs/prds/` AND `docs/prds/_abandoned/` for the highest existing `<NNN>-` prefix. Use `<NNN+1>`, three-digit zero-padded. PRD numbers are immutable (never reused).

2. **Pick a slug.** Kebab-case, descriptive, short (3–5 words). Should match the PRD topic — e.g. `add-user-authentication`, not `auth-stuff`.

3. **Sketch the major modules** the PRD will touch. Look for opportunities to surface deep modules — small interfaces hiding complex behavior. These populate the **Modules touched** section.

4. **Write the PRD** at `docs/prds/<NNN>-<slug>/prd.md` using the structure below. Use vocabulary from `CONTEXT.md`. Respect any ADRs in the area you're touching.

5. **Do NOT create `tickets/` or `retro.md`.** Those are downstream skills' responsibilities (`/to-tickets`, `/done`).

6. **Set status to `drafting`.** Never `open` — the lock transition is `/to-tickets`'s job.

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

Which parts of the codebase, using CONTEXT.md vocabulary.
```

## After writing

Suggest the user run `/grill-me` to refine the draft before `/to-tickets` locks it.

## Anti-patterns

- **Don't interview the user.** Synthesize from existing context only. If the conversation hasn't covered something the PRD needs, leave it out — `/grill-me` will surface the gap.
- **Don't include specific file paths or code snippets.** Modules-level granularity only. Specific paths go stale fast.
- **Don't write `Decisions`, `Open questions`, or `Next steps` sections.** See PRD-FORMAT.md anti-patterns.
- **Don't auto-invoke `/to-tickets`.** That's a separate user decision after grilling refines the PRD.
