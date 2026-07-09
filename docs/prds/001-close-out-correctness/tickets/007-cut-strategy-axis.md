---
status: in-progress
depends_on: []
---

# Cut the branching-strategy config axis

## Goal

The `strategy` config axis no longer exists anywhere: serial is the unconditional, unnamed behavior, `[branching]` holds only the `merge` convention key, and repos carrying the stale key keep working.

## Acceptance criteria

- [ ] Setup's settings template, the store doc's config example and its branching-strategy prose, and the plugin CONTEXT.md's Config entry carry no `strategy` key and no serial/stacked language.
- [ ] `/next-ticket` has no strategy read and no ask-once strategy prompt.
- [ ] The template's consumer comment for the `merge` key names both `/done` and `/retro`.
- [ ] Setup refresh on a repo whose `settings.toml` still contains `strategy = "serial"` succeeds and ignores the key.

## Deviations

- Criterion 4 needed no behavioral change: setup's refresh mode already skips an existing `settings.toml` wholesale, and nothing in the plugin parses TOML programmatically, so a stale `strategy` key was already inert by construction. Satisfied by stating the tolerance in the files re-run step; the repo's own dogfood `settings.toml` deliberately keeps its stale `strategy = "serial"` as the living instance of the tolerated state.
- The template's `merge`-key comment didn't just omit `/retro` — it *misattributed* the second reader as `/next-ticket`, which only routes merges to `/done` and never reads the convention itself. The rewrite corrects the attribution rather than appending.
