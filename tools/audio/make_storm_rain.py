"""The storm's rain, synthesised so it never repeats (Claude, 2026-10-10; Preston: the first rain loop, stitched
from two 1 s generated clips, had "a lot of repeating sounds"). Three layers, all from seeded noise, so the
same file comes out every time and nothing in it is a copy of anything:
  - the hiss: broadband noise, high-passed, its level breathing a little;
  - the drops: a few hundred short ticks a second at random times, each its own pitch and loudness, some
    heavier splats among them;
  - the wind: low noise swelling and falling over several seconds.
32 seconds, its end folded onto its start so it loops without a seam. Mono, 44.1 kHz.
  python tools/audio/make_storm_rain.py
Writes assets/audio/sfx/story/storm_rain.wav.
"""
import wave
import numpy as np

SR = 44100
SECS = 32
FOLD = 2.0          # seconds of end crossfaded onto the start
OUT = "assets/audio/sfx/story/storm_rain.wav"
rng = np.random.default_rng(1010)


def one_pole(x, a):
    """A gentle low-pass: a in (0, 1), smaller is darker."""
    y = np.empty_like(x)
    acc = 0.0
    for i in range(len(x)):
        acc += a * (x[i] - acc)
        y[i] = acc
    return y


def slow(n, seconds):
    """A smooth random curve, a new value every `seconds`, eased between."""
    points = rng.uniform(0.0, 1.0, int(n / (SR * seconds)) + 3)
    t = np.arange(n) / (SR * seconds)
    i = t.astype(int)
    f = t - i
    f = f * f * (3 - 2 * f)
    return points[i] * (1 - f) + points[i + 1] * f


n = int(SR * (SECS + FOLD))
# The hiss: white noise minus its low part (a high-pass), its level breathing.
white = rng.standard_normal(n)
hiss = white - one_pole(white, 0.08)
hiss *= 0.55 + 0.25 * slow(n, 3.0)
# The drops.
drops = np.zeros(n)
for _ in range(int(SECS * 260)):
    at = rng.integers(0, n - 2000)
    length = rng.integers(60, 260)
    env = np.exp(-np.arange(length) / (length / 5))
    tick = rng.standard_normal(length) * env
    bright = rng.uniform(0.15, 0.6)
    tick = tick - one_pole(tick, bright)        # brighter or duller by drop
    drops[at:at + length] += tick * rng.uniform(0.2, 1.0)
for _ in range(int(SECS * 6)):                   # the occasional heavy splat
    at = rng.integers(0, n - 6000)
    length = rng.integers(1500, 4000)
    env = np.exp(-np.arange(length) / (length / 6))
    drops[at:at + length] += one_pole(rng.standard_normal(length), 0.25) * env * rng.uniform(1.5, 3.0)
# The wind: dark noise, swelling and falling.
wind = one_pole(one_pole(rng.standard_normal(n), 0.01), 0.02)
wind *= (0.25 + 0.75 * slow(n, 5.0) ** 2)
wind /= np.abs(wind).max() + 1e-9

mix = 0.55 * hiss / np.abs(hiss).max() + 0.6 * drops / np.abs(drops).max() + 0.5 * wind
# Fold the extra end onto the start (equal power), so the loop has no seam.
k = int(SR * FOLD)
r = np.linspace(0.0, 1.0, k)
body = mix[:SR * SECS].copy()
body[:k] = body[:k] * np.sqrt(r) + mix[SR * SECS:SR * SECS + k] * np.sqrt(1 - r)
body = body / np.sqrt(np.mean(body ** 2)) * 3000
with wave.open(OUT, "wb") as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(np.clip(body, -32767, 32767).astype(np.int16).tobytes())
print(OUT, SECS, "s")
