---
name: implement
description: Plan-then-execute implementation with a plan-approval gate. Use when building a feature or fixing a bug that isn't test-first, or when TDD doesn't fit the work.
---

# Implement — plan-then-execute

`/implement` is the non-TDD ticket-implementation mode, a peer to [`/tdd`](../tdd/SKILL.md). It produces a plan the user approves, executes it, and — inside an `agentic-flow` ticket — runs the same clean-completion exit tasks as `/tdd`, stopping and surfacing per the shared contract when it hits the always-stop list or a decision it can't responsibly make.

## When this mode fits

Reach for `/implement` when test-first doesn't fit the work: a change with no meaningful executable unit to drive red-green (prose, config, scaffolding, doc corpora), an exploratory or migration slice where the interface is already settled, or anywhere the user asks to plan-then-build rather than test-first. When the work *is* test-shaped, prefer `/tdd` — a failing test is a sharper spec than a plan paragraph, and red-green keeps the implementation honest against real behavior rather than an imagined plan. `/next-ticket` recommends which mode fits a given ticket; this skill owns the plan-then-execute path once that's the call.

## Workflow

### 1. Plan

Explore the code and docs the ticket touches; use the project's domain glossary so your vocabulary matches the repo's, and respect ADRs in the area. Produce a plan the user approves before any code is written: the change's shape (the modules, seams, and interfaces it touches), the steps to get there, and how you'll know it's done.

**Plan-gate discipline.** The plan carries three marks before approval is requested: (1) state whether the design derives from first principles for this problem or from precedent/diff-minimization — "smallest change" is not an argument; argue from the repo's recorded design philosophy (CLAUDE.md weighting, ADRs); (2) mark each load-bearing constraint as **user-stated** or **assumed**; (3) note the strongest alternative shape and why it loses. User approval is a **blocking** checkpoint — present the plan and end the turn; don't start executing in the same breath.

### 2. Execute

Work the approved plan top to bottom. Keep the implementation minimal for the plan as approved — don't anticipate work the plan didn't call for. When execution meets a decision the plan didn't settle, the shared stop-or-record contract governs what happens next (below) — the same seam behavior `/tdd` follows; only how code is produced differs between the two modes.

## Working within an `agentic-flow` ticket

When `/implement` runs inside an in-progress `agentic-flow` ticket, its stop/record behavior and its clean-completion exit tasks follow the shared [IMPLEMENTATION-LOOP.md](../../_shared/IMPLEMENTATION-LOOP.md) contract — cited here, not restated.

**Stop or record a mid-execution divergence.** Outside the always-stop list, a seam- or behavioral-level choice the plan didn't specify but you can responsibly pick is appended to the ticket's `## Deviations` as it emerges and execution continues — store-as-primary means the deviation lands in the store (see [STORE.md](../../_shared/STORE.md)) before `/done` runs, not held back for `/done` to discover; threshold and rationale-placement per [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md). But when the divergence is on the contract's hard always-stop list — its highest-consequence seam moves — or is an unplanned decision you can't responsibly pick, **stop and surface to the user instead of recording and continuing**. The exact triggers live in IMPLEMENTATION-LOOP.md's "Stop or record" section.

**Exit on clean-green completion.** When every planned step is done *and* the repo's full verification passes, fire the contract's exit tasks with no intervening prompt: commit the completed implementation on the ticket branch, then invoke `/done`. Two points this mode leans on, both owned by the contract:
- **Verify with the full build-and-test suite.** "Green" is the whole suite, resolved per IMPLEMENTATION-LOOP.md's "Resolving the repo's verification" — the same check `/done`'s merge gate runs.
- **Stage by explicit paths.** Stage the implementation paths *plus* the ticket file — it carries the riding `In progress` flip and any recorded Deviations — never `-A`; a clean tree lets the auto-invoked `/done` materialize its diff normally instead of misrouting to interrupted close-out (the contract's staging section).

**Don't commit past a stop.** If verification is absent, unrunnable, or red, or a stop-and-surface decision was raised, do **not** auto-commit — surface the manual "implementation complete — commit and run `/done`" prompt and stop, per the contract's graceful-degradation rule.
