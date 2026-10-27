---
description: Use when working inside the api layer in src/api.
applyTo: 'src/api/**'
---
## API

### Controllers
- Controllers inherit `BaseController`, use `[Route("api/[controller]")]` and kebab-case URLs. Auth is on by default (`FallbackPolicy = DefaultPolicy`); use `[AllowAnonymous]` to opt out.
- Verbs via `[HttpGet]`, `[HttpPost]`, `[HttpPut]`, `[HttpDelete]` with route templates and typed constraints (`{id:int?}`).
- Controllers always take in DTOs and return DTOs. NEVER return entities from controllers.
- For errors inside controllers, use `BaseController` helper methods to generate return values.
- Keep controllers thin: parameter normalization, body/null guards, service calls, and HTTP result shaping only. Put authorization, validation, and business rules in domain services.
