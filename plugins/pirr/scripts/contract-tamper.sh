#!/usr/bin/env bash
# contract-tamper.sh — compare guarded contract sections base→head and emit the
# line-numbered base text of each. Governed by ADR 0005 (reviewers distrust
# diff-touched authority); placement per ADR 0002 (hot-path procedure → script).
# Division of labor: skills/_shared/DIFF-MATERIALIZATION.md — the invoking skill
# resolves the store-dependent targets (which sections are guarded and which file
# holds each); this script owns the git-deterministic extract-and-compare.
#
# Usage: contract-tamper.sh <base> <head> <path> <heading> [<path> <heading> ...]
#
# For each (path, heading) target it prints one tab-delimited record:
#   SECTION<TAB><path><TAB><heading><TAB><changed|unchanged>
# followed by that section's BASE text, each line prefixed with its absolute base
# line number (`<N>:<line>`) — consumed by the conformance close-out brief. A
# target that does not resolve to exactly one section at a ref reports `changed` as
# a fail-safe — surfacing rather than silently passing — for any of: the section
# absent at base (file absent, or the heading renamed/removed/mistyped), absent at
# BOTH refs (a mis-targeted or drifted guard), or the heading matching more than
# once outside fences (ambiguous, unknowable which is the contract). The base body
# is emitted only when the base ref resolved to exactly one section, so a heading
# doubled only at head still hands over its clean base text. Tamper is data, not an
# error: exit stays 0 whether or not a section changed.
#
# Exit codes:
#   0  success — per-section records emitted (a changed section is data, not an error)
#   1  usage error, or not inside a git repository
#   2  unknown base or head ref
# (There is no exit 3: the ambiguity fail-safe above is folded into a `changed`
# record, never surfaced as a script exit — unlike materialize-diff.sh, where every
# numbered exit code is a refusal.)
set -euo pipefail

usage='usage: contract-tamper.sh <base> <head> <path> <heading> [<path> <heading> ...]'

refuse() {
  local code=$1
  shift
  printf 'contract-tamper: %s\n' "$1" >&2
  exit "$code"
}

(($# >= 4)) || refuse 1 "$usage"
base=$1
head=$2
shift 2
(($# % 2 == 0)) || refuse 1 "$usage (path/heading come in pairs)"

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) ||
  refuse 1 "not inside a git repository (cwd: $PWD)"
cd "$repo_root"

git rev-parse --verify --quiet "${base}^{commit}" >/dev/null 2>&1 ||
  refuse 2 "unknown ref: ${base}"
git rev-parse --verify --quiet "${head}^{commit}" >/dev/null 2>&1 ||
  refuse 2 "unknown ref: ${head}"

# Extract one section (its heading line through the next `## ` heading or EOF)
# from <content>, printing each retained line as `<absolute-line-number>:<line>`.
# Keys on the exact heading, so a renamed/removed heading yields nothing.
#
# Fenced code blocks are inert: a `## ` line inside one is sample text, not a
# heading, so it neither ends the section nor starts one. A fence is tracked by
# marker char and length (CommonMark: 3+ backticks or tildes, indented 0-3), so a
# ``` block nested inside a ~~~ block doesn't close it early — the shape a corpus
# of markdown-about-markdown actually writes. A closer must also be bare — only
# trailing spaces or tabs; CommonMark forbids an info string on a close — so a
# fence-marker line carrying trailing text is content, not a close, and does not
# end the block (openers, by contrast, may carry an info string).
#
# Exits 3 when the heading matches more than once outside fences, printing nothing:
# which of the two sections is the contract is unknowable, so there is no base text
# to hand over. The caller turns that into the same `changed`-with-no-body verdict
# it already gives a target that resolves at neither ref.
section() {
  awk -v h="## $2" '
    {
      if (match($0, /^ {0,3}(`{3,}|~{3,})/)) {
        marker = substr($0, RSTART, RLENGTH)
        sub(/^ */, "", marker)
        if (fence == "") {
          fence = marker
        } else if (substr(marker, 1, 1) == substr(fence, 1, 1) &&
                   length(marker) >= length(fence) &&
                   substr($0, RSTART + RLENGTH) ~ /^[ \t]*$/) {
          fence = ""
        }
      } else if (fence == "") {
        if ($0 == h) { matches++; cap = 1; buf = buf NR ":" $0 "\n"; next }
        if (cap && /^## /) { cap = 0 }
      }
      if (cap) { buf = buf NR ":" $0 "\n" }
    }
    END { if (matches > 1) { exit 3 } printf "%s", buf }
  ' <<<"$1"
}

while (($# >= 2)); do
  path=$1
  heading=$2
  shift 2

  base_content=$(git show "$base:$path" 2>/dev/null || true)
  head_content=$(git show "$head:$path" 2>/dev/null || true)

  # `|| rc=$?` is load-bearing: under `set -e` a bare assignment from a command
  # substitution that exits non-zero kills the script, turning a fail-safe verdict
  # into an abort. Any non-zero here means the section did not resolve to exactly
  # one candidate, so the fail-safe is closed by construction rather than by
  # enumerating awk's exit codes.
  base_rc=0
  base_num=$(section "$base_content" "$heading") || base_rc=$?
  head_rc=0
  head_num=$(section "$head_content" "$heading") || head_rc=$?

  # Compare section TEXT, not the numbered form: a section shifted to a new line
  # range by an unrelated edit above it must not read as changed.
  base_plain=$(printf '%s' "$base_num" | sed 's/^[0-9]*://')
  head_plain=$(printf '%s' "$head_num" | sed 's/^[0-9]*://')

  if ((base_rc != 0 || head_rc != 0)); then
    # The heading matched more than once outside fences at one of the refs, so no
    # single section is authoritative. Same fail-safe posture as the both-refs-
    # empty case below: surface it rather than picking one and calling it the
    # contract. A base that resolved cleanly still emits its body — discarding
    # known-good evidence would weaken the brief without making it safer.
    flag=changed
  elif [[ -z "$base_num" && -z "$head_num" ]]; then
    # Target resolves to nothing at either ref — a mis-targeted or drifted guard
    # (heading typo/case/whitespace, path typo, a format-doc rename the caller
    # didn't track). Fail safe: surface it rather than reporting a reassuring
    # all-clear that would also hand ticket 003 an empty base contract silently.
    flag=changed
  elif [[ "$base_plain" == "$head_plain" ]]; then
    flag=unchanged
  else
    flag=changed
  fi

  printf 'SECTION\t%s\t%s\t%s\n' "$path" "$heading" "$flag"
  if [[ -n "$base_num" ]]; then
    printf '%s\n' "$base_num"
  fi
done
