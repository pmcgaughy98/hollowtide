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
Writes assets/audio/sfx/vitrecrag/{cry,buildup,rupture}.wav (44.1 kHz; the rupture is stereo).
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
    """Mono (1-D) or stereo (N x 2), peak-normalized to -1 dBFS."""
    x = x / max(1e-9, np.abs(x).max()) * 10 ** (-1 / 20)  # peak at -1 dBFS
    with wave.open(str(DIR / f"{name}.wav"), "wb") as w:
        w.setnchannels(1 if x.ndim == 1 else 2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((x * 32767).astype(np.int16).tobytes())
    print(f"{name}.wav  {len(x) / SR:.2f} s  {'mono' if x.ndim == 1 else 'stereo'}")


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
    # The silence before the release is not baked in here: the battle fades
    # this out when the strain frame's hush begins (battle_screen._hush_cues),
    # so sound and picture go quiet together however the frame timing drifts.
    return fade(out, 0.02, 0.03)


def db(x: float) -> float:
    return 10 ** (x / 20)


def bandpass(x: np.ndarray, lo: float, hi: float) -> np.ndarray:
    return lowpass(highpass(x, lo), hi)


def sub_drop(seconds: float = 0.45, f0: float = 80.0, f1: float = 30.0) -> np.ndarray:
    """A sine sweeping down from f0 to f1 Hz, dying away: the weight you feel."""
    n = int(seconds * SR)
    freq = f0 * (f1 / f0) ** np.linspace(0, 1, n)
    wave_ = np.sin(2 * np.pi * np.cumsum(freq) / SR)
    return wave_ * np.exp(-np.linspace(0, 5, n)) * np.minimum(1, np.arange(n) / (0.004 * SR))


def haas(x: np.ndarray, delay: float = 0.015) -> np.ndarray:
    """Stereo from mono: the right side 15 ms late, so it spreads wide."""
    d = int(delay * SR)
    right = np.concatenate([np.zeros(d), x[:-d]])
    return np.stack([x, right], axis=1)


def cavern_ir(seconds: float, seed: int) -> np.ndarray:
    """A synthetic impulse response: dark noise dying away over `seconds`, the
    sound of a big stone space. Convolving with it adds the space to a sound."""
    rng = np.random.default_rng(seed)
    n = int(seconds * SR)
    ir = rng.standard_normal(n) * np.exp(-6.9 * np.linspace(0, 1, n))  # -60 dB by the end
    ir = lowpass(ir, 2500)
    return ir / np.sqrt((ir ** 2).sum())


def convolve(x: np.ndarray, ir: np.ndarray) -> np.ndarray:
    """Convolution through the FFT (numpy only; the report suggests scipy)."""
    n = len(x) + len(ir) - 1
    size = 1 << (n - 1).bit_length()
    return np.fft.irfft(np.fft.rfft(x, size) * np.fft.rfft(ir, size), size)[:n]


def put2(out: np.ndarray, x: np.ndarray, at: float, gain=1.0) -> None:
    """Adds mono (centred, both sides) or stereo x into a stereo buffer."""
    s = int(at * SR)
    x = x[: max(0, len(out) - s)]
    if x.ndim == 1:
        x = np.stack([x, x], axis=1)
    g = gain if np.isscalar(gain) else gain[: len(x), None]
    out[s: s + len(x)] += x * g


def rupture() -> np.ndarray:
    """The release, layered the way a big impact is built (Gemini audio
    research, 2026-09-29): each layer has one job in its own band, so none
    masks another. It lands out of the buildup's 60 ms silence.
      transient  the shell cracking      1-8 kHz, under 50 ms, loudest, centred
      sub drop   a sine 80 -> 30 Hz      felt more than heard, centred
      body       the carapace breaking   200 Hz - 1 kHz, about 0.4 s
      voice      Vitrecrag's brass-locomotive core peaking on the hit: a sub
                 copy (low-passed, driven) under a bright copy, so the release
                 is still him and not a stock explosion
      material   the glass burst and sizzle, then the pour and cooling ticks
      sweeteners steam and raining glass shards, spread wide with a 15 ms delay
      space      a cavern-like reverb tail, so it happens somewhere
    """
    n = int(3.4 * SR)
    out = np.zeros((n, 2))
    dry = np.zeros(n)  # what feeds the reverb
    # Transient: the crack, bright and hard-clipped so it snaps.
    crack = unit(highpass(load("crack_a"), 1000))[: int(0.12 * SR)]
    crack = np.clip(crack * 2.2, -1, 1) * np.exp(-np.linspace(0, 6, len(crack)))
    put2(out, crack, 0.0, db(0))
    put(dry, crack, 0.0, db(0))
    # Sub drop.
    put2(out, sub_drop(), 0.0, db(-2))
    # Body: the shell giving way.
    body = fade(unit(bandpass(load("body_a"), 200, 1000))[: int(0.7 * SR)], 0.003, 0.35)
    put2(out, body, 0.0, db(-4))
    put(dry, body, 0.0, db(-4))
    # The voice on the payoff: the bellow's attack pitched up sharply.
    cry_ = unit(speed_ramp(load("cry_a"), 0.85, 1.25, 0.7))
    under = np.tanh(3.0 * unit(lowpass(cry_, 150)))
    bright = unit(highpass(cry_, 800))
    voice = fade(0.8 * under + 0.35 * bright, 0.01, 0.4)[: int(0.7 * SR)]
    put2(out, voice, 0.0, db(-3))
    put(dry, voice, 0.0, db(-3))
    # Material: the glass burst (its slow lead-in skipped), then the pour.
    burst = fade(unit(load("rupture_a"))[int(0.4 * SR):], 0.01, 0.3)
    put2(out, burst, 0.03, db(-6))
    pour = fade(unit(lowpass(load("boil_b"), 2500))[: int(1.9 * SR)], 0.2, 0.5)
    put2(out, pour, 0.6, db(-9))
    ticks = fade(unit(highpass(load("stress_b"), 2000))[: int(1.2 * SR)], 0.1, 0.5)
    put2(out, haas(ticks), 1.4, db(-14))
    # Sweeteners, spread wide.
    steam = fade(unit(highpass(load("steam_a"), 3000))[: int(1.5 * SR)], 0.005, 0.6)
    put2(out, haas(steam), 0.02, db(-10))
    shards = fade(unit(highpass(load("shards_a"), 4000))[: int(1.6 * SR)], 0.02, 0.6)
    put2(out, haas(shards, 0.012), 0.12, db(-11))
    # Space: the dry hit rung through a stone cavern, slightly different each side.
    wet_l = convolve(dry, cavern_ir(2.6, 1))[:n]
    wet_r = convolve(dry, cavern_ir(2.6, 2))[:n]
    wet = np.stack([unit(wet_l), unit(wet_r)], axis=1)
    put2(out, wet[: n - int(0.04 * SR)], 0.04, db(-12))
    return out


if __name__ == "__main__":
    for name, make in (("cry", cry), ("buildup", buildup), ("rupture", rupture)):
        save(name, make())
