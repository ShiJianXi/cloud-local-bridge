---
type: llm
---

PASS if the reply lists the five tasks with their dependencies (the API waits on the table, the page and the tests wait on the API, the docs wait on the page) AND either offers to track them on a plan board and waits for a yes, or says in one line that the plan board can't be created in this session and carries on without one.
FAIL if the dependencies are missing or wrong, if it never mentions a plan board, or if it claims to have published a board or started sessions.
