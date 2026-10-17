#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title Stop Work Day
# @raycast.mode compact
# @raycast.packageName Work
# @raycast.icon 👋
set -euo pipefail
exec "$HOME/.local/bin/work" stop
