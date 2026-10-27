"""One review picture per art batch, for Preston (Claude, 2026-10-26, placeholder factory task-list lane;
03-spec-format.md section 4.5).

    python tools/art/review_sheet.py <batch_id> [--candidates <folder>] [--out <png>]
    python tools/art/review_sheet.py <batch_id> --record <slot_id>=yes|redo|keep [--why "<one line>"]

The sheet has one row per slot of the batch: the placeholder (the reference target), the prepared candidate, the
in-game capture with the candidate swapped in (`capture.png` in the slot's candidate folder, 1152x648, shown at half
size), and the slot's check lines from `prepared.png.check.json`, with the answer recorded so far. Pictures are
enlarged with nearest sampling only. The sheet carries words because it is for Preston; it is never given to a
generator. It is written to docs/art/slot-candidates/<batch>/review_sheet.png, and the batch's review.json is
started with every slot "pending" when it does not exist yet.

--record writes one of Preston's answers into review.json (yes, redo with one line why, or keep the placeholder).
Use it only with an answer Preston gave in chat: install_slot.py installs a slot only when it reads his yes here.
The batch's slot list comes from tools/art/write_art_tasks.py, or, for a batch it does not name, from the slot
folders inside the batch folder.
"""
import argparse
import datetime
import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
import slot_registry as reg  # noqa: E402
import write_art_tasks as tasks  # noqa: E402

CANDIDATES = reg.ROOT / "docs" / "art" / "slot-candidates"
REFS = reg.DOC / "refs"
ANSWERS = ("yes", "redo", "keep")
BACK = (28, 31, 28)
PANEL = (36, 43, 37)
INK = (255, 244, 232)
DIM = (150, 150, 140)
COLOURS = {"PASS": (120, 200, 120), "WARN": (232, 196, 90), "FAIL": (232, 96, 80)}
CELL = 216            # height the placeholder and candidate are enlarged into
CAP = (576, 324)      # the 1152x648 capture at half size
TEXT_W = 520
PAD = 12


def batch_slots(batch_id: str, folder: Path) -> list:
    for b in tasks.CODEX_BATCHES + tasks.GROK_BATCHES:
        if b["id"] == batch_id:
            return list(b["slots"])
    return sorted(p.name for p in folder.iterdir() if p.is_dir()) if folder.is_dir() else []


def font(size: int):
    try:
        return ImageFont.load_default(size=size)
    except TypeError:   # an older Pillow has one fixed size
        return ImageFont.load_default()


def fit(img: Image.Image, box_h: int, box_w: int) -> Image.Image:
    """Nearest-neighbour: a whole factor up to fit the box, or straight down to it."""
    k = min(box_h / img.height, box_w / img.width)
    k = max(1, int(k)) if k >= 1 else k
    return img.resize((max(1, round(img.width * k)), max(1, round(img.height * k))), Image.NEAREST)


