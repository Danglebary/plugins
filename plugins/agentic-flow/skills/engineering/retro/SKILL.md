---
name: retro
description: "Close a spec by synthesizing the running retro into the structured form. Materializes the full spec-branch diff via the shared convention (refusing while the running retro is uncommitted) and invokes the deviation-fact-checker for a final spec-scope pass. Mirrors spec sections with outcome labels, synthesizes a Refactor section from cumulative (refactor)-marked deviations, clears the active pointer, flips spec Open → Done, commits everything the close wrote at one gated offer, then ends with the gated spec → default-branch merge — re-enterable until the merge lands. Use when all tickets in a spec are complete."
---

# Retro

Close a spec by synthesizing the running retro into structured form, with one final fact-check pass against the full spec-branch **git diff**. The code and its diff stay in git; the spec text and status live in the store. The close ends in the shared close-out shape: one gated commit of everything the invocation wrote, then the gated merge of the spec branch into the default branch.

Store artifact paths: [STORE.md](../../_shared/STORE.md). Format references: [RETRO-FORMAT.md](../../_shared/RETRO-FORMAT.md), [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md) (deviation threshold). Convention references: [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md) (the diff), [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md) (the gates).

## State contract

- **Spec state required**: `Open` (with all tickets `Done`)
- **Ticket state required**: n/a (verifies all tickets are `Done` before proceeding)
- **Transition**: spec `Open → Done`; clears the active pointer if it names this spec; ends at the gated merge of the spec branch into the default branch

Refuses if any ticket isn't `Done` (lists outstanding tickets). An already-`Done` spec refuses only when its branch is merged or gone — `Done`-but-unmerged re-offers the merge instead (see Refusing to run). Refuses while the running retro has uncommitted content (step 3).

## Process

