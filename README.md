# dev-agent-setup

A template repository for new projects: agent skills, plus an opinionated default architecture.

Stack- and infrastructure-agnostic. Nothing here assumes a language, framework, or cloud.

> **Status:** work in progress. The skills and architecture are settled; this README will be
> expanded once the implementation plan is done.

## Starting a project

Create a repository from this template, then run three skills in order. The order matters — each
one needs what the previous produced.

### 1. `/setup-matt-pocock-skills`

Configures the issue tracker, triage label vocabulary, and domain doc layout that the vendored
engineering skills assume. Six of them expect it to have run.

### 2. `/grill-with-docs`

A relentless interview that sharpens what you are actually building, and records the answers as a
glossary and ADRs as it goes.

**This is where the tech decisions get made** — language, runtime, storage, how the project is
deployed. A brand-new repo has no lockfile and no manifest, so there is nothing to detect yet. Come
out of this step with those decisions written down.

### 3. `/setup`

Lays down the event-sourced vertical-slice structure in the language you just chose: modules and
slices, the event log, boundary enforcement, and one real working slice.

It finishes only once a boundary violation has been shown to fail a command. Folders existing is not
evidence.

## Default architecture

**Event sourcing** arranged as **vertical slices**.

- Append and query only. No update, no delete. Corrections are new events.
- One slice per command or query. Minimal coupling between slices.
- The event log is the only thing slices share.

AQ-over-CRUD is absolute here — there is no CRUD slice and no opt-out.

The reasoning lives in the `event-orientation` and `vertical-slices` skills. Read those; `/setup`
installs what they describe rather than repeating it.

## Skills

36 skills in `.agents/skills/`, surfaced to Claude Code through `.claude/skills/` symlinks.

- **33 vendored** from [mattpocock/skills](https://github.com/mattpocock/skills), tracked in
  `skills-lock.json`. Run `/ask-matt` for the map of how they compose.
- **3 authored here**, not in the lockfile: `setup`, `event-orientation`, `vertical-slices`.

Four upstream skills were removed as unusable in a stack-agnostic template: `scaffold-exercises`
(calls a private CLI), `setup-pre-commit`, `migrate-to-shoehorn`, and `setup-ts-deep-modules`.

## Documentation

The code is the source of truth. Rules live where they are enforced; the reasons live in the rule
that enforces them. Judgements that no rule can catch live in the skills.

`docs/research/` holds the cited primary-source research behind these decisions — the skills
inventory, documentation practice, and the vertical-slices and event-sourcing sources.
