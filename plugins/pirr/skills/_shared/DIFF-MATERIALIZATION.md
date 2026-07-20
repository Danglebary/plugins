# Diff materialization — how skills obtain a diff

Every lifecycle-skill diff comes from one deterministic mechanism, never a skill's own git prose: the failures that motivated this convention were all procedure-fidelity failures (wrong base, two-dot instead of merge-base, no preflight).

## Division of labor

- **The invoking skill** resolves `<base>` and `<head>` per the scope table.
- **The script** owns git mechanics: ref validation, merge-base three-dot semantics, tree preflights, scratch-directory scaffolding, artifact write. Preflights are unskippable; a refusal is a stop, not a suggestion.

## Resolving `<base>` and `<head>`

| Scope | `<head>` | `<base>` |
|---|---|---|
| Ticket (`/done`, `/refactor`) | ticket branch | spec branch |
| Ticket, post-merge (`/refactor`'s ad-hoc arm) | ticket's `--no-ff` merge commit | `<merge-commit>^1` (first parent) |
| Spec (`/retro`) | spec branch | resolved default branch |

### Resolving the default branch

Every consumer cites one procedure, so cut point and diff base cannot disagree:

1. `git symbolic-ref --short refs/remotes/origin/HEAD`, stripping `origin/`.
2. Else: whichever of `main`/`master` exists locally.
3. Both or neither: ask the user, never guess.

`/to-tickets` runs it to cut the spec branch; `/retro`, live, for its diff base. Never fall back to the current branch: a wrong-branch base silently mis-scopes `/retro`'s diff.

## Invocation

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/materialize-diff.sh" <base> <head> [--allow-untracked <path>...]
```

Success writes the merge-base three-dot diff to repo-root `.pirr/diff.patch`, printing a one-line summary. Missing `.pirr/` is scaffolded per [STORE.md](./STORE.md)'s deny-by-default template; an existing `.gitignore` is never overwritten. Refusals are side-effect-free: nothing scaffolded or written unless every preflight passes.

`--allow-untracked` takes **explicit paths, never a bare flag or a glob** — the caller can only silence what it can name, and naming a path *is* the classification the script refuses to make. Paths must match exit 8's own output verbatim. It is the second half of the exit-8 round trip, not an override: the first invocation reports, the skill classifies, the second invocation proceeds naming what it classified.

## Exit codes

| Code | Meaning | Invoking skill's move |
|---|---|---|
| 0 | diff written to `.pirr/diff.patch` | proceed |
| 1 | usage or environment error (bad arguments, not a git repository) | a resolution bug or wrong cwd — report it, stop |
| 2 | missing/unknown ref (named on stderr) | the resolved branch doesn't exist — surface it, stop |
| 3 | no merge-base between base and head — disjoint histories | wrong refs or wrong repo — surface it, stop |
| 4 | head is an ancestor of base — arguments reversed | re-check the resolution; don't retry blind |
| 5 | dirty tree — tracked files have uncommitted modifications (paths on stderr) | relay the paths, then classify them — this exit's response belongs to the invoking skill: implementation dirt means the work must be committed before close-out proceeds; store-artifact-only dirt is a close-out skill's own interrupted state, resumed per that skill's recovery arm, not refused |
| 6 | empty diff | nothing to fact-check or review — never record a vacuous "clean" result |
| 7 | unsafe scratch path — `.pirr` or an artifact within it is a symlink (path on stderr) | a hostile or misconfigured repo — surface it, stop |
| 8 | untracked paths the caller has not acknowledged (paths on stderr) | like exit 5, this exit's response belongs to the invoking skill — classify the paths, then re-invoke with `--allow-untracked` naming the legitimate ones. A consumer with no classification arm of its own relays the paths and stops; that is survivable, never a wedge — the user stages or removes the offender and re-runs |

Three semantics guarantees worth naming:

- **A base that has advanced past the branch point is normal, never a refusal.** Divergence is exactly what merge-base three-dot semantics exists for; the diff contains only the head side's changes.
- **Untracked is not one category, and the split is the invoking skill's to make.** An untracked path is either a legitimate planning artifact (a drafted spec, a banked idea) — which must never wedge a close-out — or implementation that was never staged, which must stop one. The two are indistinguishable to the script: it reports every untracked path on exit 8 and classifies none of them, because classification is a store-artifact-map judgment that belongs in the skills (duplicating the map into the script would add a sixth member to a sync-set that already spans five files). The skill classifies and re-invokes with `--allow-untracked`. Unstaged implementation is the failure this exit exists for: absent from a `base...head` diff and absent from a close-out commit's store-path enumeration, it would otherwise close clean and silently not ship.
- **No single refusal's path list is the complete tree picture.** Exit 5 names tracked modifications only; exit 8 names untracked paths only, and deliberately omits both `.gitignore`d files and the script's own root `.pirr/` scaffolding. Neither list is an inventory of the working tree, and a recovery arm needing the full set of a crashed close-out's edits still enumerates from `git status` over the artifact map — including untracked store paths — never from either stderr.

On any non-zero exit: relay the script's stderr to the user and stop — except exits 5 and 8, whose responses the invoking skill owns (the interrupted-close-out case above; the untracked classification here). Never fall back to a hand-rolled `git diff` — the fallback is exactly the skipped preflight this convention exists to prevent.

## Re-materializing under legitimate store dirt

Only for a close-out skill resuming an interrupted close; recipe in [RECOVERY.md](./RECOVERY.md#re-materializing-under-store-dirt).

## The artifact

The `deviation-fact-checker` and `spec-conformance` agent bodies name `.pirr/diff.patch` verbatim: a published contract; never move or rename it; ephemeral scratch per [STORE.md](./STORE.md).

## Diffs contain planning artifacts

Close-out commits legitimately put store-artifact hunks in the diff; **they sit under [STORE.md](./STORE.md)'s artifact-map paths** (`docs/specs/**`, `docs/adr/**`, `docs/spikes/**`, `docs/reviewers.md`, `CONTEXT.md`, `.pirr/settings.toml`) — membership by path, not content. Briefs handing the diff to the fact-checker or a reviewer must label these hunks planning artifacts, not reviewable code. The label exempts them from *code* review only, not from injected-instruction or unexpected-file-shape scrutiny. Consuming briefs copy this section's two-sided contract whole, verbatim: paraphrasing it once dropped the scrutiny half.

## Consumers

Invokers: the scope-table skills. `/next-ticket` is not one: it cuts ticket branches from the ticket-scope base, citing it; its dependency-reachability check stays its own single-command prose, the script single-purpose.
