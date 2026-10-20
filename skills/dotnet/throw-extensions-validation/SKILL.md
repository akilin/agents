---
name: throw-extensions-validation
description: 'Use when validating incoming data in the domain layer using `ThrowExtensions`'
---

# Validate Incoming Data with `ThrowExtensions`

Use these extensions in `src/domain` (entities, services, DTO ingestion) instead of writing manual `if (x is null) throw ...` blocks. They produce consistent `AbstractException`-derived errors with proper error codes.

## Available Helpers

From `ThrowExtensions` (shared library):

| Extension | Receiver | Purpose |
|---|---|---|
| `ThrowIfEmpty(name)` | `string?` | Non-null, non-empty, non-whitespace |
| `ThrowIfNull(name)` | `T? class` / `T? struct` | Non-null |
| `ThrowIfDefault(name)` | `T struct` | Not equal to `default(T)` |
| `ThrowIfNullOrDefault(name)` | `T? struct` | Non-null AND not default; unwraps to `T` |
| `ThrowIfStringTooLong(name, maxLength?)` | `string` | Length <= `maxLength` (default `Constants.DefaultMaxStringLength`) |
| `ThrowIfNameTooLong(name)` | `string` | Length <= `Constants.NameMaxStringLength` |
| `ThrowIfInvalidEmail()` | `string` | Valid email per `EmailValidator` |
| `ThrowIfInvalidEnumValue(name)` | `T struct, Enum` | Defined enum value |
| `ThrowIfNotValidPageSize()` | `int` | Page size is in `AppConstants.AllowedPageSizes` |

Check `ThrowExtensions` for an existing helper before introducing another one. Keep one-off validation local to the owning entity.

## When to Use

- Any Domain methods that accept user-supplied primitives or DTOs.
- Any place where invalid input must surface as a `400`-class domain error rather than a `NullReferenceException`/`ArgumentException`.

Do **not** use for cross-entity business rules (e.g. permission checks, uniqueness) — those throw specific `AbstractException` subclasses directly with codes from `ErrorCodes`.

## Procedure

### 1. Identify the field's contract
For each property to assign, decide:
- Required vs optional (nullable on the entity)?
- Type: `string`, struct (`int`, `LocalDate`, enum...), or reference type?
- Length cap (default vs name-length vs custom constant)?
- Special format (email, enum, page size, custom)?

### 2. Pick the chain

**Required string** → `ThrowIfEmpty(name).ThrowIfStringTooLong(name)` (or `ThrowIfNameTooLong`)
```csharp
Name = dto.Name.ThrowIfEmpty(nameof(dto.Name)).ThrowIfStringTooLong(nameof(dto.Name));
```

**Optional string** (null/whitespace → `null`, otherwise validated):
```csharp
Name = dto.Name.IsNullOrWhiteSpace()
    ? null
    : dto.Name.ThrowIfStringTooLong(nameof(dto.Name));
```

**Required nullable enum (with default = invalid)** → `ThrowIfNullOrDefault(name).ThrowIfInvalidEnumValue(name)`
```csharp
Species = dto.Species.ThrowIfNullOrDefault(nameof(dto.Species))
                     .ThrowIfInvalidEnumValue(nameof(dto.Species));
```

**Required nullable enum (default IS a valid member)** → `ThrowIfNull(name).ThrowIfInvalidEnumValue(name)`
```csharp
Sex = dto.Sex.ThrowIfNull(nameof(dto.Sex)).ThrowIfInvalidEnumValue(nameof(dto.Sex));
```

**Required nullable bool** → `ThrowIfNull(name)`
```csharp
IsPublic = isPublic.ThrowIfNull(nameof(IsPublic));
```

**Optional email** (trim, null when empty):
```csharp
Email = dto.Email.IsEmpty ? null : dto.Email.Trim().ThrowIfInvalidEmail();
```

**Custom format** - wrap a one-off rule in a `private static` helper that throws the appropriate `AbstractException` subtype and error code.

### 3. Chain order matters

1. Null/default check first (so subsequent ops have a non-null receiver).
2. Then format/length validation.
3. `ThrowIfNullOrDefault` / `ThrowIfEmpty` unwrap the value — chain length checks after them, not before.

### 4. Use `nameof(dto.Field)`
Pass `nameof(dto.X)` (not `nameof(X)`) so the error parameter name matches the input the caller sent. When validating inside a private setter helper, `nameof(Property)` is acceptable.

### 5. Custom max lengths
Hold them as `private const int` on the entity:
```csharp
private const int MaxDescriptionLength = 200;
...
Description = dto.Description.IsNullOrWhiteSpace()
    ? null
    : dto.Description.ThrowIfStringTooLong(nameof(dto.Description), MaxDescriptionLength);
```

### 6. New error code?
If a custom validator needs an error code that doesn't exist:
1. Add `public const string` to the proper nested class in `ErrorCodes.cs`.
2. Add the human message in `ErrorCodeToMessageMapper.cs`.
3. Throw `new AppException(ErrorCodes.X.Y)` (or the most specific `AbstractException` subclass).

## Reference Examples

Read existing entities under `src/domain/Entities` to see these chains in context before writing new ones.

## Anti-patterns

- `if (x is null) throw new ArgumentNullException(...)` in domain code — use `ThrowIfNull`.
- Validating `string` length before `ThrowIfEmpty` — null receiver will throw the wrong exception type.
- Using `ThrowIfDefault` on a nullable struct — use `ThrowIfNullOrDefault` instead.
- Calling `ThrowIfInvalidEnumValue` without first ensuring non-null/non-default for required enums.
- Hardcoding `"FieldName"` strings — always use `nameof(...)`.
- Adding a one-off `ThrowIf*` extension to shared `ThrowExtensions` for an entity-specific rule.
