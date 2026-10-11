"""Recolour one line's wing or sail membranes so two lines stop looking alike (Claude, 2026-10-10;
Preston: "dustkite and canvaswing's lines look too similar, someone needs a recolor").

Only the blue membrane pixels move (hue 180 to 250 degrees, even the greyish slate blues); the body, the outline
and the veins stay. Each pixel keeps its own lightness, so the shading survives.
  python tools/arena/recolor_line.py preview <scheme> <out.png>
  python tools/arena/recolor_line.py apply <scheme>        rewrites every sprite of the line in place
Schemes: dust (Dustkite's line, dusty rust-ochre sails), canvas (Canvaswing's line, cream canvas wings).
"""
import colorsys, sys
from pathlib import Path
from PIL import Image

SCHEMES = {
    "dust": {"forms": ["dustkite", "waywhistle", "highsignal"], "hue": 24 / 360, "sat": 0.62, "light": 1.0},
    "canvas": {"forms": ["canvaswing", "windcut", "galeshear"], "hue": 38 / 360, "sat": 0.22, "light": 1.28},
}


def recolor(im: Image.Image, s: dict) -> Image.Image:
    im = im.convert("RGBA")
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            h, l, sat = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
            if 180 / 360 <= h <= 250 / 360 and sat > 0.05 and 0.1 < l < 0.93:
                nl = min(0.95, l * s["light"])
                nr, ng, nb = colorsys.hls_to_rgb(s["hue"], nl, min(1.0, s["sat"] * (0.6 + sat)))
                px[x, y] = (int(nr * 255), int(ng * 255), int(nb * 255), a)
    return im


def files(form: str) -> list:
    """Every sprite of the form, and the source sheets the builders read, so a rebuild keeps the colour."""
    root = Path("assets/sprites/arena") / form
    out = [p for p in root.rglob("*.png")]
    out += [p for p in Path("assets/sprites/ui/dialogue").glob(f"{form}*.png")]
    src = Path("docs/creatures/arena-starters-2026-10-07")
    out += list(src.glob(f"{form}_*sheet.png")) + list(src.glob(f"{form}_*rotation_3x3.png"))
    out += list((src / "walk").glob(f"{form}_*_sheet.png")) + list((src / "forms").glob(f"{form}*.png"))
    out += list(Path("docs/creatures/actions-2026-10-09").glob(f"{form}_*_sheet.png"))
    return sorted(set(out))


if __name__ == "__main__":
    mode, name = sys.argv[1], sys.argv[2]
    s = SCHEMES[name]
    if mode == "preview":
        tiles = [recolor(Image.open(f"assets/sprites/arena/{f}/se.png"), s) for f in s["forms"]]
        k = 240
        sheet = Image.new("RGBA", (len(tiles) * (k + 20), k + 20), (222, 214, 196, 255))
        for i, t in enumerate(tiles):
            z = k / max(t.size)
            t = t.resize((int(t.width * z), int(t.height * z)), Image.NEAREST)
            sheet.alpha_composite(t, (i * (k + 20) + 10, 10))
        sheet.save(sys.argv[3])
    elif mode == "apply":
        import shutil
        back = Path("docs/creatures/gale-recolor-2026-10-10/before")
        n = 0
        for f in s["forms"]:
            for p in files(f):
                keep = back / p
                if not keep.exists():   # the original, once, before any recolour
                    keep.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(p, keep)
                recolor(Image.open(keep), s).save(p)   # always from the original, so a rerun is safe
                n += 1
        print("recoloured", n, "files; originals in", back)
