#!/usr/bin/env bash
# SwiftBar plugin: shows work state in the menu bar, refreshes every minute.
# Dropdown shows details; click "Toggle" items to start/stop.
set -uo pipefail

caffeinate_on=0
pgrep -x caffeinate >/dev/null && caffeinate_on=1
colima_on=0
colima list 2>/dev/null | awk '$1=="default" && $2=="Running"{f=1} END{exit !f}' && colima_on=1

if [ "$caffeinate_on" = 1 ] && [ "$colima_on" = 1 ]; then
	echo ":bolt.fill:"
elif [ "$caffeinate_on" = 1 ] || [ "$colima_on" = 1 ]; then
	echo ":bolt.badge.clock:"
else
	echo ":zzz:"
fi

echo "---"
[ "$caffeinate_on" = 1 ] && echo "keep-awake: on" || echo "keep-awake: off"
[ "$colima_on" = 1 ] && echo "colima: running" || echo "colima: off"
echo "---"
if [ "$caffeinate_on" = 1 ] || [ "$colima_on" = 1 ]; then
	echo "Stop Work Day | shell=\"$HOME/.local/bin/work\" param1=stop terminal=false refresh=true"
else
	echo "Start Work Day | shell=\"$HOME/.local/bin/work\" param1=start terminal=false refresh=true"
fi
