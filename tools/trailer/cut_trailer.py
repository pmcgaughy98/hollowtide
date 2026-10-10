"""Cut the Hollowtide trailer from the real game (Claude, 2026-10-10; Preston: "make trailer for us").
  python tools/trailer/cut_trailer.py
Reads docs/trailer/raw.avi and docs/trailer/segments.txt (tools/trailer/record_trailer.gd, Godot's
Movie Maker at 30 fps), the title painting and the game's font, and writes docs/trailer/hollowtide_trailer.mp4.

Everything on screen is the game itself or its own art. The one generated test (a Higgsfield
image-to-video of the title painting) added torches, a campfire and new sign lettering that are not in
the painting, so camera moves here are done in code on the real art instead.

Pixel art is enlarged 2x pixel-for-pixel first and only then smoothed down to 1080p, so every pixel
stays the same size. The text-card lines are proposals; change LINES and run it again.
"""
import subprocess
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "docs" / "trailer"
WORK = OUT / "_work"
RAW = OUT / "raw.avi"
FONT = str(ROOT / "assets" / "fonts" / "AlegreyaSansSC-Bold.ttf")
FONT_LIGHT = str(ROOT / "assets" / "fonts" / "AlegreyaSansSC-Regular.ttf")
MUSIC = ROOT / "assets" / "audio" / "music" / "title.mp3"
PAINTING = ROOT / "assets" / "sprites" / "menu" / "creature_village_2026_10_09.png"
W, H, FPS = 1920, 1080, 30
MOSS = (20, 26, 21)
PARCHMENT = (255, 244, 232)
BRASS = (182, 155, 109)

LINES = {   # proposals for Preston
    "card1": "Beneath Highbank, the river keeps its Hollows.",
    "card2": "Gather a team. Fight as one.",
    "card3": "Grow together.",
    "card4": "Face what waits below.",
}
# (kind, name or text, start offset s, length s)
SHOTS = [
    ("painting", "open", 0, 5.0),
    ("card", "card1", 0, 2.8),
    ("seg", "town", 0, 3.6),
    ("seg", "explore", 2.0, 6.0),
    ("card", "card2", 0, 2.4),
    ("seg", "fight", 0, 4.3),
    ("seg", "party", 0, 5.0),
    ("card", "card3", 0, 2.4),
    ("seg", "evolution", 0, 7.4),
    ("card", "card4", 0, 2.4),
    ("seg", "boss", 0, 9.0),
    ("end", "end", 0, 5.5),
]


def run(args):
    subprocess.run(args, check=True, capture_output=True)


def segments():
    seg = {}
    for line in (OUT / "segments.txt").read_text().splitlines():
        p = line.split()
        if p and p[0] == "SEG":
            seg[p[1]] = (int(p[2]) / FPS, int(p[3]) / FPS)
    return seg


def card(text: str, path: Path, sub: str = ""):
    im = Image.new("RGB", (W, H), MOSS)
    d = ImageDraw.Draw(im)
    f = ImageFont.truetype(FONT, 72)
    tw = d.textlength(text, font=f)
    d.text(((W - tw) / 2, H / 2 - 60), text, font=f, fill=PARCHMENT)
    d.line([(W / 2 - 160, H / 2 + 40), (W / 2 + 160, H / 2 + 40)], fill=BRASS, width=3)
    if sub:
        fs = ImageFont.truetype(FONT_LIGHT, 40)
        sw = d.textlength(sub, font=fs)
        d.text(((W - sw) / 2, H / 2 + 70), sub, font=fs, fill=BRASS)
    im.save(path)


def end_card(path: Path):
    paint = Image.open(PAINTING).convert("RGB").resize((W, H), Image.NEAREST)
    dark = Image.blend(paint, Image.new("RGB", (W, H), MOSS), 0.62)
    d = ImageDraw.Draw(dark)
    f = ImageFont.truetype(FONT, 168)
    t = "HOLLOWTIDE"
    tw = d.textlength(t, font=f)
    for off in [(-4, 0), (4, 0), (0, -4), (0, 4), (0, 8)]:
        d.text(((W - tw) / 2 + off[0], H / 2 - 150 + off[1]), t, font=f, fill=(43, 33, 80))
    d.text(((W - tw) / 2, H / 2 - 150), t, font=f, fill=(244, 214, 150))
    fs = ImageFont.truetype(FONT_LIGHT, 48)
    s = "A mystery dungeon on the river.   In development."
    sw = d.textlength(s, font=fs)
    d.text(((W - sw) / 2, H / 2 + 70), s, font=fs, fill=PARCHMENT)
    dark.save(path)


def still_clip(png: Path, length: float, out: Path, push: bool = False):
    vf = f"fade=in:0:8,fade=out:st={length - 0.3}:d=0.3,format=yuv420p"
    if push:   # a slow push in on the real painting, done in code
        frames = int(length * FPS)
        vf = (f"scale=7680:4320:flags=neighbor,zoompan=z='1+0.06*on/{frames}':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d={frames}:s={W}x{H}:fps={FPS},"
              + vf)
    src = ["-i", str(png)] if push else ["-loop", "1", "-t", str(length), "-i", str(png)]   # zoompan makes its own frames
    run(["ffmpeg", "-y", *src, "-vf", vf, "-r", str(FPS), "-t", str(length),
         "-c:v", "libx264", "-crf", "16", "-preset", "medium", "-an", str(out)])


def game_clip(start: float, length: float, out: Path):
    vf = (f"scale=2304:1296:flags=neighbor,scale={W}:{H}:flags=lanczos,"
          f"fade=in:0:6,fade=out:st={length - 0.25}:d=0.25,format=yuv420p")
    run(["ffmpeg", "-y", "-ss", f"{start:.3f}", "-t", f"{length:.3f}", "-i", str(RAW), "-vf", vf, "-r", str(FPS),
         "-c:v", "libx264", "-crf", "16", "-preset", "medium", "-an", str(out)])


if __name__ == "__main__":
    WORK.mkdir(parents=True, exist_ok=True)
    seg = segments()
    parts = []
    total = 0.0
    for k, (kind, name, off, length) in enumerate(SHOTS):
        out = WORK / f"{k:02d}_{name}.mp4"
        if kind == "painting":
            png = WORK / "painting.png"
            Image.open(PAINTING).convert("RGB").resize((W, H), Image.NEAREST).save(png)
            still_clip(png, length, out, push=True)
        elif kind == "card":
            png = WORK / f"{name}.png"
            card(LINES[name], png)
            still_clip(png, length, out)
        elif kind == "end":
            png = WORK / "end.png"
            end_card(png)
            still_clip(png, length, out)
        else:
            a, b = seg[name]
            length = min(length, b - a - off)
            game_clip(a + off, length, out)
        parts.append(out)
        total += length
        print(f"{k:02d} {kind:8s} {name:10s} {length:4.1f} s")
    lst = WORK / "list.txt"
    lst.write_text("".join(f"file '{p.as_posix()}'\n" for p in parts))
    silent = WORK / "silent.mp4"
    run(["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", str(lst), "-c", "copy", str(silent)])
    final = OUT / "hollowtide_trailer.mp4"
    run(["ffmpeg", "-y", "-i", str(silent), "-i", str(MUSIC), "-map", "0:v", "-map", "1:a",
         "-af", f"afade=in:st=0:d=1.5,afade=out:st={total - 3.0:.2f}:d=3.0", "-t", f"{total:.2f}",
         "-c:v", "copy", "-c:a", "aac", "-b:a", "192k", str(final)])
    print(f"trailer: {final} ({total:.1f} s)")
