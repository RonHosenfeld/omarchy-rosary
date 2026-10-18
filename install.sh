#!/bin/bash
# Install (or update) the Rosary theme for Omarchy. Safe to re-run after `git pull`.
#
#   ./install.sh [--style soft|standard] [--no-plugin] [--no-apply]
#
#   --style      color style (default: keep the current setting, else soft)
#   --no-plugin  skip the per-screen background plugin (wallpapers are then cropped
#                to fit screens whose shape differs from 3440x1440)
#   --no-apply   install everything but don't switch to the theme
set -euo pipefail

cd "$(dirname "$(realpath "$0")")"
STYLE=""
PLUGIN=1
APPLY=1
while (( $# )); do
  case $1 in
    --style) STYLE=$2; shift ;;
    --no-plugin) PLUGIN=0 ;;
    --no-apply) APPLY=0 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done
STYLE=${STYLE:-$(cat ~/.config/rosary-wallpaper/style 2>/dev/null || echo soft)}
step() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }

step "Checking dependencies"
missing=()
command -v python3 >/dev/null || missing+=(python)
command -v curl >/dev/null || missing+=(curl)
command -v rsvg-convert >/dev/null || missing+=(librsvg)
command -v magick >/dev/null || missing+=(imagemagick)
fc-list ':family=Noto Serif' | grep -q . || missing+=(noto-fonts)
if (( ${#missing[@]} )); then
  echo "Installing: ${missing[*]}"
  omarchy pkg add "${missing[@]}"
else
  echo "All present"
fi

step "Installing rosary-wallpaper"
install -Dm755 bin/rosary-wallpaper ~/.local/bin/rosary-wallpaper

step "Installing theme"
THEME=~/.config/omarchy/themes/rosary
mkdir -p "$THEME/backgrounds"
install -m644 theme/icons.theme theme/preview.png "$THEME/"
[[ -f $THEME/colors.toml ]] || install -m644 theme/colors.toml "$THEME/"

step "Installing hooks and daily timer"
omarchy hook install theme-set hooks/rosary-today.sh
omarchy hook install post-boot hooks/rosary-today.sh
install -Dm644 -t ~/.config/systemd/user systemd/rosary-wallpaper.service systemd/rosary-wallpaper.timer
systemctl --user daemon-reload
systemctl --user enable --now rosary-wallpaper.timer

if (( PLUGIN )); then
  step "Installing per-screen background plugin"
  PLUGIN_ID="$(whoami).background"
  PLUGIN_DIR=~/.config/omarchy/plugins/$PLUGIN_ID
  [[ -d $PLUGIN_DIR ]] || omarchy plugin clone omarchy.background
  if python3 -I plugin/patch-background.py "$PLUGIN_DIR/Background.qml"; then
    omarchy restart shell >/dev/null 2>&1 || true
    sleep 3
  else
    echo "This Omarchy version's background plugin has changed; skipping per-screen support." >&2
    omarchy plugin disable "$PLUGIN_ID" || true
    omarchy plugin enable omarchy.background || true
  fi
fi

step "Rendering wallpapers ($STYLE style)"
~/.local/bin/rosary-wallpaper style "$STYLE"

if (( APPLY )); then
  step "Applying theme"
  omarchy theme set rosary
fi

step "Done"
echo "Change style any time:  rosary-wallpaper style soft|standard"
