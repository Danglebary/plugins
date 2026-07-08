# agentic-flow — whole-plugin deep-dive review

**Date:** 2026-07-07 · **Tree reviewed:** branch `claude/vibrant-sutherland-8515a8` @ `fae902e` (head of open PR #2 — includes the store seam and notion backend) · **Scope:** all 11 skills, all 10 plugin-shipped agents, all `_shared` docs, plus 9 cross-cutting axes.

**Method:** 21 parallel reviewers (one per skill, one for the agents, nine axis reviewers: DX/ergonomics, confusion vectors, edge cases, prompt/skill design, store-seam symmetry, state-lifecycle coherence, mutation safety, onboarding/first-run, notion spec-only risk), each returning schema-structured findings. Every critical/major finding was then handed to an independent adversarial verifier instructed to refute it against the full doc set. 118 agents ran in total.

**Raw tally:** 219 findings — 2 critical, 95 major, 104 minor, 18 nit. Of the 97 critical/major findings, 87 were adversarially verified: **55 confirmed, 31 downgraded to minor, 1 refuted**. The remaining 10 (all of onboarding-first-run's and notion-spec-risk's, plus one mutation-safety) are **unverified** — their verification agents were lost to a session usage limit, not to refutation.

**Settled ground excluded by design:** the store-seam architecture itself, and the four fae902e fixes (store-neutral reviewer briefs, recovery-vs-bootstrap resolver split, real-default-branch Diff base, Glossary phrasing). Reviewers were instructed not to re-litigate these; verifiers refuted anything that did.

---

## Executive summary

The plugin's core prompt engineering is genuinely strong — blocking gates that state "present and end the turn" at the exact step where LLM eagerness fires, failure-history annotations that anchor every hard rule to a real incident, uniform state-contract blocks, and a parse-safe fact-checker output contract. The workflow's happy path on the files store is coherent and cross-checked in multiple places.

The confirmed defects cluster in four zones, and convergence across independent reviewers was heavy — the same underlying flaws were found 4–10 times from different angles:

1. **The files store's git story breaks at close time.** The "a status flip rides along with the ticket's next real commit" convention has no carrier at ticket close or PRD close — the workflow's own instructions produce a git checkout/merge refusal (reproduced live in a scratch repo by a verifier), and `/retro`'s destructive rewrite can permanently destroy the running retro while asserting it is "preserved in history." Ten findings from seven reviewers.
2. **The notion backend is underspecified exactly where it diverges from files.** No home for the ticket number/slug the whole workflow keys on; no defined heading or edit protocol for the running-retro section that co-resides with the frozen PRD body; a private root page that silently forks a team's store; and a stack of untested tool-contract assumptions ("the CREATE TABLE framing is literal") that could wedge setup with no recovery. Roughly 25 findings across 10 reviewers.
3. **Stacked branching mode cannot work as written.** `/done`'s unconditional merge-and-delete close-out destroys the branch that stacked cutting and stacked diffing both require; the stacked merge target is never defined; the serial-vs-stacked prompt is dead code. Six findings from six reviewers.
4. **Cross-skill contract drift.** A YAML foot-gun truncates two skills' frontmatter descriptions in the live skill registry (empirically verified); the reviewer dispatch brief demands output its own agents' contracts forbid; the `(refactor)` marker has one definition in five docs and a contradicting sixth; abandonment and idea-promotion are transitions no skill owns.

One finding was refuted outright (to-prd fabrication risk — the guard already exists at `to-prd/SKILL.md:80`), and 31 more survived only in weakened form — the verification pass was worth running.

---

## Verdict key

- **CONFIRMED** — an adversarial verifier read the cited text plus everything that could reconcile it and the finding held.
- **weakened → minor** — a real kernel, but the severity claim failed (usually because an explicit rule elsewhere blocks the feared outcome).
- **UNVERIFIED** — no verifier ran (session limit); treat as plausible-but-unaudited.
- Convergence counts (\"×N\") tally independent reviewers that flagged the same underlying issue.

---

## Tier 1 — the load-bearing defects

### 1. Files-store close-time edits have no commit vehicle — CONFIRMED ×7 reviewers (10 findings)

**Locations:** `done/SKILL.md:72-79`, `retro/SKILL.md:56-60`, `_shared/STORE.md:90`, `to-prd/SKILL.md:23`

`STORE.md:90` says a status flip is "never its own commit — it rides along with the ticket's next real commit." That works for the Open→In-progress flip (`/next-ticket`), and never again. At ticket close, `/done` steps 5/8/9 produce three working-tree edits (deviations materialized, retro entry appended, status flipped Done) with no next real commit — and step 11's close-out then runs `git checkout <parent>` and `git merge --no-ff`, both of which **refuse** when the ticket file differs between branches with uncommitted local changes. A verifier reproduced the exact wedge in a scratch repo: the standard accept-path fails as written, and the executor's only moves (stash, ungated commit) are ones the plugin's own rules forbid.

At PRD close it gets worse: `/retro`'s in-place rewrite (step 10) destroys the per-ticket running entries while asserting "the running form is preserved in history (git or Notion page history)" — but nothing in the workflow ever commits `retro.md`, so in the normal flow there is no history. `RETRO-FORMAT.md:99`'s own anti-pattern ("don't drop the running form without git committing it") has no enforcing step anywhere. And after `/retro` finishes, the synthesized retro, the Done flip, and the deleted `.active` sit uncommitted on an unmerged PRD branch — no skill anywhere owns the PRD→main merge, even though setup's `settings.toml` comment names it as a convention. A teammate on the default branch still sees the PRD as Open with a live pointer. Related confirmed leak: spikes and ideas written by `/to-prd` have **no** commit path at all (they never pass through `/to-tickets`' planning-commit offer), so "banked" ideas are untracked files lost on a fresh clone (`to-prd #4`).

**Fix direction:** extend the gated close-out offers to include the planning commit — `/done` step 11: "commit the close-out store edits on the ticket branch, then merge"; `/retro`: gated planning commit of the synthesized retro + flip + pointer removal, then a gated PRD→default-branch merge offer per the configured convention; `/retro` step 10 gains a precondition — refuse to rewrite until the running form is committed. Add a gated commit offer after `/to-prd` writes a spike/idea. Amend `STORE.md:90` to state that end-of-lifecycle flips are committed as part of close-out. The three copies of the close-out recipe (`done` step 11, `next-ticket` reachability recovery, `retro` step 3) must all change together.

### 2. Notion running retro: an undefined section inside a frozen page — CONFIRMED ×6, weakened ×3 (9 findings from 9 reviewers)

**Locations:** `done/SKILL.md:60`, `retro/SKILL.md:56`, `_shared/RETRO-FORMAT.md:5`, `_shared/NOTION-RESOLVER.md` (no retro mention at all)

In the notion store the running retro lives "as a section in the PRD row body" — the same page body holding the five frozen PRD sections that `/retro` later locates by byte-identical headings. But no document defines the retro section's heading, position, or boundary. `/done` must "create the section if absent" with no name to create it under; `/retro` must rewrite "the retro section" with no way to know where it ends. The pointer chain is dead: `RETRO-FORMAT.md` defers to `NOTION-RESOLVER.md`, which never mentions the retro. Fresh sessions will improvise different headings ("## Retro" vs "## Running retro"), fragmenting the retro across sessions; the synthesized form's headings ("## Problem — Exact match") prefix-collide with the PRD's own "## Problem"; and no doc mandates block-scoped edits over whole-body replacement, so a `notion-update-page` call in replace mode clobbers the frozen PRD — the single most dangerous write in a backend that has never been run live (`retro #1`, confirmed). The "this contradicts the frozen-PRD rule" framing was weakened (the docs do treat PRD and retro as distinct co-resident artifacts), but the operational gap — no heading, no boundary, no edit protocol, no post-edit verification — was confirmed repeatedly.

**Fix direction:** pick one literal heading (e.g. `# Retro`, always the last section of the body; everything under it is retro content), define it once in `RETRO-FORMAT.md` + `NOTION-RESOLVER.md`, and have `/done` step 8 and `/retro` step 10 cite it verbatim. Mandate: edit only blocks at/below that heading, never replace the full body; after writing, re-fetch and confirm the five PRD headings survived. State the freeze-scope explicitly (five sections frozen; retro section is the sanctioned mutable region). Require exact-match, not prefix-match, heading lookup.

### 3. The notion Tickets schema cannot carry the ticket number or slug — CONFIRMED ×3, unverified ×1 (4 findings)

**Locations:** `_shared/NOTION-RESOLVER.md:69-80`, `_shared/STORE.md:60`, `to-tickets/SKILL.md:38`

The Tickets schema has only Name, Status, PRD relation, Depends-on, and a **database-global** `Ticket ID` (`UNIQUE_ID PREFIX 'TKT'`). Nothing holds the PRD-scoped `001`-based number or the slug — yet `STORE.md:60` promises a "highest ticket number among rows related to the PRD" query (no column to MAX over), `/next-ticket` builds branch names `prd-<NNN>/ticket-<NNN>-<slug>`, `/done` writes retro headings `## Ticket NNN`, and `/retro` references tickets by number. The resolver even explains why `UNIQUE_ID` can't serve as a skill-assigned number for PRDs (`NOTION-RESOLVER.md:65`) — making the identical gap on Tickets conspicuous. Fresh sessions must each invent an encoding, and divergent guesses silently break branch naming and retro correlation.

**Fix direction:** add `Number` (plain NUMBER) and `Slug` (RICH_TEXT) properties to the Tickets schema — or mandate a literal `NNN-slug` Name convention mirroring the files-store filename — have `/to-tickets` step 7 write them, and point `STORE.md:60`'s numbering row at the exact property. Give `Ticket ID` a documented purpose or drop it.

### 4. Stacked branching mode is internally incoherent — CONFIRMED ×4, weakened ×2 (6 findings from 6 reviewers)

**Locations:** `next-ticket/SKILL.md:54,57`, `done/SKILL.md:25-26,76-79`, `setup-agentic-flow/SKILL.md:155-161`

Three confirmed contradictions: (a) `/done`'s close-out offer is unconditional in both strategies and deletes the ticket branch after merge, but stacked mode cuts the next ticket from "the previous ticket's branch" and computes the next diff against it — accepting the offer (the README's illustrated normal path) destroys both; (b) the stacked merge *target* is never defined — `/done`'s "merge the ticket branch back… green on the parent" resolves via its own step 2 to the previous ticket's branch, meaning ticket N merges into ticket N−1's possibly-deleted branch and the PRD branch accumulates nothing all PRD long; (c) "previous ticket" itself parses two ways (by number vs most-recently-Done), so cut-time and diff-time can reconstruct different parents. Adjacent confirmed dead code: setup's template always writes `strategy = "serial"` uncommented, so `/next-ticket`'s ask-once prompt ("if the config doesn't have the strategy set yet") can never fire, while setup's own template comment promises that prompt.

**Fix direction:** decide whether stacked mode is real. If yes: make the close-out offer strategy-aware (stacked → defer per-ticket merges to PRD close, or keep branches alive until the stack lands), define the merge target and "previous ticket" deterministically, and give the deleted-branch fallback (the `--no-ff` merge commit, findable by branch name). If no: cut the option from the template. Either way, reconcile the template/prompt contradiction — probably by shipping `strategy` commented out.

### 5. YAML frontmatter truncation breaks two skills' registered descriptions — CONFIRMED, empirically (×2 reviewers)

**Locations:** `done/SKILL.md:3`, `improve-codebase-architecture/SKILL.md:3`

Both descriptions contain an unquoted ` ## Deviations` — and in a YAML plain scalar, space-then-`#` starts a comment. The registered descriptions truncate mid-sentence ("…compare the ticket diff against" / "…captured in the ticket's"), dropping the auto-invocation trigger phrases ("Use when finishing a ticket" / "Use after /done"). Verified three ways: raw parse, an independent YAML parser, and the live Claude Code skill registry in the verifier's own session showing exactly the predicted truncation.

**Fix direction:** quote the two description strings (or rewrite `## Deviations` as "the ticket's Deviations section"). Audit all skills/agents for space-hash in unquoted frontmatter. Five-minute fix; do it first.

### 6. The notion root page is private — a team's store silently forks — CONFIRMED ×1 + UNVERIFIED critical ×1

**Locations:** `setup-agentic-flow/SKILL.md:26-27,85`, `_shared/NOTION-RESOLVER.md:11`

The root `Agentic-Flow` page is created as a workspace-level **private** page, and no document ever says to share it. In a shared repo where teammates all use the workflow: the committed `settings.toml` hands them a `root_page_id` their Notion account cannot fetch (unauthorized presents as not-found), their recovery search finds nothing (the page is private to someone else), and setup's bootstrap — finding zero results — creates a second private root. Each teammate ends up with a disjoint planning store while believing they share one, plus `settings.toml` churning in git with conflicting ids. Setup's two questions have no arm for "shared repo where others *do* use this" combined with notion. The skill-reviewer's version was confirmed; the onboarding axis rated the same mechanism critical (unverified, but the mechanism is the confirmed one).

**Fix direction:** after creating the root, instruct the user to share it with teammates who will use the workflow, and state that until shared the store is single-user. Make the recovery/bootstrap zero-results branch warn — "a committed id you cannot fetch may be another user's private root; proceeding creates a second, divergent store" — and require explicit confirmation before creating.

### 7. The notion backend's tool contracts are load-bearing and untested — UNVERIFIED (critical + 2 major), corroborated by confirmed setup findings

**Locations:** `_shared/NOTION-RESOLVER.md:29,33,48,70-80`, `setup-agentic-flow/SKILL.md:85`

The whole backend routes through two never-executed contracts: `notion-query-data-sources` accepting SQL, and `notion-create-database` accepting the literal `CREATE TABLE` dialect (`SELECT('x':color)`, `COMMENT`, `UNIQUE_ID PREFIX`, `RELATION/DUAL`). The doc's "this framing is literal" actively suppresses the executor's natural recovery move (adapting to the tool's real schema), so drift wedges setup or the first query-dependent skill. Additional stacked assumptions: parentless `notion-create-pages` creating a workspace-level page (the public API has always required a parent); `notion-fetch` exposing `data_source_id`s via `<data-source url="collection://…">` tags; surgical body edits via `notion-update-page`. The axis also confirmed-by-argument that the "no never-rename-the-root constraint" claim is overstated — child databases are matched by exact title with no missing-child handling, so renaming `Tickets` routes the user into setup's "create only what's missing" and a duplicate database.

**Fix direction (cheap and singular):** one ~15-minute live smoke test in a scratch workspace before anyone uses this backend — list actual tool names/schemas, create a root + one database exercising every property type used, run one max-Number and one `Active = true` query, try a parentless page create, try a body-scoped update, delete. Then stamp the resolver "verified against mcp.notion.com <date>" or amend it. The axis ranked the assumptions; items 1–5 of its list are all covered by that one session. Also: state that the five database titles (and root title, for gitignored repos) are load-bearing; add a missing-child branch to resolution.

---

## Tier 2 — confirmed, narrower or cheaper

### 8. Reviewer dispatch seam: diff delivery unspecified; brief contradicts agent contracts — CONFIRMED ×3 (+1 weakened)

`improve-codebase-architecture/SKILL.md:42-50` vs all nine `agents/*.md`. (a) The nine reviewers have `[Read, Grep, Glob]` — no git — and every body says only "Read the diff," while the dispatching skill produces only a diff *range* and never materializes an artifact; the plugin's own convention (`.agentic-flow/diff.patch`, "the fact-checker's only view of a diff") exists precisely for this and isn't applied here. Reviewers either review the whole tree or Glob up a **stale** `diff.patch` from an earlier `/done`. (b) The brief demands per-area "checked, clean" lines, but every agent's output contract ends "output `_No <lens> candidates._` **and stop**" — nine subagents receive contradictory instructions and the merge layer can't distinguish clean from not-looked, the exact gap the requirement exists to close. (c, weakened) The brief's "verify external-system claims against the installed toolchain" is impossible without execution tools. **Fix:** materialize the diff to `diff.patch` in step 3 and pass the path in every brief; pick one side of the checked-clean contract and change all nine agents plus the brief together; move toolchain verification to the merge layer, which has Bash.

### 9. Abandonment is a transition no skill owns — CONFIRMED ×2 (+4 weakened)

`done/SKILL.md:56`, `_shared/STORE.md:64`, `retro/SKILL.md:18 vs 24`, `TICKET-FORMAT.md:34`. `/done` steers users toward abandoning ("prefer abandoning the ticket per the store rather than running /done"), but `/done` is the sole producer of running-retro entries — so `RETRO-FORMAT`'s Omitted label ("note where the work went") has **no producer** on the recommended path, and if `/done` is run anyway, step 9 flips the abandoned ticket to Done, misrepresenting history. Confirmed store asymmetry compounds it: `/retro`'s state contract says "refuses if any ticket isn't Done" while step 2 refuses only on "Open or In progress" — for a notion `Status = Abandoned` row those disagree (files-store `_abandoned/` moves are structurally invisible, notion rows are not). Weakened-but-real satellites: no confirm gate, no `git mv` guidance, dangling `depends_on` at abandoned tickets permanently blocking dependents, active pointer left on an abandoned PRD. **Fix:** specify the Omitted path end-to-end in `/done` (append the retro entry noting where the work went, perform the store abandon instead of the Done flip, skip the merge offer), align `/retro`'s two phrasings, state that reads exclude abandoned tickets except for numbering, and give `/next-ticket` a rule for dependencies on Abandoned tickets.

### 10. `/done` contradicts itself on the deviations sentinel — CONFIRMED ×3

`done/SKILL.md:90` ("leave the section empty (or at `_None yet._`)") vs step 5 at line 46, which mandates materializing `_None._` at close and declares the `_None._`-vs-`_None yet._` distinction load-bearing. Anti-patterns sit last, where LLMs weight recency. Related confirmed dangler: line 46 claims "/retro relies on the distinction" but `/retro` never reads it — one side of that contract needs writing down. **Fix:** reword line 90 ("the section reads `_None._` — never invent entries"); either make `/retro` actually use the distinction or drop the claim.

### 11. Diff semantics are ambiguous everywhere they matter — CONFIRMED ×3

(a) `retro/SKILL.md:26-28`: "the PRD branch vs the diff base" never pins two-dot vs merge-base semantics — on a long-lived PRD branch, literal `git diff main <branch>` includes inverse hunks of all mainline drift, feeding the fact-checker spurious deviation gaps that step 5 then writes into tickets (confirmed; same ambiguity in `/done` and `/improve`). (b) `confusion-vectors`: the PRD-branch base is stated three different ways — `/to-tickets` resolves the real default branch and records notion `Diff base`; `/next-ticket`'s lazy PRD-branch creation cuts "from `main` (or repo's default)" and never reads Diff base; `/retro` says "vs `main` (or repo default)" — so the cut point and the final diff base can disagree (confirmed). (c) `done/SKILL.md:24`: step 2 has no preflight at all — no branch check, no dirty-tree check, no empty-diff check; an empty `diff.patch` yields a vacuous `_None._` fact-check recorded as "checked, clean" (confirmed). **Fix:** one shared diff-materialization convention (in `STORE.md` or a small shared doc): merge-base three-dot semantics, base = recorded Diff base (notion) / resolved default (files), preflight (right branch, clean tree, non-empty patch) — cited by `/done`, `/retro`, `/improve`, and `/next-ticket`'s branch cut.

### 12. Interrupted multi-step writes re-run as duplication — CONFIRMED ×2 (+3 weakened)

`to-tickets/SKILL.md:22,34-38` (confirmed twice): a crash between step 7 (tickets written) and step 9 (PRD flip) leaves a Drafting PRD with tickets; on re-run the only guard ("status is Drafting") passes, and step 5's numbering rule explicitly continues past the orphans — producing a full duplicate ticket set under immutable numbers. Same shape confirmed in setup's notion path (see Tier 1 #7 corroboration): the two-step Tickets creation crash window leaves a database without its `Depends on` relation, which re-run's existence-only check declares healthy forever (`setup #0` + `edge-cases #6`, both confirmed). Weakened satellites: `/done` re-run appends a duplicate retro entry; `/retro` crash between rewrite and flip re-synthesizes from a consumed document. **Fix:** re-entry checks — `/to-tickets` step 1: "Drafting PRD with existing tickets = interrupted run → reconcile, don't re-propose"; setup notion re-run: verify schema (relations present), not just existence; `/done` step 8: check for an existing `## Ticket NNN` entry; `/retro` step 1: an Open PRD whose retro is already synthesized = interrupted close → skip to the flip.

### 13. `/tdd` is the least-integrated skill — CONFIRMED ×3 (+2 weakened)

(a) `tdd/SKILL.md:97-99`: the entire agentic-flow integration hangs on "If TDD runs inside an in-progress ticket" with **no detection procedure** — a fresh session never realizes it's in a ticket, so the Deviations duty silently drops and the behavior list is invented instead of seeded from Acceptance criteria (confirmed). (b) `tdd/SKILL.md:35`: reads "the project's domain glossary" and ADRs without ever resolving the store — in a notion repo both reads silently no-op; tdd is the only store-reading skill without the resolve-the-store opener (confirmed). (c) `tdd/refactoring.md:18`: instructs TDD-phase seam moves to carry the `(refactor)` prefix, which five canonical docs define as provenance from `/improve-codebase-architecture` specifically — corrupting the marker `/retro`'s Refactor synthesis keys on (confirmed). Weakened: mid-loop plan invalidation re-gating; redundant re-interviewing of content the ticket already records. **Fix:** add a step 0 (resolve store if set up → active PRD → In-progress ticket → seed the plan from Goal/Acceptance/Implementation notes; else run standalone); drop the prefix from `refactoring.md` (or broaden the canonical definition in all five docs — pick one); align tdd's support-doc vocabulary (Ousterhout ratio framing) with LANGUAGE.md's rejected-framings list.

### 14. `/grill-me` gaps — CONFIRMED ×3 (+1 weakened, +1 unverified)

(a) The detail-stage grill never instructs editing the drafting PRD — inline-update discipline exists for the Glossary and ADRs but not the third artifact the grill exists to sharpen; resolutions live only in chat, a later `/to-tickets` session reads the stale draft, and the PRD locks with the grill's answers lost. `PRD-FORMAT.md:28` grants the edit right, but grill-me never references that doc (confirmed). (b) ADR minting: line 75 says *offer* (a README-listed confirm gate) but line 77's "Mint ADRs inline as decisions land — don't defer" and the self-check's "mint it now" read as write-without-asking, and ADRs are written directly in `accepted` status (confirmed). (c) The notion Glossary mapping cannot carry the format's content: `_Avoid_` lines (called "critical"), cross-term relationship ownership, flagged ambiguities, and the header have no defined home in a Term/Definition/Relationships row (confirmed; two more reviewers hit it as minors). Weakened: no target-resolution step (real gap, low blast radius). Unverified but thrice-flagged: the unconditional "resolve the store first" + STORE.md's hard stop collides with grill-me's advertised store-free generic use. **Fix:** add an "update the PRD inline" subsection mirroring the Glossary one; state the offer→accept→mint sequence once; extend `CONTEXT-FORMAT.md`'s notion section with an explicit mapping; scope store resolution to when a PRD/Glossary/ADR is actually involved.

### 15. Idea and spike promotion: two conflicting specs, no owner — CONFIRMED ×2

`_shared/NOTION-RESOLVER.md:67` says promote in place (flip Kind → PRD, assign Number, Status = Drafting); `/to-prd` — the only PRD-creating skill — always creates a new artifact and never touches the source idea; the files store has no promotion mechanics at all (nothing consumes `docs/prds/ideas/`). `/next-prd` actively proposes promotion and hands off to `/to-prd`, so this is a live gap in the recommended flow, not hypothetical. Following the resolver yields a PRD row whose body is a parked paragraph instead of the five sections `/retro` depends on; following `/to-prd` leaves a stale Idea resurfacing forever. **Fix:** make `/to-prd` own promotion explicitly (files: create the PRD, delete/move the ideas file; notion: flip the existing row and rewrite its body to the five sections — or create new and archive the Idea), align the resolver, and state that spikes are never converted (the spike stays; a new PRD references it).

### 16. `/improve-codebase-architecture` drops hand-offs — CONFIRMED ×2 (+2 weakened)

(a) The no-candidates/none-accepted early exit ("report that and offer to skip") never routes to step 9's close-out merge offer — but `/done` explicitly deferred the merge to this pass, so a no-op pass strands the ticket branch with no skill owning the merge (confirmed). (b) Deferrals outside the current PRD's tickets ("good idea, not this PRD") have no store home — the locked PRD can't gain tickets and the skill never mentions the Idea vehicle, so the deferral evaporates and reviewers re-propose it indefinitely (confirmed). **Fix:** make the close-out offer explicitly unconditional ("even a no-op pass ends with the merge offer"); add a second deferral arm banking outside-PRD deferrals as Ideas, and include idea-banked deferrals in step 4's brief input.

### 17. Remaining confirmed singles

- **`/next-prd` contradicts the canonical chain** (`next-prd/SKILL.md:8,35,44`): hands off directly to `/to-prd` in three places, while README workflow step 2 and grill-me's own Two-stages section put a high-level `/grill-me` between them. An executor will skip the sharpening pass; `/to-prd` explicitly doesn't interview, so the draft builds from a deliberately shallow conversation. Pick the canonical chain and align all three sites.
- **`.active` content is ambiguous — "slug" is overloaded** (`CONTEXT.md:70` vs `to-prd` step 2; confirmed + 4 minor echoes): the pointer docs say `.active` holds "the PRD slug" with example `001-add-auth` (the *directory name*), while slug canonically means the bare topic (`add-auth`). A writer/reader mismatch breaks active-PRD resolution. Rename the pointer content to "the PRD directory name (`<NNN>-<slug>`)" everywhere.
- **`/to-tickets` validates acyclicity before the gate, not after** (`to-tickets/SKILL.md:32`): user revisions at the confirmation gate are written unvalidated — the one path where a cycle plausibly enters — and `TICKET-FORMAT.md:30` promises write-time refusal the ordering doesn't deliver. Re-validate the confirmed graph immediately before writing.
- **Files-store ticket statuses are checkout-dependent** (`next-ticket/SKILL.md:28`): statuses ride commits on ticket branches, and no skill says which ref to read from — a done-flip sitting on an unmerged ticket branch makes `/next-ticket` compute wrong readiness with no hint the cause is an unmerged branch. Notion has no such problem; state the read ref and add the unmerged-flip check to the triage.
- **`/new`'s gitignore safety claim is conditional on setup having run** (`new/SKILL.md:35`; confirmed + 4 minor echoes across `/done` and STORE.md recovery): "its deny-by-default .gitignore keeps scratch uncommitted" — but only setup scaffolds that file; `/new` and `/done` create the bare directory and assert protection that isn't there. One `git add -A` commits the handoff. Make every create-the-directory site scaffold the four-line gitignore if absent.
- **Setup's circular recovery** (`setup-agentic-flow/SKILL.md:96`): notion re-run with a dead/missing `root_page_id` and a fruitless search terminates in the resolver's "re-run /setup-agentic-flow. Stop." — self-referential *inside* setup — with no fall-through to first-run root creation. Add the explicit branch (offer to create a fresh root, overwrite the cached id on confirm) and a preflight that verifies the notion tools are loadable before writing `backend = "notion"` (the unverified onboarding finding independently flagged the same preflight gap).

---

## Downgraded by verification (31 findings, now minor)

The adversarial pass killed the severity — not the kernel — of these. Recurring reasons: an explicit rule elsewhere in the executor's scope blocks the feared outcome; the state is recoverable by an existing downstream guard; or the finding misread which artifact a term referred to. Notable ones (full list implicit in the appendix):

- Active-pointer read-side anomalies (multiple `Active = true` rows, pointer at a Drafting/Abandoned PRD, `/next-ticket` not repointing on user-specified PRD) — four reviewers, all weakened individually, but the *convergence* says the read-side rule is genuinely missing from `STORE.md`'s single-active section; a one-paragraph fix covers all of them.
- `/retro`'s silent PRD-retarget fallback (real, but the only pre-gate write is bounded and the drop-list gate reveals the identity before anything destructive).
- `/to-prd` re-run duplicating a PRD under a fresh number (real gap, cheap recovery via abandonment).
- `/improve` and `/done` interrupted-run duplicate appends (recoverable; see Tier 2 #12 for the confirmed siblings).
- tdd mid-loop plan invalidation; `/tdd` re-interviewing content the ticket records; `/improve`'s missing identify-the-ticket step (the ticket branch checkout anchors the designed flow).
- "close commit" terminology in `/next-ticket` (the close-out *merge* commit exists; the term just needs pinning).
- Fact-checker PRD-scope attribution (`plugin-agents` + `retro`, both weakened): the agent body is written single-ticket and its output has no ticket-attribution field while `/retro` step 5 needs per-ticket routing — verifiers rated the blast radius minor, but both flagged the same seam; a short "PRD scope" subsection in the agent body closes it.

## Refuted (1)

- `to-prd #2` (fabrication risk when the conversation is thin): the guard already exists in the cited file — `to-prd/SKILL.md:80` "If the conversation hasn't covered something the PRD needs, leave it out — /grill-me will surface the gap."

## Unverified (10)

All of `onboarding-first-run` (4) and `notion-spec-risk` (5), plus `mutation-safety #1` (retro terminal mutations — its content is subsumed by the confirmed Tier 1 #1 cluster). The onboarding and notion findings are woven into Tiers 1–2 above where confirmed findings corroborate them (private root, MCP preflight, tool contracts, rename tolerance); treat the rest with one grain of salt: the commit-vs-ignore question misleading files-store users about repo footprint (`onboarding #3`), and grill-me's store hard-stop on first run (`onboarding #2`, echoed by two other reviewers as minors).

---

## Minor and nit findings (122, deduplicated highlights)

Recurring themes already covered above: slug/.active ambiguity (4 echoes), scratch-gitignore-not-scaffolded (4), serial/stacked dead prompt (3), notion Glossary mapping gaps (2), duplicate retro entry on re-run (2), `/retro` fact-checker brief drifting from `/done`'s (2), Idea promotion (2). The rest, by area — each is a one-line defect with location in the workflow output; the highest-value ones:

**setup-agentic-flow:** refresh has no baseline (declined reviewers re-proposed every run; hand-added repo-specific reviewers at risk in removal proposals); settings.toml never gains new plugin-version options (contradicts its own discoverability claim); no path to switch backends on re-run (silent refresh of the old one); reviewer-proposal gate lacks blocking language; orphaned-store decline path undefined; notion row-removal mechanic unspecified; empty-repo condition conflates "no signal files" with "empty"; root-gitignore append lacks an already-present check.

**next-prd:** read set omits Abandoned PRDs and Spikes (and the two stores default oppositely on visibility); empty-state shortcut discards banked ideas/spikes — the parked signal the skill exists to resurface; "most recent 2–3 Done PRDs" has no recency definition in the files store; "what's next" trigger collides with `/next-ticket`; candidate-count bounds disagree (2–4 vs 3–4).

**grill-me:** no termination/handoff — the only broken link in the README's skill-to-skill chain (also flagged by dx-ergonomics); Open-PRD refusal has no guidance text; "before starting" vs "during grilling" read-ordering conflict; no ordered Process spine (unique among workflow skills); CONTEXT-FORMAT's changed-term→retro-Cross-cutting duty has no carrying mechanism; "design tree"/"decision tree" drift.

**to-prd:** numbering has no empty-store base case; fit-check addressee/blocking semantics unclear; "frozen PRD… with status Drafting" contradicts the lifecycle in its own description (+ README echo, 3 reviewers); path-style Modules-touched example contradicts the no-file-paths anti-pattern; Spike/Idea vehicles thinly specified (no SPIKE-FORMAT).

**to-tickets:** step 10 silently steals the active pointer from a mid-implementation PRD (2 reviewers); Diff-base fallback can freeze an arbitrary current branch; single-batch relation-write failure may be silent; the proposal gate shows Goals only — acceptance criteria are authored after confirmation, unreviewed; H1-title mismatch with TICKET-FORMAT.

**next-ticket:** trigger overlaps `/done` ("finishing a ticket", 2 reviewers); research-opener brief isn't store-neutral (sub-agent can't fetch Goal/AC in notion) and collides with "don't read ticket bodies"; lazy PRD-branch creation keyed on ordinal not existence, ignores Diff base (3 reviewers); no-ready triage misses the zero-tickets case; dependency on Abandoned/unresolvable tickets undefined.

**tdd:** refactor-per-cycle vs refactor-at-end ambiguity; test-passes-immediately path missing; no exit step (full suite, plan reconciliation, `/done` handoff); deep-modules ratio framing vs LANGUAGE.md rejected-framings (vocabulary conflict inside one ticket lifecycle); deviations duty in a trailing paragraph, absent from the loop checklist; "CLAUDE.md weighting" jargon.

**done:** steps 4–5 confirmation ambiguity (user vs self); diff-range notation + planning-artifact hunks unaddressed in the brief (2 reviewers); ADR "defer" has no persistence; absent/Drafting active-pointer unhandled; `--no-ff` hard-coded in the same sentence that says read the convention from config; red-verification path leaves the merge commit on the parent with no revert/fix-forward guidance; three consecutive blocking turns to close a clean ticket (gate-density, with a skip-when-empty suggestion).

**improve-codebase-architecture:** ad-hoc mode contradicts "don't run before /done" and leaves mandatory brief inputs referent-less; no behavior when the ticket branch was already merged-and-deleted (2 reviewers); "who implements accepted candidates" is never stated; name-resolution verification mechanism unspecified; "## Glossary" heading collides with the defined term; "settled" is not a defined ADR status.

**retro:** ADR-candidate step lacks `/done`'s blocking language and toolchain gate; outcome-label derivation underspecified (ticket→section mapping is pure inference; "dominant label" buries a real Divergence); Drafting PRD passes both refusal checks vacuously; resolver says "/retro clears it on close" unconditionally, contradicting the thrice-stated conditional clear.

**new:** bootstrap tells the new agent to delete the handoff before doing any work (destroying it at the moment of highest failure likelihood); fixed filename silently overwrites an unconsumed handoff; volatile-state hygiene scoped only to the long form; nested-fence breakage in the inline path.

**plugin-agents:** qa-engineer is the one reviewer still referencing ADRs without the brief-sourcing line (residual from the store-neutralization pass); the brief's three exclusion inputs are honored by no agent body; ux-ui-expert's 90-word description violates AGENT-FORMAT's one-line rule and duplicates setup's detection table.

**shared docs / notion:** ADRs schema ships a `Proposed` status the lifecycle forbids (3 reviewers); Reviewers schema can't represent repo-specific reviewers; PRDs `Tags` multi-select referenced by nothing; `RELATION(…, DUAL 'Blocks' 'blocks')` tokens unexplained; id-plumbing assumptions stacked without fallback; CONTEXT-FORMAT's CONTEXT-MAP.md convention exists in no other doc; RETRO-FORMAT's "git history is the only place they survive" is files-store-only phrasing in a store-neutral doc.

---

## What's working

Consistently praised across independent reviewers — worth protecting through the fixes:

- **Blocking-gate discipline.** The "present and end the turn — don't proceed in the same breath" formula appears at exactly the steps where LLM eagerness fires (`/done` 6–7, `/retro` 10, tdd plan gate, `/improve` 9), and `/done`'s outcome-label step requiring the strongest alternative label makes skipped elicitation transcript-visible.
- **Failure-history annotations.** "~20 cancelled git calls", "four ADRs rotted on unverified external facts", "this happened and shipped a real defect" — six reviewers independently called these out as materially improving rule adherence.
- **Uniform `## State contract` blocks** make lifecycle preconditions checkable at a glance, and the core Drafting→Open→Done / Open→In progress→Done machine is coherent across five documents.
- **The deviation-fact-checker seam** is parse-safe on both sides: exact headings, fixed order, `_None._` sentinels, identical in agent body, `/done`, and AGENT-FORMAT's example.
- **Store-neutrality discipline mostly holds**: skills name artifacts abstractly, backend mechanics appear only at genuine divergence points, and the fae902e store-neutralization carried through 9 of 10 agents.
- **Deliberate crash-geometry where it was designed**: clear-then-set failing safe to zero actives, `/next-ticket`'s reachability check, `/retro`'s diff-completeness check, warn-vs-refuse calibration.
- **CONTEXT.md's vocabulary is self-applied** (`_Avoid_` lists actually enforced in LANGUAGE.md and agent prose), and grill-me's Protected-behaviors block is a rare, high-signal guard against prompt rot.

## Contract sync-sets (maintenance inventory)

Cross-references the reviewers surfaced as must-change-together sets:

| Contract | Copies that must stay in sync |
|---|---|
| fact-checker 3-heading output | `agents/deviation-fact-checker.md`, `done` step 3, `retro` step 4, AGENT-FORMAT example |
| `(refactor)` marker provenance | CONTEXT.md, README:75, TICKET-FORMAT:58, RETRO-FORMAT:44, fact-checker:42 — **plus the contradicting `tdd/refactoring.md:18`** |
| close-out merge recipe | `done` step 11, `next-ticket` reachability recovery, `retro` step 3 |
| five PRD body headings | `to-prd` step 4, PRD-FORMAT, NOTION-RESOLVER template limitation, `retro` step 7 |
| notion Branch / Diff base | written by `to-tickets` step 8; read by `done` step 2, `retro` step 3; **ignored by `next-ticket`'s branch cut (bug)** |
| settings.toml template ↔ consumers | setup template; `next-ticket` (strategy, research_opener), `done` (merge convention) |
| reviewer brief bullets ↔ agent bodies | `improve` step 4 ↔ all nine agents' "your brief carries…" phrases |
| ride-along commit rule | STORE.md:90, `next-ticket` step 6, `done` step 9 |
| framework detection list | ux-ui-expert description ↔ setup's detection table |
| Also noted: spike findings currently have **no consumer** anywhere in the workflow chain. | |

## Suggested fix sequence

1. **Now (minutes):** quote the two YAML descriptions (Tier 1 #5); fix `done:90`'s sentinel anti-pattern (Tier 2 #10).
2. **Before anyone uses the notion backend:** the 15-minute live smoke test (Tier 1 #7); then Tickets `Number`/`Slug` (Tier 1 #3), the `# Retro` heading + body-edit protocol (Tier 1 #2), root-page sharing guidance (Tier 1 #6), setup schema-check on re-run + non-circular recovery (Tier 2 #12, #17).
3. **Files-store correctness (one coherent PR):** planning-commit offers at both close points + PRD→main merge offer + `/retro` committed-baseline precondition + spike/idea commit offer (Tier 1 #1); the shared diff-materialization convention (Tier 2 #11).
4. **Decide stacked mode** — spec it fully or remove it (Tier 1 #4).
5. **Contract repairs:** reviewer diff delivery + checked-clean (Tier 2 #8); abandonment owner (Tier 2 #9); idea promotion (Tier 2 #15); tdd integration + marker decision (Tier 2 #13); grill-me PRD edits + ADR gate (Tier 2 #14); `/improve` hand-offs (Tier 2 #16); the workflow-chain and slug singles (Tier 2 #17).
6. **Sweep the minors** opportunistically when touching each file — the appendix groups them by area.

---

*Generated from workflow run `wf_17381f5c-ac1` (118 agents, ~5.4M tokens). Ten verification agents did not complete (session limit); their findings are marked UNVERIFIED above. The full structured output, including verifier reasoning per finding, is preserved in the session's task output for `wj8m0hdto`.*
