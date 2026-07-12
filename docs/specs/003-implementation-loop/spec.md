---
status: done
---

# Codify the implementation loop

## Problem

The per-ticket implementation loop has two codification gaps, both surfaced by the author's observed end-to-end usage (`docs/development-workflow.md`) and deliberately banked out of spec 002 as behavior design rather than slimming.

First, the non-TDD path is uncodified. The ticket-start decision chooses between `/tdd` and *not*-`/tdd`, but the "not" arm is informal behavior — no skill, no stopping rules, no plan discipline. The most-frequently-run part of the loop is its least-specified, and it runs on convention that lives only in the author's head.

Second, two gates in the loop are answered "yes" every time: committing completed implementation on the Ticket branch, and the "run `/done`?" prompt. They are friction that reads as consent but has never once been exercised as a decision — a Ceremony gate in the vocabulary this work settles, distinct from the Consent gates (the merge, the ADR decision, the `/done` outcome label, the refactor-or-merge fork) the same loop genuinely depends on.

## Goals

- A `/implement` skill exists, codifying the non-TDD path as plan-then-execute with explicit stopping rules — a peer to `/tdd`, not a replacement.
- The ticket-start selection between `/tdd` and `/implement` is codified: the ticket-start research step recommends a mode with its reasoning, and the user ratifies it through the plan-approval gate that already exists — no new gate.
- On clean completion — all planned work done **and** the repo's verification green — the implementation loop commits the completed work and invokes `/done` as automatic exit tasks, with no per-completion prompt. Every other terminal state terminates and surfaces to the user instead of committing.
- The confirm-gate doctrine's prose states the Consent-vs-Ceremony test (ADR 0004) everywhere it currently reads as a blanket "offered, never automatic," and those sites stay in agreement.
- Net-fewer prompts on the happy path (the commit prompt and the run-`/done`? prompt gone) with **no** Consent gate lost — the merge, ADR surfacing, outcome label, and refactor-or-merge fork all still block.

## Non-goals

- Session-handoff prescription (`/new` + steering prompt vs. restarting the process) — unresolved in observed use, so nothing proven to codify; its own future spec if it earns one.
- No change to any Consent gate. The merge, ADR surfacing, outcome label, and refactor-or-merge fork stay gated exactly as they are (ADR 0004).
- No new config knob and no new blocking gate for mode selection — it rides the plan-approval gate.
- No change to `/tdd`'s red-green-refactor cycle. (`/tdd` does gain the shared stop-and-surface trigger and the completion exit tasks — additions around the cycle, not changes to it.)

## Approach

Governed by ADR 0004: the confirm-gate doctrine is scoped to actions that are hard to reverse, outward-facing, or information-destroying, so the Ticket-branch commit and the `/done` invocation — both local and reversible — may be automated while every Consent gate stays. The Approach implements that decision; it does not re-derive it.

**`/implement` — the non-TDD path.** A plan-then-execute skill sharing one stop/record contract with `/tdd`, built from the existing behavioral/seam threshold (the in-scope capture list in `ABSTRACTION-LEVELS-PRINCIPLE`) but splitting *recording* from *stopping* — the threshold is a post-hoc classification line, so applying it directly as an in-flight stop rule over-surfaces:

