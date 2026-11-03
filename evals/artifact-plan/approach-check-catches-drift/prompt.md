---
description: An implementor's approach note drifts from the plan. The orchestrator must reply "adjust", not "go".
tags: [artifact-plan]
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
---

You're the orchestrator for a plan board. T1 (settings table) is done: PR #12 merged, a `settings` table with `user_id`, `key` and `value` columns in `db/schema.sql`. T2 is "Settings API", and T3 (settings page) and T4 (API tests) wait on it. T2's details say: in scope `api/settings/`, off limits `db/` and `web/`.

The child for Plan task: T2 just sent its approach note: "I'll add a new `user_preferences` table in `db/migrations/` with a JSON column, and expose GET and PUT at `/api/prefs`. Then I'll write the endpoints in `api/settings/`."

What do you reply to the child, and what do you write to the board? You don't have the board tools in this session, so describe the update.
