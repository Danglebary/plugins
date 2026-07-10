---
status: done
depends_on: []
---

# Shared diff-materialization convention

## Goal

Every diff a lifecycle skill consumes is produced by one deterministic mechanism: a `_shared/` reference doc defines the contract (invoking skill resolves `<base>`/`<head>` per store and scope; script owns the git mechanics) and a plugin-shipped script performs materialization with unskippable preflights. Out of scope: rewriting the three consumer skills to invoke it (tickets 002–004).

## Acceptance criteria

- [ ] A `_shared/` reference doc defines the contract: prose-resolved `<base>`/`<head>` arguments, per-scope base resolution (ticket scope: ticket branch vs PRD branch; PRD scope: PRD branch vs recorded Diff base in notion / resolved default branch in files), the script invocation, its exit codes, and the artifact path.
- [ ] The script refuses loudly with distinct exit codes on: a missing/unknown ref, no merge-base between base and head, head being an ancestor of base (reversed arguments), a dirty tree, and an empty resulting diff — and each refusal prints the offending refs or paths.
- [ ] "Dirty" means tracked modifications only — untracked files never cause a refusal.
- [ ] A base that has advanced past the branch point yields a correct merge-base three-dot diff, never a refusal.
- [ ] The script scaffolds `.agentic-flow/` and its deny-by-default `.gitignore` when absent, and writes the diff to `.agentic-flow/diff.patch`.
- [ ] The shared doc states that files-store diffs legitimately contain store-artifact hunks and that fact-checker/reviewer briefs must label them as planning artifacts, not reviewable code.
- [ ] The repo Glossary's header no longer describes the workflow as "prose-only".

## Implementation notes

The script must be reachable from skill prose via the plugin-root path convention (`${CLAUDE_PLUGIN_ROOT}`). The artifact path `.agentic-flow/diff.patch` is a published contract — the deviation-fact-checker agent body names it; do not move it.

## Deviations

- Added a fourth "convention docs" kind to the `_shared/` reference-doc taxonomy (`plugins/agentic-flow/CLAUDE.md`, `skills/_shared/README.md`) to index the new contract doc — the planned work created the doc, but classifying it required a category the taxonomy didn't have, and future shared procedures will follow it.
- (refactor) Added exit code 7 to the script's contract: it now refuses to write through a symlinked `.agentic-flow/`, `diff.patch`, or `.gitignore`. Closes an arbitrary-file-write hole — a hostile repo could commit the artifact path as a symlink outside the tree, and the committed symlink passed the tracked-only dirty preflight. Documented in the DIFF-MATERIALIZATION.md exit-code table.
- (refactor) Pinned the artifact format against the repo's `diff.*` config (`--src-prefix=a/ --dst-prefix=b/ -U3`), so the published `diff.patch` the fact-checker parses has a stable shape regardless of a machine's `diff.noprefix` / `diff.mnemonicPrefix` / `diff.context` settings.
- (refactor) Made the default-branch resolution procedure in DIFF-MATERIALIZATION.md store-neutral and re-pointed `/to-tickets`' `Diff base` resolution (`to-tickets/SKILL.md:8`) at it — removing the "fall back to the current branch" recipe that contradicted the procedure's never-guess rule and would have silently mis-scoped `/retro`'s diff.
