"""Cut Preston's three Ironvent Furnace Roar Opal sheets into single frames.

Preston (2026-09-28): build Furnace Roar from these sheets by the attack-sheet
protocol. Layouts, read by eye:
  sheet 1  3x3 grid with white cell lines: idle, then the roar building
  sheet 2  three idles on top, and one big close-up of the roar below it
  sheet 3  three idles, three roar frames (fire bursting, closing), and a strip
           of lower body only along the bottom (head and torso hidden by the
           row above), which is left out: it cannot stand on its own
Regular frames convert at their own block so the body matches the in-game
Ironvent's height (same measure as tools/cut_vitrecrag_cannon_sheets.py). The
big close-up keeps its own drawn pixel grid (it is meant to be shown large, as
a cut-in), so it is converted with the detected block.

Originals stay untouched in OneDrive. Writes
assets/sprites/creatures/attacks/ironvent_furnace_roar/frames/<sheet>_fNN.png
and closeup.png.
Run from the project root: python tools/cut_ironvent_furnace_roar_sheets.py
"""
import sys
import tempfile
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import convert_forge_sprite  # noqa: E402
from cut_vitrecrag_cannon_sheets import body_height, grid, opaque_height  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
SRC = Path.home() / "OneDrive/Documents/HollowTide Sprites/Effect Sheets/IronVent Effect"
OUT = ROOT / "assets/sprites/creatures/attacks/ironvent_furnace_roar/frames"
OFFICIAL = ROOT / "assets/sprites/creatures/ironvent.png"
INSET = 8

SHEETS = {
    "roar1": ("Furance roar sheet 1.jfif", grid(3, 3)),
    "roar2": ("Furnace roar sheet  2.jfif", grid(3, 1, 0, 300)),
    "roar3": ("Furnace roar 3.jfif", grid(3, 1, 0, 400) + grid(3, 1, 430, 690)),
}
CLOSEUP = ("Furnace roar sheet  2.jfif", (0, 300, 1024, 1024))

# One block per sheet row, because every frame in a row is drawn at the same
# scale. Matching each frame's height on its own shrank the rearing roar poses
# (a raised head makes the pose taller). Taken from each row's idle frames;
# sheet 3's second row has no idle and is drawn smaller, so it is set by eye
# against the sheet and checked on the board.
ROW_BLOCK = {
    "roar1": [3.62] * 9,
    "roar3": [3.66] * 3 + [3.3] * 3,
}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for old in OUT.glob("*.png"):
        old.unlink()
    target = opaque_height(Image.open(OFFICIAL).convert("RGBA"))
    print("in-game body height", target)
    with tempfile.TemporaryDirectory() as tmp:
        for name, (rel, cells) in SHEETS.items():
            sheet = Image.open(SRC / rel).convert("RGB")
            for n, (x0, y0, x1, y1) in enumerate(cells):
                cell = sheet.crop((int(x0) + INSET, int(y0) + INSET, int(x1) - INSET, int(y1) - INSET))
                h = body_height(cell)
                if h < 40:
                    print(f"{name} cell {n}: empty, skipped")
                    continue
                block = h / target
                src = Path(tmp) / f"{name}_{n}.png"
                dst = Path(tmp) / f"{name}_{n}_out.png"
                cell.save(src)
                if name in ROW_BLOCK:
                    block = ROW_BLOCK[name][n]
                    convert_forge_sprite.convert(str(src), str(dst), block=block)
                    img = Image.open(dst).convert("RGBA")
                else:
                    for _ in range(2):  # a second pass at the exact scale if needed
                        convert_forge_sprite.convert(str(src), str(dst), block=block)
                        img = Image.open(dst).convert("RGBA")
                        tall = opaque_height(img)
                        if abs(tall - target) <= 1:
                            break
                        block *= tall / target
                box = img.getbbox()
                img.crop(box).save(OUT / f"{name}_f{n:02d}.png")
                print(f"{name}_f{n:02d}: block {block:.2f} -> {box[2] - box[0]}x{box[3] - box[1]}")
        rel, box = CLOSEUP
        cell = Image.open(SRC / rel).convert("RGB").crop(box)
        src = Path(tmp) / "closeup.png"
        cell.save(src)
        convert_forge_sprite.convert(str(src), str(OUT / "closeup.png"))
        img = Image.open(OUT / "closeup.png").convert("RGBA")
        img.crop(img.getbbox()).save(OUT / "closeup.png")
        print("closeup:", img.getbbox())


if __name__ == "__main__":
    main()
