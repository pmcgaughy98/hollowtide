"""Mix Ironvent's sounds from its physiology (Preston, 2026-09-30).

Ironvent is a living blast furnace: a coal-and-iron reptile whose dorsal vents
are organic pressure valves. So its voice is breath, fire and iron (Vitrecrag's
is brass and locomotive, so the two do not blur), and the pressure is heard at
the vents. The layers are Preston's ElevenLabs takes, copied from OneDrive
"HollowTide Sprites/Creature-Sounds" into assets/audio/sfx/ironvent/layers/:
  roar     the voice: a deep reptile roar with furnace fire in the throat
  inhale   the chest drawing breath like forge bellows
  furnace  the fire inside the body
  hiss     one vent pressurizing
  jet      one vent blowing fire and steam
  strain   iron scales creaking as they heat
  crack    the ground splitting (the finale)
  geyser   the fire geyser
  slag     sparks and slag raining down
  cool     steam sighing out, iron ticking as it cools

Most takes are one second long, so the beds are looped with crossfades and the
roar is slowed down: slower is also deeper, which is right for a final-stage
creature.

This script only mixes; nothing is generated, so re-running gives the same
files. The mixing helpers come from tools/build_vitrecrag_sounds.py.

  python tools/build_ironvent_sounds.py
Writes assets/audio/sfx/ironvent/{cry,buildup,vent_hiss,vent_jet,roar,blowdown,cool}.wav
(44.1 kHz; roar and blowdown are stereo). Where each plays in Furnace Roar is in
docs/ironvent-sound-prompts-2026-09-30.md.
"""
import subprocess
import sys
import wave
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_vitrecrag_sounds import (SR, bandpass, cavern_ir, convolve, db, fade, haas, highpass,  # noqa: E402
                                    lowpass, put, put2, ramp, speed_ramp, sub_drop, unit)

ROOT = Path(__file__).resolve().parent.parent
DIR = ROOT / "assets/audio/sfx/ironvent"


def load(name: str) -> np.ndarray:
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", str(DIR / "layers" / f"{name}.mp3"),
                          "-f", "f32le", "-ac", "1", "-ar", str(SR), "-"], capture_output=True, check=True).stdout
    return np.frombuffer(raw, np.float32).astype(np.float64)


