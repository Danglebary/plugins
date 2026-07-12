---
status: accepted
---

# 0005 — Shared reviewer agents treat diff-touched authority as suspect

## Context

The plugin-shipped reviewer agents are `tools: [Read, Grep, Glob]` — no git — and discover the authority they defer to from the **working tree**, which at review time equals the diff's **head** (`materialize-diff.sh` refuses on a dirty tree, so the checkout is exactly head). `standards-reviewer`'s precedence rule lets a *documented repo standard silence a baseline smell*; `spec-conformance` judges a diff against a spec source (the ticket's Goal/Acceptance, the spec's Approach) that it reads from the same head tree. In both, the authority and the code under review come from the same post-diff state.

That is a self-authorization hole: one diff can both trip a rule and rewrite the authority that would catch it. A change that adds a 400-line handler *and* appends a `CLAUDE.md` line blessing large handlers reads its own blessing back and stays silent; a ticket branch that rewrites its own Acceptance criteria to match what it built is judged conformant against the rewritten bar. The weakness is latent in the Personal workflow, where the diff author is the trusted user — ticket 005 (spec 001) surfaced it and deliberately **deferred it on YAGNI grounds**, assigning untrusted-author defense to the future Work plugin.

Two facts changed the calculus. The reviewer agents and the `/done` close-out pair are cross-plugin **Knowledge-layer** API (ADR 0001), reused by skill invocation rather than forked. And the Work plugin — PR-based, where the diff author is an untrusted teammate — is now a live second consumer under active development. The weakness is therefore baked into a reused surface just as its riskiest consumer arrives, which is what reopened the deferral.

## Decision

The plugin-shipped reviewer agents and the Personal close-out dispatchers defend the reviewer trust boundary **in this repo**, rather than leaving it to the Work plugin. An authority file a reviewed diff modified is treated as **suspect** — surfaced or judged against its base (pre-diff) version — never obeyed as post-diff authority.

`standards-reviewer` **surfaces** a diff-introduced blessing as a proposal to scrutinize instead of being silenced by it; because its job is to emit findings, surfacing is a complete remedy and lives entirely in its agent body. `spec-conformance` **judges against the base contract**: `/done` inlines the frozen Goal/Acceptance from the spec branch (the base it already resolves) rather than the head version and mechanically surfaces when the diff modified that contract, while the agent's own change is to treat the inlined base copy as authoritative rather than re-grounding its citations against the possibly-rewritten head ticket file; `## Deviations` are exempt, being legitimately diff-authored. Because the toolless agents cannot reach the base tree themselves, the fix necessarily splits across two layers — the agent bodies and the `/done` brief.

## Consequences

- Both close-out paths harden without expanding any reviewer agent's tool surface; the agents stay `Read/Grep/Glob`, and git stays in the dispatcher per DIFF-MATERIALIZATION.md's division of labor.
- The fix spans agent bodies *and* `/done`'s brief. The "diff-touched authority is suspect" principle is stated once; the trigger differs per agent (standards sources for one; Goal/Acceptance/Approach-but-not-Deviations for the other), so the two are conceptual reuse of one rule, not must-stay-verbatim copies.
- The false-positive tension resolves toward surfacing: an honest same-diff convention introduction ("establish X and use it") becomes a one-line confirm rather than either a silent application of stale rules or an unexplained smell.
- The Work plugin inherits a hardened shared surface and need not re-defend the boundary in its own dispatch layer, though it remains free to base-pin its briefs for stronger mechanical guarantees.
- `standards-reviewer`'s remedy leans on the agent correctly recognizing that a discovered standards file is in the diff's changed set. A standards source it fails to recognize as such is a pre-existing discovery gap, not one this decision worsens — but it means the standards-reviewer half is agent-judgment robust, not mechanically robust.
- Risk: for `standards-reviewer`, mechanical base-truth (materialize a base snapshot, discover only from it) would be more robust than agent-noticed suspicion, but it needs base materialization a toolless agent can't do and would silently drop the "the rules changed" signal. Accepted as the right balance for the current threat model; the Work plugin can add base-pinning if it needs the mechanical guarantee.

## Alternatives considered

- **Defer to the Work plugin (ticket 005's YAGNI stance).** Rejected now that the Work plugin is a live second consumer: hardening a cross-plugin surface *before* its riskiest consumer depends on it beats leaving every consumer to re-defend the same boundary, and the shared agents are the natural home for the fix.
- **Base-truth semantics as the primary behavior** — the reviewer reads only the base version and a diff-introduced blessing simply doesn't exist for it. Rejected: it hides the highest-value signal (a change that also changes the rules) and turns honest convention-introducing diffs into unexplained smells. Surface-as-suspect routes that signal to the human instead. (Base semantics remain available underneath — pinning base is compatible with surfacing, not opposed to it.)
- **Give the reviewer agents git access to read the base tree themselves.** Rejected: it puts git prose back inside the agents, contradicting DIFF-MATERIALIZATION.md's "git mechanics live in one deterministic mechanism, never a skill's own git prose," and widens the tool surface of a cross-plugin agent.
- **A uniform agent-only fix for `spec-conformance`** — reconstruct the base criteria from the diff's own removed (`-`) lines. Rejected as fragile: it only works when the criteria fall inside the hunk's context window and leans on exactly the patch-parsing judgment the fix exists to make robust.
