#!/usr/bin/env bash
# Style pass for coding agents: applies the repo's .editorconfig, then builds with every analyzer and IDE style rule on
# and prints what is left to fix by hand. Exit code 0 means nothing is left. Lives at the repo root, next to the solution.
# Written by the setup-akilin-skills skill, which replaces it when re-run.

set -e

cd "$(dirname "$0")"

# IDE0130 is excluded because dotnet format has no fix for it and crashes on it
# (https://github.com/dotnet/format/issues/1623). The build still reports it. Drop the exclusion once that issue is fixed.
dotnet format --exclude-diagnostics IDE0130 -v q

# --no-incremental: an up-to-date project isn't recompiled, so its violations would go unreported.
# The -p switches turn the rules on even where the repo's build turns them off for agents.
# -warnaserror, not the TreatWarningsAsErrors property (turned off here even when the repo sets it): the property fails the compiler,
# which keeps the projects depending on it from compiling, so only the lowest failing layer would be reported. The switch converts
# warnings to errors after compiling, so every project is still built and reported. Only safe with --no-incremental: the switch
# still writes the outputs, so an incremental rebuild skips the compiler and passes without reporting anything.
dotnet build --no-incremental -p:RunAnalyzersDuringBuild=true -p:EnforceCodeStyleInBuild=true -p:TreatWarningsAsErrors=false -warnaserror \
	-tl:off -v:q --nologo '-clp:ErrorsOnly;WarningsOnly;NoSummary'
