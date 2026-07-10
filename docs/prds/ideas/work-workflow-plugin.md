# Work workflow plugin

A separate plugin for the Work workflow (ADR 0001) — collaborative, PR-based repos — composing with agentic-flow's Knowledge layer by skill invocation, never forking it. Likely lives in a work-private repo, not this public marketplace.

Requirements gathered during the 2026-07-08 grill:

- **Tickets live in Jira**, not the agentic-flow store — a per-artifact split (PRDs/retros in Notion, tickets in Jira) the current store seam cannot express. Self-planned track: mint the PRD in Notion → create a Jira epic for it → create Jira tickets linked to epic and PRD.
- **A no-PRD track**: much work arrives as assigned Jira tickets planned by others (possibly in someone else's epic); the per-ticket lifecycle must run without an active PRD.
- **Two branch topologies**: flat (each ticket branches from the default branch, one PR per ticket straight to main) and feature-branch epics (a long-lived branch analogous to a PRD branch, ticket PRs stacked against it — review latency makes stacking necessary here in a way it never is in the Personal workflow).
- **Close-out never merges.** The sequence: draft PR → self-review + fresh-agent review → open PR → post to Slack (employer-required format) → teammate review → manual merge in GitHub. Fresh environment (coder box) per ticket.
- **First step is a vetting spike over the range-dev plugin**: analyze its skills (start-issue's worktree/branch mechanics, post-slack-pr's required format, commit/PR conventions) and decide what to absorb as vetted fragments vs. build fresh — do not delegate to it sight-unseen. Spike findings feed this idea's promotion to a PRD.
