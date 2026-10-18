#!/usr/bin/env python3
"""Teach a clone of omarchy.background to show each screen its own wallpaper variant.

For an image <dir>/<file>, each screen first tries <dir>/screens/<W>x<H>/<file>
(W x H = the screen's logical size) and falls back to the original image.
Usage: patch-background.py <path/to/Background.qml>   (exit 2 if the layout is unrecognized)
"""
import sys

path = sys.argv[1]
s = open(path).read()
if "screenVariant" in s:
    print("already patched")
    sys.exit(0)


def rep(old, new):
    global s
    if s.count(old) != 1:
        print(f"unrecognized Background.qml (could not find: {old.strip()[:60]!r})", file=sys.stderr)
        sys.exit(2)
    s = s.replace(old, new)


rep('''  function imageUrl(path) {
    return Util.fileUrl(path)
  }
''', '''  function imageUrl(path) {
    return Util.fileUrl(path)
  }

  // Per-screen variant: <dir>/screens/<W>x<H>/<file>, keyed by the screen's
  // logical size. Screens without a variant fall back to the original image.
  function screenVariant(path, screen) {
    if (!path || !screen) return path
    const slash = path.lastIndexOf("/")
    return path.slice(0, slash) + "/screens/" + screen.width + "x" + screen.height + path.slice(slash)
  }
''')

for img, prop, ind in (("base", "displayedBackground", 8), ("oldFrame", "oldBackground", 8),
                       ("incomingFrame", "incomingBackground", 10)):
    p = " " * ind
    rep(f'''{p}id: {img}
{p}anchors.fill: parent
{p}source: root.imageUrl(root.{prop})''', f'''{p}id: {img}
{p}anchors.fill: parent
{p}property string wanted: root.{prop}
{p}property bool useOriginal: false
{p}onWantedChanged: useOriginal = false
{p}source: root.imageUrl(useOriginal || !wanted ? wanted : root.screenVariant(wanted, panel.modelData))''')

fallback = "if (status === Image.Error && !useOriginal) { useOriginal = true; return }"
rep('''        onStatusChanged: {
          if (status === Image.Ready && root.finishingTransition) {''', f'''        onStatusChanged: {{
          {fallback}
          if (status === Image.Ready && root.finishingTransition) {{''')
rep('''        visible: root.oldBackground !== "" && root.revealProgress < 1
        onStatusChanged: panel.maybeStartReveal()''', f'''        visible: root.oldBackground !== "" && root.revealProgress < 1
        onStatusChanged: {{
          {fallback}
          panel.maybeStartReveal()
        }}''')
rep('''          mipmap: true
          onStatusChanged: panel.maybeStartReveal()
        }
      }''', f'''          mipmap: true
          onStatusChanged: {{
            {fallback}
            panel.maybeStartReveal()
          }}
        }}
      }}''')

open(path, "w").write(s)
print("patched", path)
