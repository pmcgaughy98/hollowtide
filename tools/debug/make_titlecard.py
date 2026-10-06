"""Signature title card from a creature frame (Claude, 2026-10-05).
  python tools/debug/make_titlecard.py <frame.png> <out.png>
Fits the whole creature into 140 x 118 with a 4 px margin (the card shows it at 3x),
shrinking with Retro Diffusion's free k-centroid pixel downscale so the pixels stay
clean; the outline comes from the original's own transparency."""
import base64, io, json, sys
from pathlib import Path
from PIL import Image
sys.path.insert(0, str(Path(__file__).parent)); import rd_client
W, H, M = 140, 118, 4
src = Image.open(sys.argv[1]).convert("RGBA")
art = src.crop(src.getbbox())
k = min((W - 2 * M) / art.width, (H - 2 * M) / art.height)
w, h = max(1, round(art.width * k)), max(1, round(art.height * k))
b = io.BytesIO(); art.save(b, "PNG")
r = rd_client.call("tools/call", {"name": "run_edit_tool", "arguments": {"tool_id": "k_centroid_downscale", "input_image": base64.b64encode(b.getvalue()).decode(), "width": w, "height": h}})
d = json.loads(r["result"]["content"][0]["text"])
small = Image.open(io.BytesIO(base64.b64decode(d["base64_images"][0].split(",")[-1]))).convert("RGBA")
small.putalpha(art.getchannel("A").resize((w, h), Image.NEAREST).point(lambda a: 255 if a >= 128 else 0))
card = Image.new("RGBA", (W, H), (0, 0, 0, 0))
card.alpha_composite(small, ((W - w) // 2, H - M - h))  # standing on the bottom margin
card.save(sys.argv[2]); print("card", sys.argv[2], (w, h), "cost", d.get("balance_cost"))
