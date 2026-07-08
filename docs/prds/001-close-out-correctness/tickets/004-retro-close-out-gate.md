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

## Deviations

_None yet._
