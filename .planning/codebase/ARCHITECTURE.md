# Architecture

## Overall Pattern

This repository uses **GNU Stow** with a **single Stow package** named `home/`. The package directory mirrors the layout under `$HOME`: files in `home/.config/nvim/...` in the repo become symlinks at `~/.config/nvim/...` after stow. The repo root is the Stow parent directory (`-d`), and the target directory is `$HOME` (`-t`).

Stow commands used:

- **Install / update symlinks:** `stow -vt "$HOME" -d "$repo_dir" home` (`scripts/stow.sh`)
- **Restow (e.g. after renames):** `stow -Rvt "$HOME" -d "$repo_dir" home` (`scripts/restow.sh`)
- **Remove managed links:** `stow -Dvt "$HOME" -d "$repo_dir" home` (`scripts/unstow.sh`)

If `stow` is missing, `scripts/stow.sh` installs it via Homebrew when `brew` is available.

## Directory Layout Philosophy

- **`home/`** — The only Stow package content. Paths under `home/` map 1:1 to paths under `~/` (e.g. `home/.zshrc` → `~/.zshrc`). This keeps the “live” tree identical to what tools expect in `$HOME`.
- **Repo root** — Operational and machine-level manifests that are **not** symlinked into `$HOME` by default: `bootstrap.sh`, `Brewfile`, `uv-tools.txt`, `README.md`, `AGENTS.md`, `LICENSE.txt`, `.gitignore`.
- **`scripts/`** — Bash entry points for bootstrap steps and Stow lifecycle (`scripts/stow.sh`, `scripts/restow.sh`, `scripts/unstow.sh`, `scripts/install-external-tools.sh`). `scripts/bin/` exists as an empty placeholder directory.
- **`.planning/codebase/`** — Planning and documentation (this file); not part of Stow.

Application configuration follows the **XDG-style** convention under `home/.config/<app>/` for most tools (`nvim`, `tmux`, `ghostty`, `bat`, `eza`, `opencode`, `starship.toml` at `home/.config/starship.toml`). User-level scripts intended for `PATH` live under `home/.local/bin/` so Stow exposes them as `~/.local/bin/`.

## Data Flow

End-to-end orchestration is in `bootstrap.sh`:

1. **`Brewfile` (optional)** — If `brew` exists and `Brewfile` is present, run `HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file "$brewfile_path" --no-upgrade`; if not satisfied, run `brew bundle --file "$brewfile_path" --no-upgrade`. If `brew` is missing, this phase is skipped with a message.
2. **`scripts/install-external-tools.sh`** — Idempotent curl-based installers for tools **not** fully represented in the Brewfile policy: `uv`, `opencode`, `bun`, and Oh My Zsh (checks `PATH` or common install locations, or `~/.oh-my-zsh`).
3. **`PATH` augmentation** — `export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.bun/bin:$PATH"` so subsequent steps and the current shell see newly installed binaries.
4. **`scripts/stow.sh`** — Stow the `home` package into `$HOME`, creating/updating symlinks.
5. **`uv` tools** — If `uv` is on `PATH` and `uv-tools.txt` exists at the repo root, run `home/.local/bin/uv-tools-install "$repo_dir/uv-tools.txt"`, which reads the manifest line-by-line (comments and blank lines skipped) and runs `uv tool install` for each pinned spec.

Standalone use: you can run `scripts/stow.sh` / `restow.sh` / `unstow.sh` or `install-external-tools.sh` without `bootstrap.sh` when you only need part of the pipeline.

## Key Abstractions

| Abstraction | Role |
|-------------|------|
| **Stow package `home`** | Single unit of symlink management; everything user-facing under `~` that is versioned here lives under `home/`. |
| **`Brewfile`** | Curated Homebrew manifest: CLI tools, casks, and fonts used by this setup. Documented policy: keep it minimal; Homebrew itself and `opencode` are installed outside the Brewfile. |
| **`uv-tools.txt`** | Manifest of `uv tool install` targets with compatible release specifiers (`~=` lines). Consumed by `home/.local/bin/uv-tools-install`; companion scripts `uv-tools-export` and `uvx-upgrade` maintain or refresh the file. |
| **`home/.local/bin/*` helpers** | Small bash utilities stowed into `~/.local/bin` so they are available in the shell without a separate install step. |
| **External installers** | `scripts/install-external-tools.sh` centralizes non-Brew installs (curl scripts) for a consistent bootstrap story. |

## Entry Points

| Entry point | Purpose |
|-------------|---------|
| **`bootstrap.sh`** | Full machine bring-up: Brew bundle → external tools → stow → uv tools. Primary “clone repo and go” script. |
| **`scripts/stow.sh`** | Apply or refresh Stow symlinks for `home/` only. |
| **`scripts/restow.sh`** | Restow after structural changes inside `home/` (same package, replace symlinks). |
| **`scripts/unstow.sh`** | Remove Stow-managed symlinks for `home/` (does not uninstall Homebrew or curl-installed tools). |
| **`scripts/install-external-tools.sh`** | Install `uv`, `opencode`, `bun`, Oh My Zsh when missing; safe to run alone. |
| **`home/.local/bin/uv-tools-install`** | Installs command-line tools from a manifest (defaulting to `$DOTFILES_DIR/uv-tools.txt` or `$HOME/.dotfiles/uv-tools.txt`). Invoked by `bootstrap.sh` with an explicit repo path to `uv-tools.txt`. |

Relationship: **`bootstrap.sh`** composes the others in order. Day-to-day config edits typically only require re-running **`scripts/stow.sh`** (or **`restow.sh`** after moves). **`AGENTS.md`** at the repo root documents agent-oriented workflows and sensitive paths (`home/.gitconfig*`, `home/.config/opencode/opencode.jsonc`).
