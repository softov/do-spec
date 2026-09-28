---
title: Files and Steps stay Markdown under a strict line grammar; only data is fenced
status: accepted
date: 2026-09-27
refs:
  - "[code://skills/do-spec/assets/task.md](../../skills/do-spec/assets/task.md) - the sections this governs"
---

## Context

Task sections are free Markdown, so no tool can read what a task creates, changes or checks.
Fenced blocks are easy to parse, but a Markdown view renders a fence as monospace text, and a `code://` link inside one stops being a link.

## Decision

`## Files` and `## Steps` stay Markdown, and every line under them follows a fixed grammar the validator enforces.
Content that is data and not prose is fenced with a typed info string: ` ```validations ` for a task's checks and ` ```delta <spec> ` for a plan's spec changes.
Mermaid and code fences are unchanged.

Source: Softov, 2026-09-27, asked "Files and Steps: fenced blocks or strict grammar under the heading?", answered "Headings, fences for data".

## Consequences

Links in Files and Steps stay clickable.
The validator needs two parsers: a line grammar under headings and a schema per fence type.

## Options

- Fence everything (` ```files `, ` ```steps `, ` ```validations `, ` ```delta `): one parser, but `code://` links inside render as plain text.
