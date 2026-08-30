# AGENTS.md

Template repository for new projects. Stack- and infrastructure-agnostic.

## Default architecture

New projects start with **event sourcing** and **vertical slices**. Deviating is allowed but is a decision worth recording.

- Events: append and query only, never update or delete. See the `event-orientation` skill.
- Slices: organise by feature, not by layer. Minimise coupling between slices.

## Skills

33 vendored skills live in `.agents/skills/`, surfaced to Claude Code via `.claude/skills/` symlinks. Run `/ask-matt` for the map of how they compose.

`setup-matt-pocock-skills` is a precondition for the main flow — six skills assume it has run.

Skills under the upstream `in-progress/` bucket are beta and may change without warning.

## Conventions

- Documentation lives outside this repo; do not scaffold docs here.
- Research output goes in `docs/research/` as cited Markdown.
