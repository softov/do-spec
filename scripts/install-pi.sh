#!/usr/bin/env sh
# Install the skills in skills/ for pi.
set -eu

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
. "$script_dir/lib.sh"

run_installer "$script_dir/.." pi \
  "${PI_HOME:-$HOME/.pi}/agent/skills" \
  'pi discovers skills under ~/.pi/agent/skills and ~/.agents/skills.' \
  "$@"
