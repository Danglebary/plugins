# Close-out — the gated commit, merge, and recovery convention

Every lifecycle close ends in the same shape: a **gated commit** of the close's store edits, then a **gated merge** of the closed branch into its parent. The commit gate serves any invocation; the merge gate and resting-state table apply only to closes. Consumers bind the variables — which branch, which edit set, which arm has no merge to offer — and cite the mechanics from here, never restating them. Both gates here are **Consent** gates under the [ADR 0004](../../../../docs/adr/0004-confirm-gate-doctrine-scope.md) test — deliberately kept offers, never automated. (The recipe's inline copies drifted twice in one ticket before this extraction: a dropped show-content rule, a halved brief label — and the bootstrap's first inline copy dropped the show-content and name-the-paths rules on day one.)

## The gated store commit

1. **Enumerate every store edit this invocation made** — from `git status` over the store-artifact paths ([STORE.md](./STORE.md)'s artifact map: `docs/specs/**`, `docs/adr/**`, `docs/spikes/**`, `docs/reviewers.md`, `CONTEXT.md`, `.pirr/settings.toml`), **including untracked files** — minted ADRs, a first `retro.md`, banked Ideas — which the diff script's exit-5 stderr never names ([DIFF-MATERIALIZATION.md](./DIFF-MATERIALIZATION.md)); never enumerate from a refusal's output. The set is *whatever this invocation edited or created*, never a fixed list. **Enumeration is authorship-scoped**: a store-path entry the invocation didn't author — another spec's draft, a banked idea, a foreign planted file — is excluded and named to the user, never silently swept into the commit.
2. **Offer one commit** on the invocation's branch, naming the enumerated paths. Stage them explicitly — `git add <path> <path>`, never `-A`, never `git add .` (blanket staging sweeps in unrelated tree state). An unanswered offer blocks — it is not consent, same as the merge gate below; announcing the offer and committing in the same turn destroys the gate, and on a resume it destroys the show-content review with it.
3. **Show content on resume.** When the offering run didn't author the edits, show the enumerated paths' working-tree changes with the offer — new files included, not just path names. The user confirms they match the interrupted run; anything unexpected stops here.
4. **On decline: stop and state the wedge plainly.** The consumer binds the specific stakes (a close: status reads closed, edits uncommitted, merge blocked). Switching branches carries the edits or refuses — git never silently drops them — so commit or stash the paths before leaving the branch; re-running the skill resumes at this commit.

## The gated merge

- **Read the merge convention from the config / the repo's CLAUDE.md** — never improvise it.
- **Offer, never perform.** Offer the merge of the closed branch into its parent per the convention (`--no-ff`). The merge is the user's control point; an unanswered offer blocks — it is not consent.
- **On accept**: merge, run the repo's verification (build + tests) — **resolved per [IMPLEMENTATION-LOOP.md](./IMPLEMENTATION-LOOP.md#resolving-the-repos-verification), never improvised**, the same convention the loop's exit task uses — and delete the merged branch **only after green**. Red, absent, or unrunnable all mean stop and surface it; none is a green, and none deletes the branch.
- **On decline**: name the resting state ([RECOVERY.md](./RECOVERY.md#resting-states)). A declined merge never orphans a branch — the gate is re-enterable from every resting state.

## Resting states and the interrupted-close discriminator

A published invariant every closing skill must maintain: **store edits happen in step order, and the status flip is last.** Recovery routing reads the flip's position — reordering breaks every consumer of the resting-state table.

The table — six tree states — lives in [RECOVERY.md](./RECOVERY.md#resting-states); enter it when a consumer's discriminator fires. The per-run gates above never need it.

## Consumers

`/done` (ticket close: ticket branch → spec branch; gated commit, then the refactor-or-merge fork), `/refactor` (refactor-pass close-out: same branch pair; post-merge and general ad-hoc arms end at the commit gate — no branch to merge), `/retro` (spec close: spec branch → resolved default branch; its merge offer, with no refactor-pass arm to defer to, is the merge's only home), and `/to-tickets` (spec-branch bootstrap: commit gate only; the resting-state table doesn't apply — the bootstrap's own re-entry discriminator routes its interruptions). `/next-ticket` consumes the resting-state table as a router only — it classifies an unreachable dependency's state, points at re-running `/done` for whichever gates that state still owes, and never walks the gates itself.
