# Stack

## Languages & Runtimes

- **Shell scripting:** Bash (`#!/usr/bin/env bash`) for repo automation — `bootstrap.sh`, `scripts/stow.sh`, `scripts/restow.sh`, `scripts/unstow.sh`, `scripts/install-external-tools.sh`, `home/.local/bin/*`, and `home/.config/tmux/install.sh`. Conventions per `AGENTS.md`: `set -euo pipefail`, script-dir resolution.
- **Interactive shell:** Zsh with [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) — `home/.zshrc` sources `$HOME/.oh-my-zsh/oh-my-zsh.sh` (installed outside the repo by `scripts/install-external-tools.sh`). Default shell for tmux: `/bin/zsh` in `home/.config/tmux/tmux.conf`.
- **Neovim config:** Lua — entry `home/.config/nvim/init.lua` loads `lua/base_config`, `lua/plugin_manager` (lazy.nvim). Formatter config: `home/.config/nvim/stylua.toml`. Plugin lockfile: `home/.config/nvim/lazy-lock.json`.
- **Config/data formats:** JSON with comments for OpenCode (`home/.config/opencode/opencode.jsonc`, `home/.config/opencode/vibecode.jsonc`); TOML for Starship (`home/.config/starship.toml`); Ghostty and bat use plain-text config (`home/.config/ghostty/config`, `home/.config/bat/config`).
- **Runtimes (machine-level, not pinned in-repo):** **Go** (`brew "go"` in `Brewfile`); **Python tooling** via **uv** (installer from `https://astral.sh/uv/install.sh` in `scripts/install-external-tools.sh`); **Node** tooling for OpenCode plugins via **bun** (`https://bun.com/install` in `scripts/install-external-tools.sh`), with deps declared in `home/.config/opencode/package.json` and lockfile `home/.config/opencode/bun.lock`.

## Package Managers & Tools

| Tool | Role | Primary paths / notes |
|------|------|------------------------|
| **Homebrew** | OS packages and GUI apps | `Brewfile`; used by `bootstrap.sh` with `HOMEBREW_NO_AUTO_UPDATE=1` and `--no-upgrade`. |
| **GNU Stow** | Symlink `home/` → `$HOME` | `brew "stow"`; `scripts/stow.sh`, `scripts/restow.sh` (`stow -R`), `scripts/unstow.sh` (`stow -D`). |
| **uv** | Python envs and global CLI tools | Installed by `scripts/install-external-tools.sh`; `bootstrap.sh` runs `home/.local/bin/uv-tools-install` against `uv-tools.txt`. Helpers: `home/.local/bin/uv-tools-export`, `home/.local/bin/uvx-upgrade`. |
| **bun** | Install `@opencode-ai/plugin` for OpenCode | `home/.config/opencode/package.json`; after edits, `bun install` in `home/.config/opencode` per `AGENTS.md`. |
| **git** | Neovim lazy.nvim bootstrap clones plugins | `home/.config/nvim/lua/plugin_manager.lua` clones `folke/lazy.nvim` from GitHub. |

## Key Dependencies

### `Brewfile`

- **Stow / core:** `stow`, `git`, `bash`, `curl`.
- **Terminal / editor:** `neovim`, `tmux`, `starship`, `neofetch`.
- **Containers:** `colima`, `docker`, `docker-buildx`, `docker-compose`.
- **Languages & ops:** `go`, `k6`, `kubectx`, `just`, `sqlcipher`.
- **CLI UX:** `bat`, `eza`, `fd`, `fzf`, `jq`, `ripgrep`, `tree`, `zoxide`.
- **Zsh (Homebrew packages used by `home/.zshrc`):** `zsh-autosuggestions`, `zsh-syntax-highlighting`.
- **GUI:** `cask "ghostty"`, `cask "legcord"`, and a font cask — see `Brewfile` line for `font-geist-mono` (verify `brew` syntax: intended `cask`, not `cast`).

Homebrew itself and **opencode** are intentionally *not* in `Brewfile`; they are installed via curl in `scripts/install-external-tools.sh` (`https://opencode.ai/install`).

### Manifests (repo root)

- **`uv-tools.txt`** — PEP 440-style tool specs for `uv tool install` (e.g. `cookiecutter`, `dunk`, `posting`, `ty`, `yamllint`), consumed by `home/.local/bin/uv-tools-install`.
- **`home/.config/opencode/package.json`** — single dependency `@opencode-ai/plugin` (version pinned there).

No `requirements.txt` or root `pyproject.toml`; Python tools are managed through **uv** and `uv-tools.txt`.

## Configuration

- **Layout:** `home/` mirrors `$HOME`; only tracked content is what lives under `home/` plus repo scripts and manifests.
- **Apply mechanism:** `stow -vt "$HOME" -d "$repo_dir" home` from `scripts/stow.sh` links the `home` package into the live home directory.
- **App configs** (non-exhaustive): `home/.config/nvim/**`, `home/.config/tmux/tmux.conf`, `home/.config/ghostty/**`, `home/.config/starship.toml`, `home/.config/bat/**`, `home/.config/opencode/**`, `home/.config/eza/` (referenced from `home/.zshrc` via `EZA_CONFIG_DIR`).
- **Git:** `home/.gitconfig` plus conditional includes `home/.gitconfig-sumup`, `home/.gitconfig-lightit` for work trees.
- **Agent docs:** `AGENTS.md` at repo root; OpenCode-specific rules in `home/.config/opencode/AGENTS.md`.
- **TMUX plugins:** `home/.config/tmux/plugins` is treated as vendor-like per `AGENTS.md`; TPM and plugins referenced from `home/.config/tmux/tmux.conf`.

## Build & Deploy

- **`bootstrap.sh`** — Optional `brew bundle` from `Brewfile` → `scripts/install-external-tools.sh` (uv, opencode, bun, oh-my-zsh) → extends `PATH` with `$HOME/.local/bin`, `$HOME/.opencode/bin`, `$HOME/.bun/bin` → `scripts/stow.sh` → if `uv` exists, `home/.local/bin/uv-tools-install` with `uv-tools.txt`.
- **`scripts/stow.sh`** — Ensures `stow` (via brew if needed), then stows `home` into `$HOME`.
- **`scripts/restow.sh`** — `stow -R` for replace/restow after moves/renames.
- **`scripts/unstow.sh`** — `stow -D` to remove symlinks.
- **`scripts/install-external-tools.sh`** — Idempotent curl-based installers for uv, opencode, bun, oh-my-zsh (see URLs inside the script).
- **Optional manual path:** `home/.config/tmux/install.sh` links `tmux.conf` and a `tmux-new-session` helper into `$HOME` / `$HOME/.local/bin` (paths defined in that script).

There is no CI pipeline or automated test harness in this repo (`AGENTS.md`).
