# Molt: Claude Code orchestration skills, in a workflow kit that sheds its shell

Molt bundles the skills its author uses to work with Claude Code, and changes as that way of working does. **Today: orchestration.** One orchestrator session runs related tasks in parallel sessions, tracks them on a live plan board and keeps a private wiki so it can run for weeks. It also lets cloud sessions use your computer. Formerly Cloud Local Bridge.

## What is a Claude Code orchestrator?

A Claude Code orchestrator is one session that plans the work and hands each task to its own session, instead of doing everything in one long chat. You talk only to the orchestrator. It starts the sessions, passes their questions to you, checks each pull request and tracks progress. Molt gives Claude Code the skills to work this way. The orchestrator runs in a claude.ai/code cloud session, and its tasks run in cloud sessions or on your computer. See [Claude Code orchestrator](https://shijianxi.github.io/molt/orchestrator/index.md).

## The skills in the kit

- **orchestrate**: splits a request into tasks and runs each in its own Claude Code session, in the cloud or on your computer. You talk to one session; it relays questions, checks pull requests and asks before archiving finished sessions.
- **artifact-plan**: a live plan board for work with several dependent tasks. It shows every task, its order and what blocks it. A task only moves to done once its pull request is checked.
- **orchestrator-wiki**: a private wiki for a long-running orchestrator, one per domain. You can `/compact` or `/clear` and say "resume my billing orchestrator". Old items move to a monthly archive, and the orchestrator reviews its own friction to learn rules.
- **cloud-local-bridge**: hands browser use, OAuth sign-ins, local files, desktop apps and local MCP servers from a claude.ai/code cloud session to a Claude session on your computer, and sends the result back.

## Install

1. Open [Customize → Plugins](https://claude.ai/customize/plugins) on claude.ai.
2. Find **Molt** under Discover. Choose Add.
3. Start a new session.

Or in a local Claude Code session: `/plugin install molt --marketplace ShiJianXi/molt`

## Questions

**How do I orchestrate several Claude Code sessions at once?** Install Molt and say "orchestrate these tasks, one session each". The orchestrator starts a session per task, each on its own branch, and passes their questions to you in one place.

**How is this different from subagents?** A subagent runs inside one session and reports back once. Molt's orchestrator starts full sessions, each on its own branch, that can ask you questions while they work. Code tasks usually end in their own pull request, and for bigger plans with dependent tasks it offers a live plan board.

**Can I clear or compact a long-running orchestrator?** Yes, if it keeps a wiki. Prefer `/compact`; after `/clear`, say "resume my billing orchestrator" and it reads the wiki first.

**How do I let Claude Code on the web do something that needs my computer?** Ask it to hand that step to your computer. A local Claude session (Claude Desktop, or `claude remote-control`) does it and sends the result back.

**Does it collect data?** No. No servers, no hooks, no network calls.

**Is it free?** Yes. Free and open source, MIT license.

Source: https://github.com/ShiJianXi/molt
