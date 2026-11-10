# Verifying work

After adding, renaming or moving anything under `skills/`, `instructions/` or `packs/`, run `bash scripts/check-names.sh`. It must exit 0.

# Keeping the README current

`README.md` is the consumer-facing catalog. Update it in the same change whenever you add, remove, rename or move a skill, instruction or pack. Also update it when you change something it describes: a skill's purpose, an instruction's `applyTo` glob, a pack's contents or assumptions, or the install commands.

# Packs that mirror skill folders

`packs/general` includes every skill under `skills/general/`, and `packs/engineering` includes every skill under `skills/engineering/`. When you add, remove, rename or move a skill in one of those folders, update the matching pack's `apm.yml` in the same change so the pack keeps listing all of them.
