#!/usr/bin/env bash
set -euo pipefail

if ! command -v fd >/dev/null 2>&1; then
  printf 'fd is required but not installed\n' >&2
  exit 1
fi

PROJECT_DIRS=("$HOME/coding" "$HOME/.config")
FAVORITES_FILE="$HOME/.config/tmux/switch-project-favorites"
PICK_FILE="${PICK_FILE:-}"

FD_EXCLUDE=(
  --exclude node_modules
  --exclude .venv
  --exclude venv
  --exclude .cache
  --exclude vendor
  --exclude .npm
  --exclude .cargo
  --exclude .rustup
  --exclude 'go/pkg'
)

get_projects() {
  if [[ -f "$FAVORITES_FILE" ]]; then
    while IFS= read -r fav; do
      [[ -d "$fav" ]] && printf '★ %s\n' "$fav"
    done < "$FAVORITES_FILE"
  fi
  for dir in "${PROJECT_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
      fd --type d --hidden --no-ignore '^\.git$' "$dir" \
        --max-depth 5 "${FD_EXCLUDE[@]}" \
        --exec dirname {} \; 2>/dev/null
      fd --type f --no-ignore '^(package\.json|pyproject\.toml|go\.sum)$' "$dir" \
        --max-depth 5 "${FD_EXCLUDE[@]}" \
        --exec dirname {} \; 2>/dev/null
    fi
  done | sort -u
}

selected="$(get_projects | fzf --prompt="project> " --no-preview)" || true
selected="${selected##★ }"

if [[ -n "${selected:-}" ]]; then
  printf '%s' "$selected" > "${PICK_FILE:?}"
fi
