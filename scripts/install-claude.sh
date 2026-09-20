#!/usr/bin/env sh
# Install the skills in .agents/skills/ for Claude Code.
set -eu

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
. "$script_dir/lib.sh"

run_installer "$script_dir/.." 'Claude Code' \
  "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills" \
  'Claude Code discovers skills under ~/.claude/skills and .claude/skills in a project.' \
  "$@"
