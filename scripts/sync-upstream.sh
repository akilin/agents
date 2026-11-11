#!/usr/bin/env bash
# Sync upstream SHAs for AI customization files tracked via *.upstream.json sidecars.
# Bash port of Sync-Upstream.ps1 for Linux / devcontainer use.
#
# Usage: scripts/sync-upstream.sh [ROOT]
#   ROOT  Directory to scan. Defaults to the `upstreams` folder next to this script.
#
# Recursively scans ROOT for sidecar files named `upstream.json` or `*.upstream.json`.
# For each one:
#   1. Resolve default branch + HEAD SHA via GitHub API.
#   2. If HEAD == stored commit -> up to date.
#   3. Otherwise look up the stored commit's date, open a browser at
#        https://github.com/{owner}/{repo}/commits/{branch}/{path}?since={yyyy-MM-dd}
#      where the date is the day of the stored commit.
#   4. Wait for Enter, then bump the sidecar's `commit` to HEAD.
#
# Sidecar schema:
#   { "repo": "...", "path": "...", "commit": "<sha>", "branch": "main" }
# `branch` is optional; if absent it is resolved from the repo's default branch
# on first run and written back to the sidecar.
#
# If $GITHUB_TOKEN is set it is used to lift API rate limits; otherwise the
# token from `gh auth token` is used when available.
#
# The browser is opened via $BROWSER (set by VS Code in devcontainers, opens on
# the host), falling back to xdg-open. If neither works the URL is just printed.
#
# Requires: bash, curl, jq, GNU date.
set -uo pipefail

script_dir=$(cd "$(dirname "$0")" && pwd)
workspace_root=$(cd "$script_dir/.." && pwd)
root=${1:-$script_dir/upstreams}

required_fields=(repo path commit)

if [[ -t 1 ]]; then
  c_cyan=$'\e[36m' c_gray=$'\e[90m' c_green=$'\e[32m' c_yellow=$'\e[33m' c_reset=$'\e[0m'
else
  c_cyan='' c_gray='' c_green='' c_yellow='' c_reset=''
fi

warn() { echo "${c_yellow}WARNING: $*${c_reset}" >&2; }
die() { echo "error: $*" >&2; exit 1; }

for cmd in curl jq date; do
  command -v "$cmd" >/dev/null || die "'$cmd' is required but not installed"
done

token=${GITHUB_TOKEN:-}
if [[ -z $token ]] && command -v gh >/dev/null; then
  token=$(gh auth token 2>/dev/null || true)
fi

# ---------------------------------------------------------------------------
# GitHub API
# ---------------------------------------------------------------------------