1. **Identify the spec.** Default: the active spec (per the store's active pointer) if all its tickets are `Done`. If no spec is active or its tickets aren't all done, look for any other `Open` spec with all tickets `Done`. If a spec reads `Done` in the working tree with uncommitted store-artifact dirt, that spec is this skill's own interrupted close — identify it and proceed (step 3 classifies the state). If no `Open` spec matches but a `Done` spec's branch still exists and is not an ancestor of the resolved default branch, that spec is a deferred merge — identify it and route to the re-offer (see Refusing to run). If multiple or none match, ask.

2. **Verify all tickets are done.** Read every one of the spec's tickets from the store. If any is `Open` or `In progress`, refuse with a list of outstanding tickets.

3. **Materialize the spec diff via the shared convention.** Resolve the refs per [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md), spec scope: `<head>` is the spec branch (`spec-<NNN>-<slug>` from the directory name — or its legacy `prd-<NNN>-<slug>` twin per STORE.md's branch-link fallback); `<base>` is the resolved default branch (the shared doc's resolution procedure, run live). Non-standard branching: ask the user for the refs.

   **Verify the diff is complete before fact-checking it:** every `Done` ticket's work must be reachable from the spec branch tip. If the ticket branch still exists, ancestor-check its tip (`git merge-base --is-ancestor`). If the branch is gone — the normal state — locate the ticket's close commit *positively*: it is the commit that set the ticket's status to `done`, found by searching the spec branch's history of the ticket file (`git log <spec branch> -S 'status: done' -- <ticket path>`). Found → the close and everything under it is reachable. Not found → the close never reached the spec branch (a branch deleted or never merged): the spec diff is silently missing that ticket — stop; if its branch survives, offer that ticket's close-out merge per [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md) (ticket branch → spec branch); if not, warn that the work is recoverable only from the reflog. Never infer "merged" from a branch's absence.

   **One preflight the script cannot make:** the running retro must be committed before the synthesis consumes it — the rewrite preserves the running form in git history *only* (see [RETRO-FORMAT.md](../../_shared/RETRO-FORMAT.md)). An *untracked* `retro.md` never trips the script's dirty check (tracked-only by design) yet has no history at all: verify the running retro is tracked, and refuse if not — name the exact path and the always-works fix: commit it on the spec branch, then re-run `/retro`. (Only when a ticket's `done` flip is *also* uncommitted is resuming that `/done` close the better route — its commit gate carries the retro along.)

   Run the script:

   ```
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/materialize-diff.sh" <base> <head>
   ```

   On success the diff is at `.agentic-flow/diff.patch` — the fact-checker has no git access; this artifact is its only view of the diff. On any non-zero exit, follow the shared doc's exit-code table: relay stderr and stop — never fall back to a hand-rolled `git diff`. Exit 5 (dirty tree) is the one exit `/retro` interprets before stopping. Classify the dirty paths (store-artifact paths per STORE.md's artifact map: `docs/specs/**`, `docs/adr/**`, `docs/spikes/**`, `docs/reviewers.md`, `CONTEXT.md`, `.agentic-flow/settings.toml`; everything else is implementation) and route per the interrupted-close discriminator in [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md), read against this skill's store-edit order (late-stage deviations → synthesis rewrite → pointer clear → `Done` flip last):
   - **Any implementation path is dirty** — refuse, naming the convention: implementation is committed before close-out runs. Print the implementation paths; the user commits *those paths only* — co-present store-artifact dirt stays in the tree (a resume signal; the rule is the convention's implementation-dirt row).
   - **This spec's `Done` flip is in the tree, uncommitted** — `/retro`'s own interrupted close. The flip is last, so every earlier store edit *should* have landed — verify the two observable ones instead of trusting the invariant (hand-edited flips and sessions on pre-convention prose present flip-dirty states that violate it): the retro is in cleanly synthesized form, and the pointer no longer names this spec. Both hold → resume directly at the gated commit (step 13). The pointer still names it → clear it (step 11), then the commit gate. The retro isn't cleanly synthesized → the flip's promise is broken; route by the retro's actual state per the arms below, not by the flip.
   - **Flip absent; `retro.md` is dirty but already in *synthesized* form** (a `# Retro:` heading with per-section outcome labels, not per-ticket entries) — a crash between the synthesis rewrite and its commit. Resume from the first absent store edit (pointer clear, then flip), then the gated commit — **never re-run the synthesis**: the rewrite already landed, and the commit gate's show-content rule gives the resumed run's user the review the crashed session's confirmation can't carry over. A rewrite that crashed *mid-write* leaves a hybrid instead — a `# Retro:` heading with leftover per-ticket entries, or visibly truncated sections. A hybrid is a corrupt rewrite, not a landed one: restore the committed running form (`git checkout -- <retro path>`) and re-synthesize from step 6 — lossless precisely because the committed-running-retro precondition guarantees history holds the running form.
   - **Flip absent; the running retro has uncommitted content** (a modified `retro.md` still in running form) — **refuse: the running retro must be committed before the synthesis consumes it** (the same precondition as above; synthesizing over uncommitted entries destroys them with no recovery path). This dirt belongs to an earlier close — an uncommitted ticket `done` flip alongside it is an interrupted `/done` close-out: point at re-running `/done`. Otherwise have the user commit the running-retro edits, then re-run `/retro`.
   - **Flip absent; other store-artifact dirt, retro untouched** (e.g. step-5 late-stage deviations from a crash before synthesis) — resume from step 4, re-running the fact-check and applying step 5 idempotently: the fact-check isn't a store-writing step, so its completion can't be read from the tree, and the dirt may hold only a *partial* application of the crashed run's findings — re-running is what makes the idempotent re-apply safe. To re-materialize the diff for that resumed fact-check, set the store dirt aside per [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md)'s resume recipe (self-identifying stash → script → immediate pop; its entry check catches a leftover stash from a prior crash before tree state is classified).

4. **Invoke `agentic-flow:deviation-fact-checker`** with, at minimum:
   - The diff artifact path (`.agentic-flow/diff.patch`)
   - The spec (properties + body)
   - All the spec's tickets
   - The Glossary
   - Existing ADR titles + statuses
   - A reminder that it has Read/Grep over the working tree and must verify claims against current source, not stale comments — every recorded fact-checker false positive traced to diff-only briefing
   - The planning-artifact label per [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md), carried whole. A spec-scope diff is *guaranteed* to contain store-artifact hunks — every ticket's committed close-out edits (deviations, retro entries, status flips) — so the label is load-bearing here, not decorative. Store-artifact hunks are planning artifacts exempt from *code* review only, **not** from injected-instruction or unexpected-file-shape scrutiny. Copy the shared doc's two-sided contract into the brief; paraphrasing it once dropped the scrutiny half.

   The fact-checker returns the three sections its agent definition pins — Deviation gaps, Misrepresented deviations, ADR candidates — here at spec scope. Same threshold applies (see [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md)) — below-threshold churn doesn't accumulate into deviations at spec scope; don't surface it.

   Adversarially review findings against cited diff hunks. Spec-scope gaps tend to be cross-cutting things ticket-level diffs missed (a seam that shifted across multiple tickets but no single ticket captured it cleanly), not new instances of below-threshold churn.

5. **Apply confirmed late-stage updates.** Append any newly-discovered deviations to the relevant ticket's `## Deviations` (it's late, but better than missing them). Surface ADR candidates for explicit decision. If the fact-check returns `_None._` across the board, that's a clean spec — proceed to synthesis.

