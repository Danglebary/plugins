#!/usr/bin/env bats
# Behavioral tests for materialize-diff.sh — the diff-materialization contract.
# Contract doc: ../skills/_shared/DIFF-MATERIALIZATION.md

SCRIPT="$BATS_TEST_DIRNAME/materialize-diff.sh"
load test_helpers

setup() {
  # Shield fixtures from the contributor's global/system git config — a stray
  # commit.gpgsign, core.hooksPath, or diff.* setting would otherwise leak in
  # and make pass/fail machine-dependent.
  export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$REPO"
  cd "$REPO"
  git init -q -b main
  git config user.email test@example.com
  git config user.name test
  # Killing the global config is not enough for the exit-8 tests: --exclude-standard
  # still consults $XDG_CONFIG_HOME/git/ignore (or ~/.config/git/ignore), which
  # GIT_CONFIG_GLOBAL does not cover. A contributor carrying *.log or *.ts there
  # would otherwise see exit-8 paths silently dropped — a fail on their machine
  # only, or worse, a gitignore test passing without the repo .gitignore.
  git config core.excludesFile /dev/null
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

# Merge-now fixture: ticket branch merged --no-ff into an advanced main, branch
# deleted — the resting state the post-merge row (DIFF-MATERIALIZATION.md)
# recovers from. Leaves the merge commit's sha in MERGE_SHA.
merge_now() {
  commit_on ticket work.txt
  git switch -q main
  echo advanced > mainline.txt
  git add mainline.txt
  git commit -qm "advance main"
  git merge -q --no-ff -m "merge ticket" ticket
  git branch -qd ticket
  MERGE_SHA=$(git rev-parse main)
}

@test "missing arguments refuse with exit 1 and print usage" {
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  assert_output_contains usage
}

@test "an unrecognized third argument refuses with exit 1 and prints usage" {
  run bash "$SCRIPT" main ticket --force
  [ "$status" -eq 1 ]
  assert_output_contains usage
}

@test "--allow-untracked with no paths refuses with exit 1" {
  run bash "$SCRIPT" main ticket --allow-untracked
  [ "$status" -eq 1 ]
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
  assert_output_contains no-such-branch
}

@test "unknown head ref refuses with exit 2 and names the ref" {
  run bash "$SCRIPT" main no-such-branch
  [ "$status" -eq 2 ]
  assert_output_contains no-such-branch
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
  assert_output_contains rootless
  assert_output_contains ticket
}

@test "head that is an ancestor of base refuses with exit 4 (reversed arguments)" {
  commit_on ticket work.txt
  run bash "$SCRIPT" ticket main
  [ "$status" -eq 4 ]
  assert_output_contains ticket
  assert_output_contains main
}

@test "modified tracked file refuses with exit 5 and prints the path" {
  commit_on ticket work.txt
  echo changed > base.txt
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 5 ]
  assert_output_contains base.txt
}

@test "staged tracked modification refuses with exit 5 and prints the path" {
  commit_on ticket work.txt
  echo changed > base.txt
  git add base.txt
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 5 ]
  assert_output_contains base.txt
}

@test "deleted tracked file refuses with exit 5 and prints the path" {
  commit_on ticket work.txt
  rm base.txt
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 5 ]
  assert_output_contains base.txt
}

@test "a never-staged file refuses with exit 8 and names it" {
  commit_on ticket work.txt
  mkdir -p src
  echo impl > src/impl.ts
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 8 ]
  assert_output_contains src/impl.ts
}

@test "exit 8 never names a gitignored file" {
  commit_on ticket work.txt
  printf 'ignored/\n*.log\n' > .gitignore
  git add .gitignore
  git commit -qm "add gitignore"
  mkdir -p ignored
  echo secret > ignored/secret.txt
  echo noise > junk.log
  echo impl > impl.ts
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 8 ]
  assert_output_contains impl.ts
  refute_output_contains secret.txt
  refute_output_contains junk.log
}

@test "a new file under a new directory is named as its own path, not the directory" {
  # git status --porcelain collapses this to "?? newdir/", which would name a
  # directory the user cannot act on. ls-files --others reports per-file.
  commit_on ticket work.txt
  mkdir -p newdir/nested
  echo impl > newdir/nested/impl.ts
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 8 ]
  assert_output_contains newdir/nested/impl.ts
}

@test "acknowledged untracked paths proceed and the diff is written" {
  # Supersedes "untracked files never cause a refusal": legitimate planning
  # artifacts still must never wedge a close-out, but the skill now says so by
  # naming them rather than the script silently ignoring every untracked path.
  commit_on ticket work.txt
  mkdir -p docs/specs/ideas
  echo banked > docs/specs/ideas/stray.md
  run bash "$SCRIPT" main ticket --allow-untracked docs/specs/ideas/stray.md
  [ "$status" -eq 0 ]
  [ -s .pirr/diff.patch ]
}

