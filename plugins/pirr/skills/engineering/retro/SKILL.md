---
name: retro
description: "Close a spec: synthesize the running retro into structured form, fact-check the spec-branch diff, flip Open → Done, gated merge. Use when all tickets in a spec are complete."
---

# Retro

Close a spec by synthesizing the running retro into structured form, with one final fact-check pass against the full spec-branch **git diff**. Code and its diff stay in git; spec text and status live in the store. The close ends in the shared close-out shape: one gated commit of everything the invocation wrote, then the gated merge into the default branch.

References: [STORE.md](../../_shared/STORE.md) (artifact paths); [RETRO-FORMAT.md](../../_shared/RETRO-FORMAT.md); [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md) (deviation threshold); [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md) (the diff); [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md) (the gates).

## State contract

- **Spec state required**: `Open` (with all tickets `Done`)
- **Ticket state required**: n/a (verifies all tickets are `Done` before proceeding)
- **Transition**: spec `Open → Done`; clears the active pointer if it names this spec; ends at the gated merge of the spec branch into the default branch

Refuses if any ticket isn't `Done` (lists outstanding tickets). An already-`Done` spec refuses only when its branch is merged or gone — `Done`-but-unmerged re-offers the merge instead (see Refusing to run). Refuses while the running retro has uncommitted content (step 3).

## Process

