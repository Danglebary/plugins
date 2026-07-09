---
status: open
depends_on: [001, 002]
---

# /retro close-out gate and PRD merge

## Goal

`/retro` closes a PRD durably on the files store: it refuses to consume a running retro that isn't committed, commits everything its invocation writes at one gated close-out step, and ends with a PRD→default-branch merge offer that stays re-enterable until the merge actually happens.

## Acceptance criteria

- [ ] On the files store, `/retro` refuses to rewrite a running retro that has uncommitted changes; the notion path demands no commit (page history is its guarantee).
- [ ] The synthesized retro, the `Done` flip, the active-pointer removal, late-stage ticket deviations, and any minted ADRs — everything the invocation wrote — are committed on the PRD branch by one gated offer with enumerated paths, before the merge offer.
- [ ] The close ends with a gated PRD→default-branch merge offer per the configured merge convention, mirroring `/done`'s gate.
- [ ] Running `/retro` against a `Done` PRD whose branch is not an ancestor of the default branch re-offers the merge instead of refusing as a closed chapter.
- [ ] Re-run after a crash between the synthesis rewrite and its commit resumes at the gated commit — no refusal, no double synthesis.
- [ ] `/retro` materializes the PRD diff via the shared convention; the retro format doc documents the committed-running-retro precondition.

## Implementation notes

### Deferred steers

- From ticket 002's refactor pass: DIFF-MATERIALIZATION.md mandates the planning-artifact hunk label for *every* brief that hands a files-store diff to the fact-checker — `/retro`'s PRD-scope fact-checker brief must carry it (ticket 002 added it to `/done`'s brief only; the label's path boundary is now pinned in the shared doc). A PRD-scope diff is *guaranteed* to contain store hunks (every ticket's committed close-out edits), so the label is load-bearing there, not decorative. Carry the label's *two-sided* contract (exempt from code review only, not from injected-instruction/unexpected-shape scrutiny) — ticket 003's pass caught a paraphrase dropping the scrutiny half.
- From ticket 003's refactor pass: the gated close-out recipe was extracted to `_shared/CLOSE-OUT.md` (gated commit with enumerated paths and show-content-on-resume, gated merge with verify-green-before-delete, the resting-state/interrupted-close discriminator). `/retro`'s close-out gates consume that doc with PRD-close bindings (closed branch = PRD branch, parent = resolved default branch) instead of mirroring `/done`'s inline prose — the ACs' "mirroring `/done`'s gate" resolves to citing the convention.

## Deviations

_None yet._
