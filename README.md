# Dotfiles

Managed with GNU Stow using a `home/` package, so files map to `$HOME`.
Homebrew dependencies are tracked in a curated `Brewfile`.

## Structure

- `home/.config/...` -> `~/.config/...`
- `home/.zshrc` -> `~/.zshrc` (same for other home dotfiles)
- `Brewfile` -> curated Homebrew packages for this setup

## Usage

```bash
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

## Commands

- `./bootstrap.sh` - apply `Brewfile`, clone `oh-my-zsh` when missing, stow `home`, then run `mise install` for global tools
- `./scripts/stow.sh` - stow `home`
- `./scripts/restow.sh` - restow `home` after file moves/renames
- `./scripts/unstow.sh` - remove symlinks managed by `home`

## Brew bundle

- `Brewfile` is intentionally minimal and curated.
- Homebrew itself is installed via external curl script and is not managed by `Brewfile`.
- CLI dev tools are mise-managed via `home/.config/mise/config.toml`, not via `Brewfile`.
- Check/install from repo root:

```bash
HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file ./Brewfile --no-upgrade || \
  HOMEBREW_NO_AUTO_UPDATE=1 brew bundle --file ./Brewfile --no-upgrade
```

## Global commands

Commands in `home/.local/bin/` are Stow-managed and symlinked to `~/.local/bin`.

- `vibecode` - starts `opencode` with `~/.config/opencode/vibecode.jsonc` overrides

## Global CLI tools

Managed by mise via `home/.config/mise/config.toml` (stowed to `~/.config/mise/config.toml`).

- `mise install` - install everything pinned in the manifest
- `mise upgrade` - upgrade installed tools

## Current migration backups

- `/Users/vitaliy/.config/.pre-stow-backup-20260207-200454`
- `/Users/vitaliy/.config/.pre-stow-backup-20260207-201517`
- `/Users/vitaliy/.pre-stow-backup-20260207-201718`
