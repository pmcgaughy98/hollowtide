"""Tallowroot front: RD image_edit ($0.18) repaints the root-like right forefoot
as a clawed foot; only that region of the result is pasted back. Run from the repo root."""
import base64, io, json, sys, urllib.request
from PIL import Image
sys.path.insert(0, "tools/debug"); import rd_client
D = "docs/creatures/tallowroot-rd-2026-10-05/"
PROMPT = ("Change only the creature's front leg that stands under its chest: replace its brown tree-root foot "
          "with a sturdy brown lower leg ending in a foot with three cream claws, exactly like its back feet. "
          "Keep every other part of the creature exactly the same.")
img = base64.b64encode(open(D + "front_take1.png", "rb").read()).decode()
res = rd_client.call("tools/call", {"name": "run_edit_tool", "arguments": {"tool_id": "image_edit", "input_image": img, "prompt": PROMPT}})
d = json.loads(res["result"]["content"][0]["text"])
open(D + "receipt_edit.json", "w").write(json.dumps({k: v for k, v in d.items() if k not in ("base64_images",)})[:3000])
raw = (d.get("base64_images") or [None])[0]
if raw is None and d.get("output_urls"):
    raw = base64.b64encode(urllib.request.urlopen(d["output_urls"][0]).read()).decode()
edit = Image.open(io.BytesIO(base64.b64decode(raw.split(",")[-1]))).convert("RGBA")
print("edit size", edit.size, {k: d.get(k) for k in ("balance_cost", "remaining_balance")})
if edit.size != (160, 160):
    edit = edit.resize((160, 160), Image.NEAREST)
edit.save(D + "edit_raw.png")
