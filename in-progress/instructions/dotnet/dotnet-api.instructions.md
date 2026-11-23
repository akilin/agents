---
description: Use when working inside the api layer in src/api.
applyTo: 'src/api/**'
---

- Controllers always take in DTOs and return DTOs. NEVER return entities from controllers.
- Prefer `record` types for incoming DTOs.
