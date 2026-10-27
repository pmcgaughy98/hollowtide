"""Prepares a raw generation into a slot candidate (Claude, 2026-10-26, placeholder factory contract;
03-spec-format.md section 3.4).

    python tools/art/prepare_slot.py <slot_id> <raw.png> <out.png>

Keys the flat magenta background conservatively (only pixels within 60 RGB of #FF00FF), crops to the content,
box-downscales it to fit the slot (one cell at a time for a sheet), hardens alpha to 0 or 255, snaps every colour to
the slot's palette strip with no dithering (or, with no strip yet, cuts the picture's own colours to the budget by
median cut), and places the content so its lowest row sits on the slot's foot row, clear of the edges the slot may
not touch. Backdrops, rooms and ground (opaque slots) are centre-cropped to the slot's aspect instead and keep no
transparency. It does not repaint, sharpen or re-outline: Preston's 2026-10-13 call was that heavy finishing made
generated art worse. Then run tools/art/validate_slot.py on the result.
"""
import argparse
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import slot_registry as reg  # noqa: E402

MAGENTA = np.array([255, 0, 255])
KEY_DISTANCE = 60


def key_magenta(img: Image.Image) -> Image.Image:
    a = np.asarray(img.convert("RGBA")).copy()
    d = np.sqrt(((a[..., :3].astype(int) - MAGENTA) ** 2).sum(-1))
    a[d < KEY_DISTANCE, 3] = 0
    return Image.fromarray(a, "RGBA")


def harden(img: Image.Image) -> Image.Image:
    a = np.asarray(img).copy()
    a[..., 3] = np.where(a[..., 3] >= 128, 255, 0)
    a[a[..., 3] == 0, :3] = 0
    return Image.fromarray(a, "RGBA")


def shrink(img: Image.Image, w: int, h: int) -> Image.Image:
    """Box filter on premultiplied colour, so keyed pixels do not bleed magenta into the edges."""
    return img.convert("RGBa").resize((max(1, w), max(1, h)), Image.BOX).convert("RGBA")


def fit_cell(raw: Image.Image, s: dict) -> Image.Image:
    cw, ch = s["size"]
    if s["alpha"] == "opaque":
        rw, rh = raw.size
        want = cw / ch
        if rw / rh > want:
            nw = int(round(rh * want))
            raw = raw.crop(((rw - nw) // 2, 0, (rw - nw) // 2 + nw, rh))
        else:
            nh = int(round(rw / want))
            raw = raw.crop((0, (rh - nh) // 2, rw, (rh - nh) // 2 + nh))
        out = raw.convert("RGB").resize((cw, ch), Image.BOX).convert("RGBA")
        return out
    keyed = key_magenta(raw)
    box = keyed.getchannel("A").point(lambda v: 255 if v >= 128 else 0).getbbox()
    cell = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    if not box:
        return cell
    content = keyed.crop(box)
    allowed = reg.allowed_sides(s["edges"])
    left = 0 if "left" in allowed else 1
    top = 0 if "top" in allowed else 1
    right = cw - (0 if "right" in allowed else 1)
    foot = s["anchor"][1] if s.get("anchor_mode") == "foot" else ch - (0 if "bottom" in allowed else 1) - 1
    bw, bh = right - left, foot + 1 - top
    k = min(bw / content.width, bh / content.height)
    nw, nh = max(1, int(content.width * k)), max(1, int(content.height * k))
    small = harden(shrink(content, nw, nh))
    if s.get("anchor_mode") == "foot":
        x = min(max(left, s["anchor"][0] - nw // 2), right - nw)
    else:
        x = left + (bw - nw) // 2
    y = foot + 1 - nh
    if s.get("anchor_mode") not in ("foot",) and s["kind"] in ("hud_piece", "hud_icon", "effect", "character"):
        y = top + (bh - nh) // 2
    cell.alpha_composite(small, (x, y))
    # The lowest opaque row lands on the foot row even when the box filter dropped a thin bottom line.
    a = np.asarray(cell)
    ys = np.nonzero((a[..., 3] > 0).any(axis=1))[0]
    if s.get("anchor_mode") == "foot" and ys.size and ys.max() != foot:
        a = np.roll(a, foot - int(ys.max()), axis=0)
        cell = Image.fromarray(a, "RGBA")
    return cell


def snap(img: Image.Image, s: dict) -> Image.Image:
    a = np.asarray(img).copy()
    m = a[..., 3] > 0
    if not m.any():
        return img
    pal = reg.palette(s)
    budget = int(s["palette"].get("max", 0)) or 256
    px = a[m][:, :3].astype(int)
    if pal is None:
        # No strip yet: the picture's own colours, cut to the budget with a fixed median cut, no dithering.
        strip = Image.fromarray(px.reshape(-1, 1, 3).astype(np.uint8), "RGB")
        q = strip.quantize(colors=min(budget, 256), method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
        pal = np.array(q.getpalette()[: 3 * len(q.getcolors())], dtype=int).reshape(-1, 3)
    pal = np.asarray(pal, dtype=int)
    out = np.empty_like(px)
    for i in range(0, len(px), 65536):
        chunk = px[i:i + 65536]
        d = ((chunk[:, None, :] - pal[None, :, :]) ** 2).sum(-1)
        out[i:i + 65536] = pal[d.argmin(1)]
    a[m, :3] = out.astype(np.uint8)
    return Image.fromarray(a, "RGBA")


def prepare(slot_id: str, raw_path: Path, out_path: Path) -> Image.Image:
    s = reg.spec(slot_id)
    raw = Image.open(raw_path).convert("RGBA")
    sw, sh = s["sheet_size"]
    cw, ch = s["size"]
    sheet = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    rows, frames = s["rows"], s["frames"]
    if rows * frames == 1:
        sheet = fit_cell(raw, s)
    else:
        # A sheet: the raw is cut into the same grid of frames and state rows, each cell prepared alone.
        rw, rh = raw.size
        for r in range(rows):
            for f in range(frames):
                part = raw.crop((rw * f // frames, rh * r // rows, rw * (f + 1) // frames, rh * (r + 1) // rows))
                sheet.alpha_composite(fit_cell(part, s), (f * cw, r * ch))
    sheet = snap(sheet, s)
    if s["alpha"] == "opaque":
        a = np.asarray(sheet).copy()
        a[..., 3] = 255
        sheet = Image.fromarray(a, "RGBA")
    out_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out_path)
    return sheet


def main() -> int:
    ap = argparse.ArgumentParser(description="Prepare a raw generation into a slot candidate.")
    ap.add_argument("slot_id")
    ap.add_argument("raw")
    ap.add_argument("out")
    a = ap.parse_args()
    try:
        img = prepare(a.slot_id, Path(a.raw), Path(a.out))
    except (reg.StaleRegistry, KeyError) as e:
        print(f"refused: {e}", file=sys.stderr)
        return 2
    arr = np.asarray(img)
    m = arr[..., 3] > 0
    n = len(np.unique(arr[m][:, :3], axis=0)) if m.any() else 0
    print(f"prepared {a.slot_id}: {img.width}x{img.height}, {n} colours, {int(m.sum())} opaque pixels -> {a.out}")
    print(f"next: python tools/art/validate_slot.py {a.slot_id} {a.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
