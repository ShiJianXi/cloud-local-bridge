# Privacy policy

Molt is a set of instruction files (`skills/`) for Claude Code plus one small shell
script (`hooks/wiki-binding.sh`). It has no servers, no MCP servers and no network calls of its own.

- **Collects:** nothing. The plugin's author receives no data from it.
- **Stores:** only on your own machine and your own claude.ai account. When you keep an
  orchestrator wiki, the script writes one line (the wiki's link and its domain name) to
  the plugin's own data folder (Claude Code's `CLAUDE_PLUGIN_DATA`). The plan boards and wikis themselves are private
  artifacts in your claude.ai account, written by Claude with Claude Code's built-in tools.
- **Sends:** nothing to any third party. It tells Claude to pass task briefs and results between
  your own Claude Code sessions with Claude Code's built-in `ListAgents` and `SendMessage` tools.
  Those messages are handled by Claude Code under Anthropic's privacy policy, not by this plugin.

Questions: open an issue at https://github.com/ShiJianXi/molt/issues.
