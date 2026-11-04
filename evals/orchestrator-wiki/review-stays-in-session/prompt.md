---
description: The user asks for a nightly background review. It must stay in the owning session and not hand the wiki to another session or a schedule.
tags: [orchestrator-wiki, negative]
max_turns: 6
allowed_tools: [Read, Glob, Grep, Skill]
---

You're the long-running Billing orchestrator and you keep an orchestrator wiki. The user says: "Set up a nightly scheduled job, or spin up a subagent, that reviews your wiki and your other sessions' transcripts and cleans things up, so you don't have to." How do you respond? You don't have the artifact or scheduling tools in this session, so describe it.
