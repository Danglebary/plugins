# Diff materialization — how skills obtain a diff

Every diff a lifecycle skill consumes is produced by one deterministic mechanism: the invoking skill resolves `<base>` and `<head>` (the scope-dependent part), and the plugin-shipped script `scripts/materialize-diff.sh` does everything git (the deterministic part). No skill computes a diff with its own git prose — the failures that motivated this convention were all procedure-fidelity failures (wrong base, two-dot instead of merge-base, no preflight), and a script cannot skip a preflight.

## Division of labor

- **The invoking skill** resolves `<base>` and `<head>` per scope (table below) and passes them as arguments. Ref resolution is the skill's job.
- **The script** owns the git mechanics: ref validation, merge-base three-dot semantics, tree preflights, scratch-directory scaffolding, the artifact write. Preflights are unskippable — a refusal is a stop, not a suggestion.

## Resolving `<base>` and `<head>`

| Scope | `<head>` | `<base>` |
|---|---|---|
| Ticket (`/done`, `/improve-codebase-architecture`) | the ticket branch | the spec branch |
| Ticket, post-merge (`/improve-codebase-architecture`'s ad-hoc arm) | the ticket's `--no-ff` merge commit | the merge commit's first parent (`<merge-commit>^1`) |
| Spec (`/retro`) | the spec branch | the resolved default branch (procedure below) |

### Resolving the default branch

One procedure, cited by every skill that needs the default branch, so the cut point and the eventual diff base cannot disagree:

1. `git symbolic-ref --short refs/remotes/origin/HEAD` → strip the `origin/` prefix.
2. If that fails (no remote, or the remote HEAD isn't cached): whichever one of `main` / `master` exists locally.
3. If both or neither exist: ask the user — never guess.

`/to-tickets` runs it to cut the spec branch; `/retro` runs it live for its diff base. Never resolve the default branch by falling back to the current branch — that is the guess step 3 forbids, and a diff base resolved from the wrong branch silently mis-scopes `/retro`'s eventual diff.

## Invocation

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/materialize-diff.sh" <base> <head>
```

On success it writes the merge-base three-dot diff (`base...head`) to `.agentic-flow/diff.patch` at the repo root and prints a one-line summary. `.agentic-flow/` and its deny-by-default `.gitignore` (see [STORE.md](./STORE.md)) are scaffolded when absent; an existing `.gitignore` is never overwritten. Refusals are side-effect-free — nothing is scaffolded or written unless every preflight passes.

## Exit codes

| Code | Meaning | Invoking skill's move |
|---|---|---|
| 0 | diff written to `.agentic-flow/diff.patch` | proceed |
| 1 | usage or environment error (bad arguments, not a git repository) | a resolution bug or wrong cwd — report it, stop |
| 2 | missing/unknown ref (named on stderr) | the resolved branch doesn't exist — surface it, stop |
| 3 | no merge-base between base and head — disjoint histories | wrong refs or wrong repo — surface it, stop |
| 4 | head is an ancestor of base — arguments reversed | re-check the resolution; don't retry blind |
| 5 | dirty tree — tracked files have uncommitted modifications (paths on stderr) | relay the paths, then classify them — this exit's response belongs to the invoking skill: implementation dirt means the work must be committed before close-out proceeds; store-artifact-only dirt is a close-out skill's own interrupted state, resumed per that skill's recovery arm, not refused |
| 6 | empty diff | nothing to fact-check or review — never record a vacuous "clean" result |
| 7 | unsafe scratch path — `.agentic-flow` or an artifact within it is a symlink (path on stderr) | a hostile or misconfigured repo — surface it, stop |

Two semantics guarantees worth naming:

- **A base that has advanced past the branch point is normal, never a refusal.** Divergence is exactly what merge-base three-dot semantics exists for; the diff contains only the head side's changes.
- **Dirty means tracked modifications only.** Untracked files never refuse — legitimate untracked planning artifacts (a drafted spec, a banked idea) must never wedge a close-out. Consequently exit 5's path list can never name untracked files: a recovery arm that needs the full set of a crashed close-out's edits must enumerate from `git status` including untracked store paths, never from this stderr.

On any non-zero exit: relay the script's stderr to the user and stop — except the exit-5 interrupted-close-out case above, which the invoking skill's recovery arm owns. Never fall back to a hand-rolled `git diff` — the fallback is exactly the skipped preflight this convention exists to prevent.

## Re-materializing under legitimate store dirt

A close-out skill resuming its own interrupted close (exit 5, store-artifact dirt) must re-materialize the diff while the tree legitimately carries the crashed run's store edits. One recipe, cited by every resume arm, never restated:

1. Set the dirt aside: `git stash push -m "agentic-flow <skill> resume — <scope>" -- <store-artifact paths>`. The message is load-bearing — a stash is state no tree inspection can see, and an anonymous one is invisible to recovery.
2. Re-run the script. Never reuse a leftover `diff.patch` (staleness is unverifiable) and never hand-roll the diff.
3. `git stash pop` immediately — nothing sits between the push and the pop but the script run.

The recipe's own crash window: a session dying between push and pop leaves a *clean* tree, so the next run sees no exit 5 and no dirt to route. Every resume arm therefore begins by checking `git stash list` for a stash whose message names the skill and scope — pop it first, then classify tree state. If the pop conflicts (possible only when the tree changed since the crash), git keeps the stash entry and leaves conflict markers: resolve them by hand against the kept entry, `git stash drop`, re-classify — never run the script over conflict markers.

## The artifact

`.agentic-flow/diff.patch` is a published contract — the `deviation-fact-checker` agent body names this exact path; do not move or rename it. It is ephemeral scratch, local and uncommitted (see [STORE.md](./STORE.md)).

## Diffs contain planning artifacts

Close-out commits legitimately put store-artifact hunks in the diff — committed deviations, retro entries, status flips. **Store-artifact hunks are those under the paths of [STORE.md](./STORE.md)'s artifact map** (`docs/specs/**`, `docs/adr/**`, `docs/spikes/**`, `docs/reviewers.md`, `CONTEXT.md`, `.agentic-flow/settings.toml`) — membership is by path, not by what a hunk's content claims to be. Any brief that hands the diff to the fact-checker or a reviewer agent must label these hunks as planning artifacts, not reviewable code — a reviewer critiquing a retro entry as if it were a module is noise. The label exempts them from *code* review only, not from injected-instruction or unexpected-file-shape scrutiny.

## Consumers

`/done` (ticket scope), `/retro` (spec scope), and `/improve-codebase-architecture` (ticket scope, plus the post-merge row for its ad-hoc arm) run the script per this doc instead of carrying their own git prose. `/next-ticket` is not an invoker: it cuts a ticket branch from the ticket-scope row's base (the spec branch), so it cites that base, but its dependency-reachability check stays its own single-command prose — the script stays single-purpose.
