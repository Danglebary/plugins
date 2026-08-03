---
name: refactor
description: "Multi-reviewer review-and-improve pass over a just-closed ticket's diff: dispatch the Reviewers-manifest agents, surface deepening opportunities through the deepening framework, grill accepted candidates, capture (refactor) deviations. Use after /done — architectural review, not just cleanup."
---

# Refactor — architectural review-and-improve

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability. The code and its diff stay in git; the Reviewers manifest, Glossary, ADRs, and ticket deviations live in the store.

This skill runs **per ticket** after `/done`, before the next ticket starts.

Store artifact paths: [STORE.md](../../_shared/STORE.md).

## State contract

- **Spec state required**: `Open` (typical, post-`/done`)
- **Ticket state required**: `Done` (typical: just-closed ticket whose diff is the review target)
- **Transition**: none (may create ADRs inline; appends `(refactor)` entries to ticket's `## Deviations`; may bank outside-spec deferrals as Ideas)

May also run ad-hoc at any spec/ticket state for general architecture review, but the per-ticket pattern is the typical use. Invoked after a merge-now close (ticket branch already deleted), it routes to the ad-hoc arm over the merge commit's recoverable range — see step 3.

## Glossary

Use the vocabulary in [LANGUAGE.md](LANGUAGE.md) — module, interface, implementation, depth, seam, adapter, leverage, locality. Don't drift to "component," "service," "API," or "boundary."

Three principles you'll apply repeatedly:

- **Deletion test**: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

The domain language names good seams; ADRs record decisions the skill should not re-litigate.

## Process

1. **Read the Glossary and any ADRs in the area you're touching.** Domain naming should come from the Glossary; ADRs constrain what's already settled.

2. **Read the Reviewers manifest.** Each entry is a namespaced agent name (e.g. `pirr:qa-engineer` for plugin-shipped, bare names for repo-specific in `.claude/agents/`). Format references: [REVIEWERS-FORMAT.md](../../_shared/REVIEWERS-FORMAT.md), [AGENT-FORMAT.md](../../_shared/AGENT-FORMAT.md).

   The next two moves run **in this order** — compose the record, *then* check the names. The order is the whole point: the check refuses, and a record composed after it would not exist in the one case that refusal describes.

   **Compose the dispatch record from the manifest names — before any result arrives, and before the check below.** Enter every manifest entry unsettled, and settle each as its result lands or fails to, per the shared doc's four states (`returned`, `degraded`, `refused`, `unresolved`). Composing it from the returns instead would make a lens that never ran invisible — the failure the record exists to prevent.

   **Verify each name resolves** — the **Resolution preflight** ([EVIDENCE-PRINCIPLE.md](../../_shared/EVIDENCE-PRINCIPLE.md)). If any listed agent isn't registered, mark those names `unresolved` in the record and **refuse with a clear list of them, emitting the record as part of the refusal** — silent skipping presents an incomplete review as complete. The pass ends before step 9, so that emission is the record's only one; no retro entry receives it. The usual cause is a newly authored or renamed agent that isn't a registered dispatch type until the plugin reloads.

   **Anti-substitution.** A `subagent_type` that does not resolve means *that lens did not run* — **never recover it by inlining the agent's body into a general-purpose agent**, the way step 3's exit-code discipline never falls back to a hand-rolled `git diff`. An inlined agent reproduces the output contract, so the degraded return looks on-contract and nothing downstream can tell: the recovery is forbidden rather than detected. Report the lens as not having run; don't manufacture its findings.

3. **Materialize the diff via the shared convention.** Route on the just-closed ticket's branch first:
   - **Ticket branch exists** (typical — `/done`'s refactor-pass arm): resolve refs per [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md) — `<base>` is the spec branch, `<head>` is the ticket branch.
   - **Ticket branch deleted** (a merge-now close already happened): there is no post-merge mode — route to the ad-hoc arm with the recoverable range. Identify the ticket first: default to the active spec's most recently closed `Done` ticket (its close is the newest ticket merge on the spec branch); several plausible → ask. Then find that ticket's `--no-ff` merge commit on the spec branch (`git log --merges --first-parent <spec branch>`, matched by the ticket branch name — or the ticket number where the merge message was customized; missing or ambiguous → ask the user, never guess). Resolve `<base> = <merge-commit>^1`, `<head> = <merge-commit>` per the shared doc's post-merge row. **The handover is a confirm gate, not a notification**: present the identified ticket and the resolved range, end the turn, and dispatch only on the user's confirmation — an unanswered proposal is not consent. In this arm refactor commits land on the **spec branch**, and `(refactor)` captures still append to the `Done` ticket (step 8).
   - **General ad-hoc invocation**: ask the user for the scope. A ref pair is materialized via the script all the same; a files-or-tree scope needs no diff artifact.

   Then run the script:

   ```
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/materialize-diff.sh" <base> <head> [--allow-untracked <path>...]
   ```

   On success the diff is at `.pirr/diff.patch`. On any non-zero exit, follow the shared doc's exit-code table: relay stderr and stop — never fall back to a hand-rolled `git diff`. Exits 5 and 8 are the two this skill interprets before stopping. Both classify their paths against the same division — **store-artifact paths per STORE.md's artifact map** (`docs/specs/**`, `docs/adr/**`, `docs/spikes/**`, `docs/reviewers.md`, `CONTEXT.md`, `.pirr/settings.toml`); everything else is implementation. A path under none of those and recognizable as neither — scratch notes, an editor backup, un-ignored build output — is **not** implementation: refuse on it too, but say only that it can't be classified and point at `.gitignore`, never that work would fail to ship.

   **Exit 5 (dirty tree)**: `/done` commits every close-out edit before its fork, so this pass starts from a clean tree by construction. Route the dirt per the interrupted-close discriminator ([RECOVERY.md](../../_shared/RECOVERY.md#resting-states)): implementation dirt is uncommitted work — surface it and stop; store-artifact dirt with the ticket's `done` flip *uncommitted* is `/done`'s interrupted close-out — point back at re-running `/done`; store-artifact dirt with the flip already committed is this skill's own interrupted pass — resume at the close-out (step 9), where the convention's show-content-on-resume rule governs the straggler commit.

   **Exit 8 (untracked paths).** The arms are inlined here rather than cited, per [ADR 0002](../../../../../docs/adr/0002-hot-path-classifications-stay-inlined.md) — this is a mid-step classification on the hot path, and a refactor pass runs on a tree that routinely carries banked ideas and drafted specs, so it is the routine case, not a rarely-entered procedure. Classify **per path, never by the set as a whole**: [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md)'s enumeration is per-entry, and a whole-set test leaves a mixed tree matching no arm.
   - **Any reported path is implementation** — refuse, naming the convention: implementation is committed before a close-out or a refactor pass runs. Say plainly what the exit prevented: *a never-staged file is absent from the diff and from the close-out commit's enumeration — reviewing now would review nothing of it*. Print the implementation paths; the user stages or removes them, then re-runs `/refactor`. This arm fires even when legitimate planning artifacts are reported alongside — one unstaged implementation file refuses the whole pass.
   - **No reported path is implementation** — proceed: re-invoke the script with `--allow-untracked` naming **every** reported path. This pass authored nothing before step 3, so **every** store path it acknowledges here is foreign by construction — name them all to the user as excluded from the reviewed diff. (That is a stronger binding than `/done`'s, whose own in-flight edits pass without comment; do not carry `/done`'s split over.) Relaying and stopping instead would wedge the common case rather than catch anything.

4. **Dispatch each reviewer in parallel** via the Agent tool, **pinning the exact agent type on every dispatch** — pass each manifest name as `subagent_type` verbatim. The field is optional at the tool boundary and an omitted type silently resolves to a general-purpose agent, which is the anti-substitution failure reached by omission rather than by choice. Reviewer agents read only the working tree (`Read/Grep/Glob`, no store access), so the brief must carry every planning input they need: resolve each from the store (step 1) and inline it. Every reviewer brief contains:
   - **The diff itself, inlined as content** — not `.pirr/diff.patch`'s path. Reviewers hold no path to it by contract: exactly two agent bodies name that artifact and [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md)'s two-agent contract is published, so handing a reviewer the path both widens that contract and hands a `Read`-only agent a file it was never promised. In a files-or-tree ad-hoc scope there is no artifact at all — inline the scope description. Plus the steering prompt: *"Review the following changes through your area of expertise. Identify deepening opportunities or architectural concerns per your lens. Output structured findings with file/line citations."*
   - **The closed ticket's `## Goal` and `## Acceptance criteria`** — the contract the change was meant to satisfy.
   - **The closed ticket's `## Deviations`** — already-settled divergences are not findings.
   - **The Glossary's domain vocabulary** (terms + one-line definitions) — so findings name concepts in the project's language, not generic placeholders.
   - **Settled ADR titles + their one-line decision**, marked *"do not re-litigate"*.
   - **The spec's open-ticket list** — work already scheduled is not a finding.
   - **Deferred candidates from previous passes** (see step 7) — both ticket-appended steers and outside-spec deferrals banked as Ideas (`docs/specs/ideas/`) — already deferred or banked is not a new finding.
   - **The planning-artifact hunk label** per [DIFF-MATERIALIZATION.md](../../_shared/DIFF-MATERIALIZATION.md)'s "Diffs contain planning artifacts" section, carried whole — copy the section's two-sided contract into the brief, never a paraphrase of it.
   - One output requirement: *"verify any severity-determining claim about an external system (stdlib, build APIs, language semantics) against the installed toolchain before asserting it — and when your tool grant cannot run that check, register the surface rather than asserting or silently dropping the claim."*

     The escape hatch is load-bearing, not politeness: every shipped reviewer holds `tools: [Read, Grep, Glob]` and can execute nothing, so the bare instruction ordered a check no lens could perform. The register is where an unrunnable check goes ([EVIDENCE-PRINCIPLE.md](../../_shared/EVIDENCE-PRINCIPLE.md)'s worked example is this exact case).

     **There is no per-area "checked, clean" requirement.** Enumerated coverage is the rejected form (ADR 0006) — the Partial verdict register each reviewer already ends with lists *gaps*, never inventory, and it is what answers "silence is indistinguishable from not-looked." Don't reintroduce the enumeration in a brief; a lens that examined fifteen areas cleanly says so in one sentinel, not fifteen lines.

5. **Merge findings through the deepening framework.** Classify each candidate by whether it represents a shallow module, leaky seam, missing locality, or untestable interface. Apply the **deletion test** to anything you suspect is shallow — "Concentrates" is the signal you want.

   Three merge-layer contracts:
   - **Adversarially verify reviewer factual claims against source before relaying them.** A finding built on a false premise must die here, not in front of the user.
   - **Convergence count is a ranking input.** Surface convergence explicitly ("4 of 5 reviewers flagged this").
   - **Check each return for its Partial verdict register — presence only, never contents** ([EVIDENCE-PRINCIPLE.md](../../_shared/EVIDENCE-PRINCIPLE.md), [AGENT-FORMAT.md](../../_shared/AGENT-FORMAT.md)). A return arriving without one is **degraded, not returned**: settle its dispatch-record entry (step 2) that way. A degraded return's findings still merge normally — the register's absence says its *gap check* is unaccounted for, not that its findings are wrong. It also means that lens must not be counted as clean coverage in the convergence read above.

   If the Reviewers manifest is missing or empty, fall back to a generic exploration looking for the same kinds of friction:
   - Where does understanding one concept require bouncing between many small modules?
   - Where are modules **shallow** — interface nearly as complex as the implementation?
   - Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
   - Where do tightly-coupled modules leak across their seams?
   - Which parts of the codebase are untested, or hard to test through their current interface?

6. **Present candidates** as a numbered list. **Candidate inclusion and deviation recording are two different bars — don't conflate them.** The seam-level threshold in [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md) gates what gets *documented* in `## Deviations` (step 8); it does **not** gate what gets *proposed or fixed*. Cheap below-seam cleanups a reviewer surfaced are valid candidates; include them (grouped as minor cleanups, distinct from the deepening candidates). For each candidate:
   - **Files** — which files/modules are involved
   - **Problem** — why the current architecture is causing friction (cite which reviewer surfaced it, and the convergence count when more than one did)
   - **Solution** — plain English description of what would change, argued from the repo's recorded design philosophy (CLAUDE.md weighting, ADRs) — not from generic churn or diff-size caution. State whether it derives from first principles or precedent, and mark load-bearing constraints as user-stated vs assumed.
   - **Benefits** — explained in terms of locality and leverage, and how tests would improve

   **Use Glossary vocabulary for the domain, and [LANGUAGE.md](LANGUAGE.md) vocabulary for the architecture** — "the Order intake module," never "the FooBarHandler."

   **ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant revisiting the ADR. Mark it clearly. Don't list every theoretical refactor an ADR forbids.

   If no candidates surface, report that and proceed to the close-out (step 9). A no-op refactor pass is a valid outcome, but it still runs the close-out gates. The same applies when candidates were presented and the user accepts none.

   Do NOT propose interfaces yet. Ask the user: *"Which of these would you like to explore?"*

7. **Grilling loop.** Once the user picks a candidate, walk the design tree with them — constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive. Side effects happen inline as decisions crystallize:
   - **User defers a candidate to a named future ticket?** Append it to that ticket's `## Implementation notes` (or a `### Deferred steers` subsection there) immediately. A deferral that lives only in chat evaporates at the session boundary — reviewers re-proposed exactly such items in past runs.
   - **User defers a candidate that belongs to no ticket in the active spec?** Bank it as an Idea per STORE.md's artifact map (`docs/specs/ideas/<slug>.md`, un-numbered) — same evaporation rationale. Content per `/to-spec`'s Idea bar: one paragraph to a page, enough to re-find the thought, no more. The close-out's pending-store-edits check (step 9) commits the new file; banked deferrals feed the next pass's brief (step 4). Idea *promotion* is out of scope here — banking is the whole move.
   - **Naming a deepened module after a concept not in the Glossary?** Add the term to the Glossary — same discipline as `/grill-me` (see [CONTEXT-FORMAT.md](../../_shared/CONTEXT-FORMAT.md)).
   - **Sharpening a fuzzy term during the conversation?** Update the Glossary right there.
   - **User rejects the candidate with a load-bearing reason?** Offer an ADR, framed as: _"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"_ Only offer when the reason would actually be needed by a future explorer to avoid re-suggesting the same thing — skip ephemeral reasons ("not worth it right now") and self-evident ones. See [ADR-FORMAT.md](../../_shared/ADR-FORMAT.md).
   - **Need to classify dependencies before deepening?** See [DEEPENING.md](DEEPENING.md) for the four dependency categories.
   - **Want to explore alternative interfaces for the deepened module?** See [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md) for the parallel sub-agent pattern.

8. **Capture refactor work.** When refactor changes land (commits to the ticket branch — or the spec branch in the post-merge arm), append to the just-closed ticket's `## Deviations` section with a `(refactor)` prefix:

   ```markdown
   - (refactor) <one-line description of what was deepened/extracted/consolidated and the locality benefit>
   ```

   **Ordering is mandated: append the capture before or with the refactor commit that carries it.** The capture is a store edit that rides its own refactor commit — stage it alongside the refactor's paths — never a follow-up left for later. The close-out's pending-store-edits check (step 9) is the backstop for a straggler, not the convention.

   Threshold same as any deviation — only seam-level moves get captured (see [ABSTRACTION-LEVELS-PRINCIPLE.md](../../_shared/ABSTRACTION-LEVELS-PRINCIPLE.md)). If the refactor pass produced no seam-level moves, append nothing — that's the correct outcome. (This is the *recording* bar, not the *inclusion* bar of step 6 — below-seam cleanups were worth doing; they just don't get an entry.)

   The dispatch record is **not** captured here — it belongs to step 9, which every pass reaches. This step is skipped entirely when no refactor changes landed, and a record placed behind that condition would be unreachable in exactly the no-op case it exists to document.

9. **Close-out — every pass ends here, including a no-op.** The pass ends with refactor commits on the branch it worked on (the ticket branch typically; the spec branch in the post-merge arm; the user's branch in a general ad-hoc pass), one write, then three gates, in order. Gates 2 and 3 are this pass's bindings of [CLOSE-OUT.md](../../_shared/CLOSE-OUT.md) — the convention owns the mechanics:

   **Persist the dispatch record — before the gates, so gate 2 commits it.** Append the record composed at step 2 to the just-closed ticket's running-retro entry (`docs/specs/<NNN>-<slug>/retro.md`), which `/done` already wrote and committed:

   ```markdown
   **Dispatch** (refactor): <the record>
   ```

   The `(refactor)` marker distinguishes it from `/done`'s own `**Dispatch**` line in the same entry — same discipline as step 8's `(refactor)` deviation prefix. Emission is mandatory and detail is gap-only: the clean case is one line (`7 reviewers — all returned.`), and any lens that degraded, refused, or went unresolved is named with what its absence cost. Unlike a `(refactor)` capture there is **no threshold** — a pass that surfaced nothing still records which lenses ran, because that is the pass's coverage claim, not its output. This is why the record lives here and not in step 8: a no-op pass skips step 8 and still owes its record. Field format: [RETRO-FORMAT.md](../../_shared/RETRO-FORMAT.md).

   **The record follows step 8's ticket binding**: it persists only where a `Done` ticket owns the reviewed scope (the per-ticket and post-merge arms). A general ad-hoc pass has no ticket entry to carry it — emit the record to the user and say it wasn't persisted, rather than refusing the pass or inventing a home for it.

   **A pass that never dispatched writes no record.** Step 3's interrupted-pass arm resumes *here*, having read the manifest at step 2 but never reached step 4 — its record is composed and unsettled. Don't settle it by assumption: if the ticket's entry already carries a `**Dispatch** (refactor):` line, the interrupted predecessor persisted its own and it stands; if it doesn't, say so plainly — that pass's record went down with its session and this run cannot reconstruct it. Writing an all-`returned` line for lenses this run never dispatched would be the attestation-as-verification error the record exists to avoid.

   1. **End-of-pass ADR check.** Did any accepted refactor embody a choice that passes the three-gate test and isn't recorded? Offer it — before the commit check, so a minted ADR is committed with the rest.
   2. **Pending-store-edits check** — the convention's gated commit. The edit set: uncommitted store edits *this pass* made — a straggler `(refactor)` capture, **the running retro carrying the dispatch record this step's preamble just wrote**, Glossary edits, minted ADRs, banked Ideas — committed on the branch the pass worked on. The last capture can't be left carrier-less, and a no-op pass that recorded only its dispatch record still has an edit to commit here. On a resume of an interrupted pass (step 3's exit-5 arm), the convention's show-content rule applies: the resuming session didn't author the stragglers, so show their content with the offer, not just paths.
   3. **The merge offer — only when the pass worked a live ticket branch.** The convention's gated merge, bound ticket branch → spec branch. On decline, name the resting state (`Done`-but-unmerged) and differentiate the re-entry routes honestly: re-running `/done` re-presents the fork directly (merge-only); re-running *this skill* runs a full new pass — manifest, diff, reviewer dispatch — before re-reaching this offer.

   **Arms without a ticket branch end after gate 2** — there is no merge to offer. Post-merge ad-hoc: refactor commits are already on the spec branch. General ad-hoc: the work sits on whatever branch the user scoped; any merge belongs to that branch's own lifecycle, not this pass. (Step 8's captures likewise apply only when a just-closed `Done` ticket owns the reviewed scope.)

   **Ratification questions block.** If the pass surfaced a question the user must answer — a new caller-facing contract, a changed public default, a widened public surface — and the answer hasn't come, the work does not merge and the contract does not ship. End the turn and wait. An unanswered question is a "no", not a "proceed". (This pass once self-merged an unratified caller-facing contract; that is the failure this rule exists to prevent.)

## Anti-patterns

- **Don't run before `/done`.** The fact-check + deviation-capture sequence depends on the ticket being `done`; running mid-implementation conflates feature changes with refactor changes.
- **Don't propose more than 3-5 candidates per ticket.** A ticket-scoped pass isn't a full audit; if reviewers surface many, narrow to the highest-leverage ones tied to the ticket's diff.
- **Don't let reviewers' raw output through unfiltered.** Adversarially review their candidates against the deepening framework — drop noise, surface signal.
- **Don't skip the `(refactor)` marker on deviations.** That marker is what makes retro synthesis work.
- **Don't capture below-threshold cleanups as `(refactor)` entries.** Internal renames, control-flow tidy-up, dedup that doesn't cross a module boundary — none belongs in `## Deviations`. The threshold is the seam, not the line.
- **Don't run reviewer dispatch silently if the Reviewers manifest lists agents that don't exist.** Fail loudly with a clear list.
- **Don't recover an unresolved reviewer by inlining its body into a general-purpose agent.** The lens did not run; producing its findings shape anyway manufactures evidence of a review that never happened — and it is undetectable after the fact.
- **Don't dispatch a reviewer without pinning `subagent_type`.** An omitted type is not a neutral default — it silently resolves to a general-purpose agent.
- **Don't ask reviewers to enumerate what they checked.** Per-area "checked, clean" lines are the rejected form (ADR 0006); the gap-only register is what makes silence legible.
- **Don't hand a reviewer `.pirr/diff.patch`'s path.** The diff is inlined as content — only two agent bodies hold that artifact by contract.
- **Don't write the dispatch record only when something broke.** If the clean case writes nothing, an absent record carries no meaning.
- **Don't filter candidates by the deviation-recording threshold.** Dropping a worthwhile cheap cleanup because it "wouldn't be a recordable deviation" conflates the two bars — inclusion is about worth, recording is about seams.
- **Don't merge the pass's work yourself.** Offer the merge; the user owns it. And never ship a contract the user was asked about but didn't answer.
- **Don't end a pass before the close-out.** No candidates, none accepted, nothing recordable — the pass still runs step 9's close-out gates. A pass that walks away early strands a live ticket branch.
- **Don't leave a `(refactor)` capture uncommitted.** The capture rides the refactor commit that motivated it — appended before or with, never after. The close-out check is the backstop, not the plan.
- **Don't let an outside-spec deferral live only in chat.** Bank it as an Idea; chat evaporates at the session boundary and reviewers re-propose it next pass.