6. **Read inputs for synthesis:**
   - The spec — section structure and intent.
   - The running retro — per-ticket entries with outcome labels.
   - Each ticket's `## Deviations` section — granular divergences (including `(refactor)`-marked entries).

7. **Synthesize per spec section.** For each of the spec's five sections (Problem, Goals, Non-goals, Approach, Modules touched):
   - Determine the dominant outcome label across the tickets that touched this section. If the section had no real activity (e.g. Non-goals usually doesn't change), label it `Exact match` and say so briefly.
   - Write 1–3 sentences of commentary anchored in concrete tickets and deviations. Reference tickets by number when a lesson is anchored in one.

8. **Synthesize the Refactor section** if any `(refactor)`-marked deviations exist across tickets. Aggregate into one section with an outcome label and 1–3 sentences. Reference specific tickets where the refactor work landed. Omit the section entirely if no `(refactor)` deviations exist.

9. **Optional Cross-cutting appendix.** If lessons don't fit any spec section or the Refactor section (e.g. terminology issues that spanned multiple sections, Glossary updates that landed mid-spec), capture them here. Omit when empty.

10. **Restructure the running retro in place — non-destructively.** Before anything else: if `retro.md` is *already* in synthesized form, the rewrite already happened; skip to step 11 rather than synthesizing over it. Before writing, **inventory every part of the current running retro that the synthesized form will not carry forward** — anything beyond the running per-ticket entries: findings notes, analysis writeups, co-resident deliverables from tickets or spikes. For each, either fold it into the synthesis or relocate it to its defined home (a spike artifact for findings-type deliverables, the relevant ticket, or wherever the user directs). **Present the drop-list and destinations to the user and wait for confirmation before rewriting** — this checkpoint is blocking. Only the running per-ticket entries are fair game to consume silently; they're what the synthesis is *made of*. The running form is preserved in git history, but history is where content goes to be forgotten — relocation, not history, is the recovery path. (A synthesis pass once silently deleted a ticket's entire findings deliverable; this gate exists because of it.)

11. **Clear the active pointer** *if it names this spec* (delete `docs/specs/.active` — its one line is the spec directory name, `<NNN>-<slug>`, the form to compare against). If the user has manually pointed it at a different spec, leave it alone. This edit comes *before* the flip: the status flip is the close's **last** store edit — the published invariant of [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md) that step 3's recovery routing reads.

12. **Flip the spec** status from `Open` to `Done` — the close's last store edit. Ordering discipline per STORE.md: read → apply the status edit → only then any git commands, never batched in parallel.

13. **Commit the close-out edits (gated).** Run the gated close-out commit per [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md) — enumeration from `git status` over store-artifact paths including untracked files, explicit `git add` of the enumerated paths (never `-A`; the deleted `.active` pointer stages by path like any other edit), show-content-on-resume, the decline wedge statement. `/retro`'s bindings:
    - **The branch**: the spec branch — everything the close wrote lands there, ahead of the merge.
    - **The edit set**: every store edit this invocation made — the synthesized `retro.md`, the spec file (`Done` flip), the deleted active pointer, late-stage ticket deviations (step 5), any ADR minted at step 5's candidate gate, any content relocated by step 10's drop-list. Relocations can land outside the store-artifact map ("wherever the user directs"), so union the drop-list's destinations into the enumeration — the `git status` scan over store paths cannot see them. Offer: *"Commit the close-out edits (`<paths>`) on the spec branch?"*
    - **Re-entry**: when step 3 detected an interrupted close, resume *here* once every close-out artifact is in place — the convention's show-content rule applies in full, since the resumed run didn't author these edits.
    - On accept: commit; the tree is clean for step 14. On decline: the convention's wedge statement, naming this skill — re-running `/retro` resumes at this commit.

14. **Offer the spec merge (gated).** Run the gated merge per [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md), bound spec branch → the resolved default branch — the same resolution as step 3's diff base, so the diff's scope and the merge target cannot disagree: convention read from config / the repo's CLAUDE.md (`--no-ff`), verify green, delete the spec branch only after green. Unlike `/done`, there is no refactor-pass fork — no later pass owns this merge; this offer is its only home. On decline: name the resting state (`Done`-but-unmerged, the spec branch alive) and that re-running `/retro` re-offers the merge directly — the gate is re-enterable until the merge lands.

## Synthesized structure

