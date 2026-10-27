"""Run the walk fix lanes in one chain on the raw PixelLab courier walk (Claude, 2026-10-26, the composer step).

    python tools/art/walk_fix/compose_walk.py [--order headlock,height,legs,satchel,bob,colour]
                                              [--chain-dir DIR] [--out FIXED.png] [--no-measure]

Starts from the raw atlas docs/art/characters/sprite-tool-test-2026-10-26/pixellab_courier_walk_native80.png
(read only), runs each chosen fix script on the previous step's output, saves every intermediate as
DIR/NN_<step>.png with that step's own report, measures each step with measure_walk.py and writes
DIR/step_metrics.json. The last step's output is copied to FIXED.png
(default docs/art/characters/sprite-tool-test-2026-10-26/fix/pixellab_courier_walk_fixed_native80.png).

Why this order (each lane's own order note, plus what the chain showed):
  headlock  first: it pastes one master head per direction and must run before the satchel strap reaches the
            shoulders (a strap above the collar would count as head and be erased). For left, right and
            down_right it picks PixelLab's rotation head, which is 1 px taller than the walk frames' heads.
  height    next, so it measures what is still short once the heads are fixed. It reads alpha only and
            lengthens the short side views by duplicating whole body rows. Run before the head lane (as its
            note suggests) it adds 7 rows and the side views end 1 to 2 px taller than RD's (median 65 to 66
            against 64); run after it, it adds 4 rows and they land on 64 to 65. The leg and bob lanes still
            see the final proportions.
  legs      rebuilds the down and up strides from RD and sets RD's own body bob on those two rows. It runs
            BEFORE the satchel, against its own order note: run after the satchel, its leg mask took the
            lower half of the new back bag for trouser and erased it on the up row (bag drawn fell from 100%
            to 41.8% in the worst frame, and the bag bottom smeared into the legs at 3x).
  satchel   after the heads and the legs, before the bob. Its per-frame placement follows the leg lane's
            body shift and re-timing, so the bag rides on the final torso.
  bob       adds the 2 px walk bob to the other six rows. The down and up rows are put back as the leg lane
            left them (BOB_KEEP), because running the bob there would replace RD's bob, matched to RD's legs,
            with a textbook one.
  colour    last: it locks every colour any lane brought in to the 40-colour palette and repairs eyes, side
            lenses and the maroon far leg on the final geometry. It is idempotent. Running it first as well
            was tried and dropped: the head lane then picks PixelLab's small frame heads for left, right and
            down_right instead of the fuller rotation heads. Re-measured 2026-10-27 on the final output: head
            tops end the same (the height lane evens them out), but the dark outline share falls (left 0.984
            to 0.966, down_right 0.948 to 0.931) and head redraw doubles in those rows (0.008-0.012 to
            0.018-0.026).
            Satchel before legs was also re-measured 2026-10-27: up bag drawn min 41.8% and down 31.9%,
            against 100% and 48.9% in this order.

Everything is integer pixel work inside the lanes; this script only runs them, copies rows and measures.
"""
import argparse
import json
import shutil
import subprocess
import sys
import time
from pathlib import Path

import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
HT = HERE.parents[2]
TEST = HT / "docs/art/characters/sprite-tool-test-2026-10-26"
RAW = TEST / "pixellab_courier_walk_native80.png"
DEFAULT_OUT = TEST / "fix/pixellab_courier_walk_fixed_native80.png"
DEFAULT_CHAIN = TEST / "fix/chain"
ROWS = ["down", "down_left", "left", "up_left", "up", "up_right", "right", "down_right"]
CELL = 80
DEFAULT_ORDER = ["headlock", "height", "legs", "satchel", "bob", "colour"]
BOB_KEEP = ("down", "up")   # rows whose bob comes from the leg lane


