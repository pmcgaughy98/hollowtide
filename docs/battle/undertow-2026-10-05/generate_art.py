"""Undertow art, Retro Diffusion (Claude, 2026-10-05). Run from the repo root.
The signature stage (RD Pro, $0.18) and Scourmaw erupting jaws-first from the water,
two takes with Scourmaw's front as the reference ($0.36)."""
import json, sys, time, urllib.request
sys.path.insert(0, "tools/debug"); import rd_client, rd_creature
D = "docs/battle/undertow-2026-10-05/"
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
            print(name, "ok", (d.get("result") or {}).get("balance_cost"), flush=True); return
        print(name, "failed", (d.get("error") or {}).get("code"), flush=True); time.sleep(120)
job("stage", {"prompt_style": "rd_pro__default", "width": 256, "height": 144, "num_images": 1,
    "prompt": "A battle arena scene: a wide flooded river shallows at night under a heavy moon, dark blue-green water covering the whole foreground and middle as a flat calm surface for two creatures to stand in, faint ghostly pale mist drifting over the water, old broken wooden pilings and a sunken rowboat, a dark muddy far bank with drowned trees. Wide side view, no creatures, no people."})
rd_creature.front(D, "eruption", 96, 2,
    "The giant armoured river catfish monster from the reference image bursting straight up out of dark river water, seen from the side: its huge armoured head and the front of its body rising vertically out of a churning splash, its enormous dredge-scoop jaw gaping wide open upward with rows of teeth, thick barbels whipping, water, silt and pebbles cascading off its stone-scoured armour plates, a ring of white foam and spray at the waterline. Same colours as the reference. On a plain white background.",
    ["assets/sprites/creatures/rimefin_catfish_2026_10_05/scourmaw_front.png"])
print(tool("get_balance", {}), flush=True)
