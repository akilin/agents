---
name: setup-akilin-skills
description: "Configure this repo for the engineering skills: set up its issue tracker and domain doc layout, and add a token-efficient test runner and a review-time style pass to .NET repos. Run once before first use of the other engineering skills."
disable-model-invocation: true
---

# Setup akilin's Skills

Scaffold the per-repo configuration that the engineering skills assume:

- **Issue tracker**: where issues live (GitHub by default; local markdown is also supported out of the box)
- **Domain docs**: where `GLOSSARY.md` and ADRs live, and the consumer rules for reading them
- **Test runner** (.NET repos only): a root `test.sh` that agents run instead of `dotnet test`, for a short command and short output
- **Style pass** (.NET repos only): a root `format.sh` that `code-review` runs to apply the repo's `.editorconfig` before reviewing, so style rules stay out of the implementing agent's loop

This is a prompt-driven skill, not a deterministic script. Explore, present what you found, confirm with the user, then write.

## Process

### 1. Explore

Look at the current repo to understand its starting state. Read whatever exists; don't assume:

- `git remote -v` and `.git/config`: is this a GitHub repo? Which one?
- `AGENTS.md` and `CLAUDE.md` at the repo root: does either exist? Is there already an `## Agent skills` section in either?
- `GLOSSARY.md` and `GLOSSARY-MAP.md` at the repo root, and the legacy `CONTEXT.md` / `CONTEXT-MAP.md`. If a legacy file exists, offer to `git mv` it to its `GLOSSARY` name and rewrite those names in `docs/agents/domain.md`.
- `docs/adr/` and any `src/*/docs/adr/` directories
- `docs/agents/`: does this skill's prior output already exist?
- `.scratch/`: a sign that a local-markdown issue tracker convention is already in use
- .NET test signals: test projects (`.csproj` files that hold tests, not helper libraries such as `TestUtils` or `Fixtures`), whether `global.json` sets `test.runner` to `Microsoft.Testing.Platform`, and whether a `test.sh` already exists at the repo root
- .NET style signals: the `*.sln` / `*.slnx` files at the repo root, whether a root `.editorconfig` exists, and whether a `format.sh` already exists at the repo root
- Monorepo signals: a `pnpm-workspace.yaml`, a `workspaces` field in `package.json`, or a populated `packages/*` with its own `src/`. These are present only in a genuinely large multi-package repo; their absence means single-context, which is almost every repo.

### 2. Present findings and ask

Summarise what's present and what's missing. Then take the sections in order. One section, one answer, then the next.

Lead each section with the recommended answer so the user can accept it in a word. Give a one-line explainer only when the choice genuinely branches; skip the section entirely when exploration already settled it.

**Section A: Issue tracker.**

> Explainer: The "issue tracker" is where issues live for this repo. Skills like `to-tickets` and `to-spec` read from and write to it. They need to know whether to call `gh issue create`, write a markdown file under `.scratch/`, or follow some other workflow you describe. Pick the place you actually track work for this repo.

Default posture: these skills were designed for GitHub. If a `git remote` points at GitHub, propose that. Otherwise (or if the user prefers), offer:

- **GitHub**: issues live in the repo's GitHub Issues (uses the `gh` CLI)
- **Local markdown**: issues live as files under `.scratch/<feature>/` in this repo (good for solo projects or repos without a remote)
- **Other** (Jira, Linear, etc.): ask the user to describe the workflow in one paragraph; the skill will record it as freeform prose

Record the choice in `docs/agents/issue-tracker.md`.

A GitHub tracker needs a reachable repo. When the user picks GitHub and no `git remote` points at GitHub, get the repo URL from them and wire it up (`git init` if needed, `git remote add origin <url>`) before going further. Done when `gh repo view` prints the project from inside this directory; if it can't, stop and tell the user what's missing.

**Section B: Domain docs.** Default to **single-context** (one `GLOSSARY.md` + `docs/adr/` at the repo root). This fits almost every repo; write it without asking.

Offer **multi-context** (a root `GLOSSARY-MAP.md` pointing to per-context `GLOSSARY.md` files) only when exploration found monorepo signals. Then confirm which layout they want.

**Section C: Test runner.** Skip this section without mentioning it when the repo has no .NET test projects.

> Explainer: `test.sh` wraps `dotnet test` so an agent types a short command and reads short output: nothing when the tests pass, and only the failures, with build and runner noise stripped, when they don't.

The script uses options that only the Microsoft.Testing.Platform runner has. If `global.json` doesn't select that runner, say so, don't write the script, and move on. Don't change the runner here.

Otherwise propose one target per test project: a short lowercase name the agent will type, mapped to the project's path relative to the repo root. Use `unit`, `integration` and `e2e` where a project's name or folder says so; derive the others from the project name.

If a root `test.sh` already exists:

