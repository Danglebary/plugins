---
status: done
depends_on: [001, 002]
---

# /improve pass integration

## Goal

`/refactor` never strands a ticket branch or a deviation capture: every `(refactor)` entry gets a commit carrier, every pass — including a no-op — ends at the close-out merge offer, a post-merge invocation degrades to a deliberate ad-hoc pass with a named range, and outside-PRD deferrals are banked instead of evaporating.

## Acceptance criteria

- [ ] A `(refactor)` deviation entry is always committed: the capture is appended before or with the refactor commit that carries it, and a pending-store-edits check at the merge offer commits any straggler.
- [ ] A pass with no candidates, or none accepted, still ends at the close-out merge offer — no stranded ticket branches.
- [ ] Invoked after a merge-now close (ticket branch deleted), the skill routes to its ad-hoc scope arm and names the recoverable range (`<merge-commit>^1...<merge-commit>`, the `--no-ff` merge commit found by branch name); refactor commits land on the PRD branch and captures still append to the `Done` ticket.
- [ ] A deferral that belongs to no ticket in the active PRD is banked as an Idea, and idea-banked deferrals are included in the next pass's brief inputs so reviewers don't re-propose them.
- [ ] `/improve` materializes its diff via the shared convention and carries no stacked-mode or self-authored diff prose.

## Implementation notes

### Deferred steers

- From ticket 002's refactor pass: DIFF-MATERIALIZATION.md mandates the planning-artifact hunk label for *every* brief that hands a files-store diff to a reviewer agent — `/improve`'s step-4 reviewer briefs must carry it (ticket 002 added it to `/done`'s fact-checker brief only; the label's path boundary is now pinned in the shared doc).

## Deviations

- Added an exit-5 recovery arm to `/improve`'s diff step beyond the ticket's ACs, per the PRD's "re-entry generally" clause: store-artifact dirt with the `done` flip uncommitted routes back to `/done`'s resume; with the flip committed it's `/improve`'s own interrupted pass, resumed at the close-out gates.
- DIFF-MATERIALIZATION.md's resolving table gained a post-merge row (`<head>` = the ticket's `--no-ff` merge commit, `<base>` = `<merge-commit>^1`) so the ad-hoc arm's range is convention-owned rather than skill-authored prose.
- (refactor) Extracted the close-out recipe — gated store-edits commit, gated merge, resting-state/interrupted-close discriminator with the flip-last ordering as a published invariant — into `_shared/CLOSE-OUT.md`; `/done` and `/improve` now cite it with arm-specific bindings, the convention-doc taxonomy widened to cover pure-procedure docs, and tickets 004/006 carry steers to consume the seam instead of minting copies three and four.
- (refactor) Scoped `/improve`'s close-out contract per arm: the merge offer exists only when the pass worked a live ticket branch, the post-merge handover became a blocking confirm gate (identified ticket + resolved range), the general ad-hoc arm ends at the commit gate, and the decline prose differentiates the re-entry routes' costs (`/done` re-offers merge-only; a re-run of the pass is a full dispatch).
- (refactor) The planning-artifact label in `/done`'s and `/improve`'s briefs now carries the shared doc's two-sided contract — code-review exemption plus retained injected-instruction/unexpected-shape scrutiny — and TICKET-FORMAT.md gained the `### Deferred steers` subsection definition both skills append to.
