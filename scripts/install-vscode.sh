#!/usr/bin/env sh
# Install the skills in skills/ for VS Code (GitHub Copilot).
set -eu

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
. "$script_dir/lib.sh"

run_installer "$script_dir/.." 'VS Code' \
  "${COPILOT_HOME:-$HOME/.copilot}/skills" \
  'VS Code discovers personal skills under ~/.copilot/skills, ~/.claude/skills and ~/.agents/skills.' \
  "$@"
