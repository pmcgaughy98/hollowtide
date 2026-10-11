"""Dialogue portraits for the scene text box (Claude, 2026-10-10; Preston: "make dialogue portraits for
stage 1 starters then warden for boss scene").

No new art: each one is cut from the creature's own detailed front idle (the bigger, earlier sprites)
round the face, then shrunk to 40x40 with the palette kept (tools/arena/downscale.py resample).
40x40 is Explorers of Sky's portrait size, and the game shows it at the world's 3x, so a portrait
pixel is a world pixel. Boxes were read by eye from a tenths grid of each source.
  python tools/ui/build_dialogue_portraits.py     writes assets/sprites/ui/dialogue/<form>.png
"""
import sys
from pathlib import Path
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "arena"))
from downscale import resample

ROOT = Path("assets/sprites/creatures")
OUT = Path("assets/sprites/ui/dialogue")
SIZE = 40
SOURCES = {   # form: (source frame, crop box left, top, right, bottom)
    "kithflare": (ROOT / "starter_material_detail_2026_10_05/kithflare_idle_tail_outline_2026_10_05/f0.png", (70, 19, 140, 89)),
    "tallowroot": (ROOT / "idle_2026_10_05/1701_tallowroot/f0.png", (75, 19, 163, 107)),
    "rimefin": (ROOT / "idle_2026_10_05/001_rimefin/f0.png", (90, 61, 171, 142)),
    "warden": (Path("docs/creatures/arena-starters-2026-10-07/forms/warden_arena_front_take1.png"), (62, 42, 124, 104)),
    # The rival crew (2026-10-10), from their front takes (96 px).
    "mirekit": (Path("docs/creatures/arena-starters-2026-10-07/forms/mirekit_arena_front_take1.png"), (42, 18, 90, 66)),
    "whinet": (Path("docs/creatures/arena-starters-2026-10-07/forms/whinet_arena_front_take1.png"), (26, 18, 78, 70)),
    "starward": (Path("docs/creatures/arena-starters-2026-10-07/forms/starward.png"), (62, 0, 118, 56)),   # the Guildmaster (Preston, 2026-10-10)
    # Highbank's townsfolk and the Hollow's new wilds (2026-10-10), from Preston's chosen takes.
    "wayling": (Path("docs/creatures/arena-starters-2026-10-07/forms/wayling_arena_front_chosen.png"), (30, 8, 70, 48)),
    "swaphoard": (Path("docs/creatures/arena-starters-2026-10-07/forms/swaphoard_arena_front_chosen.png"), (40, 6, 90, 56)),
    "pouchbill": (Path("docs/creatures/arena-starters-2026-10-07/forms/pouchbill_arena_front_chosen.png"), (40, 8, 96, 64)),
    "inkhoot": (Path("docs/creatures/arena-starters-2026-10-07/forms/inkhoot_arena_front_chosen.png"), (34, 4, 124, 94)),
    "cairnshell": (Path("docs/creatures/arena-starters-2026-10-07/forms/cairnshell_arena_front_chosen.png"), (82, 70, 128, 116)),
    "crawdukes": (Path("docs/creatures/arena-starters-2026-10-07/forms/crawdukes_arena_front_chosen.png"), (54, 0, 112, 58)),
    "skimlet": (Path("docs/creatures/arena-starters-2026-10-07/forms/skimlet_arena_front_chosen.png"), (36, 26, 76, 66)),
    "ozbender": (Path("docs/creatures/arena-starters-2026-10-07/forms/ozbender_arena_front_chosen.png"), (50, 42, 96, 88)),
    "valvekin": (Path("docs/creatures/arena-starters-2026-10-07/forms/valvekin_arena_front_chosen.png"), (14, 44, 66, 96)),
    "gruntle": (Path("docs/creatures/arena-starters-2026-10-07/forms/gruntle_arena_front_chosen.png"), (40, 14, 95, 69)),
}

