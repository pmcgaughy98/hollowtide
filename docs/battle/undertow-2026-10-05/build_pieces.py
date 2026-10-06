"""Undertow pieces (Claude, 2026-10-05). Free; run from the repo root.
Eruption: RD take 2 with its flat water band trimmed into an oval of churned water
around the body (eruption_alt is the mirror). Stage upscaled to 448 x 252."""
from PIL import Image, ImageOps
D = "docs/battle/undertow-2026-10-05/"
E = "assets/sprites/effects/scourmaw/undertow/"
im = Image.open(D + "eruption_front_take2.png").convert("RGBA"); px = im.load(); W, H = im.size
for y in range(int(H * 0.72), H):
    for x in range(W):
        d = abs(x - W / 2) / (W / 2)
        k = (y - H * 0.72) / (H * 0.28)          # deeper rows are trimmed narrower
        edge = 0.95 - 0.35 * k
        if d > edge or (d > edge - 0.08 and (x + y) % 2):
            px[x, y] = (0, 0, 0, 0)
im.save(E + "eruption.png"); ImageOps.mirror(im).save(E + "eruption_alt.png")
Image.open(D + "stage_0.png").convert("RGBA").resize((448, 252), Image.NEAREST).save("assets/backgrounds/signature_stages/undertow.png")
print("ok", im.getbbox())
