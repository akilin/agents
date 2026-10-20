---
description: Use when editing .csproj or .props files
applyTo: '**/*.{csproj,props}'
---

- Use central package management via `Directory.Packages.props`. Add `<PackageReference Include="..." />` without a `Version=` attribute in `.csproj` files; pin the version in `Directory.Packages.props` instead.
- Shared compiler settings such as nullable, implicit usings, language version, and warning policy belong in `Directory.Build.props`.
- Use `$(RepoRoot)` for project references: `<ProjectReference Include="$(RepoRoot)\src\domain\Domain.csproj" />`
