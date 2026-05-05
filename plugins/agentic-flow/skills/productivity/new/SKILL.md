---
name: new
description: Distill session and project context into a prompt for a new agent.
disable-model-invocation: true
---

# new

The user has invoked `/new`. They want a prompt that bootstraps a fresh agent into the work that's been happening in this session — so they can paste it into a new conversation and pick up without losing momentum.

Your job is to write that prompt. The new agent will read it cold, with none of the context you currently have, so everything it needs has to be on the page.

## What to include

Walk through the conversation and the project, and pull together whatever a new agent would actually need to be useful on its first turn. That generally means some subset of:

- **The project**: what it is, what it's for, what stack/language/conventions it uses. One or two sentences is usually enough — link to the README or equivalent rather than restating it.
- **The current task**: what the user is trying to accomplish right now, and how it fits into the larger project. Be specific about the goal, not just the topic.
- **Where we are**: what's been tried, what's working, what's been ruled out. A new agent that doesn't know what's already been attempted will redo it.
- **Files of interest**: paths the new agent should read first, with a short note on why each one matters (e.g. "`src/auth/session.ts` — where the bug lives" vs. "`docs/architecture.md` — read for context before editing").
- **Documentation pointers**: external docs, internal wikis, design docs, or spec files the new agent should consult. Include URLs or paths.
- **Open questions**: decisions that haven't been made yet — implementation choices, architecture tradeoffs, design questions, anything you've been waiting on the user for. Frame these so the new agent knows to ask rather than guess.
- **Constraints and gotchas**: things the user has said matter (style preferences, "don't touch X", deadline pressure, "we tried Y and it broke prod"). These are easy to lose and expensive to rediscover.

Skip categories that don't apply. A bug-hunting session has different needs than a greenfield design session — match the prompt to the actual work.

Write it as a prompt directed at the new agent ("You're picking up..."), not as a status report directed at the user.

## Output: inline vs. `prompt.md`

Decide based on length:

- **If the prompt fits comfortably in chat** (roughly under 2,000 characters — short enough to copy-paste and skim quickly), output it inline in a single fenced code block so the user can copy it cleanly.

- **If it's longer than that**, write the full prompt to `prompt.md` in the root of the project, and output a short bootstrap prompt in chat that points the new agent at the file. The bootstrap must instruct the new agent to **delete `prompt.md` after reading and understanding it** — the file is scratch context, not a project artifact, and leaving it around pollutes the repo.

Example bootstrap prompt for the long case:

```
Read prompt.md in the project root — it contains everything you need to get up to speed on the current task. Once you've read it and you're confident you understand the context, delete prompt.md (it's transient scratch context, not part of the project) and confirm you're ready to continue.
```

Adjust the wording to fit, but keep the deletion instruction — it's the part that's easiest to drop and most annoying to clean up later.

## A few things to watch for

- **Don't pad.** If a section would be empty or thin, cut it. A tight prompt beats a comprehensive one the new agent has to wade through.
- **Don't paraphrase the user's exact words on contested points.** If the user said "I want this to be functional, not OO," quote that — paraphrase loses the edge.
- **Be honest about uncertainty.** If you're not sure whether a file is relevant, say so rather than asserting it confidently. The new agent will trust the prompt; misplaced confidence costs more than a hedge.
- **Don't include this skill or the `/new` command itself in the prompt.** The new agent doesn't need to know how it got bootstrapped.