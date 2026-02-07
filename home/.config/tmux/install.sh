#!/usr/bin/env bash
set -euo pipefail

# Resolve the directory where install.sh is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Paths
TMUX_CONF_SRC="$SCRIPT_DIR/tmux.conf"
TMUX_CONF_DEST="$HOME/.tmux.conf"

HELPER_SRC="$SCRIPT_DIR/tmux-new-session"
HELPER_DEST="$HOME/.local/bin/tmux-new-session"

# Ensure ~/.local/bin exists
mkdir -p "$HOME/.local/bin"

echo "Linking tmux.conf → $TMUX_CONF_DEST"
ln -sf "$TMUX_CONF_SRC" "$TMUX_CONF_DEST"

echo "Linking tmux-new-session → $HELPER_DEST"
ln -sf "$HELPER_SRC" "$HELPER_DEST"
chmod +x "$HELPER_SRC"

echo "✅ Installation complete!"
echo "   - tmux.conf linked to $TMUX_CONF_DEST"
echo "   - tmux-new-session available in ~/.local/bin"
