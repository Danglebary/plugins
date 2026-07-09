# agentic-flow

A Claude Code plugin (slash commands and behaviors) supporting a four-phase workflow for AI-augmented software development: Plan → Implement → Refactor / Cleanup → Retro. Built on a hierarchy of **PRD** → **Ticket** → **Retro**, with cross-cutting **ADR**s and a living **Glossary** in each consuming repo. Planning artifacts live in the **Store** — in-repo files or Notion databases, chosen per repo.

## Language

**Store**:
Where planning artifacts (**PRD**s, **Ticket**s, **Retro**s, the **Glossary**, **ADR**s, the Reviewers manifest, config) live. Two interchangeable backends chosen per repo by `/setup-agentic-flow`: **files** (in-repo markdown) or **notion** (databases under a private `Agentic-Flow` root page). Skills are store-neutral and resolve the store at the start of each run; `skills/_shared/STORE.md` is the contract. Code, branches, and diffs stay in git in both.
_Avoid_: backend (overloaded), database (only one store is one)

**Glossary**:
The living domain vocabulary of a consuming repo. Files store: `CONTEXT.md` at the repo root. Notion store: the Glossary database. Grown lazily by `/grill-me`.

**PRD** (Product Requirements Document):
The multi-ticket scope unit. Describes what to build at a level larger than a single **Ticket** but smaller than an epic. Files store: `docs/prds/<NNN>-<slug>/prd.md`; notion store: a PRDs row (`Kind = PRD`). Carries one of `Drafting | Open | Done`; editable while `Drafting`, frozen on **Lock** to `Open`.
_Avoid_: epic, story, design doc, plan doc

**Ticket**:
A single unit of work nested under a **PRD**. A vertical slice of behavior. Files store: `docs/prds/<NNN>-<slug>/tickets/<NNN>-<slug>.md`; notion store: a Tickets row related to its PRD. Carries one of `Open | In progress | Done`.
_Avoid_: issue (overloaded with GitHub Issues / Linear), task

**Retro**:
A two-pass document paired one-to-one with each **PRD**. The running form is appended to during the PRD's lifecycle (one entry per **Ticket** close); the synthesized form is written by `/retro` at PRD close, mirroring PRD sections with **Outcome label**s.
_Avoid_: post-mortem, results doc, retrospective

**ADR** (Architectural Decision Record):
A cross-**PRD** durable decision (files store: `docs/adr/<NNNN>-<slug>.md`; notion store: an ADRs row). Created inline during `/grill-me` when all gates of the **Three-gate test** pass.

**Outcome label**:
One of `Exact match | Extended | Divergence | Omitted`. Applied to per-**Ticket** entries in the running **Retro** and to per-section entries in the synthesized **Retro**.

**Plugin-shipped agent**:
A Claude Code subagent shipped by `agentic-flow` at `agents/<name>.md`, namespaced at invocation as `agentic-flow:<name>`. Two classes: **Reviewer agent** and **Workflow agent**. Auto-discovered by the plugin loader.

**Reviewer agent**:
A **Plugin-shipped agent** (or repo-specific subagent at `.claude/agents/<name>.md`) invoked by `/improve-codebase-architecture` for refactor candidate-finding. Listed in the Reviewers manifest (`docs/reviewers.md` or the Reviewers database). Examples: `agentic-flow:qa-engineer`, `agentic-flow:software-architect`, `agentic-flow:security-engineer`.
_Avoid_: linter, expert, sub-agent (when distinguishing role)

**Workflow agent**:
A **Plugin-shipped agent** invoked by a specific skill for a structured analytical task — not user-facing, not a reviewer, not in the Reviewers manifest. Returns output that calling skills depend on by exact shape. Example: `agentic-flow:deviation-fact-checker`, invoked by `/done` and `/retro`.

**Deviation fact-checker**:
The **Workflow agent** (`agentic-flow:deviation-fact-checker`) that compares a ticket diff (or PRD-branch diff) against the ticket's `## Deviations` section. Returns three sections — `Deviation gaps`, `Misrepresented deviations`, `ADR candidates` — each potentially `_None._`. Calling skills (`/done`, `/retro`) depend on the exact shape.

**Three-gate test**:
The criteria used to decide whether a decision warrants an **ADR**. All three must hold: (1) hard to reverse, (2) surprising without context, (3) the result of a real trade-off.

**Bucket folder**:
A subdirectory of `skills/` grouping related skills. Currently `engineering/`, `productivity/`, and `_shared/`. The `_shared/` folder holds **Reference doc**s, not skills.

