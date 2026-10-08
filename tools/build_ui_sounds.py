"""Build Hollowtide's interface and feedback sounds (Preston, 2026-09-30).

The world and the creatures are recorded and layered (build_vitrecrag_sounds.py,
build_ironvent_sounds.py); menus and game feedback are made here.

Preston, after hearing the first raw square-wave set: "I don't want it to
sound bit-like, more like Coromon, but it's a good foundation." So the notes,
lengths and moments are the same, but the voices are soft and rounded, the
polished handheld-era sound rather than bare chip beeps:
  pluck   a mallet-like tone with a quiet chip pulse under it (the CHIP setting)
  chime   the same with a glassy, bell-like shimmer, for the happy sounds
  puff    smooth filtered noise, for thumps and whooshes (not stepped chip noise)
and every sound gets a very short room tail so it does not stop dead.

Everything is synthesized, so it costs no credits and re-running gives the
same files.

Every note comes from the five-note scale G A B D E. The battle theme is in
E minor and the menu and victory themes are in G major (the same notes), and
those five also fit the route theme in C major, so a menu sound never lands on
a wrong note over the music. (Keys measured from the tracks, 2026-09-30.)

  python tools/build_ui_sounds.py
Writes assets/audio/sfx/ui/*.wav (mono, 44.1 kHz).
"""
import wave
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent.parent
DIR = ROOT / "assets/audio/sfx/ui"
SR = 44100

# Concert pitch. Preston, 2026-10-06: the whole game is tuned to A = 432 Hz (the
# music was retuned with tools/retune_432.sh), so these notes are too, to stay in
# tune with it. The 440 set is in docs/audio/ui-sounds-440-2026-10-06/.
A4 = 432.0

# The scale, by name. Octave 4 starts at middle C.
SEMITONE = {"C": 0, "D": 2, "E": 4, "F#": 6, "G": 7, "A": 9, "B": 11}


def hz(note: str) -> float:
    """'E5' -> 659.26."""
    name, octave = note[:-1], int(note[-1])
    return A4 * 2 ** ((SEMITONE[name] - 9) / 12 + (octave - 4))


def t(seconds: float) -> np.ndarray:
    return np.arange(int(seconds * SR)) / SR


def phase(freq, seconds: float) -> np.ndarray:
    """Running phase for a fixed pitch or a per-sample pitch curve."""
    n = int(seconds * SR)
    f = np.broadcast_to(np.asarray(freq, dtype=np.float64), (n,))
    return np.cumsum(f) / SR


## How much chip character sits under each note, 0 to 1. Preston, 2026-09-30:
## "not too bit-like": the first set (1.0, bare square waves) was too much and
## the second (0.0, all soft) lost the retro feel. This is the blend.
CHIP = 0.35


def pulse(freq, seconds: float, duty: float = 0.25) -> np.ndarray:
    """The old chip voice: a pulse wave with its harsh top taken off."""
    raw = np.where(phase(freq, seconds) % 1.0 < duty, 1.0, -1.0)
    return lowpass(raw, 3200.0)


def mallet(freq, seconds: float, bright: float = 1.6, ratio: float = 2.0) -> np.ndarray:
    """A mallet tone. A sine whose tone is bent by a second, faster sine (FM);
    the bend dies away quickly, so it starts bright and ends pure and round."""
    n = int(seconds * SR)
    ph = 2 * np.pi * phase(freq, seconds)
    bend = bright * np.exp(-np.linspace(0, 9, n))
    return np.sin(ph + bend * np.sin(ratio * ph))


def pluck(freq, seconds: float, bright: float = 1.6, ratio: float = 2.0) -> np.ndarray:
    """The main voice: the soft mallet with a quiet chip pulse under it, so it
    is rounded but still reads as a retro game."""
    return (1.0 - CHIP) * mallet(freq, seconds, bright, ratio) + CHIP * 0.7 * pulse(freq, seconds)


def chime(freq, seconds: float) -> np.ndarray:
    """A small bell: the pluck with an off-ratio shimmer on top."""
    return 0.8 * pluck(freq, seconds, 1.2, 2.0) + 0.35 * pluck(freq, seconds, 2.2, 3.5)


def round_tone(freq, seconds: float) -> np.ndarray:
    """The warm low voice: a sine with a little of its octave."""
    ph = 2 * np.pi * phase(freq, seconds)
    return np.sin(ph) + 0.25 * np.sin(2 * ph)


