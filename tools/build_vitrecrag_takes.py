"""Vitrecrag's sounds from ElevenLabs takes (Claude, 2026-10-08).

Preston: "update Vitrecrag's sounds, the horn stuff doesn't sound great." The 2026-09-29
mix (`build_vitrecrag_sounds.py`) layered a brass-and-locomotive voice over boil, stress,
rumble and groan layers; that voice is what reads as a horn. These are straight takes of the
creature as physiology: a kiln core under a stone shell. Takes in
assets/audio/sfx/vitrecrag/takes2/ (`eleven_text_to_sound_v2`, prompt influence 0.3), prompts
and credits in docs/audio/sources.md. Picked by measurement (envelope, length); Preston's
ears can overrule: change PICKS. The old mixes are kept beside them as old_mix_<name>.wav.

Each is trimmed, faded, lowered by 432/440 like the rest of the game, normalised.
  python tools/build_vitrecrag_takes.py        (needs ffmpeg on PATH)
"""
import shutil
import subprocess
import sys
import wave
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_vitrecrag_sounds import SR, fade  # noqa: E402

DIR = Path(__file__).resolve().parent.parent / "assets" / "audio" / "sfx" / "vitrecrag"
TAKES = DIR / "takes2"
RETUNE = 440.0 / 432.0

# name: (take, start s, end s, fade in s, fade out s, peak dB)
PICKS = {
    # the roar swells from 0.2 s, peaks at 0.45 to 0.65 and decays by 1.8 s
    "cry": ("cry_a", 0.05, 1.90, 0.02, 0.15, -2.0),
    # take d of the rerun (3 s; a, b and c came back short or quiet): the first two seconds
    # of its swell, cut so it is still rising at the end (the rupture follows at once)
    "buildup": ("buildup_d", 0.00, 2.00, 0.02, 0.03, -3.0),
    # the 7 s take has its real burst at 1.45 s: crack, whoomp, splatter tail
    "rupture": ("rupture_b", 1.40, 3.20, 0.002, 0.30, -1.0),
}


def decode(name: str) -> np.ndarray:
    out = subprocess.run(["ffmpeg", "-v", "error", "-i", str(TAKES / f"{name}.mp3"), "-f", "s16le", "-ac", "1", "-ar", str(SR), "-"],
                         capture_output=True, check=True).stdout
    return np.frombuffer(out, np.int16).astype(float) / 32768.0


def retune(x: np.ndarray) -> np.ndarray:
    n = int(len(x) * RETUNE)
    return np.interp(np.linspace(0, len(x) - 1, n), np.arange(len(x)), x)


def save(path: Path, x: np.ndarray, peak_db: float) -> None:
    x = x / max(1e-9, np.abs(x).max()) * 10 ** (peak_db / 20)
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((x * 32767).astype(np.int16).tobytes())


if __name__ == "__main__":
    for name, (take, a, b, fin, fout, peak) in PICKS.items():
        if not (TAKES / f"{take}.mp3").exists():
            print(f"{name}: take {take} missing, skipped")
            continue
        old = DIR / f"{name}.wav"
        keep = DIR / f"old_mix_{name}.wav"
        if old.exists() and not keep.exists():
            shutil.copy(old, keep)
        x = decode(take)[int(a * SR):int(b * SR)]
        x = retune(fade(x, fin, fout))
        save(DIR / f"{name}.wav", x, peak)
        print(f"{name}.wav  <- {take} [{a:.2f}, {b:.2f}] s, {len(x) / SR:.2f} s at 432")
