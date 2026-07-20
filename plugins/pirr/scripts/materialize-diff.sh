#!/usr/bin/env bash
# materialize-diff.sh — the single mechanism by which pirr skills obtain a diff.
# Contract doc: skills/_shared/DIFF-MATERIALIZATION.md
#
# Usage: materialize-diff.sh <base> <head> [--allow-untracked <path>...]
#
# Writes the merge-base three-dot diff (base...head) to .pirr/diff.patch at the
# repo root, scaffolding .pirr/ and its deny-by-default .gitignore when absent.
# Refusals are side-effect-free: nothing is scaffolded or written unless every preflight
# passes. "Dirty" (exit 5) means tracked modifications only; untracked paths are
# exit 8's business, and a tree carrying both refuses 5 first. Untracked paths
# are reported, never classified here — the invoking skill decides which are
# legitimate and re-invokes naming them via --allow-untracked.
#
# Exit codes:
#   0  success — diff written
#   1  usage or environment error (bad arguments, not a git repository)
#   2  missing/unknown ref
#   3  no merge-base between base and head
#   4  head is an ancestor of base (arguments reversed?)
#   5  dirty tree — tracked files have uncommitted modifications
#   6  empty diff
#   7  unsafe scratch path — .pirr or an artifact within it is a symlink
#   8  untracked paths the caller has not acknowledged
set -euo pipefail

refuse() {
  local code=$1
  shift
  printf 'materialize-diff: %s\n' "$1" >&2
  shift
  (($# == 0)) || printf '%s\n' "$@" >&2
  exit "$code"
}

usage="usage: materialize-diff.sh <base> <head> [--allow-untracked <path>...]"
(($# >= 2)) || refuse 1 "$usage"
base=$1
head=$2
shift 2

# Acknowledged untracked paths. Deliberately explicit paths, never a bare flag
# or a glob: the caller can only silence what it can name, and naming them is
# the classification. Paths must match the script's own exit-8 output verbatim.
allowed=()
if (($# > 0)); then
  [[ $1 == --allow-untracked ]] || refuse 1 "$usage"
  shift
  (($# > 0)) || refuse 1 "--allow-untracked requires at least one path"
  allowed=("$@")
fi

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

# Untracked paths are absent from a base...head diff and are not enumerated by
# any close-out commit, so work left never-staged would silently fail to ship.
# Report them; the invoking skill classifies (this script never reads the
# artifact map). .pirr/ is this script's own scaffolding, never the user's work.
untracked=$(git ls-files --others --exclude-standard -- ':(exclude).pirr')
unacknowledged=""
while IFS= read -r path; do
  [[ -n "$path" ]] || continue
  acknowledged=0
  for ack in ${allowed[@]+"${allowed[@]}"}; do
    if [[ "$path" == "$ack" ]]; then
      acknowledged=1
      break
    fi
  done
  ((acknowledged)) || unacknowledged+="${path}"$'\n'
done <<< "$untracked"
[[ -z "$unacknowledged" ]] ||
  refuse 8 "untracked files are absent from the diff — classify before proceeding:" "${unacknowledged%$'\n'}" \
    "stage or remove any that are implementation; re-run with --allow-untracked '<path>' ... to acknowledge the rest."

git diff --quiet "${base_sha}...${head_sha}" &&
  refuse 6 "empty diff for ${base}...${head} (merge-base $(git rev-parse --short "$merge_base"))"

# Refuse to write through a symlinked scratch path. A hostile repo can commit
# .pirr/diff.patch (or .pirr itself) as a symlink pointing
# outside the tree; committed symlinks are tracked-and-unmodified, so the dirty
# preflight passes and a plain redirect would clobber the link's target.
for path in .pirr .pirr/.gitignore .pirr/diff.patch; do
  [[ -L "$path" ]] && refuse 7 "unsafe scratch path — refusing to write through symlink: ${path}"
done

mkdir -p .pirr
if [[ ! -f .pirr/.gitignore ]]; then
  # Keep this heredoc in sync with the template of record in STORE.md.
  cat > .pirr/.gitignore <<'EOF'
# deny by default, whitelist durable files
*
!.gitignore
!settings.toml
EOF
fi

# Explicit prefixes + fixed context pin the artifact format against the user
# repo's diff.* config (diff.noprefix, diff.mnemonicPrefix, diff.context) — the
# fact-checker parses this file, so its shape is a published contract.
git diff --no-color --no-ext-diff --src-prefix=a/ --dst-prefix=b/ -U3 \
  "${base_sha}...${head_sha}" > .pirr/diff.patch

file_count=$(git diff --name-only "${base_sha}...${head_sha}" | wc -l | tr -d ' ')
echo "wrote .pirr/diff.patch — ${base}...${head}, ${file_count} file(s), merge-base $(git rev-parse --short "$merge_base")"
