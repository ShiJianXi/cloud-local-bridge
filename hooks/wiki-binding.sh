#!/bin/sh
# Binds an orchestrator wiki to one running Claude Code process (orchestrator-wiki skill).
#   wiki-binding.sh bind <wiki url> <domain>   run by the skill through Bash
#   wiki-binding.sh key | show | unbind        run by the skill through Bash
#   wiki-binding.sh inject                     run by the SessionStart hook (compact, clear)
# The key is the nearest ancestor process named claude plus its start time. Compaction and /clear
# keep that process, so the binding follows them; any other session is another process and gets
# nothing. A restarted process loses the binding on purpose: the skill then finds the wiki itself.
dir="${CLAUDE_WIKI_BINDINGS:-$HOME/.claude/orchestrator-wiki/bindings}"

key() {
  p=$$ i=0
  while [ "$p" -gt 1 ] && [ $i -lt 20 ]; do
    case "$(basename "$(ps -o comm= -p "$p" 2>/dev/null)" 2>/dev/null)" in
      claude|claude.exe|Claude) echo "$p-$(ps -o lstart= -p "$p" | tr -cd '[:alnum:]')"; return 0 ;;
    esac
    p=$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ') i=$((i + 1))
    [ -n "$p" ] || return 1
  done
  return 1
}

k=$(key) || exit 0 # no Claude process above us: bind nothing, inject nothing
f="$dir/$k"
case "$1" in
  bind)
    [ -n "$2" ] && [ -n "$3" ] || { echo "usage: $0 bind <wiki url> <domain>" >&2; exit 2; }
    mkdir -p "$dir" && printf '%s\t%s\n' "$2" "$3" > "$f" && echo "bound $3 wiki to this session" ;;
  key) echo "$k" ;;
  show) [ -f "$f" ] && cat "$f" ;;
  unbind) rm -f "$f" ;;
  inject)
    cat > /dev/null # hook input, unused
    [ -f "$f" ] || exit 0
    IFS="$(printf '\t')" read -r url domain < "$f"
    echo "orchestrator-wiki: you are the long-running $domain orchestrator. Before anything else, load the orchestrator-wiki skill and follow its Resume steps with your wiki at $url. Your earlier context was compacted or cleared; the wiki, not your memory, is the source of truth." ;;
  *) echo "usage: $0 bind|key|show|unbind|inject" >&2; exit 2 ;;
esac
