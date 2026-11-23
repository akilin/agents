---
description: When and how to write code comments
applyTo: '**'
---
## Comments
Default to no comments. Anything a competent reader could work out from the code, the names and the rest of the repo does not get one. If something needs explaining, first try a more descriptive name or an extracted, well-named method.

Write a comment only when a reader would ask "why is it done this way?" and the code cannot answer: it looks wrong, unnecessary or improvable, and someone might "fix" it and break something. Give that reason, not a description of the code. It is one of:
- an alternative or obvious approach deliberately not taken. Name it and say why: "no cancellation token: the payment is already captured, so this write must finish even during shutdown"
- a workaround for a dependency bug or limitation. Link the issue and say when it can go: "workaround for <issue link>, remove once fixed"
- external behavior that contradicts the types or docs: "the SDK declares this non-nullable, but the API returns null when <condition>"
- an accepted limitation or shortcut: "loads every row: ok for now, needs paging if the table grows"
- a link to the source of copied code or a non-obvious constant

No doc comments (XML docs, JSDoc, docstrings); names and signatures are the documentation. Exception: the public API of a package consumed outside its own repo. Document that, and say what the signature does not.
