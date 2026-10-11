"""The second Hollowtide trailer (Claude, 2026-10-11; Preston: "make trailer again with higgsfield but use
synthesis to make it look as legit as possible from finished products so it doesn't look like A.I.").
  python tools/trailer/cut_trailer_v2.py
Writes docs/trailer/v2/hollowtide_trailer_v2.mp4 (and a smaller _share copy).

What finished trailers do, and how this follows it (structure only, nothing copied):
  - Gameplay before the logo; the logo comes last (Derek Lieu's trailers for Noita and others).
  - "Tell, show, repeat": a short title card, then footage that proves it, then the next idea.
  - Hard cuts on the music's bar lines, no novelty wipes; shots shorten as it builds.
  - Pixels stay square: every shot is the game's own frames, enlarged by whole numbers.
  - A cold open on the game's own sound, then the music comes in on the first card.
Every shot is the real game (docs/trailer/v2/raw.avi from tools/trailer/record_trailer.gd, and the scene
videos in docs/design/videos-2026-10-11/). The one generated shot is the closing title painting
(Higgsfield, Kling 3.0, the painting as its first and last frame), forced back onto the painting's
own 256x144 grid and its 23 colours, so nothing smooth or invented survives.
The card lines are proposals for Preston; change CARDS and run it again.
"""
import subprocess
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "docs" / "trailer" / "v2"
WORK = OUT / "_work"
VIDS = ROOT / "docs" / "design" / "videos-2026-10-11"
RAW = OUT / "raw.avi"
MUSIC = ROOT / "assets" / "audio" / "music" / "hollow_flute.mp3"   # "Hollow in the Cottonwoods"
PAINTING = ROOT / "assets" / "sprites" / "menu" / "creature_village_2026_10_09.png"
HF_CLIP = OUT / "hf" / "painting_kling.mp4"
JERSEY = str(ROOT / "assets" / "fonts" / "Jersey10-Regular.ttf")
LOGO_FONT = str(ROOT / "assets" / "fonts" / "AlegreyaSansSC-Bold.ttf")   # the title screen's wordmark face
W, H, FPS = 1920, 1080, 30
BPM = 106.0                 # measured from the song's onsets
BAR = 4 * 60.0 / BPM        # 2.264 s
PHASE = 0.34                # the first downbeat in the song
MOSS = (16, 21, 17)
PARCHMENT = (244, 232, 210)
BRASS = (190, 160, 108)

CARDS = {   # proposals for Preston
    "genre": "A mystery dungeon adventure",
    "explore": "Lead a team into the Hollows",
    "fight": "Every step is a turn. Fight side by side.",
    "town": "Run with the Wayline",
    "grow": "Grow together",
    "below": "Something waits below",
}

# (kind, source, start s, bars). "cold" shots keep the game's own sound and play before the music.
SHOTS = [
    ("cold", "01_storm_open", 1.6, 2),
    ("cold", "01_storm_open", 10.6, 2),
    ("card", "genre", 0, 1),
    ("clip", "01b_soul_arrives", 14.6, 1),
    ("clip", "02_flood_talk", 31.8, 1),
    ("clip", "03_ruin_rises", 0.6, 2),
    ("card", "explore", 0, 1),
    ("clip", "hollow", 3.0, 1),
    ("clip", "hollow", 24.3, 1),
    ("card", "fight", 0, 1),
    ("clip", "hollow", 28.3, 2),
    ("card", "town", 0, 1),
    ("clip", "04_job_board_theft", 43.0, 1),
    ("clip", "05_guild_trial_and_runners", 83.0, 1),
    ("clip", "06_roll_call", 34.0, 1),
    ("card", "grow", 0, 1),
    ("clip", "09_evolution", 1.4, 2),
    ("card", "below", 0, 1),
    ("clip", "07_warden_entrance", 51.6, 2),
    ("clip", "07_warden_entrance", 62.0, 1),
    ("end", "end", 0, 3),
]


