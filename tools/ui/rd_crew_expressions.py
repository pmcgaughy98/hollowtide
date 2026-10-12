"""Expression portraits for the six Hall crew (Claude, 2026-10-12; Preston: spend the rest of the Retro balance
where it moves the pitch, so their conversations stop falling back to one flat face).

The same method as tools/ui/rd_expressions.py (the starters' faces), with one difference: the crew's portraits were
cut by Codex from Preston's chosen fronts (tools/ui/build_crew_dialogue_portraits.py), so each base is Codex's exact
crop (docs/ui/crew-portraits-2026-10-11/evidence/crop/<form>.png) on the parchment well, not a detailed idle. One
Retro Diffusion image_edit ($0.18) per face, told to change only the expression; the result is shrunk to 40 px,
every pixel snapped to the crew member's own portrait colours, and the cream cleared from the edges in. A result
whose silhouette drifts from the plain portrait (alpha overlap under 0.8) or that comes back mostly pale (a white
block) is kept in the work folder and not installed, so a bad edit never reaches the game.
  python tools/ui/rd_crew_expressions.py <form> <face> [...]      (run from the project root, one crew member at a time)
Writes assets/sprites/ui/dialogue/<form>_<face>.png and docs/ui/crew-expressions-2026-10-12/.
"""
import sys
from pathlib import Path
import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "debug"))
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "arena"))
sys.path.insert(0, str(Path(__file__).resolve().parent))
import rd_creature                                   # noqa: E402  (its edit())
import rd_expressions as x                           # noqa: E402  (FACES, finish(), BG, UP, OUT)

WORK = Path("docs/ui/crew-expressions-2026-10-12")
CROPS = Path("docs/ui/crew-portraits-2026-10-11/evidence/crop")
CREW = ("grubbit", "stillwade", "wickglow", "muskin", "slipjaw", "rinsepaw")


def base(form: str) -> Path:
    cut = Image.open(CROPS / f"{form}.png").convert("RGBA")
    side = max(cut.size)
    sq = Image.new("RGBA", (side, side), x.BG)
    sq.alpha_composite(cut, ((side - cut.width) // 2, (side - cut.height) // 2))
    up = max(1, min(x.UP, 256 // side))   # the edit tool takes 256 px at most
    big = sq.resize((side * up, side * up), Image.NEAREST)
    WORK.mkdir(parents=True, exist_ok=True)
    p = WORK / f"{form}_base.png"
    big.save(p)
    return p


def pale_share(p: Path) -> float:
    """How much of the edit came back near white or pale grey (the debris that spoils a take)."""
    a = np.array(Image.open(p).convert("RGB")).astype(int)
    pale = (a.min(2) > 200) & (a.max(2) - a.min(2) < 25)
    return float(pale.mean())


def overlap(form: str, face: str) -> float:
    plain = np.array(Image.open(x.OUT / f"{form}.png").convert("RGBA"))[..., 3] > 0
    new = np.array(Image.open(x.OUT / f"{form}_{face}.png").convert("RGBA"))[..., 3] > 0
    return float((plain & new).sum() / max(1, (plain | new).sum()))


if __name__ == "__main__":
    form, faces = sys.argv[1], sys.argv[2:]
    assert form in CREW, form
    b = base(form)
    kept = []
    for face in faces:
        edited = WORK / f"{form}_{face}_edit.png"
        if not edited.exists():   # never pay twice for the same face
            rd_creature.edit(str(b), str(edited), "The same creature, same pose, same colours, same pixel art style and dark outline, same cream background; change only its facial expression to: %s." % x.FACES[face])
        pale = pale_share(edited)
        out = x.finish(form, edited, face)
        iou = overlap(form, face)
        ok = pale < 0.6 and iou >= 0.8
        print("%s %s: pale %.2f, silhouette overlap %.2f -> %s" % (form, face, pale, iou, "installed" if ok else "REJECTED (kept in the work folder)"))
        if ok:
            kept.append(face)
        else:
            out.rename(WORK / f"{form}_{face}_rejected.png")
    names = [form] + [f"{form}_{f}" for f in kept]
    sheet = Image.new("RGBA", (len(names) * 132, 132), x.BG)
    for k, n in enumerate(names):
        sheet.alpha_composite(Image.open(x.OUT / f"{n}.png").convert("RGBA").resize((120, 120), Image.NEAREST), (k * 132 + 6, 6))
    sheet.save(WORK / f"{form}_sheet.png")
    print("sheet", WORK / f"{form}_sheet.png")
