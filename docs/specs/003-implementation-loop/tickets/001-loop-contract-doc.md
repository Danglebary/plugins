---
status: done
depends_on: []
---

# Loop contract doc

## Goal

A single shared Convention doc defines the implementation loop's contract so that `/tdd` and `/implement` behave identically at the seams they share. It specifies three things: (1) the **stop/record split** — a seam- or behavioral-level choice the approved plan didn't make is recorded as a Deviation and execution continues when the agent can responsibly pick, but execution stops and surfaces to the user on the hard always-stop list or when the decision is otherwise undecidable; (2) the **exit-tasks** — on clean completion (all planned work done and the repo's verification green) the loop commits the completed implementation and invokes `/done`, with the staging and degradation rules below; (3) how **"the repo's verification"** resolves. The doc is authored here but cited by no skill yet — tickets 002 and 003 wire it in.

## Acceptance criteria

- [ ] A Convention doc (provisional name `IMPLEMENTATION-LOOP.md`) exists in the shared reference-doc location, consumed by citation — mechanics stated once here, not restated by consumers.
- [ ] It specifies the two-mechanism stop/record contract, including the hard always-stop list verbatim: a new/deleted/split/merged module, a public-API boundary-signature change, or an IO-surface change the plan didn't name — stop unconditionally; plus the decidability test for everything else unplanned.
- [ ] It specifies the exit-task trigger (all planned work done **and** the repo's verification green) and the explicit staging contract: stage the implementation paths **plus** the ticket file (the riding `In progress` flip and any mid-run Deviations), by explicit paths, never `-A`, so the auto-invoked `/done` sees a clean tree.
- [ ] It specifies graceful degradation: if auto-invoke doesn't fire, or verification is absent/unrunnable/red, the loop surfaces the manual commit-and-`/done` prompt and does not auto-commit.
- [ ] It specifies how "the repo's verification" resolves, reusing the merge convention's sources (`settings.toml` / the repo's `CLAUDE.md` / a project verify skill).
- [ ] It states the boundary that its auto-commit is the implementation commit on the ticket branch, distinct from `CLOSE-OUT.md`'s later gated store-edit commit inside `/done`.

## Implementation notes

Lives in `skills/_shared/` under the no-suffix Convention-doc naming. Reuse `CLOSE-OUT.md`'s verification sources rather than inventing a new resolution mechanism. Governed by ADR 0004 — cite it for the Consent-vs-Ceremony rationale, don't re-derive it.

## Deviations

- Approach — Exit tasks (spec lines 43/47): the spec enumerated the verification sources config-first (`settings.toml` / `CLAUDE.md` / project verify skill); the doc instead resolves them by first-match in the inverted order — project verify skill → `settings.toml` → `CLAUDE.md` — because an executable, purpose-built verify skill is the least-ambiguous statement of how to verify a repo. The spec delegated the resolution to this doc ("owns the resolution") without fixing the order; user-ratified.
- `skills/_shared/README.md` gained a one-line index entry for the new Convention doc under "Convention docs" — the corpus index lists every convention doc, so registering it is part of landing the doc in the shared location, not a separate module (below the seam/behavioral threshold; recorded only because the file falls outside the spec's enumerated Modules touched).
