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

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  printf "oh-my-zsh already installed\n"
else
  printf "Installing oh-my-zsh via git clone\n"
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

"$repo_dir/scripts/stow.sh"

if command -v mise >/dev/null 2>&1; then
  mise install
else
  printf "mise is not installed; skipping mise tool install\n"
fi

printf "Dotfiles bootstrap complete from %s\n" "$repo_dir"
