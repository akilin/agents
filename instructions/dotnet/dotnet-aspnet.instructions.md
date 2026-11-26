---
description: Conventions for ASP.NET API endpoints.
applyTo: '**/*.cs'
---
### ASP.NET
- Endpoints accept and return DTOs, never entities, not even nested inside a DTO property. This keeps the API contract independent of the persistence model and avoids leaking internal columns.
- Prefer `record` types for DTOs.
