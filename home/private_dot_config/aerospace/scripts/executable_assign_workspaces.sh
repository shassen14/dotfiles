#!/bin/bash
# Dynamically assigns AeroSpace workspaces to monitors based on connected display count.
# Run at startup or via keybinding (alt-shift-m) after connecting/disconnecting monitors.
#
# Layout:
#   1 monitor  — all workspaces on monitor 1
#   2 monitors (built-in + external) — workspaces 1-4 on external, 5-9 on built-in
#   2 monitors (both external) — workspaces 1-4 on monitor 1, 5-9 on monitor 2
#   3+ monitors — workspaces 1-3 on monitor 1, 4-6 on monitor 2, 7-9 on monitor 3

MONITOR_COUNT=$(aerospace list-monitors 2>/dev/null | wc -l | tr -d ' ')
BUILTIN_ID=$(aerospace list-monitors 2>/dev/null | grep -i "Built-in" | awk '{print $1}')

assign() {
    local ws="$1" monitor="$2"
    aerospace workspace "$ws"
    aerospace move-workspace-to-monitor "$monitor"
}

case "$MONITOR_COUNT" in
    1)
        for ws in 1 2 3 4 5 6 7 8 9; do assign "$ws" "1"; done
        ;;
    2)
        if [ -n "$BUILTIN_ID" ]; then
            EXTERNAL_ID=$(aerospace list-monitors 2>/dev/null | grep -iv "Built-in" | awk '{print $1}')
            for ws in 1 2 3 4;   do assign "$ws" "$EXTERNAL_ID"; done
            for ws in 5 6 7 8 9; do assign "$ws" "$BUILTIN_ID"; done
        else
            for ws in 1 2 3 4;   do assign "$ws" "1"; done
            for ws in 5 6 7 8 9; do assign "$ws" "2"; done
        fi
        ;;
    *)
        for ws in 1 2 3; do assign "$ws" "1"; done
        for ws in 4 5 6; do assign "$ws" "2"; done
        for ws in 7 8 9; do assign "$ws" "3"; done
        ;;
esac

aerospace workspace 1
