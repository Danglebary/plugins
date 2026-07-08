# Notion resolver — the notion store's backend contract

The mechanism behind the **notion store** (see [STORE.md](./STORE.md)). In this store there are **no planning artifacts on disk**: no `docs/prds/`, no `.active`. Config lives in `.agentic-flow/settings.toml` like every repo's (see STORE.md); the databases live in Notion.

This document is the notion backend's contract: the resolution path, the five database schemas, the file-to-Notion mapping, single-active enforcement, and the tool names.

Targets the hosted Notion MCP (`mcp.notion.com`, API `2025-09-03`, data-source model). Every tool is prefixed `notion-`.

## The anchor: one root page

A single workspace-level **private** page titled `Agentic-Flow` is the anchor. All five databases are its children; skills find them by fetching the root, never by searching for them independently.

Root layout (all children created by `/setup-agentic-flow`):

```
Agentic-Flow                (private root page)
├── PRDs        (database)
├── Tickets     (database)
├── Glossary    (database)   ← replaces CONTEXT.md
├── ADRs        (database)   ← replaces docs/adr/
└── Reviewers   (database)   ← replaces docs/reviewers.md
```

## Resolution (once per skill invocation)

**Hot path — no search.** `/setup-agentic-flow` caches the root page id in `.agentic-flow/settings.toml` (`store.notion.root_page_id`). Skills read the id and `notion-fetch` it directly:

1. Read `root_page_id` from `.agentic-flow/settings.toml`.
2. `notion-fetch` the root page id. The response lists child databases with `<data-source url="collection://…">` tags.
3. Match children **by title** (`PRDs`, `Tickets`, `Glossary`, `ADRs`, `Reviewers`) and capture each `data_source_id`.
4. Hold the resolved IDs for the whole invocation. Skills are single-run, so resolve once — don't re-resolve mid-skill.

No search, no index-lag guard, no title-collision guard, no "never rename the root" constraint — the id is stable across renames.

**Recovery — cached id no longer fetches (skill-reachable).** `settings.toml` exists, so the backend is already known to be notion, but `root_page_id` 404s (root deleted or moved). A skill re-finds the root by search, re-caches, and proceeds via the hot path:

1. `notion-search` — `query: "Agentic-Flow"`, `query_type: internal`, small `page_size`. Caveats: `notion-search` is semantic, not exact-match, and without a Notion AI plan it is workspace-limited — treat results as candidates to verify by title, not authoritative.
2. **0 results** → the root is gone; tell the user to re-run `/setup-agentic-flow`. Stop.
   **>1 exact-title match** → collision. Refuse and ask the user which root to use; do not guess.
3. On success, write the found id back to `settings.toml` (`store.notion.root_page_id`), then proceed via the hot path.

**Bootstrap — no `settings.toml` (setup only).** This is the *only* search-driven entry, and only `/setup-agentic-flow` reaches it. A workflow skill with no `settings.toml` can't tell it's a notion repo, so it stops at STORE.md's resolution step 3 ("not set up — run `/setup-agentic-flow`") and never searches. Setup does: on a fresh clone of a repo that keeps `.agentic-flow/` out of git, it runs the same `notion-search` + verify-by-title as above, and on a hit re-caches the id and continues in re-run mode instead of creating a duplicate root.

Search is eventually consistent — a page created seconds ago may not appear yet. On either path, retry up to 3 times with a brief wait before declaring "not found." Setup never relies on search to verify what it *just* created — it confirms each database by fetching its returned ID directly.

## Schemas

Created by `/setup-agentic-flow` via `notion-create-database`. **Ordering matters** — Tickets references PRDs, so PRDs is created first. The `CREATE TABLE (…)` framing below is literal: row queries (max-`Number`, `Active = true`, tickets-by-PRD) go through **`notion-query-data-sources`**, which takes SQL.

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
  "Diff base" RICH_TEXT COMMENT 'branch/ref to diff against; set to the repo default branch, not hard-coded main',
  "Tags"      MULTI_SELECT('backend':blue, 'frontend':green, 'infra':orange, 'confidential':red)
)
```

**Why `Number` is a plain field, not `UNIQUE_ID`.** `UNIQUE_ID` auto-increments on *every* row, which would burn a PRD number on every idea and spike — violating the rule that only committed PRDs are numbered and numbers are assigned on promotion. The files store computes numbers in skill code (globbing directories); the notion store does the same via a max-`Number` query (`notion-query-data-sources`) over `Kind = PRD` rows (including `Abandoned`, so retired numbers stay reserved). Spikes and Ideas leave `Number` blank until promoted.

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
-- step 2: notion-update-data-source to add the self-relation once the ds_id is known
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

## Files-store → notion-store mapping

| files | notion | Notes |
|---|---|---|
| `status:` frontmatter | `Status` select | Read via `notion-fetch`, write via `notion-update-page` |
| `docs/prds/.active` (pointer) | `Active` checkbox | See single-active enforcement below |
| dir name `prd-003-auth` (implicit branch link) | `Branch` property | Now explicit — this is how `/done` and `/retro` find the diff range |
| `depends_on: [...]` | `Depends on` relation | Acyclicity still validated in skill code; Notion won't enforce it |
| `tickets/_abandoned/` glob, `docs/prds/_abandoned/` | `Status = Abandoned` | Numbers stay reserved; max-`Number`/`UNIQUE_ID` query replaces directory globs |
| `docs/spikes/<slug>.md`, `docs/prds/ideas/<slug>.md` | PRDs rows with `Kind = Spike` / `Kind = Idea` | No `Number`, no lifecycle; body holds findings/idea |
| 5-section `prd.md` body | page content written by `/to-prd` | See template limitation below |

Config does **not** map — `.agentic-flow/settings.toml` serves both stores (see STORE.md).

## Single-active enforcement

`.active` was one file — atomically one PRD. Notion has no cross-row "only one true" constraint, so the invariant lives in skill code. Any skill that sets a PRD active **first queries `PRDs` for `Active = true` rows** (`notion-query-data-sources`) **and clears them** (`notion-update-page`), then sets the new one. `/retro` clears it on close. Treat clear-then-set as one logical step and always clear first, so a crash between the two never leaves two actives.

## Template limitation

The MCP exposes `notion-create-pages` with `template_id` but **no template-creation tool**. So the 5-section PRD body (Problem / Goals / Non-goals / Approach / Modules touched) is written as page **content** by `/to-prd`, not enforced by a Notion database template. Keep the section headings byte-identical across PRDs so `/retro` can locate each section by heading when it synthesizes.

## Tools each skill must load first

Core set: `notion-create-database`, `notion-create-pages`, `notion-fetch`, `notion-search`, `notion-query-data-sources`. Skills that flip status or edit rows also need **`notion-update-page`**, and setup's two-step Tickets creation needs **`notion-update-data-source`** — load via tool search before use if not already available.
