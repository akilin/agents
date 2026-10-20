---
description: Use the token-efficient test runner when running tests
applyTo: '**'
---

## Running tests

- Run tests from the repository root with `./test.sh <unit|integration|e2e> [filter]`.
- Do not invoke `dotnet test` directly.
- Omit `filter` to run the entire selected test project.
- To run one test class, pass its exact fully qualified path: `./test.sh unit Namespace.Class`.
- To run one test method, pass its exact fully qualified path: `./test.sh unit Namespace.Class.Method`.
- Successful runs are intentionally silent; exit code `0` means all selected tests passed.
