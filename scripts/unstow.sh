#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v stow >/dev/null 2>&1; then
  printf "stow is missing\n" >&2
  exit 1
fi

stow -Dvt "$HOME" -d "$repo_dir" home
printf "Unstowed links from %s/home\n" "$repo_dir"
