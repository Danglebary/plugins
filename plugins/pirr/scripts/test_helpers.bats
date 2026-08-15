#!/usr/bin/env bats
# Behavioral tests for test_helpers.bash — the assertion mechanism both script
# suites rest on. These exist because an assertion that has never been observed
# failing is unverified no matter how many times it has "passed" (spec 006).
#
# Every test here takes its verdict from a single-bracket `[ ]`, never from the
# return status of the helper under test: `[ ]` is a simple command and so honors
# `errexit` in every position, which is exactly the property the helpers are being
# built to supply. Letting a helper call be a test's final command would make the
# function under test its own judge.
#
# That discipline is necessary but not sufficient, and the gap is worth naming.
# A helper stubbed to `return 0` still passes every positive-path test here — an
# assertion that something succeeds cannot distinguish a working helper from one
# that always succeeds. The negative-path tests are what actually pin the mechanism:
# stub all three helpers to `return 0` and tests 1, 3, 4, 6 and 8 fail. When adding
# a positive case, add its negative twin, or the new coverage proves nothing.

HELPERS="$BATS_TEST_DIRNAME/test_helpers.bash"
source "$HELPERS"

# Write a one-test bats file that sources the helpers, runs $1 as a NON-FINAL
# command, and ends with a command that always succeeds. If the helper cannot
# fail its test, this file passes.
write_probe() {
  probe="$BATS_TEST_TMPDIR/probe.bats"
  {
    printf '#!/usr/bin/env bats\n'
    printf 'source %s\n' "$HELPERS"
    printf '@test "probe" {\n'
    printf '  output=%s\n' "$2"
    printf '  %s\n' "$1"
    printf '  [ 1 = 1 ]\n'
    printf '}\n'
  } > "$probe"
}

@test "an assertion that fails in non-final position fails its test" {
  write_probe 'assert_output_contains "definitely-absent"' "'hello world'"
  run bats "$probe"
  [ "$status" -ne 0 ]
  # Assert on the diagnostic, not merely on non-zero: a missing or unsourceable
  # helper also exits non-zero, and would green this test for the wrong reason.
  case "$output" in
    *"expected output to contain: definitely-absent"*) found=yes ;;
    *) found=no ;;
  esac
  [ "$found" = yes ]
}

@test "an expected value containing bracket metacharacters matches literally" {
  output='6:## Acceptance criteria
7:- [ ] a'
  assert_output_contains '7:- [ ] a' && rc=0 || rc=$?
  [ "$rc" -eq 0 ]
}

@test "an expected value containing ? is not treated as a single-character wildcard" {
  output='abc'
  assert_output_contains 'a?c' 2>/dev/null && rc=0 || rc=$?
  [ "$rc" -eq 1 ]
}

@test "an expected value containing * is not treated as a wildcard" {
  output='abc'
  assert_output_contains 'a*c' 2>/dev/null && rc=0 || rc=$?
  [ "$rc" -eq 1 ]
}

@test "ordered matching succeeds when the substrings appear in order" {
  output='SECTION	tkt.md	Goal	unchanged'
  assert_output_in_order 'SECTION' 'tkt.md' 'Goal' 'unchanged' && rc=0 || rc=$?
  [ "$rc" -eq 0 ]
}

@test "ordered matching fails when the substrings appear out of order" {
  output='SECTION	tkt.md	Goal	unchanged'
  assert_output_in_order 'unchanged' 'SECTION' 2>/dev/null && rc=0 || rc=$?
  [ "$rc" -eq 1 ]
}

@test "ordered matching treats each substring literally, not as a glob" {
  output='7:- [ ] a
8:- [ ] b'
  assert_output_in_order '7:- [ ] a' '8:- [ ] b' && rc=0 || rc=$?
  [ "$rc" -eq 0 ]
}

@test "a refutation that fails in non-final position fails its test" {
  write_probe 'refute_output_contains "hello"' "'hello world'"
  run bats "$probe"
  [ "$status" -ne 0 ]
  case "$output" in
    *"expected output NOT to contain: hello"*) found=yes ;;
    *) found=no ;;
  esac
  [ "$found" = yes ]
}

@test "refutation succeeds when the substring is absent" {
  output='hello world'
  refute_output_contains 'goodbye' && rc=0 || rc=$?
  [ "$rc" -eq 0 ]
}

@test "refutation treats * literally rather than matching anything" {
  output='hello world'
  refute_output_contains '*' && rc=0 || rc=$?
  [ "$rc" -eq 0 ]
}
