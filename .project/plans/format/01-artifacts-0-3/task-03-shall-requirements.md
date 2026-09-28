---
title: Specs hold named SHALL requirements with scenarios
status: todo
depends: []
layer: "skills/do-spec"
---

## Objective

A spec lists named requirements, each a `SHALL` sentence with its `WHEN` / `THEN` scenarios, so a plan can address one by name.

## Files

- `UPDATE: skills/do-spec/assets/spec.md` - `## Requirements`, each `### Requirement: <name>` with `#### Scenario: <name>` under it.
- `UPDATE: skills/do-spec/SKILL.md` - how requirements are named and worded.

## Steps

1. Replace `## Scenarios` in the template with requirements that own their scenarios.
2. State the wording: `The <subject> SHALL <behaviour>.`, one per requirement.
3. State that a requirement name is unique within its spec.

## Validation

- The template read top to bottom gives a requirement, its sentence, and two scenarios.

## Resume
