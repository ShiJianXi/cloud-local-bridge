# Molt: Claude Code orchestration skills

[![check](https://github.com/ShiJianXi/molt/actions/workflows/check.yml/badge.svg)](https://github.com/ShiJianXi/molt/actions/workflows/check.yml)
[![version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FShiJianXi%2Fmolt%2Fmain%2F.claude-plugin%2Fplugin.json&query=%24.version&label=version)](.claude-plugin/plugin.json)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-d97757.svg)](#install)

**A Claude Code workflow kit that sheds its shell as the way we work with Claude changes.**

Molt bundles the skills I use to work with Claude Code, and it changes as the way I work changes.

**Today: orchestration.** One Claude Code session acts as an orchestrator. It splits work into
tasks, runs each in its own parallel session, tracks them on a live plan board, and keeps its own
memory in a private wiki so it can run for weeks. It can also hand browser, sign-in and local-file
steps from cloud sessions to your computer.

*Formerly Cloud Local Bridge. Already installed it? See [Renamed from Cloud Local Bridge](#renamed-from-cloud-local-bridge).*

[Website](https://shijianxi.github.io/molt/) ·
[Install](#install) ·
[FAQ](#faq)

![A cloud session hands a sign-in to a local session, which does it and sends the result back](assets/demo.gif)

## What is a Claude Code orchestrator?

A Claude Code orchestrator is one session that plans the work and hands each task to its own
session, instead of doing everything in one long chat. You talk only to the orchestrator. It
starts the sessions, passes their questions to you, checks each pull request and tracks progress.
Molt gives Claude Code the skills to work this way. The orchestrator runs in a claude.ai/code cloud session, and its tasks run in cloud sessions or on your computer.

## What it does

- **Runs tasks in parallel.** One session per task, and you only talk to one.
- **Tracks big tasks on a live plan board.** See every task, its order and what blocks it.
- **Long-running orchestrators keep a private wiki.** One per domain, read only by that session,
  so you can `/compact` or `/clear` it and it picks up where it left off.
- **The wiki stays small and gets better.** Old items move to an archive instead of piling up,
  and the orchestrator reviews its own friction to tidy up and learn its own rules.
- **Tasks that need your computer.** Browser use, OAuth sign-ins, local files, desktop apps and
  local MCP servers. The cloud session hands the step to your computer and gets the result back.
- **Picks the right local session.** It asks which open session should do the work, or starts a
  new one for you.
- **Replies find their way back.** No session ids to copy around.

## Install

Add it once to your claude.ai account. Your cloud and local sessions both get it.

1. Open [Customize → Plugins](https://claude.ai/customize/plugins) on claude.ai or in Claude
   Desktop.
2. Find **Molt** under **Discover** and choose **Add**.
3. Start a new session.

Not in Discover yet, or want the newest version? Choose **Add → Add marketplace** instead and enter
`ShiJianXi/molt`.

<details>
<summary>Other ways to install</summary>

| Way | Works in cloud sessions? |
|---|---|
| `/plugin install molt --marketplace ShiJianXi/molt` in a local session | No, that computer only |
| Upload each folder in `skills/` under claude.ai → Customize → Skills | Yes |
| Copy the `skills/` folders into a repository's `.claude/skills/` | Only for that repository |
| `npx skills add ShiJianXi/molt` | No |

Pick one. Installing two ways loads everything twice.

</details>

## Use it

Just ask in a cloud session:

- "Orchestrate these three tasks, one session each."
- "Plan this and track it on a board."
- "Own billing from now on and keep a wiki."
- "This needs my browser. Hand it to my computer."
- "Read the file in my Downloads folder."

You need a local Claude session on the same account, connected to Remote Control. In Claude
Desktop, turn on **Connect new sessions to Remote Control**. In a terminal, run
`claude remote-control`.

### Let the cloud start local sessions for you

Run this in your project folder and leave it open:

```
claude remote-control --spawn worktree --chrome
```

The cloud session can then start a fresh local session whenever it needs one. Each gets its own
git worktree and can use your browser.

## Good to know

- Read the reply in the cloud session. Delivery back to the cloud isn't confirmed.
- Run parallel tasks from a cloud session in **auto** mode, or they stall waiting for approvals.
- A cloud session started by another session can come up without your claude.ai plugins. The
  orchestrator lists the plugins it has in each child's brief, and a child that's missing one
  attaches the plugin's repository and links its skills in, so they load mid-session. Only the
  skills come across, not the plugin's hooks or MCP servers. Attaching a plugin's repository needs
  your yes, so the orchestrator asks once before it starts the children. A plugin step that must happen (say,
  a script whose output goes in the PR) goes in the child's "done when", and the orchestrator
  checks it before calling the task done.
- Don't use bypass-permissions mode for the local session. It holds messages from the cloud, and
  Desktop drops them after 5 minutes.
- An orchestrator with a wiki writes to it only when a fact would otherwise be lost. Only that
  session reads it. After `/compact`, `/clear` or a restart, say "resume my <domain>
  orchestrator" and it reads the wiki before anything else. Prefer `/compact`: the orchestrator restates its role
  after each wiki write, so an automatic compaction usually keeps it working from the wiki. Molt ships no hooks, so nothing runs
  on its own when a session starts.
- The wiki page shows what needs you first, then a card for each piece of work, then the
  decisions and gotchas. Ids and tool names are kept in a "Technical details" fold. A wiki made
  before 2.1.0 switches to this layout the next time it's resumed or written to.
- The wiki stays the same size over weeks or months. Superseded decisions, stale gotchas, finished
  work and old log lines move to monthly archive docs inside the same private wiki, which are read
  only when a question needs history. Nothing is deleted.
- About once a week, or when you say "review the wiki", the orchestrator reviews itself. It works
  from friction it noted at the time (your corrections, failed children, retries, questions left
  waiting). It tidies and adds or retires its own **learned rules**, shown apart from your rules,
  on its own. It asks you before changing your rules or the scope. The review never runs in
  another session, a subagent or on a schedule, and never reads other sessions.

## Renamed from Cloud Local Bridge

This plugin was called **Cloud Local Bridge** (`cloud-local-bridge`) until version 2.0.0. Claude
Code treats the new name as a different plugin, so an old install stops getting updates. Remove
**Cloud Local Bridge** under Customize → Plugins and add **Molt**. Old GitHub links redirect here.

## FAQ

**How do I orchestrate several Claude Code sessions at once?**
Install Molt and say "orchestrate these tasks, one session each". The orchestrator starts a
session per task, each on its own branch, and passes their questions to you in one place.

**How is this different from subagents?**
A subagent runs inside one session and reports back once. Molt's orchestrator starts full sessions, each on its own branch, that can ask you questions while they work. Code tasks usually end in their own pull request, and for bigger plans with dependent tasks it offers a live plan board.

**How do I let Claude Code on the web do something that needs my computer?**
Install this plugin and ask the cloud session to hand that step to your computer. A local Claude
session does it and sends the result back.

**Why does SendMessage say "No agent named 'session_…' is reachable"?**
Local sessions can't reach a cloud session by its id, only by its title. The plugin uses the title
for you.

**Can I clear or compact a long-running orchestrator?**
Yes, if it keeps a wiki. Ask it to own a domain and keep a wiki. It saves decisions and what's
running as they happen, so `/compact` and `/clear` lose nothing: afterwards, say "resume my
<domain> orchestrator". Each wiki is private to the one session that owns it.

**Won't a wiki kept for months get huge?**
No. The pages read on every resume stay capped. What falls off them goes to a monthly archive in
the same private wiki, and a regular review tidies up, merges duplicates and learns rules from
recurring trouble. Say "forget that rule" to drop a learned rule.

**Why doesn't a session started by another session have my plugins?**
Sessions you start from the app get your claude.ai plugins. A session another session starts can
come up with only the built-in ones, and nothing when starting it turns that on. The orchestrator
tells each child which plugins it uses and where they live, and the child loads their skills
itself.

**Does it collect any data?**
No. It has no servers, no hooks and no scripts that make network calls. See the [privacy policy](PRIVACY.md).

**Is it free?**
Yes. Free and open source.

## Development

Run these from the plugin root after changing a skill:

- `claude plugin eval . --tag artifact-plan`: three cases in `evals/artifact-plan/`.
- `claude plugin eval . --tag orchestrator-wiki`: nine cases in `evals/orchestrator-wiki/`.
- `node skills/orchestrator-wiki/test_wiki_page.mjs`: checks the wiki page shows learned rules, the
  last review and the archive.
- `python3 skills/artifact-plan/scripts/validate_plan.py --selftest`: checks the plan validator.
- `sh skills/orchestrate/test_plugin_block.sh`: checks the brief's plugin-loading block.

CI (`.github/workflows/check.yml`) runs `claude plugin validate .`, the last three checks and a check that skill frontmatter has no `<` or `>` (claude.ai strips them from descriptions) on every pull request. The evals call the model, so CI leaves them out. Run them by hand before a release.

When a review finding is accepted, fix it with a check that fails before the fix and passes after it. Add that check to one of the scripts above, so CI keeps the bug from coming back.

## Website

The [website](https://shijianxi.github.io/molt/) lives on the `gh-pages` branch. The page title,
description, the line under the main heading and this README's "Today" paragraph name the current
workflow. When the way of working changes, update those lines and add a page for the new workflow.
Keep old workflow pages up and mark them as earlier workflows. Agents can read
[llms.txt](https://shijianxi.github.io/molt/llms.txt).

Every page has a dark and a light theme. It follows the system setting until a visitor uses the
theme button in the header, which remembers their choice. A new page needs the same theme colors,
the small script in `<head>` that applies the saved theme before the page draws, and the button.

## Contributing

Issues and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT
