"""Tallowroot Stage I front, Retro Diffusion Pro (Claude, 2026-10-05).
Brief: docs/creatures/creature-roster-draft.md, Line 17. Style reference: Cinderhide's front.
Two takes, $0.36 estimated. Run from the repo root."""
import base64, json, pathlib, sys, urllib.request
sys.path.insert(0, "tools/debug")
import rd_client

HERE = pathlib.Path("docs/creatures/tallowroot-rd-2026-10-05")
PROMPT = ("The first-stage starter creature of a monster-collecting RPG, a sturdy young seed-burrower. "
    "Low, broad, four-legged body on short stocky visible legs. A tapered pointed snout made for digging. "
    "Its forefeet end in thick rootlike claws, one claw pressed into the earth. Its back is a tough seed husk "
    "broken into angular husk points, and one large husked seed pod sits on its shoulder with a small cream "
    "sprout curling out of it. Colours: moss green, seed ochre, rich soil brown, a little cream. Small calm eyes, "
    "patient and protective. Three-quarter view facing right, braced low. Crisp dark outline, the same finish "
    "and shading as the reference creature. Not a vegetable, no flower crown, no tools. Shown whole in the "
    "centre of the frame with empty space on every side. On a plain white background.")
ref = base64.b64encode(open("assets/sprites/creatures/cinderhide.png", "rb").read()).decode()
args = {"prompt": PROMPT, "prompt_style": "rd_pro__default", "width": 160, "height": 160,
        "num_images": 2, "remove_bg": True, "reference_images": [ref]}
(HERE / "prompt_front.json").write_text(json.dumps({**args, "reference_images": ["assets/sprites/creatures/cinderhide.png"]}, indent=1))
res = rd_client.call("tools/call", {"name": "create_inference", "arguments": args})
text = json.dumps(res)
(HERE / "receipt_front.json").write_text(text)
data = json.loads(res["result"]["content"][0]["text"]) if "result" in res else {}
for i, url in enumerate(data.get("output_urls", [])):
    urllib.request.urlretrieve(url, HERE / f"front_take{i + 1}.png")
    print("saved", HERE / f"front_take{i + 1}.png")
print({k: data.get(k) for k in ("balance_cost", "remaining_balance", "request_id")})
