# danglebary-plugins

A Claude Code plugin marketplace repo. Its main plugin, `agentic-flow`, ships a Spec → Ticket → Retro workflow with ADRs, a living Glossary, and refactor-time reviewer agents; planning artifacts live in a per-repo store of in-repo markdown files. This repo dogfoods that workflow on its own development.

## Language

**Personal workflow**:
The workflow agentic-flow itself ships: single-user repos where the plugin performs local merges at close-out gates (ticket branch → spec branch at `/done`'s close-out fork or its deferred `/improve-codebase-architecture` pass, spec branch → default branch at `/retro`). agentic-flow's lifecycle skills are single-path — they assume this workflow unconditionally (ADR 0001).
_Avoid_: "solo mode" (a rejected config-axis framing — separation is by plugin, not by setting).

**Work workflow**:
The planned separate plugin for collaborative, PR-based repos: tickets sourced from Jira, an optional Notion PRD linked via a Jira epic, a no-PRD track for assigned tickets, and a close-out that ends in a pull request rather than a merge — the plugin never merges. Composes with agentic-flow's **Knowledge layer** by invoking its skills.
_Avoid_: "team mode" (rejected config-axis framing); "day-job mode".

**Knowledge layer**:
The lifecycle-agnostic subset of agentic-flow that both workflows share: `/next-spec`, `/grill-me`, `/to-spec`, `/tdd`, the Glossary, ADRs, reviewer agents, and the deviation fact-checker. A cross-plugin API surface — these skills must not *perform* either workflow's close-out mechanics (no merges, no lifecycle gates). Advisory git reads are compatible: the unmerged spec-branch sweep (`spec-*` and legacy `prd-*`) and numbering's branch scan follow the branch-link conventions where present and are inert where they're absent — they warn or reserve, never gate.
_Avoid_: "shared skills" without qualification (ambiguous with `skills/_shared/`, which holds reference docs, not skills).

**Lifecycle layer**:
The workflow-specific skills that move specs and tickets through their states and integrate code: `/to-tickets`, `/next-ticket`, `/done`, `/improve-codebase-architecture`, `/retro`. Each plugin ships its own.

**Store backend**:
Where planning artifacts (specs, tickets, retros, Glossary, ADRs) live. Settled 2026-07-09 (PRD 002): `files` (in-repo markdown) is the only backend — the notion backend is removed from agentic-flow, preserved at a pinned pre-removal commit referenced in the work-workflow idea, not as a live file. A storage choice only; carries no workflow semantics.
_Avoid_: "backend" for anything other than artifact storage; "store backend" for the Work workflow's per-artifact sourcing (Jira tickets, Notion specs) — a split the seam never expressed (ADR 0001).

## Relationships

- The **Personal workflow** and the **Work workflow** are separate plugins; each ships its own **Lifecycle layer**.
- Both workflows share agentic-flow's **Knowledge layer** by skill invocation, never by forking.
- The **Store backend** is orthogonal to which workflow a repo uses.

## Flagged ambiguities

- "day-job vs. personal project" was initially conflated with the notion-vs-files store choice, then briefly modeled as a `settings.toml` workflow-mode axis, and settled as separate plugins (ADR 0001) once grilling showed the divergence spans the whole lifecycle layer — Jira ticket source, no-PRD track, PR-based close-out (2026-07-08).
- "keep the notion resolver for the Work plugin" was weighed as park-the-file vs. delete-with-pinned-history and settled as delete: git history is the archive, and the Work plugin's storage gets a first-principles design rather than inheriting the resolver's shape (2026-07-09, PRD 002).
- "PRD" named agentic-flow's scope unit through its first two dogfood rounds — renamed **Spec** (PRD 002, ticket 002): the artifact is a frozen scope document, not a product-requirements doc. Legacy `prd-*` branches (including this repo's own in-flight ones) stay resolvable via the plugin's branch-link fallback; dated planning history keeps the old wording (2026-07-09).
