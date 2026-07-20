---
status: in-progress
depends_on: []
---

# A guarded section is compared in full and in isolation

## Goal

The tamper guard's section extractor treats any `## `-prefixed line as a section boundary and keys its start condition on an exact heading match evaluated on every line. Two defects follow: a guarded section containing a fenced heading is compared only up to that fence, so a rewrite of everything after it reads as unchanged; and a heading that appears more than once makes capture additive, concatenating both sections and handing the widened text to the conformance brief as authoritative base contract. This ticket makes the comparison see exactly the intended section and nothing else. Out of scope: which sections are guarded and which file holds each — that policy stays with the calling skill.

## Acceptance criteria

- [ ] A guarded section containing a fenced `## ` line is captured whole, and a later rewrite of body text following that fence reports `changed`.
- [ ] A fenced line matching the guarded heading, appearing anywhere before the real section, neither starts capture nor contributes text to it.
- [ ] A guarded heading appearing more than once outside fences reports `changed` with no base body, rather than emitting the two sections concatenated.
- [ ] `~~~` fences behave identically to ``` fences, including unterminated ones.
- [ ] Existing fail-safe behavior is unchanged: a section absent at base, absent at both refs, or whose heading was renamed still reports `changed`.
- [ ] A section shifted to new line numbers by an unrelated edit above it still reports `unchanged`.
- [ ] Emitted base text still carries absolute base line numbers.
- [ ] Both fence positions and the repeated-heading case have bats fixtures; the existing suite still passes.

## Implementation notes

The multiple-match response mirrors the posture the script already takes when a target resolves at neither ref — report `changed` with no base body rather than guessing which section was meant. Tamper remains exit-0 data: a fail-safe verdict is not a script failure, and a caller's `set -e` must not read it as one.

## Deviations

- Acceptance criteria (AC8, "have bats fixtures"): the suite gained two assertion helpers (`assert_output_contains` / `refute_output_contains`) and this ticket's new tests route their `$output` checks through them. On bash 3.2 — the only bash on macOS — a failing `[[ ]]` inside a function does not trip `errexit` and does not fire the ERR trap, so in a bats test only the *final* command decides pass/fail and every earlier `[[ ]]` fails silently. Fixtures whose assertions cannot fail would not have satisfied AC8. Scoped deliberately to this ticket's own tests; the corpus-wide sweep is ticket 006.
- The helpers take a **literal substring** rather than a glob pattern. Passing a pattern through a variable loses the ability to quote parts of it literally, which would have turned the `[ ]` in every Acceptance-criteria checkbox fixture into a bracket expression. The quoted expansion inside `case` keeps metacharacters inert.
