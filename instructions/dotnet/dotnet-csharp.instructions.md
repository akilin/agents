---
applyTo: '**/*.cs'
---
## Instructions
- Use `NodaTime` types for dates/times.
- **Bug fix → write a failing regression test first** that reproduces the bug, see it fail, then fix.

### Comments
Most changes should add no comments. A comment should hold something the code cannot say.
Anything a competent reader could work out from the code, the names and the rest of the repo does not get one.

Before writing a comment, try to make the code say it instead: a more descriptive name, or an extracted method with a descriptive name.

Write a comment only when a future reader would otherwise ask "why is it done this way?" and could not answer it from the code: it would look wrong, unnecessary or improvable to someone who doesn't know what you know, so that they might "fix" it and break something. The comment gives that reason, not a description of what the code does. In practice that is one of:
- a trade-off: there were genuine alternatives, a reader could reasonably have picked the other one, and you chose this one for specific reasons. Name the alternative and why it lost: "retrying the whole batch instead of only the failed items: the handler is idempotent, and tracking failures per item would need extra state"
- an obvious approach deliberately not taken: "no cancellation token here: the payment is already captured, so this write has to finish even during shutdown"
- a workaround for a bug or limitation in a framework, library or external service. Link the issue, and say when the workaround can be removed if you know: "workaround for <issue link>: the driver ignores the command timeout on pooled connections. Remove after upgrading to a version with the fix"
- external behavior that contradicts the types or the docs: "the SDK declares this non-nullable, but the API returns null when <condition>"
- a known limitation or shortcut being accepted. Say where it stops working: "loads every row into memory: fine for the few hundred we have, needs paging if the table grows"
- a link to the source of copied code or of a non-obvious constant