@test "every acknowledged path is honored, not just the first" {
  # The skills re-invoke naming *every* reported path, so the plural case is the
  # normal one — a store carrying several banked ideas. A regression that read
  # only $1 would pass every single-path case above.
  commit_on ticket work.txt
  mkdir -p docs/specs/ideas docs/adr
  echo one > docs/specs/ideas/one.md
  echo two > docs/specs/ideas/two.md
  echo three > docs/adr/0001-x.md
  run bash "$SCRIPT" main ticket --allow-untracked \
    docs/specs/ideas/one.md docs/specs/ideas/two.md docs/adr/0001-x.md
  [ "$status" -eq 0 ]
  [ -s .pirr/diff.patch ]
}

@test "acknowledging some of many still refuses, naming only the rest" {
  # The complement of the case above: proves the loop subtracts per path rather
  # than short-circuiting once any argument matches.
  commit_on ticket work.txt
  mkdir -p docs/specs/ideas
  echo one > docs/specs/ideas/one.md
  echo two > docs/specs/ideas/two.md
  run bash "$SCRIPT" main ticket --allow-untracked docs/specs/ideas/one.md
  [ "$status" -eq 8 ]
  assert_output_contains two.md
  refute_output_contains one.md
}

@test "a path containing a space is acknowledged as one path" {
  # Pins the ${allowed[@]+"${allowed[@]}"} guard's quoting under bash 3.2: the
  # elements must survive expansion whole, or a spaced path would split into two
  # acknowledgments that match nothing.
  commit_on ticket work.txt
  mkdir -p docs/specs/ideas
  echo banked > "docs/specs/ideas/with space.md"
  run bash "$SCRIPT" main ticket --allow-untracked "docs/specs/ideas/with space.md"
  [ "$status" -eq 0 ]
}

@test "an acknowledgment is a literal, never a pattern" {
  # --allow-untracked is an acknowledgment, not an override: a caller can only
  # silence what it can name. A glob must silence nothing.
  commit_on ticket work.txt
  mkdir -p docs/specs/ideas
  echo banked > docs/specs/ideas/stray.md
  run bash "$SCRIPT" main ticket --allow-untracked '*'
  [ "$status" -eq 8 ]
  assert_output_contains stray.md
}

@test "an unacknowledged path still refuses even alongside acknowledged ones" {
  commit_on ticket work.txt
  mkdir -p docs/specs/ideas
  echo banked > docs/specs/ideas/stray.md
  echo impl > impl.ts
  run bash "$SCRIPT" main ticket --allow-untracked docs/specs/ideas/stray.md
  [ "$status" -eq 8 ]
  assert_output_contains impl.ts
  refute_output_contains stray.md
}

@test "a staged-but-uncommitted new file still refuses with exit 5, not 8" {
  commit_on ticket work.txt
  echo impl > staged.ts
  git add staged.ts
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 5 ]
  assert_output_contains staged.ts
}

@test "tracked dirt alongside untracked paths refuses with exit 5, not 8" {
  # The untracked check sits after the dirty check, so exit 5 keeps its meaning
  # and its stderr contract: commit the tracked dirt first, then re-run.
  commit_on ticket work.txt
  echo changed > base.txt
  echo impl > impl.ts
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 5 ]
  assert_output_contains base.txt
}

@test "the script's own .pirr scaffolding never trips exit 8 on a later run" {
  # This repo tracks .pirr/.gitignore, so the hazard is invisible here: in a
  # consuming repo that neither tracks nor ignores .pirr, run 1 scaffolds an
  # untracked .pirr/.gitignore that run 2 would otherwise refuse on.
  commit_on ticket work.txt
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 0 ]
  [ -f .pirr/.gitignore ]
  [ -n "$(git ls-files --others --exclude-standard -- .pirr)" ]
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 0 ]
}

@test "a nested .pirr the script does not own is still reported" {
  # The exclusion is root-anchored: it covers this script's scaffold, not a
  # directory that merely shares its name deeper in the user's tree.
  commit_on ticket work.txt
  mkdir -p sub/.pirr
  echo impl > sub/.pirr/thing.ts
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 8 ]
  assert_output_contains sub/.pirr/thing.ts
}

@test "exit 5 stderr names tracked dirt only, never untracked files" {
  # Exit 5 stays tracked-only: untracked paths are exit 8's business, and a
  # tree with both refuses 5 first. Close-out commit gates therefore still
  # enumerate untracked store files from git status, never from this stderr —
  # pin the negative, which exit 8's arrival narrows rather than repeals.
  commit_on ticket work.txt
  echo changed > base.txt
  mkdir -p docs/specs/ideas
  echo banked > docs/specs/ideas/stray.md
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 5 ]
  assert_output_contains base.txt
  refute_output_contains stray.md
}

@test "empty diff refuses with exit 6 and names both refs" {
  git switch -qc ticket
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 6 ]
  assert_output_contains main
  assert_output_contains ticket
}

