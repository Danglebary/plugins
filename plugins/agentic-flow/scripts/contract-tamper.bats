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
