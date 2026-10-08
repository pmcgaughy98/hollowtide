"""Synthesize the arena's own sounds (Claude, 2026-10-07).

Until now the arena borrowed: rocks used Root Rampart's slam and eruption, slams used
the UI hit, Crest Ram used Ironvent's vent jet, Cinder Claw used the weak UI hit, and
telegraphs were silent. These are built from shaped noise and tones with fixed seeds (the
same method as the other build_*_sounds.py scripts), so they are ours outright; the one
Internet Archive candidate worth sampling (a CC0 fire crackle) is a layer Preston can
approve later (docs/audio/sampled-sounds-rule-2026-10-07.md). Any pitched element sits
on A = 432 Hz like the rest of the game.

  python tools/build_arena_sounds.py
Writes assets/audio/sfx/arena/{rock_crack,rock_break,wall_slam,crest_ram,cinder_claw,telegraph}.wav
(44.1 kHz mono).
"""
import sys
import wave
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_vitrecrag_sounds import SR, bandpass, fade, highpass, lowpass, sub_drop  # noqa: E402

DIR = Path(__file__).resolve().parent.parent / "assets" / "audio" / "sfx" / "arena"
A4 = 432.0


def save(name: str, x: np.ndarray, peak_db: float = -1.0) -> None:
    x = x / max(1e-9, np.abs(x).max()) * 10 ** (peak_db / 20)
    DIR.mkdir(parents=True, exist_ok=True)
    with wave.open(str(DIR / f"{name}.wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((x * 32767).astype(np.int16).tobytes())
    print(f"{name}.wav  {len(x) / SR:.2f} s")


def env(n: int, attack: float, decay: float) -> np.ndarray:
    t = np.arange(n) / SR
    return np.minimum(1.0, t / max(attack, 1e-4)) * np.exp(-t / decay)


def noise(seconds: float, seed: int) -> np.ndarray:
    return np.random.default_rng(seed).standard_normal(int(seconds * SR))


def put(out: np.ndarray, x: np.ndarray, at: float, gain: float = 1.0) -> None:
    i = int(at * SR)
    n = min(len(x), len(out) - i)
    if n > 0:
        out[i:i + n] += x[:n] * gain


def clack(seed: int, lo: float, hi: float, length: float) -> np.ndarray:
    """One stone striking stone: a short resonant band of noise."""
    n = int(length * SR)
    return bandpass(noise(length, seed), lo, hi) * env(n, 0.0005, length * 0.3)


def gravel(seconds: float, seed: int, rate: float, gain_fall: float = 3.0) -> np.ndarray:
    """Small stones trickling and settling: sparse clacks that thin out."""
    rng = np.random.default_rng(seed)
    out = np.zeros(int(seconds * SR))
    t = 0.0
    k = 0
    while t < seconds:
        t += rng.exponential(1.0 / rate)
        f = rng.uniform(900, 3200)
        put(out, clack(seed * 100 + k, f * 0.7, f * 1.5, rng.uniform(0.008, 0.02)), t, np.exp(-gain_fall * t / seconds))
        k += 1
    return out


def whoosh(seconds: float, seed: int, f0: float, f1: float, rise: bool = True) -> np.ndarray:
    """Air rushing past: noise through a band that sweeps from f0 to f1, in ten steps."""
    n = int(seconds * SR)
    x = noise(seconds, seed)
    out = np.zeros(n)
    steps = 10
    seg = n // steps
    for s in range(steps):
        k = s / (steps - 1)
        f = f0 * (f1 / f0) ** k
        a, b = s * seg, min(n, (s + 2) * seg)   # overlapping windows, crossfaded
        chunk = bandpass(x[a:b], f * 0.6, f * 1.6)
        w = np.hanning(b - a)
        out[a:b] += chunk * w
    amp = np.linspace(0.15, 1.0, n) if rise else np.linspace(1.0, 0.15, n)
    return out * amp


def rock_crack() -> np.ndarray:
    """A fissure opening in the boulder: a snap, a stone 'tock', and a few chips falling."""
    out = np.zeros(int(0.4 * SR))
    put(out, highpass(noise(0.015, 1), 1800) * env(int(0.015 * SR), 0.0003, 0.004), 0.0, 1.0)
    put(out, clack(2, 320, 950, 0.05), 0.004, 0.9)
    put(out, gravel(0.3, 3, 40.0), 0.03, 0.35)
    return fade(out, 0.001, 0.05)


def rock_break() -> np.ndarray:
    """The boulder shatters: weight, a low burst, a clatter of big shards, then settling gravel."""
    out = np.zeros(int(1.0 * SR))
    put(out, sub_drop(0.45, 95, 32), 0.0, 1.0)
    body = lowpass(noise(0.5, 4), 650) * env(int(0.5 * SR), 0.003, 0.12)
    put(out, body, 0.0, 0.9)
    rng = np.random.default_rng(5)
    for k in range(9):
        f = rng.uniform(350, 1400)
        put(out, clack(10 + k, f * 0.6, f * 1.6, rng.uniform(0.02, 0.045)), rng.uniform(0.02, 0.45), 0.6)
    put(out, gravel(0.7, 6, 55.0), 0.25, 0.3)
    return fade(out, 0.001, 0.1)


def wall_slam() -> np.ndarray:
    """A creature driven into the wall: a crack of contact, the thud, and dust sifting down."""
    out = np.zeros(int(0.5 * SR))
    put(out, highpass(noise(0.01, 7), 2200) * env(int(0.01 * SR), 0.0002, 0.003), 0.0, 0.8)
    put(out, sub_drop(0.3, 115, 42), 0.002, 1.0)
    put(out, lowpass(noise(0.2, 8), 420) * env(int(0.2 * SR), 0.002, 0.06), 0.002, 0.9)
    dust = bandpass(noise(0.35, 9), 900, 3200) * env(int(0.35 * SR), 0.02, 0.12)
    put(out, dust, 0.05, 0.18)
    return fade(out, 0.001, 0.06)


def crest_ram() -> np.ndarray:
    """Ironvent's charge: vents roaring up as it runs, heavy feet under it."""
    out = np.zeros(int(0.5 * SR))
    put(out, whoosh(0.45, 11, 260, 1900), 0.0, 1.0)
    for k in range(4):
        put(out, lowpass(noise(0.08, 20 + k), 180) * env(int(0.08 * SR), 0.002, 0.03), 0.04 + k * 0.11, 0.8)
    return fade(out, 0.005, 0.04)


def cinder_claw() -> np.ndarray:
    """Claws hot from the vents: a swipe, a sizzle as they bite, and a hot tick."""
    out = np.zeros(int(0.32 * SR))
    put(out, whoosh(0.09, 12, 4200, 1300, rise=False), 0.0, 0.9)
    sizzle = highpass(noise(0.22, 13), 3800) * env(int(0.22 * SR), 0.003, 0.07)
    put(out, sizzle, 0.05, 0.55)
    n = int(0.06 * SR)
    t = np.arange(n) / SR
    put(out, np.sin(2 * np.pi * A4 * 4 * t) * env(n, 0.0005, 0.015), 0.055, 0.5)   # E7-ish on the 432 scale
    return fade(out, 0.001, 0.04)


def telegraph() -> np.ndarray:
    """The soft cue when an attack starts winding up: a low tick on A3 (216 Hz at 432 tuning)."""
    n = int(0.12 * SR)
    t = np.arange(n) / SR
    tone = np.sin(2 * np.pi * (A4 / 2) * t) * env(n, 0.001, 0.03)
    click = highpass(noise(0.004, 14), 2500) * env(int(0.004 * SR), 0.0002, 0.001)
    out = tone.copy()
    put(out, click, 0.0, 0.35)
    return fade(out, 0.0005, 0.03)


if __name__ == "__main__":
    save("rock_crack", rock_crack(), -3.0)
    save("rock_break", rock_break(), -1.0)
    save("wall_slam", wall_slam(), -1.0)
    save("crest_ram", crest_ram(), -2.0)
    save("cinder_claw", cinder_claw(), -3.0)
    save("telegraph", telegraph(), -9.0)
