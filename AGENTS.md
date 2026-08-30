# AGENTS.md

Template repository for new projects. Stack- and infrastructure-agnostic.

## Default architecture

New projects use **event sourcing** and **vertical slices**.

- Events: append and query only, never update or delete. See the `event-orientation` skill.
- Slices: one slice per command or query. Minimise coupling between slices. See `vertical-slices`.
- AQ-over-CRUD is absolute. There is no CRUD slice and no opt-out.

Starting a project runs three skills in order: `/setup-matt-pocock-skills`, then `/grill-with-docs`
to decide the stack, then `/setup` to lay the structure down in it. See README.md.

## Skills

36 skills live in `.agents/skills/`, surfaced to Claude Code via `.claude/skills/` symlinks. Run
`/ask-matt` for the map of how the vendored ones compose.

33 are vendored from `mattpocock/skills` and tracked in `skills-lock.json`. Three are authored here
and are **not** in the lockfile: `setup`, `event-orientation`, `vertical-slices`.

`setup-matt-pocock-skills` is a precondition for the main flow — six skills assume it has run.
`setup` additionally requires the stack decisions from `grill-with-docs`.

Skills under the upstream `in-progress/` bucket are beta and may change without warning.

## Conventions

- Documentation lives outside this repo; do not scaffold docs here.
- Research output goes in `docs/research/` as cited Markdown.
