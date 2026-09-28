"""Print the pixel size of every creature sprite, plus the battle zoom it gets.

Read-only. Battle draws each creature at a fixed target height (CREATURE_HEIGHT
in scripts/battle_screen.gd), then picks the nearest whole-number zoom, so two
creatures with very different source art can end up the same size on screen.

Usage:
    python tools/sprite_sizes.py
"""
from __future__ import annotations

import glob
import os

from PIL import Image

# Must match CREATURE_HEIGHT in scripts/battle_screen.gd.
CREATURE_HEIGHT = 264


def zoom_for(height: int) -> int:
    return max(1, round(CREATURE_HEIGHT / height))


def main() -> int:
    paths = sorted(glob.glob("assets/sprites/creatures/*.png"))
    if not paths:
        print("no creature sprites found")
        return 1

    print("%-26s %-12s %-6s %s" % ("file", "size", "zoom", "on-screen height"))
    for path in paths:
        with Image.open(path) as img:
            width, height = img.size
        zoom = zoom_for(height)
        print("%-26s %-12s %-6d %d"
              % (os.path.basename(path), "%dx%d" % (width, height), zoom, height * zoom))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
