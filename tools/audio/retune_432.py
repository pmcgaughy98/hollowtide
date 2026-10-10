"""Install Preston's Suno songs and retune all of Hollowtide's audio to A = 432 Hz (Claude, 2026-10-09;
Preston: "make everything 432 hz including everything we have in the game already sound wise").

  python tools/audio/retune_432.py install   copies the songs from Downloads into assets/audio/music
                                             under the music brief's file names
  python tools/audio/retune_432.py retune    retunes every .wav/.ogg/.mp3 under assets/audio

Retuning is a pitch shift of 432/440 (about a third of a semitone down) with ffmpeg's rubberband
filter, which keeps the tempo and length, so loops and timings in the game do not move. The 440 Hz
originals are copied once to assets/audio/_440hz_originals/ (which Godot ignores) and every run
re-reads them, so running it twice never shifts twice. A file already retuned is listed in
assets/audio/_440hz_originals/retuned.txt and skipped.

WARNING (2026-10-09): everything in the game before Preston's Suno songs was ALREADY at 432 (the
music by tools/retune_432.sh on 2026-10-06, the sound effects by their build scripts and
tools/retune_sfx_432.py). The first run of this tool shifted those a second time (to about 424 Hz);
they were restored from the backup and are listed in retuned.txt as done. Only new 440 Hz audio
(fresh downloads) should ever go through `retune`. The ElevenLabs build scripts lower their own
takes, so never run `retune` over assets/audio/sfx."""
import shutil, subprocess, sys
from pathlib import Path

AUDIO = Path("assets/audio")
BACKUP = AUDIO / "_440hz_originals"
DOWNLOADS = Path.home() / "Downloads"
RATIO = 432.0 / 440.0
SONGS = {
    "Highbank on the Bluff": "highbank", "Down Into the Hollow": "hollow", "The Guardian of the Hollow": "guardian",
    "The Wayline Hall": "wayline_hall", "The Old Ferry Landing": "ferry_landing", "Monster House": "monster_house",
    "Something Is Waiting": "boss_scene", "The Hollow Is Quiet": "victory", "Growing": "evolution", "A New Partner": "recruit",
    "Hollowtide": "title", "Over the River": "lookout_flute", "Hollow in the Cottonwoods": "hollow_flute",
    "Morning at the Hall": "morning_call", "Setting Out": "setting_out",
}


def install() -> None:
    for title, name in SONGS.items():
        src = DOWNLOADS / f"{title}.mp3"
        if not src.exists():
            print("missing", title)
            continue
        dst = AUDIO / "music" / f"{name}.mp3"
        shutil.copy2(src, dst)
        print("installed", title, "->", dst.name)


def retune() -> None:
    BACKUP.mkdir(parents=True, exist_ok=True)
    (BACKUP / ".gdignore").write_text("")
    done_list = BACKUP / "retuned.txt"
    done = set(done_list.read_text().split("\n")) if done_list.exists() else set()
    count = 0
    for f in sorted(AUDIO.rglob("*")):
        if f.suffix.lower() not in (".wav", ".ogg", ".mp3") or BACKUP in f.parents:
            continue
        rel = f.relative_to(AUDIO).as_posix()
        if rel in done:
            continue
        keep = BACKUP / rel
        keep.parent.mkdir(parents=True, exist_ok=True)
        if not keep.exists():
            shutil.copy2(f, keep)
        tmp = f.with_name(f.stem + ".432tmp" + f.suffix)
        codec = {".mp3": ["-c:a", "libmp3lame", "-q:a", "2"], ".ogg": ["-c:a", "libvorbis", "-q:a", "6"], ".wav": ["-c:a", "pcm_s16le"]}[f.suffix.lower()]
        r = subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", str(keep), "-af", f"rubberband=pitch={RATIO:.6f}", *codec, str(tmp)], capture_output=True, text=True)
        if r.returncode != 0:
            print("FAILED", rel, r.stderr.strip()[:200])
            tmp.unlink(missing_ok=True)
            continue
        tmp.replace(f)
        done.add(rel)
        count += 1
    done_list.write_text("\n".join(sorted(d for d in done if d)))
    print("retuned", count, "files to 432 Hz; originals in", BACKUP)


if __name__ == "__main__":
    {"install": install, "retune": retune}[sys.argv[1]]()
