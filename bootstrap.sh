#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
brewfile_path="$repo_dir/Brewfile"

if [[ -f "$brewfile_path" ]]; then
  if command -v brew >/dev/null 2>&1; then
    if HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file "$brewfile_path" --no-upgrade >/dev/null 2>&1; then
      printf "Brew bundle already satisfied from %s\n" "$brewfile_path"
    else
      HOMEBREW_NO_AUTO_UPDATE=1 brew bundle --file "$brewfile_path" --no-upgrade
    fi
  else
    printf "brew is not installed; skipping Brewfile apply\n"
  fi
else
  printf "Brewfile not found at %s; skipping brew bundle\n" "$brewfile_path"
fi

"$repo_dir/scripts/install-external-tools.sh"
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.bun/bin:$PATH"

"$repo_dir/scripts/stow.sh"

if command -v uv >/dev/null 2>&1; then
  if [[ -f "$repo_dir/uv-tools.txt" ]]; then
    "$repo_dir/home/.local/bin/uv-tools-install" "$repo_dir/uv-tools.txt"
  else
    printf "uv-tools.txt not found at %s; skipping uv tool install\n" "$repo_dir/uv-tools.txt"
  fi
else
  printf "uv is not installed; skipping uv tool install\n"
fi

printf "Dotfiles bootstrap complete from %s\n" "$repo_dir"
