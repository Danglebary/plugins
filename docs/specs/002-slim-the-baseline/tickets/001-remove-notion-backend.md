---
status: done
depends_on: []
---

# Remove the notion backend

## Goal

The plugin serves the files store only, per ADR 0003. A reader of any skill or shared doc encounters no notion vocabulary, no store-resolution ladder, and no two-backend framing: STORE.md presents a files-only artifact map, setup provisions the files layout without asking which store to use, and NOTION-RESOLVER.md is gone. The resolver remains reachable only through git history, via a pinned pre-removal commit reference recorded in the banked work-workflow idea.

## Acceptance criteria

- [ ] `grep -ri notion plugins/pirr/` returns no matches; NOTION-RESOLVER.md does not exist and nothing references it.
- [ ] STORE.md is a files-only artifact map — no resolution ladder, no per-store columns, no store-equivalence claims.
- [ ] No skill begins with a resolve-the-store step; skills address store artifacts by their paths (or cite the artifact map for the bindings).
- [ ] setup provisions the files layout only and asks no store question; the commit-or-ignore question for `.pirr/` remains.
- [ ] `docs/prds/ideas/work-workflow-plugin.md` records the pre-removal commit hash and a retrieval command (`git show <hash>:<path>`).
- [ ] README and plugin CONTEXT.md describe a files-only plugin; the two-backend headline is gone.

## Implementation notes

- Pin the hash before deleting: the reference is the commit at HEAD immediately before this ticket's first removal commit.

## Deviations

- **The `[store]` config block is gone entirely, not just de-notioned.** With the resolution ladder deleted, no skill reads `store.backend` — so the setup template no longer ships a `[store]` block, and this repo's live `settings.toml` dropped the whole block rather than only its notion comment lines. The config surface is now workflow-only (`[branching]`, `[ticket_start]`); the deliberately-retained stale `[branching] strategy` block is untouched.
- **Criterion 6's "README" read as every marketplace-facing headline.** Beyond the plugin README and CONTEXT.md, the repo-root `README.md`, `.claude-plugin/marketplace.json`, and the repo-root `CONTEXT.md` preamble carried the same two-backend headline (outside the criterion-1 grep path) and were updated to files-only — the glossary preamble caught by the close-out fact-check after contradicting that file's own Store backend entry. `docs/reviews/2026-07-08-whole-plugin-deep-dive.md` and the docs/ planning history keep their notion mentions as historical record.
