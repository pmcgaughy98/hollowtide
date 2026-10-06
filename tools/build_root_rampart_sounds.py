"""Synthesize Root Rampart's sounds (Claude, 2026-10-05).

Rampartroot's signature: it rears with its seed-pod club raised (wood and husk
straining), slams the club into the ground (a heavy thud), a wave of roots tears
through the earth toward the opponent (cracking wood and rumbling ground), and a
towering wall of roots and stone erupts under it (a deep earth burst). Built
from shaped noise and tones with fixed seeds, so re-running gives the same
files. Preston's ElevenLabs takes can replace any of them later.

  python tools/build_root_rampart_sounds.py
Writes assets/audio/sfx/root_rampart/{strain,slam,rootwave,eruption}.wav (44.1 kHz mono).
"""
import sys
import wave
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_vitrecrag_sounds import SR, bandpass, fade, highpass, lowpass, ramp, sub_drop  # noqa: E402

DIR = Path(__file__).resolve().parent.parent / "assets" / "audio" / "sfx" / "root_rampart"


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
    t = np.arange(n) / SR
    return np.minimum(1.0, t / max(attack, 1e-4)) * np.exp(-t / decay)


def creaks(seconds: float, rate: float, seed: int, rising: bool = False) -> np.ndarray:
    """Wood creaking and splitting: short resonant groans and sharp cracks."""
    rng = np.random.default_rng(seed)
    n = int(seconds * SR)
    out = np.zeros(n)
    t = 0.0
    while t < seconds:
        k = t / seconds if rising else 0.6
        t += rng.exponential(1.0 / (rate * (0.4 + 1.2 * k)))
        i = int(t * SR)
        if rng.random() < 0.35:  # a crack: a bright snap
            length = int(rng.uniform(0.01, 0.04) * SR)
            if i + length >= n:
                break
            out[i:i + length] += highpass(rng.standard_normal(length), 1200) * env(length, 0.0005, 0.01) * (0.5 + k)
        else:  # a groan: a low pitched creak that bends
            length = int(rng.uniform(0.08, 0.25) * SR)
            if i + length >= n:
                break
            f = rng.uniform(90, 260) * np.linspace(1.0, rng.uniform(0.8, 1.25), length)
            tone = np.sign(np.sin(2 * np.pi * np.cumsum(f) / SR))
            out[i:i + length] += bandpass(tone, 150, 1600) * env(length, 0.01, 0.08) * 0.4 * (0.5 + k)
    return out


def rumble(seconds: float, seed: int, cutoff: float = 140) -> np.ndarray:
    return lowpass(np.random.default_rng(seed).standard_normal(int(seconds * SR)), cutoff)


def strain() -> np.ndarray:
    """Rearing with the club raised: husk and wood straining, a low growl of the ground."""
    seconds = 1.6
    n = int(seconds * SR)
    return fade(1.2 * creaks(seconds, 9, 21, rising=True) + 0.6 * rumble(seconds, 22) * ramp(n, 0.2, 1.0), 0.05, 0.1)


def slam() -> np.ndarray:
    """The club hitting the ground: a deep thud, a crack of earth, dirt pattering down."""
    seconds = 1.4
    n = int(seconds * SR)
    rng = np.random.default_rng(23)
    out = np.zeros(n)
    drop = sub_drop(0.45, 70.0, 30.0)
    out[:len(drop)] += 1.8 * drop
    out += 1.2 * lowpass(rng.standard_normal(n), 300) * env(n, 0.001, 0.18)
    out += 0.5 * bandpass(rng.standard_normal(n), 800, 4000) * env(n, 0.002, 0.05)
    patter = highpass(rng.standard_normal(n), 2000) * (rng.random(n) < 0.002)
    out += 0.6 * lowpass(patter, 6000) * np.exp(-np.arange(n) / SR / 0.6)
    return fade(out, 0.0005, 0.3)


def rootwave() -> np.ndarray:
    """Roots tearing through the earth toward the opponent: cracking wood over a travelling rumble."""
    seconds = 2.4
    n = int(seconds * SR)
    ground = rumble(seconds, 24, 180) * (0.6 + 0.4 * np.sin(2 * np.pi * 5.0 * np.arange(n) / SR))
    return fade(1.0 * creaks(seconds, 22, 25, rising=True) + 1.4 * ground * ramp(n, 0.4, 1.0), 0.1, 0.2)


def eruption() -> np.ndarray:
    """The wall of roots and stone bursting up: a huge earth blast, splitting wood, rubble falling."""
    seconds = 3.0
    n = int(seconds * SR)
    rng = np.random.default_rng(26)
    out = np.zeros(n)
    drop = sub_drop(0.7, 80.0, 25.0)
    out[:len(drop)] += 1.8 * drop
    out += 1.4 * lowpass(rng.standard_normal(n), 350) * env(n, 0.003, 0.7)
    out += 1.0 * creaks(seconds, 30, 27) * np.exp(-np.arange(n) / SR / 1.2)
    out += 0.8 * rumble(seconds, 28, 120) * env(n, 0.2, 1.2)
    return fade(out, 0.001, 0.5)


if __name__ == "__main__":
    save("strain", strain())
    save("slam", slam())
    save("rootwave", rootwave())
    save("eruption", eruption())
