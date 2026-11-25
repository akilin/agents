---
description: Conventions for Entity Framework Core persistence.
applyTo: '**/*.cs'
---
### EF Core
- Configure entities via `IEntityTypeConfiguration<T>` classes, never via attributes on the entity class.
- Default DeleteBehavior is set to `ClientNoAction`. Configure `Cascade` or `SetNull` explicitly when they are needed.
