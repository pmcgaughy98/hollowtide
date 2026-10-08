"""Turn the chosen ElevenLabs takes into the arena's sounds (Claude, 2026-10-07).

Preston (2026-10-07): use ElevenLabs for the arena and creature sounds for now. The takes
(two per sound, `eleven_text_to_sound_v2`, prompt influence 0.3) are in
assets/audio/sfx/arena/takes/; the prompts, flow and credits are in docs/audio/sources.md.
One take per sound was chosen by measurement (onset, decay, brightness; Preston's ears can
overrule: change PICKS). Each is decoded, trimmed to the moment that matters, faded, lowered
by 432/440 so it sits with the rest of the game, normalised and written over the synthesised
version, which is kept beside it as synth_<name>.wav for comparison.

  python tools/build_arena_takes.py
Needs ffmpeg on PATH (to decode the mp3s).
"""
import shutil
import subprocess
import sys
import wave
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build_vitrecrag_sounds import SR, fade  # noqa: E402

DIR = Path(__file__).resolve().parent.parent / "assets" / "audio" / "sfx" / "arena"
TAKES = DIR / "takes"
RETUNE = 440.0 / 432.0   # play this much slower: pitch drops to A = 432

# name: (take, start s, end s, fade in s, fade out s, peak dB)
PICKS = {
    "rock_crack": ("rock_crack_b", 0.00, 0.70, 0.002, 0.08, -3.0),
    "rock_break": ("rock_break_a", 0.00, 1.40, 0.002, 0.15, -1.0),
    "wall_slam": ("wall_slam_b", 0.04, 0.95, 0.002, 0.10, -1.0),
    "crest_ram": ("crest_ram_b", 0.30, 1.15, 0.06, 0.05, -2.0),
    "cinder_claw": ("cinder_claw_b", 0.00, 0.60, 0.002, 0.08, -3.0),
    "match_start": ("match_start_b", 0.00, 1.90, 0.01, 0.25, -3.0),
}


def decode(name: str) -> np.ndarray:
    out = subprocess.run(["ffmpeg", "-v", "error", "-i", str(TAKES / f"{name}.mp3"), "-f", "s16le", "-ac", "1", "-ar", str(SR), "-"],
                         capture_output=True, check=True).stdout
    return np.frombuffer(out, np.int16).astype(float) / 32768.0


def retune(x: np.ndarray) -> np.ndarray:
    n = int(len(x) * RETUNE)
    return np.interp(np.linspace(0, len(x) - 1, n), np.arange(len(x)), x)


def save(path: Path, x: np.ndarray, peak_db: float) -> None:
    x = x / max(1e-9, np.abs(x).max()) * 10 ** (peak_db / 20)
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((x * 32767).astype(np.int16).tobytes())


if __name__ == "__main__":
    for name, (take, a, b, fin, fout, peak) in PICKS.items():
        synth = DIR / f"{name}.wav"
        keep = DIR / f"synth_{name}.wav"
        if synth.exists() and not keep.exists():
            shutil.copy(synth, keep)
        x = decode(take)[int(a * SR):int(b * SR)]
        x = retune(fade(x, fin, fout))
        save(DIR / f"{name}.wav", x, peak)
        print(f"{name}.wav  <- {take} [{a:.2f}, {b:.2f}] s, {len(x) / SR:.2f} s at 432")
