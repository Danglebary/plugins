# danglebary-plugins

A Claude Code plugin marketplace repo. Its main plugin, `pirr`, ships a Spec → Ticket → Retro workflow with ADRs, a living Glossary, and refactor-time reviewer agents; planning artifacts live in a per-repo store of in-repo markdown files. This repo dogfoods that workflow on its own development.

## Language

**Personal workflow**:
The workflow pirr itself ships: single-user repos where the plugin performs local merges at close-out gates (ticket branch → spec branch at `/done`'s close-out fork or its deferred `/refactor` pass, spec branch → default branch at `/retro`). pirr's lifecycle skills are single-path — they assume this workflow unconditionally (ADR 0001).
_Avoid_: "solo mode" (a rejected config-axis framing — separation is by plugin, not by setting).

**Work workflow**:
The separate plugin for collaborative, PR-based repos, shipped from its own repo (`work-plugins`): tickets sourced from Jira, an optional Notion PRD linked via a Jira epic, a no-PRD track for assigned tickets, and a close-out that ends in a pull request rather than a merge — the plugin never merges. **Forks** pirr's **Knowledge layer** rather than invoking it — its own ADR 0004 (*fork, don't depend*) settled that, and it ships its own copies of all fifteen agents plus its own `_shared` corpus.
_Avoid_: "team mode" (rejected config-axis framing); "day-job mode".

**Knowledge layer**:
The lifecycle-agnostic subset of pirr that both workflows implement: `/next-spec`, `/grill-me`, `/to-spec`, `/tdd`, the Glossary, ADRs, reviewer agents, and the close-out pair (the deviation fact-checker and spec-conformance agents) — analytical judges that perform no close-out mechanics themselves. A shared *design*, replicated by fork, **not an invoked API surface** — the constraint it carries is that these skills must not *perform* either workflow's close-out mechanics (no merges, no lifecycle gates), and that constraint binds each fork's own copy. Advisory git reads are compatible: the unmerged spec-branch sweep (`spec-*` and legacy `prd-*`) and numbering's branch scan follow the branch-link conventions where present and are inert where they're absent — they warn or reserve, never gate.
_Avoid_: "shared skills" without qualification (ambiguous with `skills/_shared/`, which holds reference docs, not skills).

**Lifecycle layer**:
The workflow-specific skills that move specs and tickets through their states and integrate code: `/to-tickets`, `/next-ticket`, `/done`, `/refactor`, `/retro`. Each plugin ships its own.

**Store backend**:
Where planning artifacts (specs, tickets, retros, Glossary, ADRs) live. Settled 2026-07-09 (PRD 002): `files` (in-repo markdown) is the only backend — the notion backend is removed from pirr, preserved in git history at the pre-removal commit `f83bfbf` (`git show f83bfbf:plugins/pirr/skills/_shared/NOTION-RESOLVER.md`), not as a live file. A storage choice only; carries no workflow semantics.
_Avoid_: "backend" for anything other than artifact storage; "store backend" for the Work workflow's per-artifact sourcing (Jira tickets, Notion specs) — a split the seam never expressed (ADR 0001).

**Consent gate**:
A confirm gate whose action is hard to reverse, outward-facing, or information-destroying — where the user's "no" is load-bearing and must block. The merge, the ADR decision, the `/done` outcome label, and the refactor-or-merge fork are consent gates (ADR 0004). Never automated.
_Avoid_: "confirm gate" as a synonym — that names the mechanism; consent gate names the load-bearing subset.

**Ceremony gate**:
A confirm gate whose action is local, reversible, and whose "no" branch never fires and would change nothing if it did — a prompt that reads as consent but only adds friction. Committing completed work on a ticket branch and invoking `/done` are ceremony gates (ADR 0004); they may be automated, fired on a positive clean-completion signal (all planned work done and verification green). The reversible / outward-facing / information-destroying test sorts a gate into consent vs. ceremony.
_Avoid_: assuming any always-answered-yes gate is ceremony — the test decides, not the answer history alone (a gate can be load-bearing and still usually get a yes).

**Reviewer trust boundary**:
The line past which a reviewer agent must not let the diff under review define the authority it is judged by. A **standards source**, a ticket's **Goal/Acceptance criteria**, or a spec's **Approach** that the reviewed diff modified is *suspect authority*: surfaced or judged against its base (pre-diff) version, never obeyed as post-diff authority (ADR 0005). Hardened in the shared reviewer agents — not deferred to the Work workflow — because that plugin reviews untrusted-author diffs; latent but harmless in the Personal workflow, where the diff author is the trusted user.
Distinct from the **content channel**: instruction-shaped text in the material an agent reviews — comments, docstrings, fixture text — carries no authority over it. Two delivery paths, both covered: hunks inlined into a reviewer's brief, and working-tree content the agent reads itself (the ad-hoc arm ships no diff artifact at all). Every agent refuses to obey it; only the owning lens — security for code, prompt for prompt artifacts — *reports* it, so a single planted line cannot inflate `/refactor`'s convergence count. That rule never demotes repo authority arriving via the brief or read from the base tree; which authority a diff can rewrite remains ADR 0005's line-granular test.
_Avoid_: "untrusted input" — too broad; it collapses the authority channel (ADR 0005) into the content channel, which are hardened separately.

## Relationships

- The **Personal workflow** and the **Work workflow** are separate plugins; each ships its own **Lifecycle layer**.
- Both workflows implement pirr's **Knowledge layer** by **forking** it, never by invoking it (work-plugins' ADR 0004). Fixes do not propagate automatically — each repo pulls by hand, if at all.
- The **Store backend** is orthogonal to which workflow a repo uses.

## Flagged ambiguities

- "day-job vs. personal project" was initially conflated with the notion-vs-files store choice, then briefly modeled as a `settings.toml` workflow-mode axis, and settled as separate plugins (ADR 0001) once grilling showed the divergence spans the whole lifecycle layer — Jira ticket source, no-PRD track, PR-based close-out (2026-07-08).
- "keep the notion resolver for the Work plugin" was weighed as park-the-file vs. delete-with-pinned-history and settled as delete: git history is the archive, and the Work plugin's storage gets a first-principles design rather than inheriting the resolver's shape (2026-07-09, PRD 002).
- "the Work workflow *composes* with the Knowledge layer by invoking its skills" was this Glossary's claim until 2026-07-19, when it was checked against the fork and found false: `work-plugins` ships its own copies of all fifteen agents (13 differing only by a two-line provenance banner) and its own `_shared` corpus, including a second, incompatible evidence contract. The record is corrected above; **reconciling the two doctrines is deferred** — as is deciding whether a Knowledge-layer fix, which is workflow-agnostic by definition, should propagate at all under an ADR that priced only *workflow* divergence.
- "PRD" named pirr's scope unit through its first two dogfood rounds — renamed **Spec** (PRD 002, ticket 002): the artifact is a frozen scope document, not a product-requirements doc. Legacy `prd-*` branches (including this repo's own in-flight ones) stay resolvable via the plugin's branch-link fallback; dated planning history keeps the old wording (2026-07-09).
