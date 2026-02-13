#!/usr/bin/env bash
set -euo pipefail

has_tool() {
  local tool_name="$1"
  shift || true

  if command -v "$tool_name" >/dev/null 2>&1; then
    return 0
  fi

  local candidate
  for candidate in "$@"; do
    if [[ -x "$candidate" ]]; then
      return 0
    fi
  done

  return 1
}

install_uv() {
  printf "Installing uv via curl installer\n"
  curl -LsSf https://astral.sh/uv/install.sh | sh
}

install_opencode() {
  printf "Installing opencode via curl installer\n"
  curl -fsSL https://opencode.ai/install | bash
}

install_bun() {
  printf "Installing bun via curl installer\n"
  curl -fsSL https://bun.com/install | bash
}

install_oh_my_zsh() {
  printf "Installing oh-my-zsh via curl installer\n"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

if has_tool uv "$HOME/.local/bin/uv"; then
  printf "uv already installed\n"
else
  install_uv
fi

if has_tool opencode "$HOME/.opencode/bin/opencode"; then
  printf "opencode already installed\n"
else
  install_opencode
fi

if has_tool bun "$HOME/.bun/bin/bun"; then
  printf "bun already installed\n"
else
  install_bun
fi

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  printf "oh-my-zsh already installed\n"
else
  install_oh_my_zsh
fi
