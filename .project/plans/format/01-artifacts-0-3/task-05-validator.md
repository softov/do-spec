---
title: do-skills validate checks a .project/ tree
status: todo
depends: [task-01-files-and-steps-grammar.md, task-02-validations-fence.md, task-03-shall-requirements.md, task-04-spec-deltas.md]
layer: "bin"
---

## Objective

`npx do-skills validate [dir]` parses every artifact and reports each violation with file, line and expected form; it exits non-zero on errors.

## Files

- `UPDATE: bin/do-skills.js` - the `validate` subcommand.
- `UPDATE: package.json` - `@cofold/yaml` as the one dependency.
- `CREATE: bin/validate.js` - the parser and the checks.
- `CREATE: .project/specs/validate.md` - the command's behaviour as SHALL requirements.

## Steps

1. Load `@cofold/yaml` with `import()` inside `validate` only, per [validator-parses-yaml-with-cofold](../../../decisions/validator-parses-yaml-with-cofold.md); on Node older than 22, say so and exit non-zero.
2. Parse frontmatter, headings, Files and Steps lines, and typed fences into one record per file.
3. Check paths per kind, required frontmatter, statuses, ref URIs, `code://` link depth, links that resolve, the Files and Steps grammar, fence schemas, deltas against `changes` and `creates`, task status against the plan table, and a warning for a task with no ` ```validations ` fence.
4. Read the format version and apply 0.2 rules to a 0.2 tree.

## Validation

- Passes on this repository's `.project/`.
- Fails with a line number on a task whose Files line has no `OP`.

## Resume
