---
description: Use when working inside the domain layer in src/domain.
applyTo: 'src/domain/**'
---
## Domain
`src/domain` is the domain layer. Keep it free of ASP.NET and Entity Framework dependencies.
If a class needs Entity Framework, Npgsql, AWS SDK, MailKit, etc. - it belongs in `Infra`, not `Domain`.

### Entities
- Persisted entities derive from `BaseEntity<TId>` when they use the standard key shape.
- Properties have `private set` (or `protected set` for inheritance). Mutate via methods.
- Provide a non-public parameterless constructor when EF cannot bind an existing constructor. Guard it by `#pragma warning disable CS8618 ... restore.
- Validate inputs using `ThrowExtensions`. See the `throw-extensions-validation` and `domain-entity` skills.

### Services
- Keep business rules and orchestration in services rather than controllers or repositories.
- Use `IIdentityProvider` in services when an operation depends on the authenticated user.
- Accept and return DTOs at application boundaries; keep entities inside the domain and persistence layers.

### DTOs
- For Create/Update DTOs make all fields nullable and validate in the service layer.
- For Get DTOs, use constructors that take entities and map properties. If mapping requires async work, use a static async factory method.

### Exceptions
- Domain errors derive from `AbstractException` and use codes from `ErrorCodes`.
- When introducing a new error code, follow the `domain-error-code` skill.
