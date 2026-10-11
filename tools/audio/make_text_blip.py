"""The dialogue text blip (Claude, 2026-10-10; Preston: the sound when text plays in Mystery Dungeon, "like the
old military computer" printing a readout). Synthesised here, not generated: a short square-wave tick,
the way handheld text boxes sound, with a soft attack so it never clicks and a quick fall so a run of
them reads as typing. Three takes a hair apart in pitch, so a long line does not drone on one note.
Pitches sit on the game's 432 Hz tuning: 864 Hz is 432 x 2, the A an octave up, with a take a semitone
either side. (First made at 1296 Hz; Preston, 2026-10-10: "a little high pitched", so a fifth lower.)
  python tools/audio/make_text_blip.py
Writes assets/audio/sfx/ui/text_blip_0.wav, _1, _2 (44.1 kHz, 16-bit, mono). Tweak LENGTH_MS, the
pitches or DUTY and run again.
"""
import wave
from pathlib import Path
import numpy as np

RATE = 44100
LENGTH_MS = 34
DUTY = 0.125                     # a thin pulse: bright 2nd and 3rd overtones, as measured in Explorers of Sky (2026-10-10)
PITCHES = [864.0, 864.0 * 2 ** (1 / 12), 864.0 * 2 ** (-1 / 12)]   # 432 x 2, and a semitone either side
OUT = Path("assets/audio/sfx/ui")


def blip(freq: float) -> np.ndarray:
    n = int(RATE * LENGTH_MS / 1000)
    t = np.arange(n) / RATE
    phase = (t * freq) % 1.0
    wave_ = np.where(phase < DUTY, 1.0, -1.0)
    # A touch of the octave below gives it body on small speakers.
    wave_ += 0.35 * np.where(((t * freq / 2) % 1.0) < 0.5, 1.0, -1.0)
    env = np.minimum(1.0, t / 0.002) * np.exp(-t / 0.012)   # 2 ms in, falls away in about 30 ms
    sig = wave_ * env
    # Soften the very top so the pulse is bright, not harsh: a one-pole low-pass.
    out = np.zeros_like(sig)
    a = 0.55
    for i in range(1, len(sig)):
        out[i] = out[i - 1] + a * (sig[i] - out[i - 1])
    out /= np.abs(out).max()
    return (out * 0.5 * 32767).astype(np.int16)


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    for k, f in enumerate(PITCHES):
        with wave.open(str(OUT / f"text_blip_{k}.wav"), "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(RATE)
            w.writeframes(blip(f).tobytes())
        print(OUT / f"text_blip_{k}.wav", round(f, 1), "Hz")
