"""Stormlantern art, Retro Diffusion (Claude, 2026-10-05). Run from the repo root.
Two 16-frame VFX sheets ($0.07 each) and the signature stage painting (RD Pro)."""
import json, sys, time, urllib.request
sys.path.insert(0, "tools/debug"); import rd_client
D = "docs/battle/stormlantern-2026-10-05/"
def tool(n, a):
    r = rd_client.call("tools/call", {"name": n, "arguments": a}); return json.loads(r["result"]["content"][0]["text"])
def job(name, args):
    for attempt in range(5):
        t = tool("start_inference_job", args); tid = t.get("task_id") or t.get("id")
        for _ in range(120):
            time.sleep(4); d = tool("get_inference_job", {"task_id": tid})
            if d.get("status") in ("succeeded", "failed"): break
        urls = d.get("output_urls") or (d.get("result") or {}).get("output_urls") or []
        open(D + name + "_receipt.json", "w").write(json.dumps(d)[:3000])
        if urls:
            for i, u in enumerate(urls): urllib.request.urlretrieve(u, D + f"{name}_{i}.png")
            print(name, "ok", (d.get("result") or {}).get("balance_cost")); return
        print(name, "failed", (d.get("error") or {}).get("code")); time.sleep(120)
VFX = {"prompt_style": "rd_animation__vfx", "width": 96, "height": 96, "frames_duration": 16, "return_spritesheet": True}
job("orb_vfx", {**VFX, "prompt": "a glowing sphere of white-gold fire wrapped in crackling pale yellow lightning arcs, pulsing with energy, small embers swirling around it"})
job("impact_vfx", {**VFX, "prompt": "a huge explosion of orange fire and crackling yellow-white lightning bursting outward, electric arcs spreading in every direction, glowing embers flying"})
job("stage", {"prompt_style": "rd_pro__default", "width": 256, "height": 144, "num_images": 1,
    "prompt": "A battle arena scene: an old river ferry landing at night under a violent thunderstorm, dark purple-grey storm clouds lit from inside by branching yellow lightning, rain streaks, a few amber signal lanterns glowing on weathered wooden posts along the dock, the wide dark river behind, and flat empty muddy ground across the foreground and middle for two creatures to stand on. Wide side view, no creatures, no people."})
print(tool("get_balance", {}))
