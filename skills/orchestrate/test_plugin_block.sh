#!/bin/sh
# Runs the brief's plugin block from SKILL.md against this repo with a throwaway HOME.
set -e
dir=$(cd "$(dirname "$0")" && pwd); repo=$(cd "$dir/../.." && pwd)
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
sed -n '/^   ```sh$/,/^   ```$/p' "$dir/SKILL.md" | sed '1d;$d;s/^   //' > "$tmp/block.sh"
HOME="$tmp" p=molt r="$repo" sh "$tmp/block.sh" > /dev/null
for s in artifact-plan cloud-local-bridge orchestrate orchestrator-wiki; do
  [ -f "$tmp/.claude/skills/$s/SKILL.md" ] || { echo "FAIL: $s not linked"; exit 1; }
done
mkdir -p "$tmp/.claude/plugins/synced/x/molt"; rm -rf "$tmp/.claude/skills"
HOME="$tmp" p=molt r="$repo" sh "$tmp/block.sh" > /dev/null
[ ! -e "$tmp/.claude/skills" ] || { echo "FAIL: linked a plugin that was already synced"; exit 1; }
echo "plugin block OK"
