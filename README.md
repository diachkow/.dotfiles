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

- `./bootstrap.sh` - apply `Brewfile`, install `uv`/`opencode`/`bun`/`oh-my-zsh` via curl, stow `home`, then install `uv` tools from `uv-tools.txt`
- `./scripts/stow.sh` - stow `home`
- `./scripts/restow.sh` - restow `home` after file moves/renames
- `./scripts/unstow.sh` - remove symlinks managed by `home`
- `./scripts/install-external-tools.sh` - install `uv`, `opencode`, `bun`, `oh-my-zsh` via curl installers if missing

## Brew bundle

- `Brewfile` is intentionally minimal and curated.
- Homebrew itself and `opencode` are installed via external curl scripts and are not managed by `Brewfile`.
- Check/install from repo root:

```bash
HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file ./Brewfile --no-upgrade || \
  HOMEBREW_NO_AUTO_UPDATE=1 brew bundle --file ./Brewfile --no-upgrade
```

## Global commands

Commands in `home/.local/bin/` are Stow-managed and symlinked to `~/.local/bin`.

- `uv-tools-install [manifest]` - install tools listed in `uv-tools.txt`
- `uv-tools-export [manifest]` - export installed tools to `uv-tools.txt` using `~=` version specifiers
- `uvx-upgrade [manifest]` - run `uv tool upgrade --all` then refresh `uv-tools.txt`

## Current migration backups

- `/Users/vitaliy/.config/.pre-stow-backup-20260207-200454`
- `/Users/vitaliy/.config/.pre-stow-backup-20260207-201517`
- `/Users/vitaliy/.pre-stow-backup-20260207-201718`
