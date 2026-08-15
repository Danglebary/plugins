# Shared bats assertion helpers for the script suites in this directory.
#
# ## Usage
#
#     load test_helpers            # near the top of a .bats file, beside SCRIPT=
#
#     assert_output_contains "<expected>"
#     refute_output_contains "<expected>"
#
# Both assert against `$output` as set by the most recent `run` — call them
# after a `run`, never before one. A test that `run`s twice (see
# materialize-diff.bats' "base advanced past the branch point") asserts against
# whichever `run` came last; forgetting the second `run` silently asserts
# against the first one's output and passes for the wrong reason.
#
# **Quote every expected value.** An unquoted argument is word-split and
# pathname-expanded by the caller's shell before the helper is entered, so the
# literal-matching guarantee below cannot protect it (see "Matching is literal").
#
# `test_helpers.bats` `source`s this file rather than `load`ing it, because it
# also passes the file's path to its probe generator; suites use `load`.
#
# Not bats-assert: that library is a two-repo vendored dependency (bats-assert
# plus bats-support) for three functions, in a repo whose only other dependency
# is bats-core itself. The cost of the local version is that it must be
# maintained and its semantics pinned by test_helpers.bats — which is precisely
# the work AC5 of spec 006 ticket 006 required anyway.
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
# ## Matching is literal, never glob — from `case` inward
#
# A *quoted* expected value is a literal substring, not a pattern: the quoted
# expansion inside `case` keeps metacharacters inert, so an expected value
# containing `[ ]` (every checkbox in an Acceptance criteria fixture) matches as
# written rather than as a bracket expression.
#
# The guarantee starts at the function boundary and cannot reach past it. An
# UNQUOTED argument is glob-expanded against the caller's cwd — a bats fixture
# repo full of real files — before the helper ever runs, so `assert_output_contains a*c`
# may arrive as `abc`, or as several arguments of which all but the first are
# then dropped. Quote at the call site; the guards below catch the arity half.

# _assert_one_arg <caller> <count>
# Refuses unless the caller got exactly one non-empty argument. Both failure
# modes are silent-pass hazards, which is the one thing an assertion helper may
# not have: an EMPTY expected value degenerates to `*""*`, which matches every
# string including empty output, and a SECOND argument means the call site was
# unquoted and glob-expanded, so the value actually checked is not the one
# written. Either way the assertion can no longer fail — the exact defect these
# helpers were built to remove.
_assert_one_arg() {
  if [ "$2" -ne 1 ]; then
    printf '%s: expected exactly 1 argument, got %s — an unquoted expected value glob-expanded at the call site?\n' "$1" "$2" >&2
    return 1
  fi
  return 0
}

# assert_output_contains <substring>
# Fails unless $output contains <substring> literally.
assert_output_contains() {
  _assert_one_arg assert_output_contains $# || return 1
  [ -n "$1" ] || { printf 'assert_output_contains: empty expected value matches everything\n' >&2; return 1; }
  case "$output" in
    *"$1"*) return 0 ;;
  esac
  printf 'expected output to contain: %s\nactual output:\n%s\n' "$1" "$output" >&2
  return 1
}

# refute_output_contains <substring>
# Fails if $output contains <substring> literally.
refute_output_contains() {
  _assert_one_arg refute_output_contains $# || return 1
  [ -n "$1" ] || { printf 'refute_output_contains: empty expected value matches everything\n' >&2; return 1; }
  case "$output" in
    *"$1"*)
      printf 'expected output NOT to contain: %s\nactual output:\n%s\n' "$1" "$output" >&2
      return 1
      ;;
  esac
  return 0
}

# There is deliberately no ordered-match helper. The one assertion that wanted
# one — contract-tamper.bats' `*"SECTION"*"tkt.md"*"Goal"*"unchanged"*` — is
# matching a single tab-delimited record that contract-tamper.sh emits with one
# printf, so the whole record is available as a literal:
#
#     assert_output_contains "SECTION"$'\t'"tkt.md"$'\t'"Goal"$'\t'"unchanged"
#
# That is strictly stronger than an ordered match — it pins adjacency and the
# separators, not merely the order — and it is the idiom the rest of the suite
# already uses. A variadic ordering helper served exactly that one call site.
