"""Small square HUD headshots cut from each creature's own sprites (Claude, 2026-10-10; Preston:
"make small square portraits for the creatures next to their name"). No new art: the arena south
facing (assets/sprites/arena/<form>/s.png) is cropped to a square round the head and shrunk to
48x48 with nearest sampling, saved as assets/sprites/arena/<form>/portrait.png.

The default square sits at the top of the sprite (the head of a creature facing the camera) and is
as wide as the upper body. CROP overrides it per form, read by eye from portraits_sheet.png:
(centre x, top, side) as fractions of the sprite's opaque box.
  python tools/arena/build_portraits.py            all forms with an s.png
  python tools/arena/build_portraits.py sheet      also writes docs/ui/ui-tour-2026-10-10/portraits_sheet.png
"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageOps

ART = Path("assets/sprites/arena")
SIZE = 48
CROP = {   # front-view cuts (s), for forms whose turned view hides the face; Troughspine's turned view is nearly top-down
    "fusern": (0.5, 0.4, 0.5),
    "slagglass": (0.5, 0.36, 0.5),
    "troughspine": (0.45, 0.48, 0.56),
    "vitrecrag": (0.5, 0.47, 0.56),
}

# Headshots the Mystery Dungeon way (Preston, 2026-10-10: "we want headshots like mystery dungeon.
# So them facing us but pointing to their right"): the three-quarter facing that turns to the
# creature's own right (sw), cut tight round the head. Read by eye from a tenths grid of every sw
# sprite. Forms missing here read better from the front and keep the CROP / default front cut.
HEAD = {   # Preston's notes, 2026-10-10: Kithflare, Punchybun and Sparkwick left; Scourmaw down and a little right;
           # Canvaswing up to its head; Cinderhide, Clinkerhide, Ironvent, the jade line, Tallowroot and Rampartroot
           # on the same turned angle as the rest (Huskward's framing); Archroot framed like Springvault.
    "archroot": (0.22, 0.44, 0.36),
    "caller": (0.2, 0.0, 0.35),
    "canvaswing": (0.15, 0.36, 0.31),
    "cinderhide": (0.15, 0.08, 0.35),
    "clinkerhide": (0.14, 0.33, 0.28),
    "dustkite": (0.15, 0.0, 0.3),
    "galeshear": (0.34, 0.13, 0.25),
    "highsignal": (0.15, 0.2, 0.34),
    "huskward": (0.27, 0.28, 0.38),
    "ironvent": (0.13, 0.28, 0.3),
    "kithflare": (0.36, 0.0, 0.5),
    "listener": (0.23, 0.12, 0.5),
    "oathfen": (0.22, 0.5, 0.35),
    "oxbowarchon": (0.22, 0.52, 0.33),
    "preostmar": (0.15, 0.15, 0.3),
    "punchybun": (0.27, 0.0, 0.55),
    "rampartroot": (0.24, 0.4, 0.36),
    "riftfin": (0.15, 0.3, 0.3),
    "rimefin": (0.38, 0.25, 0.5),
    "scourmaw": (0.27, 0.38, 0.4),
    "sparkjab": (0.22, 0.0, 0.35),
    "sparkwick": (0.2, 0.18, 0.37),
    "springvault": (0.2, 0.38, 0.4),
    "starward": (0.4, 0.0, 0.33),
    "stormwick": (0.15, 0.2, 0.33),
    "tallowroot": (0.3, 0.25, 0.47),
    "warden": (0.24, 0.5, 0.33),
    "waywhistle": (0.2, 0.0, 0.33),
    "windcut": (0.12, 0.5, 0.28),
}


# A form whose best face is in its original front art (Preston, 2026-10-10: Galeshear's front view,
# head thrown back, "looks epic"), mirrored so it turns to its right like the rest.
SOURCE = {"galeshear": "docs/creatures/arena-starters-2026-10-07/forms/galeshear_arena_front_take1.png"}


def portrait(form: str) -> Image.Image:
    facing = "sw" if form in HEAD else "s"
    if form in SOURCE:
        im = ImageOps.mirror(Image.open(SOURCE[form]).convert("RGBA"))
    else:
        im = Image.open(ART / form / f"{facing}.png").convert("RGBA")
    x0, y0, x1, y1 = im.getchannel("A").getbbox()
    w, h = x1 - x0, y1 - y0
    cx, top, side = HEAD[form] if form in HEAD else CROP.get(form, (0.5, 0.0, 0.0))
    s = side * max(w, h) if side else min(w, h * 0.75, max(w, h) * 0.62)
    left = x0 + cx * w - s / 2
    t = y0 + top * h
    box = tuple(int(round(v)) for v in (left, t, left + s, t + s))
    return im.crop(box).resize((SIZE, SIZE), Image.NEAREST)


if __name__ == "__main__":
    forms = sorted(p.name for p in ART.iterdir() if (p / "s.png").exists())
    out = []
    for f in forms:
        pic = portrait(f)
        pic.save(ART / f / "portrait.png")
        out.append((f, pic))
    print(len(out), "portraits")
    if "sheet" in sys.argv:
        cols = 8
        sheet = Image.new("RGBA", (cols * 80, ((len(out) + cols - 1) // cols) * 80), (36, 43, 37, 255))
        bg = Image.new("RGBA", (SIZE, SIZE), (239, 230, 210, 255))   # the HUD's parchment square
        d = ImageDraw.Draw(sheet)
        for k, (f, pic) in enumerate(out):
            x, y = (k % cols) * 80 + 16, (k // cols) * 80 + 6
            sheet.alpha_composite(bg, (x, y))
            sheet.alpha_composite(pic, (x, y))
            d.rectangle((x - 1, y - 1, x + SIZE, y + SIZE), outline=(182, 155, 109, 255))
            d.text((x - 12, y + 52), f[:12], fill=(255, 244, 232, 255))
        sheet.resize((sheet.width * 2, sheet.height * 2), Image.NEAREST).save("docs/ui/ui-tour-2026-10-10/portraits_sheet.png")