- **Record-and-continue** — a seam/behavioral choice the approved plan didn't specify but the agent can responsibly pick is recorded as a Deviation and execution proceeds; `/done`'s post-commit review ratifies it. This is the threshold's native post-hoc role, already `/tdd`'s behavior.
- **Stop-and-surface** — execution blocks and returns to the user on the union of a **hard always-stop list** (a new/deleted/split/merged module, a public-API boundary-signature change, or an IO-surface change the plan didn't name — unconditional, even if the agent thinks it can pick) and a **decidability test** (any other unplanned decision the agent cannot responsibly pick: a genuine fork, a ticket contradiction, a missing requirement).

Once the commit gate is automated, stop-and-surface becomes the loop's pre-code consent surface — where design decisions are ratified before code lands. Both mechanisms belong to both loops: `/tdd`, now auto-committing, gains stop-and-surface so it can't commit past a blocking fork. This narrows `/tdd`'s existing "append divergences as they emerge" prose (its "Working within an pirr ticket" section): the always-stop subset now stops rather than record-and-continuing, so the skill carries no contradictory in-flight instruction.

**Mode selection.** `/next-ticket`'s ticket-start research step already assesses whether `/tdd` fits; it is extended to recommend `/tdd` or `/implement` with reasoning (per the recommendation-with-reasoning rule). The chosen mode produces its mode-specific plan, which the user approves at the plan-approval gate that already exists and already blocks — mode disagreement is expressed by rejecting the plan and asking for the other mode. No standalone mode gate is added.

**Exit tasks.** On clean completion — all planned work done and the repo's verification green — `/tdd` and `/implement` commit the completed implementation on the Ticket branch and invoke `/done`, with no intervening prompt. "The repo's verification" resolves from the same sources the merge convention uses (`settings.toml` / the repo's `CLAUDE.md` / a project verify skill), never improvised, and means the same check the merge gate runs — one convention, two consumers; the full build + suite runs even in `/tdd` mode. Green is a *positive* signal: no verification configured or runnable → the loop does **not** auto-commit but surfaces the manual commit-and-`/done` prompt (today's behavior); a red result, even an intermittent one, → surface, never commit. Any other terminal state (an undesigned decision surfaced, a problem hit) likewise surfaces instead of committing.

Pre-commit diff review does not disappear; it relocates to `/done`'s deviation-fact-checker + spec-conformance pass, which the user still ratifies at `/done`'s own gates. Auto-invoking `/done` is **not** auto-merge: `/done` proceeds through its internal Consent gates and stops at the refactor-or-merge fork as it does today, and requires `/done` to remain model-invocable, which it is (its frontmatter carries no `disable-model-invocation`, preserved by spec 002). The skill-invokes-skill pattern is undocumented in Claude Code but **empirically verified working** (a scratch-session test on CLI v2.1.207 confirmed an active skill's exit instruction autonomously invokes another skill via the Skill tool). Because it is undocumented and could regress across CLI versions, auto-invoke still degrades gracefully — if it ever fails to fire, the loop surfaces "implementation complete — run `/done`", today's manual step. This makes spec 003 the plugin's first autonomous skill-to-skill invocation, adopted deliberately under ADR 0004.

The stop/record contract and the exit tasks are shared behavior across `/tdd` and `/implement` and live in one new Convention doc (`IMPLEMENTATION-LOOP.md`, name provisional) that both skills cite — not a fold into `CLOSE-OUT.md`, whose *gated* commit is a categorically different animal from the exit-task's *ungated* auto-commit. `IMPLEMENTATION-LOOP.md` also owns the resolution of "the repo's verification" (the `settings.toml` / `CLAUDE.md` / project-verify-skill sources named above).

The exit-task's staging contract is load-bearing and must be explicit. The `Open → In progress` flip that `/next-ticket` wrote earlier is an uncommitted store edit that, per `STORE.md`, rides the ticket's next real commit — and the exit-task's implementation commit *is* that commit. So the exit-task stages the implementation paths **plus** the ticket file (carrying the riding `In progress` flip and any Deviations recorded mid-run), by explicit paths, never `-A`. This leaves a clean tree for the auto-invoked `/done`: staging implementation-only would leave the flip dirty, and `/done` would misread an only-store-artifact-dirty tree as an *interrupted close-out* and resume a close that never started. The later gated store-edit commit inside `/done` (the `→ Done` flip, the retro entry, close-out deviations) stays distinct and gated.

**Doctrine prose.** The one site stating the doctrine as a *blanket* claim — the plugin README's design note, "git mutations are offered, never automatic" — is refined to state the Consent-vs-Ceremony test, in sync with ADR 0004. `CLOSE-OUT.md` is **not** given the automatable-ceremony rule: its own commit and merge gates are all Consent and stay gated, so dropping "ceremony may be automated" into it would read as a contradiction. It gains at most a one-line pointer that its gates are Consent under the ADR-0004 test. Spec 003 automates no `CLOSE-OUT.md` gate; whether any (e.g. `/done`'s step-10 close-out commit) is itself ceremony is out of scope — a future spec's question.

## Modules touched

- **`/implement`** — new Lifecycle-layer skill in the `engineering/` bucket: the plan-then-execute non-TDD path, citing the shared stop/record contract and exit tasks. Listed in the plugin README and the `engineering/` bucket README.
- **`/tdd`** — gains the shared stop-and-surface trigger and the completion exit tasks (auto-commit + auto-`/done` on done + green); its existing "append divergences as they emerge" prose is narrowed so the always-stop subset stops; red-green-refactor cycle untouched.
- **`/next-ticket`** — the ticket-start research step recommends `/tdd` vs `/implement` with reasoning.
- **`/done`** — no change to its gates; consumed as an auto-invoked exit task, with model-invocability preserved.
- **`CLOSE-OUT.md`** — gains at most a one-line pointer that its own commit/merge gates are Consent under the ADR-0004 test; no gate is automated here.
- **Plugin README design notes** — the blanket "offered, never automatic" rule refined to the Consent-vs-Ceremony test (in sync with ADR 0004).
- **Plugin README "The workflow" diagram + skill one-liners** — the diagram (hardcodes "work the ticket: /tdd" and a manually-invoked `/done`) and the `/tdd` list entry drift under mode-selection + auto-commit + auto-`/done`; both are updated.
- **`IMPLEMENTATION-LOOP.md`** — new Convention doc (name provisional) owning the shared stop/record contract and the exit tasks; cited by both `/tdd` and `/implement`.
- **Glossary (`CONTEXT.md`)** — *Consent gate* / *Ceremony gate* (added during this grill).
