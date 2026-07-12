---
status: done
---

# Slim the baseline

## Problem

The plugin's close-out semantics are sound — an adversarial nine-axis comparison against mattpocock/skills (18 agents, every claim skeptic-verified) scored it best-in-class on workflow soundness, grounding, and corpus maintainability — but the same comparison confirmed that context economy is its worst axis and that the trajectory is the real threat: PRD 001 grew the corpus from 37,468 to 47,516 words (+26.8%) in one dogfood round, the heaviest lifecycle skills each load 8,850–11,898 words of instructions per invocation, and roughly two-thirds of the added mass is crash-recovery prose for rarely-fired states that now taxes every run — a direct strain on the author's session-hygiene rule of never exceeding ~30% context usage.

Two structural passengers make this worse. The notion backend exists only for day-job use, which ADR 0001 already assigns to a separate future plugin — so every skill carries store-neutrality prose and notion arms for a backend with no remaining user in this plugin (retired by ADR 0003). And the "PRD" name misdescribes the artifact: it is a frozen scope document — a spec.

The comparison also surfaced a short list of verified cross-document defects (a /done↔/retro contradiction on deleted branches, an ADR-0002 citation that leaks this dogfood repo into shipped plugin prose, a path-list shorthand that omits the config file from close-out enumeration, and several smaller ones) and one genuine capability gap worth importing from the other lineage: nothing in the close-out chain judges implementation correctness against the ticket — the deviation-fact-checker is deliberately bookkeeping-only, so outcome labels rest on deviation honesty alone.

The Work plugin will compose with this plugin's Knowledge layer by invocation — never by forking — and pattern its own Lifecycle layer on this one (ADR 0001). The baseline must be lean and correct before it becomes that template.

## Goals

