"""Animated battle idles with Retro Diffusion (Claude, 2026-10-05).
  python tools/debug/rd_idle.py <creature.tres> <out_dir> "<motion hint>" [back]
Runs rd_advanced_animation__idle (8 frames, $0.14) on the creature's front sprite (or, with
"back", its back sprite; 2026-10-06) at its
own canvas size, retries "busy" failures (not charged), and saves the sheet and receipt."""
import base64, json, re, sys, time, urllib.request
from pathlib import Path
from PIL import Image
sys.path.insert(0, str(Path(__file__).parent)); import rd_client
def tool(n, a):
    r = rd_client.call("tools/call", {"name": n, "arguments": a}); return json.loads(r["result"]["content"][0]["text"])
tres, out, hint = sys.argv[1], Path(sys.argv[2]), sys.argv[3]
back = len(sys.argv) > 4 and sys.argv[4] == "back"
out.mkdir(parents=True, exist_ok=True)
text = open(tres, encoding="utf-8").read()
key = re.search(r'^%s = ExtResource\("([^"]+)"\)' % ("back_sprite" if back else "sprite"), text, re.M).group(1)
sprite = re.search(r'path="res://([^"]+)" id="%s"' % re.escape(key), text).group(1)
im = Image.open(sprite).convert("RGBA"); side = max(im.size)
name = Path(tres).stem + ("_back" if back else "")
args = {"prompt": hint, "prompt_style": "rd_advanced_animation__idle", "width": side, "height": side,
        "frames_duration": 8, "input_image": base64.b64encode(open(sprite, "rb").read()).decode(), "return_spritesheet": True}
for attempt in range(6):
    t = tool("start_inference_job", args); tid = t.get("task_id") or t.get("id")
    for _ in range(150):
        time.sleep(4); d = tool("get_inference_job", {"task_id": tid})
        if d.get("status") in ("succeeded", "failed"): break
    (out / f"{name}_idle_receipt.json").write_text(json.dumps(d)[:3000])
    urls = d.get("output_urls") or (d.get("result") or {}).get("output_urls") or []
    if urls:
        urllib.request.urlretrieve(urls[0], out / f"{name}_idle_sheet.png")
        print(name, "ok", sprite, side, (d.get("result") or {}).get("balance_cost"), flush=True); break
    print(name, "failed", (d.get("error") or {}).get("code"), flush=True); time.sleep(150)
