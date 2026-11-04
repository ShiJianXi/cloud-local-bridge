#!/bin/sh
# Self-check for wiki-binding.sh: run `sh hooks/test_wiki_binding.sh` from the plugin root.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
export CLAUDE_WIKI_BINDINGS="$tmp/b"
cp "$(command -v sh)" "$tmp/claude" # a stand-in process named claude
s="$here/wiki-binding.sh"
fail() { echo "FAIL: $1"; exit 1; }

# Same process: bind, then a hook in that process sees it (what compaction and /clear do).
out=$("$tmp/claude" -c "sh '$s' bind https://claude.ai/artifact/abc 'Cohort 005' >/dev/null; echo '{}' | sh '$s' inject")
echo "$out" | grep -q 'Cohort 005 orchestrator' || fail "same process did not get its wiki: $out"
echo "$out" | grep -q 'https://claude.ai/artifact/abc' || fail "url missing: $out"

# Another process (another session) gets nothing.
out=$("$tmp/claude" -c "echo '{}' | sh '$s' inject")
[ -z "$out" ] || fail "another session got a wiki: $out"

# Unbind removes it.
out=$("$tmp/claude" -c "sh '$s' bind u d >/dev/null; sh '$s' unbind; echo '{}' | sh '$s' inject")
[ -z "$out" ] || fail "unbind left a binding: $out"
echo "ok"
