---
description: Use when working inside the infrastructure layer in src/infra.
applyTo: 'src/infra/**'
---
## Entity framework
- Migrations are applied automatically on API startup by `SetupDatabase` in `Program.cs`.
- Save via `IUnitOfWork`. Avoid calling `DbContext.SaveChangesAsync` from domain services.
- Use `IUnitOfWork.RegisterPostSaveChangesAction` for side effects that must run after a successful db operation (e.g. cleaning cache).

### Entity configuration
- Configure entities via  `IEntityTypeConfiguration<T>` classes under `src/infra/DAL/EntityTypeConfigurations`.
- Default OnDelete behavior is set to `Restrict`. Configure cascade deletes explicitly in the entity configuration when they are needed.
- Express constraints in the configuration, not in attributes.
- Column names follow snake_case automatically; don't override unless legacy.

### Repositories
- Follow existing conventions for method names: `Add`, `Get*ById`, `Get*ForUpdate`, `Query*Paged`, and `Query*NonPaged`.
- Return `PagedData<T>` through `ToPagedListAsync(pageNumber, pageSize)` for paged queries.
