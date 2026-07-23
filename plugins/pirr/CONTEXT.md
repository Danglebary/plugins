# pirr

A Claude Code plugin (slash commands and behaviors) supporting a four-phase workflow for AI-augmented software development: Plan → Implement → Refactor / Cleanup → Retro — the four phases whose initials the name **pirr** spells (**P**lan · **I**mplement · **R**efactor · **R**etro). Built on a hierarchy of **Spec** → **Ticket** → **Retro**, with cross-cutting **ADR**s and a living **Glossary** in each consuming repo. Planning artifacts live in the **Store** — markdown files committed to the consuming repo.

## Language

**Store**:
Where planning artifacts (**Spec**s, **Ticket**s, **Retro**s, the **Glossary**, **ADR**s, the Reviewers manifest, config) live: in-repo markdown, provisioned per repo by `/setup`. Skills address store artifacts by path; `skills/_shared/STORE.md` is the contract and artifact map. Code, branches, and diffs stay in git.
_Avoid_: backend (a retired axis — the store once had two), database

**Glossary**:
The living domain vocabulary of a consuming repo: `CONTEXT.md` at the repo root. Grown lazily by `/grill-me`.

**Spec**:
The frozen multi-ticket scope unit. Describes what to build at a level larger than a single **Ticket** but smaller than an epic. Lives at `docs/specs/<NNN>-<slug>/spec.md`. Carries one of `Drafting | Open | Done`; editable while `Drafting`, frozen on **Lock** to `Open`.
_Avoid_: PRD (the pre-rename term — it misdescribed the artifact: a frozen scope document, not a product-requirements doc; survives only in legacy `prd-*` branch names and migration prose), epic, story, design doc, plan doc

**Ticket**:
A single unit of work nested under a **Spec**. A vertical slice of behavior. Lives at `docs/specs/<NNN>-<slug>/tickets/<NNN>-<slug>.md`. Carries one of `Open | In progress | Done`.
_Avoid_: issue (overloaded with GitHub Issues / Linear), task

**Retro**:
A two-pass document paired one-to-one with each **Spec**. The running form is appended to during the spec's lifecycle (one entry per **Ticket** close); the synthesized form is written by `/retro` at spec close, mirroring spec sections with **Outcome label**s.
_Avoid_: post-mortem, results doc, retrospective

**ADR** (Architectural Decision Record):
A cross-**Spec** durable decision (`docs/adr/<NNNN>-<slug>.md`). Created inline during `/grill-me` when all gates of the **Three-gate test** pass.

**Outcome label**:
One of `Exact match | Extended | Divergence | Omitted`. Applied to per-**Ticket** entries in the running **Retro** and to per-section entries in the synthesized **Retro**.

**Plugin-shipped agent**:
A Claude Code subagent shipped by `pirr` at `agents/<name>.md`, namespaced at invocation as `pirr:<name>`. Two classes: **Reviewer agent** and **Workflow agent**. Auto-discovered by the plugin loader.

**Reviewer agent**:
A **Plugin-shipped agent** (or repo-specific subagent at `.claude/agents/<name>.md`) invoked by `/refactor` for refactor candidate-finding. Listed in the Reviewers manifest (`docs/reviewers.md`). Examples: `pirr:qa-engineer`, `pirr:software-architect`, `pirr:security-engineer`.
_Avoid_: linter, expert, sub-agent (when distinguishing role)

**Workflow agent**:
A **Plugin-shipped agent** invoked by a specific skill for a structured analytical task — not user-facing, not a reviewer, not in the Reviewers manifest. Returns output that calling skills depend on by exact shape. Example: `pirr:deviation-fact-checker`, invoked by `/done` and `/retro`.

**Deviation fact-checker**:
The **Workflow agent** (`pirr:deviation-fact-checker`) that compares a ticket diff (or spec-branch diff) against the ticket's `## Deviations` section. Returns three **finding** sections — `Deviation gaps`, `Misrepresented deviations`, `ADR candidates` — each potentially `_None._`, followed by the **Partial verdict** register. Calling skills (`/done`, `/retro`) depend on the finding sections' exact headings; the register is outside that parse contract.

