"""Flat facings for low creatures (Claude, 2026-10-09, Preston: "Warden and Vitrecrag don't
touch flat on the ground of the arena map at all angles"). Retro Diffusion's rotation draws
the south view from high above and the side views from near ground level, so on the arena's
overhead floor a frog or a tortoise seen from the side stands on edge. For a creature that is
flat on the ground, every facing is the south view turned in the image plane and squashed a
little toward the floor's angle, and its walk is the south walk turned the same way.
  python tools/arena/flat_facings.py <name> [name ...]
Reads assets/sprites/arena/<name>/small/s.png and walk_s_f*.png (the built small set) and
rewrites the other seven facings and their walks; the originals are kept once under
docs/creatures/arena-anchor-2026-10-09/perspective_backup/<name>/ (never inside assets, or Godot imports them).
"""
import shutil, sys
from pathlib import Path
from PIL import Image
SQUASH = 0.82   # the floor's foreshortening applied to turned views (the south view keeps its own)
TURN = {"e": 90, "ne": 135, "n": 180, "nw": 225, "w": 270, "sw": 315, "se": 45}   # counter-clockwise degrees from south

def turn(im: Image.Image, deg: int) -> Image.Image:
    big = im.rotate(deg, resample=Image.NEAREST, expand=True)
    if deg % 180 != 0:
        big = big.resize((big.width, max(1, round(big.height * SQUASH))), Image.NEAREST)
    # trim to content and pad back to the source size so the builder's assumptions hold
    bbox = big.getbbox()
    if bbox:
        big = big.crop(bbox)
    out = Image.new("RGBA", im.size, (0, 0, 0, 0))
    if big.width > out.width or big.height > out.height:
        big.thumbnail(out.size, Image.NEAREST)
    out.alpha_composite(big, ((out.width - big.width) // 2, (out.height - big.height) // 2))
    return out

for name in sys.argv[1:]:
    small = Path("assets/sprites/arena") / name / "small"
    keep = Path("docs/creatures/arena-anchor-2026-10-09/perspective_backup") / name
    if not keep.exists():
        shutil.copytree(small, keep, ignore=shutil.ignore_patterns("*.import"))
    s = Image.open(keep / "s.png").convert("RGBA")
    walks = [Image.open(keep / f"walk_s_f{k}.png").convert("RGBA") for k in range(8) if (keep / f"walk_s_f{k}.png").exists()]
    for facing, deg in TURN.items():
        turn(s, deg).save(small / f"{facing}.png")
        for k, w in enumerate(walks):
            turn(w, deg).save(small / f"walk_{facing}_f{k}.png")
    print(name, "flat facings from the south view:", list(TURN), "walk frames", len(walks))
