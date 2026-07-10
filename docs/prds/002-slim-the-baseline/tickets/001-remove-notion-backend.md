---
status: open
depends_on: []
---

# Remove the notion backend

## Goal

The plugin serves the files store only, per ADR 0003. A reader of any skill or shared doc encounters no notion vocabulary, no store-resolution ladder, and no two-backend framing: STORE.md presents a files-only artifact map, setup provisions the files layout without asking which store to use, and NOTION-RESOLVER.md is gone. The resolver remains reachable only through git history, via a pinned pre-removal commit reference recorded in the banked work-workflow idea.

## Acceptance criteria

- [ ] `grep -ri notion plugins/agentic-flow/` returns no matches; NOTION-RESOLVER.md does not exist and nothing references it.
- [ ] STORE.md is a files-only artifact map — no resolution ladder, no per-store columns, no store-equivalence claims.
- [ ] No skill begins with a resolve-the-store step; skills address store artifacts by their paths (or cite the artifact map for the bindings).
- [ ] setup-agentic-flow provisions the files layout only and asks no store question; the commit-or-ignore question for `.agentic-flow/` remains.
- [ ] `docs/prds/ideas/work-workflow-plugin.md` records the pre-removal commit hash and a retrieval command (`git show <hash>:<path>`).
- [ ] README and plugin CONTEXT.md describe a files-only plugin; the two-backend headline is gone.

## Implementation notes

- Pin the hash before deleting: the reference is the commit at HEAD immediately before this ticket's first removal commit.

## Deviations

_None yet._