# Every recruitable form without a hand-placed source above (Preston, 2026-10-10: "make normal portraits
# for all recruitable creatures"): all stages of every line met in dungeons (the Punchybun line is the
# Guildmaster's and is not met). Cut from the full-size turned sprite with the headshot crop Preston
# reviewed (tools/arena/build_portraits.py HEAD/CROP/SOURCE), then resampled to 40x40 like the rest.
import re
from PIL import ImageOps
from build_portraits import HEAD, CROP, SOURCE as HEAD_SOURCE

NOT_MET = {"punchybun", "sparkjab", "starward"}


def recruitable() -> list:
    src = open("scripts/arena/arena_prototype.gd", encoding="utf-8").read()
    forms = []
    for m in re.finditer(r'"forms": \[\["([a-z]+)", "[^"]*"\], \["([a-z]+)", "[^"]*"\], \["([a-z]+)"', src):
        forms += [f for f in m.groups() if f not in NOT_MET]
    return forms


def auto_cut(form: str) -> Image.Image:
    """The headshot's square, from the full-size sprite (the headshot itself is only 48 px)."""
    art = Path("assets/sprites/arena")
    if form in HEAD_SOURCE:
        im = ImageOps.mirror(Image.open(HEAD_SOURCE[form]).convert("RGBA"))
    else:
        im = Image.open(art / form / ("sw.png" if form in HEAD else "s.png")).convert("RGBA")
    x0, y0, x1, y1 = im.getchannel("A").getbbox()
    w, h = x1 - x0, y1 - y0
    cx, top, side = HEAD[form] if form in HEAD else CROP.get(form, (0.5, 0.0, 0.0))
    s = side * max(w, h) if side else min(w, h * 0.75, max(w, h) * 0.62)
    left = x0 + cx * w - s / 2
    t = y0 + top * h
    return im.crop(tuple(int(round(v)) for v in (left, t, left + s, t + s)))


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    sheet = Image.new("RGBA", (len(SOURCES) * 132, 132), (239, 230, 210, 255))
    for k, (form, (src, box)) in enumerate(SOURCES.items()):
        cut = Image.open(src).convert("RGBA").crop(box)
        side = max(cut.size)
        im = resample(cut, side / SIZE).resize((SIZE, SIZE), Image.NEAREST)
        im.save(OUT / f"{form}.png")
        sheet.alpha_composite(im.resize((120, 120), Image.NEAREST), (k * 132 + 6, 6))
        print(form, cut.size, "->", im.size)
    sheet.save("docs/ui/dialogue_portraits_sheet.png")
    # The recruitable forms, and a review sheet of every portrait on the normal face's blue.
    from PIL import ImageDraw
    auto = [f for f in recruitable() if f not in SOURCES]
    for form in auto:
        cut = auto_cut(form)
        im = resample(cut, max(cut.size) / SIZE).resize((SIZE, SIZE), Image.NEAREST)
        im.save(OUT / f"{form}.png")
    every = [f for f in recruitable() if (OUT / f"{f}.png").exists()]
    cols = 8
    review = Image.new("RGBA", (cols * 140, ((len(every) + cols - 1) // cols) * 150), (29, 36, 32, 255))
    d = ImageDraw.Draw(review)
    for k, f in enumerate(every):
        x, y = (k % cols) * 140 + 10, (k // cols) * 150 + 6
        bg = Image.new("RGBA", (SIZE, SIZE), (143, 208, 228, 255))
        bg.alpha_composite(Image.open(OUT / f"{f}.png").convert("RGBA"))
        review.alpha_composite(bg.resize((120, 120), Image.NEAREST), (x, y))
        d.text((x, y + 124), f, fill=(255, 244, 232, 255))
    review.save("docs/ui/dialogue_portraits_recruitable.png")
    print(len(auto), "recruitable portraits made;", len(every), "on the review sheet")
