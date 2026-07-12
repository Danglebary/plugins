---
status: done
---

# Rename to pirr

## Problem

The plugin's name, `agentic-flow`, is generic and low-signal — it describes the category ("an agentic flow") rather than what this workflow is. Two skill names miss for their own reasons: `setup-agentic-flow` carries a redundant plugin suffix (skills are already namespaced, so the fully-qualified name doubles the plugin into it), and `improve-codebase-architecture` is accurately descriptive but verbose where a standard verb would do. The chosen replacement, `pirr`, is a backronym of the plugin's own headline four-phase framing — Plan → Implement → Refactor → Retro — so the name states the mental model instead of the category, and the two skills become `setup` and `refactor`.

The name is not a label on one file; it is baked into every surface a user and a coding agent touches. It is the plugin directory, the invocation namespace (`agentic-flow:<agent>`), the per-repo Config directory (`.agentic-flow/`), the manifest identity, and the product name threaded through the Glossary, the Store contract, every Skill and Reference doc, every Plugin-shipped agent's description, and the frozen Specs, Tickets, Retros, and ADRs that record the plugin's own history. A rename that stops short of any of these leaves the corpus with two names for one concept — which, beyond looking half-finished, degrades future coding-agent work: an agent reading a corpus that calls the same thing `agentic-flow` in the history and `pirr` in the live surface is measurably more likely to hallucinate or hedge across the aliases. The rename is therefore worth doing exhaustively or not at all.

## Goals

- The plugin installs and loads as `pirr`; the marketplace entry and plugin manifest carry the new identity and source path.
- Skills invoke as `pirr:<skill>`; `setup-agentic-flow` is `setup` (`pirr:setup`) and `improve-codebase-architecture` is `refactor` (`pirr:refactor`), with every cross-reference in Skills and Reference docs following.
- Plugin-shipped agents resolve under the `pirr:` namespace; the Reviewers manifest and every agent description that cited `/improve-codebase-architecture` name `/refactor`.
- The Config lives at `.pirr/`, and `/setup` provisions and regenerates it under the new name — the generator template changes too, so a fresh setup run produces no `agentic-flow` residue.
- The diff-materialization mechanism and its bats suite operate on `.pirr/` and pass green — the rename's one behavioral surface is verified by running it, not assumed.
- No tracked file contains `agentic-flow`, `setup-agentic-flow`, or `improve-codebase-architecture`, except where the old token is the explicit subject of a migration note.
- Existing consumer repos have a documented path to migrate `.agentic-flow/` → `.pirr/`, mirroring the shape of the PRD→spec migration note already in the README.

## Non-goals

- Branch naming. Branches are prefixed `spec-*` / legacy `prd-*`, never the plugin name; the rename does not touch them.
- Renumbering any immutable ID. Only product-name tokens change; Spec and Ticket `<NNN>` identifiers are untouched. ADR 0003's filename slug loses its `agentic-flow` component but keeps its number and every by-number cross-reference.
- Re-scoping either renamed skill's behavior. `refactor` keeps the full multi-reviewer `improve-codebase-architecture` prose; only its name and the framing of its one-line listing description change.
- Automatic in-place migration logic inside `/setup` (detecting and moving an existing `.agentic-flow/`). The documented manual path is sufficient at current adoption; auto-migration can be banked as an idea if adoption warrants.
- The untracked scratch tree (`fleet-*`, `diff.patch`). It carries the old name but never enters git, so it is neither renamed nor a source of committed alias drift.

## Approach

**One canonical name, everywhere — frozen artifacts included.** Every tracked occurrence is rewritten, including those in closed Specs, Tickets, Retros, and ADRs. This is a meaning-preserving relabel — same referent, new token — not the renumbering or re-scoping the store's immutability actually forbids, so it sits outside that principle rather than overriding it; a single canonical name across the corpus is chosen over historical-wording fidelity because the alias-hallucination cost falls on every future coding agent that reads the repo. The move is safe for cross-references because ADRs are cited by number, never by filename slug, and the PRD→spec historical narrative uses its own vocabulary — so a pure token swap disturbs neither. Because the README's "Frozen artifacts never edit" design note reads flatly, the sweep adds a one-line clause there marking relabeling as the one sanctioned exception — scope and decision edits stay forbidden — so a future reader who meets the new name in a pre-rename frozen doc finds the rule, not a puzzle.

**The name renders lowercase `pirr`.** The sweep's single target token is lowercase `pirr` — matching the `agentic-flow` precedent and keeping the replacement case-variant-free; a `PIRR` caps form in running prose would reintroduce a second token, the exact drift this spec exists to remove. The backronym is recorded once, in the opening description line of the plugin README and `CONTEXT.md` (Plan · Implement · Refactor · Retro), so the name's meaning is durable without being scattered.

**Most-specific-first replacement order.** `agentic-flow` is a substring of `setup-agentic-flow` and `.agentic-flow`, so the specific tokens are replaced before the bare one — `setup-agentic-flow` → `setup` and `.agentic-flow` → `.pirr` first, then bare `agentic-flow` → `pirr`. `improve-codebase-architecture` → `refactor` is independent (no overlap) and shares no substring with the others. Matching only the full specific tokens also means the common English words "setup" and "refactor" already in the prose are never touched.

**Namespace and directory land atomically.** The plugin-directory rename redefines the invocation namespace, so it and the prose swap `agentic-flow:` → `pirr:` ship together — no intermediate state has `pirr:`-prefixed prose pointing at a still-`agentic-flow`-loaded plugin.

**The Config generator, not just the file.** `/setup` writes the Config; its generator template must emit the `pirr` header and `.pirr/` layout, so a re-run never reintroduces the old name. Editing only the committed `settings.toml` would regress on the next setup.

**The behavioral surface is the diff-materialization mechanism.** The rename's only non-prose edits are the shared script and its bats suite, which hardcode the Config-dir path. The bats suite passing is the acceptance signal for the whole rename — everything else is documentation whose correctness is read, not run.

**Executed as one mechanical ordered sweep, its own spec, off the default branch** — per the plugin's own migration doctrine (renames happen between specs, on a clean checkout, nothing in flight) — and not driven through the very Skills being renamed mid-flight.

## Modules touched

- **Plugin manifest + marketplace manifest** — the plugin `name` and marketplace source path adopt the new identity.
- **The two renamed Skills** — `setup` (was `setup-agentic-flow`) and `refactor` (was `improve-codebase-architecture`), plus every Skill and Reference doc that invokes them; `refactor`'s listing description reframed so the shorter name does not undersell its multi-reviewer scope.
- **Plugin-shipped agents + Reviewers manifest** — the `agentic-flow:` → `pirr:` invocation namespace and every agent description citing `/improve-codebase-architecture`.
- **Config + its generator** — the `.pirr/` directory, `settings.toml`, and the `/setup` skill that writes them.
- **Store contract + diff-materialization Convention doc and mechanism** — the Config-dir path in the store map, the shared script, and its bats suite (the behavioral surface).
- **Glossary (`CONTEXT.md`, root and plugin)** — the canonical vocabulary and product name.
- **README design notes (plugin)** — a one-line relabel-exception clause on the "Frozen artifacts never edit" note.
- **Frozen artifacts** — closed Specs, Tickets, Retros, and the ADRs that name the product; ADR 0003's filename slug.
- **Top-level project surface** — the root README and the historical review doc.
