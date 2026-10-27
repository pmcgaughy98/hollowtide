"""Checks a candidate picture against its art slot (Claude, 2026-10-26, placeholder factory contract;
03-spec-format.md section 2.3).

    python tools/art/validate_slot.py <slot_id> <candidate.png>

Runs the slot's scripted checks (C1 to C13, from its spec in slots.json), prints one line each, PASS, FAIL or WARN
with the number, lists the review items (R1 to R4) a person answers, and writes <candidate>.check.json beside the
candidate. Exit 0 only when no scripted check fails. The connected-region and edge measurements come from
tools/art/finish_sprite.py, so they are measured one way everywhere.
"""
import argparse
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import slot_registry as reg  # noqa: E402
from finish_sprite import components, edge_mask  # noqa: E402

REVIEW = {
    "R1": "no text, letters, numbers or signage lettering anywhere",
    "R2": "nothing that reads as another game or franchise",
    "R3": "no creature, animal or person unless the slot asks for one",
    "R4": "sits in the scene: placeholder, candidate and in-game capture side by side",
}
NAMES = {"C1": "size", "C2": "colours", "C3": "alpha", "C4": "edges", "C5": "palette", "C6": "seams", "C7": "foot row",
         "C8": "frame health", "C9": "specks", "C10": "doorway", "C11": "scale", "C12": "light side", "C13": "9-slice"}


def luma(rgb):
    return rgb[..., 0] * 0.299 + rgb[..., 1] * 0.587 + rgb[..., 2] * 0.114


def seam(a, b):
    """Mean and max absolute difference between two edge lines (RGB), as C6 measures it."""
    d = np.abs(a[..., :3].astype(int) - b[..., :3].astype(int))
    return float(d.mean(axis=0).max()) if d.size else 0.0, int(d.max()) if d.size else 0


