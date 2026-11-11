<#
.SYNOPSIS
    Sync upstream SHAs for AI customization files tracked via *.upstream.json sidecars.

.DESCRIPTION
    Recursively scans -Root for sidecar files named `upstream.json` or `*.upstream.json`.
    For each one:
      1. Resolve default branch + HEAD SHA via GitHub API.
      2. If HEAD == stored commit -> up to date.
      3. Otherwise look up the stored commit's date, open Chrome at
            https://github.com/{owner}/{repo}/commits/{branch}/{path}?since={yyyy-MM-dd}
         where the date is the day of the stored commit.
      4. Wait for Enter, then bump the sidecar's `commit` to HEAD.

    Sidecar schema:
      { "repo": "...", "path": "...", "commit": "<sha>", "branch": "main" }
    `branch` is optional; if absent it is resolved from the repo's default branch
    on first run and written back to the sidecar.

    If $env:GITHUB_TOKEN is set it is used to lift API rate limits.

.PARAMETER Root
    Directory to scan. Defaults to the `upstreams` folder next to this script.
#>
[CmdletBinding()]
param(
    [string]$Root = (Join-Path $PSScriptRoot 'upstreams')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RequiredFields = @('repo', 'path', 'commit')

# ---------------------------------------------------------------------------
# GitHub API
# ---------------------------------------------------------------------------

function Invoke-GitHub {
    param([Parameter(Mandatory)][string]$Uri)

    $headers = @{
        'Accept'               = 'application/vnd.github+json'
        'X-GitHub-Api-Version' = '2022-11-28'
        'User-Agent'           = 'sync-upstream-script'
    }
    if ($env:GITHUB_TOKEN) { $headers['Authorization'] = "Bearer $env:GITHUB_TOKEN" }

    Invoke-RestMethod -Uri $Uri -Headers $headers -Method GET
}

function Get-OwnerRepo {
    param([Parameter(Mandatory)][string]$Url)
    if ($Url -notmatch '^https?://github\.com/([^/]+)/([^/]+?)(?:\.git)?/?$') {
        throw "Not a GitHub HTTPS URL: $Url"
    }
    [pscustomobject]@{ Owner = $Matches[1]; Repo = $Matches[2] }
}

function Get-DefaultBranch {
    param([Parameter(Mandatory)]$OwnerRepo)
    (Invoke-GitHub "https://api.github.com/repos/$($OwnerRepo.Owner)/$($OwnerRepo.Repo)").default_branch
}

function Get-BranchHead {
    param(
        [Parameter(Mandatory)]$OwnerRepo,
        [Parameter(Mandatory)][string]$Branch
    )
    (Invoke-GitHub "https://api.github.com/repos/$($OwnerRepo.Owner)/$($OwnerRepo.Repo)/commits/$Branch").sha
}

function Get-CommitDate {
    param(
        [Parameter(Mandatory)]$OwnerRepo,
        [Parameter(Mandatory)][string]$Sha
    )
    $commit = Invoke-GitHub "https://api.github.com/repos/$($OwnerRepo.Owner)/$($OwnerRepo.Repo)/commits/$Sha"
    # ConvertFrom-Json may auto-parse the ISO 8601 string into a [datetime]; handle both.
    $raw = $commit.commit.committer.date
    if ($raw -is [datetime]) { $raw.ToUniversalTime() }
    else { [datetime]::Parse([string]$raw, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind).ToUniversalTime() }
}

# ---------------------------------------------------------------------------
# Sidecar I/O
# ---------------------------------------------------------------------------

function Read-Sidecar {
    param([Parameter(Mandatory)][string]$Path)

    $data = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    foreach ($field in $RequiredFields) {
        $hasField = $data.PSObject.Properties[$field]
        if (-not $hasField -or [string]::IsNullOrWhiteSpace([string]$data.$field)) {
            throw "Missing required field '$field'."
        }
    }
    $data
}

function Save-Sidecar {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][pscustomobject]$Data
    )
    $json = $Data | ConvertTo-Json -Depth 10
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, $json + [Environment]::NewLine, $utf8NoBom)
}

