"""Synthesize Undertow's sounds (Claude, 2026-10-05).

Scourmaw's signature: it sinks into the river (a deep gurgling plunge), surges
unseen toward the opponent (an underwater rush with a low drone), a whirlpool
opens (a swirling, rising suck), then it bursts up jaws-first (a huge splash,
a jaw snap, water falling back). Hollow gives it a faint ghostly undertone.
Shaped noise and tones with fixed seeds; ElevenLabs takes can replace any later.

  python tools/build_undertow_sounds.py
Writes assets/audio/sfx/undertow/{plunge,surge,whirlpool,burst}.wav (44.1 kHz mono).
"""
import sys
import wave
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_vitrecrag_sounds import SR, bandpass, fade, highpass, lowpass, ramp, sub_drop  # noqa: E402

DIR = Path(__file__).resolve().parent.parent / "assets" / "audio" / "sfx" / "undertow"


def save(name, x):
    x = x / max(1e-9, np.abs(x).max()) * 10 ** (-1 / 20)
    DIR.mkdir(parents=True, exist_ok=True)
    with wave.open(str(DIR / f"{name}.wav"), "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes((x * 32767).astype(np.int16).tobytes())
    print(f"{name}.wav  {len(x) / SR:.2f} s")


def env(n, attack, decay):
    t = np.arange(n) / SR
    return np.minimum(1.0, t / max(attack, 1e-4)) * np.exp(-t / decay)


def bubbles(seconds, rate, seed, lo=300, hi=1200):
    """Bubbles: short tones that sweep upward, like air escaping underwater."""
    rng = np.random.default_rng(seed)
    n = int(seconds * SR); out = np.zeros(n); t = 0.0
    while t < seconds:
        t += rng.exponential(1.0 / rate)
        i = int(t * SR); length = int(rng.uniform(0.02, 0.07) * SR)
        if i + length >= n: break
        f0 = rng.uniform(lo, hi); f = f0 * np.linspace(1.0, 1.8, length)
        out[i:i + length] += np.sin(2 * np.pi * np.cumsum(f) / SR) * env(length, 0.003, 0.02) * rng.uniform(0.3, 1.0)
    return out


def ghost(seconds, f0, seed):
    """The Hollow undertone: a faint, slowly beating pair of pure tones."""
    t = np.arange(int(seconds * SR)) / SR
    return np.sin(2 * np.pi * f0 * t) + np.sin(2 * np.pi * (f0 * 1.007) * t + seed)


def plunge():
    seconds = 1.6; n = int(seconds * SR); rng = np.random.default_rng(31)
    splash = bandpass(rng.standard_normal(n), 400, 5000) * env(n, 0.005, 0.18)
    body = lowpass(rng.standard_normal(n), 250) * env(n, 0.02, 0.5)
    return fade(1.0 * splash + 1.4 * body + 0.6 * bubbles(seconds, 25, 32) * ramp(n, 1.0, 0.2), 0.002, 0.3)


def surge():
    seconds = 2.4; n = int(seconds * SR); rng = np.random.default_rng(33)
    rush = lowpass(rng.standard_normal(n), 500) * ramp(n, 0.3, 1.0, 1.4)
    drone = lowpass(np.tanh(2 * np.sin(2 * np.pi * np.cumsum(np.linspace(45, 70, n)) / SR)), 300)
    return fade(1.2 * rush + 0.6 * drone + 0.3 * bubbles(seconds, 12, 34) + 0.08 * ghost(seconds, 330, 1.0) * ramp(n, 0.0, 1.0), 0.2, 0.2)


def whirlpool():
    seconds = 1.6; n = int(seconds * SR); rng = np.random.default_rng(35)
    noise = rng.standard_normal(n)
    swirl = bandpass(noise, 200, 1500) * (0.6 + 0.4 * np.sin(2 * np.pi * np.cumsum(np.linspace(3, 9, n)) / SR))
    return fade(swirl * ramp(n, 0.2, 1.0, 1.5) + 0.1 * ghost(seconds, 220, 2.0), 0.1, 0.05)


def burst():
    seconds = 3.0; n = int(seconds * SR); rng = np.random.default_rng(36); out = np.zeros(n)
    drop = sub_drop(0.6, 75.0, 28.0); out[:len(drop)] += 1.6 * drop
    out += 1.6 * bandpass(rng.standard_normal(n), 300, 6000) * env(n, 0.003, 0.35)   # the eruption splash
    snap_at = int(0.45 * SR); snap_len = int(0.05 * SR)                                # the jaw slamming shut
    out[snap_at:snap_at + snap_len] += 1.8 * highpass(rng.standard_normal(snap_len), 600) * env(snap_len, 0.0005, 0.012)
    rain = highpass(rng.standard_normal(n), 1500) * (rng.random(n) < 0.004)           # water falling back
    out += 0.9 * lowpass(rain, 7000) * np.exp(-np.arange(n) / SR / 1.2)
    out += 0.12 * ghost(seconds, 165, 3.0) * np.exp(-np.arange(n) / SR / 1.0)
    return fade(out, 0.001, 0.5)


if __name__ == "__main__":
    save("plunge", plunge()); save("surge", surge()); save("whirlpool", whirlpool()); save("burst", burst())
