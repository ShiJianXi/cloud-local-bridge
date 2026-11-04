#!/bin/sh
# Binds an orchestrator wiki to one running Claude Code session host (orchestrator-wiki skill).
#   wiki-binding.sh start                      SessionStart hook, every source: shares the key
#                                              with Bash through CLAUDE_ENV_FILE and, after
#                                              compact or clear, points Claude at its wiki
#   wiki-binding.sh bind <wiki url> <domain>   run by the skill through Bash
#   wiki-binding.sh key | show | unbind        run by the skill through Bash
# The key is the host process (the first ancestor that isn't a shell, whatever its name: claude,
# node, the Desktop app) plus its start time. /compact and /clear keep that process, so the binding
# follows them. The binding also stores its conversation's session id, so another conversation
# opened in the same process with /resume gets nothing; another session is another process.
# Where ps can't walk the tree (Git Bash on Windows), the key falls back to the session id:
# compaction still works, /clear then needs a manual resume. A restarted host loses the binding
# on purpose.
# Bindings live in the plugin's own data folder (CLAUDE_PLUGIN_DATA, set for hooks); the hook
# hands that path to Bash with the key. Without it they go to the temp folder, which is enough:
# a binding only lives as long as its host process anyway.
dir="${CLAUDE_WIKI_BINDINGS:-${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}/molt}/orchestrator-wiki-bindings}"

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
    sid=$(printf '%s' "$input" | field session_id)
    k=$(host) || k="s-$sid"
    [ "$k" = "s-" ] && exit 0
    [ -n "$CLAUDE_ENV_FILE" ] && printf "export CLAUDE_WIKI_KEY='%s' CLAUDE_WIKI_BINDINGS='%s'\n" "$k" "$dir" >> "$CLAUDE_ENV_FILE"
    f="$dir/$k" prev=$(cat "$dir/$k.current" 2>/dev/null)
    mkdir -p "$dir" && printf '%s\n' "$sid" > "$dir/$k.current"
    [ -f "$f" ] || exit 0
    IFS="$(printf '\t')" read -r url domain owner < "$f"
    # The binding follows its own conversation only: through compaction (same id), through /clear
    # (new id, but the conversation cleared was the bound one), and back to it with /resume.
    # A different conversation in the same process (/resume to another one) gets nothing.
    case "$(printf '%s' "$input" | field source)" in
      compact|resume) [ "$sid" = "$owner" ] || exit 0 ;;
      clear) [ "$prev" = "$owner" ] || exit 0; printf '%s\t%s\t%s\n' "$url" "$domain" "$sid" > "$f" ;;
      *) exit 0 ;;
    esac
    echo "orchestrator-wiki: you are the long-running $domain orchestrator. Before anything else, load the orchestrator-wiki skill and follow its Resume steps with your wiki at $url. Your earlier context was compacted or cleared; the wiki, not your memory, is the source of truth."
    exit 0 ;;
esac

k="${CLAUDE_WIKI_KEY:-$(host)}"
[ -n "$k" ] || { echo "No session key: this plugin's SessionStart hook didn't run here. Bind skipped; resume by hand after /compact or /clear." >&2; exit 1; }
f="$dir/$k"
case "$1" in
  bind)
    [ -n "$2" ] && [ -n "$3" ] || { echo "usage: $0 bind <wiki url> <domain>" >&2; exit 2; }
    sid=$(cat "$f.current" 2>/dev/null)
    [ -n "$sid" ] || { echo "No session id: this plugin's SessionStart hook didn't run here. Bind skipped; resume by hand after /compact or /clear." >&2; exit 1; }
    printf '%s\t%s\t%s\n' "$2" "$3" "$sid" > "$f" && echo "bound $3 wiki to this conversation" ;;
  key) echo "$k" ;;
  show) [ -f "$f" ] && cat "$f" ;;
  unbind) rm -f "$f" ;;
  *) echo "usage: $0 start|bind|key|show|unbind" >&2; exit 2 ;;
esac
