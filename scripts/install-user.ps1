#!/usr/bin/env pwsh
# Install the skills in skills/ for any client that reads the Agent Skills standard, on Windows.
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

$default = if ($env:AGENTS_HOME) { Join-Path $env:AGENTS_HOME 'skills' } else { Join-Path $HOME '.agents/skills' }

Invoke-SkillInstaller -RepoRoot (Split-Path -Parent $PSScriptRoot) `
  -AgentLabel 'Agent Skills client' `
  -DefaultSkillsDir $default `
  -Note 'The standard location %USERPROFILE%\.agents\skills is read by pi, VS Code and other clients.' `
  -ScriptName 'install-user.ps1' `
  @PSBoundParameters
