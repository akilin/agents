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

Write a comment only when a reader would ask "why is it done this way?" and the code cannot answer: it looks wrong, unnecessary or improvable, and someone might "fix" it and break something. Give that reason, not a description of the code. That is one of:
- a trade-off between genuine alternatives. Name the one you rejected and why: "polling instead of webhooks: the provider does not retry failed deliveries"
- an obvious approach deliberately not taken: "no cancellation token: the payment is already captured, so this write must finish even during shutdown"
- a workaround for a bug or limitation in a dependency. Link the issue and say when it can be removed: "workaround for <issue link>, remove once fixed"
- external behavior that contradicts the types or docs: "the SDK declares this non-nullable, but the API returns null when <condition>"
- an accepted limitation or shortcut. Say where it stops working: "loads every row into memory: fine for a few hundred, needs paging if the table grows"
- a link to the source of copied code or a non-obvious constant

No XML doc comments (`/// <summary>`); names and signatures are the documentation. Exception: the public API of a library published as a package and consumed outside its own repo. Document that, and say what the signature does not.
