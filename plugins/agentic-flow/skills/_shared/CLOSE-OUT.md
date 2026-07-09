# Close-out — the gated commit, merge, and recovery convention

Every lifecycle close ends in the same shape: a **gated commit** of the close's store edits, then a **gated merge** of the closed branch into its parent. This document is the single home of that recipe and of the recovery states around it. A closing skill binds the variables — which branch pair, which edit set, which arm has no merge to offer — and cites the mechanics from here; it does not restate them. (The recipe's inline copies drifted twice in one ticket before this extraction: a dropped show-content rule, a halved brief label.)

Store note: the commit gate is **files-store only** — notion's store edits are property/body updates independent of git, nothing to commit; notion skips to the merge gate, which is git-identical in both stores.

## The gated close-out commit (files store)

1. **Enumerate every store edit this invocation made** — from `git status` over the store-artifact paths (the files-store column of [STORE.md](./STORE.md)'s artifact map: `docs/prds/**`, `docs/adr/**`, `docs/spikes/**`, `docs/reviewers.md`, `CONTEXT.md`), **including untracked files**: minted ADRs, a first `retro.md`, banked Ideas are *new* files, and the diff script's exit-5 stderr can never name them (its dirty check is tracked-only by design) — never enumerate from a refusal's output. The set is *whatever this close edited or created*, never a fixed list.
2. **Offer one commit** on the branch the close works on, naming the enumerated paths. Stage them explicitly — `git add <path> <path> …`, never `-A`, never `git add .` (blanket staging sweeps unrelated tree state into the close-out commit). An unanswered offer blocks — it is not consent, same as the merge gate below; announcing the offer and committing in the same turn destroys the gate, and on a resume it destroys the show-content review with it.
3. **Show content on resume.** When the run making the offer didn't author the edits — a fresh session resuming an interrupted close — show the working-tree changes to the enumerated paths with the offer, new files included, not just path names. The user confirms it matches the close they remember interrupting; anything unexpected stops here.
4. **On decline: stop and state the wedge plainly.** The status reads closed but the close-out edits are uncommitted — the merge can't proceed, and switching branches will either carry the edits into the target branch or refuse outright (git never silently drops them); either way they block work somewhere they don't belong. Commit or stash the paths before leaving the branch; re-running the closing skill resumes at this commit.

## The gated merge

- **Read the merge convention from the config / the repo's CLAUDE.md** — never improvise it.
- **Offer, never perform.** Offer the merge of the closed branch into its parent per the convention (`--no-ff`). The merge is the user's control point; an unanswered offer blocks — it is not consent.
- **On accept**: merge, run the repo's verification (build + tests), and delete the merged branch **only after green**. If verification fails, stop and surface it — don't delete the branch.
- **On decline**: name the resting state (below). A declined merge never orphans a branch — the gate is re-enterable from every resting state.

## Resting states and the interrupted-close discriminator

A published invariant every closing skill must maintain: **store edits happen in step order, and the status flip is last.** Recovery routing reads the flip's position, so a closing skill that reorders its store edits breaks every consumer of this table.

Given the flip's location, ownership of the tree state follows:

- **Flip committed, branch merged (or deleted)** — fully closed. Refuse a re-close; point at git history.
- **Flip committed, branch unmerged, tree clean** — a deferred merge, the *normal* resting state between a close and its merge. Re-offer the merge; never treat it as a closed chapter.
- **Store-artifact dirt, flip in the working tree (uncommitted)** — the closing skill's own interrupted close. That skill resumes: the flip's presence means every earlier store edit landed (the flip is last) — but verify the earlier edits that are observable in the tree before resuming at the gated commit; states that violate the invariant exist in the wild (hand-edited flips, sessions on pre-convention prose), and a mismatch routes by the actual state, not the flip's promise. If instead the flip is absent from tree and history, the crash was mid-close: resume from the first absent store-writing step, applying idempotently — unless the dirt fails one of the closing skill's published preconditions or belongs to an earlier close (an uncommitted running retro at PRD close, another skill's uncommitted flip): a precondition failure refuses per that skill's preflight, and foreign dirt routes to its owning skill.
- **Store-artifact dirt, flip already committed** — a *post-close* pass's interrupted close-out (a refactor pass's straggler captures, Glossary edits, banked Ideas). That pass resumes at its own close-out gates.
- **Implementation-path dirt, any** — not a close-out state. Refuse: implementation is committed before close-out runs — and the user commits *the implementation paths only*. Co-present store-artifact dirt stays in the tree: it is an interrupted close's resume signal, and sweeping it into an implementation commit destroys it.

## Consumers

`/done` (ticket close: ticket branch → PRD branch; its gated commit, then the merge-or-defer fork), `/improve-codebase-architecture` (refactor-pass close-out: same branch pair; its post-merge and general ad-hoc arms have no branch to merge and end at the commit gate), and `/retro` (PRD close: PRD branch → resolved default branch; its gated commit, then a merge offer with no defer arm — that offer is the merge's only home). Each consumer states its bindings and cites this document for the mechanics.
