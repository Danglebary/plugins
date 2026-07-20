# Retro: 006 — the close-out evidence path

## Ticket 001 — Untracked implementation files stop a close-out

**Outcome**: Extended

Designing the preflight against the repo's actual resting state rather than the ticket's imagined one changed the answer: six untracked banked ideas sat in the tree the whole time, which killed the stash-widening approach (ceremony plus a crash window on every routine close-out) in favor of a report-then-acknowledge round trip. A preflight added to a shared mechanism acquires callers nobody enumerated — the new exit fired inside `RECOVERY.md`'s resume recipe, and the deviation entry declaring that file "untouched" recorded the non-edit while missing its consequence, which is the shape a non-edit's blast radius always takes. The close-out pair earned its keep here: four real defects, two of them leaving an acceptance criterion partial, none of which the implementing session saw.
