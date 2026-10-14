"""V4 pitch edit, Codex2026-10-14, derived from Claude's preserved V3 cutter.
Reads the measured V4 segment/shot markers, not V3 timings. Nine current engine segments,
with archival storm/ruin/V2 combat cutaways; exact inputs/edits recorded beside the outputs.
Same proposed cards, bar-line edit, fonts, existing title painting and hollow_flute music.
Use HT_PITCH_ROOT/OUT/RAW/MARKERS for an isolated work output; defaults target docs/trailer/v4/full.
"""
import re
import os
import json
import subprocess
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(os.environ.get("HT_PITCH_ROOT", Path(__file__).resolve().parents[2]))
OUT = Path(os.environ.get("HT_PITCH_OUT", ROOT / "docs" / "trailer" / "v4" / "full"))
WORK = OUT / "_work"
RAW = Path(os.environ.get("HT_PITCH_RAW", OUT / "raw.avi"))
SEGS = Path(os.environ.get("HT_PITCH_MARKERS", OUT / "shot-markers.json"))
COMMANDS = []
EDIT = []
_PROBES = {}
VIDS = ROOT / "docs" / "design" / "videos-2026-10-11"
V2_HOLLOW = ROOT / "docs" / "trailer" / "v2" / "hollow.avi"
MUSIC = ROOT / "assets" / "audio" / "music" / "hollow_flute.mp3"   # "Hollow in the Cottonwoods", 102.8 s
PAINTING = ROOT / "assets" / "sprites" / "menu" / "creature_village_2026_10_09.png"
JERSEY = str(ROOT / "assets" / "fonts" / "Jersey10-Regular.ttf")
LOGO_FONT = str(ROOT / "assets" / "fonts" / "AlegreyaSansSC-Bold.ttf")
W, H, FPS = 1920, 1080, 30
BPM = 106.0
BAR = 4 * 60.0 / BPM        # 2.264 s
PHASE = 0.34                # the first downbeat in the song (measured for v2)
MOSS = (16, 21, 17)
PARCHMENT = (244, 232, 210)
BRASS = (190, 160, 108)

CARDS = {   # proposals for Preston
    "river": "A courier guild on a flooded river",
    "mail": "Carry the mail",
    "turn": "Every step is a turn. The lantern is the clock.",
    "home": "Go down. Come home.",
    "grow": "Grow together",
    "below": "Something waits below",
}

# (kind, source, start s, bars). "cold" shots keep the game's own sound and play before the music.
# A source "seg:<name>" is a segment of raw.avi; its start is seconds into that segment.
SHOTS = [
    ("cold", "01_storm_open", 1.6, 2),
    ("card", "river", 0, 1),
    ("clip", "mark:flood_partner", 0.15, 1),
    ("clip", "03_ruin_rises", 0.6, 1),
    ("clip", "seg:title_continue", 0.0, 1),
    ("clip", "seg:title_continue", 4.4, 1),
    ("card", "mail", 0, 1),
    ("clip", "mark:mail_early", 0.2, 3),
    ("clip", "seg:mail_call", 24.0, 2),
    ("clip", "mark:board_parcel", 0.4, 2),
    ("card", "turn", 0, 1),
    ("clip", "mark:water_rows_1", 0.2, 2),
    ("clip", "mark:water_rows_2", 0.2, 2),
    ("clip", "v2hollow", 28.3, 2),
    ("card", "home", 0, 1),
    ("clip", "seg:faint", 0.8, 1),
    ("clip", "mark:faint_information", 0.2, 2),
    ("clip", "mark:storage_shelves", 0.1, 2),
    ("clip", "mark:storage_deposit", 0.1, 1),
    ("clip", "mark:storage_withdraw", 0.1, 1),
    ("card", "grow", 0, 1),
    ("clip", "seg:growth", 0.5, 3),
    ("card", "below", 0, 1),
    ("clip", "seg:standoff", 1.0, 2),
    ("clip", "mark:standoff_starward", 0.3, 3),
    ("clip", "mark:stone_rises", 0.0, 1),
    ("end", "end", 0, 3),
]


