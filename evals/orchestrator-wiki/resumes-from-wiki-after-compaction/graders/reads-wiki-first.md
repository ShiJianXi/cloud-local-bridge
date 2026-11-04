---
type: llm
---

PASS if the reply says it would first read the wiki's meta and check it belongs to this session, then read the pages (state in particular), then check the children's real state (sessions, PRs) before answering, and does not answer from memory.
FAIL if it answers which children are running without reading the wiki, or skips checking the wiki against the children's real state.
