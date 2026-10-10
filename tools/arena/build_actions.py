"""Dungeon-size action frames from the Retro Diffusion action sheets (Claude, 2026-10-09).
  python tools/arena/build_actions.py [creature ...]
Reads docs/creatures/actions-2026-10-09/<creature>_<action>_<facing>_sheet.png (rd_action.py), slices the
frames (a grid of the sprite's own cell size), resamples each to the dungeon size of its stage with the
same factor as build_dungeon_set.py (so a frame lines up with the creature's stills), and writes
assets/sprites/arena/<creature>/dungeon/<action>_<facing>_f<i>.png for all eight facings:
  attack: generated for s, se, e, ne, n; w, sw, nw are mirrors.
  hurt:   generated for s, e, n; the diagonals use the nearest side (se, ne -> e; sw, nw -> mirrored e).
  sleep:  generated for s only; a sleeper is shown from the front whatever way it faced (as in Explorers of Sky),
          and only the second half of the take, where it is lying down, is kept as the loop.
Missing sheets are skipped, so it can run while a batch is still generating."""
import sys
from pathlib import Path
import numpy as np
from PIL import Image, ImageOps

sys.path.insert(0, str(Path(__file__).parent))
from downscale import resample  # noqa: E402

ART = Path("assets/sprites/arena")
SHEETS = Path("docs/creatures/actions-2026-10-09")
FACINGS = ["s", "se", "e", "ne", "n", "nw", "w", "sw"]
FRAMES = {"attack": 6, "hurt": 6, "sleep": 8}
# facing shown -> (generated facing, mirrored)
SOURCE = {
    "attack": {"s": ("s", False), "se": ("se", False), "e": ("e", False), "ne": ("ne", False), "n": ("n", False),
               "nw": ("ne", True), "w": ("e", True), "sw": ("se", True)},
    "hurt": {"s": ("s", False), "se": ("e", False), "e": ("e", False), "ne": ("e", False), "n": ("n", False),
             "nw": ("e", True), "w": ("e", True), "sw": ("e", True)},
    "sleep": {f: ("s", False) for f in FACINGS},
}
TARGET = {0: 15.5, 1: 21.0, 2: 30.0}   # keep in step with build_dungeon_set.py
# The lighter plan (front, side and back attacks; front and side hurts) leaves facings ungenerated;
# each uses the nearest that exists. Mirrored facings (w, sw, nw) mirror what their source used.
FALLBACK = {"se": ["e", "s"], "ne": ["e", "n"], "e": ["s"], "n": ["e", "s"]}


def stage_of(name: str) -> int:
    import re
    src = open("scripts/arena/arena_prototype.gd", encoding="utf-8").read()
    for m in re.finditer(r'"forms": \[\["([a-z]+)", "[^"]*"\], \["([a-z]+)", "[^"]*"\], \["([a-z]+)"', src):
        if name in m.groups():
            return m.groups().index(name)
    raise SystemExit(f"{name}: not in LINES")


def factor(name: str) -> float:
    v = [np.sqrt((np.array(Image.open(ART / name / f"{f}.png").convert("RGBA"))[..., 3] > 0).sum()) for f in FACINGS]
    return float(np.mean(v)) / TARGET[stage_of(name)]


def frames_of(sheet: Path, side: int, n: int) -> list:
    im = Image.open(sheet).convert("RGBA")
    cols, rows = im.width // side, im.height // side
    out = []
    for r in range(rows):
        for c in range(cols):
            if len(out) < n:
                out.append(im.crop((c * side, r * side, (c + 1) * side, (r + 1) * side)))
    return out


for name in (sys.argv[1:] or ["kithflare", "tallowroot", "rimefin", "cinderhide", "fusern", "preostmar", "punchybun", "listener", "canvaswing", "dustkite"]):
    side = Image.open(ART / name / "s.png").size[0]
    f = factor(name)
    made = []
    for action, n in FRAMES.items():
        cache = {}
        for shown in FACINGS:
            gen, flip = SOURCE[action][shown]
            sheet = SHEETS / f"{name}_{action}_{gen}_sheet.png"
            for alt in FALLBACK.get(gen, []):
                if sheet.exists():
                    break
                gen, sheet = alt, SHEETS / f"{name}_{action}_{alt}_sheet.png"   # a facing not generated uses the nearest one that was
            if not sheet.exists():
                continue
            if gen not in cache:
                frames = frames_of(sheet, side, n)
                if action == "sleep":
                    frames = frames[n // 2:]   # the take lies down over its first half; the loop is the asleep half
                cache[gen] = [resample(fr, f) for fr in frames]
            for i, fr in enumerate(cache[gen]):
                (ImageOps.mirror(fr) if flip else fr).save(ART / name / "dungeon" / f"{action}_{shown}_f{i}.png")
            made.append(f"{action}:{shown}")
    print(name, "x%.2f" % f, ", ".join(made) or "no sheets yet")
