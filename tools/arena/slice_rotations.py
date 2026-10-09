"""Cut the arena starters' 3x3 Retro Diffusion rotation sheets into one PNG per facing
(Claude, 2026-10-07).  python tools/arena/slice_rotations.py
Which cell faces which way was read by eye from each sheet (RD does not label them);
"mirror:X" means the facing is drawn by flipping X, used where a sheet has no clean frame.
Writes assets/sprites/arena/<creature>/<s|se|e|ne|n|nw|w|sw>.png, trimmed to a shared box.
  python tools/arena/slice_rotations.py [name ...]   only those creatures. Name them: a bare run
  reslices all of them and overwrites Codex's colour-fixed facings."""
import sys
from pathlib import Path
from PIL import Image, ImageOps

SRC = Path("docs/creatures/arena-starters-2026-10-07")
OUT = Path("assets/sprites/arena")
SHARED = {"s": (0, 0), "sw": (0, 1), "w": (0, 2), "se": (1, 0), "ne": (2, 0), "n": (2, 1), "nw": (2, 2), "e": "mirror:w"}
TALLOW = {"s": (0, 2), "se": (0, 1), "e": (0, 0), "ne": (1, 0), "n": (2, 0), "nw": (2, 1), "w": (2, 2), "sw": (1, 2)}
CELLS = {
    "kithflare": SHARED,
    "rimefin": SHARED,
    "tallowroot": TALLOW,
    # Stage 2 and 3 forms (2026-10-07), sheets in SRC/forms/.
    "sparkwick": SHARED,
    "stormwick": TALLOW,
    "huskward": TALLOW,
    "rampartroot": TALLOW,
    "riftfin": TALLOW,   # remade 2026-10-09 (the ambusher); the old blade-fin sheet is riftfin_bladefin_rotation_3x3.png
    "scourmaw": TALLOW,   # remade 2026-10-09 (epic take 1); the serpent sheet is scourmaw_serpent_rotation_3x3.png
    # The Ironvent line (2026-10-07): all three sheets came back in Tallowroot's layout.
    "cinderhide": TALLOW,
    "clinkerhide": TALLOW,
    "ironvent": TALLOW,
    # The Vitrecrag line (2026-10-07): Tallowroot's layout again.
    "fusern": TALLOW,
    "slagglass": TALLOW,
    "vitrecrag": TALLOW,
    # The Oxbowarchon line (2026-10-08): Tallowroot's layout again (read by eye: e at r0c0, s at r0c2, w at r2c2).
    "preostmar": TALLOW,
    "oathfen": TALLOW,
    "oxbowarchon": TALLOW,
    # The Punchybuns line (2026-10-08): Tallowroot's layout (e at r0c0, s at r0c2, w at r2c2).
    "punchybun": TALLOW,
    "sparkjab": TALLOW,
    "starward": TALLOW,
    # The River Listener line (2026-10-08): layout read by eye after the rotation.
    "listener": TALLOW,
    "caller": TALLOW,
    "warden": TALLOW,
    # The Canvaswing line (2026-10-08): layout read by eye after the rotation.
    "canvaswing": TALLOW,
    "windcut": TALLOW,
    "galeshear": TALLOW,
    # The Dustkite line (2026-10-09): layout read by eye after the rotation.
    "dustkite": TALLOW,
    "waywhistle": TALLOW,
    "highsignal": TALLOW,
}
FORMS = {"sparkwick", "stormwick", "huskward", "rampartroot", "riftfin", "scourmaw", "cinderhide", "clinkerhide", "ironvent", "fusern", "slagglass", "vitrecrag", "preostmar", "oathfen", "oxbowarchon", "punchybun", "sparkjab", "starward", "listener", "caller", "warden", "canvaswing", "windcut", "galeshear", "dustkite", "waywhistle", "highsignal"}

for name, cells in CELLS.items():
    if len(sys.argv) > 1 and name not in sys.argv[1:]:
        continue
    folder = SRC / "forms" if name in FORMS else SRC
    sheet = Image.open(folder / f"{name}_arena_rotation_3x3.png").convert("RGBA")
    cw = sheet.width // 3
    frames = {}
    for facing, cell in cells.items():
        if isinstance(cell, tuple):
            r, c = cell
            frames[facing] = sheet.crop((c * cw, r * cw, (c + 1) * cw, (r + 1) * cw))
    for facing, cell in cells.items():
        if isinstance(cell, str):
            frames[facing] = ImageOps.mirror(frames[cell.split(":")[1]])
    (OUT / name).mkdir(parents=True, exist_ok=True)
    for facing, im in frames.items():
        im.save(OUT / name / f"{facing}.png")
    print(name, cw, sorted(frames))
