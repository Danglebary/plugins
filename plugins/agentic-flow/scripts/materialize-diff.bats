#!/usr/bin/env bats
# Behavioral tests for materialize-diff.sh — the diff-materialization contract.
# Contract doc: ../skills/_shared/DIFF-MATERIALIZATION.md

SCRIPT="$BATS_TEST_DIRNAME/materialize-diff.sh"

setup() {
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$REPO"
  cd "$REPO"
  git init -q -b main
  git config user.email test@example.com
  git config user.name test
  echo base > base.txt
  git add base.txt
  git commit -qm initial
}

# Cut <branch> from the current HEAD and add one commit creating <file>.
commit_on() {
  git switch -qc "$1"
  echo content > "$2"
  git add "$2"
  git commit -qm "add $2"
}

@test "missing arguments refuse with exit 1 and print usage" {
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *usage* ]]
}

@test "outside a git repository refuses with exit 1" {
  mkdir -p "$BATS_TEST_TMPDIR/notrepo"
  cd "$BATS_TEST_TMPDIR/notrepo"
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 1 ]
}

@test "unknown base ref refuses with exit 2 and names the ref" {
  commit_on ticket work.txt
  run bash "$SCRIPT" no-such-branch ticket
  [ "$status" -eq 2 ]
  [[ "$output" == *no-such-branch* ]]
}

@test "unknown head ref refuses with exit 2 and names the ref" {
  run bash "$SCRIPT" main no-such-branch
  [ "$status" -eq 2 ]
  [[ "$output" == *no-such-branch* ]]
}

@test "disjoint histories refuse with exit 3 and name both refs" {
  commit_on ticket work.txt
  git checkout -q --orphan rootless
  git rm -qrf .
  echo other > other.txt
  git add other.txt
  git commit -qm "disjoint root"
  run bash "$SCRIPT" rootless ticket
  [ "$status" -eq 3 ]
  [[ "$output" == *rootless* && "$output" == *ticket* ]]
}

@test "head that is an ancestor of base refuses with exit 4 (reversed arguments)" {
  commit_on ticket work.txt
  run bash "$SCRIPT" ticket main
  [ "$status" -eq 4 ]
  [[ "$output" == *ticket* && "$output" == *main* ]]
}

@test "modified tracked file refuses with exit 5 and prints the path" {
  commit_on ticket work.txt
  echo changed > base.txt
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 5 ]
  [[ "$output" == *base.txt* ]]
}

@test "staged tracked modification refuses with exit 5 and prints the path" {
  commit_on ticket work.txt
  echo changed > base.txt
  git add base.txt
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 5 ]
  [[ "$output" == *base.txt* ]]
}

@test "deleted tracked file refuses with exit 5 and prints the path" {
  commit_on ticket work.txt
  rm base.txt
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 5 ]
  [[ "$output" == *base.txt* ]]
}

@test "untracked files never cause a refusal" {
  commit_on ticket work.txt
  echo stray > stray.txt
  mkdir -p docs
  echo draft > docs/draft.md
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 0 ]
}

@test "empty diff refuses with exit 6 and names both refs" {
  git switch -qc ticket
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 6 ]
  [[ "$output" == *main* && "$output" == *ticket* ]]
}

@test "base advanced past the branch point yields the merge-base diff, not a refusal" {
  commit_on ticket work.txt
  git switch -q main
  echo advanced > mainline.txt
  git add mainline.txt
  git commit -qm "advance main"
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 0 ]
  run cat .agentic-flow/diff.patch
  [[ "$output" == *work.txt* ]]
  [[ "$output" != *mainline.txt* ]]
}

@test "a commit sha is accepted as base" {
  base_sha=$(git rev-parse main)
  commit_on ticket work.txt
  run bash "$SCRIPT" "$base_sha" ticket
  [ "$status" -eq 0 ]
}

@test "scaffolds .agentic-flow with the deny-by-default .gitignore and writes diff.patch" {
  commit_on ticket work.txt
  [ ! -d .agentic-flow ]
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 0 ]
  [ -s .agentic-flow/diff.patch ]
  grep -qx '\*' .agentic-flow/.gitignore
  grep -qx '!.gitignore' .agentic-flow/.gitignore
  grep -qx '!settings.toml' .agentic-flow/.gitignore
}

@test "an existing .agentic-flow/.gitignore is never overwritten" {
  commit_on ticket work.txt
  mkdir -p .agentic-flow
  echo "# custom" > .agentic-flow/.gitignore
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 0 ]
  [ "$(cat .agentic-flow/.gitignore)" = "# custom" ]
}

@test "a refusal creates no .agentic-flow scaffold" {
  git switch -qc ticket
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 6 ]
  [ ! -d .agentic-flow ]
}

@test "invoked from a subdirectory, the artifact lands at the repo root" {
  commit_on ticket work.txt
  mkdir -p sub/dir
  cd sub/dir
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 0 ]
  [ -s "$REPO/.agentic-flow/diff.patch" ]
}

@test "success reports the artifact path" {
  commit_on ticket work.txt
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 0 ]
  [[ "$output" == *.agentic-flow/diff.patch* ]]
}
