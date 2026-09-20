#!/usr/bin/env sh
# Shared logic for the dospec installers.
#
# Sourced by install-<agent>.sh, never run directly. An installer ends with:
#
#   run_installer <repo-root> <agent-label> <default-skills-dir> <note> [options]
#
# Every skill in <repo-root>/.agents/skills/ is installed as <skills-dir>/<skill>,
# unless one or more --skill names are given.

die() {
  printf 'dospec: error: %s\n' "$*" >&2
  exit 1
}

info() {
  printf 'dospec: %s\n' "$*"
}

# Print the name of every skill in <repo-root>/.agents/skills, one per line.
discover_skills() {
  for manifest in "$1"/.agents/skills/*/SKILL.md; do
    [ -f "$manifest" ] || continue
    basename "$(dirname "$manifest")"
  done | sort
}

list_skills() {
  printf 'skills in %s/.agents/skills:\n' "$REPO_ROOT"
  discover_skills "$REPO_ROOT" | sed 's/^/  /'
}

usage() {
  cat <<EOF
Install skills for $AGENT_LABEL.

Usage: $(basename "$0") [options]

Options:
  --skill NAME  install only this skill; repeatable (default: every skill)
  --dest DIR    skills directory to install into (default: $DEFAULT_SKILLS_DIR)
  --copy        copy each skill directory (default)
  --link        symlink each skill directory instead of copying
  --force       replace existing installs
  --dry-run     print what would happen and exit
  --list        list the skills found in $REPO_ROOT/.agents/skills
  -h, --help    show this help

Each skill <name> is installed at <DEST>/<name>.
$NOTE
EOF
}

# Print <path> as an absolute path, expanding a leading ~, without requiring
# the last component to exist yet.
absolute_dir() {
  case $1 in
    '~') set -- "$HOME" ;;
    '~/'*) set -- "$HOME/${1#\~/}" ;;
  esac
  case $1 in
    /*) printf '%s' "$1" ;;
    *)
      parent=$(dirname "$1")
      base=$(basename "$1")
      if [ -d "$parent" ]; then
        printf '%s/%s' "$(CDPATH= cd "$parent" && pwd -P)" "$base"
      else
        printf '%s/%s' "$(pwd -P)" "$1"
      fi
      ;;
  esac
}

run_installer() {
  [ "$#" -ge 4 ] || die 'run_installer needs at least 4 arguments'
  REPO_ROOT=$(CDPATH= cd "$1" && pwd -P) || die "no such directory: $1"
  AGENT_LABEL=$2
  DEFAULT_SKILLS_DIR=$3
  NOTE=$4
  shift 4

  skills_dir=$DEFAULT_SKILLS_DIR
  mode=copy
  force=0
  dry_run=0
  selection=''

  while [ "$#" -gt 0 ]; do
    case $1 in
      --skill)
        [ "$#" -ge 2 ] || die '--skill needs a name'
        selection="$selection $2"
        shift 2
        ;;
      --skill=*) selection="$selection ${1#--skill=}"; shift ;;
      --dest)
        [ "$#" -ge 2 ] || die '--dest needs a directory'
        skills_dir=$2
        shift 2
        ;;
      --dest=*) skills_dir=${1#--dest=}; shift ;;
      --copy) mode=copy; shift ;;
      --link) mode=link; shift ;;
      --force) force=1; shift ;;
      --dry-run) dry_run=1; shift ;;
      --list) list_skills; return 0 ;;
      -h|--help) usage; return 0 ;;
      *) die "unknown option: $1 (try --help)" ;;
    esac
  done

  [ -d "$REPO_ROOT/.agents/skills" ] || die "no .agents/skills directory in $REPO_ROOT"
  available=$(discover_skills "$REPO_ROOT")
  [ -n "$available" ] || die "no skills found in $REPO_ROOT/.agents/skills"

  if [ -n "$selection" ]; then
    for name in $selection; do
      printf '%s\n' "$available" | grep -qx "$name" || die "unknown skill: $name (try --list)"
    done
    install_list=$(printf '%s\n' "$selection" | tr ' ' '\n' | sort -u)
  else
    install_list=$available
  fi

  skills_dir=$(absolute_dir "$skills_dir")

  # Refuse the whole run before touching anything if one destination is in the way.
  for name in $install_list; do
    src=$REPO_ROOT/.agents/skills/$name
    dest=$skills_dir/$name
    [ "$src" != "$dest" ] || die "the install target is the source directory: $src"
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      [ "$force" -eq 1 ] || die "$dest already exists; rerun with --force to replace it"
    fi
  done

  if [ "$dry_run" -eq 1 ]; then
    for name in $install_list; do
      info "dry run: would $mode $REPO_ROOT/.agents/skills/$name to $skills_dir/$name"
    done
    return 0
  fi

  mkdir -p "$skills_dir"
  installed=0
  for name in $install_list; do
    src=$(CDPATH= cd "$REPO_ROOT/.agents/skills/$name" && pwd -P)
    dest=$skills_dir/$name
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      rm -rf "$dest"
    fi
    if [ "$mode" = link ]; then
      ln -s "$src" "$dest"
    else
      cp -R "$src" "$dest"
    fi
    info "installed $dest"
    installed=$((installed + 1))
  done

  info "$installed skill(s) installed for $AGENT_LABEL in $skills_dir."
  info "$NOTE"
  info "Start a new $AGENT_LABEL session to load them."
}
