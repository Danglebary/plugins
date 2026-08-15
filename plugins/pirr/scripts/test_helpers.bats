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
# that always succeeds. The negative-path tests are what actually pin the
# mechanism: stub both helpers to `return 0` and 9 of these 13 tests fail
# (1, 3, 4, 6, 7, 8, 9, 10, 11 — measured, not assumed). When adding a positive
# case, add its negative twin, or the new coverage proves nothing.

HELPERS="$BATS_TEST_DIRNAME/test_helpers.bash"
source "$HELPERS"

# write_probe <assertion-line> <fixture-output>
#
# Writes a one-test bats file at $probe (set here, read by the caller) that
# sources the helpers, sets $output to <fixture-output>, runs <assertion-line>
# as a NON-FINAL command, and ends with a command that always succeeds. If the
# helper cannot fail its test, that file passes.
#
# <fixture-output> is passed as PLAIN TEXT — this function quotes it into the
# generated source. Requiring callers to pre-quote invited a probe whose
# `output=hello world` ran `world` as a command and exercised an empty $output,
# passing for the wrong reason.
#
# The probe `source`s an absolute path rather than `load test_helpers`: it is
# written to $BATS_TEST_TMPDIR, where a relative `load` cannot resolve.
write_probe() {
  probe="$BATS_TEST_TMPDIR/probe.bats"
  {
    printf '#!/usr/bin/env bats\n'
    printf "source '%s'\n" "$HELPERS"
    printf '@test "probe" {\n'
    printf "  output='%s'\n" "$2"
    printf '  %s\n' "$1"
    printf '  [ 1 = 1 ]\n'
    printf '}\n'
  } > "$probe"
}

@test "an assertion that fails in non-final position fails its test" {
  write_probe 'assert_output_contains "definitely-absent"' 'hello world'
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

@test "a tab-delimited record matches as one literal, pinning separators and order" {
  # The idiom that replaced the ordered-match helper: contract-tamper.sh emits
  # the whole SECTION record with one printf, so matching it as a single literal
  # is strictly stronger than an ordered match — it pins adjacency too.
  output='SECTION	tkt.md	Goal	unchanged'
  assert_output_contains "SECTION"$'\t'"tkt.md"$'\t'"Goal"$'\t'"unchanged" && rc=0 || rc=$?
  [ "$rc" -eq 0 ]
}

@test "a record literal fails when a separator differs" {
  output='SECTION tkt.md Goal unchanged'
  assert_output_contains "SECTION"$'\t'"tkt.md" 2>/dev/null && rc=0 || rc=$?
  [ "$rc" -eq 1 ]
}

@test "an empty expected value is refused, not matched against everything" {
  output='hello world'
  assert_output_contains '' 2>/dev/null && rc=0 || rc=$?
  [ "$rc" -eq 1 ]
}

@test "an empty expected value is refused by the refutation too" {
  output='hello world'
  refute_output_contains '' 2>/dev/null && rc=0 || rc=$?
  [ "$rc" -eq 1 ]
}

@test "a second argument is refused rather than silently dropped" {
  # The shape an unquoted, glob-expanded call site arrives in. Dropping the
  # extras would check a value nobody wrote.
  output='hello world'
  assert_output_contains 'hello' 'definitely-absent' 2>/dev/null && rc=0 || rc=$?
  [ "$rc" -eq 1 ]
}

@test "an arity violation in non-final position fails its test" {
  write_probe 'assert_output_contains one two' 'hello world'
  run bats "$probe"
  [ "$status" -ne 0 ]
  case "$output" in
    *"expected exactly 1 argument, got 2"*) found=yes ;;
    *) found=no ;;
  esac
  [ "$found" = yes ]
}

@test "a refutation that fails in non-final position fails its test" {
  write_probe 'refute_output_contains "hello"' 'hello world'
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
