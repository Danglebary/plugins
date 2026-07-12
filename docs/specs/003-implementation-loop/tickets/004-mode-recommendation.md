---
status: done
depends_on: [003]
---

# Mode recommendation

## Goal

At ticket start, `/next-ticket`'s research step assesses and recommends either `/tdd` or `/implement` with its reasoning, and the user ratifies the mode through the plan-approval gate that already exists — no new gate is introduced. Choosing the other mode is expressed by rejecting the plan and asking for it.

## Acceptance criteria

- [ ] `/next-ticket`'s ticket-start research step recommends `/tdd` or `/implement` for the ticket, naming what favors the chosen mode and what the alternative would cost (the recommendation-with-reasoning rule).
- [ ] No new blocking gate and no new config knob is introduced for mode selection; the recommendation is ratified at the existing plan-approval gate.
- [ ] Declining the recommended mode routes to the other mode without a separate gate.

## Implementation notes

Extends the existing ticket-start research sub-agent step, which already assesses whether `/tdd` fits — it now emits a mode recommendation rather than a fit-for-`/tdd` judgment.

## Deviations

- Left the stale `[ticket_start]` comment in `.pirr/settings.toml` ("...assess whether /tdd fits") untouched rather than rewriting it to match the new mode-recommendation wording. It's a deliberately-tolerated stale key (STORE.md config read contract — retired keys are inert; setup no longer ships a `[ticket_start]` block; the retained `strategy` key is the precedent), so editing it would be scope creep into config this ticket doesn't own.
