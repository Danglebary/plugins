# danglebary/plugins

A Claude Code plugin marketplace. The product here is **prose that another model executes** — skills, agent definitions, and reference docs — plus a few bash scripts the skills shell out to. Treat authoring changes with the care of code changes: a dropped sentence in a contract doc is a behavior change.

## Layout

| Path | What lives there |
|---|---|
| `plugins/<name>/` | One plugin. `plugins/pirr/CLAUDE.md` owns that plugin's internal authoring rules — read it before editing under `plugins/pirr/`. |
| `plugins/pirr/scripts/` | Bash mechanisms the skills invoke, each with a `.bats` suite beside it. |
| `docs/specs/` | The planning store — specs, tickets, retros, banked ideas. `docs/specs/.active` names the spec in flight. |
| `docs/adr/` | Architecture decision records. |
| `.pirr/settings.toml` | Workflow config. Read as prose; nothing parses it. |

## Verification

```
bats plugins/pirr/scripts/
```

That is the whole suite — there is no build step. `.pirr/settings.toml`'s `[verification] command` is the authoritative copy of this; if the two ever disagree, the config wins and this line is stale.

**Assertions in the `.bats` suites go through the helpers in `scripts/test_helpers.bash`, never a bare `[[ ]]`.** On bash 3.2 — the only bash macOS ships — `[[ ]]` does not trip `errexit` in any position, so a non-final `[[ ]]` assertion fails silently and its test still passes. `(( ))` shares the exemption; single-bracket `[ ]` does not. The helper file's header carries the full explanation.

## Conventions

- **Markdown prose: one paragraph = one line.** No mid-sentence hard wraps. Code blocks, tables, and frontmatter are exempt.
- **A recommendation always carries its reasoning and what the alternative costs.** This binds prose the model reads at runtime and prose humans read alike — a bare recommendation invites rubber-stamping instead of an informed accept.
- **Don't restate a contract that lives in another document — cite it.** Inline copies of shared contracts have drifted here before; `plugins/pirr/skills/_shared/` is the home for anything two skills both depend on.
