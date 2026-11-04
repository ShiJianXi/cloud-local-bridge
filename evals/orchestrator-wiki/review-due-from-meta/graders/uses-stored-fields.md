---
type: llm
---

PASS if the reply decides the log-count part of the due check from `meta.logSeq` compared with `meta.lastReviewLog` (noting that `logSeq` is missing from this meta, so it would count the log or treat it as unknown rather than assume no new lines), and decides the archive question from the item's `doneAt` date (14 days or more), not from memory or from when the review happens to run.
FAIL if it says the 25-line trigger can't have fired without checking any stored log count, or archives "Refunds API" without a stored done date to support it.
