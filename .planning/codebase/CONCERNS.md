# Concerns

## Security

- **`home/.gitconfig`** — Committed identity (`email`, `name`), forced SSH identity via `core.sshCommand` (`ssh -i ~/.ssh/personal`), and conditional includes for work trees. Anyone with repo access learns email addresses, key filenames, and employer/repo layout under `~/coding/work/`. Treat as sensitive if the remote is shared or public.
- **`home/.gitconfig-sumup`** and **`home/.gitconfig-lightit`** — Work emails, display names, and distinct SSH key paths (`~/.ssh/sumup`, `~/.ssh/lightit`). Same exposure profile as the main gitconfig; keys are referenced by path, not embedded.
- **`README.md`** — “Current migration backups” lists absolute paths under `/Users/vitaliy/...`, which leaks OS username and backup locations if published.
- **`scripts/install-external-tools.sh`** — Installs `uv`, OpenCode, Bun, and Oh My Zsh via `curl ... | sh` / `| bash`. No checksum verification; trust is entirely in TLS and upstream scripts (standard pattern but worth periodic review).
- **`home/.zshrc`** — `gi()` pulls gitignore templates over HTTPS from `toptal.com` developers API (no integrity pinning beyond TLS).
- **`home/.config/opencode/vibecode.jsonc`** — `permission.edit` and `permission.bash` are both `"allow"`, unlike the stricter policy in **`home/.config/opencode/opencode.jsonc`**. Using the `vibecode` alias materially increases what OpenCode can do without prompts.
- **SSH and secrets** — No private keys or API tokens were found in tracked `home/` content; risk is metadata exposure (emails, key names, work aliases) rather than raw credentials in-repo.

## Technical Debt

- **`Brewfile`** — Line 50 uses `cast "font-geist-mono"`; Homebrew Bundle expects **`cask`**. As written, `brew bundle` is likely to fail or skip the font until corrected.
- **`README.md`** — Documents `vibecode` as a command in `home/.local/bin/`; in practice it is a **`home/.zshrc`** alias, not a standalone script. Misleading for automation or non-zsh shells.
- **Dual tmux wiring** — Config lives at **`home/.config/tmux/tmux.conf`** (Stow). **`home/.config/tmux/install.sh`** additionally symlinks that file to **`~/.tmux.conf`**, which Stow does not manage. Reload binding in **`home/.config/tmux/tmux.conf`** references `~/.tmux.conf`, so behavior depends on whether `install.sh` was run vs. Stow-only setup.
- **`home/.zshenv`** — Unconditionally sources **`$HOME/.cargo/env`**; on machines without Rust/cargo this path may be missing (harmless if guarded elsewhere, but noisy or surprising on first load).
- **Neovim** — **`home/.config/nvim/lua/plugins/linting.lua`** has a **TODO** to add JS/TS linters; commented-out `eslint_d` block.
- **Large vendored/editor themes** — Bat Catppuccin/Tokyonight/Gruvbox themes under **`home/.config/bat/themes/`** are large XML-ish blobs; updates are manual and diffs are noisy.

## Fragile Areas

- **`home/.zshrc`** — Hardcoded **`/Users/vitaliy/google-cloud-sdk/...`** for gcloud and **`/Users/vitaliy/.bun/_bun`** for Bun completions. Breaks on other users, Linux, or different install locations; **`$HOME/.bun/_bun`** would be portable for Bun.
- **Apple Silicon Homebrew** — **`home/.zshrc`** prepends `/opt/homebrew/bin` and **`home/.config/tmux/tmux.conf`** sets `PATH` with the same prefix. Intel Macs (`/usr/local`) or Linux Homebrew paths will not match without edits.
- **`home/.config/tmux/tmux.conf`** — `run-shell` for **`~/.config/tmux/plugins/tmux-switch-project/switch-project.tmux`** and TPM path **`~/.config/tmux/plugins/tpm/tpm`** assume plugins are installed outside the repo (per **`AGENTS.md`**, tmux plugins are vendor-like). Fresh clone + Stow alone leaves tmux incomplete until TPM/plugin steps are done.
- **`home/.config/ghostty/config`** — macOS-specific options (`macos-titlebar-*`, `macos-icon`, etc.). Not portable to Linux or other terminals without a parallel config.
- **`home/.zshrc`** — `DOCKER_HOST` points at Colima’s socket under **`$HOME/.colima/docker.sock`**; other Docker setups need different values.
- **`home/.zshrc`** — `DIARY_HOME` and diary alias assume a specific **`$HOME/Personal/diary`** layout.

## Maintenance

- **`uv-tools.txt`** — Tool versions use `~=` pins; **`home/.local/bin/uvx-upgrade`** + **`uv-tools-export`** refresh the manifest but require periodic runs to pick up security fixes.
- **`home/.config/opencode/package.json`** — Pins **`@opencode-ai/plugin`**; **`home/.config/opencode/bun.lock`** should stay in sync after dependency bumps (`bun install` per **`AGENTS.md`**).
- **`home/.config/nvim/lazy-lock.json`** — Neovim plugin versions are lockfile-managed; updates need `:Lazy` / conscious bumps.
- **External installers** — URLs in **`scripts/install-external-tools.sh`** (`astral.sh`, `opencode.ai`, `bun.com`, `ohmyzsh` raw GitHub) can change behavior; no version pinning at install time.
- **`Brewfile`** — Large surface (GUI casks, Docker stack, fonts); Homebrew formula renames or cask removals can break **`bootstrap.sh`** until the file is updated.

## Missing Features

- **No automated validation** — Repo has no CI; **`bootstrap.sh`**, Stow, and **`brew bundle`** are not exercised automatically on push.
- **Backup strategy** — **`README.md`** mentions one-off migration backups only; no documented routine for pre-Stow snapshots or restore.
- **`home/.local/bin/uv-tools-install`** — Stops on first `uv tool install` failure (`set -e`); no partial success summary or retry loop.
- **`home/.local/bin/uv-tools-export`** — Uses embedded Python via **`uv run python3`**; if `uv` or the environment is broken, export fails without a fallback.
- **Stow conflicts** — Scripts do not preflight for existing non-symlink files in **`$HOME`**; users must resolve clashes manually.

## Known Issues

- **`home/.config/nvim/lua/plugins/linting.lua`** — **TODO**: “figure out JS linters”; JS/TS/React linting is intentionally disabled (commented block).
- **`Brewfile`** — **`cast "font-geist-mono"`** is almost certainly a typo for **`cask`** (also noted in `.planning/codebase/STACK.md`).
- **Documentation drift** — **`README.md`** lists **`vibecode`** as a `home/.local/bin` helper; implementation is **`home/.zshrc`** alias only.
- **`AGENTS.md` (repo root)** vs **`README.md`** — Overlapping docs; keep behavior descriptions in sync when paths or commands change.
