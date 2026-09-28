---
title: Plans carry spec deltas that close merges in place
status: todo
depends: [task-03-shall-requirements.md]
layer: "skills/do-spec"
---

## Objective

A plan states what it changes in each spec as a ` ```delta ` block, and closing the plan applies it to the spec.

## Files

- `UPDATE: skills/do-spec/assets/plan.md` - a `## Spec changes` section with one delta fence per spec in `changes` or `creates`.
- `UPDATE: skills/do-spec/SKILL.md` - the delta form and the close step that applies it.

## Steps

1. Define the fence: info string `delta <spec path>`; entries `ADDED`, `MODIFIED` or `REMOVED` followed by a requirement name; `ADDED` and `MODIFIED` carry the full requirement with its scenarios.
2. Require one delta per spec named in `changes` or `creates`, and none for other specs.
3. Rewrite the close step: apply each delta to its spec and keep the plan in place, per [spec-deltas-merge-in-place](../../../decisions/spec-deltas-merge-in-place.md).

## Validation

- A delta written against the updated spec template applies to it by hand without ambiguity.

## Resume
