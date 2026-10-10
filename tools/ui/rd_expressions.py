"""Expression portraits (Claude, 2026-10-10; Preston: "make specialized portraits like these from the actual
mystery dungeon game... the different expression ones too for the dialogue").

Structure from Explorers of Sky: one bust per creature, the same framing and facing for every
expression, a fixed set of faces. Nothing of theirs is used: each expression is a Retro Diffusion
image_edit ($0.18) of the creature's own portrait crop (the detailed idle, tools/ui/build_dialogue_portraits.py),
told to change only the face. The result is shrunk to 40x40 and every pixel snapped to the colours of the
creature's own portrait, so the palette cannot drift; the cream background is cleared from the edges in.
  python tools/ui/rd_expressions.py <form> <expression> [...]
Writes assets/sprites/ui/dialogue/<form>_<expression>.png and docs/ui/expressions-2026-10-10/.
"""
import sys
from collections import deque
from pathlib import Path
import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "debug"))
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "arena"))
sys.path.insert(0, str(Path(__file__).resolve().parent))
import rd_creature                                   # noqa: E402  (its edit())
from downscale import resample                       # noqa: E402
from build_dialogue_portraits import SOURCES, SIZE   # noqa: E402

WORK = Path("docs/ui/expressions-2026-10-10")
OUT = Path("assets/sprites/ui/dialogue")
BG = (239, 230, 210, 255)   # the portrait well's parchment
UP = 3
FACES = {   # what changes; everything else must stay
    "happy": "a warm closed-mouth smile, eyes bright and open",
    "joyous": "eyes squeezed shut in happy upward arcs, mouth wide open in a big laugh",
    "surprised": "eyes wide open with small pupils, mouth open in a small round gasp",
    "angry": "eyes narrowed under a hard frown, teeth bared in a snarl",
    "sad": "eyes downcast and half closed, brows tilted up, a small frown",
    "worried": "brows raised and tilted together, eyes looking aside, mouth a nervous wavy line",
    "determined": "eyes set and focused, brows lowered, mouth firm and set",
    "mischievous": "a sly, mean, scheming grin, one corner of the mouth curled up, eyes half lidded and narrowed, brows angled down in mischief",
}


def base(form: str) -> Path:
    src, box = SOURCES[form]
    cut = Image.open(src).convert("RGBA").crop(box)
    side = max(cut.size)
    sq = Image.new("RGBA", (side, side), BG)
    sq.alpha_composite(cut, ((side - cut.width) // 2, (side - cut.height) // 2))
    up = max(1, min(UP, 256 // side))   # the edit tool takes 256 px at most
    big = sq.resize((side * up, side * up), Image.NEAREST)
    WORK.mkdir(parents=True, exist_ok=True)
    p = WORK / f"{form}_base.png"
    big.save(p)
    return p


def palette_of(form: str) -> np.ndarray:
    a = np.array(Image.open(OUT / f"{form}.png").convert("RGBA"))
    return np.unique(a[a[..., 3] > 0][:, :3], axis=0).astype(int)


def clear_bg(a: np.ndarray) -> np.ndarray:
    """Clear background-coloured pixels joined to the edge."""
    h, w = a.shape[:2]
    near = (np.abs(a[..., :3].astype(int) - np.array(BG[:3])).sum(2) < 40)
    seen = np.zeros((h, w), bool)
    q = deque([(y, x) for y in range(h) for x in (0, w - 1)] + [(y, x) for x in range(w) for y in (0, h - 1)])
    while q:
        y, x = q.popleft()
        if 0 <= y < h and 0 <= x < w and not seen[y, x] and near[y, x]:
            seen[y, x] = True
            q.extend([(y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)])
    a[seen, 3] = 0
    # Peel the cream fringe the edit leaves: background-coloured pixels touching the cleared outside.
    for _ in range(2):
        out = a[..., 3] == 0
        touch = np.zeros_like(out)
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            touch |= np.roll(np.roll(out, dy, 0), dx, 1)
        cream = (np.abs(a[..., :3].astype(int) - np.array(BG[:3])).sum(2) < 60) & (a[..., 3] > 0)
        a[cream & touch, 3] = 0
    return a


def finish(form: str, edited: Path, face: str) -> Path:
    im = Image.open(edited).convert("RGBA")
    small = resample(im, im.width / SIZE).resize((SIZE, SIZE), Image.NEAREST)
    a = np.array(small).astype(int)
    pal = np.vstack([palette_of(form), np.array([BG[:3]])])
    flat = a[..., :3].reshape(-1, 3)
    idx = ((flat[:, None, :] - pal[None, :, :]) ** 2).sum(2).argmin(1)
    a[..., :3] = pal[idx].reshape(a.shape[:2] + (3,))
    a[..., 3] = 255
    a = clear_bg(a.astype(np.uint8))
    out = OUT / f"{form}_{face}.png"
    Image.fromarray(a).save(out)
    return out


if __name__ == "__main__":
    form, faces = sys.argv[1], sys.argv[2:]
    b = base(form)
    for face in faces:
        edited = WORK / f"{form}_{face}_edit.png"
        if not edited.exists():   # never pay twice for the same face
            rd_creature.edit(str(b), str(edited), f"The same creature, same pose, same colours, same pixel art style and dark outline, same cream background; change only its facial expression to: {FACES[face]}.")
        print("portrait", finish(form, edited, face))
    # A review sheet: the base portrait, then each face, at 3x.
    names = [form] + [f"{form}_{f}" for f in faces]
    sheet = Image.new("RGBA", (len(names) * 132, 132), BG)
    for k, n in enumerate(names):
        sheet.alpha_composite(Image.open(OUT / f"{n}.png").convert("RGBA").resize((120, 120), Image.NEAREST), (k * 132 + 6, 6))
    sheet.save(WORK / f"{form}_sheet.png")
