# Shared logic for the do-skills installers on Windows (Windows PowerShell 5.1 and PowerShell 7+).
#
# Dot-sourced by install-<agent>.ps1, never run directly. An installer calls:
#
#   Invoke-SkillInstaller -RepoRoot <dir> -AgentLabel <name> -DefaultSkillsDir <dir>
#     -Note <text> -ScriptName <file> @PSBoundParameters
#
# Every skill in <RepoRoot>\skills is installed as <SkillsDir>\<skill>,
# unless -Skill names one or more.

Set-StrictMode -Version Latest

function Get-SkillNames {
  [CmdletBinding()]
  param([Parameter(Mandatory)][string]$RepoRoot)

  $skillsRoot = Join-Path $RepoRoot 'skills'
  if (-not (Test-Path -LiteralPath $skillsRoot -PathType Container)) {
    throw "no skills/ directory in $RepoRoot"
  }

  $names = @(
    Get-ChildItem -LiteralPath $skillsRoot -Directory |
      Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') -PathType Leaf } |
      Select-Object -ExpandProperty Name |
      Sort-Object
  )
  if ($names.Count -eq 0) {
    throw "no skills found in $skillsRoot"
  }
  return $names
}

function Resolve-Directory {
  [CmdletBinding()]
  param([Parameter(Mandatory)][string]$Path)

  $value = $Path
  if ($value -eq '~') { return $HOME }
  if ($value.StartsWith('~/') -or $value.StartsWith('~\')) {
    $value = Join-Path $HOME $value.Substring(2)
  }
  if ([System.IO.Path]::IsPathRooted($value)) {
    return [System.IO.Path]::GetFullPath($value)
  }
  return [System.IO.Path]::GetFullPath((Join-Path (Get-Location).ProviderPath $value))
}

function Show-InstallerUsage {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][string]$ScriptName,
    [Parameter(Mandatory)][string]$AgentLabel,
    [Parameter(Mandatory)][string]$DefaultSkillsDir,
    [Parameter(Mandatory)][string]$Note
  )

  @"
Install skills for $AgentLabel.

Usage: $ScriptName [options]

Options:
  -Skill NAME  install only this skill; comma-separated or repeatable (default: every skill)
  -Dest DIR    skills directory to install into (default: $DefaultSkillsDir)
  -Copy        copy each skill directory (default)
  -Link        create a directory junction instead of copying, needs no admin
  -Force       replace existing installs
  -DryRun      print what would happen and exit
  -List        list the skills found in skills
  -Help        show this help

Each skill <name> is installed at <DEST>\<name>.
$Note
"@
}

function Invoke-SkillInstaller {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)][string]$RepoRoot,
    [Parameter(Mandatory)][string]$AgentLabel,
    [Parameter(Mandatory)][string]$DefaultSkillsDir,
    [Parameter(Mandatory)][string]$Note,
    [Parameter(Mandatory)][string]$ScriptName,
    [string[]]$Skill,
    [string]$Dest,
    [switch]$Link,
    [switch]$Copy,
    [switch]$Force,
    [switch]$DryRun,
    [switch]$List,
    [switch]$Help
  )

  if ($Help) {
    Show-InstallerUsage -ScriptName $ScriptName -AgentLabel $AgentLabel -DefaultSkillsDir $DefaultSkillsDir -Note $Note
    return
  }

  $available = @(Get-SkillNames -RepoRoot $RepoRoot)

  if ($List) {
    Write-Host "skills in $(Join-Path $RepoRoot 'skills'):"
    foreach ($name in $available) { Write-Host "  $name" }
    return
  }

  # -Skill accepts repeated values and comma or space separated strings.
  $requested = @()
  if ($PSBoundParameters.ContainsKey('Skill')) {
    foreach ($item in $Skill) {
      foreach ($part in ($item -split '[,\s]+')) {
        if ($part) { $requested += $part }
      }
    }
  }

  if ($requested.Count -gt 0) {
    foreach ($name in $requested) {
      if ($available -notcontains $name) { throw "unknown skill: $name (try -List)" }
    }
    $installList = @($requested | Select-Object -Unique)
  } else {
    $installList = $available
  }

  if ($PSBoundParameters.ContainsKey('Dest')) {
    $skillsDir = Resolve-Directory -Path $Dest
  } else {
    $skillsDir = Resolve-Directory -Path $DefaultSkillsDir
  }

  # Refuse the whole run before touching anything if one destination is in the way.
  foreach ($name in $installList) {
    $source = Join-Path (Join-Path $RepoRoot 'skills') $name
    $target = Join-Path $skillsDir $name
    if ($source -eq $target) { throw "the install target is the source directory: $source" }
    if (Test-Path -LiteralPath $target) {
      if (-not $Force) { throw "$target already exists; rerun with -Force to replace it" }
    }
  }

  $verb = if ($Link) { 'link' } else { 'copy' }
  if ($DryRun) {
    foreach ($name in $installList) {
      $source = Join-Path (Join-Path $RepoRoot 'skills') $name
      Write-Host "do-skills: dry run: would $verb $source to $(Join-Path $skillsDir $name)"
    }
    return
  }

  New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
  $installed = 0
  foreach ($name in $installList) {
    $source = Join-Path (Join-Path $RepoRoot 'skills') $name
    $target = Join-Path $skillsDir $name
    if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }

    if ($Link) {
      if ($env:OS -eq 'Windows_NT') {
        New-Item -ItemType Junction -Path $target -Target $source | Out-Null
      } else {
        New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
      }
    } else {
      Copy-Item -LiteralPath $source -Destination $target -Recurse -Force
    }

    Write-Host "do-skills: installed $target"
    $installed++
  }

  Write-Host "do-skills: $installed skill(s) installed for $AgentLabel in $skillsDir."
  Write-Host "do-skills: $Note"
  Write-Host "do-skills: Start a new $AgentLabel session to load them."
}
