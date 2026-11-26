---
description: Default to test-driven development for features and bug fixes
applyTo: '**'
---
### Test-Driven Development (TDD)
Default to TDD for features and bug fixes: write a failing test first, see it fail for the expected reason, then write the code that makes it pass. For a bug fix, the test reproduces the bug.

Exceptions:
- throwaway code: prototypes, spikes, one-off scripts
- no behavior change: refactors, renames, moves, formatting
- no logic to test: docs, configuration, dependency bumps, generated code
- results judged by eye: layout, styling, copy
