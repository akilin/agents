#!/usr/bin/env bash

set -u

readonly MTP_EXIT_SUCCESS=0
readonly MTP_EXIT_NO_TESTS=8

if [[ $# -lt 1 || $# -gt 2 ]]; then
	printf 'usage: %s <unit|integration> [filter]\n' "${0##*/}" >&2
	exit 2
fi

case "$1" in
	unit) project='tests/unit-tests/UnitTests.csproj' ;;
	integration) project='tests/integration/IntegrationTests.csproj' ;;
	*)
		printf 'unknown test target: %s\n' "$1" >&2
		exit 2
		;;
esac

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# global.json (selects the test runner) is resolved from the working directory.
cd "$repo_root" || exit 1
output=$(mktemp)
trap 'rm -f "$output"' EXIT

filter_args=()
if [[ $# -eq 2 ]]; then
	filter_args=(--filter-method "$2" "$2.*")
fi

run_tests() {
	dotnet test \
		--project "$repo_root/$project" \
		--no-restore \
		"$@" \
		--no-ansi \
		--no-progress \
		--show-stdout Failed \
		--show-stderr Failed \
		-v:q
}

run_tests "${filter_args[@]}" >"$output" 2>&1
status=$?

if [[ $status -eq $MTP_EXIT_SUCCESS ]]; then
	exit "$MTP_EXIT_SUCCESS"
fi

if [[ $status -eq $MTP_EXIT_NO_TESTS ]]; then
	if [[ $# -eq 2 ]]; then
		printf 'no tests matched: %s\n' "$2" >&2
	else
		printf 'no tests found\n' >&2
	fi
	exit "$status"
fi

sed -E \
	-e $'s/\x1B\[[0-9;]*m//g' \
	-e '/^Using launch settings from /d' \
	-e '/^Running tests from /d' \
	-e '/^  from \/.*\.dll \(/d' \
	-e 's#^/.*/([^/]+\.dll) \([^)]*\) #\1 #' \
	-e '/^Build (started|completed|FAILED)/d' \
	-e '/^Project .* on node [0-9]+/d' \
	-e '/^Done Building Project /d' \
	-e '/^Test run completed with non-success exit code:/d' \
	-e '/^Build failed with exit code: /d' \
	-e '/^Exit code: [0-9]+$/d' \
	-e '/^ +at (AwesomeAssertions|Xunit|System\.Reflection)\./d' \
	-e '/^ +--- End of stack trace from previous location ---$/d' \
	-e 's/ \[[^]]*\.csproj\]$//' \
	-e "s#$repo_root/##g" \
	-e '/^[[:space:]]*$/N;/^\n$/D' \
	-e '/(^|\n)Test run summary: /{:a;N;s/\n  ([a-z]+: )/, \1/;ta;s/\nTest run completed with non-success exit code:.*//}' \
	"$output" >&2

exit "$status"
