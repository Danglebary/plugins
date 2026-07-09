# Diff materialization — how skills obtain a diff

Every diff a lifecycle skill consumes is produced by one deterministic mechanism: the invoking skill resolves `<base>` and `<head>` (the store-dependent part), and the plugin-shipped script `scripts/materialize-diff.sh` does everything git (the deterministic part). No skill computes a diff with its own git prose — the failures that motivated this convention were all procedure-fidelity failures (wrong base, two-dot instead of merge-base, no preflight), and a script cannot skip a preflight.

## Division of labor

- **The invoking skill** resolves `<base>` and `<head>` per store and scope (tables below) and passes them as arguments. A script cannot read the store; ref resolution is the skill's job.
- **The script** owns the git mechanics: ref validation, merge-base three-dot semantics, tree preflights, scratch-directory scaffolding, the artifact write. Preflights are unskippable — a refusal is a stop, not a suggestion.

## Resolving `<base>` and `<head>`

| Scope | `<head>` | `<base>` — files store | `<base>` — notion store |
|---|---|---|---|
| Ticket (`/done`, `/improve-codebase-architecture`) | the ticket branch | the PRD branch | the PRD branch |
| PRD (`/retro`) | the PRD branch | the resolved default branch (procedure below) | the PRD row's recorded `Diff base` property |

### Resolving the default branch (files store)

One procedure, cited by every skill that needs the default branch — `/retro`'s diff base here, and `/to-tickets`' PRD-branch cut point — so the cut point and the eventual diff base cannot disagree:

1. `git symbolic-ref --short refs/remotes/origin/HEAD` → strip the `origin/` prefix.
2. If that fails (no remote, or the remote HEAD isn't cached): whichever one of `main` / `master` exists locally.
3. If both or neither exist: ask the user — never guess.

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
| 5 | dirty tree — tracked files have uncommitted modifications (paths on stderr) | relay the paths; the work must be committed before close-out proceeds |
| 6 | empty diff | nothing to fact-check or review — never record a vacuous "clean" result |

Two semantics guarantees worth naming:

- **A base that has advanced past the branch point is normal, never a refusal.** Divergence is exactly what merge-base three-dot semantics exists for; the diff contains only the head side's changes.
- **Dirty means tracked modifications only.** Untracked files never refuse — legitimate untracked planning artifacts (a drafted PRD, a banked idea) must never wedge a close-out.

On any non-zero exit: relay the script's stderr to the user and stop. Never fall back to a hand-rolled `git diff` — the fallback is exactly the skipped preflight this convention exists to prevent.

## The artifact

`.agentic-flow/diff.patch` is a published contract — the `deviation-fact-checker` agent body names this exact path; do not move or rename it. It is ephemeral scratch, local and uncommitted in both stores (see [STORE.md](./STORE.md)).

## Files-store diffs contain planning artifacts

On the files store, close-out commits legitimately put store-artifact hunks in the diff — committed deviations, retro entries, status flips. Any brief that hands the diff to the fact-checker or a reviewer agent must label these hunks as planning artifacts, not reviewable code — a reviewer critiquing a retro entry as if it were a module is noise.

## Consumers

`/done` (ticket scope), `/retro` (PRD scope), and `/improve-codebase-architecture` (ticket scope) run the script per this doc instead of carrying their own git prose. `/next-ticket` is not an invoker: its branch cut cites the base-resolution procedure above, but its dependency-reachability check stays its own single-command prose — the script stays single-purpose.
