"""Cut the RD effect sheets into arena frames (Claude, 2026-10-07).
  python tools/arena/slice_vfx.py
Each docs/.../vfx/<name>_sheet.png is a 4 x 4 grid of 16 frames at 64 px. Every frame is
shrunk to half (tools/arena/downscale.py, crisp) so an impact is about the size of a creature,
and saved as assets/sprites/arena/vfx/<name>/f00..f15.png."""
import sys
from pathlib import Path
from PIL import Image
sys.path.insert(0, str(Path(__file__).parent))
from downscale import shrink  # noqa: E402

SRC = Path("docs/creatures/arena-starters-2026-10-07/vfx")
OUT = Path("assets/sprites/arena/vfx")
for sheet in sorted(SRC.glob("*_sheet.png")):
    name = sheet.name[:-len("_sheet.png")]
    im = Image.open(sheet).convert("RGBA")
    cw = im.width // 4
    (OUT / name).mkdir(parents=True, exist_ok=True)
    for i in range(16):
        r, c = divmod(i, 4)
        shrink(im.crop((c * cw, r * cw, (c + 1) * cw, (r + 1) * cw)), 2).save(OUT / name / f"f{i:02d}.png")
    print(name, "16 frames at", cw // 2)
