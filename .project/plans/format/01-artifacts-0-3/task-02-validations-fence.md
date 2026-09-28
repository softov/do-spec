---
title: A task's checks are a validations fence
status: todo
depends: []
layer: "skills/do-spec"
---

## Objective

A task states its checks in a ` ```validations ` fence that a tool can read and run.

## Files

- `UPDATE: skills/do-spec/assets/task.md` - the Validation section holds the fence.
- `UPDATE: skills/do-spec/SKILL.md` - the fence schema.

## Steps

1. Define the schema: a YAML list; each item is one of `cmd` with optional `expect`, `test` with optional `cases`, or `manual`.
2. Put the fence in the template under `## Validation`.
3. State in `SKILL.md` that the fence is optional and that a task without one draws a warning.

## Validation

- The template's fence parses as YAML and matches the schema.

## Resume
