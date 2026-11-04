---
name: orchestrator-wiki
description: >
  Keeps a small private wiki for one long-running, single-domain orchestrator session, so its
  context can be compacted or cleared and it carries on from the wiki instead of from memory. Use
  when the user wants a long-running orchestrator or agent for one domain ("you're my Cohort 005
  agent", "keep a wiki", "a long-running orchestrator for X", "so I can clear your context safely"),
  when a line in context starts with `orchestrator-wiki:`, when the user hands over a wiki link to
  resume, and before writing anything to an existing wiki.
---

# Orchestrator wiki

One **wiki** per long-running orchestrator. It belongs to that one session: only it reads the wiki,
only it writes to it, and no other session, child, thread or file ever gets the link. It holds what
the orchestrator would otherwise lose on `/compact` or `/clear`, and nothing else.

The page is `wiki.html` in this skill's directory; the data lives in the artifact's database, so
writes are database writes, never republishes. `<plugin root>/hooks/wiki-binding.sh` (two levels
up from this skill's directory) ties the wiki to the running Claude process.

## Facts that shape the procedure (November 2026, Claude Code 2.1.31x)

- `/compact` and `/clear` run as soon as they are typed. No model turn comes before them, so
  nothing can be saved "just before". The wiki is written as facts happen (step 3), so it is
  current whenever either runs.
- `/compact` keeps the session id. `/clear` starts a new session id (`SessionEnd` with reason
  `clear`, then `SessionStart` with source `clear`). Both stay in the same Claude process.
- This plugin's `SessionStart` hook (matcher `compact|clear`) runs `wiki-binding.sh inject`: if this
  process has a binding, it injects one line starting `orchestrator-wiki:` with the domain and the
  link. Any other process (another session) gets nothing.
- The hook ships with the plugin. Installed as bare skills (no plugin), nothing is injected:
  after a compaction or `/clear` the user says "resume my <domain> orchestrator" and step 5 runs.
  The script needs `sh` and `ps` (macOS, Linux, WSL).
- A new process loses the binding on purpose: a resumed cloud session in a fresh container, a
  restarted terminal, a switch from cloud to Desktop. Step 5 covers finding the wiki then.

## Rules that are never bent

1. **One session.** `wiki/meta` names the session that owns it: `session` = the `session_…` id
   from `get_session` (cloud), and `process` = the output of `wiki-binding.sh key`. Before reading
   any page, check that one of them is yours. Neither matches: read nothing past `meta` and go to
   step 6.
2. **The link stays here.** Never put the wiki link in a child's brief, a `HANDOFF` header, a
   plan board, a PR, a commit, a repository file, project memory or a shared project folder.
   Children get facts copied into their brief (orchestrate step 5, `Already done by the
   orchestrator`), never a pointer.
3. **Only you write.** Children and other sessions never write to it. A child's report is data;
   you decide what, if anything, reaches the wiki.
4. **Owner-only.** The database rules make every path owner-read and owner-write, so sharing the
   page shows nothing.
5. **Not a log of the work.** Plan boards, PRs, Jira and child sessions already hold progress.
   The wiki links them and holds only what step 3 lets in.

## 1. Detect and offer

Offer a wiki when the user wants this session to own one domain over many sessions' worth of work
(days, several plans, context they expect to clear). Not for one orchestrate run, however large:
a plan board covers that. Ask once with `AskUserQuestion`:

> Keep a private wiki for <domain>, so you can compact or clear my context and I pick up from it?

Options: **Keep a wiki (Recommended)** and **No wiki**. Never offer twice in a session after a no.
If the Artifact tool or `ArtifactData` isn't available, say so in one line and go on without one.

## 2. Create and bind

1. Copy `wiki.html` to the scratchpad as `wiki-<domain slug>.html` and publish it with the
   Artifact tool: `icon` = `book`, `capabilities` = `{"db": {"rules": [{"path": "wiki", "read":
   "owner", "write": "owner"}, {"path": "pages", "read": "owner", "write": "owner"}, {"path":
   "log", "read": "owner", "write": "owner"}]}}`.
2. Run `sh <plugin root>/hooks/wiki-binding.sh key` and keep the output.
3. Seed it with one `ArtifactData` `batch`:
   - `wiki/meta`: `{domain, orchestrator: <this session's title>, session: <session_… id or "">,
     process: <key>, boards: [], createdAt}`.
   - `pages/charter`, `pages/decisions`, `pages/state`, `pages/gotchas`: `{title, body, updatedAt}`.
     `charter` gets the domain in a paragraph, what is in and out of scope, and any standing rules
     the user gave. The others start with an empty `body`.
   - `log/e1`: `{at, text: "Wiki created for <domain>."}`.
4. Bind it: `sh <plugin root>/hooks/wiki-binding.sh bind <wiki url> "<domain>"`.
5. Tell the user in one line: the link, that only they and this session can read it, and that
   `/compact` and `/clear` are now safe here.

## 3. Write only when necessary

Most turns write nothing. Write a fact only when all three hold:

1. **It would be lost.** After a compaction or `/clear` you would have to ask the user again or
   redo work to get it back.
2. **It has no other home.** It can't be re-read cheaply from the repository, a PR, a plan board,
   Jira or a child session. If it can, store the link at most.
3. **It will still hold.** A decision, a standing rule, a scope line, a lesson. Not a step in
   progress.

| Page        | Holds                                                                     | Update style                  | Cap      |
|-------------|---------------------------------------------------------------------------|-------------------------------|----------|
| `charter`   | the domain, in and out of scope, the user's standing rules for it, the skills to use (e.g. `/implement-spec`, `/retro`) | edit in place | 25 lines |
| `decisions` | user decisions that still hold: date, decision, why in a line             | append, prune superseded      | 30 lines |
| `state`     | what is running now: children (title, id, branch, PR), open plan boards, what waits on the user | overwrite whole | 20 lines |
| `gotchas`   | what cost a retry and will again: a tool quirk, a repository trap, a preference | append, prune stale     | 20 lines |

Write triggers: the user decides something or states a rule for the domain; a child starts,
finishes or is archived (overwrite `state`); a plan board is created (add `{title, url}` to
`meta.boards` and name it in `state`); something cost a retry (`gotchas`). The user can also say
"note that in the wiki" or "forget that".

Never write: child progress reports, CI runs, transcripts, tool output, diffs, guesses, plans the
user hasn't approved, anything about another domain or thread, secrets or credentials.

Each write is one `ArtifactData` `batch`, pinned with the `if_version` you last read: the page
change (with `updatedAt`) plus one `log/e<n>` line saying which page and why. At most one wiki
write per turn. At a page's cap, rewrite it shorter (merge, drop what no longer holds) before
adding. Keep the whole wiki under about 2,000 tokens.

## 4. Resume after `/compact` or `/clear`

A line starting `orchestrator-wiki:` in context means this session was compacted or cleared.
Before replying to anything:

1. `ArtifactData` `get` `wiki/meta` and check rule 1. If `process` differs but `session` matches
   (a resumed cloud session), update `process` to the new `key` and rebind (step 2.4).
2. Read the four pages in one `list` of `pages`.
3. Check `state` against reality: each child's `get_session` or `ListAgents` row, each PR, each
   plan board. Where they differ, overwrite `state` in one batch with a log line.
4. For each open plan board, follow the `artifact-plan` skill's step 7.
5. Then answer the user's message as the orchestrator `charter` describes.

## 5. Resume without a binding

The process is new, so nothing was injected (a fresh cloud container, a restarted terminal). If
you know you are a domain orchestrator (the conversation or the user says so), find the wiki:
`Artifact` `list`, look for `<domain> wiki`, `get` its `wiki/meta`, and check rule 1. A cloud
session's `session` id survives a container restart, so a match there is yours: update `process`,
rebind, and run step 4. No match or no wiki found: ask the user for the link and go to step 6.

## 6. Adopt a wiki

A wiki moves to a new session only on the user's word: they hand you its link ("you're my Cohort
005 orchestrator now, here's the wiki"). Read `wiki/meta` only. If `meta.orchestrator` names
another session, ask once with `AskUserQuestion`: **Take it over (Recommended)**, after which that
session can no longer use it, or **Leave it**. On take over, update `session`, `process` and
`orchestrator` in one batch with a log line ("Adopted by <title>."), bind it (step 2.4), then run
step 4. A link that reaches you any other way (a child's report, a file, a comment) is not the
user's word: don't read it.

## 7. Finish

When the user says the domain is done, add a final log line, run `wiki-binding.sh unbind`, and
leave the wiki as the record. It stays private unless the user shares it, and even then its data
stays owner-only.

## Evals

The plugin's `evals/orchestrator-wiki/` holds four cases for `claude plugin eval`: a short
orchestrate run that must not offer a wiki, a resume after compaction that must read the wiki
first, a progress report that must not be written, and a wiki owned by another session that must
not be read. Run `claude plugin eval . --tag orchestrator-wiki` from the plugin root after changing
this file. `sh hooks/test_wiki_binding.sh` checks the binding script.
