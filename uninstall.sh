#!/bin/bash
# Remove the Rosary theme and everything install.sh set up.
set -uo pipefail

if [[ $(cat ~/.local/state/omarchy/current/theme.name 2>/dev/null) == rosary ]]; then
  echo "Switch to another theme first, e.g.: omarchy theme set tokyo-night" >&2
  exit 1
fi

systemctl --user disable --now rosary-wallpaper.timer 2>/dev/null
rm -f ~/.config/systemd/user/rosary-wallpaper.{service,timer}
systemctl --user daemon-reload
rm -f ~/.config/omarchy/hooks/{theme-set,post-boot}.d/rosary-today.sh
rm -f ~/.local/bin/rosary-wallpaper
rm -rf ~/.config/omarchy/themes/rosary ~/.config/omarchy/backgrounds/rosary \
       ~/.config/rosary-wallpaper ~/.cache/rosary-theme

PLUGIN_ID="$(whoami).background"
PLUGIN_DIR=~/.config/omarchy/plugins/$PLUGIN_ID
if grep -q screenVariant "$PLUGIN_DIR/Background.qml" 2>/dev/null; then
  read -rp "Also remove the per-screen background plugin and restore Omarchy's own? [y/N] " a
  if [[ $a == [yY]* ]]; then
    omarchy plugin disable "$PLUGIN_ID"
    omarchy plugin enable omarchy.background
    rm -rf "$PLUGIN_DIR"
    omarchy restart shell
  fi
fi
echo "Rosary theme removed."
