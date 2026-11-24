---
description: Conventions for Entity Framework Core persistence.
applyTo: '**/*.cs'
---
### EF Core
- Configure entities via `IEntityTypeConfiguration<T>` classes, never via attributes on the entity class.
- Default OnDelete behavior is set to `Restrict`. Configure cascade deletes explicitly in the entity configuration when they are needed.
