# do-skills

Agent skills for the `.project/ artifacts` way of working: what a project is building lives in files an agent can read, and each skill teaches the agent to write those files.

Skills follow the [Agent Skills specification](https://agentskills.io/specification). A skill is a directory with a `SKILL.md` and whatever it needs beside it, so the same skill works in Codex, Claude Code, pi, VS Code and any other client that reads the standard.

## Skills

| Skill | Path | What it does |
| --- | --- | --- |
| `do-spec` | [skills/do-spec](skills/do-spec) | Creates and maintains `.project/` artifacts (plans with their task files, implemented and deferred records, domain references, specs, rules, decisions, problems, research) in the `.project/ artifacts` 0.2 format. |

```text
.
├── package.json              the published package, name: do-skills
├── bin/
│   └── do-skills.js          npx entry point, launches a platform installer
├── scripts/                  installers for every skill in this repository
│   ├── lib.sh                shared POSIX logic, not run directly
│   ├── install.sh            POSIX dispatcher: one or more agents
│   ├── install-<agent>.sh    one per agent
│   ├── lib.ps1               shared PowerShell logic, not run directly
│   ├── install.ps1           PowerShell dispatcher
│   └── install-<agent>.ps1   one per agent
└── skills/
    └── do-spec/
        ├── SKILL.md          instructions the agent loads
        └── assets/           the file templates it writes from
```

`skills/<name>/SKILL.md` is the layout clients and installers expect: the specification requires a skill's `name` to match its parent directory, and a skill directory is what every client scans for. Adding a skill is dropping a directory with a `SKILL.md` under `skills/`; the installers find it on their own.

The installers live at the root because they cover every skill, not one of them.

## Install

Each agent reads skills from its own directory, and one script installs the skills for one agent. By default it installs every skill in `skills/`; `--skill` (PowerShell: `-Skill`) limits it to one or more. The default is a copy. The link option points the agent at the skill directory in this repository instead, so edits there show up immediately.

### With npx

The package is published as [`do-skills`](https://www.npmjs.com/package/do-skills) and ships the skills and the installers together, so npx needs nothing else on the machine.

```sh
# the agents already configured on this machine, else ~/.agents/skills
npx do-skills

# one agent
npx do-skills claude

# two agents, one skill, linked
npx do-skills codex pi --skill do-spec --link

# straight from the repository, no publish needed
npx github:softov/do-skills claude
```

With no agent named, the CLI installs for whichever of `~/.codex`, `~/.claude`, `~/.pi`, `~/.copilot` and `~/.agents` already exist, falling back to `~/.agents/skills` when none do. It prints which agents it chose.

| Option | Meaning |
| --- | --- |
| `-a`, `--agent NAME` | agent to install for; repeatable or comma-separated |
| `-s`, `--skill NAME` | skill to install; repeatable or comma-separated (default: every skill) |
| `-d`, `--dest DIR` | skills directory to install into |
| `--link` | link the skill directories instead of copying |
| `--copy` | copy the skill directories (default) |
| `-f`, `--force` | replace existing installs |
| `--dry-run` | print what would happen and exit |
| `-l`, `--list` | list the agents and the skills in the package |
| `-h`, `--help` | usage |

The CLI is a launcher, not a third implementation. It resolves the agent and the skills, then runs the `sh` or `ps1` installer that ships in `scripts/`, so its behavior cannot drift from the scripts below.

#### If npx refuses or cannot authenticate

Two things bite people on npm 12, and neither is this package.

`EALLOWGIT: Fetching packages of type "git" have been disabled` means npm's `allow-git` is `none`, which is the npm 12 default, so it refuses every git spec. Pass `--allow-git=all` for one run, or persist it with `npm config set allow-git=all`. Once `do-skills` is on the registry, `npx do-skills` needs neither, because it is no longer a git spec.

A private repository is the second: `npx github:` clones over HTTPS, so it needs git credentials. Run `gh auth setup-git` once, or make the repository public. Never pass a token as a command argument, because npx echoes its arguments and `--token gho_...` ends up in your terminal and your logs; use a credential helper instead.

```sh
gh auth setup-git
npx --allow-git=all github:softov/do-skills claude
```

Without npm at all, the same files come from a tarball, which needs no `allow-git` and no git. Drop the `-H` header once the repository is public:

```sh
tmp=$(mktemp -d)
curl -fsSL -H "Authorization: token $(gh auth token)" \
  https://codeload.github.com/softov/do-skills/tar.gz/refs/heads/main -o "$tmp/do-skills.tgz"
mkdir -p "$tmp/src" && tar xzf "$tmp/do-skills.tgz" -C "$tmp/src" --strip-components=1
"$tmp/src/scripts/install-claude.sh"
```

### Universal installer

[`agent-skills-cli`](https://www.npmjs.com/package/agent-skills-cli) installs skills for many agents and reads the same Agent Skills layout, so `do-spec` passes its `validate`. Point it at the skill directory, not at the repository:

```sh
# from a clone, works today; installs into the project unless -g is passed
npx agent-skills-cli install ./skills/do-spec -a claude

# from GitHub, once the repository is public
npx agent-skills-cli install-url https://github.com/softov/do-skills/tree/main/skills/do-spec
```

`install` is also spelled `add` and `i`. `-a` takes one or more agents (`-a claude,cursor`), `--all` targets every agent the CLI knows, and `-g` installs user-wide instead of into the current project.

`install-url` fetches `SKILL.md` from `raw.githubusercontent.com`, which needs no credentials only while the repository is public. A private repository can use the first form from a clone.

Do not hand it the repository URL. `npx agent-skills-cli install https://github.com/softov/do-skills` treats the whole repository as one skill named after the repository, so it copies `.git`, `bin/` and `scripts/` and leaves `SKILL.md` where no agent will load it. That is how the CLI handles a repository-root source, not a problem with this layout, and the two commands above avoid it.

### From a clone: macOS, Linux, WSL and Git Bash

| Agent | Script | Installs to |
| --- | --- | --- |
| Codex | `scripts/install-codex.sh` | `$CODEX_HOME/skills` (`~/.codex/skills`) |
| Claude Code | `scripts/install-claude.sh` | `${CLAUDE_CONFIG_DIR:-~/.claude}/skills` |
| pi | `scripts/install-pi.sh` | `~/.pi/agent/skills` |
| VS Code (GitHub Copilot) | `scripts/install-vscode.sh` | `~/.copilot/skills` |
| Any Agent Skills client | `scripts/install-user.sh` | `~/.agents/skills` |

```sh
# every skill, one agent
scripts/install-codex.sh

# one skill, symlinked while you are editing it
scripts/install-claude.sh --skill do-spec --link

# a specific skills directory
scripts/install-user.sh --dest .agents/skills

# see what every installer would do
scripts/install.sh all --dry-run
```

`scripts/install.sh` takes one or more agents (`codex`, `claude`, `pi`, `vscode`, `user`, or `all`) followed by installer options, and `--list` prints the agents and the skills found in `skills/`.

Under Git Bash and MSYS2, `--link` does not create a symlink: `ln -s` deep-copies by default, so it behaves like `--copy`. Real symlinks there need Developer Mode plus `MSYS=winsymlinks:nativestrict`, and an NTFS volume. Use WSL if you want `--link` to mean what it says.

### From a clone: Windows

| Agent | Script | Installs to |
| --- | --- | --- |
| Codex | `scripts\install-codex.ps1` | `%CODEX_HOME%\skills` (`%USERPROFILE%\.codex\skills`) |
| Claude Code | `scripts\install-claude.ps1` | `%CLAUDE_CONFIG_DIR%\skills` (`%USERPROFILE%\.claude\skills`) |
| pi | `scripts\install-pi.ps1` | `%USERPROFILE%\.pi\agent\skills` |
| VS Code (GitHub Copilot) | `scripts\install-vscode.ps1` | `%USERPROFILE%\.copilot\skills` |
| Any Agent Skills client | `scripts\install-user.ps1` | `%USERPROFILE%\.agents\skills` |

```powershell
# every skill, one agent
.\scripts\install-codex.ps1

# one skill, junctioned while you are editing it
.\scripts\install-claude.ps1 -Skill do-spec -Link

# see what every installer would do
.\scripts\install.ps1 all -DryRun
```

`scripts\install.ps1` mirrors the POSIX dispatcher, and `-List` prints the agents and skills.

`-Link` creates a directory junction, not a symlink. Junctions need no administrator rights or Developer Mode, unlike `New-Item -ItemType SymbolicLink`, and they require NTFS or ReFS, not FAT32 or exFAT.

If your execution policy blocks local scripts, run one through `powershell` directly:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-codex.ps1
```

### Script options

Both script families accept the same flags.

| POSIX | PowerShell | Meaning |
| --- | --- | --- |
| `--skill NAME` | `-Skill NAME` | install only this skill; repeat or comma-separate for more (default: every skill) |
| `--dest DIR` | `-Dest DIR` | skills directory to install into; each skill lands at `DIR/<name>` |
| `--copy` | `-Copy` | copy the skill directories (default) |
| `--link` | `-Link` | link the skill directories instead of copying |
| `--force` | `-Force` | replace existing installs |
| `--dry-run` | `-DryRun` | print what would happen and exit |
| `--list` | `-List` | list the skills found in `skills/` |
| `-h`, `--help` | `-Help` | usage |

The installers touch only `<DEST>/<skill>`. They never edit an agent's settings or a skill they did not install. Start a new agent session after installing so it picks up the skills.

### Manual install

Any client that reads Agent Skills works with a plain copy into the directory it scans.

```sh
# user level, every project
mkdir -p ~/.claude/skills
cp -R skills/do-spec ~/.claude/skills/do-spec

# project level, committed with the repository
mkdir -p "$PROJECT/.agents/skills"
cp -R skills/do-spec "$PROJECT/.agents/skills/do-spec"
```

```powershell
# user level, every project
New-Item -ItemType Directory -Force "$HOME\.claude\skills" | Out-Null
Copy-Item -Recurse skills\do-spec "$HOME\.claude\skills\do-spec"

# project level, committed with the repository
New-Item -ItemType Directory -Force "$PROJECT\.agents\skills" | Out-Null
Copy-Item -Recurse skills\do-spec "$PROJECT\.agents\skills\do-spec"
```

## Publishing

The package is unscoped and public. `files` whitelists `bin/`, `scripts/` and `skills/`, so the tarball carries the skills and the installers and nothing else.

```sh
npm pack --dry-run   # inspect exactly what would be published
npm publish          # after npm login
```

`prepublishOnly` lists the skills and fails the publish if `skills/` is missing or a skill has no `SKILL.md`.

## Reference links

`do-spec` writes a reference to local code as a Markdown link, so a `.project/` file opens the code it talks about. The link text stays `code://<path>#L<n>-L<m>` and the target is the same path relative to the file, which keeps `rg "code://..."` working as the index over `.project/`.

## License

MIT. See [LICENSE](LICENSE).
