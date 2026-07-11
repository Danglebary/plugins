# agentic-flow

A Claude Code plugin: a small, composable set of skills for AI-augmented software development. Built on a four-phase workflow:

```
Plan  →  Implement  →  Refactor / Cleanup  →  Retro
```

Two ideas anchor the system:

- **A single store for planning artifacts** — specs, tickets, retros, the glossary, ADRs, and the reviewer manifest live as **in-repo markdown files**: everything in git, reviewable in PRs; see [STORE.md](./skills/_shared/STORE.md). No external issue tracker. Code, branches, and diffs stay in git alongside.
- **Spec/ticket/retro hierarchy** — a frozen-intent (spec) + living-retro pair captures the durable record of each body of work.

## Setup

In a new repo, run:

```
/setup-agentic-flow
```

This asks whether `.agentic-flow/` should be committed or git-ignored, writes `.agentic-flow/settings.toml` (the workflow config, plus a deny-by-default `.agentic-flow/.gitignore` for scratch), then provisions the store: the directories `agentic-flow` uses (`docs/specs/`, `docs/adr/`), a `docs/reviewers.md` populated from default + heuristic-detected reviewer agents, and a `CONTEXT.md` skeleton.

## Migrating from the PRD era

Repos set up before the spec rename carry a `docs/prds/` store and `prd-*` branches. To migrate:

1. `git mv docs/prds docs/specs`, and inside each spec directory `git mv <NNN>-<slug>/prd.md <NNN>-<slug>/spec.md` — one commit, history follows.
2. Land or rename live `prd-*` branches — finish them through their normal close-outs, or `git branch -m prd-<NNN>-<slug> spec-<NNN>-<slug>`.
3. Do it between specs, not mid-flight — a clean default-branch checkout with nothing in progress is the safe window.

Mid-transition safety nets: the branch link resolves a legacy `prd-<NNN>-<slug>` branch from a migrated `docs/specs/` directory without renaming it, and every branch sweep scans both `spec-*` and legacy `prd-*` patterns (see [STORE.md](./skills/_shared/STORE.md)) — so an in-flight legacy branch keeps working; renaming it is step 2's choice, not a requirement.

## The workflow

```
0. /setup-agentic-flow                          (once per repo)

1. /next-spec                                   → conversation: what to build next
2. /grill-me                                    → high-level: what are we trying to do
3. /to-spec                                     → writes the spec (Status: Drafting)
4. /grill-me                                    → detail: sharpen; updates the Glossary, may create ADRs
5. /to-tickets                                  → creates tickets, flips spec → Open, marks it active, then:
   (accept the gated bootstrap offer)           → cut the spec branch from the default branch, commit the
                                                  planning artifacts as its first commit

LOOP per ticket:
  6. /next-ticket                               → recommends next ready ticket
  7. (work the ticket: /tdd)
  8. /done                                      → fact-checks deviations + judges spec conformance, flips status,
                                                  appends retro entry, commits close-out edits (gated), forks:
                                                  refactor pass or merge
  9. /improve-codebase-architecture (if chosen)   → per-ticket refactor pass with reviewer subagents
     (accept the gated close-out offer)         → merge ticket branch --no-ff, verify green, delete branch

10. /retro                                      → fact-checks the spec diff, synthesizes the retro, flips spec → Done,
                                                  commits close-out edits (gated), then:
    (accept the gated merge offer)              → merge spec branch --no-ff into the default branch, verify green,
                                                  delete branch
```

## Skills

### Engineering

- **[setup-agentic-flow](./skills/engineering/setup-agentic-flow/SKILL.md)** — Idempotent per-repo bootstrap and refresh. Provisions the store; populates the Reviewers manifest from default + heuristic-detected reviewer agents.
- **[next-spec](./skills/engineering/next-spec/SKILL.md)** — Exploration of what to work on next. Reads specs, retros, the Glossary, and ADRs; surfaces gaps and priorities as a conversation. Hands off to a high-level `/grill-me`.
- **[grill-me](./skills/engineering/grill-me/SKILL.md)** — Interview the user relentlessly about a plan or design. Updates the Glossary inline and offers ADRs via the three-gate test.
- **[to-spec](./skills/engineering/to-spec/SKILL.md)** — Synthesize the current conversation into a frozen spec (Status: Drafting). Does not interview.
- **[to-tickets](./skills/engineering/to-tickets/SKILL.md)** — Break a spec into dependency-ordered vertical-slice tickets. Flips spec `Drafting → Open` and ends at the gated spec-branch bootstrap — cut from the default branch, planning artifacts committed as its first commit.
- **[next-ticket](./skills/engineering/next-ticket/SKILL.md)** — Recommend the next ready ticket within the current spec. Computes blocked from dependencies.
- **[tdd](./skills/engineering/tdd/SKILL.md)** — Test-driven development with a red-green-refactor loop. Builds features or fixes bugs one vertical slice at a time.
- **[implement](./skills/engineering/implement/SKILL.md)** — Plan-then-execute implementation. Builds features or fixes bugs from an approved plan when TDD doesn't fit.
- **[done](./skills/engineering/done/SKILL.md)** — Close the current ticket. Dispatches the deviation-fact-checker and spec-conformance agents against the ticket diff — two reports, separate headings, never merged — flips status, appends a retro entry, commits the close-out edits at one gated offer, then forks: run `/improve-codebase-architecture`'s refactor pass, or merge now — one arm recommended from the diff's nature.
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)** — Per-ticket refactor pass. Dispatches reviewer agents listed in the Reviewers manifest against the just-closed ticket's diff, merges findings through the deepening framework, captures refactor changes in the ticket's `## Deviations` with a `(refactor)` marker. Every pass ends at the gated close-out (merge offered when a ticket branch is live); outside-spec deferrals bank as Ideas.
- **[retro](./skills/engineering/retro/SKILL.md)** — Synthesize the running retro into the structured spec-close form. Fact-checks the full spec diff, flips spec `Open → Done`, commits the close-out edits at one gated offer, and ends with the gated spec → default-branch merge — re-enterable until it lands.

