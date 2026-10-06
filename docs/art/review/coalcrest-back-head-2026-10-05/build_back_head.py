import sys
from PIL import Image
BACK = "assets/sprites/creatures/kithflare_line_rechecked_2026_10_04/coalcrest_back_occluded_leg_v3.png"
FRONT = "assets/sprites/creatures/coalcrest_rechecked_2026_10_04/coalcrest_front.png"
def build(dx, dy):
    back = Image.open(BACK).convert("RGBA")
    front = Image.open(FRONT).convert("RGBA")
    bp = back.load()
    # Clear the flat-cut neck top so no ledge shows beside the head.
    for y in range(26, 32):
        for x in range(89, 110):
            bp[x, y] = (0, 0, 0, 0)
    head = front.crop((100, 29, 131, 48))
    back.alpha_composite(head, (100 + dx, 29 + dy))
    return back
if __name__ == "__main__":
    S = sys.argv[1]
    for name, (dx, dy) in {"a": (-8, -8), "b": (-10, -6)}.items():
        build(dx, dy).save(f"{S}/coal_back_{name}.png")

def clean(img):
    """Candidate B touch-up: remove the sail-edge nub behind the skull and the
    stray stripe speck the front crop carried onto the neck."""
    p = img.load()
    for y in range(20, 26):
        for x in range(88, 96):
            p[x, y] = (0, 0, 0, 0)
    for x in range(89, 96):
        if p[x, 26][3] > 0:
            p[x, 26] = (0, 0, 0, 255)
    fill = p[93, 38]
    for y in range(36, 41):
        for x in range(88, 93):
            r, g, b, a = p[x, y]
            if a > 0 and r > 200 and g > 140:
                p[x, y] = fill
    return img
