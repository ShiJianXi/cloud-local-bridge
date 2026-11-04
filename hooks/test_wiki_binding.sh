#!/bin/sh
# Self-check for wiki-binding.sh: run `sh hooks/test_wiki_binding.sh` from the plugin root.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
export CLAUDE_WIKI_BINDINGS="$tmp/b"
unset CLAUDE_WIKI_KEY CLAUDE_ENV_FILE 2>/dev/null || true
cp "$(command -v sh)" "$tmp/node" # a stand-in host process that isn't named claude
s="$here/wiki-binding.sh"
fail() { echo "FAIL: $1"; exit 1; }

# One host process living through a conversation's whole life. ev <source> <session id> prints
# what the SessionStart hook injects; each result line is "<step>:<injected or ->". No command
# substitution inside: a forked subshell would look like another host process.
cat > "$tmp/life.sh" <<LIFE
ev() { echo "{\"session_id\":\"\$2\",\"source\":\"\$1\"}" | sh '$s' start > '$tmp/o'; printf '%s:' "\$3"; if [ -s '$tmp/o' ]; then cat '$tmp/o'; else echo -; fi; }
export CLAUDE_ENV_FILE='$tmp/env'
ev startup s1 startup
. '$tmp/env'
sh '$s' bind https://claude.ai/artifact/abc 'Billing' >/dev/null
ev compact s1 compact
ev clear s2 clear
ev compact s2 compact-after-clear
ev resume s9 resume-other
ev compact s9 compact-other
ev clear s10 clear-other
ev resume s2 resume-back
LIFE
out=$("$tmp/node" "$tmp/life.sh")
check() { echo "$out" | grep -q "^$1:$2" || fail "$1: expected $2, got: $(echo "$out" | grep "^$1:")"; }
check startup -
check compact 'orchestrator-wiki: you are the long-running Billing orchestrator.*artifact/abc'
check clear orchestrator-wiki
check compact-after-clear orchestrator-wiki
check resume-other -
check compact-other -
check clear-other -
check resume-back orchestrator-wiki

# Another host (another session) gets nothing.
out=$("$tmp/node" -c "echo '{\"session_id\":\"s2\",\"source\":\"compact\"}' | sh '$s' start")
[ -z "$out" ] || fail "another session got a wiki: $out"

# No usable ps (Git Bash): falls back to the session id, so compaction still works.
mkdir "$tmp/bin"; printf '#!/bin/sh\nexit 1\n' > "$tmp/bin/ps"; chmod +x "$tmp/bin/ps"
out=$(PATH="$tmp/bin:$PATH" sh -c "echo '{\"session_id\":\"w1\",\"source\":\"startup\"}' | sh '$s' start; CLAUDE_WIKI_KEY=s-w1 sh '$s' bind u2 W >/dev/null; echo '{\"session_id\":\"w1\",\"source\":\"compact\"}' | sh '$s' start")
echo "$out" | grep -q 'W orchestrator' || fail "session-id fallback failed: $out"

# Without the hook there's no session id: bind refuses instead of binding blind.
"$tmp/node" -c "sh '$s' bind u d" 2>/dev/null && fail "bind worked without the hook"

# Unbind removes it.
out=$("$tmp/node" -c "echo '{\"session_id\":\"u1\",\"source\":\"startup\"}' | sh '$s' start; sh '$s' bind u d >/dev/null; sh '$s' unbind; echo '{\"session_id\":\"u1\",\"source\":\"compact\"}' | sh '$s' start")
[ -z "$out" ] || fail "unbind left a binding: $out"
echo "ok"
