---
title: The validator parses YAML with @cofold/yaml, loaded only by validate
status: accepted
date: 2026-09-27
refs:
  - npm://@cofold/yaml@^0.2.0 - the YAML subset parser, zero dependencies, ESM, Node 22 or later
  - "[code://package.json](../../package.json) - do-skills has no dependencies, is CommonJS and allows Node 18"
---

## Context

Frontmatter and the ` ```validations ` fence are YAML, and do-skills has no dependencies.
`@cofold/yaml` parses a documented YAML subset with source-aware errors and has no dependencies of its own.
It is ESM and needs Node 22, while do-skills is CommonJS and its installers run on Node 18.

## Decision

`validate` parses YAML with `@cofold/yaml`, its only runtime dependency.
It is loaded with a dynamic `import()` inside `validate`, so installing skills never loads it and keeps working on Node 18.
Artifacts use only the YAML that `@cofold/yaml` documents.

Source: Softov, 2026-09-27, asked "The validator must parse YAML (frontmatter and the validations fence), and do-skills has zero dependencies. How?", answered "cofold?".

## Consequences

Parse errors carry a line and column into the validator's report.
`validate` needs Node 22 and says so when run on an older Node.
The format's YAML is bounded by what `@cofold/yaml` accepts.

## Options

- Hand-roll the subset in `bin/`: no dependency, but a second YAML parser to maintain.
- A general YAML package: full YAML, and a third-party dependency.
