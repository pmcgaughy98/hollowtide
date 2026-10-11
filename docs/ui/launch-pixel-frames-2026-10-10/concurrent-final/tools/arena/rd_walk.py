"""Walk cycle for one facing of an arena sprite (Claude, 2026-10-07).
  python tools/arena/rd_walk.py <creature> <facing> [hint]
Runs rd_advanced_animation__walking ($0.14, 8 frames) on assets/sprites/arena/<creature>/<facing>.png at its own size
and saves docs/creatures/arena-starters-2026-10-07/walk/<creature>_<facing>_sheet.png plus a receipt.
Retries only "busy" failures (not charged), five minutes apart; any other failure stops."""
import base64, json, sys, time, urllib.request
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "debug"))
import rd_client

def tool(n, a):
    return json.loads(rd_client.call("tools/call", {"name": n, "arguments": a})["result"]["content"][0]["text"])

name, facing = sys.argv[1], sys.argv[2]
hint = sys.argv[3] if len(sys.argv) > 3 else "walking forward at a steady pace, small game creature"
src = Path(f"assets/sprites/arena/{name}/{facing}.png")
out = Path("docs/creatures/arena-starters-2026-10-07/walk"); out.mkdir(parents=True, exist_ok=True)
from PIL import Image
side = Image.open(src).size[0]  # 128 for stage 1, 144 for stage 2, 160 for stage 3
args = {"prompt": hint, "prompt_style": "rd_advanced_animation__walking", "width": side, "height": side,
        "frames_duration": 8, "input_image": base64.b64encode(src.read_bytes()).decode(), "return_spritesheet": True}
for attempt in range(5):
    t = tool("start_inference_job", args); tid = t.get("task_id") or t.get("id")
    for _ in range(150):
        time.sleep(4); d = tool("get_inference_job", {"task_id": tid})
        if d.get("status") in ("succeeded", "failed"): break
    (out / f"{name}_{facing}_receipt.json").write_text(json.dumps(d)[:3000])
    urls = d.get("output_urls") or (d.get("result") or {}).get("output_urls") or []
    if urls:
        urllib.request.urlretrieve(urls[0], out / f"{name}_{facing}_sheet.png")
        print(name, facing, "ok", (d.get("result") or {}).get("balance_cost"), flush=True); break
    code = str((d.get("error") or {}).get("code"))
    print(name, facing, "failed", code, flush=True)
    if "busy" not in code:
        break   # only "busy" is free to retry; other failures can be charged (rd_action.py, 2026-10-09)
    time.sleep(300)
