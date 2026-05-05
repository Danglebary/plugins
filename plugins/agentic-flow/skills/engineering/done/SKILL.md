---
name: done
description: Close the current ticket. Invokes the deviation-fact-checker sub-agent to compare the ticket diff against ## Deviations, surfaces gaps and ADR candidates for review, appends a retro entry, and flips ticket status to done. Recommends /improve-codebase-architecture next for a per-ticket refactor pass. Use when finishing a ticket.
---

# Done

Close a ticket using **disk-as-primary-signal**: fact-check the captured `## Deviations` against the actual diff via a sub-agent, then write the retro entry. Works the same way from a fresh session as from one with full impl context.

Format references: [TICKET-FORMAT.md](../../_shared/TICKET-FORMAT.md), [RETRO-FORMAT.md](../../_shared/RETRO-FORMAT.md).

## State contract

- **PRD state required**: `open` (the active PRD per `docs/prds/.active`)
- **Ticket state required**: `in-progress` (typical) or `open` (warned)
- **Transition**: ticket `in-progress → done`

Warns rather than refuses on `open → done` (a user who did the work without flipping status mid-pairing shouldn't be blocked; warn and confirm). Refuses on already-`done` tickets.

## Process

1. **Identify the ticket.** Default to the ticket with `status: in-progress` in the active PRD. If multiple or none, ask.

2. **Determine the diff range.**
   - Default: the ticket branch's diff vs its parent (the PRD branch in `serial` mode, the previous ticket's branch in `stacked` mode per `docs/agentic-flow.toml`).
   - Fallback (non-standard branching): ask the user for the diff range.

3. **Invoke `agentic-flow:deviation-fact-checker`** with:
   - The ticket file (Goal + Acceptance + existing `## Deviations`)
   - The PRD's Approach section (for context on the intended approach)
   - The diff (passed as text or via diff range)
   - `CONTEXT.md` (so the agent uses domain vocabulary)
   - Existing ADR titles + statuses (so it doesn't propose duplicates)
   
   The fact-checker returns three sections (each may be `_None._`):
   - **Deviation gaps** — diff changes not captured in `## Deviations`
   - **Misrepresented deviations** — entries in `## Deviations` that don't match the diff
   - **ADR candidates** — choices in the diff that may warrant an ADR per the three-gate test

4. **Adversarially review the findings.** The fact-checker's drafts are *drafts* — review each finding against the cited diff hunks, drop noise/false positives, surface high-signal items to the user.

5. **Apply confirmed updates** to the ticket's `## Deviations` section (append gaps, fix misrepresentations).

6. **Surface ADR candidates to the user** for explicit decision: each candidate gets a yes/no/defer. On yes, hand off to ADR creation per [ADR-FORMAT.md](../../_shared/ADR-FORMAT.md).

7. **Determine the outcome label.**
   - **Exact match** — implemented exactly as the ticket and PRD specified.
   - **Extended** — implemented as specified, plus extra scope that proved necessary or valuable.
   - **Divergence** — implemented something different (different approach, different acceptance) than specified.
   - **Omitted** — ticket abandoned or merged into another. (If selecting this, prefer moving the ticket file to `tickets/_abandoned/` rather than running `/done`.)
   
   Propose the label with reasoning, anchored in the captured deviations. Let the user confirm or override.

8. **Append the retro entry** to `docs/prds/<NNN>-<slug>/retro.md` (creating the file if it doesn't exist):

   ```markdown
   ## Ticket NNN — <ticket title>
   
   **Outcome**: <label>
   
   <1-3 sentences on what was learned>
   ```

   The 1-3 sentences capture *what was learned*, not *what was done* (the ticket file already has that).

9. **Flip the ticket** `status` from `in-progress` to `done`.

10. **Recommend `/improve-codebase-architecture`** as the next step for a per-ticket refactor pass. Phrase as a suggestion: *"Recommend running `/improve-codebase-architecture` next for a refactor pass on this ticket. Optional but catches architectural rot while context is fresh."*

## Refusing to run

- If the ticket's status is already `done`, refuse. Suggest checking git history if the user wants to know what happened.
- If the ticket's status is `open` (never started), warn before flipping straight to `done`. Confirm with the user, then proceed.

## Anti-patterns

- **Don't restructure the running retro.** This skill appends only. Restructuring is `/retro`'s job at PRD close.
- **Don't write what was done in the retro entry.** That's redundant with the ticket file. Capture *insight*, not *log*.
- **Don't trust the fact-checker's drafts blindly.** Review each finding against the cited diff. Drop noise.
- **Don't auto-invoke `/improve-codebase-architecture`.** Recommend it; let the user choose to invoke (or defer if no refactor seems needed).
- **Don't skip the fact-check step even when impl just happened in this session.** Disk-as-primary means the fact-checker runs every time, regardless of conversation context.
