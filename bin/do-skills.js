#!/usr/bin/env node
'use strict';

// npx entry point for the do-skills package.
//
// This is a launcher, not a third implementation: it resolves the agent and the
// skills, then runs the POSIX or PowerShell installer that ships in scripts/.
// Keeping one implementation per platform means the CLI cannot drift from them.

const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const ROOT = path.resolve(__dirname, '..');
const AGENT_NAMES = ['codex', 'claude', 'pi', 'vscode', 'user'];
const IS_WINDOWS = process.platform === 'win32';

function fail(message) {
  process.stderr.write(`do-skills: error: ${message}\n`);
  process.exit(1);
}

function splitList(value) {
  return value.split(/[,\s]+/).filter(Boolean);
}

// The directory each agent keeps its configuration in, before the skills subdirectory.
function agentBaseDir(agent) {
  switch (agent) {
    case 'codex':
      return process.env.CODEX_HOME || path.join(os.homedir(), '.codex');
    case 'claude':
      return process.env.CLAUDE_CONFIG_DIR || path.join(os.homedir(), '.claude');
    case 'pi':
      return process.env.PI_HOME || path.join(os.homedir(), '.pi');
    case 'vscode':
      return process.env.COPILOT_HOME || path.join(os.homedir(), '.copilot');
    case 'user':
      return process.env.AGENTS_HOME || path.join(os.homedir(), '.agents');
    default:
      return null;
  }
}

function discoverSkills() {
  const dir = path.join(ROOT, 'skills');
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    fail(`no skills/ directory in ${ROOT}`);
  }
  const skills = entries
    .filter((entry) => entry.isDirectory() && fs.existsSync(path.join(dir, entry.name, 'SKILL.md')))
    .map((entry) => entry.name)
    .sort();
  if (skills.length === 0) fail(`no skills found in ${dir}`);
  return skills;
}

// With no agent named, install for the agents already configured on this machine.
function detectAgents() {
  const found = AGENT_NAMES.filter((agent) => fs.existsSync(agentBaseDir(agent)));
  return found.length > 0 ? found : ['user'];
}

function parseArgs(argv) {
  const opts = {
    agents: [],
    skills: [],
    dest: null,
    link: false,
    force: false,
    dryRun: false,
    list: false,
    help: false,
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    const value = () => {
      if (i + 1 >= argv.length) fail(`${arg} needs a value`);
      return argv[++i];
    };

    if (arg === '-h' || arg === '--help') opts.help = true;
    else if (arg === '-l' || arg === '--list') opts.list = true;
    else if (arg === '--link') opts.link = true;
    else if (arg === '--copy') opts.link = false;
    else if (arg === '-f' || arg === '--force') opts.force = true;
    else if (arg === '--dry-run') opts.dryRun = true;
    else if (arg === '-a' || arg === '--agent') opts.agents.push(...splitList(value()));
    else if (arg.startsWith('--agent=')) opts.agents.push(...splitList(arg.slice('--agent='.length)));
    else if (arg === '-s' || arg === '--skill') opts.skills.push(...splitList(value()));
    else if (arg.startsWith('--skill=')) opts.skills.push(...splitList(arg.slice('--skill='.length)));
    else if (arg === '-d' || arg === '--dest') opts.dest = value();
    else if (arg.startsWith('--dest=')) opts.dest = arg.slice('--dest='.length);
    else if (arg.startsWith('-')) fail(`unknown option: ${arg} (try --help)`);
    else opts.agents.push(...splitList(arg));
  }

  return opts;
}

function helpText() {
  return `do-skills - install the do-skills Agent Skills

Usage:
  npx do-skills [agent ...] [options]
  npx github:softov/do-skills [agent ...] [options]

Agents:
  codex    OpenAI Codex              -> ~/.codex/skills
  claude   Claude Code               -> ~/.claude/skills
  pi       pi                        -> ~/.pi/agent/skills
  vscode   VS Code (GitHub Copilot)  -> ~/.copilot/skills
  user     any Agent Skills client   -> ~/.agents/skills
  all      every agent above
  default: the agents already configured on this machine, else "user"

Options:
  -a, --agent NAME  agent to install for; repeatable or comma-separated
  -s, --skill NAME  skill to install; repeatable or comma-separated (default: all)
  -d, --dest DIR    skills directory to install into
      --link        link the skill directories instead of copying
      --copy        copy the skill directories (default)
  -f, --force       replace existing installs
      --dry-run     print what would happen and exit
  -l, --list        list the agents and the skills in this package
  -h, --help        show this help

Examples:
  npx do-skills
  npx do-skills claude --link
  npx do-skills codex pi --skill do-spec
`;
}

function listText() {
  const lines = ['Agents:'];
  for (const agent of AGENT_NAMES) lines.push(`  ${agent}`);
  lines.push('Skills in this package:');
  for (const skill of discoverSkills()) lines.push(`  ${skill}`);
  return `${lines.join('\n')}\n`;
}

// Run the platform installer, translating this CLI's flags to its own.
function installerCommand(agent, opts) {
  const base = path.join(ROOT, 'scripts', `install-${agent}`);

  if (IS_WINDOWS) {
    const script = `${base}.ps1`;
    const args = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', script];
    for (const skill of opts.skills) args.push('-Skill', skill);
    if (opts.dest) args.push('-Dest', opts.dest);
    if (opts.link) args.push('-Link');
    if (opts.force) args.push('-Force');
    if (opts.dryRun) args.push('-DryRun');
    return { cmd: 'powershell.exe', args, script };
  }

  const script = `${base}.sh`;
  const args = [script];
  for (const skill of opts.skills) args.push('--skill', skill);
  if (opts.dest) args.push('--dest', opts.dest);
  if (opts.link) args.push('--link');
  if (opts.force) args.push('--force');
  if (opts.dryRun) args.push('--dry-run');
  return { cmd: 'sh', args, script };
}

function main() {
  const opts = parseArgs(process.argv.slice(2));

  if (opts.help) {
    process.stdout.write(helpText());
    return;
  }
  if (opts.list) {
    process.stdout.write(listText());
    return;
  }

  const available = discoverSkills();
  const requested = opts.skills.length > 0 ? opts.skills : available;
  for (const skill of requested) {
    if (!available.includes(skill)) fail(`unknown skill: ${skill} (try --list)`);
  }

  let agents = opts.agents.length > 0 ? opts.agents : detectAgents();
  if (agents.includes('all')) agents = AGENT_NAMES.slice();
  agents = [...new Set(agents)];
  for (const agent of agents) {
    if (!AGENT_NAMES.includes(agent)) fail(`unknown agent: ${agent} (try --list)`);
  }
  if (opts.agents.length === 0) {
    process.stdout.write(`do-skills: installing for ${agents.join(', ')} (use --agent to choose)\n`);
  }

  let failed = false;
  for (const agent of agents) {
    const { cmd, args, script } = installerCommand(agent, { ...opts, skills: requested });
    if (!fs.existsSync(script)) {
      process.stderr.write(`do-skills: missing installer ${script}\n`);
      failed = true;
      continue;
    }
    const result = spawnSync(cmd, args, { stdio: 'inherit' });
    if (result.error) {
      process.stderr.write(`do-skills: failed to run ${cmd}: ${result.error.message}\n`);
      failed = true;
    } else if (result.status !== 0) {
      failed = true;
    }
  }

  if (failed) process.exit(1);
}

main();
