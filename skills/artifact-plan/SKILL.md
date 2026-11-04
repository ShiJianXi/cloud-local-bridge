---
name: artifact-plan
description: >
  Tracks a large task on a live plan board (an artifact showing the tasks, their order, and what
  blocks what) instead of a markdown plan file. Use when a request splits into 3 or more tasks with
  dependencies between them, when the orchestrate skill splits work across sessions, or when the
  user says "plan this", "track this", "make a plan board". Offers the board first and builds it
  only on a yes. Also use whenever this session orchestrates work tracked on a plan board: a
  child's report, approach note or question about a `Plan task:` id, deciding what to write to the
  board, and resuming after a restart.
---

# Artifact plan

One **plan board** per large task. The orchestrator (the session the user talks to) creates it, is
the **only writer**, and updates it as implementation agents report. Agents never touch it.
The page is `tracker.html` in this skill's directory; the data lives in the board's database, so
updates are database writes, never republishes. `scripts/validate_plan.py` checks the task graph.

## 1. Detect

Offer a plan board when all of these hold:

- the work splits into **3 or more** tasks that can each be finished and checked on their own;
- at least one task **depends on** another (needs its output, or touches the same files after it);
- it will run across several sessions or agents, or take more than about an hour.

Below that, just do the work. Never offer twice in one session after a "no".

## 2. Offer

Ask with `AskUserQuestion`, one question:

> This splits into N tasks, and K of them wait on others. Track it on a plan board?

Options: **Track it on a plan board (Recommended)** and **Just start**. On "Just start", go on
without one. If the Artifact tool or `ArtifactData` isn't available in this session, say so in one
line and go on without one.

## 3. Build the task graph

Write the tasks before publishing anything. Each task has:

| field       | meaning                                                              |
|-------------|----------------------------------------------------------------------|
| `id`        | `T1`, `T2`, ... (the doc id), stable for the life of the plan        |
| `title`     | what gets built, in the user's words, under 40 characters            |
| `order`     | tie-break inside a wave (lower first)                                |
| `blockedBy` | ids that must be `done` first; `[]` when it can start now            |
| `doneWhen`  | the observable result, e.g. "PR open, CI green, /settings renders"   |
| `details`   | scope: the files and areas in scope, and those off limits            |
| `status`    | `todo`, `in_progress`, `review`, `done` or `failed`                  |
| `owner`     | the child session's title, once started                              |
| `approach`  | the approach the orchestrator approved, in a line or two (step 6)    |
| `evidence`  | what the orchestrator checked before marking done (step 6)           |
| `branch`, `pr`, `note`, `updatedAt` | filled in as reports come in                 |

Rules: no cycles. Two tasks that touch the same files are either one task or chained with
`blockedBy`. Never store `ready` or `waiting`: the page derives them (a `todo` task is ready when
every blocker is `done`) and draws the waves from `blockedBy`. Clicking a task, in the list or the
graph, expands it to show every field plus its blockers' and dependents' statuses.

Write the tasks to a JSON list and run `python3 <skill dir>/scripts/validate_plan.py tasks.json`.
Fix every problem it prints (cycles, unknown or duplicate ids, missing `title` or `doneWhen`)
before going on. Then show the user the list (id, title, blocked by) and confirm the split, as
orchestrate step 1 does.

## 4. Publish and seed

1. Publish `tracker.html` from this skill's directory with the Artifact tool, a new file path per
   plan (copy it to the scratchpad as `plan-<slug>.html`), `icon` = `checklist`, and
   `capabilities` = `{"db": {"rules": [{"path": "plan", "read": "view", "write": "owner"},
   {"path": "tasks", "read": "view", "write": "owner"}, {"path": "log", "read": "view",
   "write": "owner"}]}}`. Only the owner writes; anyone it's shared with can only read.
