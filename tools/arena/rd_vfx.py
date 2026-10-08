"""A pixel-art effect animation for the arena (Claude, 2026-10-07).
  python tools/arena/rd_vfx.py <name> "<prompt>" [size]
rd_animation__vfx ($0.07), queued and polled, sprite sheet returned. Saves
docs/creatures/arena-starters-2026-10-07/vfx/<name>_sheet.png and a receipt."""
import json, sys, time, urllib.request
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "debug"))
import rd_client

def tool(n, a):
    return json.loads(rd_client.call("tools/call", {"name": n, "arguments": a})["result"]["content"][0]["text"])

name, prompt = sys.argv[1], sys.argv[2]
size = int(sys.argv[3]) if len(sys.argv) > 3 else 64
out = Path("docs/creatures/arena-starters-2026-10-07/vfx"); out.mkdir(parents=True, exist_ok=True)
t = tool("start_inference_job", {"prompt": prompt, "prompt_style": "rd_animation__vfx", "width": size, "height": size,
         "num_images": 1, "return_spritesheet": True})
tid = t.get("task_id") or t.get("id")
for _ in range(120):
    time.sleep(4); d = tool("get_inference_job", {"task_id": tid})
    if d.get("status") in ("succeeded", "failed"): break
(out / f"{name}_receipt.json").write_text(json.dumps(d)[:3000])
urls = d.get("output_urls") or (d.get("result") or {}).get("output_urls") or []
if urls:
    urllib.request.urlretrieve(urls[0], out / f"{name}_sheet.png")
print(name, d.get("status"), (d.get("result") or {}).get("balance_cost"))
