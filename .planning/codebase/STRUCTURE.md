# Structure

## Directory Tree

High-level layout (repository root). Dotfiles under `home/` are what Stow links into `$HOME`. Deep third-party trees (e.g. `home/.config/tmux/plugins`, `home/.config/opencode/node_modules`) are summarized rather than fully expanded.

```
.dotfiles/
├── .git/                          # Git metadata (not stowed)
├── .gitignore                     # Ignores logs, backups, .DS_Store, caches, node_modules
├── .planning/
│   └── codebase/                  # Planning docs (ARCHITECTURE.md, STRUCTURE.md)
├── home/                          # Stow package: mirrors ~/ ( sole package name: "home" )
│   ├── .config/
│   │   ├── bat/                   # bat config + Catppuccin/Gruvbox/Rose Pine/Tokyo Night themes
│   │   ├── eza/                   # eza theme (theme.yml)
│   │   ├── ghostty/               # Terminal config + gruvbox-material theme files
│   │   ├── nvim/                  # Neovim: init.lua, lazy-lock.json, lua/, after/ftplugin/, stylua.toml
│   │   ├── opencode/              # opencode: jsonc configs, package.json, bun.lock, plugins/, agents/, skills/, themes/
│   │   ├── tmux/                  # tmux.conf, install.sh; plugins/ (TPM + vendor plugins — treat as vendor)
│   │   └── starship.toml          # Starship prompt (single file at .config root)
│   ├── .local/
│   │   └── bin/                   # uv-tools-install, uv-tools-export, uvx-upgrade
│   ├── .gitconfig                 # Primary git identity (sensitive)
│   ├── .gitconfig-lightit         # Include-style / alternate identity (sensitive)
│   ├── .gitconfig-sumup           # Include-style / alternate identity (sensitive)
│   ├── .zshenv                    # Early zsh env (e.g. cargo env)
│   └── .zshrc                     # Oh My Zsh, PATH, aliases (e.g. vibecode → opencode + vibecode.jsonc)
├── scripts/
│   ├── bin/                       # Empty placeholder
│   ├── install-external-tools.sh
│   ├── restow.sh
│   ├── stow.sh
│   └── unstow.sh
├── AGENTS.md                      # Maintainer/agent notes for this repo
├── bootstrap.sh                   # Full bootstrap orchestrator
├── Brewfile                       # brew bundle manifest
├── LICENSE.txt
├── README.md
└── uv-tools.txt                   # uv tool install manifest (pins with ~=)
```

**Scale (excluding `.git`, ignoring `node_modules` for counts):** on the order of **~200** tracked files and **~90** directories; the largest footprint is **`home/.config/tmux/plugins/`** (vendored TPM and plugin repos).

## Key Locations

| Need | Location |
|------|----------|
| **Stow-managed home files** | `home/**` → symlinks under `~/` |
| **Shell** | `home/.zshrc`, `home/.zshenv` |
| **Git identity / includes** | `home/.gitconfig`, `home/.gitconfig-lightit`, `home/.gitconfig-sumup` |
| **Neovim** | `home/.config/nvim/` (`init.lua`, `lua/`, `after/`, `lazy-lock.json`) |
| **Tmux** | `home/.config/tmux/tmux.conf`, `home/.config/tmux/install.sh`; plugins under `home/.config/tmux/plugins/` |
| **Terminal emulators** | `home/.config/ghostty/` |
| **Prompt** | `home/.config/starship.toml` |
| **CLI theming (bat/eza)** | `home/.config/bat/`, `home/.config/eza/` |
| **opencode** | `home/.config/opencode/` (`opencode.jsonc`, `vibecode.jsonc`, `package.json`, `plugins/`, `themes/`) |
| **User scripts on PATH** | `home/.local/bin/` |
| **Homebrew deps** | `Brewfile` (repo root) |
| **uv CLI tools list** | `uv-tools.txt` (repo root); consumed by `home/.local/bin/uv-tools-install` |
| **Bootstrap & Stow ops** | `bootstrap.sh`, `scripts/stow.sh`, `scripts/restow.sh`, `scripts/unstow.sh`, `scripts/install-external-tools.sh` |

## Naming Conventions

- **Hidden dotfiles** — Prefixed with `.` at the repo root of the Stow tree (`home/.zshrc`, `home/.gitconfig`), matching Unix home-directory conventions.
- **XDG config** — `home/.config/<lowercase-app-name>/` for applications; single-file configs sometimes sit directly under `home/.config/` (e.g. `starship.toml`).
- **Neovim** — `lua/` for runtime Lua, `after/ftplugin/` for filetype overrides, plugin specs under `lua/plugins/` with descriptive snake_case filenames (`lspconfig.lua`, `vim_tmux_navigator.lua`).
- **Scripts** — `kebab-case.sh` or `lower_case.sh` for bash (`install-external-tools.sh`, `stow.sh`); `home/.local/bin` helpers use **kebab-case** without extension (`uv-tools-install`, `uvx-upgrade`).
- **opencode** — `*.jsonc` for configuration; `vibecode.jsonc` for overlay config used by the `vibecode` alias in `home/.zshrc`.
- **Gitconfig variants** — Suffix pattern `home/.gitconfig-<context>` for employer or project-specific includes.
- **Manifests** — `uv-tools.txt`: one package spec per line, `#` comments allowed; `Brewfile`: Ruby DSL `brew` and `cask` entries per Homebrew bundle conventions (see `Brewfile` for GUI apps and fonts).

## File Organization

- **`home/` vs repo root** — Everything that should appear in `$HOME` is under `home/`. Operational/repo-only files stay at the root so they are never symlinked by the `home` package.
- **Grouped by application** — Under `home/.config/`, each app gets its own directory; shared cross-cutting dotfiles (`.zshrc`, `.gitconfig`) sit directly under `home/`.
- **Neovim** — Split between bootstrap (`init.lua`, `lua/plugin_manager.lua`), feature modules (`lua/plugins/*.lua`), core behavior (`lua/base_config/`), and late overrides (`after/ftplugin/`).
- **opencode** — Config, lockfile, and JS plugin live together; `skills/` and `agents/` hold markdown skill/agent definitions; `themes/` holds JSON themes.
- **Tmux** — User config is minimal surface (`tmux.conf`, `install.sh`); `plugins/` holds TPM and cloned plugins (large, vendor-like; often excluded from routine edits per `AGENTS.md`).
- **Ignored artifacts** — `.gitignore` excludes `**/node_modules/` (opencode’s JS deps are installed locally with `bun install` in `home/.config/opencode` when `package.json` changes), `*.bak`, caches, and editor swap files.
