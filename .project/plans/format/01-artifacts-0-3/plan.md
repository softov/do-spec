---
title: Artifacts 0.3 - deterministic sections, spec deltas, validator, workflow skills
domain: format
status: active
priority: medium
created: 2026-09-27
revalidated: 2026-09-27
creates:
  - specs/validate.md
decisions:
  - decisions/files-and-steps-stay-markdown.md
  - decisions/spec-deltas-merge-in-place.md
  - decisions/workflow-as-separate-skills.md
  - decisions/validator-parses-yaml-with-cofold.md
refs:
  - "[code://skills/do-spec/SKILL.md](../../../../skills/do-spec/SKILL.md) - the 0.2 format this plan revises"
  - "[code://skills/do-spec/assets/task.md](../../../../skills/do-spec/assets/task.md) - Files, Steps and Validation sections that get a grammar"
  - "[code://skills/do-spec/assets/spec.md](../../../../skills/do-spec/assets/spec.md) - has WHEN/THEN scenarios, no named requirements"
  - "[code://skills/do-spec/assets/plan.md](../../../../skills/do-spec/assets/plan.md) - names specs in changes and creates, not what changes"
  - "[code://bin/do-skills.js](../../../../bin/do-skills.js) - the npx entry point the validate command joins"
  - npm://@cofold/yaml@^0.2.0 - the YAML parser validate loads
  - https://github.com/Fission-AI/OpenSpec - source of the delta, SHALL and workflow ideas
---

## Goal

Make `.project/` artifacts readable by a tool as well as by an agent.
Task files gain sections with a fixed grammar and typed fences, specs gain named `SHALL` requirements, and plans say exactly what they change in a spec.
A `do-skills validate` command checks all of it and exports the parsed record as JSON or HTML.
The work splits into stage skills so an agent loads only the stage it is in.

## Reconnaissance

The files read and the patterns to reuse are the `refs` above, each with its note.
[OpenSpec research](../../../research/openspec.md) holds what was taken from OpenSpec and where it conflicts.

### Runtime path

```
agent loads stage skill -> writes artifact from do-spec template -> do-skills validate -> errors | JSON | HTML
```

### Gaps

- No grammar under `## Files`, `## Steps`, `## Validation`.
- No named requirements in specs, so a change cannot address one.
- No validator; `bin/do-skills.js` only installs.

## Decisions locked in

| # | Decision | Rationale / source |
| --- | --- | --- |
| 1 | [Files and Steps stay Markdown under a strict line grammar; only data is fenced](../../../decisions/files-and-steps-stay-markdown.md) | Softov, 2026-09-27 |
| 2 | [A plan's spec deltas are merged into the spec in place when the plan closes, with no archive](../../../decisions/spec-deltas-merge-in-place.md) | Softov, 2026-09-27 |
| 3 | [Each workflow stage is its own skill, sharing do-spec's templates](../../../decisions/workflow-as-separate-skills.md) | Softov, 2026-09-27 |
| 4 | [The validator parses YAML with @cofold/yaml, loaded only by validate](../../../decisions/validator-parses-yaml-with-cofold.md) | Softov, 2026-09-27 |

| What | Source | Task |
| --- | --- | --- |
| Named `SHALL` requirements with `WHEN` / `THEN` scenarios | Softov chose "SHALL + WHEN/THEN", 2026-09-27 | 03 |
| A `validate` command in the npx package | Softov chose "Validator CLI", 2026-09-27 | 05 |
| Export the parsed record as structured data or HTML | Softov, 2026-09-27: "we could when reading it to validate to html or to a structured info... we could search for info like that" | 06 |
| The format version moves to 0.3 | the templates change shape | 08 |
| ` ```validations ` is optional; a task without one gets a warning, not an error | Softov chose "Optional, warn if missing", 2026-09-27 | 02, 05 |
| HTML export is one page for the whole `.project/`, plans linked to their tasks, decisions and specs | Softov chose "One page", 2026-09-27 | 06 |

## Proposed architecture

- **Data flow** - Markdown file -> frontmatter + sections + fences -> one record per artifact -> checks, JSON, HTML.
- **Layer responsibilities** - `skills/do-spec`: the format and templates · `skills/do-<stage>`: the steps of one stage · `bin/`: install and validate.
- **Source-of-truth files** - [`code://skills/do-spec/SKILL.md`](../../../../skills/do-spec/SKILL.md) defines the format; the validator follows it and never extends it.

## Tasks

| Task | Status | Depends on |
| --- | --- | --- |
| [01 - files-and-steps-grammar](task-01-files-and-steps-grammar.md) | doing | - |
| [02 - validations-fence](task-02-validations-fence.md) | todo | - |
| [03 - shall-requirements](task-03-shall-requirements.md) | todo | - |
| [04 - spec-deltas](task-04-spec-deltas.md) | todo | 03 |
| [05 - validator](task-05-validator.md) | todo | 01, 02, 03, 04 |
| [06 - export](task-06-export.md) | todo | 05 |
| [07 - workflow-skills](task-07-workflow-skills.md) | todo | 01, 02, 03, 04 |
| [08 - release-0-3](task-08-release-0-3.md) | todo | 05, 06, 07 |

## Risks and tradeoffs

- A strict grammar makes hand-written artifacts fail validation - the validator reports the line and the expected form, and templates show the form.
- Existing 0.2 projects (ahpd, ahpc, facio) would fail 0.3 checks - the validator reads `metadata.artifacts` and checks a 0.2 project against 0.2 rules.

## Resume state

- **Done so far:** task 01 built 2026-09-28, awaiting review.
- **Next action:** Softov reviews task 01; then [task-02-validations-fence.md](task-02-validations-fence.md).
- **Open questions:** none.
- **Watch out for:** `SKILL.md` stays the one definition of the format; stage skills and the validator point at it and restate nothing.
  Seven files in `skills/do-spec/` are CRLF and two are LF: an edit keeps each file's line endings, and the validator must accept both.

## Final verification checklist

- [ ] `do-skills validate` passes on this repository's own `.project/`.
- [ ] `do-skills validate` on a 0.2 project reports it as 0.2 and applies 0.2 rules.
- [ ] Every template in `skills/do-spec/assets/` validates once its placeholders are filled.
- [ ] `plans/index.md` updated.
