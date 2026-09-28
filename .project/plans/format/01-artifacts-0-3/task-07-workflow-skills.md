---
title: Each workflow stage is its own skill
status: todo
depends: [task-01-files-and-steps-grammar.md, task-02-validations-fence.md, task-03-shall-requirements.md, task-04-spec-deltas.md]
layer: "skills"
---

## Objective

`do-explore`, `do-propose`, `do-apply` and `do-close` each hold one stage's steps and point at `do-spec` for the format.

## Files

- `CREATE: skills/do-explore/SKILL.md` - read the code and `.project/`, write research, raise problems.
- `CREATE: skills/do-propose/SKILL.md` - write the plan, its tasks, decisions and deltas.
- `CREATE: skills/do-apply/SKILL.md` - work one task: status, Files, Steps, validations, Resume.
- `CREATE: skills/do-close/SKILL.md` - apply deltas, write implemented and deferred, close the plan.

## Steps

1. Write each skill with a description that triggers on its stage only.
2. Point every one at `do-spec` for paths, templates and conventions, per [workflow-as-separate-skills](../../../decisions/workflow-as-separate-skills.md).
3. Make the installers install `do-spec` whenever a stage skill is chosen.

## Validation

- `npx do-skills --list` shows all five skills.
- `--skill do-apply` also installs `do-spec`.

## Resume
