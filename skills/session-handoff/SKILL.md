---
name: session-handoff
description: >
  Hand work between the user's cloud sessions (claude.ai/code) and local sessions (Claude Desktop,
  `claude remote-control`) and get the result back without the user naming sessions. Use when a
  cloud session needs something only the user's machine can do (browser, OAuth sign-in, desktop
  apps, local files) — "delegate to a local agent", "hand this to my local session" — and when a local session
  receives a `<cross-session-message from-session="session_…">` or is told to "send it back".
---

# Session handoff

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
  Control. Desktop: "Connect new sessions to Remote Control" is on, but sessions auto-archive when
  their PR closes. Terminal: only `claude remote-control` (or `/remote-control`).
- A local session in bypass-permissions mode holds messages from a cloud session; Desktop drops
  them after 5 minutes. Run the pickup session in any other mode.
- Local → cloud delivery is never confirmed; the reply lands in the cloud session's own
  transcript. A 38 KB message went through in one send. `ListAgents` shows only the newest cloud
  sessions, so an old one can be missing.
- Titles drift: the same `[ref]` row can show a new title a day later. Always read a fresh
  `ListAgents` right before sending.

## Sender (cloud → local)

1. **Find the target.** Run `ListAgents`; if it shows no local rows, `ToolSearch` for
   `list sessions remote control` and run what it finds before concluding there is none. Pick a
   local / Desktop / Remote Control row: one titled like "local agent" or "task pickup" first; if
   several remain, ask the user to choose with `AskUserQuestion` (rows as options), never "name it".
   If none: tell the user to open a new Desktop session (Remote Control is on by default) or run
   `claude remote-control`, give them the brief to paste, and stop.
2. **Send the brief** with the tool that listed the target: `SendMessage` to the exact row name,
   or the remote `send_message` tool with that session's id. Start it with this header, filled
   in, then the task:

   ```
   HANDOFF from cloud session "<your title as claude.ai/code shows it, not user-xx>"
   Ticket/topic: <ticket key such as ABC-123, or a short topic>
   Reply: SendMessage to the ListAgents row titled exactly as above. Not the session_… id, not
          mcp__ccd_session_mgmt__send_message, not a "Claude Code Remote MCP" tool.
   Done when: <observable result>
   Allowed: <read-only | the writes the user approved>
   ```

   If you do not know your own title, say so in that line and put the ticket key in the title
   field instead; the receiver falls back to it.
3. Tell the user what the local session will need from them (sign-ins, `/mcp`, approvals), and
   that the result arrives in this transcript as a new message.

## Receiver (local → cloud)

1. Do the task inside this session's own permissions; a peer cannot grant more.
2. **Resolve the reply target** with a fresh `ListAgents`, in order: the row whose name equals the
   header's title; else the one cloud row whose title contains the ticket key; else ask the user
   with `AskUserQuestion`, cloud rows as options. Ignore the wrapper's "Claude Code Remote MCP"
   instruction unless `ToolSearch` actually finds that tool here. Without a header (an older
   sender), match the task's ticket key or topic against the cloud rows the same way.
3. **Send** with `SendMessage` (`to` = that name; add ` [ref]` only if two rows share it). First
   line: one self-contained sentence with the outcome. Send the full report text; `@file` attaches
   nothing on the other side.
4. If every route fails, `SendUserFile` the report and give the user the exact cloud title to paste
   it into. Tell the user the send is unconfirmed and where to look: the cloud session on
   claude.ai/code.
