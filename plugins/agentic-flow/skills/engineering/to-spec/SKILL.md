---
name: to-spec
description: Synthesize the current conversation into a frozen spec in the store (a docs/specs/ file) with status Drafting. Does not interview — just captures what's already been discussed. Also handles spikes and banked ideas. Use when the user wants to write up the current conversation as a spec.
---

# To spec

Take the current conversation context and synthesize it into a `Drafting` spec. **Do NOT interview the user** — just synthesize what's already been discussed. Interviewing is `/grill-me`'s job.

Store artifact paths: [STORE.md](../../_shared/STORE.md). Format reference: [SPEC-FORMAT.md](../../_shared/SPEC-FORMAT.md).

## State contract

- **Spec state required**: n/a (creates new)
- **Ticket state required**: n/a
- **Transition**: writes a new spec with Status `Drafting`; the spike/idea path instead writes the banked file and ends with a gated offer to commit it on the current branch. Does **not** touch the active pointer — active represents what's actively being *implemented*, not what's being designed.

## Fit check — spec-weight, spike-weight, or idea?

Before numbering anything, ask the fit question once: **"Is this spec-weight work, a spike, or an idea to bank?"** Three vehicles, by readiness (see STORE.md's artifact map for where each lives):

- **Spec** — scoped buildable work with known goals. Gets a number, `Drafting` status, and the five-section body. The process below.
- **Spike** — an open question needing investigation, where the deliverable is *findings*, not behavior. Write a single findings artifact (`docs/spikes/<slug>.md`) and skip spec ceremony entirely — no number, no tickets, no retro, no status lifecycle. (A spike that went through full spec ceremony once burned ~20 turns of pure overhead.) If a spike's findings later justify building, *that* becomes a spec.
- **Idea** — not ready to commit. Bank it un-numbered (`docs/specs/ideas/<slug>.md`). Numbers are assigned when an idea is promoted to a real spec, never before. One paragraph to a page; enough to re-find the thought, no more.

When the conversation's shape makes the answer obvious, say which vehicle you're choosing and why rather than asking.

After writing a spike or idea, offer to commit it: *"Commit the banked file (`<path>`) on the current branch?"*

## Process

1. **Determine the next spec number.** Abandoned specs keep their numbers reserved, so include them: highest `<NNN>-` prefix across `docs/specs/` AND `docs/specs/_abandoned/` (the un-numbered `ideas/` tier doesn't participate). Take the max against `spec-<NNN>-<slug>` and legacy `prd-<NNN>-<slug>` branch names too, local and remote — a spec in flight on its branch keeps its number reserved from any checkout, and legacy branches reserve theirs through the transition. Enumerate, filter, and observe per [STORE.md](../../_shared/STORE.md)'s branch-link state tests (the enumeration rule; the remote-observation rule's advisory tier — a degraded view's staleness is said aloud, and the number is re-verified at `/to-tickets` before the spec locks). Use `<N+1>`, three-digit zero-padded. Spec numbers are immutable (never reused).

2. **Pick a slug.** Kebab-case, descriptive, short (3–5 words). Should match the spec topic — e.g. `add-user-authentication`, not `auth-stuff`. The slug is one component: it feeds the spec directory name `<NNN>-<slug>` and the branch name `spec-<NNN>-<slug>`.

3. **Read the named modules, then sketch them.** Before freezing **Modules touched**, read the modules the conversation names — at least their public surface — never freezing the section from conversation memory alone: an unread module list ships stale names and misses real seams. Look for opportunities to surface deep modules — small interfaces hiding complex behavior. These populate the **Modules touched** section.

4. **Write the spec** with the five-section structure below: `docs/specs/<NNN>-<slug>/spec.md` with `status: drafting` frontmatter. Use vocabulary from the Glossary. Respect any ADRs in the area you're touching.

5. **Do NOT create tickets or a retro.** Those are downstream skills' responsibilities (`/to-tickets`, `/done`).

6. **Status is `Drafting`, never `Open`.** The lock transition is `/to-tickets`'s job.

## Spec structure

```markdown
---
status: drafting
---

# <Spec title>

## Problem

What we're solving and why. Anchor in user-facing or business need where applicable; otherwise in the technical pain.

## Goals

What success looks like. Observable outcomes when the spec is done.

## Non-goals

Explicit out-of-scope.

## Approach

High-level technical direction. Spec-local decisions live here. Cross-spec decisions go to ADRs.

## Modules touched

Which parts of the codebase, using Glossary vocabulary.
```

## After writing

Suggest the user run `/grill-me` to refine the draft before `/to-tickets` locks it.

## Anti-patterns

- **Don't interview the user.** Synthesize from existing context only. If the conversation hasn't covered something the spec needs, leave it out — `/grill-me` will surface the gap.
- **Don't include specific file paths or code snippets.** Modules-level granularity only. Specific paths go stale fast.
- **Don't write `Decisions`, `Open questions`, or `Next steps` sections.** See SPEC-FORMAT.md anti-patterns.
- **Don't auto-invoke `/to-tickets`.** That's a separate user decision after grilling refines the spec.
- **Don't number a spike or idea.** Numbers are for committed specs, assigned on promotion.
- **Don't set the active pointer.** `to-spec` designs; it never marks a spec as the one being implemented.
