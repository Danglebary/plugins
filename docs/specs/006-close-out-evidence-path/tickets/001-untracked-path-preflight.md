---
status: done
depends_on: []
---

# Untracked implementation files stop a close-out

## Goal

A ticket whose implementation file was never staged closes clean today: the diff script's dirty check sees tracked modifications only, so the file is absent from the reviewed diff, and because the close-out commit enumerates store-artifact paths only, it is never committed either — the work silently does not ship. This ticket makes that file stop the close-out instead of vanishing from it. The diff script reports untracked paths on a new exit, and the two skills that consume it classify what comes back. Out of scope: everything the agents do with the diff once it is complete (tickets 003–005).

## Acceptance criteria

- [ ] Running the diff script against a tree whose only dirt is a never-staged implementation file exits non-zero and names that file — today it exits 0 and writes a diff that omits it.
- [ ] Files excluded by `.gitignore` never appear among the reported paths.
- [ ] A new file nested inside a new directory is reported as its own path, not as the containing directory.
- [ ] The script's own `.pirr/` scaffolding never triggers the new exit, on a first run or any later one.
- [ ] Staged-but-uncommitted new files continue to refuse exactly as they do today.
- [ ] On the new exit, `/done` and `/retro` refuse and name the paths when any is implementation; proceed when the paths are store artifacts this invocation authored; and proceed while naming them when they are store artifacts it did not.
- [ ] A never-staged implementation file present alongside legitimate untracked planning artifacts still refuses.
- [ ] `DIFF-MATERIALIZATION.md`'s untracked-files guarantee distinguishes planning artifacts from unstaged implementation, and no longer implies the refusal's path list is the complete picture.
- [ ] `IMPLEMENTATION-LOOP.md`'s staging argument no longer claims an unstaged path "trips the same misroute", and states what actually happens for a modified file and for a new one.
- [ ] The two tests that assert the old behavior — `materialize-diff.bats:115` and `:124` — are rewritten rather than deleted, and the suite passes.

## Implementation notes

The three-way classification is `CLOSE-OUT.md:7`'s existing authorship-scoped division, not a new taxonomy — implementation dirt, this invocation's own store artifacts, and store artifacts it did not author. A two-way split would contradict it and would misread a banked idea as an interrupted close-out.

Classification stays in the skills: the script reports paths and does not consult the artifact map. Copying the map's globs into the script would add a sixth member to a sync-set that currently has five.

## Deviations

**The script gained an `--allow-untracked <path>...` argument; the recovery stash was left alone.** The ticket specifies the new exit but not how a skill that classifies its untracked paths as legitimate then obtains a diff — the refusal is side-effect-free, so nothing is written. The alternative considered first was widening `RECOVERY.md`'s resume stash to `-u`, which was verified to round-trip correctly. It was rejected on frequency: untracked banked ideas and drafted specs are the store's normal resting state (this repo carries six), so every routine `/done` and `/retro` would pay a stash-and-pop round trip — including that recipe's documented push/pop crash window — to get past a preflight this ticket adds, for files that provably cannot affect a `base...head` diff. The acknowledgment argument keeps classification in the skills as the Implementation notes require (the script never reads the artifact map), and takes explicit paths rather than a bare flag or glob so a caller can only silence what it can name.

`RECOVERY.md`'s stash was left un-widened, but the doc did not stay untouched: the close-out fact-check caught that its resume recipe becomes an exit-8 caller. The recipe stashes tracked store paths only, so a crashed run's *untracked* artifacts — a minted ADR, a first `retro.md` — survive the stash and refuse the re-run. Step 2 of the recipe now states this and routes to the resuming skill's exit-8 arms. Not anticipated when the argument was designed; found by the fact-checker.

**The `.pirr/` exclusion is a root-anchored pathspec, not `-x`/`--exclude`.** Both satisfy the acceptance criterion. `--exclude=.pirr/` is depth-agnostic and would also hide a user's `sub/.pirr/thing.ts`, which the script does not own; `-- ':(exclude).pirr'` covers only the scaffold at the repo root. Pinned by its own test.

**The untracked check sits after the exit-5 dirty check.** The ticket lists `materialize-diff.bats:115` and `:124` as equivalent rewrites; they are not. With this ordering `:124`'s assertions remain correct and only its justifying comment needed work, so it was corrected rather than inverted — calling it a behavior flip would have been false. (The old comment was *incomplete*, not wrong: exit 5's stderr still names tracked dirt only, and the close-out gates still enumerate untracked store files from `git status`. Exit 8 narrows that negative rather than repealing it — the corrected comment says so.) `:115` was genuinely superseded: its intent (legitimate planning artifacts must never wedge a close-out) now lives on the acknowledgment test, which names the lineage. Ordering is itself pinned by a test.

**`/refactor` was given the exit-8 classification too — scope creep, knowingly taken.** `refactor/SKILL.md` invokes the same script and handled exit 5 only, so shipping this ticket alone would have hard-stopped every refactor pass on any untracked banked idea — the normal state of a working store. It cites `/done`'s arms rather than restating them. The close-out conformance pass established this is creep rather than anticipation: criterion `:19` names only `/done` and `/retro`, and the spec assigns the `/refactor` exit-8 arm to *no* ticket — `spec.md:65`'s `/refactor` list omits it and ticket 005's criteria never mention it. Taken anyway because the alternative was shipping a known regression and waiting for a ticket that would never have covered it.

**Four defects were caught by the close-out pair and fixed before the flip, not deferred.** The exit-8 arms in `/done` and `/retro` were gated on the whole set reading "Only store artifacts…", so a mixed set — this run's own artifact alongside a foreign banked idea, the ordinary resumed-close state — matched no arm and fell through to relay-and-stop; they now classify per path as `CLOSE-OUT.md:7`'s enumeration does. `RECOVERY.md`'s recipe gained its exit-8 step (above). `DIFF-MATERIALIZATION.md`'s "Two semantics guarantees" lead-in was left miscounting the three bullets the same edit produced. And `/refactor`'s invocation block had been updated to show `--allow-untracked` while `/done`'s and `/retro`'s still showed the bare two-argument form their own prose contradicted.
