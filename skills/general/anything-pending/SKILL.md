---
name: anything-pending
description: List everything in the current session that is waiting on the user - unanswered questions, decisions, approvals, and actions only they can take.
disable-model-invocation: true
---

List every unresolved item in this conversation (sub-agent reports included) that needs the user:

- pending questions or decisions
- approvals you are waiting on before acting
- actions only they can take (login, secret, command to run, denied tool call)
- assumptions you made for them that would change the outcome if wrong

Skip anything answered, moot, or that you can look up yourself. If nothing is pending, say so in one line.
Don't act on any item until the user answers.
