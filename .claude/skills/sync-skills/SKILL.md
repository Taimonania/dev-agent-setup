---
name: Sync Skills
description: Sync dev-agent-setup plugin skills to the user-level ~/.claude/skills/ directory. Use when the user asks to "sync skills", "install skills", "update skills", or wants to make plugin skills available globally across all projects. Also use after adding or removing skills from the plugin.
---

# Sync Skills

Run the sync script to symlink all plugin skills into `~/.claude/skills/`:

```bash
bash /Users/timo/claude-environments/dev-agent-setup/sync-skills.sh
```

The script will:
- Create symlinks for each skill in `.claude/skills/` to `~/.claude/skills/`
- Remove stale symlinks for skills that no longer exist in the plugin
- Skip skills listed in `.syncignore`
- Skip existing non-symlink skills to avoid overwriting manually installed skills

## Excluding skills

To exclude a skill from syncing, add its folder name to `/Users/timo/claude-environments/dev-agent-setup/.syncignore` (one per line, `#` for comments).
