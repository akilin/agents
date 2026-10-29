---
description: Use when working inside the api layer in src/api.
applyTo: 'src/api/**'
---

## Project layout
Clean architecture with strict separation of concerns:
- `src/domain`: domain layer. Contains abstractions, interfaces, services, entities, constants, DTOs, exceptions, utils.
- `src/infra`: infrastructure layer. Contains EF Core, repositories, object storage, identity helpers, email, and background workers.
- `src/shared`: reusable contracts, exceptions, database helpers, messaging, and outbox infrastructure shared by service hosts.
- `src/api`: primary API host. Contains controllers, middleware, auth, rate limiting, Swagger, and DI wiring in `Startup.cs`.

## Controllers
- Controllers inherit `BaseController`, use `[Route("api/[controller]")]` and kebab-case URLs. Auth is on by default (`FallbackPolicy = DefaultPolicy`); use `[AllowAnonymous]` to opt out.
- Verbs via `[HttpGet]`, `[HttpPost]`, `[HttpPut]`, `[HttpDelete]` with route templates and typed constraints (`{id:int?}`).
- Controllers always take in DTOs and return DTOs. NEVER return entities from controllers.
- For errors inside controllers, use `BaseController` helper methods to generate return values.
- Keep controllers thin: parameter normalization, body/null guards, service calls, and HTTP result shaping only. Put authorization, validation, and business rules in domain services.
- - Use `record` types for incoming DTOs.