function Get-CommitsSinceUrl {
    param($OwnerRepo, [string]$Branch, [string]$Path, [datetime]$Since)
    $date = $Since.ToString('yyyy-MM-dd')
    "https://github.com/$($OwnerRepo.Owner)/$($OwnerRepo.Repo)/commits/$Branch/$Path`?since=$date"
}

# ---------------------------------------------------------------------------
# Per-sidecar processing
# ---------------------------------------------------------------------------

# Returns one of: 'updated', 'up-to-date', 'error'.
function Sync-Sidecar {
    param(
        [Parameter(Mandatory)][System.IO.FileInfo]$File,
        [Parameter(Mandatory)][string]$WorkspaceRoot
    )

    $relPath = [System.IO.Path]::GetRelativePath($WorkspaceRoot, $File.FullName).Replace('\', '/')
    Write-Host ''
    Write-Host "=== $relPath ===" -ForegroundColor Cyan

    try {
        $data      = Read-Sidecar  -Path $File.FullName
        $ownerRepo = Get-OwnerRepo -Url  $data.repo

        $branchProp = $data.PSObject.Properties['branch']
        $branchCached = $branchProp -and -not [string]::IsNullOrWhiteSpace([string]$data.branch)
        if ($branchCached) {
            $branch = [string]$data.branch
        } else {
            $branch = Get-DefaultBranch -OwnerRepo $ownerRepo
            $data | Add-Member -NotePropertyName branch -NotePropertyValue $branch -Force
            Save-Sidecar -Path $File.FullName -Data $data
        }

        $newSha = Get-BranchHead -OwnerRepo $ownerRepo -Branch $branch
    } catch {
        Write-Warning $_
        return 'error'
    }

    $oldSha = [string]$data.commit

    if ($oldSha -eq $newSha) {
        Write-Host "up to date ($($newSha.Substring(0, 7)))" -ForegroundColor DarkGray
        return 'up-to-date'
    }

    try {
        $since = Get-CommitDate -OwnerRepo $ownerRepo -Sha $oldSha
    } catch {
        Write-Warning $_
        return 'error'
    }

    $url = Get-CommitsSinceUrl -OwnerRepo $ownerRepo -Branch $branch -Path $data.path -Since $since

    Write-Host "  path:    $($data.path)"
    Write-Host "  branch:  $branch"
    Write-Host "  $($oldSha.Substring(0, 7)) -> $($newSha.Substring(0, 7))"
    Write-Host "  url:     $url"

    Start-Process chrome $url | Out-Null
    Read-Host 'Press Enter when done reviewing (Ctrl+C to abort)' | Out-Null

    try {
        $data.commit = $newSha
        Save-Sidecar -Path $File.FullName -Data $data
        Write-Host 'updated' -ForegroundColor Green
        return 'updated'
    } catch {
        Write-Warning "Failed to write $($File.FullName): $_"
        return 'error'
    }
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if (-not (Test-Path -LiteralPath $Root)) {
    throw "Root not found: $Root"
}

$rootFull      = (Resolve-Path -LiteralPath $Root).Path
$workspaceRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path

$sidecars = Get-ChildItem -LiteralPath $rootFull -Recurse -File |
    Where-Object { $_.Name -eq 'upstream.json' -or $_.Name.EndsWith('.upstream.json') } |
    Sort-Object FullName

if (-not $sidecars) {
    Write-Host "No upstream.json / *.upstream.json sidecars found under $rootFull"
    return
}

$counts = @{ 'updated' = 0; 'up-to-date' = 0; 'error' = 0 }
foreach ($file in $sidecars) {
    $result = Sync-Sidecar -File $file -WorkspaceRoot $workspaceRoot
    $counts[$result]++
}

Write-Host ''
Write-Host ("Summary: {0} updated, {1} up-to-date, {2} errors" -f `
    $counts['updated'], $counts['up-to-date'], $counts['error'])
