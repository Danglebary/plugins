# Implementation loop — the shared stop/record and exit-task contract

Two skills implement a ticket: `/tdd` (red-green-refactor) and `/implement` (plan-then-execute). They differ in how they produce code; at the seams *around* the code — when to stop for the user mid-flight, and what to do on clean completion — they behave identically. That shared behavior lives here, stated once; both skills **cite** it and never restate it. Governed by [ADR 0004](../../../../docs/adr/0004-confirm-gate-doctrine-scope.md): the commit of completed work on a ticket branch and the `/done` invocation are *ceremony* — local, reversible, automatable — while every Consent gate the loop depends on (the merge, the ADR decision, `/done`'s outcome label, the refactor-or-merge fork) stays gated. This doc implements that decision; it does not re-derive it.

## Stop or record — the two-mechanism contract

An implementing agent works an approved plan. When it meets a decision the plan didn't settle, one of two things happens.

**Record-and-continue.** A seam- or behavioral-level choice the plan didn't specify but the agent can responsibly pick is **recorded as a `## Deviations` entry and execution proceeds** — `/done`'s post-commit deviation-fact-checker and spec-conformance pass ratify it after the fact. This is the deviation threshold's native post-hoc role (the in-scope capture list in [ABSTRACTION-LEVELS-PRINCIPLE.md](./ABSTRACTION-LEVELS-PRINCIPLE.md)) applied as designed — a classification line for *what to record*, not a tripwire for *when to stop*.

**Stop-and-surface.** Execution **blocks and returns to the user** on the union of two triggers:

- The **hard always-stop list** — a new/deleted/split/merged module, a public-API boundary-signature change, or an IO-surface change the plan didn't name. Unconditional: the agent stops even when it believes it could pick correctly. This list is a strict *subset* of the deviation threshold's capture set — the highest-consequence seam moves, carved out to stop rather than merely record.
- The **decidability test** — any other unplanned decision the agent cannot responsibly pick: a genuine fork with no clear winner, a ticket that contradicts itself, a requirement the plan needs but doesn't supply.

Applying the full capture list as a stop rule would over-surface — the threshold classifies far more than a human needs to adjudicate mid-flight. Splitting *recording* (the whole list, post-hoc) from *stopping* (the always-stop subset plus the decidability test, in-flight) is the point of this contract. Once the commit gate is automated (below), stop-and-surface **is** the loop's pre-code consent surface: where a design decision is ratified before any code lands.

## Exit tasks — auto-commit and auto-`/done` on clean completion

**Trigger — both conditions, together:** all planned work is done **and** the repo's verification is green. On that positive signal, with no intervening prompt, the loop commits the completed implementation on the ticket branch, then invokes `/done`. Neither step is gated — both are ceremony under ADR 0004, fired only on the clean-green signal, never on the loop merely stopping.

### The staging contract

Stage **all implementation paths the ticket touched, plus the ticket file**, by explicit paths — `git add <path> <path>`, never `-A`, never `git add .`.

The ticket file is not optional. The `Open → In progress` flip `/next-ticket` wrote earlier is an uncommitted store edit that, per [STORE.md](./STORE.md#writes-edits-and-git), rides the ticket's next real commit — and this *is* that commit; it also carries any `## Deviations` recorded mid-run. Staging implementation-only leaves that flip dirty, and the auto-invoked `/done` then sees a tree dirty in **only** store-artifact paths — which it reads as an *interrupted close-out* and resumes a close that never started ([RECOVERY.md](./RECOVERY.md#resting-states)). Staging the implementation and the ticket file together leaves a clean tree, so `/done` materializes its diff normally. Enumerate *all* implementation paths: any left unstaged stays tracked-dirty and trips the same misroute.

### Graceful degradation — the signal must be positive

Green is a **positive** signal, never an assumed one. The loop auto-commits only when verification actually ran and passed. Otherwise it does **not** auto-commit — it surfaces the manual "implementation complete — commit and run `/done`" prompt (today's behavior) and stops:

- **No verification configured, or configured but unrunnable** → surface, don't commit.
- **Verification red, even intermittently** → surface, never commit.
- **Any other terminal state** — a stop-and-surface decision raised, a problem hit → surface, never commit.
- **Auto-invoke of `/done` fails to fire** — the skill-to-skill invocation is empirically working but undocumented in Claude Code and could regress across CLI versions → the loop has already committed; it surfaces "implementation complete — run `/done`", today's manual step. The commit is not lost; only the hand-off degrades.

## Resolving "the repo's verification"

"The repo's verification" is the **full build and test suite** — the same check `/done`'s merge gate runs ([CLOSE-OUT.md](./CLOSE-OUT.md#the-gated-merge)): one verification convention serving both the exit task here and the merge gate there. It runs in full even in `/tdd` mode, where the inner loop exercised only focused tests. It is **resolved, never improvised**, from three sources — first match wins:

1. **A project verify skill** — the repo's own `/verify`-style skill, if it ships one. Purpose-built and executable, it is the least-ambiguous statement of how to verify this repo, so it wins.
2. **A verification key in `.pirr/settings.toml`** — explicit structured config.
3. **A verification convention stated in the repo's `CLAUDE.md`** — prose, the interpretation-prone fallback.

No source resolves → no verification is configured → the loop degrades per above (surface, don't commit). Both loop skills resolve it the same way, so `/tdd` and `/implement` can never disagree on what "green" means.

## The commit boundary — this is the implementation commit, not the close-out commit

The exit-task's auto-commit is the **implementation commit on the ticket branch**: code plus the riding ticket-file flip, ungated ceremony. It is categorically distinct from the **gated store-edit commit inside `/done`** ([CLOSE-OUT.md](./CLOSE-OUT.md#the-gated-store-commit)) — the `→ Done` flip, the retro entry, and close-out deviations — which stays a Consent gate. Two commits, two branches of the doctrine: this one automated because it is local and reversible, that one gated because the close it seals is the user's to ratify. Folding this contract into `CLOSE-OUT.md` would collapse the distinction; they stay separate docs.

## Consumers

`/tdd` and `/implement` — the two ticket-implementation modes. Each cites this contract for its stop/record behavior and its exit tasks rather than restating the mechanics. `/next-ticket` recommends *which* mode fits a ticket but does not consume this contract; mode selection is its own concern.