def lowpass(x: np.ndarray, cutoff) -> np.ndarray:
    """One-pole low-pass; cutoff is a number or one value per sample (a sweep)."""
    fc = np.broadcast_to(np.asarray(cutoff, dtype=np.float64), x.shape)
    a = 1.0 - np.exp(-2.0 * np.pi * fc / SR)
    out = np.empty(len(x))
    acc = 0.0
    for k in range(len(x)):
        acc += a[k] * (x[k] - acc)
        out[k] = acc
    return out


def puff(seconds: float, lo: float, hi, seed: int = 7) -> np.ndarray:
    """Smooth noise between two pitches: a soft thump, tick or whoosh."""
    rng = np.random.default_rng(seed)
    x = rng.standard_normal(int(seconds * SR))
    x = lowpass(lowpass(x, hi), hi)
    return x - lowpass(x, lo)


def decay(x: np.ndarray, rate: float, attack: float = 0.004) -> np.ndarray:
    """A struck shape: a short soft rise, then dying away."""
    n = len(x)
    env = np.exp(-np.linspace(0, rate, n))
    a = max(1, int(attack * SR))
    env[:a] *= np.sin(np.linspace(0, np.pi / 2, a)) ** 2
    tail = max(1, int(0.008 * SR))
    env[-tail:] *= np.linspace(1, 0, tail)
    return x * env


def room(x: np.ndarray, seconds: float = 0.22, level: float = 0.16, seed: int = 5) -> np.ndarray:
    """A very short, soft room tail, so a sound does not stop dead."""
    rng = np.random.default_rng(seed)
    n = int(seconds * SR)
    ir = lowpass(rng.standard_normal(n) * np.exp(-np.linspace(0, 7, n)), 3500)
    size = 1 << (len(x) + n - 2).bit_length()
    wet = np.fft.irfft(np.fft.rfft(x, size) * np.fft.rfft(ir, size), size)[: len(x) + n - 1]
    out = np.zeros(len(wet))
    out[: len(x)] += x
    return out + wet * level * (np.abs(x).max() / max(1e-9, np.abs(wet).max()))


def seq(parts: list, gap: float = 0.0) -> np.ndarray:
    """Notes one after another."""
    pieces = []
    for p in parts:
        pieces.append(p)
        if gap:
            pieces.append(np.zeros(int(gap * SR)))
    return np.concatenate(pieces)


def mix(*layers) -> np.ndarray:
    n = max(len(layer) for layer in layers)
    out = np.zeros(n)
    for layer in layers:
        out[: len(layer)] += layer
    return out


def note(name: str, seconds: float, rate: float = 5.0, voice=pluck, **kw) -> np.ndarray:
    return decay(voice(hz(name), seconds, **kw), rate)


# ------------------------------------------------------------------ the sounds

## Preston, 2026-10-06: the button sounds were "too 8-bit and harsh, it would get
## tiring fast". The four menu sounds below are now soft and warm: no chip pulse,
## an octave lower, a gentle rise instead of a click, and the top rolled off. They
## play hundreds of times a session, so they sit quietly under everything. The
## battle feedback sounds (hits, catching) keep the blended retro voice.
## The previous set is in docs/audio/ui-sounds-before-2026-10-06/.

def soft(freq, seconds: float) -> np.ndarray:
    """The menu voice: a mellow mallet (barely any bright bend) with the top
    rolled off, like a felt-tipped marimba."""
    return lowpass(mallet(freq, seconds, 0.35, 2.0), 1800.0)


def soft_note(name: str, seconds: float, rate: float = 6.0) -> np.ndarray:
    return decay(soft(hz(name), seconds), rate, attack=0.012)


def cursor() -> np.ndarray:
    """Moving between menu choices: one low, soft wooden tap."""
    return soft_note("E4", 0.09, 7.0)


def confirm() -> np.ndarray:
    """Choosing: two soft notes up, close together."""
    return seq([soft_note("B4", 0.07, 4.0), soft_note("E5", 0.22, 6.0)])


def cancel() -> np.ndarray:
    """Backing out or fleeing: two soft notes down."""
    return seq([soft_note("E4", 0.07, 4.0), soft_note("B3", 0.22, 6.0)])


def text() -> np.ndarray:
    """One letter-tick of the message typing out: a tiny muted pip. The game
    nudges its pitch a little each time, so a line of them reads as a voice."""
    return soft_note("G4", 0.035, 6.0)


def hit() -> np.ndarray:
    """The tick layered over a normal hit: a soft snap and a low round thump."""
    snap = decay(puff(0.06, 900, 5000, 4), 9.0)
    thump = decay(round_tone(np.geomspace(hz("E3"), hz("E2"), int(0.12 * SR)), 0.12), 6.0)
    return mix(snap * 0.6, thump)