### Productivity

- **[new](./skills/productivity/new/SKILL.md)** — Distill the current session and project context into a bootstrap prompt for a fresh agent — for handing off mid-flight work to a new conversation without losing momentum.

## Design notes

The canonical vocabulary used by `agentic-flow` itself lives in [`CONTEXT.md`](./CONTEXT.md). A few load-bearing rules to know before modifying skills:

- **Storage mechanics live in the store doc.** Skills name artifacts and operations (a spec's Status, the active spec, the Glossary); [STORE.md](./skills/_shared/STORE.md) maps them to paths and encodings. Encoding details belong in the store doc and format docs, not re-derived in skill prose — a skill states an encoding inline only where the exact bytes matter at its decision point.
- **Frozen artifacts never edit.** Once a spec flips to `Open`, it is immutable. Once it flips to `Done`, the synthesized retro is immutable too. `/to-tickets` creates tickets only on a `Drafting` spec — its one sanctioned `Open`-spec invocation is the bootstrap re-entry (tickets exist, the branch bootstrap didn't land), which adds no scope; mid-flight scope additions are deliberate, manual exceptions.
- **Forward-looking work always lives in a new spec.** No "follow-ups" or "future work" sections on specs or retros — forward-looking lessons motivate the *next* spec.
- **ADRs only when all three gates pass:** hard to reverse, surprising without context, the result of a real trade-off. Strictness keeps ADRs rare and high-signal.
- **Vertical slicing.** Tickets are end-to-end thin slices, not horizontal layers.
- **Lazy creation.** Specs, tickets, retros, ADRs are created by the skills that produce them — not in advance, not by bootstrap. The exception is structural-marker artifacts (the glossary skeleton, the Reviewers manifest, the config), which `/setup-agentic-flow` provisions eagerly.
- **Immutable IDs.** Spec numbers and ticket numbers are never renumbered — references in retros, ADRs, and commits would rot. Abandoned work is preserved rather than deleted (moved to `_abandoned/`); numbering includes abandoned work when assigning the next ID. Spec numbering also scans `spec-*` and legacy `prd-*` branch names, local and remote — a spec in flight on its branch keeps its number reserved from any checkout.
- **`(refactor)` marker on deviations.** Seam-level changes from `/improve-codebase-architecture` land in the same ticket's `## Deviations` section with a `(refactor)` prefix, so `/retro` can group them into the synthesized retro's optional `## Refactor` section.
- **Behavioral / seam-level / code-shape — three abstraction levels.** Each artifact captures content at one level: specs/tickets/retros are *behavioral* (what changes for a user or caller); deviations and ADRs are *seam-level* (module boundaries, public APIs); inline comments are *code-shape* (why this code is shaped this way, gated on non-obvious WHY). Tickets are written in behavioral voice, not implementation prescription. Deviations capture only behavioral or seam-level divergence — internal renames, formatting, and idiomatic refactors inside a module are below threshold and don't get captured. See [`skills/_shared/ABSTRACTION-LEVELS-PRINCIPLE.md`](./skills/_shared/ABSTRACTION-LEVELS-PRINCIPLE.md).
- **The store is the primary signal.** `agentic-flow:deviation-fact-checker` compares ticket diffs against `## Deviations` from a fresh session — conversation context is bonus, not load-bearing. Skills are designed to work the same way without prior context.
- **Git mutations are offered, never automatic.** Merges, branch deletions, and planning commits are gated offers the user accepts or declines; the merge-back is the user's control point. Skills read the merge convention from the config / the repo's CLAUDE.md rather than improvising. An unanswered offer or ratification question blocks — it is never consent.
- **Announced checkpoints block.** When a skill declares a confirm gate (outcome label, ADR candidates, retro drop-list, plan approval), it presents and ends the turn. "Flag-then-proceed in the same breath" converts a review gate into a notification.
- **`.agentic-flow/` holds durable settings and ephemeral scratch.** `settings.toml` (the workflow config) is durable; diff artifacts for the fact-checker (`diff.patch`) and session handoffs (`handoff.md`) are scratch. Its own deny-by-default `.gitignore` (scaffolded by setup, or by `materialize-diff.sh` when absent) means scratch can never be committed; whether the directory itself is committed or hidden via the root `.gitignore` is the user's per-repo choice, asked once by `/setup-agentic-flow`.
- **Candidate inclusion ≠ deviation recording.** The seam-level threshold gates what gets *documented* in `## Deviations`, not what's worth *proposing or doing*. `/improve-codebase-architecture` includes worthwhile below-seam cleanups as candidates; it just doesn't record them.
- **External facts are verified before they freeze.** Any load-bearing claim about an external system (stdlib, build APIs, language semantics) is verified against the installed toolchain before it lands in an ADR or determines a reviewer finding's severity.
