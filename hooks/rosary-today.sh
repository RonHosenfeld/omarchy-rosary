#!/bin/bash
# Refresh the Rosary theme's daily wallpaper when that theme is active.
[[ $(cat ~/.local/state/omarchy/current/theme.name 2>/dev/null) == rosary ]] || exit 0
~/.local/bin/rosary-wallpaper today --apply >/dev/null 2>&1 &
