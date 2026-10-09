"""Arena-size sprites for the starters (Claude, 2026-10-07).
  python tools/arena/build_small.py
Shrinks every facing still and walk frame to a third (tools/arena/downscale.py), so a
creature's pixels match the arena maps' (both shown at 3x). Walk cycles were generated for
five facings per creature; the other three are mirrored. Explicit mirrored stills
are flipped after shrinking so discarded canvas remainders cannot break symmetry. Writes
assets/sprites/arena/<name>/small/<facing>.png and .../small/walk_<facing>_f0..f7.png."""
import sys
from pathlib import Path
from PIL import Image, ImageOps

sys.path.insert(0, str(Path(__file__).parent))
from downscale import resample, shrink  # noqa: E402

ART = Path("assets/sprites/arena")
WALK = Path("docs/creatures/arena-starters-2026-10-07/walk")
FACINGS = ["s", "se", "e", "ne", "n", "nw", "w", "sw"]
MIRROR = {"e": "w", "se": "sw", "ne": "nw", "w": "e", "sw": "se", "nw": "ne"}
# These five assignments match slice_rotations.CELLS; importing that script reslices art.
STILL_MIRRORS = {
    "kithflare": {"e": "w"}, "rimefin": {"e": "w"},
    "sparkwick": {"e": "w"}, "riftfin": {"nw": "ne"},
    "scourmaw": {"sw": "se"},
}


def walk_frames(name, facing):
    sheet = WALK / f"{name}_{facing}_sheet.png"
    if not sheet.exists():
        return None
    im = Image.open(sheet).convert("RGBA")
    cw = im.height // 2  # 4 x 2 grid of 8 frames
    return [im.crop((c * cw, r * cw, (c + 1) * cw, (r + 1) * cw)) for r in range(2) for c in range(4)]


# Size against the rest of the roster (Preston, 2026-10-08: "the ferret is way bigger than
# Ironvent and Rampartroot; Vitrecrag is a little smaller than I'd like; they are big boi
# creatures"). 1.0 is the plain third (shrink); anything else resamples by 3/scale with the
# source palette locked. Finals of the heavy lines stand about 42 to 44 px tall, the
# guardian ferret about 34.
SCALE = {
    "clinkerhide": 1.1, "ironvent": 1.15,
    "huskward": 1.1, "rampartroot": 1.15,
    "slagglass": 1.15, "vitrecrag": 1.2,
    "oathfen": 1.05, "oxbowarchon": 1.1,
    "punchybun": 0.9, "sparkjab": 0.85, "starward": 0.8,
    "listener": 0.95, "caller": 1.0, "warden": 1.1,
    "canvaswing": 0.95, "windcut": 1.0, "galeshear": 1.1,
}


def small_of(im, name):
    k = SCALE.get(name, 1.0)
    return shrink(im, 3) if k == 1.0 else resample(im, 3.0 / k)


NAMES = ("kithflare", "tallowroot", "rimefin", "sparkwick", "stormwick", "huskward", "rampartroot", "riftfin", "scourmaw",
         "cinderhide", "clinkerhide", "ironvent", "fusern", "slagglass", "vitrecrag",
         "preostmar", "oathfen", "oxbowarchon", "punchybun", "sparkjab", "starward", "listener", "caller", "warden", "canvaswing", "windcut", "galeshear")
# Pass names to rebuild only those creatures (a bare run redoes all of them).
for name in (sys.argv[1:] or NAMES):
    out = ART / name / "small"
    out.mkdir(parents=True, exist_ok=True)
    for f in FACINGS:
        small_of(Image.open(ART / name / f"{f}.png"), name).save(out / f"{f}.png")
    for facing, source in STILL_MIRRORS.get(name, {}).items():
        ImageOps.mirror(Image.open(out / f"{source}.png").convert("RGBA")).save(out / f"{facing}.png")
    made = []
    for f in FACINGS:
        frames = walk_frames(name, f)
        flip = False
        if frames is None and f in MIRROR:
            frames, flip = walk_frames(name, MIRROR[f]), True
        if frames is None:
            continue
        for i, fr in enumerate(frames):
            cell = Image.open(ART / name / f"{f}.png").size
            if fr.size != cell:
                fr = fr.resize(cell, Image.NEAREST)
            small = small_of(fr, name)
            (ImageOps.mirror(small) if flip else small).save(out / f"walk_{f}_f{i}.png")
        made.append(f + ("(mirrored)" if flip else ""))
    print(name, "walks:", ", ".join(made) or "none yet")
