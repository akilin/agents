---
description: Use when writing integration tests
applyTo: 'tests/integration/**'
---
## Instructions
- Inherit from `TestBase` and use `WebAppFactory`.
- Use `CreateClientFor` for authenticated requests and `Factory.CreateClient()` for anonymous requests.
- Use `TestConstants` for shared test credentials.
- Each test must be self-contained: create the data it needs, assert, and not depend on test ordering.
- Use `TestContext.Current.CancellationToken` through the existing `CT` property in integration tests and pass it to HTTP/content APIs that accept a token.
- Use `ExecuteDbOperations` for direct database setup or assertions.
- Use `OutboxEmails` when a test needs to inspect links generated into queued email bodies.
- For expected API failures, use `response.ShouldBeErrorResponse().WithHttpStatusCode(...).WithErrorCode(...)` from `AssertExtensions`.
