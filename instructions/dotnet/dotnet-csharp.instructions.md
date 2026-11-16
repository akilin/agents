---
applyTo: '**/*.cs'
---
## Instructions
- Use `NodaTime` types for dates/times.
- **Bug fix → write a failing regression test first** that reproduces the bug, see it fail, then fix.

### Comments
Default to no comment. Before writing one, try to make the code say it instead: a more descriptive variable name, or an extracted method with a descriptive name.

Add a comment only when a future reader would otherwise ask "why is it done this way?", for example:
- a trade-off: there were genuine alternatives and you picked one for specific reasons
- a workaround for an external bug or constraint (link the issue if there is one)
- an invariant or assumption the code relies on but does not enforce

Write the why, not the what. Do not write comments that:
- restate what the code does
- describe the change you just made ("added null check", "fixed X"); that belongs in the commit message
