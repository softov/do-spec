---
title: The parsed record exports as JSON and HTML
status: todo
depends: [task-05-validator.md]
layer: "bin"
---

## Objective

`do-skills validate --json` prints the parsed record and `--html <file>` writes a page linking plans, tasks, decisions and specs, so the record can be searched without reading Markdown.

## Files

- `UPDATE: bin/validate.js` - `--json` and `--html` outputs.

## Steps

1. Emit the record from task 05 as JSON with a stable shape, documented in `specs/validate.md`.
2. Render one HTML page for the whole `.project/` from that record, plans linked to their tasks, decisions and specs, with no further dependency.

## Validation

- `--json` on this repository lists every task with its Files entries and validations.

## Resume
