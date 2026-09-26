#!/usr/bin/env pwsh
# Install the skills in skills/ for OpenAI Codex on Windows.
[CmdletBinding()]
param(
  [string[]]$Skill,
  [string]$Dest,
  [switch]$Link,
  [switch]$Copy,
  [switch]$Force,
  [switch]$DryRun,
  [switch]$List,
  [switch]$Help
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib.ps1')

$default = if ($env:CODEX_HOME) { Join-Path $env:CODEX_HOME 'skills' } else { Join-Path $HOME '.codex/skills' }

Invoke-SkillInstaller -RepoRoot (Split-Path -Parent $PSScriptRoot) `
  -AgentLabel 'Codex' `
  -DefaultSkillsDir $default `
  -Note 'Codex discovers skills under %USERPROFILE%\.codex\skills, one directory per skill.' `
  -ScriptName 'install-codex.ps1' `
  @PSBoundParameters
