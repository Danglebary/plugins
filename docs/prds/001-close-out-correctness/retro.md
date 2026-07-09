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

## Ticket 005 — Planning chain and bootstrap gate

**Outcome**: Extended

A precondition that demands a clean tree can deadlock the very gate it guards — "clean" had to be pinned to exclude the planning dirt the bootstrap exists to commit. Serial ticket slicing means one side of a shared seam ships before the other: stating the end-state contract and recording the front-run as a deviation beat scope-dodging wording the sibling ticket would only rewrite — and the fact-checker proved able to catch the transient cross-skill contradiction, not just diff↔record mismatches.

## Ticket 006 — /next-ticket branch preconditions

**Outcome**: Extended

Ticket 003's encoding drift recurred at this ticket's own start — the flip wrote `in progress` with the corrective steer sitting in the very ticket being started — confirming that only the executed skill prose prevents a failure mode; advisory material read after the fact does not. The fact-checker's audit surface proved to extend past diff↔record mapping into the rationales inside deviation entries: it caught a placement justification claiming "both tests backend-differentiated" where only one is.

## Ticket 007 — Cut the branching-strategy config axis

**Outcome**: Exact match

Config that only an LLM reads as prose makes key removal migration-free: with no parser anywhere, a stale key is inert by construction, and "tolerate old repos" reduced to one stated sentence instead of compatibility behavior. The merge-key comment's consumer list had rotted silently — it named `/next-ticket`, which only routes merges and never reads the convention — so comments naming consumers need re-verification at every edit, not appending. The clean-tree preflight surfaced its own side effect: unrelated working-tree dirt (the `research_opener` enable) must ride the ticket branch as a rider commit, with the Deviations section as the honesty valve.
