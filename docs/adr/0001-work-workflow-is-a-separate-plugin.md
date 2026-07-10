---
status: accepted
---

# 0001 — The work workflow is a separate plugin, not a mode

## Context

Designing close-out correctness surfaced a personal-vs-work workflow split. The first framing considered made it an explicit `settings.toml` axis (`Solo` / `Team` workflow mode), on the theory that the divergence was confined to close-out integration behavior. Continued grilling enumerated the real divergence at the user's workplace: tickets live in Jira (a per-artifact store split — PRDs in Notion, tickets elsewhere — that the store seam cannot express), a substantial share of work arrives as assigned tickets with no PRD at all, each ticket runs in a fresh per-ticket environment, and close-out is a draft-PR → self/agent review → open-PR → Slack-post → teammate-review → manual-GitHub-merge sequence with employer-specific formats.

That divergence spans the entire lifecycle layer (`/to-tickets`, `/next-ticket`, `/done`, `/retro`) structurally, not just a close-out tail. Mode-conditional skills would carry two full procedures in every executor's context — the confusion-vector and skipped-step failure mode the 2026-07-07 whole-plugin review identified as this plugin's weakest point. Meanwhile the knowledge layer (`/next-prd`, `/grill-me`, `/to-prd`, `/tdd`, glossary, ADRs, reviewer agents, deviation fact-checker) is genuinely lifecycle-agnostic.

## Decision

The personal and work workflows are separate plugins. agentic-flow remains the personal workflow with **no workflow-mode conditionals**: its lifecycle skills perform local merges at close-out gates, single-path. The work workflow will be a separate plugin (likely work-private, not in this public marketplace) that ships its own lifecycle skills and composes with agentic-flow's knowledge layer by invoking those skills, never forking them.

## Consequences

- No workflow-mode axis in `settings.toml`; agentic-flow skill prose stays single-path, which directly simplifies the close-out-correctness PRD.
- agentic-flow's knowledge-layer skills become a cross-plugin API: they must stay lifecycle-agnostic (no assuming the solo close-out), and changes to them can silently break the work plugin — a new sync-set spanning two repos.
- Two installed plugins will have similar lifecycle skill names/triggers (`done`, `next-ticket`); auto-invocation collisions need explicit naming/trigger discipline in the work plugin.
- Divergent formats (Jira ticket encoding vs `TICKET-FORMAT.md`) are new content, not duplication — the fork cost is smaller than it appears.
- The work plugin is unbuilt; its design (Jira integration, the no-PRD track, absorbing vetted fragments of range-dev) is banked as future work and depends on a range-dev vetting spike.

## Alternatives considered

- **Config axis on one plugin (a `settings.toml` workflow mode).** Rejected once the divergence proved structural across the lifecycle layer rather than tail-only; mode-conditional prose in every lifecycle skill is the review's documented confusion failure mode.
- **Full fork — two independent plugins.** Rejected: duplicates the knowledge layer, doubling every contract sync-set — institutionalizing the cross-doc drift the review ranked as defect cluster #4.
- **One plugin, two skill buckets (`solo/`, `team/`).** Rejected: employer-specific content (Slack post formats, Jira conventions) does not belong in a public personal marketplace repo, and the two workflows version independently.
