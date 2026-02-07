#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v stow >/dev/null 2>&1; then
  printf "stow is missing; run ./scripts/stow.sh first\n" >&2
  exit 1
fi

stow -Rvt "$HOME" -d "$repo_dir" home
printf "Restowed from %s/home\n" "$repo_dir"
