"""Hot glass drips for the Molten Glass pour.

Preston (2026-09-28): the lava looks great except the beads falling out. The
Forge bead cutouts (bead_a/b/c) are mostly dark outline pixels, so inside the
bright stream they read as dirt. These drips use only the glass's own hot
colours and no outline: inside the stream they melt into it, and where one
peels off the edge it shows as a glowing droplet. The Forge beads are kept.

Writes into assets/sprites/effects/vitrecrag/forge_molten_glass/:
  drip_a.png  3x4 falling drop, thin tail up, round hot head down
  drip_b.png  2x2 round blob, for splashes and the pool
  drip_c.png  1x2 fleck

Run from the project root: python tools/build_glass_drips.py
"""
from pathlib import Path

from PIL import Image

OUT = Path(__file__).resolve().parent.parent / "assets/sprites/effects/vitrecrag/forge_molten_glass"
C = {
    "P": (252, 220, 164, 255),  # pale core
    "H": (252, 200, 112, 255),  # hot
    "B": (252, 156, 76, 255),   # bright
    "O": (252, 116, 36, 255),   # orange
    "D": (220, 92, 36, 255),    # deep
    ".": (0, 0, 0, 0),
}
DRIPS = {
    "drip_a": [".O.", ".B.", "BPB", "DHD"],
    "drip_b": ["HB", "BO"],
    "drip_c": ["H", "O"],
}


def main():
    for name, rows in DRIPS.items():
        img = Image.new("RGBA", (len(rows[0]), len(rows)))
        for y, row in enumerate(rows):
            for x, key in enumerate(row):
                img.putpixel((x, y), C[key])
        img.save(OUT / f"{name}.png")
        print(name, img.size)


if __name__ == "__main__":
    main()