- It has a `TEST_PROJECTS` block: it is this skill's earlier output. Keep its entries as the proposal and say the rest of the script will be refreshed from the template.
- It has none: it is someone else's script. Ask before replacing it.

**Section D: Style pass.** Skip this section without mentioning it when the repo has no `.csproj` files.

> Explainer: `format.sh` runs `dotnet format`, then builds with every analyzer and IDE style rule on and prints only what is left to fix by hand. `code-review` runs it before reviewing and again after the fixes, so the agents writing the code never see the style rules.

The script needs exactly one `*.sln` or `*.slnx` at the repo root. If there is none, or more than one, say so, don't write the script, and move on.

The script only enforces what `.editorconfig` sets. If the repo has no root `.editorconfig`, say the pass will enforce only the SDK defaults, and ask whether to write the script anyway. Either way, mention that an editorconfig option with no severity, such as `csharp_style_var_when_type_is_apparent = true`, is enforced only once it gets one: `= true:warning`, or a `dotnet_diagnostic.<rule>.severity` line.

If a root `format.sh` already exists, look at its header. When it says this skill wrote it, say it will be refreshed from the template. Otherwise it is someone else's script: ask before replacing it.

### 3. Confirm and edit

Show the user a draft of:

- The `## Agent skills` block to add to whichever of `CLAUDE.md` / `AGENTS.md` is being edited (see step 4 for selection rules)
- The contents of `docs/agents/issue-tracker.md` and `docs/agents/domain.md`
- The targets and project paths for `test.sh`, when Section C applies
- Whether `format.sh` will be written, when Section D applies

Let them edit before writing.

### 4. Write

**Pick the file to edit:**

- If `CLAUDE.md` exists, edit it.
- Else if `AGENTS.md` exists, edit it.
- If neither exists, ask the user which one to create; don't pick for them.

Never create `AGENTS.md` when `CLAUDE.md` already exists (or vice versa); always edit the one that's already there.

If an `## Agent skills` block already exists in the chosen file, update its contents in-place rather than appending a duplicate. Don't overwrite user edits to the surrounding sections.

The block:

```markdown
## Agent skills

### Issue tracker

[one-line summary of where issues are tracked]. See `docs/agents/issue-tracker.md`.

### Domain docs

[one-line summary of layout: "single-context" or "multi-context"]. See `docs/agents/domain.md`.

### Running tests

Run .NET tests with `./test.sh <unit|integration> [filter]` from the repo root, never with `dotnet test`. `filter` is a fully qualified `Namespace.Class` or `Namespace.Class.Method`; omit it to run the whole project. No output and exit code 0 mean every selected test passed.
```

Include `### Running tests` only when the repo has this skill's `test.sh` (Section C), with `unit|integration` replaced by that script's targets.

Then write the docs files using the seed templates in this skill folder as a starting point:

- [issue-tracker-github.md](./issue-tracker-github.md): GitHub issue tracker
- [issue-tracker-local.md](./issue-tracker-local.md): local-markdown issue tracker
- [domain.md](./domain.md): domain doc consumer rules + layout

For "other" issue trackers, write `docs/agents/issue-tracker.md` from scratch using the user's description.

**Test runner** (only when Section C applies):

1. Copy [test.sh](./test.sh) from this skill folder to the repo root.
2. Replace the entries of its `TEST_PROJECTS` block with the confirmed targets. Change nothing else in the script.
3. Make it executable: `chmod +x test.sh`, or `git add --chmod=+x test.sh` where the filesystem doesn't keep the bit.
4. Make sure `.gitattributes` gives shell scripts LF line endings (`*.sh text eol=lf`); add the line if it's missing.
5. Run `./test.sh` with no arguments and check that the usage line lists the targets. Then run the fastest target once, usually `unit`, and report the result. Don't start infrastructure to run the others.

**Style pass** (only when Section D applies):

1. Copy [format.sh](./format.sh) from this skill folder to the repo root. Change nothing in it.
2. Make it executable and give shell scripts LF line endings, as in steps 3 and 4 for `test.sh`.
3. Run `./format.sh` once to check the baseline. The script formats the whole solution, so the repo must already pass it: otherwise the first review would pull a repo-wide cleanup into its branch. When it changes files or exits non-zero, revert its changes, report the counts, and recommend a cleanup in a commit of its own, listed in `.git-blame-ignore-revs`, before the first review. Don't do the cleanup unasked.

Don't mention `format.sh` in the `## Agent skills` block. Only `code-review` runs it, and keeping it out of always-loaded instructions is the point.

### 5. Done

Tell the user the setup is complete and which engineering skills will now read from these files. Mention they can edit `docs/agents/*.md` directly later; re-running this skill is only necessary if they want to switch issue trackers, restart from scratch, or refresh `test.sh` or `format.sh` after this skill was updated.
