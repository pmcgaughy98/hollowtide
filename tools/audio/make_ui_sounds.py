"""Hollowtide's menu and event sounds, synthesised (Claude, 2026-10-10; Preston: make our own from Explorers of
Sky's, menu set first, then stairs, item pickup, level up, faint).

Method: Sky's sounds were measured from a recording (pitch, length, loudness over time, and which overtones
are present), and only those measurements are used here. Every sample below is generated from a wave
shape; nothing is copied, and the jingles use our own notes and intervals, on the game's A = 432 tuning.
What the measuring found (docs/audio/sources.md has the numbers):
  - Sky's cursor and cancel ticks are pure square waves (odd overtones only, 1/3 and 1/5 strong);
  - its confirm and menu-open jingles are 25% pulse waves (the 4th overtone missing), with a quiet echo;
  - ticks last 30 to 45 ms; jingles 170 to 215 ms with each note 25 to 80 ms.
  python tools/audio/make_ui_sounds.py [name ...]     (default: all)
Softened the same day (Preston: "a little harsh"): every pulse is built from its overtones up to TOP (6 kHz),
tapered so it does not ring, and a gentle two-stage roll-off at about 7 kHz runs on every file. Notes are
computed on A = 432 directly (confirm starts on 864 Hz, 432 x 2), so no retune pass is applied after.
Each file it replaces is kept once in docs/audio/replaced-2026-10-10/.
"""
import os, shutil, sys, wave
import numpy as np

SR = 44100
BACK = "docs/audio/replaced-2026-10-10"


def hz(note: int) -> float:
    """MIDI-style note number on A = 432 (A4 = 69)."""
    return 432.0 * 2 ** ((note - 69) / 12)


TOP = 6000.0   # highest overtone kept (Preston, 2026-10-10: "a little harsh"): rounds the corners, no aliasing


def _bandlimited(phase: np.ndarray, freq_now: np.ndarray, duty: float) -> np.ndarray:
    """A pulse built from its overtones, up to TOP Hz, tapered (sigma factors) so it does not ring."""
    out = np.zeros_like(phase)
    kmax = int(TOP / max(float(freq_now.min()), 1.0))
    for k in range(1, kmax + 1):
        keep = (k * freq_now) < TOP                         # drop an overtone where the note is too high for it
        sigma = np.sinc(k / (kmax + 1))
        out += keep * sigma * (4 / (k * np.pi)) * np.sin(np.pi * k * duty) * np.cos(2 * np.pi * k * phase - np.pi * k * duty)
    return out / 2.0


def pulse(freq: float, secs: float, duty: float) -> np.ndarray:
    n = int(SR * secs)
    t = np.arange(n) / SR
    return _bandlimited(t * freq, np.full(n, freq), duty)


def env(n: int, attack: float = 0.001, hold: float = 0.0, release: float = 0.01) -> np.ndarray:
    """Up in `attack`, flat for `hold`, then an exponential fall shaped to reach silence by the end."""
    t = np.arange(n) / SR
    up = np.minimum(1.0, t / max(attack, 1e-4))
    after = np.maximum(0.0, t - attack - hold)
    return up * np.exp(-after / max(release, 1e-4))


def notes(seq, duty: float, gap: float = 0.0) -> np.ndarray:
    """seq: [(note, secs, release)]; each note its own blip, back to back."""
    parts = []
    for note, secs, rel in seq:
        x = pulse(hz(note), secs, duty)
        parts.append(x * env(len(x), 0.002, secs * 0.35, rel))
        if gap:
            parts.append(np.zeros(int(SR * gap)))
    return np.concatenate(parts)


def echo(x: np.ndarray, delay: float, level: float) -> np.ndarray:
    d = int(SR * delay)
    out = np.zeros(len(x) + d)
    out[:len(x)] += x
    out[d:] += x * level
    return out


def write(path: str, x: np.ndarray, peak_db: float = -3.0) -> None:
    if os.path.exists(path):
        keep = os.path.join(BACK, path.replace("/", "__"))
        if not os.path.exists(keep):
            os.makedirs(BACK, exist_ok=True)
            shutil.copy2(path, keep)
    # A handheld speaker's softness: two gentle one-pole low-pass stages (about 7 kHz), taking the edge off.
    a = 1.0 - np.exp(-2 * np.pi * 7000.0 / SR)
    for _ in range(2):
        y = np.empty_like(x)
        acc = 0.0
        for i in range(len(x)):
            acc += a * (x[i] - acc)
            y[i] = acc
        x = y
    x = x / (np.abs(x).max() + 1e-9) * (10 ** (peak_db / 20))
    fade = int(SR * 0.003)
    x[-fade:] *= np.linspace(1, 0, fade)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((x * 32767).astype(np.int16).tobytes())
    print(path, "%d ms" % (len(x) * 1000 / SR))


def cursor():
    # One square tick, C6 on 432: 40 ms, flat for most of it, then gone (Sky's measured shape).
    x = pulse(hz(84), 0.040, 0.5)
    write("assets/audio/sfx/ui/cursor.wav", x * env(len(x), 0.001, 0.026, 0.006), -6.0)


def cancel():
    # A low square tick that falls away at once, then a second a fourth lower: "no, back".
    a = pulse(hz(74), 0.030, 0.5)
    b = pulse(hz(69), 0.040, 0.5)
    x = np.concatenate([a * env(len(a), 0.001, 0.0, 0.012), b * env(len(b), 0.001, 0.0, 0.016)])
    write("assets/audio/sfx/ui/cancel.wav", x, -6.0)


