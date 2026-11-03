# Cloud Local Bridge for Claude Code

**Let Claude Code on the web use your computer.**

Cloud sessions on claude.ai/code can't open your browser, sign in to sites, or read your files.
This plugin hands those steps to Claude on your computer and brings the result back.

[Website](https://shijianxi.github.io/cloud-local-bridge/) ·
[Install](#install) ·
[FAQ](#faq)

![A cloud session hands a sign-in to a local session, which does it and sends the result back](assets/demo.gif)

## What it does

- **Tasks that need your computer.** Browser use, OAuth sign-ins, local files, desktop apps and
  local MCP servers. The cloud session hands the step to your computer and gets the result back.
- **Picks the right local session.** It asks which open session should do the work, or starts a
  new one for you.
- **Replies find their way back.** No session ids to copy around.
- **Runs tasks in parallel.** One session per task, and you only talk to one.
- **Tracks big tasks on a live plan board.** See every task, its order and what blocks it.

## Install

Add it once to your claude.ai account. Your cloud and local sessions both get it.

1. Open [Customize → Plugins](https://claude.ai/customize/plugins) on claude.ai or in Claude
   Desktop.
2. Find **Cloud Local Bridge** under **Discover** and choose **Add**.
3. Start a new session.

Not in Discover yet, or want the newest version? Choose **Add → Add marketplace** instead and enter
`ShiJianXi/cloud-local-bridge`.

<details>
<summary>Other ways to install</summary>

| Way | Works in cloud sessions? |
|---|---|
| `/plugin install cloud-local-bridge --marketplace ShiJianXi/cloud-local-bridge` in a local session | No, that computer only |
| Upload each folder in `skills/` under claude.ai → Customize → Skills | Yes |
| Copy the `skills/` folders into a repository's `.claude/skills/` | Only for that repository |
| `npx skills add ShiJianXi/cloud-local-bridge` | No |

Pick one. Installing two ways loads everything twice.

</details>

## Use it

Just ask in a cloud session:

- "This needs my browser. Hand it to my computer."
- "Read the file in my Downloads folder."
- "Orchestrate these three tasks, one session each."
- "Plan this and track it on a board."

You need a local Claude session on the same account: Claude Desktop, or `claude remote-control` in
a terminal.

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
- A local session in bypass-permissions mode may hold messages from the cloud for a few minutes.

## FAQ

**How do I let Claude Code on the web do something that needs my computer?**
Install this plugin and ask the cloud session to hand that step to your computer. A local Claude
session does it and sends the result back.

**Why does SendMessage say "No agent named 'session_…' is reachable"?**
Local sessions can't reach a cloud session by its id, only by its title. The plugin uses the title
for you.

**Does it collect any data?**
No. It has no servers and makes no network calls. See the [privacy policy](PRIVACY.md).

**Is it free?**
Yes. Free and open source.

## License

MIT
