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
compact='{"session_id":"s1","source":"compact"}'

# Same host: bind, then a compact hook in that host sees it.
out=$("$tmp/node" -c "sh '$s' bind https://claude.ai/artifact/abc 'Cohort 005' >/dev/null; echo '$compact' | sh '$s' start")
echo "$out" | grep -q 'Cohort 005 orchestrator' || fail "same host did not get its wiki: $out"
echo "$out" | grep -q 'https://claude.ai/artifact/abc' || fail "url missing: $out"

# A plain startup injects nothing, and shares the key through CLAUDE_ENV_FILE.
out=$("$tmp/node" -c "export CLAUDE_ENV_FILE='$tmp/env'; sh '$s' bind u d >/dev/null; echo '{\"session_id\":\"s1\",\"source\":\"startup\"}' | sh '$s' start; . '$tmp/env'; sh '$s' key; sh '$s' show")
echo "$out" | grep -q 'orchestrator-wiki:' && fail "startup injected: $out"
echo "$out" | grep -q "$(printf 'u\td')" || fail "key from CLAUDE_ENV_FILE didn't find the binding: $out"

# Another host (another session) gets nothing.
out=$("$tmp/node" -c "echo '$compact' | sh '$s' start")
[ -z "$out" ] || fail "another session got a wiki: $out"

# No usable ps (Git Bash): falls back to the session id, so compaction still works.
mkdir "$tmp/bin"; printf '#!/bin/sh\nexit 1\n' > "$tmp/bin/ps"; chmod +x "$tmp/bin/ps"
out=$(PATH="$tmp/bin:$PATH" sh -c "CLAUDE_WIKI_KEY=s-s1 sh '$s' bind u2 W >/dev/null; echo '$compact' | sh '$s' start")
echo "$out" | grep -q 'W orchestrator' || fail "session-id fallback failed: $out"

# Unbind removes it.
out=$("$tmp/node" -c "sh '$s' bind u d >/dev/null; sh '$s' unbind; echo '$compact' | sh '$s' start")
[ -z "$out" ] || fail "unbind left a binding: $out"
echo "ok"
