# Mechanize the serialize-ticketing preflight

From ticket 005's refactor pass (qa-engineer): `/to-tickets`' serialize-ticketing preconditions are multi-step git preflights run from prose — unmerged-`prd-*` detection over local and remote refs, default-branch resolution, tracked-dirt classification against store-artifact paths. Prose git procedure is the repo's #1 recorded failure axis (the whole-plugin review's procedure-fidelity findings), and the same shape was already mechanized once into `scripts/materialize-diff.sh` + bats on the rationale "a script cannot skip a preflight."

The idea: extract the mechanical core (unmerged-branch detection, clean-checkout classification) into a plugin-shipped script per DIFF-MATERIALIZATION.md's division of labor — the skill resolves store-dependent inputs and routes refusals; the script owns the git-deterministic checks, with bats fixtures for cached vs uncached remote HEAD, a `Done`-but-unmerged branch, tracked store dirt vs implementation dirt, and untracked-only trees. Ticket 006's missing-branch refusal and ticket 008's unmerged-branch warning would be additional consumers.

Deliberate design call, not a drive-by: it changes the preflight's ownership model, and ADR 0002's placement test (hot-path classification vs mechanized procedure) should be applied explicitly.
