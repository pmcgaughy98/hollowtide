"""One action animation for one facing of a creature (Claude, 2026-10-09; Preston: "add the attack, hurt,
and sleep for starter stage 1s"). Built on rd_walk.py.
  python tools/arena/rd_action.py <creature> <action> <facing> "<what the body does>"
action: attack (rd_advanced_animation__attack, 6 frames, $0.14), hurt (custom_action, 6 frames, $0.25),
sleep (custom_action, 8 frames, about $0.25). Saves docs/creatures/actions-2026-10-09/<creature>_<action>_<facing>_sheet.png
and a receipt. Retries only "busy" failures; any other failure stops (they can be charged). One RD job at a time."""
import base64, json, sys, time, urllib.request
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "debug"))
import rd_client

STYLE = {"attack": ("rd_advanced_animation__attack", 6), "hurt": ("rd_advanced_animation__custom_action", 6),
         "sleep": ("rd_advanced_animation__custom_action", 8)}   # subtle_motion only breathes a standing pose


def tool(n, a):
    return json.loads(rd_client.call("tools/call", {"name": n, "arguments": a})["result"]["content"][0]["text"])


name, action, facing, hint = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
style, frames = STYLE[action]
src = Path(f"assets/sprites/arena/{name}/{facing}.png")
out = Path("docs/creatures/actions-2026-10-09"); out.mkdir(parents=True, exist_ok=True)
sheet = out / f"{name}_{action}_{facing}_sheet.png"
if sheet.exists():
    sys.exit(f"{sheet} exists; delete it first to pay for a new take")
from PIL import Image
side = Image.open(src).size[0]
args = {"prompt": hint, "prompt_style": style, "width": side, "height": side, "frames_duration": frames,
        "input_image": base64.b64encode(src.read_bytes()).decode(), "return_spritesheet": True}
for attempt in range(5):
    t = tool("start_inference_job", args); tid = t.get("task_id") or t.get("id")
    for _ in range(150):
        time.sleep(4); d = tool("get_inference_job", {"task_id": tid})
        if d.get("status") in ("succeeded", "failed"): break
    (out / f"{name}_{action}_{facing}_receipt.json").write_text(json.dumps(d)[:3000])
    urls = d.get("output_urls") or (d.get("result") or {}).get("output_urls") or []
    if urls:
        urllib.request.urlretrieve(urls[0], sheet)
        print(name, action, facing, "ok", (d.get("result") or {}).get("balance_cost"), flush=True); break
    code = (d.get("error") or {}).get("code")
    print(name, action, facing, "failed", code, flush=True)
    if code != "busy":
        break   # 2026-10-09: five "inference_failed" retries on rimefin hurt n appear to have been charged; only "busy" is retried
    time.sleep(120)
