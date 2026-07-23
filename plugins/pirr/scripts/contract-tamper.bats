#!/usr/bin/env bats
# Behavioral tests for contract-tamper.sh — the reviewer-trust-boundary
# contract-tamper surface (ADR 0005; placement per ADR 0002).

SCRIPT="$BATS_TEST_DIRNAME/contract-tamper.sh"

setup() {
  # Shield fixtures from the contributor's global/system git config so pass/fail
  # can't go machine-dependent (mirrors materialize-diff.bats).
  export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$REPO"
  cd "$REPO"
  git init -q -b main
  git config user.email test@example.com
  git config user.name test
}

# Commit the whole worktree on the current branch.
commit() {
  git add -A
  git commit -qm "$1"
}

# Assert on `run`'s captured $output.
#
# These exist because a bare `[[ ... ]]` is an unreliable assertion here: on bash
# 3.2 a failing `[[ ]]` inside a function does not trip `errexit` and does not
# fire the ERR trap, so in a bats test only the FINAL command decides pass/fail
# and every earlier `[[ ]]` fails silently. Wrapping the check in a function makes
# each call a simple command at the call site, which `errexit` does honor.
#
# They take a literal substring, not a glob: the quoted expansion inside `case`
# keeps metacharacters inert, so an expected value containing `[ ]` (every
# checkbox in an Acceptance criteria fixture) matches as written rather than as a
# bracket expression.
assert_output_contains() {
  case "$output" in
    *"$1"*) return 0 ;;
  esac
  printf 'expected output to contain: %s\nactual output:\n%s\n' "$1" "$output" >&2
  return 1
}

refute_output_contains() {
  case "$output" in
    *"$1"*)
      printf 'expected output NOT to contain: %s\nactual output:\n%s\n' "$1" "$output" >&2
      return 1
      ;;
  esac
  return 0
}

@test "unchanged section reports unchanged and emits base text with line numbers" {
  printf '# Ticket\n\n## Goal\nDeliver X.\n' > tkt.md
  commit base
  git switch -qc ticket
  echo other > other.txt
  commit work
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  [[ "$output" == *"SECTION"*"tkt.md"*"Goal"*"unchanged"* ]]
  [[ "$output" == *"3:## Goal"* ]]
  [[ "$output" == *"4:Deliver X."* ]]
}

@test "edited section body reports changed" {
  printf '# Ticket\n\n## Goal\nDeliver X.\n' > tkt.md
  commit base
  git switch -qc ticket
  printf '# Ticket\n\n## Goal\nDeliver Y instead.\n' > tkt.md
  commit tamper
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  [[ "$output" == *"tkt.md"$'\t'"Goal"$'\t'"changed"* ]]
}

@test "renamed guarded heading reports changed (fail-safe)" {
  printf '# Ticket\n\n## Goal\nDeliver X.\n' > tkt.md
  commit base
  git switch -qc ticket
  printf '# Ticket\n\n## Objective\nDeliver X.\n' > tkt.md
  commit rename
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  [[ "$output" == *"tkt.md"$'\t'"Goal"$'\t'"changed"* ]]
}

@test "a Deviations-only edit never surfaces (only guarded sections are compared)" {
  printf '# Ticket\n\n## Goal\nDeliver X.\n\n## Deviations\n_None yet._\n' > tkt.md
  commit base
  git switch -qc ticket
  printf '# Ticket\n\n## Goal\nDeliver X.\n\n## Deviations\n- Reshaped the seam.\n' > tkt.md
  commit deviate
  # The caller guards only Goal/Acceptance/Approach — never Deviations.
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  [[ "$output" == *"Goal"$'\t'"unchanged"* ]]
  [[ "$output" != *"Deviations"* ]]
}

@test "a base file absent at the base ref reports changed (fail-safe) with no base body" {
  printf 'placeholder\n' > seed.txt
  commit base
  git switch -qc ticket
  printf '# Ticket\n\n## Goal\nBrand new file.\n' > tkt.md
  commit add-file
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  [[ "$output" == *"tkt.md"$'\t'"Goal"$'\t'"changed"* ]]
  # No base version exists, so no line-numbered base body is emitted.
  [[ "$output" != *"Brand new file."* ]]
}

