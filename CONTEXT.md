# danglebary-plugins

A Claude Code plugin marketplace repo. Its main plugin, `agentic-flow`, ships a prose-only PRD → Ticket → Retro workflow with ADRs, a living Glossary, and refactor-time reviewer agents; planning artifacts live behind a store seam with files and Notion backends. This repo dogfoods that workflow on its own development.

## Language

**Personal workflow**:
The workflow agentic-flow itself ships: single-user repos where the plugin performs local merges at close-out gates (ticket branch → PRD branch at `/done`, PRD branch → default branch at `/retro`). agentic-flow's lifecycle skills are single-path — they assume this workflow unconditionally (ADR 0001).
_Avoid_: "solo mode" (a rejected config-axis framing — separation is by plugin, not by setting).

**Work workflow**:
The planned separate plugin for collaborative, PR-based repos: tickets sourced from Jira, an optional Notion PRD linked via a Jira epic, a no-PRD track for assigned tickets, and a close-out that ends in a pull request rather than a merge — the plugin never merges. Composes with agentic-flow's **Knowledge layer** by invoking its skills.
_Avoid_: "team mode" (rejected config-axis framing); "day-job mode".

**Knowledge layer**:
The lifecycle-agnostic subset of agentic-flow that both workflows share: `/next-prd`, `/grill-me`, `/to-prd`, `/tdd`, the Glossary, ADRs, reviewer agents, and the deviation fact-checker. A cross-plugin API surface — these skills must not assume either workflow's close-out mechanics.
_Avoid_: "shared skills" without qualification (ambiguous with `skills/_shared/`, which holds reference docs, not skills).

**Lifecycle layer**:
The workflow-specific skills that move PRDs and tickets through their states and integrate code: `/to-tickets`, `/next-ticket`, `/done`, `/improve-codebase-architecture`, `/retro`. Each plugin ships its own.

**Store backend**:
Where planning artifacts (PRDs, tickets, retros, Glossary, ADRs) live — `files` (in-repo markdown) or `notion` (databases under a root page). A storage choice only; carries no workflow semantics.
_Avoid_: "backend" for anything other than artifact storage.

## Relationships

- The **Personal workflow** and the **Work workflow** are separate plugins; each ships its own **Lifecycle layer**.
- Both workflows share agentic-flow's **Knowledge layer** by skill invocation, never by forking.
- The **Store backend** is orthogonal to which workflow a repo uses.

## Flagged ambiguities

- "day-job vs. personal project" was initially conflated with the notion-vs-files store choice, then briefly modeled as a `settings.toml` workflow-mode axis, and settled as separate plugins (ADR 0001) once grilling showed the divergence spans the whole lifecycle layer — Jira ticket source, no-PRD track, PR-based close-out (2026-07-08).
