"""Mix Vitrecrag's sounds from its physiology (Preston, 2026-09-29).

Preston: build each sound as if it came from a creature with a molten-glass
core going haywire inside its body. The brass-and-locomotive voice (his idea)
is the core. Around it, what a molten-glass core would sound like from inside
an armored shell:
  - boil:   thick molten glass bubbling (the core itself)
  - stress: hot glass creaking and pinging under heat stress
  - rumble: the furnace roar, heard through the chamber walls
  - groan:  shell plates grinding under the pressure
  - crack:  the glass shell splitting open

Every layer was generated with ElevenLabs (flow
https://elevenlabs.io/app/flows/xPEJTo1VIDANiC6QVpLn) and lives in
assets/audio/sfx/vitrecrag/takes/ and .../layers/. This script only mixes
them. Nothing here is generated, so re-running gives the same files.

Inside the body means muffled: a low-pass filter takes the brightness off,
the way a wall does. The buildup opens that filter as the pressure rises, so
the voice bursts out of the shell right at the rupture.

  python tools/build_vitrecrag_sounds.py
Writes assets/audio/sfx/vitrecrag/{cry,buildup,rupture}.wav (44.1 kHz mono).
"""
import subprocess
import wave
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent.parent
DIR = ROOT / "assets/audio/sfx/vitrecrag"
SR = 44100


def load(name: str) -> np.ndarray:
    """A take or layer as mono floats at 44.1 kHz (ffmpeg decodes the mp3)."""
    path = next(p for p in [DIR / "takes" / f"{name}.mp3", DIR / "layers" / f"{name}.mp3"] if p.exists())
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", str(path), "-f", "f32le", "-ac", "1", "-ar", str(SR), "-"],
                         capture_output=True, check=True).stdout
    return np.frombuffer(raw, np.float32).astype(np.float64)


