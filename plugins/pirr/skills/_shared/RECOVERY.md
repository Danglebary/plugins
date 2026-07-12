# Recovery — interrupted and abnormal lifecycle states

## Entry model

This document is entered on demand, never loaded as part of a skill's unconditional reads. A consuming skill keeps its state test — the discriminator — inline at its decision point and routes here only when it fires: an exit-5 store-dirt classification, a re-close attempt on a closed ticket or spec, an unreachable dependency, a half-landed bootstrap. Each section below is the single home of one recovery walkthrough; consumers cite a section anchor and never restate its body. Read the routed section start to finish before acting — these procedures are entered rarely and deliberately, and acting on a fragment is how interrupted state gets destroyed. Sections named for a skill use that skill's step numbers.

## Resting states

The authority every closing skill's discriminator and `/next-ticket`'s dependency router classify against. It reads the flip-last invariant published in [CLOSE-OUT.md](./CLOSE-OUT.md#resting-states-and-the-interrupted-close-discriminator).

Given the flip's location, ownership of the tree state follows:

- **Flip committed, branch merged** — fully closed. Refuse a re-close; point at git history.
- **Flip committed, branch deleted** — verify closure positively before certifying it: the close commit (the one that flipped the status to `done`, found via `git log <parent branch> -S 'status: done' -- <artifact path>`) must be reachable from the parent branch. Reachable → fully closed, as above. Not reachable → the branch was deleted out-of-convention with its work unmerged — warn loudly (recovery is reflog-only and expiring) instead of certifying a closed chapter. Never infer "merged" from a branch's absence.
- **Flip committed, branch unmerged, tree clean** — a deferred merge, the *normal* resting state between a close and its merge. Re-offer the merge; never treat it as a closed chapter.
- **Store-artifact dirt, flip in the working tree (uncommitted)** — the closing skill's own interrupted close. That skill resumes: the flip's presence means every earlier store edit landed (the flip is last) — but verify the earlier edits that are observable in the tree before resuming at the gated commit; states that violate the invariant exist in the wild (hand-edited flips, sessions on pre-convention prose), and a mismatch routes by the actual state, not the flip's promise. If instead the flip is absent from tree and history, the crash was mid-close: resume from the first absent store-writing step, applying idempotently — unless the dirt fails one of the closing skill's published preconditions or belongs to an earlier close (an uncommitted running retro at spec close, another skill's uncommitted flip): a precondition failure refuses per that skill's preflight, and foreign dirt routes to its owning skill.
- **Store-artifact dirt, flip already committed** — a *post-close* pass's interrupted close-out (a refactor pass's straggler captures, Glossary edits, banked Ideas). That pass resumes at its own close-out gates.
- **Implementation-path dirt, any** — not a close-out state. Refuse: implementation is committed before close-out runs — and the user commits *the implementation paths only*. Co-present store-artifact dirt stays in the tree: it is an interrupted close's resume signal, and sweeping it into an implementation commit destroys it.

## Re-materializing under store dirt

Cited by every resume arm in this document; the script, its exit codes, and the artifact contract live in [DIFF-MATERIALIZATION.md](./DIFF-MATERIALIZATION.md).

A close-out skill resuming its own interrupted close (exit 5, store-artifact dirt) must re-materialize the diff while the tree legitimately carries the crashed run's store edits. One recipe, cited by every resume arm, never restated:

1. Set the dirt aside: `git stash push -m "pirr <skill> resume — <scope>" -- <store-artifact paths>`. The message is load-bearing — a stash is state no tree inspection can see, and an anonymous one is invisible to recovery.
2. Re-run the script. Never reuse a leftover `diff.patch` (staleness is unverifiable) and never hand-roll the diff.
3. `git stash pop` immediately — nothing sits between the push and the pop but the script run.

The recipe's own crash window: a session dying between push and pop leaves a *clean* tree, so the next run sees no exit 5 and no dirt to route. Every resume arm therefore begins by checking `git stash list` for a stash whose message names the skill and scope — pop it first, then classify tree state. If the pop conflicts (possible only when the tree changed since the crash), git keeps the stash entry and leaves conflict markers: resolve them by hand against the kept entry, `git stash drop`, re-classify — never run the script over conflict markers.

## Done: interrupted close-out

Entered from `/done` step 2's exit-5 store-dirt discriminator; step numbers are `/done`'s.

Store edits happen in step order (deviations → retro entry → flip; flip-last is the published invariant of [CLOSE-OUT.md](./CLOSE-OUT.md) that recovery routing reads — `/done` owns keeping its ordering conformant), so the tree records how far the crashed run got:

- The `done` flip is already in the tree → every store edit landed (the flip is last) — resume directly at the gated close-out commit (step 10).
- The flip is absent → resume the close from step 3, treating each store-writing step as idempotent: apply only what's absent — never append a second retro entry for the ticket (check for its `## Ticket NNN` heading first), never re-apply deviations edits already in the tree. The crashed run's conversational output (ADR decisions, the outcome label) died with its session; re-derive it at those gates. To re-materialize the diff for the resumed fact-check, set the store dirt aside per [the resume recipe](#re-materializing-under-store-dirt) (self-identifying stash → script → immediate pop; its entry check catches a leftover stash from a prior crash before tree state is classified).

## Done: closed-ticket states

Entered from `/done`'s Refusing-to-run check on an already-closed ticket; step numbers are `/done`'s.

Classify against [the resting-state table](#resting-states) with `/done`'s bindings — parent branch: the spec branch; artifact path: the ticket file, so the deleted-branch row's close-commit search is `git log <spec branch> -S 'status: done' -- <ticket path>`. The merged and deleted rows route per the table. The one arm with a `/done`-specific route:

- **Ticket branch exists and is unmerged** — name the state ("ticket NNN is closed but its branch is unmerged — the deferred merge never happened") and re-present the step-11 fork: run `/refactor` (its close-out offer owns the merge), or merge now per the convention.

## Retro: interrupted close

Entered from `/retro` step 3's exit-5 store-dirt discriminator; step numbers are `/retro`'s. Route by the `Done` flip's position, read against this skill's store-edit order (late-stage deviations → synthesis rewrite → pointer clear → `Done` flip last):

- **This spec's `Done` flip is in the tree, uncommitted** — `/retro`'s own interrupted close. The flip is last, so every earlier store edit *should* have landed — verify the two observable ones instead of trusting the invariant (hand-edited flips and sessions on pre-convention prose present flip-dirty states that violate it): the retro is in cleanly synthesized form, and the pointer no longer names this spec. Both hold → resume directly at the gated commit (step 13). The pointer still names it → clear it (step 11), then the commit gate. The retro isn't cleanly synthesized → the flip's promise is broken; route by the retro's actual state per the arms below, not by the flip.
- **Flip absent; `retro.md` is dirty but already in *synthesized* form** (a `# Retro:` heading with per-section outcome labels, not per-ticket entries) — a crash between the synthesis rewrite and its commit. Resume from the first absent store edit (pointer clear, then flip), then the gated commit — **never re-run the synthesis**: the rewrite already landed, and the commit gate's show-content rule gives the resumed run's user the review the crashed session's confirmation can't carry over. A rewrite that crashed *mid-write* leaves a hybrid instead — a `# Retro:` heading with leftover per-ticket entries, or visibly truncated sections. A hybrid is a corrupt rewrite, not a landed one: restore the committed running form (`git checkout -- <retro path>`) and re-synthesize from step 6 — lossless precisely because the committed-running-retro precondition guarantees history holds the running form.
- **Flip absent; the running retro has uncommitted content** (a modified `retro.md` still in running form) — **refuse: the running retro must be committed before the synthesis consumes it** (the committed-running-retro precondition `/retro` step 3's preflight owns; synthesizing over uncommitted entries destroys them with no recovery path). This dirt belongs to an earlier close — an uncommitted ticket `done` flip alongside it is an interrupted `/done` close-out: point at re-running `/done`. Otherwise have the user commit the running-retro edits, then re-run `/retro`.
- **Flip absent; other store-artifact dirt, retro untouched** (e.g. step-5 late-stage deviations from a crash before synthesis) — resume from step 4, re-running the fact-check and applying step 5 idempotently: the fact-check isn't a store-writing step, so its completion can't be read from the tree, and the dirt may hold only a *partial* application of the crashed run's findings — re-running is what makes the idempotent re-apply safe. To re-materialize the diff for that resumed fact-check, set the store dirt aside per [the resume recipe](#re-materializing-under-store-dirt) (self-identifying stash → script → immediate pop; its entry check catches a leftover stash from a prior crash before tree state is classified).

## Retro: closed-spec states

Entered from `/retro`'s Refusing-to-run check on an already-`Done` spec; step numbers are `/retro`'s.

Classify against [the resting-state table](#resting-states) with `/retro`'s bindings — parent branch: the resolved default branch; artifact path: the spec file, so the deleted-branch row's close-commit search is `git log <default branch> -S 'status: done' -- <spec path>`. The merged and deleted rows route per the table (for a merged spec branch, the synthesized retro and git history are the record). The one arm with a `/retro`-specific route:

- **Spec branch exists and is not an ancestor of the default branch** — name the state ("spec NNN is closed but its branch is unmerged — the deferred merge never happened") and re-offer the merge (step 14) directly: no re-fact-check, no re-synthesis — after one look at the tree. Clean → offer. Dirty → the dirt belongs to some pass's close-out per [the resting-state discriminator](#resting-states) (this path never runs the script, so nothing else classifies it) — name the dirt's owner and stop; never merge over a dirty tree.

## To-tickets: bootstrap re-entry

Entered from `/to-tickets` step 1 on an `Open` spec whose bootstrap hasn't fully landed; step and precondition numbers are `/to-tickets`'.

An `Open` spec with tickets whose bootstrap hasn't fully landed (the landed test — `/to-tickets`' State contract) is, by construction, an interrupted or declined bootstrap. Re-invoking `/to-tickets` on it re-offers **only the missing pieces** — no re-ticketing, no re-proposal; ticket creation stays one-shot. Two states route here:

- **No linked branch, local or remote** (neither `spec-<NNN>-<slug>` nor a legacy `prd-<NNN>-<slug>` twin) — declined, or crashed before the cut. Verify the serialize-ticketing preconditions, idempotently repair the pre-bootstrap edits if the interruption swallowed one (the `Open` flip is present by construction — it is the discriminator; rewrite the active pointer if it's missing), then run step 11's offer in full.
- **Branch exists, planning commit absent from it** — crashed between cut and commit. Preconditions 1 and 3 apply; precondition 2 exempts this spec's own branch. Switch to the linked branch (the untracked planning artifacts ride the switch), then run step 11's commit half only — and because this session didn't author the edits, CLOSE-OUT.md's show-content rule applies: show the enumerated paths' content with the offer, not just their names.
