#!/usr/bin/env bash
# materialize-diff.sh — the single mechanism by which agentic-flow skills obtain a diff.
# Contract doc: skills/_shared/DIFF-MATERIALIZATION.md
#
# Usage: materialize-diff.sh <base> <head>
#
# Writes the merge-base three-dot diff (base...head) to .agentic-flow/diff.patch at the
# repo root, scaffolding .agentic-flow/ and its deny-by-default .gitignore when absent.
# Refusals are side-effect-free: nothing is scaffolded or written unless every preflight
# passes. "Dirty" means tracked modifications only — untracked files never refuse.
#
# Exit codes:
#   0  success — diff written
#   1  usage or environment error (bad arguments, not a git repository)
#   2  missing/unknown ref
#   3  no merge-base between base and head
#   4  head is an ancestor of base (arguments reversed?)
#   5  dirty tree — tracked files have uncommitted modifications
#   6  empty diff
set -euo pipefail

refuse() {
  local code=$1
  shift
  printf 'materialize-diff: %s\n' "$1" >&2
  shift
  (($# == 0)) || printf '%s\n' "$@" >&2
  exit "$code"
}

(($# == 2)) || refuse 1 "usage: materialize-diff.sh <base> <head>"
base=$1
head=$2

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) ||
  refuse 1 "not inside a git repository (cwd: $PWD)"
cd "$repo_root"

base_sha=$(git rev-parse --verify --quiet "${base}^{commit}") ||
  refuse 2 "unknown ref: ${base}"
head_sha=$(git rev-parse --verify --quiet "${head}^{commit}") ||
  refuse 2 "unknown ref: ${head}"

merge_base=$(git merge-base "$base_sha" "$head_sha" 2>/dev/null) ||
  refuse 3 "no merge-base between ${base} and ${head} — disjoint histories?"

if [[ "$base_sha" != "$head_sha" ]] && git merge-base --is-ancestor "$head_sha" "$base_sha"; then
  refuse 4 "${head} is an ancestor of ${base} — arguments reversed? (expected <base> <head>)"
fi

dirty=$(git status --porcelain --untracked-files=no)
[[ -z "$dirty" ]] ||
  refuse 5 "tracked files have uncommitted modifications — commit them first:" "$dirty"

git diff --quiet "${base_sha}...${head_sha}" &&
  refuse 6 "empty diff for ${base}...${head} (merge-base $(git rev-parse --short "$merge_base"))"

mkdir -p .agentic-flow
if [[ ! -f .agentic-flow/.gitignore ]]; then
  cat > .agentic-flow/.gitignore <<'EOF'
# deny by default, whitelist durable files
*
!.gitignore
!settings.toml
EOF
fi

git diff --no-color --no-ext-diff "${base_sha}...${head_sha}" > .agentic-flow/diff.patch

file_count=$(git diff --name-only "${base_sha}...${head_sha}" | wc -l | tr -d ' ')
echo "wrote .agentic-flow/diff.patch — ${base}...${head}, ${file_count} file(s), merge-base $(git rev-parse --short "$merge_base")"