**Claim-making agent**:
An agent whose return asserts findings, verdicts, or absences about material it examined — as opposed to one that only produces an artifact. The gate on the **Partial verdict** register's obligation: both **Reviewer agent**s and **Workflow agent**s qualify, and so does any future agent meeting the test (EVIDENCE-PRINCIPLE.md).
_Avoid_: reading the qualifier as an opt-out — no shipped `pirr` agent is exempt

**Partial verdict**:
A claim-making agent's closing section recording surfaces within its own lens that went unread — unavailable, denied, or simply not consulted — naming each surface and what it would have confirmed. **Contents gap-only, emission mandatory**: it never enumerates what *was* checked, and when there is no gap it emits the sentinel `_Full._`. Silence is off-contract, not a clean result — that asymmetry is what makes the register checkable, and it is why the register is placed ahead of any halt instruction (ADR 0006).
_Avoid_: "coverage report" (the enumerated form this replaced), "checked, clean" (the rejected per-area requirement), "optional register" — silence was the rejected arm

**Empty read**:
A search that returned nothing. Evidence of absence only with a **positive control** — the same search matching something known to be present — and only where absence is the claim being made (a *missing* or *dropped* finding). Without the control it is an unresolved surface disguised as a consulted one, and belongs in the **Partial verdict** register rather than in a finding (ADR 0006).
_Avoid_: treating an empty read as a clean read — the two are distinguishable only by the control

**Resolution preflight**:
A dispatching skill's check, before any lens is dispatched, that every named `subagent_type` resolves against the available agent types — refusing and naming the unresolved ones rather than proceeding. The deterministic half of the coverage claim: an unknown type hard-errors at the tool boundary, so absence is observable *before* the work, never after it. `/refactor` has carried one since its Reviewers-manifest step; `/done` does not, which is where the recorded degradation happened (ADR 0006).
_Avoid_: "dispatch validation" — the check is name resolution only, never output inspection

**Dispatch record**:
The dispatching skill's positive account of which lenses ran — dispatched, returned, refused, or failed to resolve — kept by `/refactor` and `/done`, and **persisted** in the ticket's running-retro entry rather than left in chat. Emission is mandatory, detail gap-only: the clean case is one line. An **attestation**, not a verification — a successful dispatch's return carries no agent identity, and the subagent cannot self-identify either, so nothing downstream can audit it (fired 2026-07-19). Its weight comes from the **Resolution preflight** and the anti-substitution rule beside it, not from its own authority (ADR 0006).
_Avoid_: "third-party observation" — refuted; the skill writing the record is the same executor whose improvisation is the failure mode

**Three-gate test**:
The criteria used to decide whether a decision warrants an **ADR**. All three must hold: (1) hard to reverse, (2) surprising without context, (3) the result of a real trade-off.

**Bucket folder**:
A subdirectory of `skills/` grouping related skills. Currently `engineering/`, `productivity/`, and `_shared/`. The `_shared/` folder holds **Reference doc**s, not skills.

**Reference doc**:
A markdown document under `skills/_shared/` referenced by one or more skills. Four kinds: **Store doc**s (where planning artifacts live — `STORE.md`), **Format doc**s (the canonical shape of a document type), **Principle doc**s (cross-cutting rules applying across multiple skills), and **Convention doc**s (a shared procedure consumed by multiple skills). Format and principle docs are distinguished by filename suffix (`-FORMAT.md` / `-PRINCIPLE.md`); store and convention docs carry no suffix.

**Format doc**:
A **Reference doc** at `skills/_shared/<NAME>-FORMAT.md` that defines the canonical shape of an artifact type (Spec, Ticket, Retro, ADR, Glossary, reviewers) — content shape plus encoding (paths, frontmatter). Referenced by skills that produce or read those artifacts.

