#!/usr/bin/env pwsh
# Install the skills in .agents/skills/ for VS Code (GitHub Copilot) on Windows.
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

$default = if ($env:COPILOT_HOME) { Join-Path $env:COPILOT_HOME 'skills' } else { Join-Path $HOME '.copilot/skills' }

Invoke-SkillInstaller -RepoRoot (Split-Path -Parent $PSScriptRoot) `
  -AgentLabel 'VS Code' `
  -DefaultSkillsDir $default `
  -Note 'VS Code discovers personal skills under %USERPROFILE%\.copilot\skills, .claude\skills and .agents\skills.' `
  -ScriptName 'install-vscode.ps1' `
  @PSBoundParameters
