# Integrations

## External Tools

| Area | Integration | Config / entry points |
|------|-------------|------------------------|
| **Editor** | **Neovim** | `home/.config/nvim/init.lua`, `home/.config/nvim/lua/**`, `lazy-lock.json`. Plugin manager clones **lazy.nvim** from GitHub (`home/.config/nvim/lua/plugin_manager.lua`). |
| **Terminal multiplexer** | **tmux** | `home/.config/tmux/tmux.conf` — prefix `C-a`, TPM (`tmux-plugins/tpm`), plugins include `christoomey/vim-tmux-navigator`, `tmux-plugins/tmux-sensible`, `tmux-plugins/tmux-yank`, `niksingh710/minimal-tmux-status`, local `~/.config/tmux/plugins/tmux-switch-project`. Optional installer: `home/.config/tmux/install.sh`. |
| **Terminal emulator** | **Ghostty** | `home/.config/ghostty/config`, themes under `home/.config/ghostty/themes/`; installed via `cask "ghostty"` in `Brewfile`. |
| **Prompt** | **Starship** | `home/.config/starship.toml` (schema URL in file); initialized from `home/.zshrc` when interactive and `TERM` is not `dumb`. |
| **CLI presentation** | **bat**, **eza** | `home/.config/bat/config` (theme `gruvbox-material-mix-dark`); `home/.zshrc` sets `EZA_CONFIG_DIR` to `home/.config/eza` and aliases `ls`→`eza`, `cat`→`bat`. |
| **Fuzzy finder / navigation** | **fzf**, **zoxide** | `home/.zshrc` runs `fzf --zsh` and `zoxide init --cmd cd zsh` when commands exist. |
| **Containers** | **Colima** + **Docker** | `home/.zshrc` sets `DOCKER_HOST="unix://${HOME}/.colima/docker.sock"`; CLI stack from `Brewfile` (`colima`, `docker`, `docker-buildx`, `docker-compose`). |
| **Kubernetes** | **kubectx** | `brew "kubectx"` in `Brewfile`. |
| **Load / perf testing** | **k6** | `brew "k6"` in `Brewfile`. |
| **DB** | **SQLCipher** | `brew "sqlcipher"` in `Brewfile`. |
| **Task runner** | **just** | `brew "just"` in `Brewfile`; allowed non-interactively in OpenCode bash policy (`home/.config/opencode/opencode.jsonc`). |
| **System info** | **neofetch** | `brew "neofetch"` in `Brewfile`. |
| **AI coding agent** | **OpenCode** | Binary from `https://opencode.ai/install` (`scripts/install-external-tools.sh`). Main config: `home/.config/opencode/opencode.jsonc` (default agent, LSP, granular bash permissions). Looser profile: `home/.config/opencode/vibecode.jsonc` (broader `edit`/`bash` allow; `external_directory` deny) — selected by `vibecode` alias in `home/.zshrc`. Bun-managed plugin: `home/.config/opencode/package.json`. Custom agents/skills/themes under `home/.config/opencode/agents`, `skills`, `themes`, `plugins`. LSP: `ty` server for Python; `pyright` disabled in `opencode.jsonc`. |
| **Chat / Discord** | **Legcord** | `cask "legcord"` in `Brewfile`. |
| **Spotify theming** | **Spicetify** (path only) | `home/.zshrc` adds `$HOME/.spicetify` to `PATH` (installation not in this repo). |

## Shell Integrations

- **Oh My Zsh** — Expected at `$HOME/.oh-my-zsh`; installed by `scripts/install-external-tools.sh` with `RUNZSH=no`, `CHSH=no`, `KEEP_ZSHRC=yes`. Sourced from `home/.zshrc` via `source $ZSH/oh-my-zsh.sh`.
- **Plugins (declared in `home/.zshrc`):** `zsh-autosuggestions`, `zsh-syntax-highlighting` — also listed as Homebrew formulae in `Brewfile` and wired for OMZ-style loading.
- **Custom fpath:** `home/.zshrc` prepends `$HOME/.zfunctions` for custom completions.
- **Starship** — Replaces OMZ theme (`ZSH_THEME=""`); see `home/.config/starship.toml`.
- **Tool-specific shell hooks:** `ngrok completion` via `eval_if_cmd` in `home/.zshrc`; **bun** completions sourced from `/Users/vitaliy/.bun/_bun` when present (hardcoded path in `home/.zshrc`).
- **Aliases / functions:** `gc` → edit Ghostty config with nvim; `vibecode` → `OPENCODE_CONFIG` pointing at `home/.config/opencode/vibecode.jsonc`; `diary` → personal diary path; `t` → tmux session `work`; `gi()` → downloads gitignore templates over HTTPS (see Cloud section).
- **Prompt / search theming:** `FZF_DEFAULT_OPTS` in `home/.zshrc` (Everblush-inspired colors).

## Git Configuration

- **Main file:** `home/.gitconfig` — `defaultBranch = main`, user identity, `core.editor = nvim`, `core.sshCommand` defaulting to `~/.ssh/personal` with `IdentitiesOnly=yes`, merge `conflictStyle = zdiff3`, push `autoSetupRemote`, various `advice` and `status` tweaks.
- **Conditional includes:** `home/.gitconfig` uses `[includeIf "gitdir:..."]` to load `home/.gitconfig-sumup` and `home/.gitconfig-lightit` for work directories — each overrides `user.*` and `core.sshCommand` to different SSH keys (`~/.ssh/sumup`, `~/.ssh/lightit`).
- **Sensitive:** Emails and SSH key paths live in these files; treat edits carefully (noted in `AGENTS.md`).

## Cloud/Service Integrations

- **OpenCode / Astral / Bun / Oh My Zsh** — Install URLs in `scripts/install-external-tools.sh`: `https://astral.sh/uv/install.sh`, `https://opencode.ai/install`, `https://bun.com/install`, `https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh`.
- **OpenCode product** — JSON schema reference `https://opencode.ai/config.json` in `home/.config/opencode/opencode.jsonc` and `vibecode.jsonc`; `share` and `autoupdate` settings in `opencode.jsonc`.
- **gitignore.io (Toptal)** — `gi()` in `home/.zshrc` curls `https://www.toptal.com/developers/gitignore/api/...` for template lists.
- **Google Cloud SDK** — Optional sourcing of `path.zsh.inc` and `completion.zsh.inc` from `/Users/vitaliy/google-cloud-sdk/` if those files exist (`home/.zshrc`); not bundled in the repo.
- **Neovim lazy.nvim** — Git clone from `https://github.com/folke/lazy.nvim.git` (`home/.config/nvim/lua/plugin_manager.lua`).
- **Starship** — Config schema `https://starship.rs/config-schema.json` in `home/.config/starship.toml`.

No API keys or cloud provider credentials are stored in tracked dotfiles; OpenCode permission policy in `home/.config/opencode/opencode.jsonc` governs agent bash/git behavior instead.
