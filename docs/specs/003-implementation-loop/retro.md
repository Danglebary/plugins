# Retro: Codify the implementation loop

## Problem — Exact match

The two-gap framing — an uncodified non-TDD path, and two answered-yes ceremony gates (the ticket-branch commit and the "run `/done`?" prompt) — held through implementation without challenge; nothing in execution pushed back on the problem statement.

## Goals — Exact match

All five goals shipped as written: `/implement` exists as a `/tdd` peer (ticket 003), mode selection rides the existing plan-approval gate with no new gate (004), the clean-green exit tasks auto-commit and auto-invoke `/done` (001–003), the doctrine prose states the Consent-vs-Ceremony test everywhere it read as blanket (005), and the happy path shed two prompts with no Consent gate lost. No goal was added, dropped, or reinterpreted.

## Non-goals — Exact match

Every fence held: session-handoff stayed untouched, no Consent gate changed, ticket 004 confirmed no new config knob or mode gate was introduced, and `/tdd`'s red-green-refactor cycle was left intact (002/006) — the shared stop-and-surface trigger and exit tasks landed *around* the cycle, not in it, exactly as scoped.

## Approach — Extended

The design was front-loaded and largely correct — plan-then-execute, the recording-vs-stopping split, the exit tasks, mode-recommendation, and the doctrine refinement all landed as specified — but execution extended two edges the plan left open or under-scoped. Ticket 001 filled the verification-source resolution *order* the spec had explicitly delegated to `IMPLEMENTATION-LOOP.md`, inverting to project-verify-skill-first as the least-ambiguous source. Ticket 002 found the stop/record split had to reach a second site — `tdd/refactoring.md`'s "what gets captured where" still routed always-stop moves to record-and-continue — because the Goal's "no contradictory in-flight instruction" was a higher bar than the AC's single-section scope, and auto-commit would have shipped that latent contradiction.

## Modules touched — Extended

Every enumerated module landed; three files the spec didn't enumerate came along as forced consequences of the corpus's own conventions — the `skills/_shared/README.md` convention-doc index (001), `tdd/refactoring.md` (002), and the bucket README's duplicate `/tdd` one-liner (006). None was scope creep: each is a sync-set or index copy the enumerated edit could not correctly land without.

## Cross-cutting

- The Consent-vs-Ceremony vocabulary the work settled during grilling became durable cross-section infrastructure — two Glossary terms in `CONTEXT.md` plus ADR 0004 — rather than living as spec prose; the whole spec sits downstream of that distinction, and every doctrine-prose edit (005) is a projection of it.
- This corpus's duplication conventions turn "single-surface" tickets into multi-file edits: both the convention-doc index (001) and the must-stay-in-sync skill one-liners (006) forced a second edit the ticket's named surface never mentioned — a standing property worth pricing into future single-surface scoping.
