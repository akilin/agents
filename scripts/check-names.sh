#!/usr/bin/env bash
# Checks naming rules for skills and instructions:
# - every folder and name under skills/, instructions/ and packs/ is lowercase kebab-case
# - skill names are unique across skills (case-insensitive), at any depth
# - instruction names are unique across instructions (case-insensitive), at any depth
# - a skill's frontmatter `name:` matches its folder name
set -uo pipefail
cd "$(dirname "$0")/.."

kebab='^[a-z0-9]+(-[a-z0-9]+)*$'
errors=0
fail() { echo "error: $*" >&2; errors=$((errors + 1)); }

check_segments() { # <path relative to a root folder>
  local seg
  IFS=/ read -ra segs <<< "$1"
  for seg in "${segs[@]}"; do
    [[ $seg =~ $kebab ]] || fail "'$seg' in '$1' is not lowercase kebab-case"
  done
}

declare -A skills instructions

while IFS= read -r file; do
  dir=$(dirname "$file")
  name=$(basename "$dir")
  check_segments "${dir#skills/}"
  key=${name,,}
  if [[ -n ${skills[$key]:-} ]]; then
    fail "skill name '$name' is used by both '${skills[$key]}' and '$dir'"
  else
    skills[$key]=$dir
  fi
  declared=$(awk 'NR == 1 && !/^---/ { exit } NR > 1 && /^---/ { exit } NR > 1 && /^name:/ { sub(/^name:[ \t]*/, ""); print; exit }' "$file" | tr -d "\r\"'")
  [[ $declared == "$name" ]] || fail "'$file' declares name '$declared' but its folder is '$name'"
done < <(find skills -name SKILL.md -type f 2>/dev/null | sort)

while IFS= read -r file; do
  rel=${file#instructions/}
  name=$(basename "$rel" .instructions.md)
  check_segments "${rel%.instructions.md}"
  key=${name,,}
  if [[ -n ${instructions[$key]:-} ]]; then
    fail "instruction name '$name' is used by both '${instructions[$key]}' and '$file'"
  else
    instructions[$key]=$file
  fi
done < <(find instructions -name '*.instructions.md' -type f 2>/dev/null | sort)

while IFS= read -r dir; do
  check_segments "${dir#packs/}"
done < <(find packs -mindepth 1 -type d 2>/dev/null | sort)

if ((errors > 0)); then
  echo "$errors naming error(s) found" >&2
  exit 1
fi
echo "names ok: ${#skills[@]} skills, ${#instructions[@]} instructions"