def run(args):
    COMMANDS.append(args)
    WORK.mkdir(parents=True,exist_ok=True)
    (OUT / "edit-commands.json").write_text(json.dumps(COMMANDS,indent=2),encoding="utf-8")
    subprocess.run(args, check=True, capture_output=True, timeout=180)

def metadata():
    return json.loads(SEGS.read_text(encoding="utf-8"))

def segments():
    return {s["name"]:(s["first"],s["last"]) for s in metadata()["segments"]}

def source(name: str, start: float, length: float = 0):
    if name.startswith("seg:"):
        a,b=segments()[name[4:]]
        at=a/FPS+start
        assert at+length <= b/FPS+0.001,(name,start,length,(b-a)/FPS)
        return RAW,at
    if name.startswith("mark:"):
        frame=next(m["frame"] for m in metadata()["markers"] if m["name"]==name[5:])
        a,b=next((a,b) for a,b in segments().values() if a<=frame<b)
        at=frame/FPS+start
        assert at+length<=b/FPS+0.001,(name,at,length,b/FPS)
        return RAW,at
    path=V2_HOLLOW if name=="v2hollow" else VIDS/f"{name}.mp4"
    assert path.is_file(),path
    return path,start


# The game draws at 384x216 and shows it at 3x (1152x648). 5x nearest then a 1/3 area step lands every game
# pixel on exactly 5x5 screen pixels at 1080p.
SHARP = f"scale=5760:3240:flags=neighbor,scale={W}:{H}:flags=area,setsar=1,fps={FPS},format=yuv420p"


def game_clip(name: str, start: float, length: float, out: Path, keep_audio: bool):
    path, at = source(name, start, length)
    EDIT.append({"name":name,"path":str(path),"source_start_seconds":at,"length_seconds":length,"keep_audio":keep_audio})
    a = ["-c:a", "aac", "-ar", "44100", "-ac", "2"] if keep_audio else ["-an"]
    run(["ffmpeg", "-y", "-ss", f"{at:.3f}", "-t", f"{length:.3f}", "-i", str(path), "-vf", SHARP,
         "-c:v", "libx264", "-threads", "4", "-crf", "16", "-preset", "medium", *a, str(out)])


def pixel_text(text: str, size_px: int, scale: int, color) -> Image.Image:
    font = ImageFont.truetype(JERSEY, size_px)
    box = font.getbbox(text)
    img = Image.new("L", (box[2] - box[0] + 2, box[3] - box[1] + 2), 0)
    d = ImageDraw.Draw(img)
    d.fontmode = "1"
    d.text((1 - box[0], 1 - box[1]), text, font=font, fill=255)
    img = img.resize((img.width * scale, img.height * scale), Image.NEAREST)
    out = Image.new("RGBA", img.size, color + (0,))
    out.putalpha(img)
    return out


