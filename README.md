# agents

My personal skills and instructions for coding agents (Claude Code and GitHub Copilot), packaged with [APM](https://github.com/microsoft/apm) (Agent Package Manager).

Most of these are tailored to my preferred project layout and conventions, especially the .NET ones. They are not simple drop-in rules for any codebase.

## Quick start

Add an `apm.yml` to your project (or add these lines to an existing one):

```yaml
name: my-project
version: 0.0.0
targets: [claude, copilot]   # agents to deploy to; drop the one you don't use
dependencies:
  apm:
    # .NET clean-architecture conventions: 8 instructions + 4 skills
    - akilin/agents/packs/dotnet
    # /grill-me: get interviewed about a plan until it holds up
    - akilin/agents/skills/general/grill-me
```

Then run `apm install`. Anything in the [catalog](#catalog) can also be installed on its own by its path.

## Usage

Install APM:

```sh
curl -sSL https://aka.ms/apm-unix | sh      # macOS / Linux
brew install apm                            # macOS with Homebrew
irm https://aka.ms/apm-windows | iex        # Windows (PowerShell)
```

Common commands:

```sh
apm install akilin/agents/packs/dotnet   # add one dependency and record it in apm.yml
apm install                              # install everything listed in apm.yml
apm outdated                             # check for newer versions
apm update                               # update to them
apm prune                                # remove packages no longer listed in apm.yml
```

Dependencies follow `main`. The exact commit is recorded in `apm.lock.yaml`, but `apm update` pulls whatever is on `main` at the time. To stay on a known version, pin a commit: `akilin/agents/packs/dotnet#<sha>`.

See the [APM docs](https://microsoft.github.io/apm/) for everything else.

## Catalog

**Skills** are procedures the agent follows when a task calls for them, or when you invoke them as `/name`. **Instructions** are rules that apply automatically to files matching their glob.

### General

| Name | Type | What it does | Install path |
|---|---|---|---|
| `grill-me` | skill | Run `/grill-me <plan>` to be interviewed one question at a time until the plan or design holds up. Adapted from [Matt Pocock's skills](#credits). | `akilin/agents/skills/general/grill-me` |

### dotnet pack

`akilin/agents/packs/dotnet` installs all of the items below.

> [!NOTE]
> This pack assumes my own project structure:
> - `src/{api,domain,infra,shared}` and `tests/{unit-tests,integration,e2e}`. The instructions only fire on those paths.
> - Existing building blocks such as `BaseEntity<TId>`, `BaseController`, `IUnitOfWork`, `ThrowExtensions`, `ErrorCodes`/`ErrorCodeToMessageMapper`, and `TestBase`/`WebAppFactory`.
> - A `./test.sh <unit|integration|e2e> [filter]` script at the repo root, used by `run-tests`. It is **not** included here; bring your own.

**Skills**

| Name | What it does | Install path |
|---|---|---|
| `domain-entity` | Scaffolds a new persisted domain entity with validated creation and update. | `akilin/agents/skills/dotnet/domain-entity` |
| `domain-error-code` | Adds a domain error code to `ErrorCodes.cs` and its message mapping. | `akilin/agents/skills/dotnet/domain-error-code` |
| `run-tests` | Runs tests through the token-efficient `./test.sh` instead of `dotnet test`. | `akilin/agents/skills/dotnet/run-tests` |
| `throw-extensions-validation` | Validates incoming data in the domain layer with `ThrowExtensions`. | `akilin/agents/skills/dotnet/throw-extensions-validation` |

**Instructions** (install path: `akilin/agents/instructions/dotnet/<name>.instructions.md`)

| Name | Applies to | What it covers |
|---|---|---|
| `dotnet-api` | `src/api/**` | Thin controllers, DTOs in and out, routing, error helpers. |
| `dotnet-csharp` | `**/*.cs` | Project layout, naming, NodaTime, general C# style. |
| `dotnet-csproj` | `**/*.{csproj,props}` | Central package management, `Directory.Build.props`, `$(RepoRoot)` references. |
| `dotnet-domain` | `src/domain/**` | Entities, services, and where business rules live. |
| `dotnet-entities` | `src/domain/Entities/**` | Entity validation and conventions; links the entity and error-code skills. |
| `dotnet-infra` | `src/infra/**` | EF Core: unit of work, migrations, entity configurations. |
| `dotnet-integration-tests` | `tests/integration/**` | `TestBase`, `WebAppFactory`, self-contained tests. |
| `dotnet-tests` | `tests/**/*.cs` | Test layout, naming, arrange/act/assert. |

## Credits

`grill-me` comes from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT). Go explore that repo; it's well worth it. Matt's skills are small, sharp and easy to edit. Each targets a real way agents go wrong (misread requirements, no feedback loop, a slowly rotting codebase) without burying you in process, and you stay in control throughout.

## License

[MIT](LICENSE). Skills adapted from elsewhere keep their original license file in their folder.
