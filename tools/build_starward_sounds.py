"""The Punchybuns line's shield sound from the chosen ElevenLabs take (Claude, 2026-10-08).
Four takes (`eleven_text_to_sound_v2`) in assets/audio/sfx/starward/takes/: a (1.0 s) and b
(0.48 s) from the first run, c (1.0 s) and d (3.0 s) from the rerun Preston asked for. Take d is
the only one long enough to carry the star forming: a swell over the first second, the pulse,
and a tail; cut at 2.2 s.
Trimmed, faded, lowered by 432/440 like the rest of the game, normalised.
  python tools/build_starward_sounds.py      (needs ffmpeg on PATH)
"""
import subprocess, sys, wave
from pathlib import Path
import numpy as np
sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_vitrecrag_sounds import SR, fade  # noqa: E402
DIR = Path(__file__).resolve().parent.parent / "assets" / "audio" / "sfx" / "starward"
RETUNE = 440.0 / 432.0
PICKS = {"star_guard": ("star_guard_d", 0.0, 2.2, 0.01, 0.25, -2.0)}

def decode(name):
    out = subprocess.run(["ffmpeg", "-v", "error", "-i", str(DIR / "takes" / f"{name}.mp3"), "-f", "s16le", "-ac", "1", "-ar", str(SR), "-"], capture_output=True, check=True).stdout
    return np.frombuffer(out, np.int16).astype(float) / 32768.0

if __name__ == "__main__":
    for name, (take, a, b, fin, fout, peak) in PICKS.items():
        x = decode(take)[int(a * SR):int(b * SR)]
        x = fade(x, fin, fout)
        x = np.interp(np.linspace(0, len(x) - 1, int(len(x) * RETUNE)), np.arange(len(x)), x)
        x = x / max(1e-9, np.abs(x).max()) * 10 ** (peak / 20)
        with wave.open(str(DIR / f"{name}.wav"), "wb") as w:
            w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes((x * 32767).astype(np.int16).tobytes())
        print(f"{name}.wav <- {take} [{a}, {b}] s, {len(x) / SR:.2f} s at 432")