@test "base advanced past the branch point yields the merge-base diff, not a refusal" {
  commit_on ticket work.txt
  git switch -q main
  echo advanced > mainline.txt
  git add mainline.txt
  git commit -qm "advance main"
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 0 ]
  run cat .pirr/diff.patch
  assert_output_contains work.txt
  refute_output_contains mainline.txt
}

@test "artifact keeps a/ b/ prefixes even when the repo sets diff.noprefix" {
  git config diff.noprefix true
  git config diff.mnemonicPrefix true
  commit_on ticket work.txt
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 0 ]
  grep -q 'diff --git a/work.txt b/work.txt' .pirr/diff.patch
}

@test "a symlinked artifact path refuses with exit 7 and does not write through it" {
  commit_on ticket work.txt
  echo PRECIOUS > "$BATS_TEST_TMPDIR/decoy.txt"
  mkdir -p .pirr
  ln -s "$BATS_TEST_TMPDIR/decoy.txt" .pirr/diff.patch
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 7 ]
  assert_output_contains diff.patch
  [ "$(cat "$BATS_TEST_TMPDIR/decoy.txt")" = "PRECIOUS" ]
}

@test "a committed symlinked artifact (passing the dirty preflight) still refuses with exit 7" {
  git switch -qc ticket
  echo PRECIOUS > "$BATS_TEST_TMPDIR/decoy.txt"
  mkdir -p .pirr
  printf '*\n!.gitignore\n' > .pirr/.gitignore
  ln -s "$BATS_TEST_TMPDIR/decoy.txt" .pirr/diff.patch
  git add -f .pirr
  echo work > work.txt
  git add work.txt
  git commit -qm work
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 7 ]
  [ "$(cat "$BATS_TEST_TMPDIR/decoy.txt")" = "PRECIOUS" ]
}

@test ".pirr itself as a symlink refuses with exit 7" {
  commit_on ticket work.txt
  mkdir "$BATS_TEST_TMPDIR/elsewhere"
  ln -s "$BATS_TEST_TMPDIR/elsewhere" .pirr
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 7 ]
  [ ! -e "$BATS_TEST_TMPDIR/elsewhere/diff.patch" ]
}

@test "a symlinked .gitignore refuses with exit 7 rather than writing through it" {
  commit_on ticket work.txt
  echo PRECIOUS > "$BATS_TEST_TMPDIR/decoy.txt"
  mkdir -p .pirr
  ln -s "$BATS_TEST_TMPDIR/decoy.txt" .pirr/.gitignore
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 7 ]
  [ "$(cat "$BATS_TEST_TMPDIR/decoy.txt")" = "PRECIOUS" ]
}

@test "a commit sha is accepted as base" {
  base_sha=$(git rev-parse main)
  commit_on ticket work.txt
  run bash "$SCRIPT" "$base_sha" ticket
  [ "$status" -eq 0 ]
}

@test "post-merge row: <merge>^1 <merge> yields the merged ticket's changes only" {
  merge_now
  run bash "$SCRIPT" "${MERGE_SHA}^1" "$MERGE_SHA"
  [ "$status" -eq 0 ]
  run cat .pirr/diff.patch
  assert_output_contains work.txt
  refute_output_contains mainline.txt
}

@test "post-merge row reversed (<merge> <merge>^1) refuses with exit 4" {
  merge_now
  run bash "$SCRIPT" "$MERGE_SHA" "${MERGE_SHA}^1"
  [ "$status" -eq 4 ]
}

@test "scaffolds .pirr with the deny-by-default .gitignore and writes diff.patch" {
  commit_on ticket work.txt
  [ ! -d .pirr ]
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 0 ]
  [ -s .pirr/diff.patch ]
  grep -qx '\*' .pirr/.gitignore
  grep -qx '!.gitignore' .pirr/.gitignore
  grep -qx '!settings.toml' .pirr/.gitignore
}

@test "an existing .pirr/.gitignore is never overwritten" {
  commit_on ticket work.txt
  mkdir -p .pirr
  echo "# custom" > .pirr/.gitignore
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 0 ]
  [ "$(cat .pirr/.gitignore)" = "# custom" ]
}

@test "a refusal creates no .pirr scaffold" {
  git switch -qc ticket
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 6 ]
  [ ! -d .pirr ]
}

@test "an exit-8 refusal creates no .pirr scaffold" {
  commit_on ticket work.txt
  echo impl > impl.ts
  [ ! -d .pirr ]
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 8 ]
  [ ! -d .pirr ]
}

@test "invoked from a subdirectory, the artifact lands at the repo root" {
  commit_on ticket work.txt
  mkdir -p sub/dir
  cd sub/dir
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 0 ]
  [ -s "$REPO/.pirr/diff.patch" ]
}

@test "success reports the artifact path" {
  commit_on ticket work.txt
  run bash "$SCRIPT" main ticket
  [ "$status" -eq 0 ]
  assert_output_contains .pirr/diff.patch
}
