#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v stow >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    brew install stow
  else
    printf "stow is missing and Homebrew is not installed\n" >&2
    exit 1
  fi
fi

stow -vt "$HOME" -d "$repo_dir" home
printf "Stowed from %s/home\n" "$repo_dir"