def hit_strong() -> np.ndarray:
    """A strong matchup: the hit, then three bright notes rising."""
    sting = seq([note("E5", 0.045, 2.0, chime), note("G5", 0.045, 2.0, chime), note("B5", 0.22, 5.0, chime)])
    return mix(hit(), np.concatenate([np.zeros(int(0.03 * SR)), sting * 0.8]))


def hit_weak() -> np.ndarray:
    """A weak matchup: a dull thud and one note sagging down."""
    thud = decay(puff(0.08, 150, 900, 3), 8.0)
    sag = decay(round_tone(np.geomspace(hz("D4"), hz("B3"), int(0.2 * SR)), 0.2), 5.0)
    return mix(thud * 0.8, sag)


def hp_drain() -> np.ndarray:
    """HP sliding down: a quick soft run of notes stepping down the scale."""
    return seq([note(n, 0.05, 3.5, bright=0.9) for n in ("E5", "D5", "B4", "A4", "G4", "E4")]) * 0.8


def faint() -> np.ndarray:
    """A creature fainting: one round note sliding down an octave, wobbling as it goes."""
    n = int(0.6 * SR)
    glide = np.geomspace(hz("B4"), hz("B3"), n) * (1.0 + 0.015 * np.sin(2 * np.pi * 7 * np.arange(n) / SR))
    return decay(round_tone(glide, 0.6), 2.4, 0.02)


def catch_reach() -> np.ndarray:
    """Reaching for a creature: a soft rising whoosh with a note climbing inside it."""
    n = int(0.3 * SR)
    shape = np.sin(np.linspace(0, np.pi, n)) ** 1.5
    whoosh = puff(0.3, 300, np.geomspace(800, 6000, n), 9) * shape
    rise = round_tone(np.geomspace(hz("G4"), hz("G5"), n), 0.3) * shape
    return mix(whoosh * 0.7, rise * 0.6)


def catch_success() -> np.ndarray:
    """Caught: a short chime jingle up the chord, the last note ringing."""
    lead = seq([note("G5", 0.075, 2.0, chime), note("B5", 0.075, 2.0, chime), note("D6", 0.075, 2.0, chime),
                note("G6", 0.5, 4.5, chime)])
    bass = np.concatenate([np.zeros(int(0.225 * SR)), decay(round_tone(hz("G3"), 0.5), 3.5)])
    return mix(lead, bass * 0.6)


def catch_fail() -> np.ndarray:
    """It broke free: a soft pop and two notes falling."""
    pop = decay(puff(0.04, 600, 4000, 11), 8.0)
    fall = seq([note("D5", 0.07, 3.0, bright=0.7), note("A4", 0.2, 5.0, bright=0.7)])
    return mix(pop * 0.6, np.concatenate([np.zeros(int(0.02 * SR)), fall]))


def encounter() -> np.ndarray:
    """A battle beginning: a fast run up the scale into a held chime."""
    run = seq([note(n, 0.04, 1.8, bright=1.2) for n in ("E4", "G4", "A4", "B4", "D5", "E5", "G5")])
    return np.concatenate([run, note("B5", 0.4, 4.5, chime)])


SOUNDS = {
    "cursor": (cursor, -9), "confirm": (confirm, -7), "cancel": (cancel, -7), "text": (text, -13),
    "hit": (hit, -3), "hit_strong": (hit_strong, -2), "hit_weak": (hit_weak, -4), "hp_drain": (hp_drain, -8),
    "faint": (faint, -4), "catch_reach": (catch_reach, -5), "catch_success": (catch_success, -3),
    "catch_fail": (catch_fail, -4), "encounter": (encounter, -4),
}


def save(name: str, x: np.ndarray, peak_db: float) -> None:
    """Peak-normalized to its own level, so quiet sounds (the text tick) are
    quiet in the file and need no volume setting in the game."""
    x = room(x) if name != "text" else x  # the text tick stays dry: it repeats fast
    x = x / max(1e-9, np.abs(x).max()) * 10 ** (peak_db / 20)
    with wave.open(str(DIR / f"{name}.wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((x * 32767).astype(np.int16).tobytes())
    print(f"{name}.wav  {len(x) / SR:.3f} s  peak {peak_db} dB")


if __name__ == "__main__":
    DIR.mkdir(parents=True, exist_ok=True)
    for name, (make, level) in SOUNDS.items():
        save(name, make(), level)
