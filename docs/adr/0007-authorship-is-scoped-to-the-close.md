---
status: accepted
---

# 0007 — Store-artifact authorship is scoped to the close, not the invocation

## Context

Two close-out mechanics ask the same question about an untracked store artifact and must not answer differently. `CLOSE-OUT.md`'s gated commit enumerates *"every store edit this invocation made"* and is explicitly authorship-scoped: a store-path entry the invocation didn't author — another spec's draft, a banked idea, a foreign planted file — is excluded and named to the user rather than swept into the commit. Spec 006 ticket 001 then added an exit-8 preflight whose proceed arm makes the same split one step earlier, at diff materialization, so nothing is silently acknowledged.

The same ticket added a resume route into that arm. `RECOVERY.md`'s re-materialization recipe stashes tracked store paths only, so a crashed close's *untracked* artifacts — a minted ADR, a first `retro.md` — survive the stash and refuse the re-run with exit 8; the recipe routes them to the resuming skill's exit-8 arms and states they are legitimately part of the close. Read with authorship scoped to the *invocation*, the resuming run authored none of them: the arm names its own crashed predecessor's minted ADR as excluded from this close, and `CLOSE-OUT.md`'s enumeration then drops it from the commit. That is the silent non-ship the exit was built to prevent, one layer up — reachable only because the resume recipe and the preflight shipped together.

`CLOSE-OUT.md` already contained the answer without stating it as a rule: its show-content-on-resume clause exists precisely for the case where *"the offering run didn't author the edits"* and still commits them, showing their content so the user can confirm they match the interrupted run. The enumeration rule and the show-content rule were reading "authorship" two different ways, and nothing said which was correct.

## Decision

Store-artifact authorship is scoped to **the close**, not to the invocation or the session. A crashed predecessor run's store edits are the resuming run's own for every purpose that tests authorship — exit-8 classification, the gated commit's enumeration, and what is named to the user as foreign. Only paths belonging to no run of the close are foreign.

## Consequences

- A resumed close commits the crashed run's minted ADR and first `retro.md` rather than excluding them, which is what `CLOSE-OUT.md`'s show-content-on-resume rule already assumed and now depends on explicitly.
- The exit-8 proceed arm and the gated commit's enumeration can no longer answer differently about the same file — the defect that motivated this record.
- "Foreign" narrows to what it was always meant to name: another spec's draft, a banked idea, a planted file. That set is the store's normal resting state, so the user-facing naming stays load-bearing rather than becoming noise.
- The resuming run cannot verify authorship from the tree — it did not observe the edits being made, and no artifact records who wrote what. The show-content-on-resume review is what carries that weight, which makes it non-optional rather than a courtesy; a resume that skips it has no check on this rule at all.
- The scope is not machine-checkable. "Belonging to no run of this close" is a judgment an executor makes from the ticket's state and the tree, and a genuinely foreign file dropped mid-close by an unrelated process would be classified as the close's own if it plausibly resembles one of its artifacts.

## Alternatives considered

- **Invocation-scoped authorship** (the reading the original arm took) — rejected because it breaks the resume path that ships alongside it, and because `CLOSE-OUT.md`'s show-content rule already contradicts it. It is the simpler reading and the literal one, which is exactly why it needs a record: the next reader will re-derive it otherwise, as happened here.
- **Session-scoped authorship** — rejected for the same reason with an extra failure: it makes correctness depend on whether the user ran `/clear`, so the same tree classifies differently across a context boundary that carries no workflow meaning.
- **Recording authorship in an artifact** so the question is answerable rather than judged — deferred, not rejected. It would make the rule checkable, but it needs a durable per-close record nothing currently writes, and the dispatch-record work in spec 006 ticket 005 may establish the shape for one. Revisit if the show-content review proves insufficient in practice.
- **Dropping the authorship test entirely** and committing every untracked store path — rejected: it silently sweeps a foreign banked idea into an unrelated close, which is the failure `CLOSE-OUT.md`'s enumeration rule exists to prevent.
