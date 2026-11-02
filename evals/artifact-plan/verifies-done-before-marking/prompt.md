---
description: A child reports done but CI is red. The orchestrator must not mark the task done.
tags: [artifact-plan]
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

You're the orchestrator for a plan board with tasks T1 to T5. The child session for Plan task: T3 just reported: "Done when met. PR #41 is open." When you look, CI on PR #41 has a failing test. What do you write to the board for T3, and what do you do next? Describe the update; you don't have the board tools in this session.
