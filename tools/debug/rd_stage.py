"""An environment scene the size of the signature stages (Claude, 2026-10-10): rd_plus__environment at
448x256, $0.06 an image. Used for the essence scenes on the Team page (Preston: "each ember gets same scene").
  python tools/debug/rd_stage.py <name> <takes> "<prompt>"
Saves assets/backgrounds/signature_stages/<name>_take<N>.png and the request in
docs/battle/signature-stages-2026-10-01/<name>.json. A failed call is never re-sent here."""
import base64, json, pathlib, sys, urllib.request
sys.path.insert(0, str(pathlib.Path(__file__).parent))
import rd_client

name, takes, prompt = sys.argv[1], int(sys.argv[2]), sys.argv[3]
args = {"prompt": prompt, "prompt_style": "rd_plus__environment", "width": 448, "height": 256, "num_images": takes}
pathlib.Path(f"docs/battle/signature-stages-2026-10-01/{name}.json").write_text(json.dumps(args, indent=1))
res = rd_client.call("tools/call", {"name": "create_inference", "arguments": args})
d = json.loads(res["result"]["content"][0]["text"])
out = pathlib.Path("assets/backgrounds/signature_stages")
imgs = d.get("base64_images") or []
for k, b in enumerate(imgs):
    (out / f"{name}_take{k + 1}.png").write_bytes(base64.b64decode(b.split(",")[-1]))
if not imgs:
    for k, u in enumerate(d.get("output_urls") or []):
        urllib.request.urlretrieve(u, out / f"{name}_take{k + 1}.png")
print(name, "takes", max(len(imgs), len(d.get("output_urls") or [])), "cost", d.get("balance_cost"), "balance", d.get("remaining_balance"))
