"""Soften the piercing whistles (Claude, 2026-10-09; Preston: "Highsignal was really ear piercing and not
sustainable without editing... same with Vitrecrag's whistle thing"). Measured first: Highsignal's
signal and Dustkite's whistle dart are near-pure whistles at about 2 kHz (97% and 89% of their energy
between 2 and 6 kHz, where hearing is most sensitive); Vitrecrag's build-up peaks near 5.7 kHz (96%
above 2 kHz). Each drops exactly one octave (a whistle still, far gentler, and an octave keeps it on the
432 tuning), gets a softer onset, a steep cut above 1.8 kHz for the build-up, and a little
less level. Originals are kept once in docs/audio/sfx-whistle-originals-2026-10-09/ and always re-read.
  python tools/audio/soften_whistles.py"""
import shutil, subprocess
from pathlib import Path

KEEP = Path("docs/audio/sfx-whistle-originals-2026-10-09")
FIX = {
    "assets/audio/sfx/dustkite/high_signal.wav": "rubberband=pitch=0.5,afade=t=in:d=0.04,volume=0.8",
    "assets/audio/sfx/dustkite/whistle_dart.wav": "rubberband=pitch=0.5,afade=t=in:d=0.02,volume=0.85",
    "assets/audio/sfx/vitrecrag/buildup.wav": "rubberband=pitch=0.5,lowpass=f=1800,lowpass=f=1800,afade=t=in:d=0.08,volume=4.0",   # a steep cut: the octave alone left it at 73% harsh
}
KEEP.mkdir(parents=True, exist_ok=True)
(KEEP / ".gdignore").write_text("")
for path, af in FIX.items():
    p = Path(path)
    keep = KEEP / (p.parent.name + "_" + p.name)
    if not keep.exists():
        shutil.copy2(p, keep)
    subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", str(keep), "-af", af, "-c:a", "pcm_s16le", str(p)], check=True)
    print("softened", path)
