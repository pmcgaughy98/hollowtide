"""One Grok Build Imagine image from a style reference, and the reduction to a game slot (Claude, 2026-10-20, from the
mech RPG session; docs/team/SYNTHESIS_FROM_MECH_RPG_2026-10-20.md, part 3).

    python tools/grok_image.py make <style_ref.png> <out.png> "<what to make>" [--aspect 16:9]
    python tools/grok_image.py reduce <in.png> <out.png> <width> <height> <colours>

make: runs `grok -p` headless in a fresh temporary folder that holds only the style reference, so Grok never reads the
repo or anywhere private. The image goes to <out.png>; Grok's reply, turns and reported cost go to <out.png>.grok.json.
Needs Grok Build logged in (`grok login`). Each run reported $0.06 to $0.13 on Preston's Grok Lite login; one image per
run, and Preston looks before the next.
reduce: centre-crops to the slot's aspect, box-downscales to width x height and median-cuts to a fixed palette with no
dithering (32 to 48 colours for a 320x180 screen, 16 to 32 for a UI panel). Compare with the installed file before
installing anything.
"""
import glob
import json
import os
import shutil
import subprocess
import sys
import tempfile

from PIL import Image

GROK = os.path.expanduser("~/.grok/bin/grok.exe") if os.name == "nt" else "grok"
HONEST = "Honesty first: if a step fails, or you cannot see the attached image, say so plainly instead of guessing. "


def make(ref, out, what, aspect="16:9"):
    work = tempfile.mkdtemp(prefix="grok_image_")
    shutil.copy(ref, os.path.join(work, "style_ref.png"))
    name = os.path.splitext(os.path.basename(out))[0]
    prompt = (HONEST + "Step 1: read style_ref.png in this folder, an image from our game, for its style and colours."
              " Step 2: use your Imagine image generation tool once to make " + what + " Aspect ratio " + aspect + ";"
              " clean pixel art: flat colour areas, hard-edged pixel clusters, no gradients or soft blur, light from the"
              " upper left; nothing from any existing franchise; no text, words or letters anywhere. Step 3: save the"
              " generated image in this folder as " + name + ".png and reply with the saved path and one sentence on"
              " what it shows and anything you could not follow. Remember: no text, labels or lettering anywhere.")
    r = subprocess.run([GROK, "-p", prompt, "--output-format", "json", "--max-turns", "8", "--always-approve",
                        "--disable-web-search"], cwd=work, capture_output=True, text=True, encoding="utf-8",
                       errors="replace", timeout=600)
    try:
        d = json.loads(r.stdout)
    except ValueError:
        d = {"text": (r.stdout or "")[-600:] + " | stderr: " + (r.stderr or "")[-300:]}
    made = [f for f in glob.glob(os.path.join(work, "*")) if os.path.basename(f) != "style_ref.png"
            and f.lower().endswith((".png", ".jpg", ".jpeg", ".webp"))]
    rec = {"style_ref": ref, "out": None, "cost_usd": d.get("total_cost_usd"), "turns": d.get("num_turns"),
           "text": (d.get("text") or "")[:800], "work": work}
    if made:
        os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
        Image.open(max(made, key=os.path.getmtime)).convert("RGB").save(out)
        rec["out"] = out
    with open(out + ".grok.json", "w", encoding="utf-8") as fh:
        json.dump(rec, fh, indent=1)
    print(json.dumps(rec)[:500])
    return 0 if made else 1


def reduce(src, out, width, height, colours):
    im = Image.open(src).convert("RGB")
    w, h = im.size
    ta = width / height
    if abs(w / h - ta) > 0.02:
        if w / h > ta:
            nw = int(h * ta)
            im = im.crop(((w - nw) // 2, 0, (w - nw) // 2 + nw, h))
        else:
            nh = int(w / ta)
            im = im.crop((0, (h - nh) // 2, w, (h - nh) // 2 + nh))
    small = im.resize((width, height), Image.BOX).quantize(colors=colours, method=Image.Quantize.MEDIANCUT,
                                                            dither=Image.Dither.NONE).convert("RGB")
    small.save(out)
    print("%s -> %s %dx%d, %d colours" % (src, out, width, height, len(small.getcolors(1 << 24))))
    return 0


if __name__ == "__main__":
    a = sys.argv[1:]
    if len(a) >= 4 and a[0] == "make":
        asp = a[a.index("--aspect") + 1] if "--aspect" in a else "16:9"
        sys.exit(make(a[1], a[2], a[3], asp))
    if len(a) == 6 and a[0] == "reduce":
        sys.exit(reduce(a[1], a[2], int(a[3]), int(a[4]), int(a[5])))
    print(__doc__)
    sys.exit(2)
