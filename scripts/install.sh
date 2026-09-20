#!/usr/bin/env sh
# Install the skills in .agents/skills/ for one or more agents.
#
# Usage: install.sh <agent> [<agent> ...] [installer options]
# Agents: codex claude pi vscode user all
#
# Options are forwarded to each per-agent installer; run one with --help for
# the full list.

set -eu

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
repo_root=$(CDPATH= cd "$script_dir/.." && pwd -P)

usage() {
  cat <<'EOF'
Install the skills in .agents/skills/ for one or more agents.

Usage: install.sh <agent> [<agent> ...] [options]

Agents:
  codex    OpenAI Codex              -> $CODEX_HOME/skills (~/.codex/skills)
  claude   Claude Code               -> ~/.claude/skills
  pi       pi                        -> ~/.pi/agent/skills
  vscode   VS Code (GitHub Copilot)  -> ~/.copilot/skills
  user     any Agent Skills client   -> ~/.agents/skills
  all      every agent above

Options, forwarded to each installer:
  --skill NAME  --dest DIR  --copy  --link  --force  --dry-run

Every skill in .agents/skills/ is installed unless --skill names one or more.

Examples:
  install.sh all
  install.sh claude --skill do-spec --link
  install.sh codex pi --force

List the agents and skills with --list.
EOF
}

case ${1:-} in
  -h|--help) usage; exit 0 ;;
  --list)
    printf 'Agents:\n  codex\n  claude\n  pi\n  vscode\n  user\n'
    printf 'Skills in .agents/skills/:\n'
    for manifest in "$repo_root"/.agents/skills/*/SKILL.md; do
      [ -f "$manifest" ] || continue
      printf '  %s\n' "$(basename "$(dirname "$manifest")")"
    done | sort
    exit 0
    ;;
  '') usage; exit 0 ;;
esac

agents=''
while [ "$#" -gt 0 ]; do
  case $1 in
    codex|claude|pi|vscode|user) agents="$agents $1"; shift ;;
    all) agents=' codex claude pi vscode user'; shift ;;
    *) break ;;
  esac
done

[ -n "$agents" ] || { usage; exit 2; }

for agent in $agents; do
  sh "$script_dir/install-$agent.sh" "$@"
done