@test "a guarded heading absent at BOTH refs reports changed (fail-safe, not a silent no-op)" {
  # A mis-targeted or drifted guard (heading typo, case/whitespace mismatch, path
  # typo, a format-doc rename the caller didn't track) resolves to nothing at both
  # base and head. It must surface, not report a reassuring all-clear.
  printf '# Ticket\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit base
  git switch -qc ticket
  printf '# Ticket\n\n## Acceptance criteria\n- [ ] a edited\n' > tkt.md
  commit work
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  [[ "$output" == *"tkt.md"$'\t'"Goal"$'\t'"changed"* ]]
}

@test "an unrelated section inserted between guarded sections does not false-positive" {
  printf '# Ticket\n\n## Goal\nDeliver X.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit base
  git switch -qc ticket
  # Insert an unrelated section between the two guarded ones — shifts Acceptance's
  # line numbers without touching either guarded section's text.
  printf '# Ticket\n\n## Goal\nDeliver X.\n\n## Notes\nscratch\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit insert
  run bash "$SCRIPT" main ticket tkt.md Goal tkt.md "Acceptance criteria"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Goal"$'\t'"unchanged"* ]]
  [[ "$output" == *"Acceptance criteria"$'\t'"unchanged"* ]]
}

@test "guards sections across two files, reporting each independently" {
  printf '# Ticket\n\n## Goal\nDeliver X.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  printf '# Spec\n\n## Approach\nOriginal plan.\n' > spec.md
  commit base
  git switch -qc ticket
  printf '# Spec\n\n## Approach\nRewritten plan.\n' > spec.md
  commit tamper-approach
  run bash "$SCRIPT" main ticket tkt.md Goal tkt.md "Acceptance criteria" spec.md Approach
  [ "$status" -eq 0 ]
  [[ "$output" == *"tkt.md"$'\t'"Goal"$'\t'"unchanged"* ]]
  [[ "$output" == *"tkt.md"$'\t'"Acceptance criteria"$'\t'"unchanged"* ]]
  [[ "$output" == *"spec.md"$'\t'"Approach"$'\t'"changed"* ]]
}

@test "base body carries the section's absolute base line numbers, not head's" {
  printf '# Ticket\n\n## Goal\nDeliver X.\n\n## Acceptance criteria\n- [ ] a\n- [ ] b\n' > tkt.md
  commit base
  git switch -qc ticket
  # Head prepends lines, shifting Acceptance downward — the emitted base numbers
  # must still be the BASE positions (heading at base line 6).
  printf '# Ticket\nextra one\nextra two\n\n## Goal\nDeliver X.\n\n## Acceptance criteria\n- [ ] a\n- [ ] b\n' > tkt.md
  commit shift
  run bash "$SCRIPT" main ticket tkt.md "Acceptance criteria"
  [ "$status" -eq 0 ]
  [[ "$output" == *"6:## Acceptance criteria"* ]]
  [[ "$output" == *"7:- [ ] a"* ]]
  [[ "$output" == *"8:- [ ] b"* ]]
}

@test "too few arguments refuse with exit 1 and print usage" {
  run bash "$SCRIPT" main ticket tkt.md
  [ "$status" -eq 1 ]
  [[ "$output" == *usage* ]]
}

@test "an odd trailing argument (unpaired path/heading) refuses with exit 1" {
  # Arg-shape is checked before any git, so no repo fixture is needed.
  run bash "$SCRIPT" main ticket tkt.md Goal spec.md
  [ "$status" -eq 1 ]
  [[ "$output" == *usage* ]]
}

@test "outside a git repository refuses with exit 1" {
  mkdir -p "$BATS_TEST_TMPDIR/notrepo"
  cd "$BATS_TEST_TMPDIR/notrepo"
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 1 ]
}

@test "unknown base ref refuses with exit 2 and names the ref" {
  printf '## Goal\nx\n' > tkt.md
  commit base
  git switch -qc ticket
  run bash "$SCRIPT" no-such-base ticket tkt.md Goal
  [ "$status" -eq 2 ]
  [[ "$output" == *no-such-base* ]]
}