def confirm():
    # Two 25% pulse notes rising a fourth, A5 to D6, and a quiet echo.
    x = notes([(81, 0.030, 0.02), (86, 0.070, 0.03)], 0.25)
    write("assets/audio/sfx/ui/confirm.wav", echo(x, 0.085, 0.35), -5.0)


def menu_open():
    # Three notes up an open chord, D5 A5 D6, quick, with the echo: the menu unfolding.
    x = notes([(74, 0.045, 0.03), (81, 0.050, 0.03), (86, 0.090, 0.05)], 0.25)
    write("assets/audio/sfx/dungeon/menu_open.wav", echo(x, 0.07, 0.3), -5.0)


def menu_close():
    # The same chord folding back down, shorter.
    x = notes([(86, 0.035, 0.02), (81, 0.035, 0.02), (74, 0.060, 0.04)], 0.25)
    write("assets/audio/sfx/dungeon/menu_close.wav", echo(x, 0.06, 0.25), -6.0)


## The event set. No clean recording of Sky's own was found to measure (its effects videos are unlabelled
## and gameplay has the music over them), so these are built in the same measured family: square ticks,
## 25% pulse jingles, the quiet echo, our notes.

def noise(secs: float, dark: float) -> np.ndarray:
    """Noise softened by a one-pole low-pass (dark in 0..1, higher is darker)."""
    x = np.random.default_rng(int(secs * 1000 + dark * 100)).standard_normal(int(SR * secs))
    y = np.empty_like(x)
    acc = 0.0
    a = 1.0 - dark
    for i in range(len(x)):
        acc += a * (x[i] - acc)
        y[i] = acc
    return y / (np.abs(y).max() + 1e-9)


def glide(f0: float, f1: float, secs: float, duty: float, wobble: float = 0.0) -> np.ndarray:
    """A pulse whose pitch slides from f0 to f1 (exponentially), with an optional vibrato in Hz."""
    n = int(SR * secs)
    t = np.arange(n) / SR
    f = f0 * (f1 / f0) ** (t / secs)
    if wobble:
        f = f * (1 + 0.03 * np.sin(2 * np.pi * wobble * t))
    phase = np.cumsum(f) / SR
    return _bandlimited(phase, f, duty)


def stairs():
    # Down the steps: five quick square notes falling D6 B5 A5 F#5 D5, a soft footfall under each,
    # then a short whoosh falling away.
    parts = []
    for note in [86, 83, 81, 78, 74]:
        x = pulse(hz(note), 0.045, 0.5) * env(int(SR * 0.045), 0.001, 0.01, 0.012)
        x[:int(SR * 0.02)] += noise(0.02, 0.85) * 0.5 * np.linspace(1, 0, int(SR * 0.02))
        parts.append(x)
    whoosh = noise(0.22, 0.6) * np.linspace(0.6, 0.0, int(SR * 0.22)) ** 1.5
    write("assets/audio/sfx/dungeon/stairs.wav", np.concatenate(parts + [whoosh]), -4.0)


def pickup():
    # A bright chime rising a major arpeggio, A5 C#6 E6 A6, the last ringing, with the echo.
    x = notes([(81, 0.035, 0.02), (85, 0.035, 0.02), (88, 0.035, 0.02), (93, 0.120, 0.06)], 0.25)
    write("assets/audio/sfx/dungeon/pickup.wav", echo(x, 0.09, 0.3), -5.0)


def level_up():
    # A short fanfare: D5 F#5 A5 quick, then D6 held with a gentle vibrato over an A5 harmony; square bass D4.
    lead = notes([(74, 0.07, 0.04), (78, 0.07, 0.04), (81, 0.07, 0.04)], 0.25)
    hold_n = int(SR * 0.42)
    top = glide(hz(86), hz(86), 0.42, 0.25, wobble=6.0) * env(hold_n, 0.004, 0.18, 0.14)
    under = pulse(hz(81), 0.42, 0.25) * env(hold_n, 0.004, 0.18, 0.14) * 0.55
    bass = pulse(hz(62), 0.42, 0.5) * env(hold_n, 0.004, 0.12, 0.12) * 0.35
    x = np.concatenate([lead, top + under + bass])
    write("assets/audio/sfx/dungeon/level_up.wav", echo(x, 0.1, 0.22), -3.0)


def faint():
    # Down and out: a square sliding two octaves, A5 to A3, wobbling as it fades, then a low thud.
    slide = glide(hz(81), hz(57), 0.55, 0.5, wobble=9.0) * env(int(SR * 0.55), 0.002, 0.15, 0.2)
    thud = noise(0.12, 0.92) * np.exp(-np.arange(int(SR * 0.12)) / (SR * 0.03))
    write("assets/audio/sfx/dungeon/faint.wav", np.concatenate([slide, thud * 0.9]), -4.0)


SOUNDS = {"cursor": cursor, "cancel": cancel, "confirm": confirm, "menu_open": menu_open, "menu_close": menu_close,
          "stairs": stairs, "pickup": pickup, "level_up": level_up, "faint": faint}

if __name__ == "__main__":
    for name in (sys.argv[1:] or SOUNDS):
        SOUNDS[name]()
