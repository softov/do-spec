#!/usr/bin/env pwsh
# Install the skills in skills/ for pi on Windows.
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

$default = if ($env:PI_HOME) { Join-Path $env:PI_HOME 'agent/skills' } else { Join-Path $HOME '.pi/agent/skills' }

Invoke-SkillInstaller -RepoRoot (Split-Path -Parent $PSScriptRoot) `
  -AgentLabel 'pi' `
  -DefaultSkillsDir $default `
  -Note 'pi discovers skills under %USERPROFILE%\.pi\agent\skills and %USERPROFILE%\.agents\skills.' `
  -ScriptName 'install-pi.ps1' `
  @PSBoundParameters
