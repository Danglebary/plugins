---
status: done
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
- Acceptance criteria (line 16, "reports `changed` with no base body"): the body suppression is narrowed to the case where the **base** ref is the ambiguous one. When base resolves to exactly one section and only *head* carries the duplicate, the record reads `changed` but the clean base body is still emitted — verified against a fixture repo: `changed`, followed by `3:## Goal` / `4:Only goal.`. Discarding a well-defined base contract would weaken the conformance brief without making the verdict safer, and the blocking `changed` flag is unaffected either way. The criterion's wording is unqualified, so this is a divergence from its literal text; it was raised and approved at the plan gate before implementation.
- Scope: this close adds a sixth ticket (`tickets/006-bats-assertions-that-cannot-fail.md`) to a spec that locked with five. The corpus's documented vehicle for out-of-scope work discovered mid-pass is a banked Idea (`STORE.md`'s artifact map; `/refactor`'s deferral rule), and `/to-tickets`' ticket creation is one-shot per spec (`SPEC-FORMAT.md`) — a numbered ticket was chosen over an idea file because the repair carries acceptance criteria and a real dependency on this ticket's helpers, which an un-numbered idea can't express. Consequence: `/next-ticket` and `/retro` will both meet a ticket the spec's Approach never planned.
- The helpers take a **literal substring** rather than a glob pattern. Passing a pattern through a variable loses the ability to quote parts of it literally, which would have turned the `[ ]` in every Acceptance-criteria checkbox fixture into a bracket expression. The quoted expansion inside `case` keeps metacharacters inert.
- (refactor) Completed `section()`'s fence-awareness: the fence-close condition now requires a **bare** closer (CommonMark forbids an info string on a close), closing a guard bypass the security lens found and I reproduced — a non-bare fence line (e.g. `` ```markdown `` inside a `` ``` `` block) was read as a close, truncating a guarded section so a real rewrite below it reported a false `unchanged`. The extractor's leverage is now sound: no fenced content can smuggle a truncated base contract past the guard. Pinned by nine new fixtures covering the close condition's three discriminators (marker char, length, bareness), the 0–3-space indent boundary, both fence markers, and the fenced-heading-in-own-body non-ambiguity case (the qa lens flagged all of these as untested); the header's two-cause fail-safe prose was generalized to the three-cause principle to match.
