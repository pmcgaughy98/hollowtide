"""Retro Diffusion creature art, the way the Hollowtide lines are made.

  python tools/debug/rd_creature.py front <out_dir> <name> <size> <takes> "<prompt>" [ref.png ...]
      rd_pro__default front takes (remove_bg), saved as <name>_front_takeN.png,
      with the prompt and receipt next to them. The refs are style/previous-stage
      references. Cost: $0.18 a take.
  python tools/debug/rd_creature.py rotate <out_dir> <name> <front.png>
      Pads the front onto a square canvas (front size + 32), runs the
      8-direction rotation and saves <name>_pad.png and <name>_rotation_3x3.png.
      Cost: $0.10.
  python tools/debug/rd_creature.py estimate <size> <takes>

Every paid call writes a receipt. A failed or lost call is never re-sent here:
check list_inference_jobs first (see the handoff's lessons).
"""
import base64, json, pathlib, sys, time, urllib.request
sys.path.insert(0, str(pathlib.Path(__file__).parent))
import rd_client
from PIL import Image


def _b64(path):
    return base64.b64encode(open(path, "rb").read()).decode()


def _tool(name, args):
    res = rd_client.call("tools/call", {"name": name, "arguments": args})
    return json.loads(res["result"]["content"][0]["text"])


def _recover():
    """A long synchronous call can drop while the server keeps the paid job.
    Wait on the newest running job instead of sending the request again."""
    time.sleep(5)
    jobs = _tool("list_inference_jobs", {"limit": 3})["tasks"]
    job = next((j for j in jobs if j["status"] in ("running", "pending")), jobs[0])
    for _ in range(120):
        d = _tool("get_inference_job", {"task_id": job["task_id"]})
        if d.get("status") in ("succeeded", "failed"):
            break
        time.sleep(5)
    result = d.get("result") or {}
    return {"output_urls": d.get("output_urls") or result.get("output_urls") or [],
            "balance_cost": result.get("balance_cost"), "recovered_task": job["task_id"]}


def front(out, name, size, takes, prompt, refs):
    out = pathlib.Path(out); out.mkdir(parents=True, exist_ok=True)
    args = {"prompt": prompt, "prompt_style": "rd_pro__default", "width": size, "height": size,
            "num_images": takes, "remove_bg": True}
    if refs:
        args["reference_images"] = [_b64(r) for r in refs]
    (out / f"{name}_prompt.json").write_text(json.dumps({**args, "reference_images": refs}, indent=1))
    try:
        d = _tool("create_inference", args)
    except (json.JSONDecodeError, KeyError, TypeError):
        d = _recover()  # the call dropped, but the paid job is still running on the server
    (out / f"{name}_receipt.json").write_text(json.dumps({k: v for k, v in d.items() if k != "base64_images"})[:4000])
    for i, url in enumerate(d.get("output_urls", [])):
        urllib.request.urlretrieve(url, out / f"{name}_front_take{i + 1}.png")
    print(name, "takes", len(d.get("output_urls", [])), "cost", d.get("balance_cost"), "balance", d.get("remaining_balance"))


def rotate(out, name, front_png):
    out = pathlib.Path(out)
    f = Image.open(front_png).convert("RGBA")
    side = max(f.size) + 32
    pad = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    pad.alpha_composite(f, ((side - f.width) // 2, (side - f.height) // 2))
    pad.save(out / f"{name}_pad.png")
    args = {"prompt": "", "prompt_style": "rd_advanced_animation__rotate", "width": side, "height": side,
            "input_image": _b64(out / f"{name}_pad.png"), "return_spritesheet": True}
    job = _tool("start_inference_job", args)
    tid = job.get("task_id") or job.get("id")
    for _ in range(150):
        time.sleep(4)
        d = _tool("get_inference_job", {"task_id": tid})
        if d.get("status") in ("succeeded", "failed"):
            break
    (out / f"{name}_rotation_receipt.json").write_text(json.dumps(d)[:4000])
    urls = d.get("output_urls") or (d.get("result") or {}).get("output_urls") or []
    if urls:
        urllib.request.urlretrieve(urls[0], out / f"{name}_rotation_3x3.png")
    print(name, "rotation", d.get("status"), "task", tid)


def edit(in_png, out_png, prompt):
    """RD image_edit ($0.18): repaint part of an image from a prompt. Saves the whole result;
    paste back only the region you meant to change if anything else drifted."""
    import io
    d = _tool("run_edit_tool", {"tool_id": "image_edit", "input_image": _b64(in_png), "prompt": prompt})
    raw = (d.get("base64_images") or [None])[0]
    if raw is None and d.get("output_urls"):
        raw = base64.b64encode(urllib.request.urlopen(d["output_urls"][0]).read()).decode()
    img = Image.open(io.BytesIO(base64.b64decode(raw.split(",")[-1]))).convert("RGBA")
    src = Image.open(in_png)
    if img.size != src.size:
        img = img.resize(src.size, Image.NEAREST)
    img.save(out_png)
    pathlib.Path(out_png).with_suffix(".prompt.txt").write_text(prompt)
    print("edited", out_png, "cost", d.get("balance_cost"), "balance", d.get("remaining_balance"))


if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "edit":
        edit(sys.argv[2], sys.argv[3], sys.argv[4])
    elif cmd == "front":
        front(sys.argv[2], sys.argv[3], int(sys.argv[4]), int(sys.argv[5]), sys.argv[6], sys.argv[7:])
    elif cmd == "rotate":
        rotate(sys.argv[2], sys.argv[3], sys.argv[4])
    elif cmd == "estimate":
        d = _tool("estimate_inference_cost", {"prompt": "x", "prompt_style": "rd_pro__default",
                  "width": int(sys.argv[2]), "height": int(sys.argv[2]), "num_images": int(sys.argv[3])})
        print("cost", d.get("balance_cost"), "balance", d.get("remaining_balance"))
