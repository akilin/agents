---
name: domain-entity
description: 'Use when adding a new domain entity in `src/domain/Entities/`'
argument-hint: 'Entity name, ID type, and fields'
---

# Scaffold a Domain Entity

Produces a new entity class under `src/domain/Entities` that follows every domain-layer convention (`dotnet-domain` and `dotnet-entities` instructions).

## When to Use

- Adding a new persisted entity.

Not for: cross-tables / pure value objects / DTOs.

## Required Inputs

Before generating, gather:
1. **Entity name** (PascalCase, singular, e.g. `Product`).
2. **Id type** (almost always `int`; `long` for high-volume; `Guid` for externally-referenced).
3. **Field list** with type, nullability, length/range, and mutability rules.
4. **Related interfaces** such as `IHaveProfilePic`, only when the entity actually supports that behavior.
5. **Folder**: pick or create `src/domain/Entities/<Plural>/` matching existing naming.

## Procedure

### 1. Create the folder + file
Path: `src/domain/Entities/<Plural>/<Name>.cs`

### 2. Use this skeleton

```csharp
using Domain.DTOs.<Plural>;
using Shared.Core.Extensions;

namespace Domain.Entities.<Plural>;

public class <Name> : BaseEntity<int>
{
    public string Name { get; private set; }

#pragma warning disable CS8618 // EF parameterless ctor
    private <Name>() { }
#pragma warning restore CS8618

    public <Name>(Create<Name>DTO dto)
    {
        Name = dto.Name.ThrowIfEmpty(nameof(dto.Name)).ThrowIfStringTooLong(nameof(dto.Name));
        // ... validate every required field
    }

    public void Update(Update<Name>DTO dto)
    {
        Name = dto.Name.ThrowIfEmpty(nameof(dto.Name)).ThrowIfStringTooLong(nameof(dto.Name));
        // ... mirror ctor validations for mutable fields
    }
}
```

### 3. Validate every field
Apply the `throw-extensions-validation` skill to the ctor and `Update`. Do not skip null/empty/length checks even if the DB column is constrained.

### 4. Mirror invariants between ctor and Update
Any field both creatable and updatable must use the **same** validation chain in both. Extract into a `private void Set<Field>(...)` if shared logic grows beyond two lines.

### 5. Optional fields
Use the `IsNullOrWhiteSpace ? null : value.ThrowIf...` pattern for optional strings.

### 6. Custom format validation
Wrap one-off validation rules in a `private static` helper on the entity. Add a shared extension only when multiple domain types use the same contract.

### 7. Const max-lengths
Declare `private const int Max<X>Length = N;` near the top of the class. Reuse `Constants.NameMaxStringLength` or `Constants.DefaultMaxStringLength` when applicable.

### 8. EF mapping (Infra)
After creating a persisted entity, add its `IEntityTypeConfiguration<T>` under `src/infra/DAL/EntityTypeConfigurations` and make it reachable from `AppDbContext`.

### 9. Don't put in domain
- No `using Microsoft.EntityFrameworkCore` — that belongs in `Infra`.
- No ASP.NET / `HttpContext` references.
- No async DB calls inside the entity.

## Reference Examples

Before generating, read one or two existing entities under `src/domain/Entities` and match their style. Prefer one with a similar key type and field mix.

## Anti-patterns

- Public setters on properties (use `private set` and methods).
- Skipping the `protected` EF ctor → EF runtime errors.
- Validating in the controller/service and trusting the entity ctor — entity must always validate too.
- Adding a one-off `ThrowIf*` to `ThrowExtensions` for a single entity's rule.
- Cross-aggregate references resolved inside the entity ctor (pass already-resolved IDs / objects in).
