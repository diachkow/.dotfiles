# Testing

## Test Framework

- **No automated test suite**: There are no `test/`, `tests/`, or `*_test.sh` files, no pytest/jest-style projects for the dotfiles repo, and no shell test harness (e.g. bats) checked in.
- **Neovim**: Editor-side tooling (formatting/linting) targets everyday editing, not a CI run of this repository.

## Validation Approach

- **Documented in `AGENTS.md`**: Validation is manual—"Validate touched area only"; for stow-related edits, run `./scripts/stow.sh` or `./scripts/restow.sh` and check for conflicts.
- **Bootstrap path**: `./bootstrap.sh` exercises `Brewfile` (when Homebrew is present), `scripts/install-external-tools.sh`, `./scripts/stow.sh`, and optionally `home/.local/bin/uv-tools-install` against `uv-tools.txt` when `uv` is installed.
- **Homebrew bundle**: From the repo root, `HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file ./Brewfile --no-upgrade` (and `brew bundle` when needed) verifies the curated dependency set; same commands are mirrored in `README.md` and used inside `bootstrap.sh` with `brew bundle check` as a gate.
- **Stow lifecycle**: `./scripts/unstow.sh` removes symlinks when verifying uninstall behavior.

## CI/CD

- **No CI pipelines**: There is no `.github/workflows/`, GitLab CI, or similar checked into this repo. `AGENTS.md` explicitly states there is no repo-wide CI/test pipeline.

## Quality Checks

- **Neovim (local editor)**:
  - **Formatting**: `home/.config/nvim/lua/plugins/formatting.lua` configures `stevearc/conform.nvim`; Lua uses **Stylua** per `formatters_by_ft`, aligned with `home/.config/nvim/stylua.toml`.
  - **Linting**: `home/.config/nvim/lua/plugins/linting.lua` uses `mfussenegger/nvim-lint` with filetype-based linters (e.g. optional `mypy` for Python when the executable exists).
  - **LSP / tools**: `home/.config/nvim/lua/plugins/lspconfig.lua` uses Mason and `mason-tool-installer` to ensure tools such as `lua-language-server`, `stylua`, `taplo`, `prettierd`, etc.—these support editor quality, not automated repo gates.
- **Repo-level**: No `pre-commit` config, no root `Makefile` or `package.json` scripts for lint/format, and no `.editorconfig` in the repo for global formatting policy.
- **Opencode**: `home/.config/opencode/package.json` lists only `@opencode-ai/plugin`; `AGENTS.md` notes running `bun install` in `home/.config/opencode` after changing that file—dependency install, not a test run.
