# dev-agent-setup

A Claude Code plugin containing reusable skills for dev agents. Skills are organized in `.claude/skills/` and can be synced to your user-level `~/.claude/skills/` directory, making them available across all projects.

## Structure

```
dev-agent-setup/
├── .claude-plugin/
│   └── plugin.json        # Plugin manifest
├── .claude/
│   └── skills/            # Skill directories go here
│       └── my-skill/
│           └── SKILL.md
├── .syncignore             # Skills to exclude from syncing
├── sync-skills.sh          # Symlink skills to ~/.claude/skills/
└── README.md
```

## Usage

### Adding a skill

Create a new directory under `.claude/skills/` with a `SKILL.md` file:

```
.claude/skills/my-skill/
└── SKILL.md
```

### Syncing skills

Run the sync script to symlink all skills into `~/.claude/skills/`:

```bash
./sync-skills.sh
```

This creates symlinks so Claude Code picks up the skills globally, regardless of which project you're working in.

### Excluding skills from sync

Add skill folder names to `.syncignore` (one per line):

```
# .syncignore
my-experimental-skill
work-in-progress
```

These skills will remain in the repo but won't be linked into `~/.claude/skills/`.

### Direct plugin loading

You can also load the entire plugin directly via CLI:

```bash
claude --plugin-dir /path/to/dev-agent-setup
```
