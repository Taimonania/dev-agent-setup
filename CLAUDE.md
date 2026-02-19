# dev-agent-setup

Claude Code plugin containing reusable skills for dev agents.

## Project structure

- `.claude-plugin/plugin.json` — Plugin manifest
- `.claude/skills/` — Skill directories (each with a SKILL.md)
- `.syncignore` — Skills excluded from syncing
- `sync-skills.sh` — Syncs skills to ~/.claude/skills/ via symlinks

See README.md for detailed usage instructions.
