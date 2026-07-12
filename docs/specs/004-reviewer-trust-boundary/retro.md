# Retro: Reviewer trust boundary

## Ticket 001 — standards-reviewer: a diff-introduced blessing no longer silences a smell

**Outcome**: Exact match

The existing output contract already carried the security flip — Source's `baseline:` arm and the mandatory Judgment-call field both predated this ticket, so hardening the trust boundary needed only a precedence caveat, no new field or louder marker. Phrasing the check against "the diff" rather than the literal `.agentic-flow/diff.patch` path kept `standards-reviewer` off DIFF-MATERIALIZATION.md's "exactly two agents name the artifact" contract — a reminder that bolting a new mechanic onto an agent can quietly introduce cross-doc drift.
