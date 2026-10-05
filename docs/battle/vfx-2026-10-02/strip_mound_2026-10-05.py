"""Rebuild the Furnace Roar finale sheet without RD's rock mound (2026-10-05).

Source: furnace_take2.png (RD output, 4x4, 96px cells). Keeps the white-hot
highlights the first cleanup removed. In every cell the grey cone starts at
row 67 or 68: everything from that row down is cleared, along with grey rim
pixels just above it, and the fire is moved down 23 rows so its base sits on
the old ground line (row 90), which is where the battle anchors the frame.
"""
from PIL import Image
SRC = "docs/battle/vfx-2026-10-02/furnace_take2.png"
OUT = "assets/sprites/effects/vfx_rd_2026_10_01/furnace_roar_geyser_4x4.png"
CELL, RIM, SHIFT, RIM_BAND = 96, 67, 23, 8

def grey(p):
    r, g, b, a = p
    return a > 0 and max(r, g, b) < 120 and max(r, g, b) - min(r, g, b) < 40

src = Image.open(SRC).convert("RGBA")
out = Image.new("RGBA", src.size, (0, 0, 0, 0))
for c in range(16):
    cx, cy = (c % 4) * CELL, (c // 4) * CELL
    cell = src.crop((cx, cy, cx + CELL, cy + CELL))
    px = cell.load()
    for y in range(CELL):
        for x in range(CELL):
            if y >= RIM or (y >= RIM - RIM_BAND and grey(px[x, y])):
                px[x, y] = (0, 0, 0, 0)
    out.alpha_composite(cell, (cx, cy + SHIFT), (0, 0, CELL, CELL - SHIFT))
out.save(OUT)
print("wrote", OUT)
