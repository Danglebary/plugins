# Enforce or remove the acceptance-criteria checkboxes

TICKET-FORMAT writes Acceptance criteria as GFM task-list items (`- [ ]`), and the format example shows them checked (`- [x]`) on a done ticket. But across every dogfooded ticket in this repo — all three specs, every ticket `done` — the boxes are **never toggled**: `/tdd` and `/implement` don't check them, and `/done` doesn't either. The checkbox is a dead affordance: it promises a state (`checked` = criterion verified) that nothing in the workflow ever writes.

Two coherent resolutions — pick one, don't leave it half-built:

- **Remove the checkboxes.** Make Acceptance criteria plain bullets in TICKET-FORMAT (and its example). Honest about what the workflow does: the criteria are a checklist the implementing agent reads, not a mutable state surface.
- **Enforce the checkboxes.** Add explicit "check off each criterion as verification confirms it" instructions to the implementation skills' verification step(s) (`/tdd`, `/implement`) and/or `/done`, so `[x]` means something. This makes the check-state a live signal — at which cost note the knock-on for the reviewer trust boundary: any base-vs-head comparison over the Acceptance section (spec 004's tamper-script) must then normalize check-state (`[ ]` ≡ `[x]`) so legitimate checking-off doesn't read as a contract tamper.

Provenance: surfaced during spec 004's (reviewer-trust-boundary) detail grill, while verifying that `/done`'s base-vs-head extract-and-compare over the Acceptance section wouldn't be poisoned by checkbox toggling. It isn't today — precisely because the boxes are dead — but a dead affordance in a canonical format doc is its own small debt, and spec 004 leans on the boxes staying untoggled without that being written down anywhere.
