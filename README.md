# dev-agent-setup

A template repository for new projects: agent skills, plus an opinionated default architecture.

Stack- and infrastructure-agnostic. Nothing here assumes a language, framework, or cloud.

> **Status:** work in progress. The skills and architecture are settled; this README will be
> expanded once the implementation plan is done.

## Starting a project

Create a repository from this template, then run:

```
/setup
```

The `setup` skill takes a new project from empty to ready-to-build. It detects your language and
toolchain first, so it works in any stack, and finishes only once a boundary violation has been
shown to fail a command. Run it once, before the first feature.

Run `/setup-matt-pocock-skills` as well; it configures the issue tracker and doc layout that six of
the vendored skills assume. The two do not overlap.

## Default architecture

**Event sourcing** arranged as **vertical slices**.

- Append and query only. No update, no delete. Corrections are new events.
- One slice per command or query. Minimal coupling between slices.
- The event log is the only thing slices share.

AQ-over-CRUD is absolute here — there is no CRUD slice and no opt-out.

## Skills

36 skills in `.agents/skills/`, surfaced to Claude Code through `.claude/skills/` symlinks.

- **33 vendored** from [mattpocock/skills](https://github.com/mattpocock/skills), tracked in
  `skills-lock.json`. Run `/ask-matt` for the map of how they compose.
- **3 authored here**, not in the lockfile: `setup`, `event-orientation`, `vertical-slices`.

Four upstream skills were removed as unusable in a stack-agnostic template: `scaffold-exercises`
(calls a private CLI), `setup-pre-commit`, `migrate-to-shoehorn`, and `setup-ts-deep-modules`.

## Research

`docs/research/` holds the cited primary-source research behind these decisions — the skills
inventory, documentation practice, and the vertical-slices and event-sourcing sources.
