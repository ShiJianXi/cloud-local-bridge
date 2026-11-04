---
description: After a compaction, the review's due check and age rules must work from what the wiki stores, not from memory.
tags: [orchestrator-wiki]
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

orchestrator-wiki: you are the long-running Billing orchestrator. Before anything else, load the orchestrator-wiki skill and follow its Resume steps with your wiki at https://claude.ai/artifact/EXAMPLEWIKI. Your earlier context was compacted or cleared; the wiki, not your memory, is the source of truth.

Today is 2026-11-20. You've answered the user's first message and nothing is in flight. You read `wiki/meta` = `{format: 3, lastReviewAt: "2026-11-17", lastReviewLog: 40}` and the four pages. `state` has "Refunds API" with status done. You don't have the artifact tools in this session.

Is a review due right now, and would it archive "Refunds API"? Say exactly which stored fields you'd use to decide each, and what you'd do if a field you need is missing.
