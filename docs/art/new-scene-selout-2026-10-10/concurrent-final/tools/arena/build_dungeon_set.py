"""Dungeon-size sprites, one size per stage (Claude, 2026-10-09; Preston: "Kithflare and
Tallowroot are just a tad too big, but I don't want making them smaller to ruin their look.
They should be stage 1 size though and same for other stages. They should be the correct stage
size"). The arena keeps its own tuned small set; the dungeon reads this one.

Size is measured as the square root of a sprite's solid pixels (its visual mass, fair to tall
and wide bodies alike), averaged over the eight facings. Every creature of a stage is resampled
from its full-size art to that stage's TARGET with the palette locked (downscale.resample), the
same method as the arena's sized creatures, so the look survives.
  python tools/arena/build_dungeon_set.py [name ...]
Writes assets/sprites/arena/<name>/dungeon/<facing>.png and walk_<facing>_f0..f7.png.
  python tools/arena/build_dungeon_set.py warden --set=boss --scale=1.9
      a larger set for a boss (Preston, 2026-10-10: bosses bigger than normal, as in Mystery
      Dungeon), written to <name>/boss/; --set=escort --scale=1.35 for its escort."""
import re, sys
from pathlib import Path
import numpy as np
from PIL import Image, ImageOps

sys.path.insert(0, str(Path(__file__).parent))
from downscale import resample  # noqa: E402

TARGET = {0: 15.5, 1: 21.0, 2: 30.0}   # stage 1, 2, 3 (drafts; Preston approves the look)
ART = Path("assets/sprites/arena")
WALK = Path("docs/creatures/arena-starters-2026-10-07/walk")
FACINGS = ["s", "se", "e", "ne", "n", "nw", "w", "sw"]
MIRROR = {"e": "w", "se": "sw", "ne": "nw", "w": "e", "sw": "se", "nw": "ne"}
STILL_MIRRORS = {"kithflare": {"e": "w"}, "rimefin": {"e": "w"}, "sparkwick": {"e": "w"}}   # as build_small.py

src = open("scripts/arena/arena_prototype.gd", encoding="utf-8").read()
STAGE = {}
for m in re.finditer(r'"forms": \[\["([a-z]+)", "[^"]*"\], \["([a-z]+)", "[^"]*"\], \["([a-z]+)"', src):
    for k, n in enumerate(m.groups()):
        STAGE[n] = k
# Dungeon-only lines (dungeon.gd CREW_LINES, the rival crew, 2026-10-10): not in the arena's LINES.
STAGE.update({"mirekit": 0, "whinet": 0, "gruntle": 0})
STAGE.update({"skimlet": 0, "ozbender": 0, "valvekin": 0, "wayling": 0, "swaphoard": 1, "pouchbill": 1, "inkhoot": 2, "cairnshell": 2, "crawdukes": 2})   # the Hollow's new wilds and the townsfolk (one form each so far)


def mass(name):
    v = [np.sqrt((np.array(Image.open(ART / name / f"{f}.png").convert("RGBA"))[..., 3] > 0).sum()) for f in FACINGS]
    return float(np.mean(v))


def walk_frames(name, facing):
    sheet = WALK / f"{name}_{facing}_sheet.png"
    if not sheet.exists():
        return None
    im = Image.open(sheet).convert("RGBA")
    cw = im.height // 2
    return [im.crop((c * cw, r * cw, (c + 1) * cw, (r + 1) * cw)) for r in range(2) for c in range(4)]


OPTS = dict(a[2:].split("=", 1) for a in sys.argv[1:] if a.startswith("--"))
SET = OPTS.get("set", "dungeon")
SIZE = float(OPTS.get("scale", "1"))
# Creatures drawn bigger than their stage in every set (Preston, 2026-10-10: Gruntle, the crew's boss, is a
# stage 1 that looks fat and bulky; about 1.25x the crew, "a tad" under the first stand-in).
BOOST = {"gruntle": 1.25}
NAMES = [a for a in sys.argv[1:] if not a.startswith("--")]

for name in (NAMES or sorted(STAGE)):
    if not (ART / name / "s.png").exists():
        print(name, "has no art yet")
        continue
    f = mass(name) / (TARGET[STAGE[name]] * SIZE * BOOST.get(name, 1.0))
    out = ART / name / SET
    out.mkdir(parents=True, exist_ok=True)
    for fc in FACINGS:
        resample(Image.open(ART / name / f"{fc}.png"), f).save(out / f"{fc}.png")
    for fc, source in STILL_MIRRORS.get(name, {}).items():
        ImageOps.mirror(Image.open(out / f"{source}.png").convert("RGBA")).save(out / f"{fc}.png")
    cell = Image.open(ART / name / "s.png").size
    walks = 0
    for fc in FACINGS:
        frames, flip = walk_frames(name, fc), False
        if frames is None and fc in MIRROR:
            frames, flip = walk_frames(name, MIRROR[fc]), True
        if frames is None:
            continue
        for i, fr in enumerate(frames):
            if fr.size != cell:
                fr = fr.resize(cell, Image.NEAREST)
            small = resample(fr, f)
            (ImageOps.mirror(small) if flip else small).save(out / f"walk_{fc}_f{i}.png")
        walks += 1
    got = float(np.mean([np.sqrt((np.array(Image.open(out / f"{fc}.png"))[..., 3] > 0).sum()) for fc in FACINGS]))
    print(f"{name:12s} stage {STAGE[name] + 1}: shrunk by {f:.2f}, size {got:.1f} (target {TARGET[STAGE[name]] * SIZE:.1f}, set {SET}), walks {walks}")
