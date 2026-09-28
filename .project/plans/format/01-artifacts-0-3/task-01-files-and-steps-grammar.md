---
title: Files and Steps follow a fixed line grammar
status: doing
depends: []
layer: "skills/do-spec"
---

## Objective

Every line under a task's `## Files` and `## Steps` has one form the validator can parse, and the template and `SKILL.md` state it.

## Files

- `UPDATE: skills/do-spec/assets/task.md` - Files and Steps sections show the exact form.
- `UPDATE: skills/do-spec/SKILL.md` - a *Sections* part states the grammar.

## Steps

1. Define a Files line: ``- `<OP>: <path>[:<n>-<m>]` - <note>.`` with `OP` one of `CREATE`, `UPDATE`, `DELETE`; a line range only on `UPDATE`.
2. Define a Steps line: `<N>. <step>`, numbered from 1 with no gaps, one line each.
3. Write both into the template and into `SKILL.md`, per [files-and-steps-stay-markdown](../../../decisions/files-and-steps-stay-markdown.md).

## Validation

- Every task under `.project/plans/` in this repository matches the grammar by hand.

## Resume

Built 2026-09-28, awaiting Softov's review before `done`.
`SKILL.md` has a *Task sections* part with both grammars; the template's Files lines already matched, and its Steps placeholder now says one line.
The eight tasks in this plan were checked against the grammar with a regex: no violations.
