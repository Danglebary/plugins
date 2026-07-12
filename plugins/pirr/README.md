# pirr

A Claude Code plugin: a small, composable set of skills for AI-augmented software development. Built on a four-phase workflow:

```
Plan  →  Implement  →  Refactor / Cleanup  →  Retro
```

The name is a backronym of those four phases — **P**lan · **I**mplement · **R**efactor · **R**etro — so it states the mental model rather than the category.

Two ideas anchor the system:

- **A single store for planning artifacts** — specs, tickets, retros, the glossary, ADRs, and the reviewer manifest live as **in-repo markdown files**: everything in git, reviewable in PRs; see [STORE.md](./skills/_shared/STORE.md). No external issue tracker. Code, branches, and diffs stay in git alongside.
- **Spec/ticket/retro hierarchy** — a frozen-intent (spec) + living-retro pair captures the durable record of each body of work.

## Setup

In a new repo, run:

```
/setup
```

This asks whether `.pirr/` should be committed or git-ignored, writes `.pirr/settings.toml` (the workflow config, plus a deny-by-default `.pirr/.gitignore` for scratch), then provisions the store: the directories `pirr` uses (`docs/specs/`, `docs/adr/`), a `docs/reviewers.md` populated from default + heuristic-detected reviewer agents, and a `CONTEXT.md` skeleton.

## Migrating from the PRD era

Repos set up before the spec rename carry a `docs/prds/` store and `prd-*` branches. To migrate:

1. `git mv docs/prds docs/specs`, and inside each spec directory `git mv <NNN>-<slug>/prd.md <NNN>-<slug>/spec.md` — one commit, history follows.
2. Land or rename live `prd-*` branches — finish them through their normal close-outs, or `git branch -m prd-<NNN>-<slug> spec-<NNN>-<slug>`.
3. Do it between specs, not mid-flight — a clean default-branch checkout with nothing in progress is the safe window.

Mid-transition safety nets: the branch link resolves a legacy `prd-<NNN>-<slug>` branch from a migrated `docs/specs/` directory without renaming it, and every branch sweep scans both `spec-*` and legacy `prd-*` patterns (see [STORE.md](./skills/_shared/STORE.md)) — so an in-flight legacy branch keeps working; renaming it is step 2's choice, not a requirement.

## Migrating from `agentic-flow`

Repos set up before this rename carry a `.agentic-flow/` config directory. The plugin identity, its `pirr:` invocation namespace, and its skills all reload from the freshly installed plugin — nothing to migrate there — but the per-repo config directory is the repo's own and does not move itself:

1. `git mv .agentic-flow .pirr` — it holds `settings.toml` (the workflow config) and a deny-by-default `.gitignore`; both carry over unchanged. If the repo git-ignored the directory instead of committing it, use a plain `mv`.
2. If `.agentic-flow/` was listed in the repo's **root** `.gitignore`, repoint that entry to `.pirr/` (a repo that committed the directory has no such entry — nothing to change).
3. Re-run `/setup` to confirm the store and manifest resolve against `.pirr/`; it is idempotent and rewrites nothing you've customized.

Do it between specs, on a clean default-branch checkout — the same safe window as the PRD migration above.

## The workflow

```
0. /setup                          (once per repo)

1. /next-spec                                   → conversation: what to build next
2. /grill-me                                    → high-level: what are we trying to do
3. /to-spec                                     → writes the spec (Status: Drafting)
4. /grill-me                                    → detail: sharpen; updates the Glossary, may create ADRs
5. /to-tickets                                  → creates tickets, flips spec → Open, marks it active, then:
   (accept the gated bootstrap offer)           → cut the spec branch from the default branch, commit the
                                                  planning artifacts as its first commit

LOOP per ticket:
  6. /next-ticket                               → recommends the next ready ticket and its mode (/tdd or /implement)
  7. /tdd  or  /implement                       → work the ticket in the recommended mode; on clean completion
                                                  (all planned work done + verification green) auto-commits on the
                                                  ticket branch and auto-invokes /done — un-gated exit-tasks;
                                                  otherwise stops and surfaces to you
  8. /done  (auto-invoked on clean completion)  → fact-checks deviations + judges spec conformance, flips status,
                                                  appends retro entry, commits close-out edits (gated), forks:
                                                  refactor pass or merge
  9. /refactor (if chosen)   → per-ticket refactor pass with reviewer subagents
     (accept the gated close-out offer)         → merge ticket branch --no-ff, verify green, delete branch

10. /retro                                      → fact-checks the spec diff, synthesizes the retro, flips spec → Done,
                                                  commits close-out edits (gated), then:
    (accept the gated merge offer)              → merge spec branch --no-ff into the default branch, verify green,
                                                  delete branch
```

