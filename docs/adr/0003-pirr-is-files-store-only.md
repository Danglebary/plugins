---
status: accepted
---

# 0003 — pirr is files-store-only; the store seam collapses

## Context

Commit `e21a9dd` deliberately reworked a two-plugin Notion split into a single plugin with a storage-adapter seam, and the two-backend store became the README's first headline idea. Two things have changed since. ADR 0001 moved the only notion consumer — the Work workflow — into a separate future plugin, leaving the notion backend with no user inside pirr. And PRD 001's dogfood round plus a nine-axis adversarial comparison measured what the seam costs to carry: STORE.md's ~2,000 words load on every lifecycle skill regardless of backend, store-neutral phrasing threads every skill, and several of the comparison's verified defects were notion-arm-only (resume idempotency in `/done`, undefined notion ticket numbering, ADR status vocabulary divergence).

One future backend idea exists — an Obsidian-vault store for the Personal workflow (banked at `docs/specs/ideas/obsidian-vault-store.md`) — but it is file-based: markdown on disk, differing in root location and linking conventions, not in kind. It would want a thin path-indirection layer, not this resolver-shaped seam; keeping the notion seam "for Obsidian" would preserve the wrong abstraction.

## Decision

Remove the notion backend and NOTION-RESOLVER.md from pirr. STORE.md collapses to a files-only artifact map, and skills address store artifacts directly rather than through a store-resolution ladder. The resolver is preserved in git history at a pinned pre-removal commit recorded in the work-workflow idea, retrieved deliberately (`git show <hash>:<path>`) when the Work plugin's storage is designed.

## Consequences

- Lifecycle skills shed the resolution ladder and store-neutral phrasing; per-invocation load drops accordingly (PRD 002's measured goal).
- This ADR retires *this* seam, not the idea of alternative storage. A future backend arrives by promoting its banked idea to a spec whose design supersedes this ADR; it pays the full re-threading cost only if it is genuinely non-file-based. The known candidate (Obsidian vault) is expected to need path indirection plus link conventions — a much thinner seam, designed fresh at promotion time rather than inherited from this one.
- Re-adding a notion-class backend (remote database, API-mediated) is full-corpus surgery. Accepted: the only such consumer lives in the Work plugin's scope by ADR 0001.
- `e21a9dd`'s adapter-seam decision is reversed with rationale rather than silently.
- The Work plugin's per-artifact split (Jira tickets, Notion specs) was never expressible by this seam (ADR 0001) and is unaffected.

## Alternatives considered

- **Keep the seam with one live variant.** Rejected: pays a measured per-invocation tax on every skill for a hypothetical, and the one banked candidate wouldn't reuse this seam's shape anyway — a resolver-style abstraction is wrong for a file-based vault.
- **Park NOTION-RESOLVER.md as a live reference doc (in or out of the plugin).** Rejected: an orphaned doc is corpus noise the technical-editor lens exists to flag, and a stale resolver invites inheriting its shape by inertia; git history is the archive, and the pinned pointer makes retrieval deliberate.
- **Defer removal until the Work plugin exists.** Rejected: PRD 002's economy goals are blocked on it, and every intervening edit to lifecycle skills would keep paying the store-neutrality tax.