def run(slot_id: str, path: Path) -> dict:
    s = reg.spec(slot_id)
    img = np.asarray(Image.open(path).convert("RGBA"))
    H, W = img.shape[:2]
    sw, sh = s["sheet_size"]
    cw, ch = s["size"]
    alpha = img[..., 3]
    opaque = alpha > 0
    out = []

    def say(cid, result, detail):
        out.append({"id": cid, "name": NAMES[cid], "result": result, "detail": detail})

    checks = set(s["checks"]) | {"C1"}
    say("C1", "PASS" if (W, H) == (sw, sh) else "FAIL", f"{W}x{H}, slot sheet {sw}x{sh}")
    sized = (W, H) == (sw, sh)
    if "C2" in checks:
        budget = int(s["palette"].get("max", 0))
        whole = len(np.unique(img[opaque][:, :3], axis=0)) if opaque.any() else 0
        worst = 0
        if sized:
            for _, _, c in reg.cells(img, s):
                m = c[..., 3] > 0
                worst = max(worst, len(np.unique(c[m][:, :3], axis=0)) if m.any() else 0)
        if budget <= 0:
            say("C2", "WARN", f"{whole} colours; no budget (as installed)")
        else:
            say("C2", "PASS" if whole <= budget and worst <= budget else "FAIL", f"{whole} colours (worst cell {worst}), budget {budget}")
    if "C3" in checks:
        if s["alpha"] == "opaque":
            n = int((alpha < 255).sum())
            say("C3", "PASS" if n == 0 else "FAIL", f"{n} pixels not fully opaque")
        else:
            n = int(((alpha > 0) & (alpha < 255)).sum())
            say("C3", "PASS" if n == 0 else "FAIL", f"{n} partial-alpha pixels")
    if "C4" in checks and sized:
        allowed = reg.allowed_sides(s["edges"])
        hits = {}
        for _, _, c in reg.cells(img, s):
            a = c[..., 3] > 0
            for side, line in (("top", a[0]), ("bottom", a[-1]), ("left", a[:, 0]), ("right", a[:, -1])):
                if side not in allowed and line.any():
                    hits[side] = hits.get(side, 0) + int(line.sum())
        say("C4", "PASS" if not hits else "FAIL", "clear" if not hits else ", ".join(f"{k} {v}" for k, v in hits.items()))
    if "C5" in checks:
        pal = reg.palette(s)
        cols = np.unique(img[opaque][:, :3], axis=0) if opaque.any() else np.zeros((0, 3), np.uint8)
        if pal is None:
            say("C5", "WARN", "no palette strip yet for " + str(s["palette"].get("family")))
        elif cols.size:
            d = np.sqrt(((cols[:, None, :].astype(int) - pal[None, :, :].astype(int)) ** 2).sum(-1)).min(1)
            px = img[opaque][:, :3]
            # Mean distance over pixels, through each pixel's colour.
            lut = {tuple(c): float(v) for c, v in zip(cols.tolist(), d.tolist())}
            mean = float(np.mean([lut[tuple(p)] for p in px[:: max(1, len(px) // 20000)].tolist()]))
            limit = 0.0 if s["palette"].get("lock") else 20.0
            far = int((d > limit).sum())
            res = "PASS" if far == 0 else "FAIL"
            if res == "PASS" and mean > 40:
                res = "WARN"
            say("C5", res, f"{far} colours over {limit:.0f} from the palette; mean distance {mean:.1f}")
        else:
            say("C5", "WARN", "no opaque pixels")
    if "C6" in checks and sized:
        res, notes = "PASS", []
        t = s.get("tiling", "none")
        for _, _, c in reg.cells(img, s):
            pairs = []
            if t in ("h", "hv"):
                pairs.append(("left/right", c[:, 0], c[:, -1]))
            if t in ("v", "hv"):
                pairs.append(("top/bottom", c[0], c[-1]))
            for name, a, b in pairs:
                mean, mx = seam(a, b)
                notes.append(f"{name} mean {mean:.1f} max {mx}")
                if mean > 10 or mx > 48:
                    res = "FAIL"
        say("C6", res, "; ".join(notes) or "no tiling")
    if "C7" in checks and sized and s.get("anchor_mode") == "foot":
        foot = s["anchor"][1]
        rows = []
        for _, _, c in reg.cells(img, s):
            ys = np.nonzero((c[..., 3] > 0).any(axis=1))[0]
            rows.append(int(ys.max()) if ys.size else -1)
        say("C7", "PASS" if all(r == foot for r in rows) else "FAIL", f"lowest rows {rows}, foot row {foot}")
    if "C8" in checks and sized:
        counts, slabs = [], []
        for _, _, c in reg.cells(img, s):
            m = c[..., 3] > 0
            counts.append(int(m.sum()))
            idx = np.full(m.shape, -1, int)
            if m.any():
                _, inv = np.unique(c[m][:, :3], axis=0, return_inverse=True)
                idx[m] = inv.reshape(-1)
                _, sizes = components(idx, True)
                slabs.append(max(sizes) / max(1, m.sum()))
        med = float(np.median(counts)) if counts else 0.0
        uneven = [n for n in counts if med and abs(n - med) > 0.25 * med]
        big = max(slabs) if slabs else 0.0
        res = "PASS" if not uneven and big < 0.25 and med > 0 else "FAIL"
        say("C8", res, f"opaque per cell {counts}; largest one-colour block {big:.0%} of a cell")
    if "C9" in checks:
        rgb = img[..., :3].astype(int)
        key = (rgb[..., 0] << 16) | (rgb[..., 1] << 8) | rgb[..., 2]
        key = np.where(opaque, key, -1)
        pad = np.pad(key, 1, constant_values=-2)
        same = np.zeros(key.shape, bool)
        for dy, dx in ((0, 1), (2, 1), (1, 0), (1, 2)):
            same |= pad[dy:dy + H, dx:dx + W] == key
        orphans = int((opaque & ~same).sum())
        lum = luma(img[..., :3].astype(float))
        lpad = np.pad(lum, 1, constant_values=-1e9)
        darker = np.ones(key.shape, bool)
        for dy, dx in ((0, 1), (2, 1), (1, 0), (1, 2)):
            darker &= lum - lpad[dy:dy + H, dx:dx + W] >= 50
        light = int((opaque & darker).sum())
        share = orphans / max(1, int(opaque.sum()))
        say("C9", "PASS" if share <= 0.01 else "FAIL", f"{orphans} orphan pixels ({share:.2%}), {light} light specks")
    if "C10" in checks and "door_px" in s and sized:
        x, y, w, h = s["door_px"]
        door = img[y:y + h, x:x + w]
        full = bool((door[..., 3] == 255).all())
        side = np.concatenate([img[y:y + h, max(0, x - 8):x], img[y:y + h, x + w:x + w + 8]], axis=1)
        sm = side[..., 3] > 0
        wall = float(luma(side[sm][:, :3].astype(float)).mean()) if sm.any() else 0.0
        dm = float(luma(door[..., :3].reshape(-1, 3).astype(float)).mean()) if door.size else 0.0
        res = "PASS" if full and wall > 0 and dm <= 0.85 * wall else "FAIL"
        say("C10", res, f"door opaque {full}; door brightness {dm:.0f}, wall beside it {wall:.0f}")
    if "C11" in checks and "door_px" in s and s.get("pass_creature"):
        box = reg.creature_box(s["pass_creature"])
        _, _, w, h = s["door_px"]
        if box is None:
            say("C11", "FAIL", f"no town set for {s['pass_creature']}")
        else:
            ok = h >= box[1] and w >= 0.75 * box[0]
            say("C11", "PASS" if ok else "FAIL", f"door {w}x{h}, {s['pass_creature']} {box[0]}x{box[1]} (needs height and 0.75 x width)")
    if "C12" in checks and s["alpha"] != "opaque" and opaque.any():
        idx = np.where(opaque, 0, -1)
        edge = edge_mask(idx)
        pad = np.pad(opaque, 1)
        ul = edge & (~pad[:-2, 1:-1] | ~pad[1:-1, :-2])
        lr = edge & (~pad[2:, 1:-1] | ~pad[1:-1, 2:])
        lum = luma(img[..., :3].astype(float))
        a, b = (float(lum[ul].mean()) if ul.any() else 0.0), (float(lum[lr].mean()) if lr.any() else 0.0)
        say("C12", "PASS" if a >= b else "WARN", f"upper-left edge {a:.0f}, lower-right edge {b:.0f}")
    if "C13" in checks and sized:
        l, t, r, b = s.get("margins", [0, 0, 0, 0])
        res, notes = "PASS", []
        if l + r >= cw or t + b >= ch:
            res, notes = "FAIL", ["margins do not fit"]
        else:
            strips = []
            if t:
                strips.append(("top", img[:t, l:cw - r], 1))
            if b:
                strips.append(("bottom", img[ch - b:, l:cw - r], 1))
            if l:
                strips.append(("left", img[t:ch - b, :l], 0))
            if r:
                strips.append(("right", img[t:ch - b, cw - r:], 0))
            if not strips:
                strips.append(("whole", img, 1))
            for name, st, axis in strips:
                if st.size == 0:
                    continue
                a2, b2 = (st[:, 0], st[:, -1]) if axis == 1 else (st[0], st[-1])
                mean, mx = seam(a2, b2)
                notes.append(f"{name} mean {mean:.1f} max {mx}")
                if mean > 10 or mx > 48:
                    res = "FAIL"
        say("C13", res, "; ".join(notes))
    ok = not any(o["result"] == "FAIL" for o in out)
    return {"slot": slot_id, "candidate": str(path), "registry_sha256": reg.registry_hash(), "pass": ok,
            "results": out, "review": REVIEW}


def main() -> int:
    ap = argparse.ArgumentParser(description="Check a candidate against its art slot (C1-C13).")
    ap.add_argument("slot_id")
    ap.add_argument("candidate")
    a = ap.parse_args()
    try:
        report = run(a.slot_id, Path(a.candidate))
    except (reg.StaleRegistry, KeyError) as e:
        print(f"refused: {e}", file=sys.stderr)
        return 2
    for r in report["results"]:
        print(f"{r['id']:4s} {r['name']:13s} {r['result']:5s} {r['detail']}")
    for k, v in REVIEW.items():
        print(f"{k:4s} {'review':13s} {'-':5s} {v}")
    Path(a.candidate + ".check.json").write_text(json.dumps(report, indent=1) + "\n", encoding="utf-8")
    print("PASS: every scripted check passed" if report["pass"] else "FAIL: a scripted check failed")
    return 0 if report["pass"] else 1


if __name__ == "__main__":
    sys.exit(main())