## Skills

### Engineering

- **[setup](./skills/engineering/setup/SKILL.md)** — Idempotent per-repo bootstrap and refresh. Provisions the store; populates the Reviewers manifest from default + heuristic-detected reviewer agents.
- **[next-spec](./skills/engineering/next-spec/SKILL.md)** — Exploration of what to work on next. Reads specs, retros, the Glossary, and ADRs; surfaces gaps and priorities as a conversation. Hands off to a high-level `/grill-me`.
- **[grill-me](./skills/engineering/grill-me/SKILL.md)** — Interview the user relentlessly about a plan or design. Updates the Glossary inline and offers ADRs via the three-gate test.
- **[to-spec](./skills/engineering/to-spec/SKILL.md)** — Synthesize the current conversation into a frozen spec (Status: Drafting). Does not interview.
- **[to-tickets](./skills/engineering/to-tickets/SKILL.md)** — Break a spec into dependency-ordered vertical-slice tickets. Flips spec `Drafting → Open` and ends at the gated spec-branch bootstrap — cut from the default branch, planning artifacts committed as its first commit.
- **[next-ticket](./skills/engineering/next-ticket/SKILL.md)** — Recommend the next ready ticket within the current spec. Computes blocked from dependencies.
- **[tdd](./skills/engineering/tdd/SKILL.md)** — Test-driven development with a red-green-refactor loop. Inside a ticket, stops and surfaces the decisions the loop can't safely make, then auto-commits and invokes `/done` on clean-green completion.
- **[implement](./skills/engineering/implement/SKILL.md)** — Plan-then-execute implementation. Builds features or fixes bugs from an approved plan when TDD doesn't fit.
- **[done](./skills/engineering/done/SKILL.md)** — Close the current ticket. Dispatches the deviation-fact-checker and spec-conformance agents against the ticket diff — two reports, separate headings, never merged — flips status, appends a retro entry, commits the close-out edits at one gated offer, then forks: run `/refactor`'s refactor pass, or merge now — one arm recommended from the diff's nature.
- **[refactor](./skills/engineering/refactor/SKILL.md)** — Per-ticket multi-reviewer review-and-improve pass — broader than a rename-level cleanup. Dispatches reviewer agents listed in the Reviewers manifest against the just-closed ticket's diff, merges findings through the deepening framework, captures refactor changes in the ticket's `## Deviations` with a `(refactor)` marker. Every pass ends at the gated close-out (merge offered when a ticket branch is live); outside-spec deferrals bank as Ideas.
- **[retro](./skills/engineering/retro/SKILL.md)** — Synthesize the running retro into the structured spec-close form. Fact-checks the full spec diff, flips spec `Open → Done`, commits the close-out edits at one gated offer, and ends with the gated spec → default-branch merge — re-enterable until it lands.

### Productivity

- **[new](./skills/productivity/new/SKILL.md)** — Distill the current session and project context into a bootstrap prompt for a fresh agent — for handing off mid-flight work to a new conversation without losing momentum.

## Design notes

The canonical vocabulary used by `pirr` itself lives in [`CONTEXT.md`](./CONTEXT.md). A few load-bearing rules to know before modifying skills:

