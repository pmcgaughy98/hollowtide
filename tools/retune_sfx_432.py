"""Lower the sound effects that were never retuned to A = 432 Hz (Claude, 2026-10-08).

The 432 check (`tools/audio_432_check.py`) found four synthesised creature sets built with no
reference to 432 at all: Ironvent, Root Rampart, Stormlantern and Undertow. Undertow's peaks
sit exactly on the A = 440 grid (220, 165, 330 Hz), so they were tuned to 440. Like the music
(`tools/retune_432.sh`), each file is lowered once by 432/440 (a resample, so about 1.8%
slower and a third of a semitone lower) from a kept original, so running this twice never
lowers a file twice. Originals: docs/audio/sfx-440-originals-2026-10-08/<set>/<file>.

  python tools/retune_sfx_432.py
"""
import shutil
import wave
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent.parent
SETS = ["ironvent", "root_rampart", "stormlantern", "undertow"]
KEEP = ROOT / "docs/audio/sfx-440-originals-2026-10-08"
RETUNE = 440.0 / 432.0


def read(path: Path):
    with wave.open(str(path)) as w:
        return w.getparams(), np.frombuffer(w.readframes(w.getnframes()), np.int16)


def write(path: Path, params, data: np.ndarray) -> None:
    with wave.open(str(path), "wb") as w:
        w.setparams(params._replace(nframes=len(data) // params.nchannels))
        w.writeframes(data.astype(np.int16).tobytes())


for s in SETS:
    folder = ROOT / "assets/audio/sfx" / s
    for f in sorted(folder.glob("*.wav")):
        keep = KEEP / s / f.name
        keep.parent.mkdir(parents=True, exist_ok=True)
        if not keep.exists():
            shutil.copy(f, keep)
        params, data = read(keep)
        ch = params.nchannels
        frames = data.reshape(-1, ch).astype(float)
        n = int(len(frames) * RETUNE)
        out = np.stack([np.interp(np.linspace(0, len(frames) - 1, n), np.arange(len(frames)), frames[:, c]) for c in range(ch)], axis=1)
        write(f, params, np.clip(out, -32768, 32767).reshape(-1))
        print("retuned", f.relative_to(ROOT).as_posix(), "%.2f s -> %.2f s" % (len(frames) / params.framerate, n / params.framerate))
