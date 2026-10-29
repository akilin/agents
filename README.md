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
    # .NET conventions: 2 instructions
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
> This pack assumes my own conventions: central package management via `Directory.Packages.props`, shared settings in `Directory.Build.props`, a `$(RepoRoot)` MSBuild property for project references, and NodaTime for dates and times.

**Instructions** (install path: `akilin/agents/instructions/dotnet/<name>.instructions.md`)

| Name | Applies to | What it covers |
|---|---|---|
| `dotnet-csharp` | `**/*.cs` | Use NodaTime types for dates and times. |
| `dotnet-csproj` | `**/*.{csproj,props}` | Central package management, `Directory.Build.props`, `$(RepoRoot)` references. |

## Credits

`grill-me` comes from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT). Go explore that repo; it's well worth it. Matt's skills are small, sharp and easy to edit. Each targets a real way agents go wrong (misread requirements, no feedback loop, a slowly rotting codebase) without burying you in process, and you stay in control throughout.

## License

[MIT](LICENSE). Skills adapted from elsewhere keep their original license; see [THIRD_PARTY_NOTICES](THIRD_PARTY_NOTICES).
