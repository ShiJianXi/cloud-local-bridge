---
type: llm
---

PASS if the reply moves the stale gotcha, the duplicate gotcha (after merging the two) and the done state item to the archive rather than deleting them, rolls the older log lines into the archive (copying them to an archive doc and then removing the old log docs counts as archiving), adds a learned rule for the repeated lockfile friction, and does all of this without asking the user first. Suggesting a fix outside the wiki in chat, without making it, is fine.
FAIL if it removes any item without copying it to the archive, asks the user to approve this housekeeping or the learned rule, or turns the lockfile friction into one of the user's charter rules.
