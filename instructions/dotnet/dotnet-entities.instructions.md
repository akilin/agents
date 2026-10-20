---
description: 'Conventions enforced when editing files under src/domain/Entities/.'
applyTo: 'src/domain/Entities/**'
---

# Domain Entity Conventions

When creating or modifying entities under `src/domain/Entities`:

- Validate **all** ingested data with `ThrowExtensions`. Follow the `throw-extensions-validation` skill for chain order, optional-string handling, enum, email, and custom-format patterns.
- When scaffolding a brand-new persisted entity, follow the `domain-entity` skill: `BaseEntity<TId>`, private setters, validated creation/update methods, and a non-public EF constructor when required.
- Mirror validation between the ctor and `Update` for any field that exists in both.
- Keep entity-specific validators as `private static` methods on the entity. Do **not** add one-off helpers to shared `ThrowExtensions`.
- When introducing a new error code, follow the `domain-error-code` skill — update both `ErrorCodes.cs` and `ErrorCodeToMessageMapper.cs`.
- No EF / ASP.NET / external-SDK `using` statements. Those references belong in `Infra`.
