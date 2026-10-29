---
description: Use when writing tests in C#
applyTo: 'tests/**/*.cs'
---
## Test Layout
- `tests/unit-tests`: xUnit v3 unit tests.
- `tests/integration`: integration tests based on `WebApplicationFactory<Program>`.
- `tests/e2e`: Playwright (xUnit v3) end-to-end.
- `tests/perf`: performance-test scripts and request payloads.

## Instructions
- Organize tests by the class and behavior under test. Name tests for observable behavior, not implementation details.
- Separate arrange, act, and assert phases with blank lines.
- Use strict mocks when a unit test depends on collaborators.
- Use NodaTime-aware assertions for time values. Keep tolerances explicit, such as `BeCloseTo(Instant.Now, TimeSpan.FromSeconds(5))`, when testing generated timestamps.
