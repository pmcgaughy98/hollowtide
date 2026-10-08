"""Riftfin 3D test (Claude, 2026-10-06): one Retro Diffusion Low-Poly model from Riftfin's art,
to see whether a 3D model rendered to pixels can replace separate front/back/idle sprites.
  python docs/creatures/riftfin-3d-test-2026-10-06/make_model.py generate   ($1.20, Detailed, 128 texels)
  python docs/creatures/riftfin-3d-test-2026-10-06/make_model.py animate    ($0.50, an idle)"""
import base64, json, sys, time
from pathlib import Path
from PIL import Image
sys.path.insert(0, "tools/debug"); import rd_client
OUT = Path("docs/creatures/riftfin-3d-test-2026-10-06")
def tool(n, a):
    return json.loads(rd_client.call("tools/call", {"name": n, "arguments": a})["result"]["content"][0]["text"])
def wait(task_id, name):
    for _ in range(120):
        time.sleep(15)
        d = tool("get_lowpoly_job", {"task_id": task_id})
        if d.get("status") in ("succeeded", "failed"):
            break
    (OUT / f"{name}_job.json").write_text(json.dumps(d, indent=1))
    print(name, d.get("status"), flush=True)
if sys.argv[1] == "generate":
    rot = Image.open("docs/creatures/starter-lines-rd-2026-10-05/evolutions/riftfin_rotation_3x3.png").convert("RGBA")
    cw = rot.width // 3
    rot.crop((0, 0, cw, cw)).save(OUT / "ref_side.png")  # the rotation's side view, the only one showing the tail
    refs = ["assets/sprites/creatures/starter_material_detail_2026_10_05/502_riftfin_front_material_detail.png",
            str(OUT / "ref_side.png"), "docs/creatures/riftfin-back-2026-10-06/riftfin_back_front_take1.png"]
    prompt = ("Riftfin, a squat river catfish monster on four legs: wide flat head, huge toothy mouth, long barbels, "
              "grey bony head plate, spiked cyan dorsal crest, armour plates, thick catfish tail with broad fin. Deep blue, slate, cyan.")
    t = tool("start_lowpoly_generate", {"prompt": prompt, "size": "128", "style": "rd_lowpoly__detailed",
             "reference_images": [base64.b64encode(open(r, "rb").read()).decode() for r in refs],
             "idempotency_key": "riftfin-3d-test-2026-10-06"})
    (OUT / "generate_start.json").write_text(json.dumps(t)); print("started", t, flush=True)
    wait(t["task_id"], "generate")
else:
    asset = json.loads((OUT / "generate_start.json").read_text())["asset_id"]
    t = tool("start_lowpoly_animate", {"asset_id": asset, "prompt": "a calm battle idle: slow heavy breathing, barbels and tail fin sway gently, feet stay planted",
             "idempotency_key": "riftfin-3d-idle-2026-10-06"})
    (OUT / "animate_start.json").write_text(json.dumps(t)); print("started", t, flush=True)
    wait(t["task_id"], "animate")