**Principle doc**:
A **Reference doc** at `skills/_shared/<NAME>-PRINCIPLE.md` that captures cross-cutting rules applying across multiple skills. Referenced from the SKILL.md files (and other reference docs) that need to enforce or align with the principle.

**Convention doc**:
A **Reference doc** under `skills/_shared/` that defines a shared procedure consumed by multiple skills — some with a plugin-shipped mechanism at their core (`DIFF-MATERIALIZATION.md`, paired with `scripts/materialize-diff.sh`: the invoking skill resolves the inputs, the mechanism owns the deterministic part), some pure procedure (`CLOSE-OUT.md`: consumers bind the variables and cite the mechanics).

**Vertical slice**:
A **Ticket** scope shape: end-to-end behavior across whatever layers it touches (UI → backend → DB), rather than one layer for many features (a horizontal slice). The default for `/to-tickets`.

**Lock** (spec lock):
The transition from `Drafting → Open` on a **Spec**, triggered by `/to-tickets`. After lock, the spec is frozen; further changes require a new **Spec**.

**Deviation**:
A divergence between a **Ticket**'s planned approach and what was actually implemented. Captured in the ticket's `## Deviations` section during impl, surfaced in the **Retro** synthesis pass. A `(refactor)` prefix marks deviations from `/refactor`'s per-ticket pass; the prefix lets `/retro` group refactor work into the synthesized retro's optional `## Refactor` section.

**Active spec pointer**:
The **Store**'s marker for the **Spec** currently being implemented — a one-line text file at `docs/specs/.active` holding the spec directory name, `<NNN>-<slug>` (e.g. `001-add-auth`). Set by `/to-tickets` at spec lock, cleared by `/retro` at spec close *if it still points to the closing spec* (otherwise left alone — a manual repoint is possible but off-workflow, an exception rather than a routine move: ticketing is serialized, and `/to-tickets` refuses while another spec is active or unmerged). Not a substitute for spec `status` — `.active` is "what am I building right now," `status` is "where in its lifecycle is this spec."

**Config**:
The per-repo configuration for `pirr`: `.pirr/settings.toml`, holding workflow config (merge convention). Read as prose — skills consult only the keys they name; stale keys and comments are inert (STORE.md's config read contract). Created by `/setup` with every knob present (commented until chosen); future options append here. Skills update it as configuration choices materialize.

## Relationships

- A **Spec** contains many **Ticket**s
- A **Spec** is paired with exactly one **Retro**
- A **Ticket** contains zero or more **Deviation**s
- An **ADR** is cross-cutting; not nested under any single **Spec**
- A **Reviewer agent** is dispatched by `/refactor`, not by individual **Ticket** work
- A **Workflow agent** is invoked by a specific skill (e.g. `/done`, `/retro`); not via the Reviewers manifest
- A **Partial verdict** is emitted by a **Plugin-shipped agent**; the **Dispatch record** is kept by the skill that dispatched it — neither layer claims what it cannot attest (ADR 0006)
- The **Active spec pointer** identifies the *one* implementation-active **Spec** — serialized ticketing (STORE.md's single-active discipline; `/to-tickets`' preconditions) keeps a second **Spec** from going `Open` while one is active or unmerged

## Flagged ambiguities

- "issue" is avoided because it's overloaded with GitHub Issues / Linear, which `pirr` does not use — collapsed into **Ticket**.
- "epic" is avoided because **Spec** scope is smaller than typical epic scope; the analogy may mislead.
- "phase" was previously used (in the user's prior workflow) to mean both a multi-spec initiative and a single spec-sized body of work — resolved: `pirr` uses **Spec** as the top-level unit; "phase" is no longer used.
- "PRD" named the scope unit through the plugin's first two dogfood rounds — renamed to **Spec** because the artifact is a frozen scope document, not a product-requirements doc. The old name survives only in legacy `prd-*` branch names (resolved via the branch link's legacy fallback in `skills/_shared/STORE.md`) and the migration note.