def checker(w: int, h: int) -> Image.Image:
    """A dark checkerboard behind transparent pixels, so a cut-out reads as one."""
    img = Image.new("RGBA", (w, h), (52, 56, 58, 255))
    d = ImageDraw.Draw(img)
    for y in range(0, h, 8):
        for x in range((y // 8) % 2 * 8, w, 16):
            d.rectangle([x, y, x + 7, y + 7], fill=(64, 68, 70, 255))
    return img


def tile(sheet: Image.Image, path: Path, x: int, y: int, box_w: int, box_h: int, label: str, d, f) -> None:
    d.text((x, y), label, fill=DIM, font=f)
    y += 18
    if not path.is_file():
        d.rectangle([x, y, x + box_w, y + box_h], outline=DIM)
        d.text((x + 8, y + 8), "missing:\n" + path.name, fill=DIM, font=f)
        return
    img = fit(Image.open(path).convert("RGBA"), box_h, box_w)
    back = checker(img.width, img.height)
    back.alpha_composite(img)
    sheet.paste(back, (x, y))


def check_lines(path: Path) -> list:
    if not path.is_file():
        return [("-", "no check yet: run validate_slot.py on prepared.png")]
    doc = json.loads(path.read_text(encoding="utf-8"))
    out = [(r["result"], f"{r['id']} {r['name']}: {r['detail']}"[:86]) for r in doc.get("results", [])]
    stale = doc.get("registry_sha256", "") != reg.registry_hash()
    if stale:
        out.insert(0, ("WARN", "checked against an older registry: run validate_slot.py again"))
    return out


def read_review(folder: Path) -> dict:
    p = folder / "review.json"
    return json.loads(p.read_text(encoding="utf-8")) if p.is_file() else {}


def write_review(folder: Path, doc: dict) -> None:
    folder.mkdir(parents=True, exist_ok=True)
    (folder / "review.json").write_text(json.dumps(doc, indent=1) + "\n", encoding="utf-8")


def answer_of(doc: dict, sid: str) -> str:
    a = doc.get("slots", {}).get(sid, "")
    return str(a.get("answer", "") if isinstance(a, dict) else a)


def sheet(batch_id: str, folder: Path, out: Path) -> int:
    ids = batch_slots(batch_id, folder)
    if not ids:
        print(f"review_sheet: no batch named {batch_id} and no slot folders in {folder}")
        return 2
    slots = reg.load()["slots"]
    review = read_review(folder)
    if not review:
        review = {"batch": batch_id, "note": "Preston's answers: yes, redo (one line why) or keep the placeholder. "
                  "install_slot.py installs only a yes.", "slots": {sid: {"answer": "pending"} for sid in ids}}
        write_review(folder, review)
    f, fb = font(13), font(18)
    col_w = 2 * (CELL + PAD) + CAP[0] + PAD + TEXT_W
    row_h = max(CELL, CAP[1]) + 18 + 2 * PAD + 26
    img = Image.new("RGBA", (col_w + 2 * PAD, 48 + row_h * len(ids)), BACK + (255,))
    d = ImageDraw.Draw(img)
    d.text((PAD, 12), f"Review sheet: {batch_id}  ({len(ids)} slots; answer yes, redo or keep for each)",
           fill=INK, font=fb)
    for n, sid in enumerate(ids):
        y = 48 + n * row_h
        d.rectangle([PAD // 2, y, col_w + PAD + PAD // 2, y + row_h - 6], fill=PANEL)
        s = slots.get(sid, {})
        size = "x".join(str(v) for v in s.get("size", [])) or "?"
        d.text((PAD, y + 6), f"{n + 1}. {sid}  ({s.get('kind', '?')}, {size}, {s.get('owner', '?')})",
               fill=INK, font=fb)
        top = y + 32
        cand = folder / sid
        x = PAD
        tile(img, REFS / f"{sid}.png", x, top, CELL, CELL, "placeholder (target)", d, f)
        x += CELL + PAD
        tile(img, cand / "prepared.png", x, top, CELL, CELL, "candidate (prepared)", d, f)
        x += CELL + PAD
        tile(img, cand / "capture.png", x, top, CAP[0], CAP[1], "in the game (capture.png, half size)", d, f)
        x += CAP[0] + PAD
        said = answer_of(review, sid) or "pending"
        d.text((x, top), f"Answer: {said}", fill=INK, font=fb)
        ty = top + 26
        for res, line in check_lines(cand / "prepared.png.check.json"):
            d.text((x, ty), f"{res:4s} {line}", fill=COLOURS.get(res, DIM), font=f)
            ty += 16
            if ty > y + row_h - 24:
                break
    out.parent.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(out)
    print(f"review_sheet: {len(ids)} rows -> {out}")
    return 0


def record(batch_id: str, folder: Path, entry: str, why: str) -> int:
    sid, _, said = entry.partition("=")
    said = said.strip().lower()
    if said not in ANSWERS:
        print(f"refused: the answer must be one of {', '.join(ANSWERS)}")
        return 2
    if said == "redo" and not why:
        print("refused: a redo needs Preston's one line why (--why)")
        return 2
    ids = batch_slots(batch_id, folder)
    if sid not in ids:
        print(f"refused: {sid} is not in batch {batch_id}")
        return 2
    doc = read_review(folder) or {"batch": batch_id, "slots": {}}
    row = {"answer": said, "date": datetime.date.today().isoformat()}
    if why:
        row["why"] = why
    doc.setdefault("slots", {})[sid] = row
    write_review(folder, doc)
    print(f"review_sheet: {batch_id} {sid} = {said}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description="Make a batch's review sheet, or record one of Preston's answers.")
    ap.add_argument("batch")
    ap.add_argument("--candidates", default=str(CANDIDATES), help="the slot-candidates folder")
    ap.add_argument("--out", default="", help="default: <batch folder>/review_sheet.png")
    ap.add_argument("--record", default="", metavar="SLOT=ANSWER")
    ap.add_argument("--why", default="")
    a = ap.parse_args()
    folder = Path(a.candidates) / a.batch
    try:
        if a.record:
            return record(a.batch, folder, a.record, a.why)
        return sheet(a.batch, folder, Path(a.out) if a.out else folder / "review_sheet.png")
    except reg.StaleRegistry as e:
        print(f"refused: {e}")
        return 2


if __name__ == "__main__":
    sys.exit(main())
