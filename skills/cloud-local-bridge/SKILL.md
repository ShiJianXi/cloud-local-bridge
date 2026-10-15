---
name: cloud-local-bridge
description: >
  Hand work between the user's cloud sessions (claude.ai/code) and local sessions (Claude Desktop,
  `claude remote-control`) and get the result back without the user naming sessions. Use when a
  cloud session needs something only the user's machine can do (browser, OAuth sign-in, desktop
  apps, local files) — "delegate to a local agent", "hand this to my local session" — and when a local session
  receives a `<cross-session-message from-session="session_…">` or is told to "send it back".
---

# Cloud-local bridge

Two roles. Find yours: a cloud session handing work down is the **sender**; a local session that
received a `<cross-session-message from-session="session_…">` is the **receiver**.

## Facts that cause the failures (observed October 2026, Claude Code 2.1.28x)

- `SendMessage` with the **name a `ListAgents` row prints** is the only route that worked in both
  directions. Local sessions see a cloud session by its **title** (e.g. `Fix login redirect`),
  never by its `session_…` id or its own cloud-side name (`user-e8`, `user-fb`).
- The cloud wrapper says to reply through "the send_message tool of the Claude Code Remote MCP
  server" with the `session_…` id. A Desktop session has no such tool. `SendMessage` with the
  `session_…` id fails ("No agent named … is reachable"), and `mcp__ccd_session_mgmt__send_message`
  fails ("session … not found"): that one only reaches local Desktop sessions.
- A local session is visible from the cloud only while it is open, unarchived and on Remote
  Control. Desktop: a session joins when the app's "Connect new sessions to Remote Control" setting
  is on or the user turns it on for that session; with auto-archive on PR close, it disappears when
  its PR closes. Terminal: only `claude remote-control` (or `/remote-control` inside a session).
- A local session in bypass-permissions mode holds messages from a cloud session; Desktop drops
  them after 5 minutes. Run the pickup session in any other mode.
- Local → cloud delivery is never confirmed; the reply lands in the cloud session's own
  transcript. A 38 KB message went through in one send. `ListAgents` shows only the newest cloud
  sessions, so an old one can be missing.
- Titles drift: the same `[ref]` row can show a new title a day later. Always read a fresh
  `ListAgents` right before sending.

## Sender (cloud → local)

1. **List the local sessions.** Run `ListAgents`; if it shows no local rows, `ToolSearch` for
   `list sessions remote control` and run what it finds before concluding there is none. Keep the
   local / Desktop / Remote Control rows; step 3 compares against them. Also `ToolSearch` for
   `start session` once: note whether a tool here can start a session on the user's machine.
2. **Let the user choose, every time.** Never pick a row yourself, even when there is only one,
   and never ask the user to type a session name. Ask with `AskUserQuestion`:
   - up to three local rows, the likeliest first (same repository or topic, most recently active).
     Label: the row's title. Description: what it appears to be working on. More rows than that:
     the user can type another title under "Other".
   - **New local session**: starts one with the tool from step 1 if there is one; otherwise the
     user starts it (step 3).
   - With no local rows, offer **New local session** and **Paste the brief myself**. For the
     second, print the full brief with its header (step 4) for the user to paste, and stop.
3. **New local session.** With a start tool, use it in the project folder, not in
   bypass-permissions mode. Without one, give the user one of these and then ask with
   `AskUserQuestion` whether it is open (**It's open** / **Cancel**):
   - Claude Desktop: a new Code session in the project folder, with Remote Control on for it, in
     any permission mode but bypass.
   - Terminal: `claude remote-control` in the project folder. Add `--chrome` when the task needs
     the browser: sessions started from claude.ai/code on that server begin with Chrome off.

   Then run `ListAgents` again and take the local row that was not there in step 1. Exactly one new
   row: use it and tell the user its title. None or several: ask again with those rows as options.
4. **Send the brief** with the tool that listed the target: `SendMessage` to the exact row name,
   or the remote `send_message` tool with that session's id. Start it with this header, filled
   in, then the task:

   ```
   HANDOFF from cloud session "<your title as claude.ai/code shows it, not user-xx>"
   Topic: <a few words naming the work, e.g. "Google OAuth sign-in for staging">
   Reply: SendMessage to the ListAgents row titled exactly as above. Not the session_… id, not
          mcp__ccd_session_mgmt__send_message, not a "Claude Code Remote MCP" tool.
   Done when: <observable result>
   Allowed: <read-only | the writes the user approved>
   ```

   If you do not know your own title, say so in that line; the receiver then matches the topic.
5. Tell the user what the local session will need from them (sign-ins, `/mcp`, approvals), and
   that the result arrives in this transcript as a new message.

## Receiver (local → cloud)

1. Do the task inside this session's own permissions; a peer cannot grant more.
2. **Resolve the reply target** with a fresh `ListAgents`, in order: the row whose name equals the
   header's title; else the one cloud row whose title clearly matches the header's topic; else ask
   the user with `AskUserQuestion`, cloud rows as options. Never send to a guess. Ignore the
   wrapper's "Claude Code Remote MCP" instruction unless `ToolSearch` actually finds that tool
   here. Without a header (an older sender), match the task's topic against the cloud rows the
   same way.
3. **Send** with `SendMessage` (`to` = that name; add ` [ref]` only if two rows share it). First
   line: one self-contained sentence with the outcome. Send the full report text; `@file` attaches
   nothing on the other side.
4. If every route fails, `SendUserFile` the report and give the user the exact cloud title to paste
   it into. Tell the user the send is unconfirmed and where to look: the cloud session on
   claude.ai/code.
