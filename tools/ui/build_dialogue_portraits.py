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
}

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
