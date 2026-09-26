#!/usr/bin/env pwsh
# Install the skills in skills/ for one or more agents on Windows.
#
# Usage: install.ps1 <agent> [<agent> ...] [options]
# Agents: codex claude pi vscode user all

[CmdletBinding()]
param(
  [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
  [string[]]$Agents,
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
$repoRoot = Split-Path -Parent $PSScriptRoot
$known = @('codex', 'claude', 'pi', 'vscode', 'user')

function Show-Usage {
  @"
Install the skills in skills/ for one or more agents.

Usage: install.ps1 <agent> [<agent> ...] [options]

Agents:
  codex    OpenAI Codex              -> %CODEX_HOME%\skills (%USERPROFILE%\.codex\skills)
  claude   Claude Code               -> %USERPROFILE%\.claude\skills
  pi       pi                        -> %USERPROFILE%\.pi\agent\skills
  vscode   VS Code (GitHub Copilot)  -> %USERPROFILE%\.copilot\skills
  user     any Agent Skills client   -> %USERPROFILE%\.agents\skills
  all      every agent above

Options, forwarded to each installer:
  -Skill NAME  -Dest DIR  -Copy  -Link  -Force  -DryRun

Every skill in skills/ is installed unless -Skill names one or more.

Examples:
  install.ps1 all
  install.ps1 claude -Skill do-spec -Link
  install.ps1 codex pi -Force

List the agents and skills with -List.
"@
}

if ($Help) { Show-Usage; return }

if ($List) {
  Write-Host 'Agents:'
  foreach ($agent in $known) { Write-Host "  $agent" }
  Write-Host 'Skills in skills/:'
  Get-ChildItem -LiteralPath (Join-Path $repoRoot 'skills') -Directory |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') -PathType Leaf } |
    Select-Object -ExpandProperty Name |
    Sort-Object |
    ForEach-Object { Write-Host "  $_" }
  return
}

$selected = @()
foreach ($entry in $Agents) {
  foreach ($part in ($entry -split '[,\s]+')) {
    if (-not $part) { continue }
    if ($part -eq 'all') { $selected += $known; continue }
    if ($known -notcontains $part) { throw "unknown agent: $part (try -List)" }
    $selected += $part
  }
}
$selected = @($selected | Select-Object -Unique)
if ($selected.Count -eq 0) { Show-Usage; exit 2 }

$forward = @{}
foreach ($key in @('Skill', 'Dest', 'Link', 'Copy', 'Force', 'DryRun')) {
  if ($PSBoundParameters.ContainsKey($key)) { $forward[$key] = $PSBoundParameters[$key] }
}

foreach ($agent in $selected) {
  & (Join-Path $PSScriptRoot "install-$agent.ps1") @forward
}
