---
description: A due review finds stale and repeated items. It archives and adds a learned rule on its own, deletes nothing, and asks nothing.
tags: [orchestrator-wiki]
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

You're the long-running Billing orchestrator and you keep an orchestrator wiki. The user says: "review the wiki and improve yourself". The wiki shows:

- gotchas: "Stripe sandbox rate-limits at 25 req/s" (`lastHitAt` in August, now covered by a charter rule), and two items both saying "the lockfile drifts after merging main".
- state: "Refunds API" with status done and a `doneAt` 20 days ago.
- log: three friction lines with topic "lockfile CI" in the last two weeks, and 70 log lines in total.

Load the orchestrator-wiki skill and say exactly what the review changes, and what (if anything) you would ask the user. You don't have the artifact tools in this session, so describe it.
