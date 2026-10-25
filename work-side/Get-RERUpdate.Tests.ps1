# Pester 5+ tests for Get-RERUpdate.ps1. Network calls are mocked; the happy
# path uses a real zip built in a temp folder so the hash check is exercised.
# Run via: ./work-side/Test-Updater.ps1
# Note: variables are plain (no $script:) because Pester mock bodies and helper
# functions see BeforeAll/BeforeEach variables through scope inheritance only.
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

BeforeAll {
  $Updater = Join-Path $PSScriptRoot 'Get-RERUpdate.ps1'
  $Fixture = Join-Path ([IO.Path]::GetTempPath()) ("rer-fixture-" + [Guid]::NewGuid())
  New-Item -ItemType Directory -Path $Fixture | Out-Null

  # A tiny kit: one VERSION file inside rer-kit-v9.9.9.zip
  $kit = Join-Path $Fixture 'kit'
  New-Item -ItemType Directory -Path $kit | Out-Null
  Set-Content -Path (Join-Path $kit 'VERSION') -Value '9.9.9'
  $FixtureZipName = 'rer-kit-v9.9.9.zip'
  $FixtureZip = Join-Path $Fixture $FixtureZipName
  Compress-Archive -Path (Join-Path $kit '*') -DestinationPath $FixtureZip
  $GoodHash = (Get-FileHash $FixtureZip -Algorithm SHA256).Hash.ToLower()
  $BadHash = ('0' * 64)

  function New-Release([string]$Tag, [string]$ZipAssetName) {
    if (-not $ZipAssetName) { $ZipAssetName = $FixtureZipName }
    [pscustomobject]@{
      tag_name = $Tag
      assets   = @(
        [pscustomobject]@{ name = $ZipAssetName;   browser_download_url = "https://example.org/$ZipAssetName" }
        [pscustomobject]@{ name = 'SHA256SUMS.txt'; browser_download_url = 'https://example.org/SHA256SUMS.txt' }
      )
    }
  }

  # Mock bodies for Invoke-WebRequest: write the sums file or copy the fixture zip.
  function Save-Download([string]$Uri, [string]$OutFile, [string]$SumsContent) {
    if ($Uri -like '*SHA256SUMS.txt') { Set-Content -Path $OutFile -Value $SumsContent }
    else { Copy-Item $FixtureZip $OutFile }
  }
}

AfterAll {
  Remove-Item -Recurse -Force $Fixture -ErrorAction SilentlyContinue
}

Describe 'Get-RERUpdate.ps1' {
  BeforeEach {
    $Dest = Join-Path $Fixture ("dest-" + [Guid]::NewGuid())
    New-Item -ItemType Directory -Path $Dest | Out-Null
    # An org folder that must survive untouched.
    New-Item -ItemType Directory -Path (Join-Path $Dest 'org') | Out-Null
    Set-Content -Path (Join-Path $Dest 'org\keep.txt') -Value 'org data'
    $GoodSums = "$GoodHash  $FixtureZipName"
    $BadSums = "$BadHash  $FixtureZipName"
    $WrongFileSums = "$GoodHash  other.zip"
  }

  Context 'happy path' {
    It 'downloads, verifies, extracts to upstream version folder and writes CURRENT.txt' {
      Mock Invoke-RestMethod { New-Release -Tag 'v9.9.9' }
      Mock Invoke-WebRequest { Save-Download -Uri $Uri -OutFile $OutFile -SumsContent $GoodSums }
      & $Updater -Owner 'example-owner' -Repo 'example-repo' -Destination $Dest
      (Join-Path $Dest 'upstream\v9.9.9\VERSION') | Should -Exist
      (Get-Content (Join-Path $Dest 'upstream\CURRENT.txt')).Trim() | Should -Be 'v9.9.9'
      (Get-Content (Join-Path $Dest 'org\keep.txt')) | Should -Be 'org data'
      Should -Invoke Invoke-WebRequest -Times 2 -Exactly
    }

    It 'is a no-op when the version is already present' {
      Mock Invoke-RestMethod { New-Release -Tag 'v9.9.9' }
      Mock Invoke-WebRequest { throw 'must not download' }
      New-Item -ItemType Directory -Path (Join-Path $Dest 'upstream\v9.9.9') -Force | Out-Null
      { & $Updater -Owner 'example-owner' -Repo 'example-repo' -Destination $Dest } | Should -Not -Throw
      Should -Invoke Invoke-WebRequest -Times 0
    }
  }

  Context 'should-fail paths' {
    It 'rejects a corrupted checksum and extracts nothing' {
      Mock Invoke-RestMethod { New-Release -Tag 'v9.9.9' }
      Mock Invoke-WebRequest { Save-Download -Uri $Uri -OutFile $OutFile -SumsContent $BadSums }
      { & $Updater -Owner 'example-owner' -Repo 'example-repo' -Destination $Dest } | Should -Throw '*Checksum mismatch*'
      (Join-Path $Dest 'upstream\v9.9.9') | Should -Not -Exist
      (Join-Path $Dest 'upstream\CURRENT.txt') | Should -Not -Exist
    }

    It 'rejects a checksum file that does not list the zip' {
      Mock Invoke-RestMethod { New-Release -Tag 'v9.9.9' }
      Mock Invoke-WebRequest { Save-Download -Uri $Uri -OutFile $OutFile -SumsContent $WrongFileSums }
      { & $Updater -Owner 'example-owner' -Repo 'example-repo' -Destination $Dest } | Should -Throw '*Checksum mismatch*'
    }

    It 'rejects a release tag that is not vX.Y.Z before downloading anything' {
      Mock Invoke-RestMethod { New-Release -Tag '..\..\evil' }
      Mock Invoke-WebRequest { throw 'must not download' }
      { & $Updater -Owner 'example-owner' -Repo 'example-repo' -Destination $Dest } | Should -Throw '*Unexpected release tag*'
      Should -Invoke Invoke-WebRequest -Times 0
    }

    It 'rejects a release whose zip asset name does not match the tag' {
      Mock Invoke-RestMethod { New-Release -Tag 'v9.9.9' -ZipAssetName 'rer-kit-v1.0.0.zip' }
      Mock Invoke-WebRequest { throw 'must not download' }
      { & $Updater -Owner 'example-owner' -Repo 'example-repo' -Destination $Dest } | Should -Throw '*missing rer-kit-v9.9.9.zip*'
      Should -Invoke Invoke-WebRequest -Times 0
    }

    It 'rejects owner or repo values that are not plain names' {
      Mock Invoke-RestMethod { throw 'must not call the API' }
      { & $Updater -Owner 'a/b' -Repo 'example-repo' -Destination $Dest } | Should -Throw '*Owner must be*'
      { & $Updater -Owner 'example-owner' -Repo 'r?x=1' -Destination $Dest } | Should -Throw '*Repo must be*'
      Should -Invoke Invoke-RestMethod -Times 0
    }
  }
}
