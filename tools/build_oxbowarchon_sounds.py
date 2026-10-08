"""Kingstone Rail's arena sounds from the chosen ElevenLabs takes (Claude, 2026-10-08).

Two takes each (`eleven_text_to_sound_v2`, prompt influence 0.3) in
assets/audio/sfx/oxbowarchon/takes/; prompts and credits in docs/audio/sources.md. Picked by
measurement (Preston's ears can overrule: change PICKS):
  rail_charge  <- take b, the only one with a real build: a hum from 0.3 s and the release
                  blast at 5.55 s. Cut so the blast lands 1.15 s in, where the arena's rails
                  fire (arena_signature.gd RAIL_FIRE).
  rail_impact  <- take a, the louder boom (0.65 against 0.52) with the cleaner decay; cut
                  to start on the boom.
Each is trimmed, faded, lowered by 432/440 like the rest of the game, normalised and written.

  python tools/build_oxbowarchon_sounds.py
Needs ffmpeg on PATH.
"""
import subprocess
import sys
import wave
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_vitrecrag_sounds import SR, fade  # noqa: E402

DIR = Path(__file__).resolve().parent.parent / "assets" / "audio" / "sfx" / "oxbowarchon"
TAKES = DIR / "takes"
RETUNE = 440.0 / 432.0

# name: (take, start s, end s, fade in s, fade out s, peak dB)
PICKS = {
    "rail_charge": ("rail_charge_b", 4.42, 6.00, 0.05, 0.08, -2.0),
    "rail_impact": ("rail_impact_a", 0.40, 1.60, 0.002, 0.15, -1.0),
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
        x = decode(take)[int(a * SR):int(b * SR)]
        x = retune(fade(x, fin, fout))
        save(DIR / f"{name}.wav", x, peak)
        print(f"{name}.wav  <- {take} [{a:.2f}, {b:.2f}] s, {len(x) / SR:.2f} s at 432")
