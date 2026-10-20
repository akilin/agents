---
description: Use when modifying C# code
applyTo: '**/*.cs'
---

## Project layout
Clean architecture with strict separation of concerns:
- `src/domain`: domain layer. Contains abstractions, interfaces, services, entities, constants, DTOs, exceptions, utils.
- `src/infra`: infrastructure layer. Contains EF Core, repositories, object storage, identity helpers, email, and background workers.
- `src/shared`: reusable contracts, exceptions, database helpers, messaging, and outbox infrastructure shared by service hosts.
- `src/api`: primary API host. Contains controllers, middleware, auth, rate limiting, Swagger, and DI wiring in `Startup.cs`.

## Instructions
- Abbreviate injected param names by role: `svc`, `repo`, `uow`, `fileSvc`, `userRepo`, `identity`, `orgProvider`.
- Prefer `NodaTime` types for dates/times. Avoid using `DateTime`, `DateTimeOffset`, `DateOnly`, or `TimeOnly`. Exception: when working with external code that already uses those types.
- Use `record` types for incoming DTOs.

## Building projects
- Restore with `dotnet restore` only when dependencies changed or not installed.
- Build with `dotnet build --no-restore $something`.
