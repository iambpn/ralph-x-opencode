#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 /path/to/project [--with-opencode]

Copies Ralph files (ralph.sh and prompt.md) into the target project's scripts/ralph/ directory
and makes ralph.sh executable. Also copies the skills directory to the target project.

Options:
  --with-opencode    Also copy opencode/opencode.json to the project root
EOF
  exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -lt 1 ]; then
  usage
fi

# Set the destination directory from the first argument
DEST="$1"

# Check for optional parameters
COPY_OPENCODE=false
for arg in "${@:2}"; do
  if [ "$arg" = "--with-opencode" ]; then
    COPY_OPENCODE=true
  fi
done

# Ensure destination directory exists and resolve absolute path
mkdir -p "$DEST"
DEST="$(cd "$DEST" && pwd)"

# Get the directory containing this script (the repo root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy main Ralph files
echo "Copying Ralph files to: $DEST/scripts/ralph/"
mkdir -p "$DEST/scripts/ralph"
mkdir -p "$DEST/.claude/skills/"

# Copy ralph.sh and make it executable
if [ -f "$SCRIPT_DIR/ralph.sh" ]; then
  cp -v "$SCRIPT_DIR/ralph.sh" "$DEST/scripts/ralph/"
  chmod +x "$DEST/scripts/ralph/ralph.sh"
else
  echo "Warning: ralph.sh not found in $SCRIPT_DIR" >&2
fi

# Copy addSkill.sh and make it executable
if [ -f "$SCRIPT_DIR/addSkill.sh" ]; then
  cp -v "$SCRIPT_DIR/addSkill.sh" "$DEST/scripts/ralph/"
  chmod +x "$DEST/scripts/ralph/addSkill.sh"
else
  echo "Warning: addSkill.sh not found in $SCRIPT_DIR" >&2
fi

# Copy prompt.md
if [ -f "$SCRIPT_DIR/prompt.md" ]; then
  cp -v "$SCRIPT_DIR/prompt.md" "$DEST/scripts/ralph/"
else
  echo "Warning: prompt.md not found in $SCRIPT_DIR" >&2
fi

# Copy skills directory if it exists
if [ -d "$SCRIPT_DIR/skills" ]; then
  echo "Copying skills directory to: $DEST/.claude/skills/"
  cp -rv "$SCRIPT_DIR/skills" "$DEST/.claude/"
else
  echo "Warning: skills directory not found in $SCRIPT_DIR" >&2
fi

# Copy opencode.json if --with-opencode flag is provided
if [ "$COPY_OPENCODE" = true ]; then
  if [ -f "$SCRIPT_DIR/opencode/opencode.json" ]; then
    echo "Copying opencode.json to: $DEST/"
    cp -v "$SCRIPT_DIR/opencode/opencode.json" "$DEST/"
  else
    echo "Warning: opencode/opencode.json not found in $SCRIPT_DIR" >&2
  fi
fi

echo "Finished."
