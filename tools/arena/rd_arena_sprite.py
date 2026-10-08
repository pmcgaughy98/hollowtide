"""One arena sprite take from a creature's front art (Claude, 2026-10-07).
  python tools/arena/rd_arena_sprite.py <name> <size> <front.png> "<what it is>"
rd_pro__default with the front as the reference, background removed ($0.18), run as a
queued job and polled (a dropped connection cannot pick up another job's result).
Saves docs/creatures/arena-starters-2026-10-07/forms/<name>.png and a receipt."""
import base64, json, sys, time, urllib.request
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "debug"))
import rd_client

def tool(n, a):
    return json.loads(rd_client.call("tools/call", {"name": n, "arguments": a})["result"]["content"][0]["text"])

name, size, front, what = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4]
out = Path("docs/creatures/arena-starters-2026-10-07/forms"); out.mkdir(parents=True, exist_ok=True)
prompt = (f"Top-down action game sprite of the same creature as the reference image, {what}, seen from above at a "
          "three-quarter overhead angle like a sprite in a top-down arena battle game, facing down and to the right "
          "toward the camera, standing ready to fight. A small, readable game sprite: chunky clear shapes, a crisp dark "
          "outline, the same colours, markings and signature features as the reference image. Whole creature centred "
          "with empty space on every side. On a plain white background.")
t = tool("start_inference_job", {"prompt": prompt, "prompt_style": "rd_pro__default", "width": size, "height": size,
         "num_images": 1, "remove_bg": "--keep-bg" not in sys.argv, "reference_images": [base64.b64encode(open(front, "rb").read()).decode()]})
tid = t.get("task_id") or t.get("id")
for _ in range(120):
    time.sleep(4); d = tool("get_inference_job", {"task_id": tid})
    if d.get("status") in ("succeeded", "failed"): break
(out / f"{name}_receipt.json").write_text(json.dumps(d)[:3000])
urls = d.get("output_urls") or (d.get("result") or {}).get("output_urls") or []
if urls:
    urllib.request.urlretrieve(urls[0], out / f"{name}.png")
print(name, d.get("status"), (d.get("result") or {}).get("balance_cost"))