github() { # <uri> -> JSON on stdout
  local uri=$1 body status
  local -a headers=(
    -H 'Accept: application/vnd.github+json'
    -H 'X-GitHub-Api-Version: 2022-11-28'
    -H 'User-Agent: sync-upstream-script'
  )
  [[ -n $token ]] && headers+=(-H "Authorization: Bearer $token")

  body=$(curl -sS -w $'\n%{http_code}' "${headers[@]}" "$uri") || {
    warn "request failed: $uri"
    return 1
  }
  status=${body##*$'\n'}
  body=${body%$'\n'*}
  if [[ $status != 2* ]]; then
    warn "GET $uri -> HTTP $status: $(jq -r '.message // empty' <<< "$body" 2>/dev/null)"
    return 1
  fi
  printf '%s' "$body"
}

parse_owner_repo() { # <url> -> sets owner, repo
  local url=$1
  if [[ ! $url =~ ^https?://github\.com/([^/]+)/([^/]+)/?$ ]]; then
    warn "Not a GitHub HTTPS URL: $url"
    return 1
  fi
  owner=${BASH_REMATCH[1]}
  repo=${BASH_REMATCH[2]%.git}
}

get_default_branch() { github "https://api.github.com/repos/$owner/$repo" | jq -er '.default_branch'; }

get_branch_head() { github "https://api.github.com/repos/$owner/$repo/commits/$1" | jq -er '.sha'; }

get_commit_date() { # <sha> -> yyyy-MM-dd (UTC)
  local raw
  raw=$(github "https://api.github.com/repos/$owner/$repo/commits/$1" | jq -er '.commit.committer.date') || return 1
  date -u -d "$raw" +%Y-%m-%d
}

# ---------------------------------------------------------------------------
# Sidecar I/O
# ---------------------------------------------------------------------------

read_sidecar() { # <path> -> validated JSON on stdout
  local data field
  data=$(jq -e . "$1" 2>/dev/null) || { warn "Invalid JSON in $1"; return 1; }
  for field in "${required_fields[@]}"; do
    if ! jq -e --arg f "$field" '(.[$f] // "") | tostring | test("\\S")' <<< "$data" >/dev/null; then
      warn "Missing required field '$field'."
      return 1
    fi
  done
  printf '%s' "$data"
}

save_sidecar() { # <path> <json> ; written as UTF-8, no BOM, 2-space indent, trailing newline
  local path=$1 tmp
  tmp=$(mktemp "$path.XXXXXX") || return 1
  if jq --indent 2 . <<< "$2" > "$tmp"; then
    chmod --reference="$path" "$tmp" 2>/dev/null
    mv "$tmp" "$path"
  else
    rm -f "$tmp"
    return 1
  fi
}

open_url() {
  if [[ -n ${BROWSER:-} ]] && "$BROWSER" "$1" >/dev/null 2>&1; then return 0; fi
  if command -v xdg-open >/dev/null && xdg-open "$1" >/dev/null 2>&1; then return 0; fi
  echo "  (could not open a browser; open the url above manually)"
}

# ---------------------------------------------------------------------------
# Per-sidecar processing
# ---------------------------------------------------------------------------

# Sets $result to updated or up-to-date; returns non-zero on error.
sync_sidecar() { # <file>
  local file=$1 rel data branch new_sha old_sha since url
  rel=$(realpath --relative-to="$workspace_root" "$file")
  echo
  echo "${c_cyan}=== $rel ===${c_reset}"

  data=$(read_sidecar "$file") || return 1
  parse_owner_repo "$(jq -r '.repo' <<< "$data")" || return 1

  branch=$(jq -r '(.branch // "") | tostring' <<< "$data")
  if [[ ! $branch =~ [^[:space:]] ]]; then
    branch=$(get_default_branch) || return 1
    data=$(jq --arg b "$branch" '.branch = $b' <<< "$data")
    save_sidecar "$file" "$data" || { warn "Failed to write $file"; return 1; }
  fi

  new_sha=$(get_branch_head "$branch") || return 1
  old_sha=$(jq -r '.commit | tostring' <<< "$data")

  if [[ $old_sha == "$new_sha" ]]; then
    echo "${c_gray}up to date (${new_sha:0:7})${c_reset}"
    result=up-to-date
    return 0
  fi

  since=$(get_commit_date "$old_sha") || return 1
  url="https://github.com/$owner/$repo/commits/$branch/$(jq -r '.path' <<< "$data")?since=$since"

  echo "  path:    $(jq -r '.path' <<< "$data")"
  echo "  branch:  $branch"
  echo "  ${old_sha:0:7} -> ${new_sha:0:7}"
  echo "  url:     $url"

  open_url "$url"
  read -r -p 'Press Enter when done reviewing (Ctrl+C to abort)' < /dev/tty ||
    die "no terminal to read confirmation from; aborting without updating $rel"

  data=$(jq --arg c "$new_sha" '.commit = $c' <<< "$data")
  if save_sidecar "$file" "$data"; then
    echo "${c_green}updated${c_reset}"
    result=updated
  else
    warn "Failed to write $file"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

[[ -d $root ]] || die "Root not found: $root"
root_full=$(cd "$root" && pwd)

mapfile -t sidecars < <(find "$root_full" -type f \( -name 'upstream.json' -o -name '*.upstream.json' \) | LC_ALL=C sort)

if (( ${#sidecars[@]} == 0 )); then
  echo "No upstream.json / *.upstream.json sidecars found under $root_full"
  exit 0
fi

declare -A counts=([updated]=0 [up-to-date]=0 [error]=0)
for file in "${sidecars[@]}"; do
  result=error
  sync_sidecar "$file" || result=error
  counts[$result]=$((counts[$result] + 1))
done

echo
echo "Summary: ${counts[updated]} updated, ${counts[up-to-date]} up-to-date, ${counts[error]} errors"
