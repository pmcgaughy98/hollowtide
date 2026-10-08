"""Back-view idle that moves in step with the front idle (Claude, 2026-10-06).

  python tools/unity_port/matched_back_idle.py <front_idle_dir> <back.png> <out_dir> [tail_side]

The front idle's 8 frames are measured: how far the top of the body and each side sink
on every frame, with the feet planted. The back view is then bent the same way, frame for
frame: feet fixed, the body sinking by the front's amount (the head side by the head
side's amount), and the tail end swaying a little on the same beat. Every frame is built
by picking whole art pixels from the back sprite (no blending), so the pixel art stays
crisp. Writes back_f0..back_f7.png on the back sprite's canvas, so frame i of the back
plays with frame i of the front at the same idle period.

tail_side is "left" (default) or "right": which side of the back view holds the tail.
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

LEGS = 0.18      # lowest share of the body that stays still (legs and feet)
TAIL_SWAY = 2.0  # art pixels the tail tip sways either way


def measure(front_dir: Path):
    """Per frame: how far the top, left third and right third sink, in art pixels."""
    tops, lefts, rights = [], [], []
    for i in range(8):
        a = np.array(Image.open(front_dir / f"f{i}.png").convert("RGBA"))[:, :, 3] > 0
        ys, _ = np.nonzero(a)
        w = a.shape[1]
        tops.append(ys.min())
        lefts.append(np.nonzero(a[:, : w // 3])[0].mean())
        rights.append(np.nonzero(a[:, 2 * w // 3:])[0].mean())
    tops, lefts, rights = (np.array(v, float) for v in (tops, lefts, rights))
    sink = tops - tops.min()
    # Each side's sink as a share of the top's, so the back keeps the same tilt.
    span = max(1.0, sink.max())
    left_share = (lefts.max() - lefts.min()) / span
    right_share = (rights.max() - rights.min()) / span
    return sink, left_share, right_share


def bend(back: np.ndarray, sink: float, left_share: float, right_share: float, sway: float, tail_left: bool):
    h, w, _ = back.shape
    alpha = back[:, :, 3] > 0
    ys, xs = np.nonzero(alpha)
    top, feet, x0, x1 = ys.min(), ys.max(), xs.min(), xs.max()
    legs_top = feet - LEGS * (feet - top)
    out = np.zeros_like(back)
    for y in range(h):
        for x in range(w):
            k = (x - x0) / max(1, x1 - x0)                   # 0 at the left edge, 1 at the right
            share = left_share + (right_share - left_share) * k
            s = sink * max(share, 0.5)                       # this column's sink at the very top
            src_y = float(y)
            if y < legs_top and s > 0:
                # Rows above the legs: the top comes down s pixels, the legs' top line stays.
                body = legs_top - top
                src_y = legs_top - (legs_top - y) * body / max(1.0, body - s)
            # The tail end (outer third on the tail side, lower half) sways on the beat.
            t = (1 - k) if tail_left else k
            src_x = float(x)
            if t > 0.66 and y > (top + feet) / 2:
                src_x = x - sway * (t - 0.66) / 0.34
            sx, sy = int(round(src_x)), int(round(src_y))
            if 0 <= sx < w and 0 <= sy < h and sy >= top - 1:
                out[y, x] = back[sy, sx]
    return out


def main():
    front_dir, back_png, out = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
    tail_left = (sys.argv[4] if len(sys.argv) > 4 else "left") == "left"
    sink, ls, rs = measure(front_dir)
    back = np.array(Image.open(back_png).convert("RGBA"))
    out.mkdir(parents=True, exist_ok=True)
    for i in range(8):
        sway = TAIL_SWAY * np.sin(2 * np.pi * i / 8)
        Image.fromarray(bend(back, sink[i], ls, rs, sway, tail_left)).save(out / f"back_f{i}.png")
    print("sink per frame", sink.tolist(), "left share %.2f right share %.2f" % (ls, rs))


if __name__ == "__main__":
    main()
