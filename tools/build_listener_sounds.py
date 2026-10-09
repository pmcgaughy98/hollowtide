"""The River Listener line's sounds from the chosen ElevenLabs takes (Claude, 2026-10-08).
Four takes (`eleven_text_to_sound_v2`) in assets/audio/sfx/listener/takes/: echo_tap_a (1.0 s,
a crisp knock with a short ring: the pick) and echo_tap_b (2.0 s, quiet wash); hush_a (2.0 s,
a low 226 Hz hum: the pick, it sits under the signature) and hush_b (2.0 s, brighter, more
water than hush). Picked by envelope and spectral centroid, not by ear: Preston's ears decide.
Trimmed, faded, lowered by 432/440 like the rest of the game, normalised.
  python tools/build_listener_sounds.py      (needs ffmpeg on PATH)
"""
import subprocess, sys, wave
from pathlib import Path
import numpy as np
sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_vitrecrag_sounds import SR, fade  # noqa: E402
DIR = Path(__file__).resolve().parent.parent / "assets" / "audio" / "sfx" / "listener"
RETUNE = 440.0 / 432.0
PICKS = {"echo_tap": ("echo_tap_a", 0.0, 1.0, 0.005, 0.15, -3.0),
         "hush": ("hush_a", 0.0, 2.0, 0.05, 0.4, -2.0)}

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
