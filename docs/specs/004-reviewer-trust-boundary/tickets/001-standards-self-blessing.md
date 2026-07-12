---
status: done
depends_on: []
---

# standards-reviewer: a diff-introduced blessing no longer silences a smell

## Goal

Close the `standards-reviewer` half of the reviewer trust boundary: a documented standard whose blessing the reviewed diff introduced or rewrote no longer earns override authority, so a change that adds a smell *and* the standard blessing it cannot silence its own review. The un-silenced smell resurfaces as an ordinary Candidate through the existing output, flagged as self-blessed. Entirely in the agent body — `standards-reviewer` already reads the diff it needs; no dispatcher or output-contract change. Governed by ADR 0005.

## Acceptance criteria

- [ ] Precedence rule 2 in `standards-reviewer` carries a caveat: a standard whose blessing appears as an added line (`+` hunk line in `.agentic-flow/diff.patch`, excluding the `+++` file header) in a hunk touching the standard's file earns no override authority.
- [ ] The test is strict and line-granular — any `+` touching the blessing line voids the override (a rewrap included), while a blessing the diff leaves untouched keeps authority even if its file is edited elsewhere — stated unambiguously enough that an executor applies it the same way twice.
- [ ] When the override is voided, the smell it would have silenced surfaces as an ordinary Candidate with Source reading `baseline: <smell>`, and the mandatory Judgment-call field records that the blessing was self-introduced by this diff, citing the standard's home.
- [ ] A blessing added outside the review's `base...head` range (pre-existing to this diff) retains override authority — the cross-diff accumulation case is explicitly out of scope.
- [ ] No change to the agent's output sections or fields, and no `/improve-codebase-architecture` brief change; the caveat cites ADR 0005.

## Implementation notes

The caveat lands in `plugins/agentic-flow/agents/standards-reviewer.md`'s `## Precedence` (rule 2). The agent derives the `+`-line check from `.agentic-flow/diff.patch`, which it already reviews hunk by hunk — do not add git access or a dispatcher brief change. The self-blessing note reuses the existing mandatory Judgment-call field; do not add a field or heading.

## Deviations

_None._
