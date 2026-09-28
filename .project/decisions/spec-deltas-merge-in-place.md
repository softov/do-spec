---
title: A plan's spec deltas are merged into the spec in place when the plan closes, with no archive
status: accepted
date: 2026-09-27
refs:
  - "[code://skills/do-spec/SKILL.md](../../skills/do-spec/SKILL.md) - \"a path is an identity: nothing is moved\""
  - https://github.com/Fission-AI/OpenSpec - the archive step this departs from
---

## Context

OpenSpec keeps deltas in the change folder and, on archive, merges them into the specs and moves the change to a dated archive folder.
do-spec holds that a path is an identity and nothing is moved.

## Decision

A plan carries its spec changes as ` ```delta <spec> ` blocks in `plan.md`.
Closing the plan applies them to the named specs in place.
The plan folder stays where it is, with `status: built`; its deltas remain as the record of what it changed.

Source: Softov, 2026-09-27, asked "Which OpenSpec ideas do you want to bring into do-spec?", chose "Spec deltas in plans: a plan carries ADDED/MODIFIED/REMOVED requirements for each spec it changes; closing the plan merges them into the spec in place (no archive move)".

## Consequences

Links to a plan never break.
`plans/index.md` keeps built plans, filtered by status.

## Options

- OpenSpec's archive move: a tidy `plans/`, at the cost of every link into a finished plan.
