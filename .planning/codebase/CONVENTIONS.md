# Conventions

## Bash Scripts

- **Shebang**: Portable bash via `#!/usr/bin/env bash` on all tracked shell scripts (`bootstrap.sh`, `scripts/stow.sh`, `scripts/restow.sh`, `scripts/unstow.sh`, `scripts/install-external-tools.sh`, `home/.config/tmux/install.sh`, and helpers under `home/.local/bin/`).
- **Strict mode**: Every script starts with `set -euo pipefail` so unset variables and pipeline failures abort execution.
- **Repository / script directory**: Top-level and `scripts/*.sh` resolve the repo with `repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")")/.." && pwd)"` (or `../..` as appropriate). `home/.local/bin/uvx-upgrade` uses `script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` for sibling script resolution. `home/.config/tmux/install.sh` uses `SCRIPT_DIR` the same way.
- **Quoting and expansion**: Paths and user-facing strings are passed through double-quoted variables (e.g. `"$repo_dir"`, `"$HOME"`, `"$manifest"`). `printf` with `%s` is preferred for messages in `bootstrap.sh` and the stow scripts; `home/.config/tmux/install.sh` uses `echo` for user feedback.
- **Feature checks**: Missing tools use `command -v … >/dev/null 2>&1` before acting; hard failures use `printf … >&2` and `exit 1` (e.g. `scripts/restow.sh`, `scripts/unstow.sh` when `stow` is absent).
- **Helpers**: `scripts/install-external-tools.sh` defines `has_tool()` with `local`, optional path candidates, and `shift || true` after consuming the first argument to avoid `set -u` issues when no extra paths are passed.
- **Manifests**: `home/.local/bin/uv-tools-install` reads `uv-tools.txt` line-by-line, strips `#` comments and trims whitespace, and skips empty lines before `uv tool install`.
- **Defaults**: `uv-tools-install`, `uv-tools-export`, and `uvx-upgrade` accept an optional manifest path; default is `${DOTFILES_DIR:-$HOME/.dotfiles}/uv-tools.txt`.

## Lua (Neovim)

- **Formatter config**: `home/.config/nvim/stylua.toml` sets 120-column lines, Unix line endings, 2-space indentation, `quote_style = "AutoPreferDouble"`, `call_parentheses = "Always"`, `collapse_simple_statement = "Never"`, and **disables** `[sort_requires]` so require order stays manual.
- **Layout**: `home/.config/nvim/init.lua` loads `base_config` then `plugin_manager`. `home/.config/nvim/lua/base_config/init.lua` exports `apply_config()` and sequences `keybinds`, `behavior`, `appearance`, `commands`, `ftmapping` in a fixed order (documented as load-order sensitive).
- **Plugins**: `home/.config/nvim/lua/plugin_manager.lua` bootstraps `lazy.nvim` into `stdpath("data")`, then `require("lazy").setup({ spec = { { import = "plugins" } } })` loads one file per plugin from `home/.config/nvim/lua/plugins/*.lua`. Each file returns a Lazy spec table (often `return { { … } }`).
- **Per-filetype tweaks**: `home/.config/nvim/after/ftplugin/*.lua` sets buffer-local options (e.g. `lua.lua` sets `colorcolumn = { 120 }` to align with Stylua width).
- **Naming**: Plugin modules use `snake_case` filenames (`colorscheme.lua`, `lspconfig.lua`). Callbacks and locals favor explicit names (`keybind`, `diagnostic_message`).

## Configuration Files

- **TOML**: Used for `home/.config/starship.toml`, `home/.config/nvim/stylua.toml`, and similar; section headers and key/value style with `#` comments where needed (e.g. Starship palette sections).
- **YAML**: `home/.config/eza/theme.yml` uses nested mappings and indentation for color themes.
- **JSON / JSONC**: `home/.config/opencode/package.json` is minimal dependency-only JSON. `home/.config/opencode/opencode.jsonc` is JSON-with-comments for opencode (schema URL, `permission`, `lsp` blocks).
- **Brewfile**: Ruby DSL in `Brewfile` with `#` comment lines describing policy (curated list, external installers for some tools). Directives: `brew`, `cask`, etc.
- **Terminal / app native formats**: Ghostty uses `home/.config/ghostty/config` and theme files under `home/.config/ghostty/themes/` (app-specific key/value and theme syntax).
- **Lockfiles**: `home/.config/nvim/lazy-lock.json` pins Lazy plugin versions (machine-generated, not hand-edited for style).

## Error Handling

- **Shell**: `set -euo pipefail` propagates command failures; explicit `exit 1` for unrecoverable cases (missing `stow`, missing manifest in `uv-tools-install`). stderr is used for errors (`>&2`).
- **Optional steps**: `bootstrap.sh` skips `brew bundle` when `brew` or `Brewfile` is missing, printing informational messages instead of failing.
- **Neovim bootstrap**: `home/.config/nvim/lua/plugin_manager.lua` checks `vim.v.shell_error` after cloning lazy.nvim and calls `os.exit(1)` on failure after user acknowledgment.

## Code Patterns

- **Stow workflow**: `scripts/stow.sh` runs `stow -vt "$HOME" -d "$repo_dir" home`; `scripts/restow.sh` uses `-Rvt`; `scripts/unstow.sh` uses `-Dvt`. Verbose `-v` is used consistently.
- **PATH augmentation**: `bootstrap.sh` exports `PATH` with `~/.local/bin`, `~/.opencode/bin`, `~/.bun/bin` before stow and uv tools.
- **External installers**: `scripts/install-external-tools.sh` chains `curl` installers for uv, opencode, bun, and oh-my-zsh with idempotent checks.
- **Embedded Python**: `home/.local/bin/uv-tools-export` pipes `uv tool list` into `uv run python3 -c '…'` for version-spec parsing (single-quoted script body in the shell).
- **Documentation in repo**: `AGENTS.md` and `README.md` at the repo root describe stow commands, Brewfile policy, and bootstrap; `home/.config/opencode/AGENTS.md` is app-specific.
