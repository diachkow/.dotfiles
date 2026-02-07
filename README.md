# Dotfiles

Managed with GNU Stow using a `home/` package, so files map to `$HOME`.

## Structure

- `home/.config/...` -> `~/.config/...`
- `home/.zshrc` -> `~/.zshrc` (same for other home dotfiles)

## Usage

```bash
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

## Commands

- `./bootstrap.sh` - install `stow` if needed, then stow `home`
- `./scripts/stow.sh` - stow `home`
- `./scripts/restow.sh` - restow `home` after file moves/renames
- `./scripts/unstow.sh` - remove symlinks managed by `home`

## Current migration backups

- `/Users/vitaliy/.config/.pre-stow-backup-20260207-200454`
- `/Users/vitaliy/.config/.pre-stow-backup-20260207-201517`
- `/Users/vitaliy/.pre-stow-backup-20260207-201718`