@test "unknown head ref refuses with exit 2 and names the ref" {
  printf '## Goal\nx\n' > tkt.md
  commit base
  run bash "$SCRIPT" main no-such-head tkt.md Goal
  [ "$status" -eq 2 ]
  [[ "$output" == *no-such-head* ]]
}

@test "a fenced heading inside a guarded section does not truncate it" {
  # The section's own body contains a fenced `## ` line (TICKET-FORMAT.md:62-92 is
  # this shape live). Capture must run past the fence to the real next heading, so
  # a rewrite of the body BELOW the fence is still compared — truncating there
  # would report a reassuring `unchanged` over rewritten contract text.
  printf '# Ticket\n\n## Goal\nDeliver X.\n\n```markdown\n## Fenced heading\n```\n\nTrailing goal text.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit base
  git switch -qc ticket
  printf '# Ticket\n\n## Goal\nDeliver X.\n\n```markdown\n## Fenced heading\n```\n\nRewritten trailing text.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit tamper-below-fence
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  assert_output_contains "tkt.md"$'\t'"Goal"$'\t'"changed"
}

@test "a section's base body spans its fenced block, at absolute base line numbers" {
  printf '# Ticket\n\n## Goal\nDeliver X.\n\n```markdown\n## Fenced heading\n```\n\nTrailing goal text.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit base
  git switch -qc ticket
  echo other > other.txt
  commit work
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  # Fenced content and everything after it, up to the real next heading, is body.
  assert_output_contains "7:## Fenced heading"
  assert_output_contains "10:Trailing goal text."
  # ...and the real next heading still ends it.
  refute_output_contains "12:## Acceptance criteria"
  refute_output_contains "- [ ] a"
}

@test "a fenced heading before the real section neither starts capture nor joins it" {
  # A format doc quoting `## Goal` as sample text above the live section. Under a
  # fence-blind extractor the sample starts capture and the real section re-starts
  # it, concatenating both and handing the widened text over as base contract.
  printf '# Ticket\n\n```markdown\n## Goal\nSample text from the format doc.\n```\n\n## Goal\nReal goal text.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit base
  git switch -qc ticket
  echo other > other.txt
  commit work
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  assert_output_contains "tkt.md"$'\t'"Goal"$'\t'"unchanged"
  # Capture begins at the real heading (line 8), not the fenced sample (line 4).
  assert_output_contains "8:## Goal"
  assert_output_contains "9:Real goal text."
  refute_output_contains "Sample text from the format doc."
  refute_output_contains "4:## Goal"
}

@test "a guarded heading repeated outside fences reports changed with no base body (fail-safe)" {
  # Two sections claim the same heading, so which one is the contract is unknowable.
  # Additive capture would concatenate them — identically at both refs — and report
  # a reassuring `unchanged` while handing the widened text over as base contract.
  # Mirrors the posture for a target that resolves at neither ref: surface it.
  printf '# Ticket\n\n## Goal\nFirst goal.\n\n## Notes\nscratch\n\n## Goal\nSecond goal.\n' > tkt.md
  commit base
  git switch -qc ticket
  echo other > other.txt
  commit work
  run bash "$SCRIPT" main ticket tkt.md Goal
  # A fail-safe verdict is data, not a script failure — the caller must not read it
  # as one.
  [ "$status" -eq 0 ]
  assert_output_contains "tkt.md"$'\t'"Goal"$'\t'"changed"
  # Neither candidate section is emitted: there is no single authoritative base.
  refute_output_contains "First goal."
  refute_output_contains "Second goal."
}

@test "a heading doubled only at head reports changed but still emits the clean base body" {
  # Ambiguity suppresses the base body only when BASE is the ambiguous ref. Here
  # base resolves to exactly one section, so its text is a well-defined contract
  # and is still handed to the brief — discarding it would weaken the reviewer's
  # evidence without making the verdict safer. The verdict is `changed` either
  # way, which is the caller's blocking gate.
  printf '# Ticket\n\n## Goal\nOnly goal.\n' > tkt.md
  commit base
  git switch -qc ticket
  printf '# Ticket\n\n## Goal\nOnly goal.\n\n## Notes\nx\n\n## Goal\nSecond goal.\n' > tkt.md
  commit double-at-head
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  assert_output_contains "tkt.md"$'\t'"Goal"$'\t'"changed"
  assert_output_contains "3:## Goal"
  assert_output_contains "4:Only goal."
  # The emitted body is BASE's, never head's.
  refute_output_contains "Second goal."
}

