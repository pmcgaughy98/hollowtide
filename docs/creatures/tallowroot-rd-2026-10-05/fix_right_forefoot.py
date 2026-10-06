"""Tallowroot front: the right forefoot (near front leg) ended in splayed tree
roots while every other foot has cream claws. Preston asked for it to match.
Clears the roots and sets a copy of its own hind foot (brown shin, cream claws,
outline) under the leg. Run from the repo root."""
from PIL import Image
D = "docs/creatures/tallowroot-rd-2026-10-05/"
src = Image.open(D + "front_take1.png").convert("RGBA")
out = src.copy()
p = out.load()
for y in range(126, 159):
    for x in range(66, 111):
        p[x, y] = (0, 0, 0, 0)
foot = src.crop((26, 126, 53, 151))
out.alpha_composite(foot, (73, 128))
out.save(D + "front_take1_claws.png")
pad = Image.new("RGBA", (192, 192), (0, 0, 0, 0))
pad.alpha_composite(out, (16, 16))
pad.save(D + "front_pad_192.png")
print("ok", out.getbbox())
