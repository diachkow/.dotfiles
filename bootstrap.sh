#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$repo_dir/scripts/stow.sh"

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
stow -vt "$HOME" -d "$repo_dir" home

printf "Dotfiles stowed from %s\n" "$repo_dir"
