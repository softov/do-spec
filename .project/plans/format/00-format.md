---
title: Format - what exists today
domain: format
revalidated: 2026-09-27
---

The `.project/ artifacts` format is defined by the `do-spec` skill: its `SKILL.md` states the conventions and its `assets/` hold one template per artifact kind.
The format is at 0.2 and nothing checks it; consistency rests on the agent reading `SKILL.md`.

## Packages

- [`code://skills/do-spec/SKILL.md`](../../../skills/do-spec/SKILL.md) - the format: paths, refs, statuses, plan lifecycle, decision and problem rules.
- [`code://skills/do-spec/assets`](../../../skills/do-spec/assets) - the templates every artifact starts from.
- [`code://bin/do-skills.js`](../../../bin/do-skills.js) - the npx entry point; today it only launches the installers.

## Runtime path

```
agent loads SKILL.md -> copies a template from assets/ -> writes .project/<kind>/<slug>.md
```

## Tests

None.

## Known gaps

- No machine-readable sections: `## Files`, `## Steps` and `## Validation` are free Markdown.
- A spec is corrected in place with no record of what a plan intended to change in it.
- Nothing validates frontmatter, statuses, ref URIs or link depth.
- One skill covers every stage of the work.
