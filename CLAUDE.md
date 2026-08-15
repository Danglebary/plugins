# danglebary/plugins

A Claude Code plugin marketplace. The product here is **prose that another model executes** — skills, agent definitions, and reference docs — plus a few bash scripts the skills shell out to. Treat authoring changes with the care of code changes: a dropped sentence in a contract doc is a behavior change.

## Layout

| Path | What lives there |
|---|---|
| `plugins/<name>/` | One plugin. `plugins/pirr/CLAUDE.md` owns that plugin's **skill-corpus** authoring rules — bucket layout, `_shared/` naming, README obligations — read it before editing under `plugins/pirr/skills/`. It does not cover `scripts/`. |
| `plugins/pirr/scripts/` | Bash mechanisms the skills invoke, each with a `.bats` suite beside it. Assertion rules live in `plugins/pirr/scripts/test_helpers.bash`'s header (see Verification). |
| `docs/specs/` | Specs, tickets, retros, banked ideas. `docs/specs/.active` names the spec in flight. |
| `docs/adr/` | Architecture decision records. |
| `CONTEXT.md` | The Glossary — the corpus's canonical domain vocabulary. |
| `docs/reviewers.md` | The Reviewers manifest `/refactor` dispatches from. |
| `.pirr/settings.toml` | Workflow config. Read as prose; nothing parses it. |

The **planning store** is not `docs/specs/` alone — its artifact map is defined once in [`plugins/pirr/skills/_shared/STORE.md`](plugins/pirr/skills/_shared/STORE.md) and spans `docs/specs/**`, `docs/adr/**`, `docs/spikes/**`, `docs/reviewers.md`, `CONTEXT.md`, and `.pirr/settings.toml`. Cite that map rather than the table above when classifying a path.

## Verification

```
bats plugins/pirr/scripts/
```

That is the whole suite — there is no build step. Requires [bats-core](https://github.com/bats-core/bats-core) (`brew install bats-core`); developed against 1.13. This line is resolution source 3 of the ladder in [`IMPLEMENTATION-LOOP.md`](plugins/pirr/skills/_shared/IMPLEMENTATION-LOOP.md#resolving-the-repos-verification), which owns the precedence rule — don't restate it here.

**No `.bats` body may assert with `[[ ]]` or `(( ))`, in any position.** Both are exempt from `errexit` on bash 3.2 — the only bash macOS ships — so a non-final one fails silently and its test still passes anyway. Two sanctioned forms, and every assertion is one of them:

- **`$output` substring checks** → the helpers in [`plugins/pirr/scripts/test_helpers.bash`](plugins/pirr/scripts/test_helpers.bash). Pass exactly one expected value, **quoted** — an unquoted argument is glob-expanded at the call site before the helper's literal matching can protect it, and the helpers now refuse the resulting arity rather than silently checking a value nobody wrote.
- **Everything else** — exit status, equality, file predicates → single-bracket `[ ]`, which honors `errexit` in every position and needs no wrapper. `grep -q` likewise.

The helper header carries the mechanism and the one caveat this summary omits; it is the single home, and this is the hot-path pointer to it.

## Conventions

- **Markdown prose: one paragraph = one line.** No mid-sentence hard wraps. Code blocks, tables, and frontmatter are exempt.
- **A recommendation always carries its reasoning and what the alternative costs.** This binds prose the model reads at runtime and prose humans read alike — a bare recommendation invites rubber-stamping instead of an informed accept.
- **Where a contract lives is decided by the placement test, not by a blanket no-copies rule.** Per [ADR 0002](docs/adr/0002-hot-path-classifications-stay-inlined.md) and [`STORE.md`](plugins/pirr/skills/_shared/STORE.md)'s statement of the test: prose consulted mid-step on the hot path **inlines at each decision point, citing its authority**; rarely-entered procedure gets a **single home** that consumers cite. An inline copy made under the first arm is deliberate and forms a sync-set with its authority — not drift. `plugins/pirr/skills/_shared/` is the home for anything two skills both depend on.
