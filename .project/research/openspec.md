---
title: OpenSpec
refs:
  - https://github.com/Fission-AI/OpenSpec - the project read
---

OpenSpec keeps `openspec/specs/` for current behaviour and `openspec/changes/<name>/` for work in flight.
A change holds `proposal.md`, `design.md`, `tasks.md` and a `specs/` folder of deltas.
A delta lists requirements under `ADDED`, `MODIFIED` and `REMOVED`.
A requirement reads `The system SHALL <capability>` and carries `WHEN` / `THEN` scenarios.
The workflow is four commands: `explore`, `propose`, `apply`, `archive`.
`archive` merges the deltas into `specs/` and moves the change to `archive/<date>-<name>/`.
`openspec validate` checks structure; `openspec init` and `update` write the agent instructions.

## Against do-spec 0.2

- do-spec already has `WHEN` / `THEN` scenarios in specs; it has no named `SHALL` requirements.
- do-spec plans name the specs they touch in `changes` and `creates`, but not what changes in them.
- The archive move conflicts with do-spec's rule that a path is an identity.
- do-spec has installers for five agents, which covers what `init` does for skills.
