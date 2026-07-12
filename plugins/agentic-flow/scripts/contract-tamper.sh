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
# line number (`<N>:<line>`) — consumed by the conformance close-out brief. A base
# with no such section (file absent at base, or the heading renamed/removed) emits
# no body lines and reports `changed` (fail-safe). Tamper is data, not an error:
# exit stays 0 whether or not a section changed.
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
section() {
  awk -v h="## $2" '
    $0 == h { cap = 1; print NR ":" $0; next }
    cap && /^## / { cap = 0 }
    cap { print NR ":" $0 }
  ' <<<"$1"
}

while (($# >= 2)); do
  path=$1
  heading=$2
  shift 2

  base_content=$(git show "$base:$path" 2>/dev/null || true)
  head_content=$(git show "$head:$path" 2>/dev/null || true)

  base_num=$(section "$base_content" "$heading")
  head_num=$(section "$head_content" "$heading")

  # Compare section TEXT, not the numbered form: a section shifted to a new line
  # range by an unrelated edit above it must not read as changed.
  base_plain=$(printf '%s' "$base_num" | sed 's/^[0-9]*://')
  head_plain=$(printf '%s' "$head_num" | sed 's/^[0-9]*://')

  if [[ "$base_plain" == "$head_plain" ]]; then
    flag=unchanged
  else
    flag=changed
  fi

  printf 'SECTION\t%s\t%s\t%s\n' "$path" "$heading" "$flag"
  if [[ -n "$base_num" ]]; then
    printf '%s\n' "$base_num"
  fi
done
