# Notion resolver — pure-search protocol

The single mechanism every agentic-flow skill depends on. There are **no local files**: no `docs/prds/`, no `.active`, no `agentic-flow.toml`. Each skill resolves its databases by searching Notion at the start of every run.

This document is the contract. Every skill's Process begins with "resolve databases (see NOTION-RESOLVER.md)".

## The anchor: one root page

A single workspace-level **private** page titled exactly `Agentic-Flow` is the anchor. It is the *only* title that must remain search-stable — the child databases are found by fetching the root, not by searching for them independently. Rename a child database and the workflow still works; rename the root and it breaks. (The user has committed to not renaming it.)

Root layout (all children created by `/setup-agentic-flow`):

```
Agentic-Flow                (private root page; config lives in its body)
├── PRDs        (database)
├── Tickets     (database)
├── Glossary    (database)   ← replaces CONTEXT.md
├── ADRs        (database)   ← replaces docs/adr/
└── Reviewers   (database)   ← replaces docs/reviewers.md
```

## Resolution steps (run once per skill invocation)

1. `notion-search` — `query: "Agentic-Flow"`, `query_type: internal`, small `page_size`.
2. **0 results** → not set up. Tell the user to run `/setup-agentic-flow`. Stop.
   **>1 exact-title match** → collision. Refuse and ask the user which root to use; do not guess.
3. `notion-fetch` the root page ID. The response lists child databases with `<data-source url="collection://…">` tags.
4. Match children **by title** (`PRDs`, `Tickets`, `Glossary`, `ADRs`, `Reviewers`) and capture each `data_source_id`.
5. Hold the resolved IDs for the whole invocation. Skills are single-run, so resolve once — don't re-search mid-skill.

## Search index lag — the one real pure-search hazard

Notion search is eventually consistent: a database created seconds ago may not appear yet. This only bites at the seam between `/setup-agentic-flow` (which creates the databases) and the next skill. Because skills run in separate, human-initiated invocations, lag normally clears on its own. Two guards:

- **Resolvers retry.** On a miss, wait briefly and re-search, up to 3 attempts, before declaring "not set up."
- **Setup verifies by ID, not search.** `/setup-agentic-flow` confirms each created database is fetchable by its returned ID before finishing, and warns the user that the very next skill may need a moment for search to catch up.

## Schemas

Created by `/setup-agentic-flow`. **Ordering matters** — Tickets references PRDs, so PRDs is created first.

**PRDs** — holds all three `to-prd` vehicles (PRD / Spike / Idea), distinguished by `Kind`.
```sql
CREATE TABLE (
  "Name"      TITLE,
  "Kind"      SELECT('PRD':blue, 'Spike':purple, 'Idea':gray),
  "Status"    SELECT('Drafting':yellow, 'Open':blue, 'Done':green, 'Abandoned':gray),
  "Number"    NUMBER COMMENT 'skill-assigned, immutable, never reused; blank for Spikes and Ideas',
  "Slug"      RICH_TEXT COMMENT 'kebab topic slug; used to build the branch name prd-NNN-slug',
  "Active"    CHECKBOX,
  "Branch"    RICH_TEXT COMMENT 'git branch this PRD maps to, e.g. prd-003-auth; set by /to-tickets',
  "Diff base" RICH_TEXT COMMENT 'branch/ref to diff against, default main',
  "Tags"      MULTI_SELECT('backend':blue, 'frontend':green, 'infra':orange, 'confidential':red)
)
```

**Why `Number` is a plain field, not `UNIQUE_ID`.** `UNIQUE_ID` auto-increments on *every* row, which would burn a PRD number on every idea and spike — violating the file-model rule that only committed PRDs are numbered and numbers are assigned on promotion. The file workflow already computes numbers in skill code (globbing directories); the Notion version does the same via a max-`Number` query over `Kind = PRD` rows (including `Abandoned`, so retired numbers stay reserved). Spikes and Ideas leave `Number` blank until promoted.

**Kind semantics.** `Status`, `Active`, tickets, and retros apply to `Kind = PRD` only. A `Spike` row carries its findings in the page body and skips the lifecycle entirely; an `Idea` row is one paragraph parked until promotion (flip `Kind → PRD`, assign `Number`, set `Status = Drafting`).

