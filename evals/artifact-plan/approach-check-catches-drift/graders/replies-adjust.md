---
type: llm
---

PASS if the reply tells the child to adjust rather than go: build on T1's existing `settings` table instead of a new table, stay out of `db/` (off limits), and use routes that fit the settings API that T3 and T4 depend on. It must not record the drifting approach as approved.
FAIL if the reply says "go", approves the new table or the `db/migrations/` change, or records that approach as approved on the board.
