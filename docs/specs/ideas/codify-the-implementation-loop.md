# Codify the implementation loop

Source: `docs/development-workflow.md` (the author's observed end-to-end usage, saved 2026-07-09) — grill that doc when promoting this.

Two codifications the workflow doc motivates, deliberately banked out of PRD 002 (slimming) because both are behavior design, not slimming:

- **An `implement` skill and a tdd-or-implement gate.** Today the "not-tdd" path is informal. Codify it: plan-then-execute with explicit stopping rules — stop when complete, or when an issue or undesigned decision needs the user, then terminate and surface. The ticket-start gate then chooses between `/tdd` and `/implement` (with reasoning, per the recommendation rule).
- **Auto-commit + auto-`/done` as implementation exit tasks.** The observed pattern: the commit gate and the "run /done?" question are always answered yes, so the loop should commit on completion and invoke `/done` automatically. This is a real doctrine change — "git mutations are offered, never automatic" — and needs its own grill, not a rider. Mechanics note, verified against Claude Code docs 2026-07-09: auto-invocation requires `/done` to remain model-invocable (a `disable-model-invocation` skill's description never enters context), which PRD 002's model-invocation decision preserves.

Open observation to carry into the grill: session-handoff style — when does `/new` + steering prompt get chosen over killing the process and starting fresh, and should the workflow prescribe one?
