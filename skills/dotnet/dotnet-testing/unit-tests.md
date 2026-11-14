# Unit tests

## Core Rules

Testing style: classicist (Detroit) by default.

- **Test behavior through public APIs** (public, or `internal` via `InternalsVisibleTo`). Never test private methods, never use reflection, never widen visibility just for tests. If private logic needs its own tests, extract a type.
- **Assert observable outcomes**: return values, state of the SUT, exceptions, and outgoing communication to *unmanaged* boundaries. Never assert on calls between your own classes.

### Never unit test
- Trivial properties, auto-properties, records/DTOs without logic.
- Auto-generated code.
- Framework/library behavior (ASP.NET Core, EF Core, serializers, DI container).
- DI registrations, `Program.cs`, EF Core configurations or queries.
- Thin pass-through code without logic.
- Private methods (directly).

## Test Doubles
Use loose mocks by default.

### What to mock
- Use classical (Detroit) style: in-process collaborators (domain objects, services, mappers, helpers) are **real instances**, never mocked.
- Mock only **boundaries**: the database (repositories, unit of work), external systems (email, payments, message bus, third-party APIs), sources of time/randomness.
- Don't mock what you don't own. Wrap the third-party SDK in your own small adapter interface and mock that. Test the adapter itself with a few integration tests.

### Repositories and unit of work
- Stub reads to drive branching logic, e.g. `IsEmailTakenAsync` returns `true`.
- Never verify calls to repositories or the unit of work. Persistence is covered by integration tests.

### Safeguards for loose mocks
Loose mocks return defaults (`null`, `0`, `false`, completed tasks) for calls that aren't set up or whose arguments don't match. To keep tests from passing for the wrong reason:
- Happy-path stubs use the exact argument values from `HappyPathDTO`, not `It.IsAny`, so a mismatched stub makes the happy path fail.
- Failure-path tests assert the specific exception type plus a message or parameter name. Never a bare `Throw<Exception>()`.

## Setting up inputs and happy path
- Define a local `HappyPathDTO` property in the test class, to avoid duplicating setup code.
- Happy path doubles are configured in the constructor; a test re-stubs only what its name is about.
- **The first test in each test class is the happy path** using the defaults unchanged. It proves the defaults are valid, so every other test's override is the only thing that differs.
- Prefer exact argument values or `It.Is<T>(x => …)` on the fields that matter. Use `It.IsAny<T>()` only for arguments irrelevant to the test (typically `CancellationToken`).


## Test Class Structure

### Arrange
- **A test overrides only what its name is about.** The Arrange section should read as "what's different about this scenario". e.g. `var dto = HappyPathDTO with { Email = "invalid-format" };`

### Builders (for domain objects)
Entities with invariants or private setters can't use `with` — use a builder:
- `{Type}Builder` in `Builders/` (or `{Solution}.Testing` when shared).
- Fluent `With{Property}(…)` methods returning `this`, and `Build()`.
- **Defaults are valid, deterministic and distinctive** (fixed ids, fixed dates, fixed amounts).
- **Reach state through public domain behavior** (factory methods, `Ship()`, `Cancel()`), never through reflection or by setting private state.

### Assert

- **Assert observable behavior only.** Observable behavior is:
1. what the caller gets: return values and exceptions;
2. the state of the SUT, or of objects the test holds a reference to;
3. side effects at **unmanaged** boundaries — things other systems can see: email sent, message published, command sent to an external API. Verify them only when the side effect IS the requirement, in a dedicated test named after it:
   - must happen → `Verify(..., Times.Once)` with the specific arguments;
   - must not happen → `Verify(..., Times.Never)`;
   - "nothing else is sent" → `VerifyNoOtherCalls()`.

## Use a TestBase when multiple method test files share mocked dependencies
When testing **multiple methods** of the same class (i.e. you will have multiple test files for the same SUT) → create a shared `{SUT}TestBase.cs` that holds the mocks and real collaborators as protected fields and exposes the SUT as a property. Each method-specific test class should derive from the TestBase and set up that method’s happy path in its constructor. Individual tests should override only the dependency behavior relevant to the scenario under test.

## Example
```csharp
// Services/UserServiceTests/UserServiceTestBase.cs — shared by CreateUserTests and ChangeEmailTests
public abstract class UserServiceTestBase
{
    protected readonly Mock<IUserRepository> UserRepoMock = new(); // boundary: stub reads, never verify
    protected readonly Mock<IUnitOfWork> UnitOfWorkMock = new();   // boundary: never verify
    protected readonly Mock<IEmailSender> EmailSenderMock = new(); // unmanaged boundary: verify when it's the requirement
    protected readonly PasswordHasher Hasher = new();              // in-process: real instance

    protected UserService Service => new(UserRepoMock.Object, UnitOfWorkMock.Object, EmailSenderMock.Object, Hasher);
}

// Services/UserServiceTests/CreateUserTests.cs
public class CreateUserTests : UserServiceTestBase
{
    CreateUserDTO HappyPathDTO => new(Email: "alice@example.com", Password: "Correct-Horse-42");

    public CreateUserTests()
    {
        UserRepoMock.Setup(r => r.IsEmailTakenAsync(HappyPathDTO.Email)).ReturnsAsync(false);
    }

    [Fact]
    public async Task CreateUser_WithValidInput_ReturnsCreatedUser()
    {
        var result = await Service.CreateUserAsync(HappyPathDTO);

        result.Email.Should().Be(HappyPathDTO.Email);
    }

    [Fact]
    public async Task CreateUser_WithValidInput_SendsWelcomeEmail()
    {
        await Service.CreateUserAsync(HappyPathDTO);

        EmailSenderMock.Verify(s => s.SendWelcomeEmailAsync(HappyPathDTO.Email), Times.Once);
    }

    [Theory]
    [InlineData("   ")]
    [InlineData("alice.example.com")]
    public async Task CreateUser_WithInvalidEmail_ThrowsArgumentException(string email)
    {
        var dto = HappyPathDTO with { Email = email };

        var act = () => Service.CreateUserAsync(dto);

        await act.Should()
            .ThrowAsync<ArgumentException>()
            .WithParameterName("Email");
    }

    [Fact]
    public async Task CreateUser_WhenEmailTaken_ThrowsEmailTaken()
    {
        UserRepoMock.Setup(r => r.IsEmailTakenAsync(HappyPathDTO.Email)).ReturnsAsync(true);

        var act = () => Service.CreateUserAsync(HappyPathDTO);

        await act.Should()
            .ThrowAsync<EmailTakenException>()
            .WithMessage("Email alice@example.com is already taken.");
    }

    [Fact]
    public async Task CreateUser_WhenEmailTaken_DoesNotSendWelcomeEmail()
    {
        UserRepoMock.Setup(r => r.IsEmailTakenAsync(HappyPathDTO.Email)).ReturnsAsync(true);

        var act = () => Service.CreateUserAsync(HappyPathDTO);

        await act.Should().ThrowAsync<EmailTakenException>();
        EmailSenderMock.Verify(s => s.SendWelcomeEmailAsync(It.IsAny<string>()), Times.Never);
    }
}
```
