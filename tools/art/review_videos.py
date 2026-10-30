"""Creature review videos (Claude, 2026-10-28; Preston: "make short video thatd show me what I need for each one to see
any issues so I can list them for you for all animations views and other things").

Records scenes/debug/creature_review.tscn with Godot's Movie Maker, one creature per run, and turns each recording into
a small mp4. A Godot window opens for a few seconds per creature. The run uses its own APPDATA, so no save or settings
file of Preston's is read or written; their hashes are compared before and after to prove it.

  python tools/art/review_videos.py [name ...] [--out=DIR]
"""
import hashlib
import os
import subprocess
import sys
import tempfile
from pathlib import Path

GODOT = "C:/Users/pmcga/Games/Tools/Godot_v4.7.2/Godot_v4.7.2-stable_win64_console.exe"
ART = Path("assets/sprites/arena")
OUT = Path.home() / "OneDrive/Desktop/Preston Hub/06 Creative Projects/Hollowtide/Creature review videos 2026-10-28"
USER = Path(os.environ["APPDATA"]) / "Godot/app_userdata"


def guarded():
    """Hashes of Preston's own save and settings files, to show the run left them alone."""
    out = {}
    for p in USER.rglob("*"):
        if p.is_file() and (p.name.startswith("team.save") or p.name in ("menu_preferences.cfg", "game_prefs.cfg")):
            out[str(p)] = hashlib.sha256(p.read_bytes()).hexdigest()
    return out


def record(name, out_dir, scratch):
    avi = scratch / f"{name}.avi"
    env = dict(os.environ, APPDATA=str(scratch / "appdata"))
    run = subprocess.run([GODOT, "--path", ".", "--resolution", "1152x648", "--write-movie", str(avi), "--fixed-fps", "30",
                          "res://scenes/debug/creature_review.tscn", "--", f"--forms={name}"],
                         env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=600)
    errors = [l for l in run.stdout.splitlines() + run.stderr.splitlines() if "ERROR" in l or "SCRIPT ERROR" in l]
    if not avi.exists():
        return f"{name}: no recording\n" + "\n".join(errors[:10])
    mp4 = out_dir / f"{name}.mp4"
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(avi), "-an", "-c:v", "libx264", "-preset", "slow",
                    "-crf", "20", "-pix_fmt", "yuv420p", "-movflags", "+faststart", str(mp4)], check=True)
    avi.unlink()
    return f"{name}: {mp4.stat().st_size // 1024} KB" + ("".join("\n  " + e for e in errors[:5]) if errors else "")


def main():
    names = [a for a in sys.argv[1:] if not a.startswith("--")] or sorted(
        p.name for p in ART.iterdir() if (p / "dungeon" / "walk_s_f0.png").exists())
    out_dir = Path(next((a.split("=", 1)[1] for a in sys.argv[1:] if a.startswith("--out=")), OUT))
    out_dir.mkdir(parents=True, exist_ok=True)
    before = guarded()
    # Godot plays its imported copies of the pictures, so frames rewritten since the last import would show as the old ones.
    subprocess.run([GODOT, "--headless", "--path", ".", "--import"], capture_output=True, timeout=600)
    with tempfile.TemporaryDirectory() as tmp:
        scratch = Path(tmp)
        for name in names:
            print(record(name, out_dir, scratch), flush=True)
    after = guarded()
    print("Preston's save and settings files unchanged:", before == after, f"({len(before)} files)")


if __name__ == "__main__":
    main()
