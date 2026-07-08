---
status: open
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

_None yet._
