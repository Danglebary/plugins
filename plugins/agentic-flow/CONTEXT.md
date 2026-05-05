# agentic-flow

A Claude Code plugin (slash commands and behaviors) supporting a four-phase workflow for AI-augmented software development: Plan → Implement → Refactor / Cleanup → Retro. Built on a hierarchy of **PRD** → **Ticket** → **Retro**, with cross-cutting **ADR**s and a living **CONTEXT.md** glossary in each consuming repo.

## Language

**PRD** (Product Requirements Document):
The multi-ticket scope unit. A frozen artifact (`prd.md`) describing what to build at a level larger than a single **Ticket** but smaller than an epic. Carries one of `drafting | open | done`. Lives at `docs/prds/<NNN>-<slug>/prd.md`.
_Avoid_: epic, story, design doc, plan doc

**Ticket**:
A single unit of work nested under a **PRD**. A vertical slice of behavior. Lives at `docs/prds/<NNN>-<slug>/tickets/<NNN>-<slug>.md`. Carries one of `open | in-progress | done`.
_Avoid_: issue (overloaded with GitHub Issues / Linear), task

**Retro**:
A two-pass document paired one-to-one with each **PRD**. The running form is appended to during the PRD's lifecycle (one entry per **Ticket** close); the synthesized form is written by `/retro` at PRD close, mirroring PRD sections with **Outcome label**s.
_Avoid_: post-mortem, results doc, retrospective

**ADR** (Architectural Decision Record):
A cross-**PRD** durable decision recorded at `docs/adr/<NNNN>-<slug>.md`. Created inline during `/grill-me` when all gates of the **Three-gate test** pass.

**Outcome label**:
One of `Exact match | Extended | Divergence | Omitted`. Applied to per-**Ticket** entries in the running **Retro** and to per-section entries in the synthesized **Retro**.

**Plugin-shipped agent**:
A Claude Code subagent shipped by `agentic-flow` at `agents/<name>.md`, namespaced at invocation as `agentic-flow:<name>`. Two classes: **Reviewer agent** and **Workflow agent**. Auto-discovered by the plugin loader; not listed in `plugin.json`.

**Reviewer agent**:
A **Plugin-shipped agent** (or repo-specific subagent at `.claude/agents/<name>.md`) invoked by `/improve-codebase-architecture` for refactor candidate-finding. Listed in `docs/reviewers.md`. Examples: `agentic-flow:qa-engineer`, `agentic-flow:software-architect`, `agentic-flow:security-engineer`.
_Avoid_: linter, expert, sub-agent (when distinguishing role)

**Workflow agent**:
A **Plugin-shipped agent** invoked by a specific skill for a structured analytical task — not user-facing, not a reviewer, not in `docs/reviewers.md`. Returns output that calling skills depend on by exact shape. Example: `agentic-flow:deviation-fact-checker`, invoked by `/done` and `/retro`.

**Deviation fact-checker**:
The **Workflow agent** (`agentic-flow:deviation-fact-checker`) that compares a ticket diff (or PRD-branch diff) against the ticket's `## Deviations` section. Returns three sections — `Deviation gaps`, `Misrepresented deviations`, `ADR candidates` — each potentially `_None._`. Calling skills (`/done`, `/retro`) depend on the exact shape.

**Three-gate test**:
The criteria used to decide whether a decision warrants an **ADR**. All three must hold: (1) hard to reverse, (2) surprising without context, (3) the result of a real trade-off.

**Bucket folder**:
A subdirectory of `skills/` grouping related skills. Currently `engineering/`, `productivity/`, and `_shared/`. The `_shared/` folder is for **Format doc**s only, not skills.

**Format doc**:
A reference document at `skills/_shared/<NAME>-FORMAT.md` that defines the canonical shape of a document type (PRD, Ticket, Retro, ADR, CONTEXT, reviewers). Referenced by skills that produce or read those documents.

**Vertical slice**:
A **Ticket** scope shape: end-to-end behavior across whatever layers it touches (UI → backend → DB), rather than one layer for many features (a horizontal slice). The default for `/to-tickets`.

**Lock** (PRD lock):
The transition from `drafting → open` on a **PRD**, triggered by `/to-tickets`. After lock, the `prd.md` is frozen; further changes require a new **PRD**.

**Deviation**:
A divergence between a **Ticket**'s planned approach and what was actually implemented. Captured in the ticket's `## Deviations` section during impl, surfaced in the **Retro** synthesis pass. A `(refactor)` prefix marks deviations from `/improve-codebase-architecture`'s per-ticket pass; the prefix lets `/retro` group refactor work into the synthesized retro's optional `## Refactor` section.

**Active PRD pointer**:
A one-line text file at `docs/prds/.active` containing the slug of the **PRD** currently being implemented (e.g. `001-add-auth`). Set by `/to-tickets` at PRD lock, cleared by `/retro` at PRD close, manually editable by the user when context-switching between concurrently-`open` PRDs. Not a substitute for PRD `status` — `.active` is "what am I building right now," `status` is "where in its lifecycle is this PRD."

**`docs/agentic-flow.toml`**:
The per-repo configuration file for `agentic-flow`. Created by `/setup-agentic-flow` with all options present (defaults uncommented, alternatives commented). Currently holds branching strategy (`serial` vs `stacked`); future options append here. Skills update it as configuration choices materialize.

## Relationships

- A **PRD** contains many **Ticket**s
- A **PRD** is paired with exactly one **Retro**
- A **Ticket** contains zero or more **Deviation**s
- An **ADR** is cross-cutting; not nested under any single **PRD**
- A **Reviewer agent** is dispatched by `/improve-codebase-architecture`, not by individual **Ticket** work
- A **Workflow agent** is invoked by a specific skill (e.g. `/done`, `/retro`); not via `docs/reviewers.md`
- The **Active PRD pointer** identifies *one* implementation-active **PRD** at a time, even though multiple **PRD**s can be `open` concurrently

## Flagged ambiguities

- "issue" is avoided because it's overloaded with GitHub Issues / Linear, which `agentic-flow` does not use — collapsed into **Ticket**.
- "epic" is avoided because **PRD** scope is smaller than typical epic scope; the analogy may mislead.
- "phase" was previously used (in the user's prior workflow) to mean both a multi-PRD initiative and a single PRD-sized body of work — resolved: `agentic-flow` uses **PRD** as the top-level unit; "phase" is no longer used.
