---
status: accepted
---

# 0004 — The confirm-gate doctrine is scoped to irreversible, outward-facing, or information-destroying actions

## Context

agentic-flow's close-out doctrine states that git mutations are "offered, never automatic" — an unanswered offer blocks, and the merge is "the user's control point" (`CLOSE-OUT.md`, the README design notes). In observed usage (`docs/development-workflow.md`), two gates in the per-ticket loop are answered "yes" every time: the commit of completed implementation on the ticket branch, and the "run `/done`?" prompt. The "codify the implementation loop" work proposes automating both — a direct collision with a doctrine phrased as a blanket rule, which is what forced this decision.

Read against the doctrine's *own* stated rationale ("the merge is the user's control point"), the two flagged gates miss it. A commit on a never-pushed ticket branch is trivially reversible (amend / reset / rebase). Invoking `/done` mutates nothing irreversibly — and auto-invoking `/done` is **not** auto-merge: `/done` retains its own internal gates (ADR surfacing, outcome label, the gated close-out store-commit, the refactor-or-merge fork), all of which still block. The doctrine taken literally as "every git mutation is gated" over-applies; taken as "the irreversible / outward-facing control points are the user's" it is exactly right, and the literal reading is what needed correcting.

## Decision

The confirm-gate doctrine is scoped to actions that are **hard to reverse, outward-facing (visible to others), or information-destroying**. A confirm gate is load-bearing *consent* when its action meets at least one of those three; it is *ceremony* when the action is local, reversible, and its "no" branch never fires and would change nothing if it did. Ceremony gates may be automated; consent gates never are.

By this test: the merge, the ADR decision, the `/done` outcome label, and the refactor-or-merge fork remain consent gates. Committing completed work on a ticket branch and invoking `/done` are ceremony gates — automated, fired only on a positive clean-completion signal (all planned work done **and** the repo's verification green), never on the loop merely stopping.

## Consequences

- The implementation-loop work can auto-commit completed implementation and auto-invoke `/done` as the loop's exit tasks without violating the doctrine.
- Pre-commit diff review does not vanish — it moves to `/done`'s automated deviation-fact-checker + spec-conformance pass, which the user still ratifies at `/done`'s own gates. A deliberate shift from manual-pre-commit review to automated-post-commit-you-ratify review.
- Every failure or ambiguity path (an undesigned decision surfaced, a problem hit, verification red) still terminates and surfaces to the user. Automation reaches only the clean, green completion path.
- The doctrine now needs a stated *test* wherever it is expressed, not a blanket "never automatic." The prose sites (`CLOSE-OUT.md`, the README design notes, and any skill gate prose that restates the blanket form) become a sync-set for this refinement.
- The distinction governs the future Work plugin too (ADR 0001): a PR-based close-out has more outward-facing actions (opening PRs, Slack posts), so its consent gates differ — but the same three-part test decides which.
- Risk: the test rests on judgment about "reversible" and "outward-facing." A gate misclassified as ceremony could automate away a real consent point. The test is a guide, not a mechanical proof.

## Alternatives considered

- **Keep the blanket doctrine ("all git mutations offered, never automatic").** Rejected: it imposes ceremony for actions that are local and reversible, and observed usage shows two such gates never once exercised — friction with no consent value.
- **Automate the two gates ad hoc, with no stated principle.** Rejected: the next contributor (and the Work plugin) would have no way to classify the next gate, and "auto-commit" would read as a naked contradiction of the doctrine with no reconciliation on record — precisely the surprising-without-context an ADR exists to prevent.
- **Treat the pre-commit commit gate as load-bearing (a diff-review forcing function) and keep it manual.** Rejected as the default, but its concern is honored: review relocates to `/done` rather than being dropped, so the forcing function survives by relocation, not by keeping the gate.