**Tickets** — two-step (self-relation can't reference a table that doesn't exist yet):
```sql
-- step 1: create with the PRD relation only
CREATE TABLE (
  "Name"      TITLE,
  "Status"    SELECT('Open':blue, 'In progress':yellow, 'Done':green, 'Abandoned':gray),
  "PRD"       RELATION('<prds_ds_id>'),
  "Ticket ID" UNIQUE_ID PREFIX 'TKT'
)
-- step 2: update-data-source to add the self-relation once the ds_id is known
--   "Depends on" RELATION('<tickets_ds_id>', DUAL 'Blocks' 'blocks')
```

**Glossary** (replaces `CONTEXT.md`)
```sql
CREATE TABLE ("Term" TITLE, "Definition" RICH_TEXT, "Relationships" RICH_TEXT)
```

**ADRs** (replaces `docs/adr/`)
```sql
CREATE TABLE (
  "Title"    TITLE,
  "Status"   SELECT('Proposed':yellow, 'Accepted':green, 'Superseded':gray),
  "Decision" RICH_TEXT,
  "ADR ID"   UNIQUE_ID PREFIX 'ADR'
)
```

**Reviewers** (replaces `docs/reviewers.md`)
```sql
CREATE TABLE ("Agent" TITLE, "Kind" SELECT('default':blue, 'specialized':purple), "Signal" RICH_TEXT)
```

## File-model → Notion mapping

| Old (file) | New (Notion) | Notes |
|---|---|---|
| `status:` frontmatter | `Status` select | Read via `notion-fetch`, write via `update-page` |
| `docs/prds/.active` (pointer) | `Active` checkbox | See single-active enforcement below |
| dir name `prd-003-auth` (implicit branch link) | `Branch` property | Now explicit — this is how `/done` and `/retro` find the diff range |
| `depends_on: [...]` | `Depends on` relation | Acyclicity still validated in skill code; Notion won't enforce it |
| `tickets/_abandoned/` glob, `docs/prds/_abandoned/` | `Status = Abandoned` | Numbers stay reserved; max-`Number`/`UNIQUE_ID` query replaces directory globs |
| `docs/spikes/<slug>.md`, `docs/prds/ideas/<slug>.md` | PRDs rows with `Kind = Spike` / `Kind = Idea` | No `Number`, no lifecycle; body holds findings/idea |
| 5-section `prd.md` body | page content written by `/to-prd` | See template limitation below |

## Single-active enforcement

`.active` was one file — atomically one PRD. Notion has no cross-row "only one true" constraint, so the invariant lives in skill code. Any skill that sets a PRD active **first queries `PRDs` for `Active = true` rows and clears them** (`update-page`), then sets the new one. `/retro` clears it on close. Treat clear-then-set as one logical step and always clear first, so a crash between the two never leaves two actives.

## Config (in the root page body)

`docs/agentic-flow.toml` is gone. Its keys live as a small config block in the body of the `Agentic-Flow` root page — `/setup-agentic-flow` writes it, and `/next-ticket`, `/done`, and `/improve-codebase-architecture` read it. The load-bearing keys:

- `branching.strategy` — `serial` (ticket branches cut from the PRD branch) or `stacked` (cut from the previous ticket's branch). `/next-ticket` prompts once on the second ticket of the first PRD if unset, then writes the choice back into the root body.
- `ticket_start.research_opener` — `true` dispatches a research sub-agent at ticket start (the config *is* the standing consent).
- merge convention (e.g. `--no-ff`) — read by `/done`'s and `/improve`'s close-out merge offer; may also live in the repo's `CLAUDE.md`.

These are workflow config, not planning artifacts, so they sit in the root body rather than a database. `.agentic-flow/diff.patch` remains a **local git-ignored scratch file** — it's a view of the git diff for the fact-checker, about the code (which is in git), not a planning artifact, so it does not move to Notion.

## Template limitation

The MCP exposes `create-pages` with `template_id` but **no template-creation tool**. So the 5-section PRD body (Problem / Goals / Non-goals / Approach / Modules touched) is written as page **content** by `/to-prd`, not enforced by a Notion database template. Keep the section headings byte-identical across PRDs so `/retro` can locate each section by heading when it synthesizes.

## Tools each skill must load first

`create-database`, `create-pages`, `fetch`, `search` were loaded during design. Skills that flip status or edit rows also need **`update-page`**, and setup's two-step Tickets creation needs **`update-data-source`** — neither was in the initial tool set, so a real run must `tool_search` for them before use.
