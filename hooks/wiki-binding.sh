#!/bin/sh
# Binds an orchestrator wiki to one running Claude Code session host (orchestrator-wiki skill).
#   wiki-binding.sh start                      SessionStart hook, every source: shares the key
#                                              with Bash through CLAUDE_ENV_FILE and, after
#                                              compact or clear, points Claude at its wiki
#   wiki-binding.sh bind <wiki url> <domain>   run by the skill through Bash
#   wiki-binding.sh key | show | unbind        run by the skill through Bash
# The key is the host process (the first ancestor that isn't a shell, whatever its name: claude,
# node, the Desktop app) plus its start time. /compact and /clear keep that process, so the binding
# follows them; another session is another process and gets nothing. Where ps can't walk the tree
# (Git Bash on Windows), the key falls back to the session id: compaction still works, /clear then
# needs a manual resume. A restarted host loses the binding on purpose.
dir="${CLAUDE_WIKI_BINDINGS:-$HOME/.claude/orchestrator-wiki/bindings}"

host() {
  p=$$ i=0
  while [ -n "$p" ] && [ "$p" -gt 1 ] && [ $i -lt 20 ]; do
    c=$(ps -o comm= -p "$p" 2>/dev/null) && [ -n "$c" ] || return 1
    case "$(basename "$c")" in
      sh|bash|dash|zsh|ash|ksh|mksh|-*|sh.exe|bash.exe) ;;
      *) echo "$p-$(ps -o lstart= -p "$p" | tr -cd '[:alnum:]')"; return 0 ;;
    esac
    p=$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ') i=$((i + 1))
  done
  return 1
}
field() { sed -n "s/.*\"$1\" *: *\"\([^\"]*\)\".*/\1/p"; }

case "$1" in
  start)
    input=$(cat)
    k=$(host) || k="s-$(printf '%s' "$input" | field session_id)"
    [ "$k" = "s-" ] && exit 0
    [ -n "$CLAUDE_ENV_FILE" ] && echo "export CLAUDE_WIKI_KEY='$k'" >> "$CLAUDE_ENV_FILE"
    case "$(printf '%s' "$input" | field source)" in compact|clear) ;; *) exit 0 ;; esac
    [ -f "$dir/$k" ] || exit 0
    IFS="$(printf '\t')" read -r url domain < "$dir/$k"
    echo "orchestrator-wiki: you are the long-running $domain orchestrator. Before anything else, load the orchestrator-wiki skill and follow its Resume steps with your wiki at $url. Your earlier context was compacted or cleared; the wiki, not your memory, is the source of truth."
    exit 0 ;;
esac

k="${CLAUDE_WIKI_KEY:-$(host)}"
[ -n "$k" ] || { echo "No session key: this plugin's SessionStart hook didn't run here. Bind skipped; resume by hand after /compact or /clear." >&2; exit 1; }
f="$dir/$k"
case "$1" in
  bind)
    [ -n "$2" ] && [ -n "$3" ] || { echo "usage: $0 bind <wiki url> <domain>" >&2; exit 2; }
    mkdir -p "$dir" && printf '%s\t%s\n' "$2" "$3" > "$f" && echo "bound $3 wiki to this session" ;;
  key) echo "$k" ;;
  show) [ -f "$f" ] && cat "$f" ;;
  unbind) rm -f "$f" ;;
  *) echo "usage: $0 start|bind|key|show|unbind" >&2; exit 2 ;;
esac
