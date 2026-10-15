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

The skill gives both sides a fixed procedure. The sender puts a short header on the brief with its
own title and ticket key. The receiver uses that header to find the reply target, and asks you to
pick from a list only when that fails.

## Install

The skill has to be in both places: in the cloud session that delegates and in the local session
that does the work.

- **Cloud and local (recommended):** zip the `skills/cloud-local-bridge` folder and upload it in
  claude.ai → Customize → Skills. Account skills load in cloud sessions and sync to Desktop and
  signed-in terminal sessions.
- **Local only, as a Claude Code plugin:**

  ```
  /plugin install cloud-local-bridge --marketplace ShiJianXi/cloud-local-bridge
  ```

  Or `npx skills add ShiJianXi/cloud-local-bridge`, or copy `skills/cloud-local-bridge` into
  `~/.claude/skills/`. Cloud sessions don't load locally installed plugins or `~/.claude/skills/`.
- **One repository's cloud sessions:** commit the folder under that repo's `.claude/skills/`.

## Examples

1. **Cloud session needs a browser sign-in.** In a cloud session, type: "This needs an OAuth
   sign-in in my browser, delegate it to my local agent." The skill picks your open Desktop session
   (it asks you to choose if there are several) and sends the brief with a `HANDOFF` header that
   carries the cloud session's title and ticket key.
2. **Local session sends the result back.** The local session gets a
   `<cross-session-message from-session="session_…">`, does the task, then finds the cloud session
   in `ListAgents` by the title in the header and replies with `SendMessage`, so you don't have to
   name it.
3. **The cloud session was renamed.** No `ListAgents` row matches the header's title any more. The
   local session falls back to the cloud row whose title contains the ticket key, such as
   `ABC-123`. If none matches, it asks you to pick from the cloud sessions it can see, and does not
   send to a guess.

## Limits

- Delivery from a local session to a cloud session is never confirmed. Read the reply in the cloud
  session's transcript.
- A local session in bypass-permissions mode holds messages from cloud sessions, and Desktop drops
  them after 5 minutes.
- The tools a cloud session uses to list local sessions aren't documented, so the skill tells it to
  search for them before deciding there is no local session.

## License

MIT