2. Seed it with one `ArtifactData` `batch`:
   - `plan/meta`: `{goal, orchestrator}` (goal = the user's ask in one line, orchestrator = this
     session's title).
   - `tasks/<id>` for every task, all `todo`.
   - `log/e1`: `{at: <ISO time>, text: "Plan created with N tasks."}`.
3. Give the user the link, and put it in your table of running sessions so a resumed orchestrator
   can find it. If this session keeps an orchestrator wiki, add the board's `{title, url}` to its
   `wiki/meta` `boards` (`orchestrator-wiki` step 3). The board stays its own artifact; the wiki
   only links it.

## 5. Dispatch from the board

The board decides what starts. Start tasks whose blockers are all `done`, wave 1 first, using the
orchestrate skill's step 4, with **at most 3 to 5 running at once** even when more are unblocked;
start the next one as a slot frees. Each child's brief carries, from the task:

```
Plan task: <id>. <title>
Objective: <one or two sentences on what and why>
Done when: <doneWhen>
In scope: <files and areas from details>. Off limits: <files and areas other tasks own>.
Built on: <one line per done blocker: id, PR, and its evidence, e.g. "T1: PR #12 merged,
  settings table in db/schema.sql">. Build on these as they are; ask before changing them.
Approach first: before writing code, send the orchestrator the files you'll touch and the
  interfaces you'll create or use, in a few lines, then wait for "go" or "adjust".
Report to the orchestrator when you start, when a PR is open, when you are blocked (say on
  what), and when Done when is met. Each report: status, PR link, branch, and one or two lines.
  Never edit the plan board.
```

Leave out `Built on` for a wave-1 task. `Approach first` is required for a task that unblocks
others, since a wrong interface there breaks every dependent; for a leaf task, drop the line
unless the task is large or vague.

Do not start a task whose blockers aren't done, even if a session is idle. If the user wants it
started anyway, set it going and add a `note` saying it started early.

## 6. Update on every report

Each child report becomes one `ArtifactData` `batch`, pinned with the `if_version` you last read:

| report                     | write to `tasks/<id>`                                        |
|----------------------------|--------------------------------------------------------------|
| child started              | `status: in_progress`, `owner`, `branch`                     |
| approach note              | check it (below), reply, then `approach` = what you approved |
| PR open                    | `status: review`, `pr`                                       |
| blocked on a decision      | keep status, `note` = the question                           |
| Done when met              | verify first (below), then `status: done`, `evidence`        |
| failed or abandoned        | `status: failed`, `note` = why                               |

**Check the approach.** Compare the note with the task's `details` (in scope, off limits), its
`doneWhen`, the `Built on` outputs it must use, and what its dependents will need from it. Reply
"go" when it fits. Otherwise reply "adjust" with the specific change, such as "use the `settings`
columns from T1, don't add a new table", and wait for a revised note. An approach that changes
the plan (a new dependency, another task's files) is a plan change: handle it as below, and ask
the user first if it changes what they asked for.

**Verify before done.** A child saying it's done is a claim. Check it yourself: the PR exists,
its CI is green, and the `doneWhen` result is observable. Write what you checked to `evidence` in
a line ("PR #12 open, CI green, settings page renders"). If a check fails, keep the task in
`review`, put the gap in `note`, and send the child what's missing.

**Failures.** A failed task may be restarted once with a corrected brief. If it fails a second
time, mark it `failed` and ask the user what to do; don't restart it again. Its dependents stay
waiting.

**`doneWhen` is fixed.** Change it only with a log entry saying why. Loosening it (accepting less
than it says) needs the user's word first.

Every write also sets `updatedAt` and adds a `log/e<n>` entry, one sentence. After a task goes
`done`, find the tasks it unblocked (every blocker now `done`), start them within the cap
(step 5), and say so in the same log entry: "T1 done. T3 and T4 are unblocked; started both."

If the plan changes (a task splits, a new dependency shows up), rerun the validator on the new
list, then update `tasks` and `blockedBy` in one batch and log why. Delete a task only on the
user's word.

## 7. Resume

After a restart or a context compaction, the board is the source of truth, not your memory.
If this session keeps an orchestrator wiki, resume it first (`orchestrator-wiki` step 4); its
`state` page lists the open boards.
Read `plan/meta`, every `tasks` doc and the last 20 `log` entries. For each task that isn't
`done`, check its real state: its child session, branch and PR. Where the board and reality
differ, fix the board in one batch with a log entry ("Resumed: T4 PR merged while away, marked
done after checks."). Then carry on from step 5.

## 8. Finish

When every task is `done`, add a final log entry, tell the user in one line with the link, and
leave the board as the record. It's private until the user shares it from the page's Share menu.
