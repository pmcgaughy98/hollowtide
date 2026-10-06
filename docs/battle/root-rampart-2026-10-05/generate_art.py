"""Root Rampart art, Retro Diffusion (Claude, 2026-10-05). Run from the repo root.
Two 16-frame root-eruption VFX takes ($0.07 each), the signature stage (RD Pro, $0.18)
and two pose edits of Rampartroot ($0.18 each). Retries busy errors; never re-sends a charged job."""
import base64, io, json, sys, time, urllib.request
from PIL import Image
sys.path.insert(0, "tools/debug"); import rd_client, rd_creature
D = "docs/battle/root-rampart-2026-10-05/"
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
VFX = {"prompt_style": "rd_animation__vfx", "width": 96, "height": 96, "frames_duration": 16, "return_spritesheet": True}
job("roots_a", {**VFX, "prompt": "giant thick twisted brown roots and sharp seed-husk spikes bursting violently up out of cracked earth, rocks and dirt clods flying, green leaves scattering"})
job("roots_b", {**VFX, "prompt": "a towering eruption of huge gnarled tree roots and jagged stone shards tearing up out of the ground in a tall column, dirt and leaves exploding outward"})
job("stage", {"prompt_style": "rd_pro__default", "width": 256, "height": 144, "num_images": 1,
    "prompt": "A battle arena scene: an ancient overgrown floodplain forest at golden dusk, an old broken stone levee wall split apart by enormous mossy tree roots, giant cottonwood trunks, ferns and moss, shafts of warm light and floating seeds in the air, and flat open earth across the foreground and middle for two creatures to stand on. Wide side view, no creatures, no people."})
F = "assets/sprites/creatures/tallowroot_2026_10_05/tallowroot3_front.png"
KEEP = " Keep the same creature, colours, armour plates, horns, collar, vine and seed-pod tail club, same size, and the same position of its back feet."
rd_creature.edit(F, D + "pose_raise_raw.png", "Change only the pose: the same armoured creature rears up high on its hind legs, front legs lifted, head raised and roaring, its heavy seed-pod tail club swung high up over its back ready to slam down, the green shoot on its shoulder glowing and straining upward." + KEEP)
rd_creature.edit(F, D + "pose_slam_raw.png", "Change only the pose: the same armoured creature crashes back down onto all fours, front feet slamming the ground, its heavy seed-pod tail club smashed down into the earth beside it with cracks and dirt flying, its shoulder shoot plunging down into the ground like a root, head low and forward bellowing." + KEEP)
print(tool("get_balance", {}), flush=True)