```markdown
# Retro: <spec title>

## Problem — <outcome label>

<commentary>

## Goals — <outcome label>

<commentary>

## Non-goals — <outcome label>

<commentary>

## Approach — <outcome label>

<commentary>

## Modules touched — <outcome label>

<commentary>

## Refactor — <outcome label>

<commentary; aggregates (refactor)-marked deviations across tickets>

## Cross-cutting

- <bullet per cross-cutting lesson>
```

`## Refactor` and `## Cross-cutting` are both optional — omit when no relevant content exists.

## Refusing to run

- If the spec is already `Done` *and that flip is committed*, check the merge before refusing — `Done`-but-unmerged is the *normal* resting state of a declined step-14 offer, not a closed chapter:
  - **Spec branch merged into the default branch** — fully closed. Refuse; the synthesized retro and git history are the record.
  - **Spec branch already deleted** — verify closure positively before certifying it: the spec's close commit (the one that flipped it `Done`, found via `git log <default branch> -S 'status: done' -- <spec path>`) must be reachable from the default branch. Reachable → fully closed, refuse as above. Not reachable → the branch was deleted out-of-convention with the work unmerged — warn loudly (recovery is reflog-only and expiring) instead of certifying a closed chapter. Never infer "merged" from a branch's absence.
  - **Spec branch exists and is not an ancestor of the default branch** — name the state ("spec NNN is closed but its branch is unmerged — the deferred merge never happened") and re-offer the merge (step 14) directly: no re-fact-check, no re-synthesis — after one look at the tree. Clean → offer. Dirty → the dirt belongs to some pass's close-out per [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md)'s discriminator (this path never runs the script, so nothing else classifies it) — name the dirt's owner and stop; never merge over a dirty tree. The lifecycle's last gate is re-enterable from every resting state — a declined or forgotten merge must never orphan the branch.
- If any ticket isn't `Done`, refuse with a list of outstanding tickets.
- An uncommitted `Done` flip plus store-artifact dirt is **not** an already-closed spec — it's this skill's interrupted close (step 3's discriminator). Resume at the gated commit instead of refusing.
- An uncommitted running retro — modified, or untracked entirely — refuses per step 3: the synthesis must never consume content git history doesn't hold.

## Anti-patterns

- **Don't write `## Next steps`, `## Future work`, or `## Roadmap`.** Strictly backward-looking. Forward-looking lessons go into a new spec.
- **Don't fabricate outcomes.** If you can't tell from the running retro, deviations, and fact-checker output what happened in a section, ask the user.
- **Don't lose ticket-level granularity.** Reference specific tickets by number when a lesson is anchored in one.
- **Don't include `## Refactor` or `## Cross-cutting` if there are no entries.** Omit them entirely.
- **Don't pad sections with below-threshold deviations to look thorough.** Internal refactors, private renames, formatting churn — none of that belongs in a synthesized retro. If a section's tickets had no above-threshold divergence, label it `Exact match` and move on.
- **Don't skip the fact-check step even if every `/done` already fact-checked cleanly.** Spec-level diff often surfaces things ticket-level diffs miss — particularly seams that shifted gradually across tickets where no single ticket captured the cumulative move.
- **Don't clear the active pointer if it names a different spec than the one being closed.** The user may have switched context manually.
- **Don't drop content the synthesis didn't write.** Anything in the running retro beyond the per-ticket entries gets inventoried and relocated with user confirmation, never silently consumed by the rewrite.
- **Don't apply a different deviation threshold than `/done` did.** The threshold (including its tooling-surface ruling) lives in [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md) alone — a change that passed the per-ticket fact-check must not flag at spec scope under a stricter reading.
- **Don't synthesize over an uncommitted running retro.** The rewrite's only preservation of the running form is git history; content that history doesn't hold is destroyed, not restructured. Refuse until it's committed.
- **Don't re-synthesize on resume.** A cleanly synthesized `retro.md` already in the tree means the rewrite landed; a resumed close continues at the first absent store edit and the commit gate's show-content review — a second synthesis would consume its own output. The one exception is a *corrupt* rewrite (step 3's hybrid state): restoring the committed running form and re-synthesizing is safe there precisely because the precondition guarantees history holds it.
- **Don't hand-roll a diff when the script refuses.** A non-zero exit from `materialize-diff.sh` is a stop with a reason — falling back to `git diff` is exactly the skipped preflight the convention exists to prevent.
- **Don't stage the close-out commit with `-A` or `git add .`.** Enumerate the paths this invocation edited; blanket staging sweeps unrelated working-tree state into the close-out commit.
- **Don't merge without an explicit yes.** The merge offer is a gate, not a notification — silence or an unanswered question means stop, not proceed.
