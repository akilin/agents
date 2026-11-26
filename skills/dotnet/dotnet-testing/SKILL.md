---
name: dotnet-testing
description: Writes and reviews .NET unit and integration tests. Test level selection, naming, file structure, test doubles, test data and assertions. Use when adding, changing, or reviewing tests in C# projects, or when the user asks for tests for a feature or bug fix.
---

# .NET testing

Before writing or reviewing unit tests, read [unit-tests.md](unit-tests.md).

## Core Rules
- Never weaken, skip, or delete a test, or change its expected values, to make failing test pass without the user's confirmation.
- Never disable parallelization or add retries to hide flakiness.
- Coverage is not a goal. Don't add tests just to raise it.

## Test Cases

Always cover:
- Happy path first.
- Every branch and error path.
- Edge cases **only where the code treats them differently** or the input's domain makes them likely, e.g.:
  - strings → `null`, empty, whitespace;
  - numeric limits → just below / at / just above the boundary;
  - collections → empty, single element, duplicates.

## Test Type Selection

Test at the lowest level that can verify the behavior:
- **Unit tests**: pure domain logic, field validation, permission checks, branching behavior that does not require real infrastructure.
- **Integration tests**: API happy paths, database-backed flows, errors that originate in the database, and behavior that could differ between a real database and in-memory objects/mocks.

## Integration tests

- Do not add integration tests for behavior that can be covered by unit tests.
- Each new API route needs one happy-path API integration test, even if its logic is unit-tested. This verifies routing, serialization, DI and middleware wiring.
- For writes, assert the persisted state by reading it back, not only the status code or return value. Unit tests never verify persistence, so this is the only place it is checked.
- Do not test framework-guaranteed behavior, such as global authorization, unless the feature adds custom behavior.

### Repository tests
Add repository integration tests when the repository method contains any of:
- Handwritten SQL queries.
- Multiple database queries.
- Logic that depends on real database behavior, such as Postgres `citext`, unique constraints violations, referential integrity violations, transactions etc.

Decision question: **"Could this code behave differently against a real database than in memory or mocks?"** If yes, add repository-level integration tests.

## Structure

### File Structure
- Folder per class under test, file per method under test
- Put tests under `{Layer}/{SUT}Tests/`
e.g. `Services/UserServiceTests/CreateUserTests.cs` or `Entities/UserTests/UserConstructorTests.cs` or `Controllers/UserControllerTests/DeleteUserTests.cs`.

### Test method naming

**`Method_Scenario_ExpectedResult`** — always exactly three parts.

- **Method**: production member name without `Async`.
- **Scenario**: starts with `When…` (state/condition), `With…` (input) or `ForAny…`. E.g. `WhenAlreadyShipped`, `WithActiveUser`, `ForAnyFormattedMoney`.
- **ExpectedResult**: observable behavior, using verbs like `Returns…`, `Throws…`, `Adds…`, `SetsStatusTo…`, `Raises…`, `Publishes…`, `Sends…`, `DoesNotSend…`.
- **Never name implementation details**: no `CallsRepository`, `InvokesMapper`, `UsesCache`.


### Test method conventions

- **Arrange / Act / Assert separated by blank lines**
- **Exactly one Act** per test.
- Multiple assertions are fine when they verify **one behavior**.
- **No `if`, loops, `switch`, or `try/catch`** in tests.

## Test Data
- **Make values distinctive and non-default**: `PageCount = 137`, not `0` or `1`; `"Chess Club"`, not `""` or `"test"`; a different id per role. A value equal to a type default (`0`, `false`, `null`, `""`, `Guid.Empty`) can make a test pass by coincidence, especially with loose doubles.

## Assertions
- Expected values must be literals, not recomputed with production logic.
- Reference test inputs directly (`dto.Email`); use literals for values the SUT derives.
- **Use the most specific assertion.**
  - ✅ `result.Should().Be(expected)`, `items.Should().ContainSingle()`
  - ❌ `(result.Status == OrderStatus.Cancelled && result.Lines.Count == 1).Should().BeTrue()`
- No `because:` text unless the reason isn't obvious from the test name.
