# AGENTS.md

## Repo Intent
- Personal dotfiles repo, managed with GNU Stow.
- `home/` mirrors `$HOME`; stow links these files into the live environment.

## Key Paths
- `home/.config/**` app configs (nvim, tmux, opencode, ghostty, starship).
- `home/.local/bin/*` helper scripts (`uv-tools-install`, `uv-tools-export`, `uvx-upgrade`).
- `Brewfile` curated Homebrew bundle manifest (minimal/intended deps only).
- `scripts/stow.sh`, `scripts/restow.sh`, `scripts/unstow.sh` for symlink lifecycle.
- `scripts/install-external-tools.sh` installs `uv`, `opencode`, `bun`, `oh-my-zsh` via curl installers when missing.
- `bootstrap.sh` applies `Brewfile` (when `brew` exists), installs external tools, runs stow, then installs uv tools from `uv-tools.txt` when `uv` exists.

## Agent Workflow
1. Edit files under `home/` (or repo scripts) only.
2. If files were moved/renamed, run `./scripts/restow.sh`.
3. For normal apply, run `./scripts/stow.sh`.
4. Avoid `home/.config/tmux/plugins` unless explicitly requested (ignored/vendor-like).

## Commands
- `./bootstrap.sh`
- `./scripts/stow.sh`
- `./scripts/restow.sh`
- `./scripts/unstow.sh`
- `./scripts/install-external-tools.sh`
- `HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file ./Brewfile --no-upgrade`
- `HOMEBREW_NO_AUTO_UPDATE=1 brew bundle --file ./Brewfile --no-upgrade`
- If changing `home/.config/opencode/package.json`, run `bun install` in `home/.config/opencode`.

## Brewfile Policy
- Keep `Brewfile` curated/minimal; avoid machine-wide dumps without review.
- Homebrew itself and `opencode` are installed via external curl scripts, not via `Brewfile`.

## Conventions
- Bash: `#!/usr/bin/env bash` + `set -euo pipefail`, quote vars, compute script dir.
- Lua (Neovim): follow `home/.config/nvim/stylua.toml` (2 spaces, 120 cols, prefer double quotes).
- Keep diffs small and scoped; avoid broad refactors.

## Sensitive Areas
- `home/.gitconfig*` contains identity/SSH settings.
- `home/.config/opencode/opencode.jsonc` controls opencode permission policy.
- Any `home/` change affects real machine config after stow.

## Validation
- No repo-wide CI/test pipeline.
- Validate touched area only (for stow changes: run stow/restow and check for conflicts).
