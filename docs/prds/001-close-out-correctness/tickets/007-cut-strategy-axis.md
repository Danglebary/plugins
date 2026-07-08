---
status: open
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

_None yet._
