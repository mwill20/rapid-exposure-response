<#
.SYNOPSIS
  Read-only updater: downloads the latest RER kit release from GitHub, verifies SHA256, and extracts it.
.DESCRIPTION
  One-way by design. No git, no credentials, no uploads. Works with a PUBLIC repo only.
  Never overwrites the org folder. Extracts to <Destination>\upstream\<version>.
  Check your organization's script and software policies before running.
.EXAMPLE
  .\Get-RERUpdate.ps1 -Owner "your-github-user" -Repo "rapid-exposure-response" -Destination "$env:OneDrive\RER"
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$Owner,
  [Parameter(Mandatory)][string]$Repo,
  [Parameter(Mandatory)][string]$Destination
)
$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Only plain owner/repo names reach the URL.
if ($Owner -notmatch '^[A-Za-z0-9](?:[A-Za-z0-9-]{0,38})$') { throw "Owner must be a GitHub user or org name." }
if ($Repo -notmatch '^[A-Za-z0-9._-]{1,100}$') { throw "Repo must be a GitHub repository name." }

$api = "https://api.github.com/repos/$Owner/$Repo/releases/latest"
$release = Invoke-RestMethod -Uri $api -Headers @{ 'User-Agent' = 'RER-Updater' }
$version = [string]$release.tag_name

# The tag becomes a folder name. Accept only vMAJOR.MINOR.PATCH so a crafted
# release can never write outside upstream\.
if ($version -notmatch '^v\d+\.\d+\.\d+$') { throw "Unexpected release tag '$version'. Expected vX.Y.Z. Do not use this release." }

$expectedZipName = "rer-kit-$version.zip"
$zipAsset = $release.assets | Where-Object { $_.name -eq $expectedZipName } | Select-Object -First 1
$sumAsset = $release.assets | Where-Object { $_.name -eq 'SHA256SUMS.txt' } | Select-Object -First 1
if (-not $zipAsset -or -not $sumAsset) { throw "Release $version is missing $expectedZipName or SHA256SUMS.txt" }

$upstream = Join-Path $Destination 'upstream'
$target = Join-Path $upstream $version
if (Test-Path $target) { Write-Information "Already have $version at $target. Nothing to do."; return }

$tmp = Join-Path ([IO.Path]::GetTempPath()) ("rer-" + [Guid]::NewGuid())
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
  $zipPath = Join-Path $tmp $zipAsset.name
  $sumPath = Join-Path $tmp 'SHA256SUMS.txt'
  Invoke-WebRequest -Uri $zipAsset.browser_download_url -OutFile $zipPath -UseBasicParsing
  Invoke-WebRequest -Uri $sumAsset.browser_download_url -OutFile $sumPath -UseBasicParsing

  # SHA256SUMS.txt lines look like: <64 hex>  <filename>
  $line = Get-Content $sumPath | Where-Object { $_ -match ('\s\*?' + [regex]::Escape($zipAsset.name) + '\s*$') } | Select-Object -First 1
  $expected = if ($line) { ($line -split '\s+')[0] } else { $null }
  $actual = (Get-FileHash $zipPath -Algorithm SHA256).Hash
  if (-not $expected -or $expected -notmatch '^[0-9A-Fa-f]{64}$' -or ($expected.ToUpper() -ne $actual.ToUpper())) {
    throw "Checksum mismatch for $($zipAsset.name). Do not use this release."
  }

  New-Item -ItemType Directory -Path $target -Force | Out-Null
  Expand-Archive -Path $zipPath -DestinationPath $target
  Set-Content -Path (Join-Path $upstream 'CURRENT.txt') -Value $version
  Write-Information "Installed $version to $target"
  Write-Information "Next: read CHANGELOG.md, then run the UPSTREAM-DIFF prompt in Copilot."
}
finally {
  Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}