def cmd_for(step, src, dst, rep):
    py = sys.executable
    return {
        "colour": [py, str(HERE / "fix_colour.py"), str(src), str(dst), str(rep)],
        "height": [py, str(HERE / "fix_height.py"), str(src), str(dst), "--plan", str(rep)],
        "headlock": [py, str(HERE / "fix_headlock.py"), str(src), str(dst), "--report", str(rep)],
        "satchel": [py, str(HERE / "fix_satchel.py"), str(src), str(dst)],
        "legs": [py, str(HERE / "fix_legs.py"), str(src), str(dst), "--report", str(rep)],
        "bob": [py, str(HERE / "fix_bob.py"), str(src), str(dst), "--report", str(rep)],
    }[step]


def load(p):
    return np.array(Image.open(p).convert("RGBA"))


def changed_per_row(a, b):
    d = np.any(a != b, axis=-1)
    return {r: int(d[i * CELL:(i + 1) * CELL].sum()) for i, r in enumerate(ROWS)}


def keep_rows(src, dst, rows):
    a, b = load(src), load(dst)
    for r in rows:
        i = ROWS.index(r)
        b[i * CELL:(i + 1) * CELL] = a[i * CELL:(i + 1) * CELL]
    Image.fromarray(b, "RGBA").save(dst)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--order", default=",".join(DEFAULT_ORDER))
    ap.add_argument("--chain-dir", default=str(DEFAULT_CHAIN))
    ap.add_argument("--out", default=str(DEFAULT_OUT))
    ap.add_argument("--bob-keep", default=",".join(BOB_KEEP), help="rows the bob step leaves as they were ('' for none)")
    ap.add_argument("--no-measure", action="store_true")
    a = ap.parse_args()

    order = [s for s in a.order.split(",") if s]
    bob_keep = [r for r in a.bob_keep.split(",") if r]
    chain = Path(a.chain_dir)
    chain.mkdir(parents=True, exist_ok=True)
    if not a.no_measure:
        sys.path.insert(0, str(HERE))
        import measure_walk as MW
        raw_arr = load(RAW)
    first = chain / "00_raw.png"
    shutil.copyfile(RAW, first)
    log = {"raw": str(RAW), "order": order, "bob_keep_rows": bob_keep, "steps": []}
    if not a.no_measure:
        log["steps"].append({"step": "raw", "file": str(first), "headline": MW.headline(MW.measure_atlas(load(first), raw_arr))})
    src = first
    for n, step in enumerate(order, 1):
        dst = chain / f"{n:02d}_{step}.png"
        rep = chain / f"{n:02d}_{step}_report.json"
        t0 = time.time()
        r = subprocess.run(cmd_for(step, src, dst, rep), capture_output=True, text=True)
        if r.returncode != 0 or not dst.exists():
            raise SystemExit(f"step {step} failed:\n{r.stdout}\n{r.stderr}")
        if step == "bob" and bob_keep:
            keep_rows(src, dst, bob_keep)
        out = load(dst)
        if out.shape != (CELL * 8, CELL * 8, 4):
            raise SystemExit(f"step {step} wrote a {out.shape} image")
        entry = {"step": step, "file": str(dst), "seconds": round(time.time() - t0, 1),
                 "changed_px_per_row": changed_per_row(load(src), out),
                 "alpha_values": sorted(int(v) for v in np.unique(out[..., 3])),
                 "stdout_tail": r.stdout.strip().splitlines()[-3:]}
        if not a.no_measure:
            entry["headline"] = MW.headline(MW.measure_atlas(out, raw_arr))
        log["steps"].append(entry)
        print(f"{n:02d} {step}: {entry['seconds']} s, changed {sum(entry['changed_px_per_row'].values())} px")
        src = dst
    Path(a.out).parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(src, a.out)
    log["final"] = str(a.out)
    (chain / "step_metrics.json").write_text(json.dumps(log, indent=1, default=str), encoding="utf-8")
    print("wrote", a.out)


if __name__ == "__main__":
    main()
