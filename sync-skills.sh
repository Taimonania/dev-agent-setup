#!/bin/bash
# Syncs all skills from this plugin repo into ~/.claude/skills/
# Creates symlinks for each skill subdirectory

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_SKILLS_DIR="$SCRIPT_DIR/.claude/skills"
USER_SKILLS_DIR="$HOME/.claude/skills"
SYNCIGNORE_FILE="$SCRIPT_DIR/.syncignore"

mkdir -p "$USER_SKILLS_DIR"

# Load ignored skill names from .syncignore
ignored_skills=()
if [ -f "$SYNCIGNORE_FILE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"   # strip comments
    line="${line// /}"   # strip whitespace
    [ -n "$line" ] && ignored_skills+=("$line")
  done < "$SYNCIGNORE_FILE"
fi

is_ignored() {
  local name="$1"
  for ignored in "${ignored_skills[@]}"; do
    [ "$name" = "$ignored" ] && return 0
  done
  return 1
}

# Remove stale symlinks pointing into this plugin
for link in "$USER_SKILLS_DIR"/*/; do
  link="${link%/}"
  if [ -L "$link" ]; then
    target="$(readlink "$link")"
    if [[ "$target" == "$PLUGIN_SKILLS_DIR"* ]] && [ ! -d "$target" ]; then
      echo "Removing stale symlink: $(basename "$link")"
      rm "$link"
    fi
  fi
done

# Create symlinks for each skill
for skill_dir in "$PLUGIN_SKILLS_DIR"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  target="$USER_SKILLS_DIR/$skill_name"

  if is_ignored "$skill_name"; then
    echo "Ignored: $skill_name"
    continue
  fi

  if [ -L "$target" ]; then
    echo "Updating: $skill_name"
    rm "$target"
  elif [ -e "$target" ]; then
    echo "Skipping: $skill_name (non-symlink already exists)"
    continue
  else
    echo "Linking: $skill_name"
  fi

  ln -s "$skill_dir" "$target"
done

echo "Done. Skills synced to $USER_SKILLS_DIR"
