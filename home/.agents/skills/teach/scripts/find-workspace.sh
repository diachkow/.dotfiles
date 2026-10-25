#!/usr/bin/env bash
# Find the teaching workspace linked to a project directory, if any.
# Usage: find-workspace.sh [project-dir]   (defaults to $PWD)
# Prints the workspace directory when found; prints nothing when not.
set -euo pipefail

if ! dir="$(cd "${1:-$PWD}" 2>/dev/null && pwd -P)"; then exit 0; fi

# Learnings root: $TEACH_LEARNINGS_DIR, else $XDG_DATA_HOME/learnings, else ~/learnings
root="${TEACH_LEARNINGS_DIR:-${XDG_DATA_HOME:+$XDG_DATA_HOME/learnings}}"
root="${root:-$HOME/learnings}"

shopt -s nullglob
for cfg in "$root"/*/workspace.yaml; do
  line="$(grep -m1 -E '^linked_project:' "$cfg" || true)"
  link="${line#linked_project:}"
  link="$(printf '%s' "$link" | sed -e "s/^[[:space:]\"']*//" -e "s/[[:space:]\"']*\$//")"
  [ -n "$link" ] || continue
  linked_dir="$(cd "$link" 2>/dev/null && pwd -P || true)"
  if [ "$linked_dir" = "$dir" ]; then
    cd "$(dirname "$cfg")" && pwd -P
    exit 0
  fi
done
