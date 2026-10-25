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
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$api = "https://api.github.com/repos/$Owner/$Repo/releases/latest"
$release = Invoke-RestMethod -Uri $api -Headers @{ 'User-Agent' = 'RER-Updater' }
$version = $release.tag_name
$zipAsset = $release.assets | Where-Object { $_.name -like 'rer-kit-*.zip' } | Select-Object -First 1
$sumAsset = $release.assets | Where-Object { $_.name -eq 'SHA256SUMS.txt' } | Select-Object -First 1
if (-not $zipAsset -or -not $sumAsset) { throw "Release $version is missing the kit zip or SHA256SUMS.txt" }

$target = Join-Path $Destination "upstream\$version"
if (Test-Path $target) { Write-Host "Already have $version at $target. Nothing to do."; return }

$tmp = Join-Path ([IO.Path]::GetTempPath()) ("rer-" + [Guid]::NewGuid())
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
  $zipPath = Join-Path $tmp $zipAsset.name
  $sumPath = Join-Path $tmp 'SHA256SUMS.txt'
  Invoke-WebRequest -Uri $zipAsset.browser_download_url -OutFile $zipPath -UseBasicParsing
  Invoke-WebRequest -Uri $sumAsset.browser_download_url -OutFile $sumPath -UseBasicParsing

  $expected = (Get-Content $sumPath | Where-Object { $_ -match [regex]::Escape($zipAsset.name) }) -split '\s+' | Select-Object -First 1
  $actual = (Get-FileHash $zipPath -Algorithm SHA256).Hash
  if (-not $expected -or ($expected.ToUpper() -ne $actual.ToUpper())) { throw "Checksum mismatch. Do not use this release." }

  New-Item -ItemType Directory -Path $target -Force | Out-Null
  Expand-Archive -Path $zipPath -DestinationPath $target
  Set-Content -Path (Join-Path $Destination 'upstream\CURRENT.txt') -Value $version
  Write-Host "Installed $version to $target"
  Write-Host "Next: read CHANGELOG.md, then run the UPSTREAM-DIFF prompt in Copilot."
}
finally {
  Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}
