"""An arena background with Retro Diffusion's top-down map style (Claude, 2026-10-07).
  python tools/arena/rd_map.py <name> "<prompt>"
rd_plus__topdown_map, 384 x 216 ($0.06), run as a queued job and polled, so a dropped
connection can never pick up another job's result. Saves
docs/creatures/arena-starters-2026-10-07/maps/<name>.png and a receipt."""
import json, sys, time, urllib.request
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "debug"))
import rd_client

def tool(n, a):
    return json.loads(rd_client.call("tools/call", {"name": n, "arguments": a})["result"]["content"][0]["text"])

name, prompt = sys.argv[1], sys.argv[2]
out = Path("docs/creatures/arena-starters-2026-10-07/maps"); out.mkdir(parents=True, exist_ok=True)
t = tool("start_inference_job", {"prompt": prompt, "prompt_style": "rd_plus__topdown_map", "width": 384, "height": 216, "num_images": 1})
tid = t.get("task_id") or t.get("id")
for _ in range(120):
    time.sleep(4); d = tool("get_inference_job", {"task_id": tid})
    if d.get("status") in ("succeeded", "failed"): break
(out / f"{name}_receipt.json").write_text(json.dumps(d)[:3000])
urls = d.get("output_urls") or (d.get("result") or {}).get("output_urls") or []
if urls:
    urllib.request.urlretrieve(urls[0], out / f"{name}.png")
print(name, d.get("status"), (d.get("result") or {}).get("balance_cost"))