def save(name: str, x: np.ndarray) -> None:
    x = x / max(1e-9, np.abs(x).max()) * 10 ** (-1 / 20)  # peak at -1 dBFS
    with wave.open(str(DIR / f"{name}.wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((x * 32767).astype(np.int16).tobytes())
    print(f"{name}.wav  {len(x) / SR:.2f} s")


def lowpass(x: np.ndarray, cutoff) -> np.ndarray:
    """Two-pole low-pass; cutoff in Hz, a number or one value per sample (a sweep)."""
    fc = np.broadcast_to(np.asarray(cutoff, dtype=np.float64), x.shape)
    a = 1.0 - np.exp(-2.0 * np.pi * fc / SR)
    y = x.copy()
    for _ in range(2):
        out = np.empty_like(y)
        s = 0.0
        for i in range(len(y)):
            s += a[i] * (y[i] - s)
            out[i] = s
        y = out
    return y


def highpass(x: np.ndarray, cutoff: float) -> np.ndarray:
    return x - lowpass(x, cutoff)


def speed_ramp(x: np.ndarray, start: float, end: float, seconds: float) -> np.ndarray:
    """Plays x at a speed gliding from start to end (pitch and pace rise together)."""
    n = int(seconds * SR)
    rate = np.linspace(start, end, n)
    pos = np.cumsum(rate)
    pos = pos[pos < len(x) - 1]
    return np.interp(pos, np.arange(len(x)), x)


def ramp(n: int, a: float, b: float, curve: float = 1.0) -> np.ndarray:
    return a + (b - a) * np.linspace(0.0, 1.0, n) ** curve


def fade(x: np.ndarray, fin: float = 0.01, fout: float = 0.05) -> np.ndarray:
    x = x.copy()
    i, o = int(fin * SR), int(fout * SR)
    if i:
        x[:i] *= np.linspace(0, 1, i)
    if o:
        x[-o:] *= np.linspace(1, 0, o)
    return x


def unit(x: np.ndarray) -> np.ndarray:
    """Scaled so its loudest moment is 1, so gains below are comparable."""
    return x / max(1e-9, np.abs(x).max())


def put(out: np.ndarray, x: np.ndarray, at: float, gain=1.0) -> None:
    s = int(at * SR)
    x = x[: max(0, len(out) - s)]
    out[s: s + len(x)] += x * (gain if np.isscalar(gain) else gain[: len(x)])


def cry() -> np.ndarray:
    """The brass-locomotive bellow, resonating through a body full of molten glass."""
    voice = unit(load("cry_a"))
    out = np.zeros(int(2.3 * SR))
    # The voice with its chest: a muffled copy under the dry one, lightly driven.
    body = np.tanh(1.6 * (0.75 * voice + 0.6 * unit(lowpass(voice, 700))))
    put(out, body, 0.0)
    # The core bubbling underneath, and the furnace behind the shell.
    put(out, fade(unit(lowpass(load("boil_a"), 1500))[: len(out)], 0.2, 0.4), 0.0, 0.3)
    put(out, fade(unit(lowpass(load("rumble_a"), 380))[: len(out)], 0.1, 0.5), 0.0, 0.45)
    # Glass ticking as the bellow shakes it.
    put(out, fade(unit(highpass(load("stress_a"), 1800))[: int(1.0 * SR)], 0.05, 0.4), 1.2, 0.3)
    return fade(out, 0.005, 0.25)


def buildup() -> np.ndarray:
    """The meltdown building inside the shell, bursting out at the rupture."""
    n = int(2.6 * SR)
    out = np.zeros(n)
    # The voice, muffled inside the body at first, opening as the pressure rises.
    # Pressure pushes its pitch up as it builds: played slightly slow at first
    # and slightly fast at the end, so it also ends right at the rupture.
    voice = unit(speed_ramp(load("buildup_a"), 0.92, 1.16, 2.6))[:n]
    sweep = 500.0 * (12000.0 / 500.0) ** np.linspace(0.0, 1.0, len(voice)) ** 1.6
    put(out, np.tanh(1.3 * unit(lowpass(voice, sweep))), 0.0)
    # The core boiling faster and higher as it overheats.
    boil = unit(lowpass(speed_ramp(load("boil_a"), 0.8, 1.45, 2.6), 2200))
    put(out, boil, 0.0, ramp(len(boil), 0.15, 0.75, 1.5))
    # The furnace behind the walls, swelling.
    rumble = unit(lowpass(load("rumble_a"), 350))[:n]
    put(out, rumble, 0.0, ramp(len(rumble), 0.35, 0.8))
    # The shell plates starting to strain.
    groan = fade(unit(lowpass(load("groan_a"), 1800))[: int(2.0 * SR)], 0.3, 0.2)
    put(out, groan, 0.6, 0.45)
    # Heat stress: the glass pings and creaks, thicker and thicker toward the peak.
    stress = unit(highpass(load("stress_a"), 1500))[: int(1.3 * SR)]
    put(out, stress, 1.3, ramp(len(stress), 0.0, 0.6, 1.4))
    stress_b = unit(highpass(load("stress_b"), 1500))[: int(0.8 * SR)]
    put(out, stress_b, 1.8, ramp(len(stress_b), 0.1, 0.55))
    return fade(out, 0.02, 0.03)


def rupture() -> np.ndarray:
    """The shell cracks and the core pours out."""
    out = np.zeros(int(2.6 * SR))
    put(out, unit(load("crack_a")), 0.0, 1.0)
    # The take swells for 0.7 s before its burst; skip most of the swell so the
    # burst follows the crack as the glass pours out (the pour starts 0.08 s in).
    put(out, fade(unit(load("rupture_a"))[int(0.4 * SR):], 0.01, 0.3), 0.03, 0.85)
    # The glass flowing out gurgles; hot shards tick as they cool.
    pour = fade(unit(lowpass(load("boil_b"), 2500))[: int(1.9 * SR)], 0.2, 0.5)
    put(out, pour, 0.6, 0.45)
    ticks = fade(unit(highpass(load("stress_b"), 2000))[: int(1.2 * SR)], 0.1, 0.5)
    put(out, ticks, 1.3, 0.25)
    return fade(out, 0.002, 0.3)


if __name__ == "__main__":
    for name, make in (("cry", cry), ("buildup", buildup), ("rupture", rupture)):
        save(name, make())
