---
title: Each workflow stage is its own skill, sharing do-spec's templates
status: accepted
date: 2026-09-27
refs:
  - "[code://skills/do-spec/SKILL.md](../../skills/do-spec/SKILL.md) - the one skill that covers every stage today"
  - https://github.com/Fission-AI/OpenSpec - explore, propose, apply, archive
---

## Context

do-spec is one skill that loads its whole format for any `.project/` work.
OpenSpec splits the work into explore, propose, apply and archive, each a command with a narrow job.

## Decision

The stages are separate skills under `skills/`: `do-explore`, `do-propose`, `do-apply`, `do-close`.
Each one names the stage's steps and reads the format and templates from `do-spec`, which stays the single definition of the format.

Source: Softov, 2026-09-27, asked "Which OpenSpec ideas do you want to bring into do-spec?", chose "Workflow skills: split into explore/propose/apply/close skills under skills/, sharing do-spec's templates".

## Consequences

A client triggers the skill that matches the request, not the whole format.
Every stage skill depends on `do-spec` being installed beside it.

## Options

- One `do-spec` skill with stage sections: nothing to install together, but every request loads every stage.