def card_png(text: str, path: Path):
    img = Image.new("RGB", (W, H), MOSS)
    t = pixel_text(text, 20, 5, PARCHMENT)
    if t.width > W - 160:
        t = pixel_text(text, 20, 4, PARCHMENT)
    img.paste(t, ((W - t.width) // 2, (H - t.height) // 2), t)
    y = (H + t.height) // 2 + 30
    ImageDraw.Draw(img).rectangle([W // 2 - 60, y, W // 2 + 59, y + 4], fill=BRASS)
    img.save(path)


def still_clip(png: Path, length: float, out: Path):
    run(["ffmpeg", "-y", "-loop", "1", "-t", f"{length:.3f}", "-i", str(png), "-vf", f"fps={FPS},format=yuv420p",
         "-c:v", "libx264", "-threads", "4", "-crf", "16", "-an", str(out)])


def end_clip(length: float, out: Path):
    logo = WORK / "logo.png"
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    font = ImageFont.truetype(LOGO_FONT, 150)
    text = "HOLLOWTIDE"
    tw = d.textlength(text, font=font)
    d.rectangle([0, 360, W, 700], fill=(10, 14, 11, 150))
    d.text(((W - tw) / 2 + 5, 395), text, font=font, fill=(0, 0, 0, 200))
    d.text(((W - tw) / 2, 390), text, font=font, fill=BRASS + (255,))
    sub = pixel_text("A playable slice, in development", 20, 3, PARCHMENT)
    img.alpha_composite(sub, ((W - sub.width) // 2, 600))
    img.save(logo)
    still = WORK / "painting_still.png"
    Image.open(PAINTING).convert("RGB").resize((W, H), Image.NEAREST).save(still)
    run(["ffmpeg", "-y", "-loop", "1", "-t", f"{length:.3f}", "-i", str(still), "-loop", "1", "-t", f"{length:.3f}",
         "-i", str(logo), "-filter_complex",
         f"[1:v]format=rgba,fade=t=in:st=0.6:d=0.8:alpha=1[l];[0:v][l]overlay=0:0,fade=t=out:st={length - 1.0:.3f}:d=1.0,fps={FPS},format=yuv420p",
         "-t", f"{length:.3f}", "-c:v", "libx264", "-threads", "4", "-crf", "16", "-an", str(out)])


def main():
    assert not (OUT / "hollowtide_pitch_v4.mp4").exists() and not (OUT / "hollowtide_pitch_v4_share.mp4").exists(), "Choose a fresh output folder; preserve the previous edit."
    WORK.mkdir(parents=True, exist_ok=True)
    parts = []
    cold_len = 0.0
    for i, (kind, name, start, bars) in enumerate(SHOTS):
        print(f"SHOT {i+1}/{len(SHOTS)} {name}",flush=True)
        length = bars * BAR
        out = WORK / f"shot{i:02d}.mp4"
        if kind == "cold":
            game_clip(name, start, length, out, keep_audio=True)
            cold_len += length
        elif kind == "clip":
            game_clip(name, start, length, out, keep_audio=False)
        elif kind == "card":
            png = WORK / f"card_{name}.png"
            card_png(CARDS[name], png)
            still_clip(png, length, out)
        else:
            end_clip(length, out)
        parts.append(out)
    lst = WORK / "list.txt"
    lst.write_text("".join(f"file '{p.as_posix()}'\n" for p in parts))
    silent = WORK / "video.mp4"
    run(["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", str(lst), "-map", "0:v", "-c:v", "libx264", "-threads", "4",
         "-crf", "16", "-preset", "medium", "-r", str(FPS), str(silent)])
    total = sum(b for *_, b in SHOTS) * BAR
    cold_audio = WORK / "cold.wav"
    run(["ffmpeg", "-y", "-i", str(WORK / "shot00.mp4"), "-map", "0:a", "-ar", "44100", "-ac", "2", str(cold_audio)])
    delay_ms = int((cold_len - PHASE) * 1000)
    final = OUT / "hollowtide_pitch_v4.mp4"
    run(["ffmpeg", "-y", "-i", str(silent), "-i", str(cold_audio), "-i", str(MUSIC), "-filter_complex",
         f"[1:a]afade=t=out:st={cold_len - 0.6:.3f}:d=0.9,apad[c];"
         f"[2:a]adelay={delay_ms}|{delay_ms},afade=t=out:st={total - 2.2:.3f}:d=2.2[m];"
         f"[c][m]amix=inputs=2:normalize=0,atrim=0:{total:.3f},loudnorm=I=-18:TP=-2:LRA=11[a]",
         "-map", "0:v", "-map", "[a]", "-c:v", "copy", "-c:a", "aac", "-b:a", "192k", "-ar", "48000",
         "-t", f"{total:.3f}", str(final)])
    share = OUT / "hollowtide_pitch_v4_share.mp4"
    run(["ffmpeg", "-y", "-i", str(final), "-c:v", "libx264", "-threads", "4", "-crf", "24", "-preset", "medium", "-c:a", "copy", str(share)])
    (OUT / "edit-timeline.json").write_text(json.dumps({"planned_seconds":total,"fps":FPS,"bars":sum(b for *_,b in SHOTS),"shots":SHOTS,"resolved_clips":EDIT},indent=2),encoding="utf-8")
    print(f"wrote {final} ({total:.1f} s) and {share}")


if __name__ == "__main__":
    main()
