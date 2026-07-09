# Canonical-edit conformance sweep for inline copies

From ticket 006's refactor pass (qa-engineer): ADR 0002's shape leaves each hot-path classification inlined at its decision points, citing a canonical `_shared` section — but nothing checks the copies when the canonical text is amended. The copies are paraphrased, not verbatim, so grep can't catch drift, and CLOSE-OUT.md's preamble records this defect class realized twice in one ticket. Ticket 008 is already scheduled to amend consumption of the branch-link authority, so the next canonical edit is imminent.

The idea: when a diff contains hunks in a `_shared` canonical section, `/done`'s fact-checker brief (or its close-out checklist) enumerates the citing copies — the citation string ("inline copy of …, cited per ADR-0002") makes the inventory mechanically greppable — and verifies each still semantically matches the amended canonical. A `/done` workflow change, outside PRD 001's scope.
