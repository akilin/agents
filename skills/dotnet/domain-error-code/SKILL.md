---
name: domain-error-code
description: 'Use when adding a new domain error code'
argument-hint: 'Category and short error description'
---

# Add a Domain Error Code

Add a new error code to the project. `ErrorCodes.cs` and `ErrorCodeToMessageMapper.cs` are project-specific; find them in the repo. Both files **must** be updated together — a code without a message falls through to a generic fallback.

## Inputs

- **Category**: the matching nested class in `ErrorCodes.cs`, such as `Asp`, `Auth`, `File`, `Http`, or `Parameters`. Create a category only when no existing one fits.
- **Constant name**: PascalCase and descriptive of the failed contract.
- **Slug**: stable kebab-case prefixed by its category, such as `file.unsupported-type`.
- **Human message**: concise and user-facing, with no internal implementation details.

## Procedure

### 1. Find or create the nested class in `ErrorCodes.cs`
Follow the neighboring category's style. Use a private slug constant when several codes share a prefix:

```csharp
public class File
{
    private const string FileSlug = "file";

    public const string UnsupportedType = $"{FileSlug}.unsupported-type";
}
```

Use a nested class when a category has a meaningful subgroup, as `ErrorCodes.Auth.Password` does.

### 2. Add the matching message to `ErrorCodeToMessageMapper.cs`
Append a switch arm in the **same alphabetical group** the existing entries follow:

```csharp
E.File.UnsupportedType => "This file type is not supported.",
```

Keep the existing visual grouping (blank lines between categories).

### 3. Throw it from the right exception type

| Situation | Exception |
|---|---|
| 400-ish input issue | `AppException(code)` |
| Resource not found | `NotFoundException(code)` |
| Auth missing | `UnauthorizedException(code)` |
| Auth present but disallowed | `ForbiddenException(code)` |
| State conflict | `ConflictException(code)` |
| Unprocessable input | `UnprocessableEntityException(code)` |

```csharp
throw new AppException(ErrorCodes.File.UnsupportedType);
```

### 4. Verify
- The slug appears nowhere else (search the codebase for the literal string).
- The constant compiles in both files.
- The message is user-facing (no stack-trace lingo, no internal class names).

## Anti-patterns

- Adding a code to `ErrorCodes.cs` without a mapper entry.
- Throwing `new Exception(...)` or `ArgumentException` from domain code — always use `AbstractException` subclasses.
- Reusing an unrelated existing code "because it sort of fits".
- Hardcoding the slug string at the throw site instead of going through `ErrorCodes.X.Y`.
- Putting implementation detail in the message (e.g. SQL constraint names, type names).

## Reference

- `ErrorCodes.cs` and `ErrorCodeToMessageMapper.cs` in this repo
- `AbstractException` and its subclasses in the shared library
