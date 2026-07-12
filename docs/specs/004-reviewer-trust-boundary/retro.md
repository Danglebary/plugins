# Retro: Reviewer trust boundary

## Ticket 001 — standards-reviewer: a diff-introduced blessing no longer silences a smell

**Outcome**: Exact match

The existing output contract already carried the security flip — Source's `baseline:` arm and the mandatory Judgment-call field both predated this ticket, so hardening the trust boundary needed only a precedence caveat, no new field or louder marker. Phrasing the check against "the diff" rather than the literal `.agentic-flow/diff.patch` path kept `standards-reviewer` off DIFF-MATERIALIZATION.md's "exactly two agents name the artifact" contract — a reminder that bolting a new mechanic onto an agent can quietly introduce cross-doc drift.

## Ticket 002 — /done surfaces contract tampering via a base/head compare script

**Outcome**: Exact match

Putting the "which sections are guarded" policy in the caller (generic `(path, heading)` targets) rather than hardcoding it in the script made the `## Deviations` exemption fall out of the design — the caller simply never names it — instead of needing a special-case guard, and the seam matched what the spec's Approach already implied ("given the guarded section names"). Extract-and-compare over the two `git show <ref>:<path>` versions kept fail-safe heading-drift detection to a trivial exact-heading match and sidestepped the patch-parsing fragility ADR 0005 had already rejected.

## Ticket 003 — spec-conformance judges against the frozen base contract

**Outcome**: Exact match

Closing the spec-conformance half was pure wiring: ticket 002's script already emitted the line-numbered base text, so the work was capturing what was already on stdout and inverting one agent sentence — no new mechanism. The base-for-head swap is behavior-neutral until a diff actually rewrites its own contract, which this very close-out proved — base and head were identical, so judging against base changed nothing. That latency is exactly why the two halves must move in lockstep: the agent body now *expects* a line-numbered base inline, so a brief that fed it plain head text would silently mismatch with no error to catch it.
