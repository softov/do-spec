#!/usr/bin/env sh
# Install the skills in .agents/skills/ for OpenAI Codex.
set -eu

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
. "$script_dir/lib.sh"

run_installer "$script_dir/.." Codex \
  "${CODEX_HOME:-$HOME/.codex}/skills" \
  'Codex discovers skills under $CODEX_HOME/skills, one directory per skill.' \
  "$@"
