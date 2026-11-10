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
    # General skills: /grill-me, /handoff
    - akilin/agents/packs/general
    # Engineering workflow skills: specs, tickets, TDD, review and more
    - akilin/agents/packs/engineering
    # .NET conventions: 2 instructions
    - akilin/agents/packs/dotnet
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

### general pack

`akilin/agents/packs/general` installs all of the items below.

| Name | Type | What it does | Install path |
|---|---|---|---|
| `grill-me` | skill | Run `/grill-me <plan>` to be interviewed one question at a time until the plan or design holds up. Adapted from [Matt Pocock's skills](#credits). | `akilin/agents/skills/general/grill-me` |
| `handoff` | skill | Run `/handoff` to compact the current conversation into a handoff document for another agent to pick up. | `akilin/agents/skills/general/handoff` |

### engineering pack

`akilin/agents/packs/engineering` installs all of the items below.

> [!NOTE]
> Run `/setup-akilin-skills` once per repo before using the other skills in this pack. It configures the issue tracker (GitHub or local files) and the domain doc layout they rely on.

**Skills** (install path: `akilin/agents/skills/engineering/<name>`)

| Name | What it does |
|---|---|
| `setup-akilin-skills` | Run `/setup-akilin-skills` to configure the repo's issue tracker and domain doc layout for this pack. |
| `grill-with-docs` | Run `/grill-with-docs` to be interviewed about a plan or design, writing ADRs and glossary entries as you go. |
| `domain-modeling` | Builds and sharpens the domain model: codebase terminology, `GLOSSARY.md` and ADRs. |
| `codebase-design` | Shared vocabulary for designing deep modules: interfaces, seams, testability. |
| `prototype` | Builds a throwaway prototype to answer a design question about logic or UI. |
| `research` | Investigates a question against primary sources and saves the findings as Markdown in the repo. |
| `to-spec` | Run `/to-spec` to turn the current conversation into a spec on the issue tracker. |
| `to-tickets` | Run `/to-tickets` to break a plan or spec into tracer-bullet tickets with blocking edges. |
| `implement` | Run `/implement` to implement a piece of work from a spec or set of tickets. |
| `implement-spec` | Run `/implement-spec` to implement the output of `/to-spec` and `/to-tickets`. |
| `tdd` | Test-driven development with a red-green-refactor loop. |
| `code-review` | Reviews changes since a commit, branch or tag against the repo's coding standards and the originating spec. |
| `retro` | Run `/retro` to hold a retrospective on a coding session. |

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
