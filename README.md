# cloud-local-bridge

A Claude Code skill for handing work from a cloud session (claude.ai/code) to a local session
(Claude Desktop or `claude remote-control`) and getting the result back, without you naming either
session by hand.

## The problem it fixes

Cloud sessions can't use your browser, run OAuth sign-ins or reach local files, so you delegate
that part to a local session. Without help, two things go wrong:

- **The reply gets lost.** A message from a cloud session tells the local session to reply through
  a "Claude Code Remote MCP" tool, using the cloud session's `session_…` id. Local sessions don't
  have that tool, and the id doesn't resolve. Only `SendMessage` to the cloud session's **title**,
  as `ListAgents` prints it, gets through.
- **The local session isn't found.** It has to be open, unarchived and connected to Remote
  Control. Desktop sessions archive themselves when their PR closes, and terminal sessions only
  show up when started with `claude remote-control`.

The skill gives both sides a fixed procedure. The sender lists your local sessions and asks which
one gets the work, or helps you open a new one. It puts a short header on the brief with its own
title and the topic. The receiver uses that header to find the reply target, and asks you to pick
from a list only when that fails.

## Install

Both sides need the plugin: the cloud session that hands work down and the local session that does
it. Add it once to your claude.ai account and it reaches both.

1. Open [Customize → Plugins](https://claude.ai/customize/plugins) on claude.ai or in the Claude
   desktop app.
2. Choose **Add → Add marketplace** and enter `ShiJianXi/cloud-local-bridge`.
3. Select **cloud-local-bridge** in the plugin list, then **Add**, and leave it turned on.
4. Start a new session. Plugins load when a session starts; in a local session that is already
   open, run `/reload-plugins`.

It then loads as `cloud-local-bridge@synced` in your cloud sessions (claude.ai/code) and in local
sessions signed in to the same account.

Once the listing in Anthropic's plugin directory is approved, you can skip step 2 and add **Cloud
Local Bridge** from **Discover** instead. On Team and Enterprise plans, an Owner may have to allow
adding marketplaces.

### Other ways to install

| Way | Reaches cloud sessions? |
|---|---|
| `/plugin install cloud-local-bridge --marketplace ShiJianXi/cloud-local-bridge` in a local Claude Code session | No, that machine only |
| Zip `skills/cloud-local-bridge` and upload it under claude.ai → Customize → Skills | Yes |
| Commit `skills/cloud-local-bridge` to a repository's `.claude/skills/` | Only for that repository |
| `npx skills add ShiJianXi/cloud-local-bridge`, or copy the folder into `~/.claude/skills/` | No |

Use one way per account. The claude.ai plugin plus a skill upload loads the skill twice.

### Optional: start local sessions from claude.ai

When the cloud session asks which local session to use, you can pick **New local session**. To
start that session from claude.ai/code or your phone instead of at your computer, set the computer
up once in either of these ways:

- **Claude Desktop:** in **Settings → Claude Code**, turn on **Use this computer from your phone
  and claude.ai** and add your project folders under it. It works while the app is open and the
  computer is awake. The docs describe this switch for Claude Projects, so it may not appear on
  every plan.
- **Terminal:** in the project folder, run
  `claude remote-control --spawn worktree --chrome` and leave it running. `--spawn worktree` gives
  each new session its own git worktree, and `--chrome` lets those sessions use your browser.

Then start a new session on claude.ai/code and pick your computer in its Remote Control menu.
Anyone signed in to your claude.ai account can start sessions in those folders, so keep the list
short.

## Examples

1. **Cloud session needs a browser sign-in.** In a cloud session, type: "This needs an OAuth
   sign-in in my browser, delegate it to a local session." The skill lists your open local sessions
   and asks which one to use, with **New local session** as another choice. For a new one, it starts
   it if it can, or tells you how and waits until it appears. It then sends the brief with a
   `HANDOFF` header that carries the cloud session's title and the topic.
2. **Local session sends the result back.** The local session gets a
   `<cross-session-message from-session="session_…">`, does the task, then finds the cloud session
   in `ListAgents` by the title in the header and replies with `SendMessage`, so you don't have to
   name it.
3. **The cloud session was renamed.** No `ListAgents` row matches the header's title any more. The
   local session falls back to the one cloud row whose title matches the header's topic. If none
   or several match, it asks you to pick from the cloud sessions it can see, and does not send to a
   guess.

## Limits

- Delivery from a local session to a cloud session is never confirmed. Read the reply in the cloud
  session's transcript.
- A local session in bypass-permissions mode holds messages from cloud sessions, and Desktop drops
  them after 5 minutes.
- The tools a cloud session uses to list local sessions aren't documented, so the skill tells it to
  search for them before deciding there is no local session.
- Anthropic's docs list plugins synced from claude.ai for Cowork and terminal sessions only. In
  October 2026 they also loaded in claude.ai/code cloud sessions, which is what the recommended
  install relies on.

## License

MIT
