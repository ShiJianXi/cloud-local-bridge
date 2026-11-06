# Claude Code orchestrator: run parallel sessions from one chat

A Claude Code orchestrator is one session that plans the work and hands each task to its own session, instead of doing everything in one long chat. You talk only to the orchestrator. It starts the sessions, passes their questions to you, checks each pull request and tracks progress. Molt's free orchestration skills let Claude Code work this way.

[Install Molt free](https://shijianxi.github.io/molt/#install)

## Why orchestrate instead of one long session

- **Each task gets a clean context.** One session per task, on its own branch, so a long chat doesn't fill up with unrelated work.
- **Tasks run at the same time.** Independent work finishes in parallel instead of one after another.
- **You still talk to one session.** Questions from every task come back to the orchestrator, so you answer them in one place.
- **Nothing is marked done unchecked.** The orchestrator checks each pull request before it calls a task finished.

## How to orchestrate Claude Code sessions with Molt

1. **Install Molt.** On claude.ai, open [Customize → Plugins](https://claude.ai/customize/plugins), find Molt under Discover and choose Add. Start a new session.
2. **Ask for orchestration.** Say "orchestrate these tasks, one session each" and list them.
3. **Pick where they run.** The orchestrator asks whether to run them in the cloud or on your computer, and warns you when two tasks touch the same files.
4. **Answer in one place.** Each task runs in its own session and branch. Their questions come to you through the orchestrator.
5. **Track the board.** For work with dependencies, say "plan this and track it on a board" to get a live plan board.
6. **Review and merge.** When a pull request is ready, the orchestrator checks it, tells you, and asks whether to archive that session.

Run the orchestrator from a cloud session in **auto** mode, or the child sessions stall waiting for approvals.

## Things to say

```
Orchestrate these three tasks, one session each.
Plan this and track it on a board.
Own billing from now on and keep a wiki.
Resume my billing orchestrator.
Review the wiki.
```

## Keep a long-running orchestrator going for weeks

Ask an orchestrator to own a domain and keep a wiki. It writes decisions, gotchas and running work to a private wiki as they happen, so `/compact` and `/clear` lose nothing. After a clear, say "resume my billing orchestrator" and it reads the wiki before anything else. Only that session reads its wiki.

The wiki doesn't grow forever. Old items move to a monthly archive, and about once a week the orchestrator reviews its own friction, tidies up and learns its own rules. It asks you before changing your rules.

## Orchestrator, subagents or one session?

| | One session | Subagents | Molt orchestrator |
|---|---|---|---|
| Where work runs | One chat | Inside one session | A full session per task |
| Pull requests | One branch | Through the parent | One per task |
| Asks you questions | Yes | Reports back once | Yes, relayed to you |
| Progress tracking | None | None | Live plan board |
| Survives /clear | No | No | Yes, with a wiki |

## Questions

**What are Claude Code orchestration skills?** Skills that teach Claude Code to coordinate several sessions: split the work, start a session per task, relay questions, track progress and check results. Molt ships three: orchestrate, artifact-plan and orchestrator-wiki.

**Does it work with Claude Code on the web?** Yes. The orchestrator can run its tasks in cloud sessions, or on your computer through Remote Control.

**Is it free?** Yes. Free and open source under the MIT license. No servers and no data collected.

Orchestration is today's workflow in Molt. Molt is a workflow kit that changes as Claude Code best practices do, and this page will stay up when the next way of working arrives. [See the whole kit](https://shijianxi.github.io/molt/).
