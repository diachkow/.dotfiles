#!/usr/bin/env bash
set -euo pipefail

HERDR="${HERDR_BIN_PATH:-herdr}"
STATE_DIR="${HERDR_PLUGIN_STATE_DIR:-$HOME/.local/state/herdr/plugins/diachkow.workspace-layout}"
mkdir -p "$STATE_DIR"
PICK_FILE="$STATE_DIR/pick-dir.txt"

rm -f "$PICK_FILE"

"$HERDR" plugin pane open \
  --plugin diachkow.workspace-layout \
  --entrypoint pick-dir \
  --placement popup \
  --width "80%" \
  --height 20 \
  --env PICK_FILE="$PICK_FILE" \
  || { printf 'failed to open directory picker\n' >&2; exit 1; }

for _ in $(seq 1 600); do
  if [[ -s "$PICK_FILE" ]]; then
    break
  fi
  sleep 0.05
done

CWD="${HOME:?}"
if [[ -s "$PICK_FILE" ]]; then
  CWD="$(<"$PICK_FILE")"
fi

WS_JSON="$("$HERDR" workspace create --cwd "$CWD" --focus)" \
  || { printf 'failed to create workspace\n' >&2; exit 1; }
WS_ID="$(jq -r '.result.workspace.workspace_id' <<<"$WS_JSON")"
TAB_ID="$(jq -r '.result.tab.tab_id' <<<"$WS_JSON")"

"$HERDR" tab rename "$TAB_ID" nvim \
  || { printf 'failed to rename tab to nvim\n' >&2; exit 1; }
"$HERDR" tab create --workspace "$WS_ID" --label test --cwd "$CWD" --no-focus \
  || { printf 'failed to create test tab\n' >&2; exit 1; }
"$HERDR" tab create --workspace "$WS_ID" --label vibe --cwd "$CWD" --no-focus \
  || { printf 'failed to create vibe tab\n' >&2; exit 1; }
