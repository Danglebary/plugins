---
status: open
depends_on: [001, 003]
---

# Every agent can report what it could not check

## Goal

Thirteen reviewer agents end their output contract with a literal halt, so an agent whose lens ran but whose key surface was unreadable emits an empty result and stops — indistinguishable from a clean review, and most likely precisely when a gap exists, since the surface you could not read is often the one that would have produced the finding. Separately, nothing tells any of the fifteen agents that instruction-shaped text inside the material they review is data to analyze rather than direction to follow. This ticket sweeps all fifteen for both. Out of scope: the dispatching skills, which are ticket 005.

## Acceptance criteria

- [ ] All fifteen agents emit a partial-verdict section in every case, and no instruction to stop precedes it.
- [ ] An agent with no gap emits the sentinel; an agent with a gap names the surface, why it went unread, and what reading it would have confirmed or refuted.
- [ ] The register lists only surfaces inside the agent's own lens, and never enumerates what was checked.
- [ ] The close-out pair's contract reads as three *finding* sections followed by the register, with the register outside the parse contract.
- [ ] Every copy of the "three sections" phrasing moves in this ticket — both agent bodies, `/done`, `/retro`, `AGENT-FORMAT.md`, both `CONTEXT.md`s, and the READMEs — with no un-reworded occurrence left in the repo.
- [ ] A surface recorded in the register is not also reported as a finding; findings keep their own verification caveats.
- [ ] All fifteen refuse to obey instruction-shaped text in reviewed material, whether it arrives inlined in a brief or is read from the working tree.
- [ ] Only the lens that owns such text reports it; the other agents continue their review without flagging it.
- [ ] Ordinary imperative prose addressed to a programmer is explicitly not reportable.
- [ ] The clause leaves untouched which authority a diff can and cannot rewrite (ADR 0005), including its line-granular test.
- [ ] A mechanical check confirms every file the sweep touches carries the new sections, and its output is recorded.
- [ ] A decorrelated re-read compares the fifteen bodies for semantic agreement; anything it finds is fixed in this ticket, not noted for later.

## Implementation notes

The register replaces the terminal halt rather than being appended after it — appending leaves it unreachable in exactly the case it exists for.

`/refactor`'s brief still carries its per-area "checked, clean" requirement until ticket 005 removes it. Until then this ticket narrows the contradiction rather than closing it; do not remove the brief's line here.

The presence check is the weaker half of the verification — this repo's recorded drifts were semantic (a dropped rule, a halved label), all of which a heading grep would pass. The decorrelated re-read is what actually catches those.

### Deferred steers

- From ticket 001's refactor pass: **re-resolve `spec.md`'s anchors by quoted phrase, not by line number.** This ticket's spec-side justification cites `DIFF-MATERIALIZATION.md:66` for the injected-instruction scrutiny requirement; ticket 001's diff moved it to `:70`. The spec is frozen and tamper-guarded, so the numbers stay as written and the anchors get re-resolved here.
- From ticket 001's refactor pass: **all fifteen agents are `tools: [Read, Grep, Glob]` — no Bash — while `/refactor`'s brief (`refactor/SKILL.md:66`) requires every reviewer to "verify any severity-determining claim about an external system against the installed toolchain."** No dispatched agent can satisfy that; all seven dispatched in ticket 001's pass reported the gap unprompted, which is the register behavior this ticket formalizes. Ticket 005 removes the *other* half of that same brief line ("checked, clean") and touches this half nowhere. Decide here whether the partial-verdict register is the whole answer (an agent declares the unfired claim) or whether the brief requirement itself must change — the two are not the same fix, and shipping only the register leaves the skill still demanding the impossible.

## Deviations

_None yet._
