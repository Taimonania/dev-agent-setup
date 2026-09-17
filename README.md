# dev-agent-setup

A template repository for new projects: agent skills, plus an opinionated default architecture.

Stack- and infrastructure-agnostic. Nothing here assumes a language, framework, or cloud.

## Starting a project

Create a repository from this template, then run three skills in order. Each needs what the
previous produced.

**1. `/setup-matt-pocock-skills`** — configures the issue tracker, triage labels, and doc layout the
vendored engineering skills assume.

**2. `/grill-with-docs`** — an interview that sharpens what you are building and records the answers
as a glossary and ADRs. **The tech decisions happen here** — language, runtime, storage. A new repo
has no lockfile, so there is nothing to detect until you have decided.

**3. `/setup`** — installs the event-sourced vertical-slice structure in the language you chose, and
rewrites `AGENTS.md` for the project. It finishes only once a boundary violation has been shown to
fail a command.

Run `/ask-matt` for the map of how the rest of the skills compose.

## Default architecture

**Event sourcing** arranged as **vertical slices**.

- Append and query only. No update, no delete. Corrections are new events.
- One slice per command or query.
- The event log is the only thing slices share.

AQ-over-CRUD is absolute — there is no CRUD slice and no opt-out. The reasoning lives in the
`event-orientation` and `vertical-slices` skills; `/setup` installs what they describe rather than
repeating it.

## This repo

Skills are in `.agents/skills/`, symlinked into `.claude/skills/`. Those vendored from
[mattpocock/skills](https://github.com/mattpocock/skills) are tracked in `skills-lock.json`; `setup`,
`event-orientation`, `vertical-slices`, and `visual-review` are authored here and are not.

`visual-review` is automatically discoverable after user-facing UI changes, and can also be
invoked with `/visual-review`. It checks the running UI against acceptance criteria and broader
usability, with screenshots and optional videos as evidence. It uses an installed `agent-browser`
CLI by default and Playwright CLI for deeper debugging or as a fallback; consult the installed
browser skills/help for setup and usage. These browser tools are not bundled in this template.

`docs/research/` is the cited research behind these decisions. It is template history, not project
material — **delete it in a project built from this template.**
