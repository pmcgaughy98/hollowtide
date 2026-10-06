"""Synthesize Stormlantern's sounds (Claude, 2026-10-05).

Stormwick's signature: lightning strikes its rod crest, its storm lantern
overloads, it throws the core, the core lands in fire and thunder. Nothing here
is recorded; every sound is built from shaped noise and tones, so re-running
gives the same files (fixed seeds). Preston's ElevenLabs takes can replace any
of them later; they play from the same move slots.

  python tools/build_stormlantern_sounds.py
Writes assets/audio/sfx/stormlantern/{crack,crackle,throw,boom}.wav (44.1 kHz mono).
"""
import sys
import wave
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_vitrecrag_sounds import SR, bandpass, fade, highpass, lowpass, ramp, sub_drop  # noqa: E402

DIR = Path(__file__).resolve().parent.parent / "assets" / "audio" / "sfx" / "stormlantern"


def save(name: str, x: np.ndarray) -> None:
    x = x / max(1e-9, np.abs(x).max()) * 10 ** (-1 / 20)
    DIR.mkdir(parents=True, exist_ok=True)
    with wave.open(str(DIR / f"{name}.wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((x * 32767).astype(np.int16).tobytes())
    print(f"{name}.wav  {len(x) / SR:.2f} s")


def env(n: int, attack: float, decay: float) -> np.ndarray:
    """A fast rise then an exponential fall, in seconds."""
    t = np.arange(n) / SR
    return np.minimum(1.0, t / max(attack, 1e-4)) * np.exp(-t / decay)


def arcs(seconds: float, rate: float, seed: int, rising: bool = False) -> np.ndarray:
    """Electric arcing: short bright bursts of noise at random moments."""
    rng = np.random.default_rng(seed)
    n = int(seconds * SR)
    out = np.zeros(n)
    t = 0.0
    while t < seconds:
        k = t / seconds if rising else 0.5
        t += rng.exponential(1.0 / (rate * (0.3 + 1.4 * k)))
        i = int(t * SR)
        length = int(rng.uniform(0.004, 0.03) * SR)
        if i + length >= n:
            break
        burst = highpass(rng.standard_normal(length), 2500) * env(length, 0.0005, rng.uniform(0.003, 0.012))
        out[i:i + length] += burst * (0.4 + 0.6 * (k if rising else rng.uniform(0.5, 1.0)))
    return out


def crack() -> np.ndarray:
    """The bolt hitting the crest: a sharp tearing snap, then rolling thunder."""
    rng = np.random.default_rng(11)
    n = int(2.6 * SR)
    snap = highpass(rng.standard_normal(n), 1800) * env(n, 0.0005, 0.05)
    tear = arcs(0.25, 160, 12)
    roll = lowpass(rng.standard_normal(n), 220) * env(n, 0.08, 0.9)
    roll *= 1 + 0.5 * np.sin(2 * np.pi * 3.1 * np.arange(n) / SR)  # thunder rumbles in waves
    out = 1.0 * snap + 3.0 * roll
    out[:len(tear)] += 0.8 * tear
    return fade(out, 0.0005, 0.4)


def crackle() -> np.ndarray:
    """The lantern overloading: a rising electric hum under building arcs."""
    seconds = 1.9
    n = int(seconds * SR)
    t = np.arange(n) / SR
    pitch = 70 + 90 * (t / seconds) ** 1.5
    hum = np.sin(2 * np.pi * np.cumsum(pitch) / SR) + 0.4 * np.sin(4 * np.pi * np.cumsum(pitch) / SR)
    hum = lowpass(np.tanh(2.5 * hum), 900) * ramp(n, 0.2, 1.0, 1.3)
    fire = bandpass(np.random.default_rng(13).standard_normal(n), 300, 2200) * ramp(n, 0.05, 0.5)
    return fade(0.5 * hum + 0.35 * fire + 0.9 * arcs(seconds, 30, 14, rising=True), 0.05, 0.08)


def throw() -> np.ndarray:
    """The tail snap and the core leaving: a fast rising whoosh with a spark trail."""
    seconds = 0.6
    n = int(seconds * SR)
    rng = np.random.default_rng(15)
    noise = rng.standard_normal(n)
    a = bandpass(noise, 300, 1200)
    b = bandpass(noise, 1500, 5000)
    k = np.linspace(0, 1, n)
    swoosh = (1 - k) * a + k * b
    return fade(swoosh * np.sin(np.pi * k) ** 0.7 + 0.5 * arcs(seconds, 50, 16), 0.01, 0.12)


def boom() -> np.ndarray:
    """The core landing: a deep hit, a fire burst and thunder, with arcs fizzing out."""
    seconds = 2.8
    n = int(seconds * SR)
    rng = np.random.default_rng(17)
    out = np.zeros(n)
    drop = sub_drop(0.6, 90.0, 28.0)
    out[:len(drop)] += 1.6 * drop
    out += 1.2 * lowpass(rng.standard_normal(n), 400) * env(n, 0.002, 0.5)   # the blast
    out += 0.6 * bandpass(rng.standard_normal(n), 400, 3000) * env(n, 0.01, 0.35)  # the fire
    out += 1.0 * lowpass(rng.standard_normal(n), 180) * env(n, 0.15, 1.1)    # the thunder after
    out += 0.7 * arcs(seconds, 25, 18) * np.exp(-np.arange(n) / SR / 0.9)
    return fade(out, 0.001, 0.5)


if __name__ == "__main__":
    save("crack", crack())
    save("crackle", crackle())
    save("throw", throw())
    save("boom", boom())