@test "a ~~~ fence is as inert as a backtick fence" {
  printf '# Ticket\n\n## Goal\nDeliver X.\n\n~~~markdown\n## Fenced heading\n~~~\n\nTrailing goal text.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit base
  git switch -qc ticket
  printf '# Ticket\n\n## Goal\nDeliver X.\n\n~~~markdown\n## Fenced heading\n~~~\n\nRewritten trailing text.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit tamper-below-fence
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  assert_output_contains "tkt.md"$'\t'"Goal"$'\t'"changed"
}

@test "an unterminated fence keeps a later heading from ending the section" {
  # The fence opened at line 6 never closes, so everything below it — including
  # what looks like the next heading — is fenced text. Capture runs to EOF rather
  # than ending at a `## ` that is really sample content.
  printf '# Ticket\n\n## Goal\nDeliver X.\n\n~~~\nunterminated fence opens here\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit base
  git switch -qc ticket
  echo other > other.txt
  commit work
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  assert_output_contains "9:## Acceptance criteria"
  assert_output_contains "10:- [ ] a"
}

@test "a non-bare closing fence is content, not a close, so a rewrite below it reports changed" {
  # CommonMark: a closing fence may not carry an info string, so `` ```markdown ``
  # inside a `` ``` `` block is content, not a close. A fence-close that ignored
  # bareness would flip parity here, read `## sample` as a real heading, truncate
  # the section, and report a reassuring `unchanged` over the rewritten body below.
  printf '# Ticket\n\n## Goal\nDeliver X.\n```\n```markdown\n## sample\nSecret contract.\n```\n\nTrailing goal text.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit base
  git switch -qc ticket
  printf '# Ticket\n\n## Goal\nDeliver X.\n```\n```markdown\n## sample\nSecret contract REWRITTEN.\n```\n\nTrailing goal text.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit tamper-below-nonbare-close
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  assert_output_contains "tkt.md"$'\t'"Goal"$'\t'"changed"
  refute_output_contains "Goal"$'\t'"unchanged"
}

@test "a non-bare closing fence keeps the section body spanning to the real next heading" {
  printf '# Ticket\n\n## Goal\nDeliver X.\n```\n```markdown\n## sample\nSecret contract.\n```\n\nTrailing goal text.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit base
  git switch -qc ticket
  echo other > other.txt
  commit work
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  assert_output_contains "tkt.md"$'\t'"Goal"$'\t'"unchanged"
  # The fenced block (info-string line included) and everything after it, up to the
  # real next heading, is body — at absolute base line numbers.
  assert_output_contains "8:Secret contract."
  assert_output_contains "11:Trailing goal text."
  # ...and the real next heading still ends it.
  refute_output_contains "Acceptance criteria"
}

@test "a backtick fence nested in a tilde fence does not close it early (marker char)" {
  # The ``` at line 6 is a different marker char than the ~~~ opener, so it must not
  # close it; `## inner sample` stays fenced content, not a heading that truncates.
  printf '# Ticket\n\n## Goal\nDeliver X.\n~~~\n```\n## inner sample\nkeep me\n~~~\n\nTrailing goal text.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit base
  git switch -qc ticket
  printf '# Ticket\n\n## Goal\nDeliver X.\n~~~\n```\n## inner sample\nkeep me\n~~~\n\nTrailing REWRITTEN.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit tamper
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  assert_output_contains "tkt.md"$'\t'"Goal"$'\t'"changed"
  assert_output_contains "7:## inner sample"
  refute_output_contains "Acceptance criteria"
}

@test "a shorter same-char fence does not close a longer one (marker length)" {
  # The 3-backtick line at 6 is shorter than the 4-backtick opener, so it must not
  # close it; the 4-backtick line at 9 does.
  printf '# Ticket\n\n## Goal\nDeliver X.\n````\n```\n## inner\nkeep\n````\n\nTrailing goal text.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit base
  git switch -qc ticket
  printf '# Ticket\n\n## Goal\nDeliver X.\n````\n```\n## inner\nkeep\n````\n\nTrailing REWRITTEN.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit tamper
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  assert_output_contains "tkt.md"$'\t'"Goal"$'\t'"changed"
  assert_output_contains "7:## inner"
  refute_output_contains "Acceptance criteria"
}

