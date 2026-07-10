# Retro — 002 slim-the-baseline (running)

## Ticket 001 — Remove the notion backend

**Outcome**: Extended

The acceptance grep under-scoped the removal in both directions: the highest-value edits carried no `notion` token (the resolve-the-store preambles, the two-backend headlines outside the grep path — one of which, the root glossary preamble, survived until the close-out fact-check caught it contradicting its own Store backend entry). Removal also cascaded further than the criteria anticipated: deleting the backend killed the config's only mandatory key, taking the whole `[store]` block with it. Future removal tickets should treat a zero-matches grep as the floor, not the definition of done.

## Ticket 002 — Rename PRD to spec

**Outcome**: Extended

The rename's real cost wasn't the word swap but the store contract's internal couplings, which generated scope the enumerated ACs missed: the artifact map names the artifact *file* (`spec.md`), the ticket-branch prefix derives from its parent's name, and setup's first-run detection keys on the store directory — each surfaced as necessary work only mid-rename. Legacy continuity needed exactly two mechanisms, both single-homed in STORE.md (the branch-link fallback and dual-pattern sweeps), which kept the mid-flight migration safe without renaming live branches — echoing ticket 001's lesson that an enumerating AC is the floor, not the definition of done.

## Ticket 003 — Defect fixes and absorbed behavior edits

**Outcome**: Extended

Vocabulary reframes fan wider than any planned site list: the fork rename touched five consumer files, and even the deviation entry recording that fan-out missed one (retro's own step-14 contrast) — caught only by the fact-checker, which argues for grep-verifying enumerations in deviation entries, not just in acceptance criteria. Repointing citations surfaced a dependency pattern worth watching: shipped prose can cite a convention whose authoritative statement lives only in the dogfood repo's ADRs, so the fix had to first give the plugin the authority being cited (the placement test and sync-set consequence now stated in STORE.md).
