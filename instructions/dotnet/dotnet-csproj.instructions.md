---
description: Use when editing .csproj or .props files
applyTo: '**/*.{csproj,props}'
---
### .csproj and .props

- Use central package management via `Directory.Packages.props` for multi-project solutions.
- Shared compiler settings such as nullable, implicit usings, language version, and warning policy belong in `Directory.Build.props`.
- Use `$(RepoRoot)` for project references: `<ProjectReference Include="$(RepoRoot)\src\api\Api.csproj" />`