- The plugin is files-store-only (ADR 0003): no notion arms, notion prose, or store-resolution ladder remain in any skill or shared doc; the resolver is preserved via a pinned pre-removal commit reference in the banked work-workflow idea, not as a live file.
- "Spec" replaces "PRD" as the artifact vocabulary throughout the plugin — skill names, shared docs, branch convention, store paths — and this repo's own planning artifacts are migrated to the new paths.
- Hard acceptance: the measured per-invocation load of each of the four heaviest closures — /refactor (11,898 words), /done (10,264), /retro (9,607), /to-tickets (8,850) — drops by at least a third. A closure is SKILL.md plus every doc the skill unconditionally instructs the executor to read; on-demand docs count only on their trigger paths. No recovery semantics are removed — relocated per ADR 0002's placement test, never deleted.
- Target, explicitly subordinate to safety: the total plugin corpus lands at or below ~40,000 words (from 47,516) after the code-review import. The fleet's final audit checks the number and reports any miss with its cause; meaning-preserving verification outranks the count.
- Session-prompt description load drops from ~720 to ~300 words (~25-word descriptions, model-invocation trigger phrases kept). Only setup joins the already-disabled /new under disable-model-invocation; every other skill stays model-invocable, because steering-prompt session handoffs and the ask-then-run /done chain depend on it (semantics verified against the Claude Code docs: a disabled skill's description never enters context).
- Every verified defect from the comparison report is resolved or explicitly declared accepted.
- Ticket close-out gains a spec-conformance review axis, and the default Reviewers manifest gains an always-on standards/smell reviewer, both adapted from the compared repo's code-review design.
- Two observed-usage items from docs/development-workflow.md land: the ticket-start research opener becomes unconditional (its config axis is cut — months of use are the promotion evidence), and /done's closing fork is reframed refactor-pass-centric — "run the refactor pass, or don't" — with a judgment recommendation driven by the nature of the diff (code touching seams or multiple modules recommends the pass; doc-only or output-capture work recommends skipping to the merge).
- The plugin's CLAUDE.md gains the corpus-wide authoring rule: a recommendation is never offered without its reasoning and why it beats the alternatives. The rewrite enforces the rule across every recommendation-offering passage.

## Non-goals

- No gate or blocking-checkpoint reductions — the confirm-gate doctrine stands. Auto-commit and auto-/done are deliberately banked (ideas/codify-the-implementation-loop) for their own grill, as is the implement skill.
- No work-plugin features (concurrency safety, worktrees, Jira, PR/CI close-out) — ADR 0001 places those in a separate plugin.
- No re-litigation of ADR 0002 — the inlined hot-path copies stay inlined; corrections to the path list fan out to every copy as the ADR's sync-set consequence requires.
- No behavioral weakening of PRD 001's recovery machinery — prose moves, guarantees don't.
- No model-invocation removal beyond setup.
- Banked ideas not explicitly absorbed here stay banked.

## Approach

Ordering, so each pass shrinks the surface the next one edits and the fleet's ledgers capture corrected contracts: notion removal (pure deletion, ADR 0003) → spec rename (mechanical, smaller after deletion; the branch this work rides on keeps its birth name, the new convention applies from the next spec) → surgical defect fixes plus the two absorbed behavior edits and the CLAUDE.md authoring rule → the slimming fleet → the code-review import, whose new prose is written to the fleet's charter voice.

Notion removal deletes the resolver and every notion arm and collapses STORE.md into a lean files-only artifact map; the removal commit's predecessor hash is recorded in the banked work-workflow idea so the future plugin consults the resolver deliberately from history rather than inheriting it by inertia.

The rename is a full vocabulary change (spec, /to-spec, /next-spec, SPEC-FORMAT, spec-NNN-slug branches, docs/specs/ paths), a migration of this repo's own artifacts, and a short migration note for consuming repos.

Defect fixes are surgical: the deleted-branch rule reconciles to /retro's positive-verification discipline; shipped prose stops citing this repo's ADR numbers and instead cites the placement test where it lives in the plugin's own docs; the path-list copies gain the config file with fan-out to every copy; the plugin CONTEXT.md's concurrent-open claim is corrected to the serialized reality; the dangling CONTEXT-MAP reference is dropped; abandoning a spec becomes a documented manual recipe with one named home; and /to-spec gains a read-the-named-modules step before freezing Modules touched.

"Trim" is five ordered operations against a protected list. Operations: delete (notion arms, the four consumer restatements of CLOSE-OUT's mechanics under its own no-restate rule, duplicate anecdote copies), relocate (rarely-entered recovery procedures move to one on-demand single-homed doc entered when a discriminator fires; per-run discriminators stay inline — ADR 0002's placement test is the design rule), dedup (multi-home contracts collapse to authority plus citation, except the ADR-0002-protected hot-path copies), compress, and descriptions. Protected and never trimmed or reworded: State contract sections, gate and blocking-checkpoint declarations, marked protected-behavior blocks, the diff-materialization exit-code table, and incident citations — kept exactly once each, at the rule they justify. Outside the verified fleet, normative prose moves whole or dies whole; paraphrase of normative prose happens only inside the fleet's verification.

The slimming fleet executes relocate, dedup, and compress as ordered, individually-gated stages of one workflow (quality-max shape, ≈4M tokens against a 5M cap). Stage-0 cartography builds numbered clause ledgers, a protected-span manifest hash-checked by script after every writing stage, and canonical sync-set cards. Writers own write-disjoint clusters — every file has exactly one writer — and stamp sync-set copies from the cards rather than authoring them; a user-gated style charter precedes all rewriting and carries the recommendation-with-reasoning rule. Verification is layered and independent of the writers: blind clause-coverage re-derivation, adversarial dropped-rule hunters (including modal weakening — must→should, never→avoid), executor simulation on the four heaviest closures asserting identical routing against synthetic repo states, sync-set and link-integrity cross-checks, and a whole-corpus voice pass whose touched files re-enter verification, closed by a coherence-and-numbers audit. Models are tiered deliberately: top tier for cartography, the charter, all writers, half the hunters, most simulation seats, the voice pass, and the final gate; opus tier for the blind verifiers, the other hunters, and the fix loop — decorrelated verification is a quality choice, not an economy; sonnet tier for mechanical cross-checks and one simulation seat as a weak-executor robustness probe.

The code-review import keeps each lineage's doctrine where it belongs: a spec-conformance sub-agent runs in /done alongside the deviation-fact-checker — the fact-checker's no-editorializing boundary is untouched; correctness judgment lives in the new agent — with the two reports presented separately, never merged or reranked, before the outcome label. The standards axis lands as a new always-on reviewer agent in the default manifest (Fowler smell baseline plus repo-standards discovery, repo standards overriding the baseline, findings always labeled judgment calls), dispatched by /refactor, whose convergence-based merge stays as is.

## Modules touched

- Shared conventions: STORE.md (collapse), NOTION-RESOLVER.md (removed), CLOSE-OUT.md, DIFF-MATERIALIZATION.md, the format docs (PRD→SPEC, TICKET, RETRO, ADR, CONTEXT), a new single-homed recovery convention doc.
- Lifecycle skills: next-prd→next-spec, to-prd→to-spec, to-tickets, next-ticket, done, retro, grill-me, refactor, setup (including the ticket_start config axis it provisions).
- Agents: deviation-fact-checker (rename references only; boundary unchanged), a new spec-conformance agent, a new standards/smell reviewer agent, the Reviewers manifest defaults.
- Plugin meta: README, CONTEXT.md, CLAUDE.md (authoring rule), plugin.json, skill frontmatter (descriptions, disable-model-invocation).
- This repo's planning store: docs/prds/ → docs/specs/ migration, the work-workflow idea (pinned resolver reference), and the banked ideas created during this grill.
