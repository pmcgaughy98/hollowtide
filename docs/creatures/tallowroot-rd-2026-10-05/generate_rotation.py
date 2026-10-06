"""Tallowroot 8-direction turnaround from front_pad_192.png, RD rotate ($0.10). Run from the repo root."""
import base64, json, sys, time, urllib.request
sys.path.insert(0, "tools/debug"); import rd_client
D = "docs/creatures/tallowroot-rd-2026-10-05/"
img = base64.b64encode(open(D + "front_pad_192.png", "rb").read()).decode()
args = {"prompt": "sturdy seed-burrower creature", "prompt_style": "rd_advanced_animation__rotate",
        "width": 192, "height": 192, "input_image": img, "return_spritesheet": True}
res = rd_client.call("tools/call", {"name": "start_inference_job", "arguments": args})
job = json.loads(res["result"]["content"][0]["text"]); tid = job.get("task_id") or job.get("id")
print("task", tid)
for _ in range(120):
    time.sleep(4)
    r = rd_client.call("tools/call", {"name": "get_inference_job", "arguments": {"task_id": tid}})
    d = json.loads(r["result"]["content"][0]["text"])
    if d.get("status") in ("succeeded", "failed"):
        break
open(D + "receipt_rotation.json", "w").write(json.dumps(d)[:4000])
print("status", d.get("status"))
urls = d.get("output_urls") or (d.get("result") or {}).get("output_urls") or []
for i, u in enumerate(urls):
    urllib.request.urlretrieve(u, D + f"rotation_3x3_{i}.png"); print("saved", i)