- **Storage mechanics live in the store doc.** Skills name artifacts and operations (a spec's Status, the active spec, the Glossary); [STORE.md](./skills/_shared/STORE.md) maps them to paths and encodings. Encoding details belong in the store doc and format docs, not re-derived in skill prose — a skill states an encoding inline only where the exact bytes matter at its decision point.
- **Frozen artifacts never edit.** Once a spec flips to `Open`, it is immutable. Once it flips to `Done`, the synthesized retro is immutable too. `/to-tickets` creates tickets only on a `Drafting` spec — its one sanctioned `Open`-spec invocation is the bootstrap re-entry (tickets exist, the branch bootstrap didn't land), which adds no scope; mid-flight scope additions are deliberate, manual exceptions. The one sanctioned *content* edit to a frozen artifact is a **meaning-preserving relabel** — a corpus-wide rename (e.g. the plugin's own name) sweeps the new token through closed specs, tickets, retros, and ADRs, same referents throughout; editing what a frozen artifact *decided* or *scoped* stays forbidden.
- **Forward-looking work always lives in a new spec.** No "follow-ups" or "future work" sections on specs or retros — forward-looking lessons motivate the *next* spec.
- **ADRs only when all three gates pass:** hard to reverse, surprising without context, the result of a real trade-off. Strictness keeps ADRs rare and high-signal.
- **Vertical slicing.** Tickets are end-to-end thin slices, not horizontal layers.
- **Lazy creation.** Specs, tickets, retros, ADRs are created by the skills that produce them — not in advance, not by bootstrap. The exception is structural-marker artifacts (the glossary skeleton, the Reviewers manifest, the config), which `/setup` provisions eagerly.
- **Immutable IDs.** Spec numbers and ticket numbers are never renumbered — references in retros, ADRs, and commits would rot. Abandoned work is preserved rather than deleted (moved to `_abandoned/`); numbering includes abandoned work when assigning the next ID. Spec numbering also scans `spec-*` and legacy `prd-*` branch names, local and remote — a spec in flight on its branch keeps its number reserved from any checkout.
- **`(refactor)` marker on deviations.** Seam-level changes from `/refactor` land in the same ticket's `## Deviations` section with a `(refactor)` prefix, so `/retro` can group them into the synthesized retro's optional `## Refactor` section.
- **Behavioral / seam-level / code-shape — three abstraction levels.** Each artifact captures content at one level: specs/tickets/retros are *behavioral* (what changes for a user or caller); deviations and ADRs are *seam-level* (module boundaries, public APIs); inline comments are *code-shape* (why this code is shaped this way, gated on non-obvious WHY). Tickets are written in behavioral voice, not implementation prescription. Deviations capture only behavioral or seam-level divergence — internal renames, formatting, and idiomatic refactors inside a module are below threshold and don't get captured. See [`skills/_shared/ABSTRACTION-LEVELS-PRINCIPLE.md`](./skills/_shared/ABSTRACTION-LEVELS-PRINCIPLE.md).
- **The store is the primary signal.** `pirr:deviation-fact-checker` compares ticket diffs against `## Deviations` from a fresh session — conversation context is bonus, not load-bearing. Skills are designed to work the same way without prior context.
- **Git mutations are gated by the Consent-vs-Ceremony test, not a blanket rule.** A gate is load-bearing *consent* — an offer the user accepts or declines — when its action is hard to reverse, outward-facing, or information-destroying: the merge (the user's control point), the ADR decision, `/done`'s outcome label, the refactor-or-merge fork. It is *ceremony*, and may be automated, when the action is local and reversible and its "no" branch would change nothing — the loop's clean-completion commit and its `/done` invocation. Skills read the merge convention from the config / the repo's CLAUDE.md rather than improvising; an unanswered consent offer blocks — it is never consent. See [ADR 0004](../../docs/adr/0004-confirm-gate-doctrine-scope.md).
- **Announced checkpoints block.** When a skill declares a confirm gate (outcome label, ADR candidates, retro drop-list, plan approval), it presents and ends the turn. "Flag-then-proceed in the same breath" converts a review gate into a notification.
- **`.pirr/` holds durable settings and ephemeral scratch.** `settings.toml` (the workflow config) is durable; diff artifacts for the fact-checker (`diff.patch`) and session handoffs (`handoff.md`) are scratch. Its own deny-by-default `.gitignore` (scaffolded by setup, or by `materialize-diff.sh` when absent) means scratch can never be committed; whether the directory itself is committed or hidden via the root `.gitignore` is the user's per-repo choice, asked once by `/setup`.
- **Candidate inclusion ≠ deviation recording.** The seam-level threshold gates what gets *documented* in `## Deviations`, not what's worth *proposing or doing*. `/refactor` includes worthwhile below-seam cleanups as candidates; it just doesn't record them.
- **External facts are verified before they freeze.** Any load-bearing claim about an external system (stdlib, build APIs, language semantics) is verified against the installed toolchain before it lands in an ADR or determines a reviewer finding's severity.