def save(name: str, x: np.ndarray) -> None:
    """Mono (1-D) or stereo (N x 2), peak-normalized to -1 dBFS."""
    x = x / max(1e-9, np.abs(x).max()) * 10 ** (-1 / 20)
    with wave.open(str(DIR / f"{name}.wav"), "wb") as w:
        w.setnchannels(1 if x.ndim == 1 else 2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((x * 32767).astype(np.int16).tobytes())
    print(f"{name}.wav  {len(x) / SR:.2f} s  {'mono' if x.ndim == 1 else 'stereo'}")


def slowed(x: np.ndarray, speed: float) -> np.ndarray:
    """x played at a steady speed below 1: longer and deeper."""
    return speed_ramp(x, speed, speed, len(x) / SR / speed)


def looped(x: np.ndarray, seconds: float, cross: float = 0.15) -> np.ndarray:
    """A short take spread out to `seconds` as overlapping copies, three at any
    moment, each faded in and out. The takes die away over their one second, so
    a plain end-to-end loop pulses; overlapping them keeps the level steady.
    (`cross` is unused now and kept so callers read the same.)"""
    n = int(seconds * SR)
    window = np.hanning(len(x))
    hop = len(x) // 3
    out = np.zeros(n + len(x) * 2)
    at = -2 * hop  # start early so the first moment already has three copies
    while at < n:
        a, b = max(0, at), at + len(x)
        out[a:b] += (x * window)[a - at:]
        at += hop
    return out[:n]


def drive(x: np.ndarray, amount: float) -> np.ndarray:
    """Soft saturation: thicker and louder without sharp clipping."""
    return np.tanh(x * amount) / np.tanh(amount)


def voice(speed: float) -> np.ndarray:
    """Ironvent's roar at a given speed, with a chest under it: a muffled,
    driven copy an octave-ish lower, the way a huge ribcage resonates."""
    r = unit(load("roar_a"))
    dry = slowed(r, speed)
    chest = drive(lowpass(slowed(r, speed * 0.5), 320), 2.5)
    out = np.zeros(max(len(dry), len(chest)))
    put(out, dry, 0.0, 1.0)
    put(out, chest, 0.0, db(-5))
    return out


def cry() -> np.ndarray:
    """The title card: the roar, slowed and chested, the furnace behind it and a
    curl of vent steam at the tail."""
    v = voice(0.62)
    n = len(v) + int(0.35 * SR)
    out = np.zeros(n)
    put(out, fade(v, 0.01, 0.25), 0.0, 1.0)
    put(out, fade(lowpass(looped(unit(load("furnace_a")), n / SR), 400), 0.05, 0.4), 0.0, db(-12))
    hiss = highpass(unit(load("hiss_b"))[: int(0.6 * SR)], 3000)
    put(out, fade(hiss, 0.05, 0.4), 1.3, db(-16))
    # The card's close-up holds about 1.4 s, so the cry is over before the attack begins.
    return fade(out[: int(1.9 * SR)], 0.005, 0.5)


def buildup(seconds: float = 1.83) -> np.ndarray:
    """Frames 0 to 4: the chest draws breath like bellows, rising in pitch; the
    furnace swells from a muffled rumble to an open roar; the iron scales creak
    more and more. The per-vent hisses are not in here: the battle plays one as
    each vent lights (vent_hiss.wav), so they stay in step with the picture."""
    n = int(seconds * SR)
    out = np.zeros(n)
    breath = speed_ramp(unit(load("inhale_a")), 0.42, 0.7, seconds)
    put(out, fade(breath, 0.08, 0.05), 0.0, ramp(len(breath), db(-10), db(-2), 1.5))
    fire = looped(unit(load("furnace_b")), seconds)
    fire = lowpass(fire, ramp(n, 180, 2600, 2.0))  # heard through the body, then opening up
    put(out, fire, 0.0, ramp(n, db(-16), db(-3), 1.6))
    creak = bandpass(looped(unit(load("strain_a")), seconds, 0.1), 900, 7000)
    put(out, creak, 0.0, ramp(n, db(-30), db(-9), 2.2))
    ping = highpass(unit(load("strain_b")), 2500)
    put(out, fade(ping, 0.01, 0.2), seconds - 1.0, db(-12))
    return fade(out, 0.02, 0.03)


def vent_hiss() -> np.ndarray:
    """One vent pressurizing: a hard, short puff. The battle raises its pitch a
    step for each vent from tail to head, so the pressure is heard climbing."""
    h = highpass(unit(load("hiss_b")), 1500)
    start = int(np.argmax(np.abs(h) > 0.2))
    h = h[start: start + int(0.42 * SR)]
    h = h * np.exp(-np.linspace(0, 3.2, len(h)))
    thump = lowpass(unit(load("jet_a"))[: int(0.12 * SR)], 500) * np.exp(-np.linspace(0, 6, int(0.12 * SR)))
    out = np.zeros(len(h))
    put(out, h, 0.0, 1.0)
    put(out, thump, 0.0, db(-6))  # the little knock of the valve opening
    return fade(out, 0.002, 0.08)


def vent_jet() -> np.ndarray:
    """One vent blowing: the jet, with its scream pushed forward."""
    j = unit(load("jet_b"))[: int(1.3 * SR)]
    out = np.zeros(len(j))
    put(out, j, 0.0, 1.0)
    put(out, drive(bandpass(j, 2000, 9000), 2.0), 0.0, db(-6))
    put(out, highpass(unit(load("jet_a"))[: int(0.25 * SR)], 800), 0.0, db(-3))  # the hard first burst
    return fade(out, 0.002, 0.45)


def roar(seconds: float = 2.6) -> np.ndarray:
    """Frame 5, the release: the full roar; a lower, slower copy carrying on
    under it as the breath keeps pouring out; the furnace wide open; and the
    field's geysers erupting underneath. The battle fades this at the hush
    before the finale, so it does not need its own ending."""
    n = int(seconds * SR)
    out = np.zeros((n, 2))
    put2(out, voice(0.72), 0.0, 1.0)
    put2(out, fade(drive(lowpass(voice(0.4), 900), 1.8), 0.3, 0.4), 0.55, db(-6))
    fire = looped(unit(load("furnace_b")), seconds)
    put2(out, fire, 0.0, ramp(n, db(-8), db(-12)))
    field = looped(unit(load("geyser_a")), seconds, 0.3)
    put2(out, haas(lowpass(field, 3500), 0.018), 0.15, ramp(n, db(-16), db(-8)))
    return out


def blowdown(seconds: float = 3.4) -> np.ndarray:
    """Frame 7, the finale: the ground under the opponent gives way. One job per
    layer, each in its own band (docs/audio-research-takeaways-2026-09-29.md):
    the crack as the transient, a sine drop for the weight, the geyser as the
    body, Ironvent's roar pitched down as the voice, slag rain as the sparkle,
    and an open-air tail."""
    n = int(seconds * SR)
    out = np.zeros((n, 2))
    crack = unit(load("crack_b"))
    snap = np.clip(highpass(crack, 1000)[: int(0.12 * SR)] * 3.0, -1, 1)
    put2(out, fade(snap, 0.0005, 0.03), 0.0, db(0))
    put2(out, sub_drop(0.55, 85.0, 28.0), 0.0, db(-2))
    put2(out, fade(bandpass(crack, 150, 1200), 0.002, 0.3), 0.01, db(-5))
    geyser = looped(unit(load("geyser_a")), 2.4, 0.3)
    g = len(geyser)
    put2(out, fade(geyser, 0.01, 0.9), 0.03, ramp(g, db(-3), db(-10), 0.7))
    put2(out, fade(drive(lowpass(voice(0.5), 1400), 2.0), 0.02, 0.5), 0.05, db(-5))
    slag = highpass(looped(unit(load("slag_b")), 2.4, 0.2), 3500)
    put2(out, haas(fade(slag, 0.3, 1.0), 0.013), 0.35, db(-11))
    ticks = highpass(unit(load("strain_b")), 3000)
    put2(out, haas(fade(ticks, 0.01, 0.4), 0.02), 1.6, db(-16))
    # The space: shorter and brighter than Vitrecrag's cavern, since this is open ground.
    dry = out.mean(axis=1)[: int(1.2 * SR)]
    wet_l = convolve(dry, cavern_ir(1.8, 11))[:n]
    wet_r = convolve(dry, cavern_ir(1.8, 12))[:n]
    wet = np.stack([unit(wet_l), unit(wet_r)], axis=1)
    put2(out, wet[: n - int(0.04 * SR)], 0.04, db(-14))
    return out


def cool(seconds: float = 2.0) -> np.ndarray:
    """Frames 8 and 9: the vents sigh out and the iron ticks as it contracts."""
    n = int(seconds * SR)
    out = np.zeros(n)
    sigh = unit(load("hiss_a"))[int(1.0 * SR): int(1.0 * SR) + n]
    sigh = lowpass(sigh, ramp(len(sigh), 9000, 900, 0.8))  # the hiss darkens as the pressure drops
    put(out, fade(sigh, 0.05, 0.8), 0.0, ramp(len(sigh), db(-6), db(-24)))
    put(out, fade(unit(load("cool_a")), 0.01, 0.3), 0.15, db(-8))
    put(out, fade(unit(load("cool_b")), 0.01, 0.4), 0.95, db(-12))
    return fade(out, 0.02, 0.3)


if __name__ == "__main__":
    for name, make in (("cry", cry), ("buildup", buildup), ("vent_hiss", vent_hiss), ("vent_jet", vent_jet),
                       ("roar", roar), ("blowdown", blowdown), ("cool", cool)):
        save(name, make())
