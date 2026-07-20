---
status: open
depends_on: [002]
---

# Every test assertion can fail

## Goal

On bash 3.2 — the only bash macOS ships, and the one both suites run under — a failing `[[ ]]` inside a function neither trips `errexit` nor fires the ERR trap. A bats test is a function, so only its **final** command decides pass/fail: every earlier `[[ ]]` assertion fails silently. Twenty-six of the sixty-seven `[[ ]]` assertions across `contract-tamper.bats` and `materialize-diff.bats` are inert, including both non-final assertions of the test that pins base-relative line numbering. This ticket makes every assertion in both suites able to fail, and reports honestly on any that turn out to have been passing only because they never ran. Out of scope: adding coverage for behaviors the suites don't already claim to test — this is about making existing claims real, not making new ones.

## Acceptance criteria

- [ ] Every assertion in `contract-tamper.bats` and `materialize-diff.bats` fails its test when the asserted condition is false, regardless of position in the test body.
- [ ] A deliberately falsified assertion in a non-final position is demonstrated to fail the suite, and the demonstration is reverted — the enforcement is shown, not assumed.
- [ ] Any assertion that fails once enforced is reported to the user with its finding — whether the assertion was wrong or the code is — and resolved as its own decision, never silently rewritten to match current behavior.
- [ ] Assertions that compare against fixture text containing glob metacharacters (`[ ]` checkboxes, `*`, `?`) match that text literally.
- [ ] The reason the bare form is unreliable is recorded next to the helpers, so a future contributor doesn't "simplify" them back to `[[ ]]`.
- [ ] Both suites pass in full.

## Implementation notes

Ticket 002 added `assert_output_contains` / `refute_output_contains` to `contract-tamper.bats` and used them for its own tests only; the rest of that file and all of `materialize-diff.bats` still use the bare form. Reuse those helpers rather than introducing a second mechanism — but note they only cover substring checks on `$output`. The pre-existing suite also asserts with interior wildcards (`*"SECTION"*"tkt.md"*"Goal"*`) and on variables other than `$output`, so the helper set will need to grow to cover those shapes; that growth is the ticket, not a deviation from it.

Whether bash 4+/5 shares this behavior is **unverified** — no other bash exists on the development machine. If it does not, suite strictness is silently machine-dependent, which is the same hazard `setup()`'s `GIT_CONFIG_GLOBAL` shielding already guards against, and worth stating wherever the helpers are explained.

The third acceptance criterion is the load-bearing one: an inert assertion that turns out to be false is a real finding about the code under test, and rewriting it to match current behavior would convert this repair into a fresh silent pass.

## Deviations

_None yet._
