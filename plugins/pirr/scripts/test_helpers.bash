# Shared bats assertion helpers for the script suites in this directory.
#
# ## Why these exist: a bare `[[ ]]` is not a reliable assertion
#
# On bash 3.2 — the only bash macOS ships, and the one these suites run under —
# `[[ ]]` does not trip `errexit` when it fails. This is not a property of being
# inside a function; it holds everywhere:
#
#     $ bash -c 'set -e; [[ 1 == 2 ]]; echo REACHED'
#     REACHED
#
# A bats test is a function, and a function's exit status is the status of its
# LAST command. So a `[[ ]]` in final position still fails its test — the call
# site is a simple command, and `errexit` does honor that — while every earlier
# `[[ ]]` fails silently. Position, not the function boundary, is what decides.
#
# `(( ))` shares the exemption and is unreliable for the same reason. Single
# bracket `[ ]` does NOT: it is a simple command, so it honors `errexit` in every
# position and needs no wrapper. That is why the assertions in test_helpers.bats
# are written with `[ ]` — and why `[ ]` is not a general substitute here, since
# POSIX `test` has no pattern-match operator.
#
# Wrapping each check in a function makes the call site a simple command, which
# restores enforcement regardless of position. Do not "simplify" these back to
# `[[ ]]`; test_helpers.bats pins the behavior, and this comment explains it.
#
# Whether bash 4+/5 shares the `[[ ]]` exemption is UNVERIFIED — no other bash
# exists on the development machine. If it does not, suite strictness would be
# silently machine-dependent, the same hazard `setup()`'s GIT_CONFIG_GLOBAL
# shielding guards against. The helpers make the suites strict on every bash, so
# the question does not affect correctness here.
#
# ## Matching is literal, never glob
#
# Expected values are literal substrings, not patterns: the quoted expansion
# inside `case` keeps metacharacters inert, so an expected value containing
# `[ ]` (every checkbox in an Acceptance criteria fixture) matches as written
# rather than as a bracket expression.

# assert_output_contains <substring>
# Fails unless $output contains <substring> literally.
assert_output_contains() {
  case "$output" in
    *"$1"*) return 0 ;;
  esac
  printf 'expected output to contain: %s\nactual output:\n%s\n' "$1" "$output" >&2
  return 1
}

# refute_output_contains <substring>
# Fails if $output contains <substring> literally.
refute_output_contains() {
  case "$output" in
    *"$1"*)
      printf 'expected output NOT to contain: %s\nactual output:\n%s\n' "$1" "$output" >&2
      return 1
      ;;
  esac
  return 0
}

# assert_output_in_order <substring>...
# Fails unless $output contains every <substring> literally AND in the given
# order. Replaces the interior-wildcard form `[[ $output == *a*b*c* ]]`, whose
# ordering constraint is the point — four separate assert_output_contains calls
# would drop it.
#
# Each substring is consumed left to right from the remaining text, so every
# `case` pattern stays a quoted expansion and metacharacters stay inert.
# Assembling the arguments into one glob pattern would be shorter and wrong:
# the arguments would become glob-active, and an expected value of `7:- [ ] a`
# would stop matching the very fixture it was written against.
assert_output_in_order() {
  local rest=$output expected
  for expected in "$@"; do
    case "$rest" in
      *"$expected"*) rest=${rest#*"$expected"} ;;
      *)
        printf 'expected output to contain in order: %s\nfirst unmatched: %s\nactual output:\n%s\n' \
          "$*" "$expected" "$output" >&2
        return 1
        ;;
    esac
  done
  return 0
}
