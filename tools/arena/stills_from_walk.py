"""Make a creature's standing stills from chosen walk frames (Claude, 2026-10-10; Preston: Wayling "looks
like it's floating with its wings in the air"). Its takes were drawn mid take-off from a perch, so every
still has the wings raised; its walk sheets have frames with the wings folded and the feet down.
  python tools/arena/stills_from_walk.py wayling s=4 se=3 e=2 ne=3 n=4
Each facing takes that frame (0-7, left to right, top row first) of its walk sheet. The west facings are
mirrors of the east ones (sw from se, w from e, nw from ne), the same way the walks are. The stills being
replaced are kept once in docs/creatures/stills-from-walk-2026-10-10/<form>/. Then rebuild the set:
python tools/arena/build_dungeon_set.py <form> --set=town --scale=1.5
"""
import shutil, sys
from pathlib import Path
from PIL import Image, ImageOps

WALK = Path("docs/creatures/arena-starters-2026-10-07/walk")
ART = Path("assets/sprites/arena")
MIRROR = {"sw": "se", "w": "e", "nw": "ne"}

form = sys.argv[1]
pick = dict(a.split("=") for a in sys.argv[2:])
keep = Path("docs/creatures/stills-from-walk-2026-10-10") / form
keep.mkdir(parents=True, exist_ok=True)
frames = {}
for facing, i in pick.items():
    sheet = Image.open(WALK / f"{form}_{facing}_sheet.png").convert("RGBA")
    cw = sheet.height // 2
    i = int(i)
    frames[facing] = sheet.crop(((i % 4) * cw, (i // 4) * cw, (i % 4 + 1) * cw, (i // 4 + 1) * cw))
for west, east in MIRROR.items():
    if east in frames:
        frames[west] = ImageOps.mirror(frames[east])
for facing, im in frames.items():
    out = ART / form / f"{facing}.png"
    if out.exists() and not (keep / out.name).exists():
        shutil.copy2(out, keep / out.name)
    im.save(out)
    print(out, "from", pick.get(facing, "mirror of " + MIRROR.get(facing, "")))