def run(args):
    subprocess.run(args, check=True, capture_output=True)


def src(name: str) -> Path:
    if name == "hollow":   # The Hollow, the Warden's dungeon (Preston, 2026-10-11), tools/trailer/record_hollow_v2.gd
        return OUT / "hollow.avi"
    return RAW if name == "raw" else VIDS / f"{name}.mp4"


# The game draws at 384x216 and shows it at 3x (1152x648). 5x nearest then a 1/3 area step lands every game
# pixel on exactly 5x5 screen pixels at 1080p.
SHARP = f"scale=5760:3240:flags=neighbor,scale={W}:{H}:flags=area,setsar=1,fps={FPS},format=yuv420p"


def game_clip(name: str, start: float, length: float, out: Path, keep_audio: bool):
    a = ["-c:a", "aac", "-ar", "44100", "-ac", "2"] if keep_audio else ["-an"]
    run(["ffmpeg", "-y", "-ss", f"{start:.3f}", "-t", f"{length:.3f}", "-i", str(src(name)), "-vf", SHARP,
         "-c:v", "libx264", "-crf", "16", "-preset", "medium", *a, str(out)])


def pixel_text(text: str, size_px: int, scale: int, color) -> Image.Image:
    """Text drawn without smoothing at its native size, then enlarged by a whole number (square pixels)."""
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
    # a short brass rule under the line, on the same 5 px grid
    y = (H + t.height) // 2 + 30
    ImageDraw.Draw(img).rectangle([W // 2 - 60, y, W // 2 + 59, y + 4], fill=BRASS)
    img.save(path)


def still_clip(png: Path, length: float, out: Path):
    run(["ffmpeg", "-y", "-loop", "1", "-t", f"{length:.3f}", "-i", str(png), "-vf", f"fps={FPS},format=yuv420p",
         "-c:v", "libx264", "-crf", "16", "-an", str(out)])


def snapped_painting_frames(length: float) -> Path:
    """The Higgsfield clip put back on the painting's grid: each frame averaged down to 256x144, every pixel
    mapped to the nearest of the painting's own colours, and kept as the painting unless it really moved."""
    frames = WORK / "hf_frames"
    frames.mkdir(parents=True, exist_ok=True)
    for f in frames.glob("*.png"):
        f.unlink()
    run(["ffmpeg", "-y", "-i", str(HF_CLIP), "-t", f"{length:.3f}", "-vf", f"fps={FPS},scale=256:144:flags=area",
         str(frames / "f%04d.png")])
    base = np.asarray(Image.open(PAINTING).convert("RGB"), np.int32)
    pal = np.unique(base.reshape(-1, 3), axis=0)
    out = WORK / "hf_snapped"
    out.mkdir(exist_ok=True)
    for f in out.glob("*.png"):
        f.unlink()
    files = sorted(frames.glob("f*.png"))
    clip = [np.asarray(Image.open(f).convert("RGB"), np.int32) for f in files]
    # Where the clip moves steadily (the willows, the lanterns) motion is allowed; everywhere else stays the
    # exact painting, so compression speckle on edges never flickers.
    rate = np.mean([np.abs(a - base).sum(-1) > 70 for a in clip], axis=0)
    zone = rate > 0.2
    zone = zone | np.roll(zone, 1, 0) | np.roll(zone, -1, 0) | np.roll(zone, 1, 1) | np.roll(zone, -1, 1)
    for i, a in enumerate(clip):
        d = ((a[:, :, None, :] - pal[None, None, :, :]) ** 2).sum(-1)
        snap = pal[d.argmin(-1)]
        moved = zone & (np.abs(a - base).sum(-1) > 70)
        frame = np.where(moved[:, :, None], snap, base).astype(np.uint8)
        Image.fromarray(frame).resize((W, H), Image.NEAREST).save(out / f"s{i:04d}.png")
    return out


def end_clip(length: float, out: Path):
    snapped = snapped_painting_frames(length) if HF_CLIP.exists() else None
    logo = WORK / "logo.png"
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    font = ImageFont.truetype(LOGO_FONT, 150)
    text = "HOLLOWTIDE"
    tw = d.textlength(text, font=font)
    d.rectangle([0, 360, W, 700], fill=(10, 14, 11, 150))
    d.text(((W - tw) / 2 + 5, 395), text, font=font, fill=(0, 0, 0, 200))
    d.text(((W - tw) / 2, 390), text, font=font, fill=BRASS + (255,))
    sub = pixel_text("In development", 20, 3, PARCHMENT)
    img.alpha_composite(sub, ((W - sub.width) // 2, 600))
    img.save(logo)
    if snapped is not None:
        base = ["-framerate", str(FPS), "-i", str(snapped / "s%04d.png")]
    else:
        still = WORK / "painting_still.png"
        Image.open(PAINTING).convert("RGB").resize((W, H), Image.NEAREST).save(still)
        base = ["-loop", "1", "-t", f"{length:.3f}", "-i", str(still)]
    fade = f"fade=t=in:st=0.6:d=0.8:alpha=1"
    run(["ffmpeg", "-y", *base, "-loop", "1", "-t", f"{length:.3f}", "-i", str(logo), "-filter_complex",
         f"[1:v]format=rgba,{fade}[l];[0:v][l]overlay=0:0,fade=t=out:st={length - 1.0:.3f}:d=1.0,fps={FPS},format=yuv420p",
         "-t", f"{length:.3f}", "-c:v", "libx264", "-crf", "16", "-an", str(out)])


def main():
    WORK.mkdir(parents=True, exist_ok=True)
    parts = []
    cold_len = 0.0
    for i, (kind, name, start, bars) in enumerate(SHOTS):
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
    # Video: every shot back to back.
    lst = WORK / "list.txt"
    lst.write_text("".join(f"file '{p.as_posix()}'\n" for p in parts))
    silent = WORK / "video.mp4"
    run(["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", str(lst), "-map", "0:v", "-c:v", "libx264",
         "-crf", "16", "-preset", "medium", "-r", str(FPS), str(silent)])
    total = sum(b for *_, b in SHOTS) * BAR
    # Sound: the cold open keeps the storm's own audio; the music comes in so its first downbeat lands on the
    # genre card; the last bars fade with the picture.
    cold_audio = WORK / "cold.wav"
    run(["ffmpeg", "-y", "-i", str(WORK / "shot00.mp4"), "-i", str(WORK / "shot01.mp4"), "-filter_complex",
         "[0:a][1:a]concat=n=2:v=0:a=1[a]", "-map", "[a]", "-ar", "44100", "-ac", "2", str(cold_audio)])
    delay_ms = int((cold_len - PHASE) * 1000)
    final = OUT / "hollowtide_trailer_v2.mp4"
    run(["ffmpeg", "-y", "-i", str(silent), "-i", str(cold_audio), "-i", str(MUSIC), "-filter_complex",
         f"[1:a]afade=t=out:st={cold_len - 0.6:.3f}:d=0.9,apad[c];"
         f"[2:a]adelay={delay_ms}|{delay_ms},afade=t=out:st={total - 2.2:.3f}:d=2.2[m];"
         f"[c][m]amix=inputs=2:normalize=0,atrim=0:{total:.3f},loudnorm=I=-18:TP=-2:LRA=11[a]",
         "-map", "0:v", "-map", "[a]", "-c:v", "copy", "-c:a", "aac", "-b:a", "192k", "-ar", "48000",
         "-t", f"{total:.3f}", str(final)])
    share = OUT / "hollowtide_trailer_v2_share.mp4"
    run(["ffmpeg", "-y", "-i", str(final), "-c:v", "libx264", "-crf", "24", "-preset", "slow", "-c:a", "copy",
         str(share)])
    print(f"wrote {final} ({total:.1f} s) and {share}")


if __name__ == "__main__":
    main()
