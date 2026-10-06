"""Cut Retro Diffusion idle sheets into frames (Claude, 2026-10-06).
  python tools/debug/slice_idles.py <sheet_dir> [back]
Each <file>_idle_sheet.png (or <file>_back_idle_sheet.png) is a 4 x 2 grid of 8 frames.
RD can return a slightly smaller canvas than the art (Stormwick 216 for 219), so every
frame is placed back on the sprite's own canvas with the same shift, chosen so frame 0's
feet and centre line up with the sprite's. Writes
assets/sprites/creatures/idle_2026_10_05/<file>/f0..f7.png (front) or .../<file>/back_f0..f7.png
and prints how far the feet and the edges move across the loop."""
import re, sys
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
sheets, back = Path(sys.argv[1]), len(sys.argv) > 2 and sys.argv[2] == "back"
suffix = "_back_idle_sheet.png" if back else "_idle_sheet.png"
for sheet in sorted(sheets.glob("*" + suffix)):
    file = sheet.name[: -len(suffix)]
    text = (ROOT / "data/creatures" / f"{file}.tres").read_text(encoding="utf-8")
    key = re.search(r'^%s = ExtResource\("([^"]+)"\)' % ("back_sprite" if back else "sprite"), text, re.M).group(1)
    art = Image.open(ROOT / re.search(r'path="res://([^"]+)" id="%s"' % re.escape(key), text).group(1)).convert("RGBA")
    im = Image.open(sheet).convert("RGBA")
    side = im.width // 4
    frames = [im.crop((c * side, r * side, (c + 1) * side, (r + 1) * side)) for r in range(2) for c in range(4)]
    a, f = art.getbbox(), frames[0].getbbox()
    dx = round((a[0] + a[2]) / 2 - (f[0] + f[2]) / 2)
    dy = a[3] - f[3]
    out = ROOT / "assets/sprites/creatures/idle_2026_10_05" / file
    out.mkdir(parents=True, exist_ok=True)
    feet, edge = set(), False
    for i, fr in enumerate(frames):
        canvas = Image.new("RGBA", art.size)
        canvas.paste(fr, (dx, dy))
        b = canvas.getbbox()
        feet.add(b[3])
        edge |= b[0] == 0 or b[1] == 0 or b[2] == art.width or b[3] == art.height
        canvas.save(out / f"{'back_' if back else ''}f{i}.png")
    print(f"{file}: sheet frame {side}, art {art.size[0]}, shift ({dx},{dy}), feet rows {sorted(feet)}, touches edge {edge}")