1. **Identify the spec.** Default: the active spec (the store's active pointer) if all its tickets are `Done`. Otherwise look for any other `Open` spec with all tickets `Done`. A spec reading `Done` in the working tree with uncommitted store-artifact dirt is this skill's own interrupted close — identify it and proceed (step 3 classifies the state). A `Done` spec whose branch still exists and is not an ancestor of the resolved default branch is a deferred merge — identify it and route to the re-offer (see Refusing to run). If multiple or none match, ask.

2. **Verify all tickets are done.** Read all of the spec's tickets from the store. If any is `Open` or `In progress`, refuse with a list of outstanding tickets.

3. **Materialize the spec diff via the shared convention.** Resolve the refs per [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md), spec scope: `<head>` is the spec branch (`spec-<NNN>-<slug>` from the directory name — or its legacy `prd-<NNN>-<slug>` twin per STORE.md's branch-link fallback); `<base>` is the resolved default branch (the shared doc's resolution procedure, run live). Non-standard branching: ask the user for the refs.

   **Verify the diff is complete before fact-checking it:** every `Done` ticket's work must be reachable from the spec branch tip. If the ticket branch still exists, ancestor-check its tip (`git merge-base --is-ancestor`). If the branch is gone — the normal state — locate the ticket's close commit *positively*: the commit that set the ticket's status to `done`, found in the spec branch's history of the ticket file (`git log <spec branch> -S 'status: done' -- <ticket path>`). Found → the close and everything under it is reachable. Not found → the close never reached the spec branch (branch deleted or never merged): the spec diff is silently missing that ticket — stop; if its branch survives, offer that ticket's close-out merge per [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md) (ticket branch → spec branch); if not, warn the work is recoverable only from the reflog. Never infer "merged" from a branch's absence.

   **One preflight the script cannot make:** the running retro must be committed before the synthesis consumes it — the rewrite preserves the running form in git history *only* (see [RETRO-FORMAT.md](../../_shared/RETRO-FORMAT.md)). An *untracked* `retro.md` never trips the script's exit-5 dirty check (tracked-only by design) and, being a store artifact, would pass exit 8's classification — yet it has no history: verify the running retro is tracked, and refuse if not — name the exact path and the always-works fix: commit it on the spec branch, then re-run `/retro`. (Only when a ticket's `done` flip is *also* uncommitted is resuming that `/done` close the better route — its commit gate carries the retro along.)

   Run the script:

   ```
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/materialize-diff.sh" <base> <head> [--allow-untracked <path>...]
   ```

   On success the diff is at `.pirr/diff.patch` — the fact-checker has no git access; this artifact is its only view of the diff. On any non-zero exit, follow the shared doc's exit-code table: relay stderr and stop — never fall back to a hand-rolled `git diff`. Exits 5 and 8 are the two `/retro` interprets before stopping. Both classify against the same division (store-artifact paths per STORE.md's artifact map: `docs/specs/**`, `docs/adr/**`, `docs/spikes/**`, `docs/reviewers.md`, `CONTEXT.md`, `.pirr/settings.toml`; everything else is implementation). Exit 8 sees one population exit 5 cannot — a path that is neither, such as a scratch note, an editor backup, or un-ignored build output. Refuse on it as well (refusing is the safe side of an unrecognized path), but say only that it can't be classified and point at `.gitignore`; the never-staged-work sentence below is false about it.

   **Exit 5 (tracked dirt)** — two arms:
   - **Any implementation path is dirty** — refuse, naming the convention: implementation is committed before close-out runs. Print the implementation paths; the user commits *those paths only* — co-present store-artifact dirt stays in the tree (a resume signal; the rule is the implementation-dirt row of [RECOVERY.md](../../_shared/RECOVERY.md#resting-states)).
   - **Only store-artifact paths are dirty** — an interrupted state this close owns. Open [RECOVERY.md](../../_shared/RECOVERY.md#retro-interrupted-close) and route per its walkthrough, which reads the `Done` flip's position against this skill's store-edit order.

   **Exit 8 (untracked paths).** Classify **per path, never by the set as a whole** — [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md)'s enumeration is per-entry, and a mixed set matching no arm is how a whole-set test fails:
   - **Any reported path is implementation** — refuse, same convention, naming what the exit prevented: a never-staged file is in neither the diff nor the close-out commit, so closing now would ship nothing of it. Print the implementation paths; the user stages or removes them, then re-runs `/retro`. Note the remedy differs from exit 5's *commit those paths only* — a never-staged file must be staged or removed first, so don't carry the exit-5 wording over. This arm fires even alongside legitimate planning artifacts.
   - **No reported path is implementation** — proceed: re-invoke with `--allow-untracked` naming **every** reported path, then split them by authorship in what you tell the user. **Authorship is scoped to the close, not to the invocation** ([ADR 0007](../../../../../docs/adr/0007-authorship-is-scoped-to-the-close.md)) — on a resume, a crashed predecessor run's edits are this close's own, not foreign ([CLOSE-OUT.md](../../_shared/CLOSE-OUT.md)'s show-content-on-resume rule commits exactly those). This close's own edits pass without comment; paths belonging to no run of it are **named** as excluded. At spec scope the foreign set is the common case: a working store normally carries banked ideas and drafted specs with nothing to do with this spec.

   Note the untracked `retro.md` case is already refused by the preflight above, which is strictly stronger than this exit: an untracked running retro fails on having no history for the synthesis to preserve, not merely on being untracked.

4. **Invoke `pirr:deviation-fact-checker`** with, at minimum:
   - The diff artifact path (`.pirr/diff.patch`)
   - The spec (properties + body)
   - All the spec's tickets
   - The Glossary
   - Existing ADR titles + statuses
   - A reminder that it has Read/Grep over the working tree and must verify claims against current source, not stale comments
   - The planning-artifact label per [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md)'s "Diffs contain planning artifacts" section, carried whole — copy the section's two-sided contract into the brief, never a paraphrase of it. A spec-scope diff always contains store-artifact hunks — every ticket's committed close-out edits — so the label is load-bearing, not decorative.

   The fact-checker returns its three pinned sections — Deviation gaps, Misrepresented deviations, ADR candidates — at spec scope. Same threshold applies (see [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md)): below-threshold churn doesn't accumulate into deviations at spec scope; don't surface it.

   Adversarially review findings against cited diff hunks. Spec-scope gaps tend to be cross-cutting things ticket-level diffs missed — seams that shifted across tickets — not new below-threshold churn.

5. **Apply confirmed late-stage updates.** Append any newly-discovered deviations to the relevant ticket's `## Deviations`. Surface ADR candidates for explicit decision. If the fact-check returns `_None._` across the board, that's a clean spec — proceed to synthesis.

6. **Read inputs for synthesis:**
   - The spec — section structure and intent.
   - The running retro — per-ticket entries with outcome labels.
   - Each ticket's `## Deviations` section — granular divergences (including `(refactor)`-marked entries).

7. **Synthesize per spec section.** For each of the spec's five sections (Problem, Goals, Non-goals, Approach, Modules touched):
   - Determine the dominant outcome label across the tickets that touched this section. If the section had no real activity, label it `Exact match` and say so briefly.
   - Write 1–3 sentences of commentary anchored in concrete tickets and deviations. Reference tickets by number when a lesson is anchored in one.

8. **Synthesize the Refactor section** if any `(refactor)`-marked deviations exist across tickets. Aggregate into one section with an outcome label and 1–3 sentences. Reference specific tickets where the refactor work landed. Omit the section entirely if no `(refactor)` deviations exist.

9. **Optional Cross-cutting appendix.** If lessons don't fit any spec section or the Refactor section (e.g. terminology spanning multiple sections, Glossary updates mid-spec), capture them here. Omit when empty.

10. **Restructure the running retro in place — non-destructively.** If `retro.md` is *already* in synthesized form, the rewrite already happened; skip to step 11 rather than synthesizing over it. Otherwise, before writing, **inventory every part of the running retro the synthesized form will not carry forward** — anything beyond the running per-ticket entries: findings notes, analysis writeups, co-resident deliverables from tickets or spikes. For each, either fold it into the synthesis or relocate it to its defined home (a spike artifact for findings-type deliverables, the relevant ticket, or wherever the user directs). **Present the drop-list and destinations to the user and wait for confirmation before rewriting** — this checkpoint is blocking. Only the running per-ticket entries are fair game to consume silently; they're what the synthesis is *made of*. The running form survives in git history, but relocation, not history, is the recovery path. (A synthesis pass once silently deleted a ticket's entire findings deliverable; this gate exists because of it.)

11. **Clear the active pointer** *if it names this spec* — delete `docs/specs/.active` (its one line is the spec directory name, `<NNN>-<slug>`). If the user has manually pointed it at a different spec, leave it alone. This edit comes *before* the flip: the status flip is the close's **last** store edit — the invariant of [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md) that step 3's recovery routing reads.

12. **Flip the spec** status from `Open` to `Done` — the close's last store edit. Ordering per STORE.md: read → apply the status edit → only then any git commands, never batched in parallel.

13. **Commit the close-out edits (gated).** Run the gated close-out commit per [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md). The deleted `.active` pointer stages by path like any other edit. `/retro`'s bindings:
    - **The branch**: the spec branch — everything the close wrote lands there, ahead of the merge.
    - **The edit set**: every store edit this invocation made — the synthesized `retro.md`, the spec file (`Done` flip), the deleted active pointer, late-stage ticket deviations (step 5), any ADR minted at step 5's gate, any content relocated by step 10's drop-list. Relocations can land outside the store-artifact map, so union the drop-list's destinations into the enumeration — the `git status` scan over store paths cannot see them. Offer: *"Commit the close-out edits (`<paths>`) on the spec branch?"*
    - **Re-entry**: when step 3 detected an interrupted close, resume *here* once every close-out artifact is in place — the convention's show-content rule applies, since the resumed run didn't author these edits.
    - On accept: commit; the tree is clean for step 14. On decline: the convention's wedge statement, naming this skill — re-running `/retro` resumes at this commit.

14. **Offer the spec merge (gated).** Run the gated merge per [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md), bound spec branch → the resolved default branch — the same resolution as step 3's diff base, so the diff's scope and merge target cannot disagree: `--no-ff` per config / the repo's CLAUDE.md, verify green, delete the spec branch only after green. Unlike `/done`, there is no refactor-pass fork — no later pass owns this merge; this offer is its only home. On decline: name the resting state (`Done`-but-unmerged, the spec branch alive) and that re-running `/retro` re-offers the merge directly — the gate is re-enterable until the merge lands.

## Synthesized structure

```markdown
# Retro: <spec title>

## Problem — <outcome label>

<commentary>

## Goals / Non-goals / Approach / Modules touched — <outcome label>

<commentary; one per section>

## Refactor — <outcome label>

<commentary; aggregates (refactor)-marked deviations across tickets>

## Cross-cutting

- <bullet per cross-cutting lesson>
```

`## Refactor` and `## Cross-cutting` are optional — omit when no relevant content exists.

## Refusing to run

- If the spec is already `Done` *and that flip is committed*, check the merge before refusing — `Done`-but-unmerged is the *normal* resting state of a declined step-14 offer, not a closed chapter. Walk the closed-spec states — branch merged, branch deleted, branch alive but unmerged — per [RECOVERY.md](../../_shared/RECOVERY.md#retro-closed-spec-states).
- An uncommitted `Done` flip plus store-artifact dirt is **not** an already-closed spec — it's this skill's interrupted close (step 3's discriminator; walkthrough in [RECOVERY.md](../../_shared/RECOVERY.md#retro-interrupted-close)). Resume at the gated commit instead of refusing.

## Anti-patterns

- **Don't write `## Next steps`, `## Future work`, or `## Roadmap`.** Strictly backward-looking. Forward-looking lessons go into a new spec.
- **Don't fabricate outcomes.** If the running retro, deviations, and fact-checker output don't reveal what happened in a section, ask the user.
- **Don't lose ticket-level granularity** — reference specific tickets by number.
- **Don't pad sections with below-threshold deviations to look thorough.** Internal refactors, private renames, formatting churn don't belong in a synthesized retro; a section whose tickets had no above-threshold divergence gets `Exact match`.
- **Don't skip the fact-check step even if every `/done` fact-checked cleanly.** Spec-level diff often surfaces things ticket-level diffs miss — particularly seams that shifted gradually across tickets, none capturing the cumulative move.
- **Don't apply a different deviation threshold than `/done` did.** The threshold (with its tooling-surface ruling) lives in [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md) alone — a change that passed the per-ticket fact-check must not flag at spec scope under a stricter reading.
- **Don't re-synthesize on resume.** A cleanly synthesized `retro.md` in the tree means the rewrite landed; a resumed close continues at the first absent store edit and the commit gate's show-content review — a second synthesis would consume its own output. The exception is a *corrupt* rewrite (the hybrid state in [RECOVERY.md](../../_shared/RECOVERY.md#retro-interrupted-close)): restore the committed running form and re-synthesize, safe there because the precondition guarantees history holds it.
- **Don't stage the close-out commit with `-A` or `git add .`.** Enumerate the paths this invocation edited; blanket staging sweeps unrelated working-tree state into the close-out commit.
- **Don't merge without an explicit yes.** The merge offer is a gate, not a notification — silence or an unanswered question means stop, not proceed.