**Reference doc**:
A markdown document under `skills/_shared/` referenced by one or more skills. Four kinds: **Store doc**s (where planning artifacts live — `STORE.md`, `NOTION-RESOLVER.md`), **Format doc**s (the canonical shape of a document type), **Principle doc**s (cross-cutting rules applying across multiple skills), and **Convention doc**s (a shared procedure consumed by multiple skills). Format and principle docs are distinguished by filename suffix (`-FORMAT.md` / `-PRINCIPLE.md`); store and convention docs carry no suffix.

**Format doc**:
A **Reference doc** at `skills/_shared/<NAME>-FORMAT.md` that defines the canonical shape of an artifact type (PRD, Ticket, Retro, ADR, Glossary, reviewers) — content shape for both stores plus the files-store encoding. Referenced by skills that produce or read those artifacts.

**Principle doc**:
A **Reference doc** at `skills/_shared/<NAME>-PRINCIPLE.md` that captures cross-cutting rules applying across multiple skills. Referenced from the SKILL.md files (and other reference docs) that need to enforce or align with the principle.

**Convention doc**:
A **Reference doc** under `skills/_shared/` that defines a shared procedure consumed by multiple skills — some with a plugin-shipped mechanism at their core (`DIFF-MATERIALIZATION.md`, paired with `scripts/materialize-diff.sh`: the invoking skill resolves the store-dependent inputs, the mechanism owns the deterministic part), some pure procedure (`CLOSE-OUT.md`: consumers bind the variables and cite the mechanics).

**Vertical slice**:
A **Ticket** scope shape: end-to-end behavior across whatever layers it touches (UI → backend → DB), rather than one layer for many features (a horizontal slice). The default for `/to-tickets`.

**Lock** (PRD lock):
The transition from `Drafting → Open` on a **PRD**, triggered by `/to-tickets`. After lock, the PRD is frozen; further changes require a new **PRD**.

**Deviation**:
A divergence between a **Ticket**'s planned approach and what was actually implemented. Captured in the ticket's `## Deviations` section during impl, surfaced in the **Retro** synthesis pass. A `(refactor)` prefix marks deviations from `/improve-codebase-architecture`'s per-ticket pass; the prefix lets `/retro` group refactor work into the synthesized retro's optional `## Refactor` section.

**Active PRD pointer**:
The **Store**'s marker for the **PRD** currently being implemented — files store: a one-line text file at `docs/prds/.active` holding the PRD directory name, `<NNN>-<slug>` (e.g. `001-add-auth`); notion store: the `Active` checkbox on the PRD row (skills enforce single-active by clearing others first). Set by `/to-tickets` at PRD lock, cleared by `/retro` at PRD close *if it still points to the closing PRD* (otherwise left alone, since the user may have manually pointed it elsewhere), manually editable by the user when context-switching between concurrently-`open` PRDs. Not a substitute for PRD `status` — `.active` is "what am I building right now," `status` is "where in its lifecycle is this PRD."

**Config**:
The per-repo configuration for `agentic-flow`: `.agentic-flow/settings.toml`, identical in both stores. Its `[store]` block is the declarative backend selector (`backend = "files" | "notion"`, plus the cached notion `root_page_id`); the rest holds workflow config (merge convention, ticket-start research opener). Read as prose — skills consult only the keys they name; stale keys and comments are inert (STORE.md's config read contract). Created by `/setup-agentic-flow` with every knob present (store selector set, workflow knobs commented until chosen); future options append here. Skills update it as configuration choices materialize.

## Relationships

- A **PRD** contains many **Ticket**s
- A **PRD** is paired with exactly one **Retro**
- A **Ticket** contains zero or more **Deviation**s
- An **ADR** is cross-cutting; not nested under any single **PRD**
- A **Reviewer agent** is dispatched by `/improve-codebase-architecture`, not by individual **Ticket** work
- A **Workflow agent** is invoked by a specific skill (e.g. `/done`, `/retro`); not via the Reviewers manifest
- The **Active PRD pointer** identifies *one* implementation-active **PRD** at a time, even though multiple **PRD**s can be `Open` concurrently

## Flagged ambiguities

- "issue" is avoided because it's overloaded with GitHub Issues / Linear, which `agentic-flow` does not use — collapsed into **Ticket**.
- "epic" is avoided because **PRD** scope is smaller than typical epic scope; the analogy may mislead.
- "phase" was previously used (in the user's prior workflow) to mean both a multi-PRD initiative and a single PRD-sized body of work — resolved: `agentic-flow` uses **PRD** as the top-level unit; "phase" is no longer used.
