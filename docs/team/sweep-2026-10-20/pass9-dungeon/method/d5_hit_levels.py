"""Pass 9 D5 (Claude, 2026-10-27, dungeon lane): the audit's wavs.py measures, with the level each hit plays at
in dungeon.gd added, so the three hit sounds can be ordered as the player hears them.
python -I d5_hit_levels.py <repo>/assets/audio/sfx/dungeon
Prints peak, RMS and loudest 50 ms for each wav, raw and with its play level, and the order for each measure."""
import sys
import wave
from pathlib import Path

import numpy as np

LEVELS = {"hit_light": -4.0, "hit_heavy": -7.5, "hit_super": -4.0}   # dungeon.gd: -4.0, HIT_HEAVY_DB, -4.0


def measure(p: Path) -> dict:
    with wave.open(str(p)) as w:
        n, ch, sw, sr = w.getnframes(), w.getnchannels(), w.getsampwidth(), w.getframerate()
        raw = w.readframes(n)
    dt = {1: np.int8, 2: np.int16, 4: np.int32}[sw]
    a = np.frombuffer(raw, dtype=dt).astype(np.float64).reshape(-1, ch) / float(2 ** (8 * sw - 1))
    m = a.mean(axis=1)
    win = int(sr * 0.05)
    best = max(np.sqrt((m[i:i + win] ** 2).mean()) for i in range(0, max(1, len(m) - win), max(1, win // 4)))
    db = lambda x: 20 * np.log10(max(x, 1e-9))
    return {"peak": db(np.abs(a).max()), "rms": db(np.sqrt((m ** 2).mean())), "loudest 50 ms": db(best)}


d = Path(sys.argv[1])
rows = {name: measure(d / (name + ".wav")) for name in LEVELS}
for name, r in rows.items():
    played = {k: v + LEVELS[name] for k, v in r.items()}
    print(f"{name:10s} plays at {LEVELS[name]:+.1f} dB | raw peak {r['peak']:6.1f} RMS {r['rms']:6.1f} 50ms {r['loudest 50 ms']:6.1f} | "
          f"as played peak {played['peak']:6.1f} RMS {played['rms']:6.1f} 50ms {played['loudest 50 ms']:6.1f}")
for k in ["loudest 50 ms", "peak", "rms"]:
    order = sorted(LEVELS, key=lambda n: rows[n][k] + LEVELS[n])
    want = order == ["hit_light", "hit_heavy", "hit_super"]
    print(f"as played, quietest to loudest by {k}: {' < '.join(order)} -> {'light < heavy < super' if want else 'NOT light < heavy < super'}")
