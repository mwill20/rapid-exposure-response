<#
.SYNOPSIS
  Validates Get-RERUpdate.ps1: PSScriptAnalyzer (Warning and Error), Pester tests, and optionally a live run.
.DESCRIPTION
  Runs under Windows PowerShell 5.1 and PowerShell 7. Installs PSScriptAnalyzer and Pester 5 to the
  current user if missing. Exits non-zero on any analyzer finding or test failure.
  -Live downloads the latest real release of Owner/Repo into a temp folder, verifies, extracts, and
  checks the result. Use only after a release exists.
.EXAMPLE
  ./work-side/Test-Updater.ps1
.EXAMPLE
  ./work-side/Test-Updater.ps1 -Live -Owner your-github-user -Repo rapid-exposure-response
#>
[CmdletBinding()]
param(
  [switch]$Live,
  [string]$Owner,
  [string]$Repo
)
$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'
$here = $PSScriptRoot
$script = Join-Path $here 'Get-RERUpdate.ps1'
$failed = $false

function Install-RequiredModule([string]$Name, [version]$MinVersion) {
  $have = Get-Module -ListAvailable -Name $Name | Where-Object { $_.Version -ge $MinVersion } | Select-Object -First 1
  if (-not $have) {
    Write-Information "Installing $Name >= $MinVersion for the current user"
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
      Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
    }
    Install-Module -Name $Name -MinimumVersion $MinVersion -Force -Scope CurrentUser -SkipPublisherCheck -AllowClobber
  }
  Import-Module $Name -MinimumVersion $MinVersion -Force
}

Write-Information "PowerShell $($PSVersionTable.PSVersion) ($($PSVersionTable.PSEdition))"

Install-RequiredModule -Name PSScriptAnalyzer -MinVersion '1.21.0'
Write-Information '--- PSScriptAnalyzer'
$findings = Invoke-ScriptAnalyzer -Path $script -Severity Warning, Error -Recurse:$false
if ($findings) {
  $findings | Format-Table RuleName, Severity, Line, Message -AutoSize | Out-String | Write-Information
  Write-Information "FAIL: $($findings.Count) analyzer finding(s)"
  $failed = $true
} else {
  Write-Information 'PSScriptAnalyzer: clean'
}

Install-RequiredModule -Name Pester -MinVersion '5.0.0'
Write-Information '--- Pester'
$cfg = New-PesterConfiguration
$cfg.Run.Path = (Join-Path $here 'Get-RERUpdate.Tests.ps1')
$cfg.Run.PassThru = $true
$cfg.Output.Verbosity = 'Detailed'
$result = Invoke-Pester -Configuration $cfg
if ($result.FailedCount -gt 0 -or $result.TotalCount -eq 0) {
  Write-Information "FAIL: Pester $($result.FailedCount) failed of $($result.TotalCount)"
  $failed = $true
}

if ($Live) {
  if (-not $Owner -or -not $Repo) { throw '-Live requires -Owner and -Repo' }
  Write-Information "--- Live run against $Owner/$Repo"
  $dest = Join-Path ([IO.Path]::GetTempPath()) ("rer-live-" + [Guid]::NewGuid())
  try {
    & $script -Owner $Owner -Repo $Repo -Destination $dest
    $current = (Get-Content (Join-Path $dest 'upstream\CURRENT.txt')).Trim()
    $kitVersion = (Get-Content (Join-Path $dest "upstream\$current\VERSION")).Trim()
    if ("v$kitVersion" -ne $current) { throw "VERSION inside the kit ($kitVersion) does not match the tag ($current)" }
    foreach ($must in @('playbook\RER_Playbook.docx', 'packs\EVENT_PACK_TEMPLATE.docx', 'tracker\RER_Tracker.xlsx', 'SHA256SUMS.txt')) {
      $p = Join-Path $dest "upstream\$current\$must"
      if ($must -eq 'SHA256SUMS.txt') { continue }
      if (-not (Test-Path $p)) { throw "Missing from kit: $must" }
    }
    Write-Information "Live run OK: $current installed, kit contents present"
  } catch {
    Write-Information "FAIL: live run: $($_.Exception.Message)"
    $failed = $true
  } finally {
    Remove-Item -Recurse -Force $dest -ErrorAction SilentlyContinue
  }
}

if ($failed) { exit 1 }
Write-Information 'Test-Updater: all checks passed'
exit 0