@test "a fence indented up to three spaces still toggles state" {
  # CommonMark allows 0-3 spaces of indent on a fence line. The 3-space-indented
  # opener/closer must still bracket the block, so `## inner` stays fenced content.
  printf '# Ticket\n\n## Goal\nDeliver X.\n   ```\n## inner\n   ```\n\nTrailing goal text.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit base
  git switch -qc ticket
  printf '# Ticket\n\n## Goal\nDeliver X.\n   ```\n## inner\n   ```\n\nTrailing REWRITTEN.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit tamper
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  assert_output_contains "tkt.md"$'\t'"Goal"$'\t'"changed"
  assert_output_contains "6:## inner"
  refute_output_contains "Acceptance criteria"
}

@test "a four-space-indented fence marker does not open a fence" {
  # Four leading spaces is past CommonMark's 0-3 fence indent, so the ``` at line 5
  # is not a fence; the real `## Acceptance criteria` still ends the section rather
  # than being swallowed as fenced content.
  printf '# Ticket\n\n## Goal\nDeliver X.\n    ```\nstill goal body\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit base
  git switch -qc ticket
  echo other > other.txt
  commit work
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  assert_output_contains "tkt.md"$'\t'"Goal"$'\t'"unchanged"
  assert_output_contains "6:still goal body"
  refute_output_contains "Acceptance criteria"
}

@test "a fenced occurrence of the guarded heading inside its own body is not counted as a duplicate" {
  # `## Goal` appears once as the real heading and once as fenced sample text. The
  # fenced copy must not inflate the ambiguity counter — the section reports
  # unchanged with its full body, not the changed/no-body ambiguity fail-safe.
  printf '# Ticket\n\n## Goal\nReal goal.\n```\n## Goal\n```\nStill goal body.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit base
  git switch -qc ticket
  echo other > other.txt
  commit work
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  assert_output_contains "tkt.md"$'\t'"Goal"$'\t'"unchanged"
  assert_output_contains "6:## Goal"
  assert_output_contains "8:Still goal body."
  refute_output_contains "Acceptance criteria"
}

@test "an unterminated backtick fence keeps a later heading from ending the section" {
  # Mirror of the ~~~ unterminated case, for backticks: the fence opened at line 5
  # never closes, so `## Acceptance criteria` is fenced content and capture runs to
  # EOF rather than ending at what looks like the next heading.
  printf '# Ticket\n\n## Goal\nDeliver X.\n```\nunterminated fence opens here\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit base
  git switch -qc ticket
  echo other > other.txt
  commit work
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  assert_output_contains "8:## Acceptance criteria"
  assert_output_contains "9:- [ ] a"
}

@test "a ~~~ fenced section's base body spans the fence at absolute base line numbers" {
  # The backtick equivalent is pinned by "a section's base body spans its fenced
  # block"; this closes the ~~~ asymmetry, where only the changed flag was asserted.
  printf '# Ticket\n\n## Goal\nDeliver X.\n\n~~~markdown\n## Fenced heading\n~~~\n\nTrailing goal text.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit base
  git switch -qc ticket
  echo other > other.txt
  commit work
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  assert_output_contains "7:## Fenced heading"
  assert_output_contains "10:Trailing goal text."
  refute_output_contains "12:## Acceptance criteria"
  refute_output_contains "- [ ] a"
}

@test "removed guarded heading reports changed (fail-safe)" {
  printf '# Ticket\n\n## Goal\nDeliver X.\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit base
  git switch -qc ticket
  printf '# Ticket\n\n## Acceptance criteria\n- [ ] a\n' > tkt.md
  commit remove
  run bash "$SCRIPT" main ticket tkt.md Goal
  [ "$status" -eq 0 ]
  [[ "$output" == *"tkt.md"$'\t'"Goal"$'\t'"changed"* ]]
}
