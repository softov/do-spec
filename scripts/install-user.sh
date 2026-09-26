#!/usr/bin/env sh
# Install the skills in skills/ for any client that reads the Agent Skills standard.
set -eu

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
. "$script_dir/lib.sh"

run_installer "$script_dir/.." 'Agent Skills client' \
  "${AGENTS_HOME:-$HOME/.agents}/skills" \
  'The standard location ~/.agents/skills is read by pi, VS Code and other clients.' \
  "$@"
