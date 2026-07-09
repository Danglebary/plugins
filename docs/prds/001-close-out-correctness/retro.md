# Running retro — PRD 001: Close-out correctness

## Ticket 001 — Shared diff-materialization convention

**Outcome**: Exact match

Script-over-prose validated on first contact: the dirty-tree preflight fired live during this ticket's own close-out, listing exactly the tracked modifications and none of the untracked planning artifacts — procedure fidelity prose never guaranteed. A prose-corpus repo grew its first executable surface cheaply (bats + shellcheck, red-green in one pass), and the only deviation came from *classifying* the new artifact, not building it — organizational taxonomies get stressed by new artifact shapes before content does.

## Ticket 002 — /done close-out commit gate

**Outcome**: Extended

Consuming a shared convention means inheriting its obligations, not just its mechanics — both scope extensions (the brief's planning-artifact label, the README sync) were contracts other documents already imposed on any change of this shape, discoverable only by reading the consumed docs end to end. Re-entry had to be pinned to observable tree state (store-artifact dirt plus an already-flipped status) because a crashed close-out leaves no session memory — in a prose workflow, crash recovery must be derivable from git alone.

## Ticket 003 — /improve pass integration

**Outcome**: Extended

A skill step that names a state transition without quoting the literal encoding invites drift: `/next-ticket`'s flip wrote `in progress` where STORE.md pins `in-progress`, so a strict frontmatter reader would have missed the ticket — caught only because the fact-checker scrutinizes planning-artifact hunks it is told not to code-review (steer recorded on ticket 006). The close-out recipe now has an inline mirror in `/improve`'s merge gate; mirrors found only by reading the consumed docs end to end are the recurring cost of prose-as-implementation.

## Ticket 004 — /retro close-out gate and PRD merge

**Outcome**: Exact match

Extracting a convention retroactively exposes conformance gaps in consumers that predate it: `/retro`'s existing step order violated CLOSE-OUT.md's flip-last invariant (pointer-clear after flip), invisible until the discriminator that reads flip position had to route this skill's recovery. And a convention with a mechanical core is only as complete as the mechanism's blind spots — the script's tracked-only dirty check can never see an untracked running retro, so the guarantee AC1 wanted needed a per-consumer preflight in skill prose, not another script exit code.
