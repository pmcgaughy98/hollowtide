"""Stormlantern attack frames (Claude, 2026-10-05, second pass). Free; run from the repo root.

Poses are RD image_edits of Stormwick's front ($0.18 each): pose_raise_raw (rears up,
lantern overhead, roaring at the sky) and pose_snap2_raw (whips the lantern forward
over its head), the snap pose outpainted 48 px right (pose_snap2_outpaint, $0.18)
because the lantern ran off the canvas. Frames are padded 48 px each side to 315 x 219
so the snap's lantern fits; the battle centres frames, so the feet stay put.
Orb frames from the RD sheet are composited onto the lantern so it overloads."""
from pathlib import Path
from PIL import Image
D = "docs/battle/stormlantern-2026-10-05/"
OUT = Path("assets/sprites/creatures/attacks/kithflare3_stormlantern"); OUT.mkdir(parents=True, exist_ok=True)
FX = Path("assets/sprites/effects/kithflare3/stormlantern"); FX.mkdir(parents=True, exist_ok=True)
PAD = 48
W, H = 219 + 2 * PAD, 219
rest = Image.open("assets/sprites/creatures/starter_texture_refine_2026_10_05/kithflare3_front_source_grid.png").convert("RGBA")
raise_ = Image.open(D + "pose_raise_raw.png").convert("RGBA")
snap = Image.open(D + "pose_snap2_raw.png").convert("RGBA")
out = Image.open(D + "pose_snap2_outpaint.png").convert("RGBA")
# The outpainted strip: drop its flat background, keep the original 219 px untouched.
bgc = (254, 252, 236)
strip = out.crop((219, 0, 267, 219)); px = strip.load()
for y in range(strip.height):
    for x in range(strip.width):
        r, g, b, a = px[x, y]
        if abs(r - bgc[0]) + abs(g - bgc[1]) + abs(b - bgc[2]) < 24:
            px[x, y] = (0, 0, 0, 0)
snap_full = Image.new("RGBA", (267, 219), (0, 0, 0, 0)); snap_full.alpha_composite(snap, (0, 0)); snap_full.alpha_composite(strip, (219, 0))

orb = Image.open(D + "orb_vfx_0.png").convert("RGBA")
cell = lambda i: orb.crop(((i % 4) * 96, (i // 4) * 96, (i % 4 + 1) * 96, (i // 4 + 1) * 96)).crop((10, 10, 86, 86))

def padded(im, dx=PAD):
    c = Image.new("RGBA", (W, H), (0, 0, 0, 0)); c.alpha_composite(im, (dx, 0)); return c

def with_orb(base, at, i, size):
    f = base.copy(); o = cell(i).resize((size, size), Image.NEAREST)
    f.alpha_composite(o, (at[0] + PAD - size // 2, at[1] - size // 2)); return f

RAISE_LANTERN = (112, 46)
frames = {
    "rest": padded(rest),
    "raise": padded(raise_),
    "glow": with_orb(padded(raise_), RAISE_LANTERN, 1, 34),
    "kindle": with_orb(padded(raise_), RAISE_LANTERN, 5, 42),
    "full": with_orb(padded(raise_), RAISE_LANTERN, 12, 52),
    "full_b": with_orb(padded(raise_), RAISE_LANTERN, 14, 56),
}
s = Image.new("RGBA", (W, H), (0, 0, 0, 0)); s.alpha_composite(snap_full, (PAD, 0)); frames["snap"] = s
# Spent: after the throw the lantern's core is gone, so its bright pixels fall
# to a dark ember until it rests and relights.
spent = frames["rest"].copy(); sp = spent.load()
LC = (59 + PAD, 69)
for y in range(max(0, LC[1] - 22), min(H, LC[1] + 22)):
    for x in range(max(0, LC[0] - 22), min(W, LC[0] + 22)):
        r, g, b, a = sp[x, y]
        if a and r > 170 and g > 90 and (x - LC[0]) ** 2 + (y - LC[1]) ** 2 < 22 * 22:
            sp[x, y] = (int(r * 0.42), int(g * 0.3), int(b * 0.25), a)
frames["spent"] = spent
for n, im in frames.items():
    im.save(OUT / f"{n}.png")
cell(15).save(FX / "stormlantern_core.png")
card = rest.crop((20, 20, 200, 172)).resize((140, 118), Image.NEAREST); card.save(OUT / "titlecard.png")
print("ok", W, H, "snap bbox", frames["snap"].getbbox())
