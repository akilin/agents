# Verifying work

After adding, renaming or moving anything under `skills/`, `instructions/` or `packs/`, run `bash scripts/check-names.sh`. It must exit 0.

# Keeping the README current

`README.md` is the consumer-facing catalog. Update it in the same change whenever you add, remove, rename or move a skill, instruction or pack. Also update it when you change something it describes: a skill's purpose, an instruction's `applyTo` glob, a pack's contents or assumptions, or the install commands.

# Packs that mirror skill folders

`packs/general` includes every skill under `skills/general/`, and `packs/engineering` includes every skill under `skills/engineering/`. When you add, remove, rename or move a skill in one of those folders, update the matching pack's `apm.yml` in the same change so the pack keeps listing all of them.

# Instruction file headings

Start the body of every `*.instructions.md` file, right after the frontmatter, with a `###` heading naming its topic, e.g. `### EF Core`. Use `###`, not `##`: `apm compile` merges instruction files that share an `applyTo` glob into one `AGENTS.md` under a generated `## Files matching <glob>` heading, and the file's heading is the only thing that separates it from the others there.
