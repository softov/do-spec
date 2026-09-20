#!/usr/bin/env pwsh
# Install the skills in .agents/skills/ for Claude Code on Windows.
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

$default = if ($env:CLAUDE_CONFIG_DIR) { Join-Path $env:CLAUDE_CONFIG_DIR 'skills' } else { Join-Path $HOME '.claude/skills' }

Invoke-SkillInstaller -RepoRoot (Split-Path -Parent $PSScriptRoot) `
  -AgentLabel 'Claude Code' `
  -DefaultSkillsDir $default `
  -Note 'Claude Code discovers skills under %USERPROFILE%\.claude\skills and .claude\skills in a project.' `
  -ScriptName 'install-claude.ps1' `
  @PSBoundParameters
