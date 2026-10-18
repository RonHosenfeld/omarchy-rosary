# Rosary — an Omarchy theme

A gentle, prayerful theme for [Omarchy](https://omarchy.org). Each day the wallpaper shows:

- **The day's mysteries of the Rosary**, using the traditional weekly cycle
  (Mon/Sat Joyful · Tue/Fri Sorrowful · Wed/Sun Glorious · Thu Luminous),
  with Advent and Christmas Sundays using the Joyful Mysteries and Lent Sundays the Sorrowful
- **The fruit of each mystery**
- **The day's Gospel** from the [USCCB daily readings](https://bible.usccb.org/bible/readings)
- **Colors for the liturgical season**: Advent violet, rose for Gaudete and Laetare Sundays,
  Christmas ivory, Lenten plum, Easter pearl, Pentecost ember, Ordinary Time sage.
  The whole desktop (terminals, bar, borders) re-tints when the season changes.

Everything is drawn as vector art. No images are downloaded, and the repo contains no
Scripture text: the Gospel is fetched once a day for local display.

## Install

The repo is private, so sign in to GitHub once on each machine (`gh` ships with Omarchy):

```bash
gh auth login
gh repo clone RonHosenfeld/omarchy-rosary ~/omarchy-rosary
~/omarchy-rosary/install.sh
```

Options: `--style soft|standard` (default `soft`), `--no-plugin`, `--no-apply`.

To update later: `cd ~/omarchy-rosary && git pull && ./install.sh`

## Use

```bash
rosary-wallpaper style soft        # dusty, low-contrast colors (terminal text ~6.8:1)
rosary-wallpaper style standard    # crisper, higher contrast
rosary-wallpaper today --apply     # refresh today's wallpaper now
rosary-wallpaper season 2026-12-13 # show the season and mysteries for any date
omarchy theme bg next              # cycle to the rosary-only wallpapers
```

The soft style's terminal contrast is `SOFT_TERMINAL_CONTRAST` near the top of
`bin/rosary-wallpaper`.

## What the installer sets up

| Piece | Location |
|---|---|
| Theme (palette, icons, preview) | `~/.config/omarchy/themes/rosary/` |
| Wallpaper generator | `~/.local/bin/rosary-wallpaper` |
| Daily refresh at 12:05 AM (catches up after sleep) | `~/.config/systemd/user/rosary-wallpaper.timer` |
| Refresh on boot and on theme switch | `~/.config/omarchy/hooks/{post-boot,theme-set}.d/rosary-today.sh` |
| Per-screen wallpapers | `~/.config/omarchy/plugins/<user>.background/` |

**Per-screen wallpapers.** Omarchy normally shows one image on every monitor, cropped to
fill. The installer clones Omarchy's background plugin and patches it so each screen shows
a version of the wallpaper laid out for its shape (ultrawide, 16:10 laptop, and so on).
Images without a per-screen version display exactly as before. The clone doesn't receive
upstream updates to Omarchy's background plugin. To go back:
`omarchy plugin disable $(whoami).background && omarchy plugin enable omarchy.background && omarchy restart shell`.

Dependencies (installed automatically if missing): `python`, `curl`, `librsvg`,
`imagemagick`, `noto-fonts`.

## Uninstall

Switch to another theme, then run `./uninstall.sh`.
