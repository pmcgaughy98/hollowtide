"""Back-view frames for Vitrecrag's Molten Glass: the furnace window and hot
seams brighten through the brace and pour, like the front view's shell glow.

From behind, the head is hidden on the far side of the shell, so the body art
itself does not change; battle draws the glass coming up from behind the
shell's front edge. Only glowing pixels (strong orange) are touched, so the
silhouette and legs match the approved rear exactly.

Writes .../vitrecrag_lava_pour/back/glow_1..3.png. Run from the project root:
  python tools/build_vitrecrag_back_pour.py
"""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
REAR = ROOT / "assets/sprites/creatures/vitrecrag_rear_2026_09_27.png"
OUT = ROOT / "assets/sprites/creatures/attacks/vitrecrag_lava_pour/back"
HOT_GOLD = (252, 200, 112)  # the glass's hot pale-gold core
# How far each glowing pixel moves toward hot gold, per level.
LEVELS = {1: 0.25, 2: 0.5, 3: 0.75}


def is_glow(r, g, b):
    return r > 200 and g > 70 and r > b + 90


def main():
    rear = Image.open(REAR).convert("RGBA")
    OUT.mkdir(parents=True, exist_ok=True)
    for level, share in LEVELS.items():
        img = rear.copy()
        p = img.load()
        changed = 0
        for y in range(img.height):
            for x in range(img.width):
                r, g, b, a = p[x, y]
                if a and is_glow(r, g, b):
                    p[x, y] = tuple(int(c + (h - c) * share) for c, h in zip((r, g, b), HOT_GOLD)) + (a,)
                    changed += 1
        img.save(OUT / f"glow_{level}.png")
        print(f"glow_{level}: {changed} glowing pixels brightened")


if __name__ == "__main__":
    main()
