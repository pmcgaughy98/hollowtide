"""Loudness and shape of the dungeon hit sounds (pass 9 audit, scratch, read-only).
python -I wavs.py <dir> name1 name2 ... : length, peak dBFS, RMS dBFS, the loudest 50 ms window, DC offset, clipped samples,
and the time of the peak (the attack)."""
import sys
import wave
import numpy as np
from pathlib import Path

d = Path(sys.argv[1])
for name in sys.argv[2:]:
    p = d / (name + ".wav")
    with wave.open(str(p)) as w:
        n, ch, sw, sr = w.getnframes(), w.getnchannels(), w.getsampwidth(), w.getframerate()
        raw = w.readframes(n)
    dt = {1: np.int8, 2: np.int16, 4: np.int32}[sw]
    a = np.frombuffer(raw, dtype=dt).astype(np.float64).reshape(-1, ch) / float(2 ** (8 * sw - 1))
    m = a.mean(axis=1)
    peak = np.abs(a).max()
    rms = np.sqrt((m ** 2).mean())
    win = int(sr * 0.05)
    best = max(np.sqrt((m[i:i + win] ** 2).mean()) for i in range(0, max(1, len(m) - win), max(1, win // 4)))
    clip = int((np.abs(a) >= 0.999).sum())
    lead = int(np.argmax(np.abs(m) > 0.02)) / sr
    tail = len(m) - int(np.argmax(np.abs(m[::-1]) > 0.01))
    db = lambda x: 20 * np.log10(max(x, 1e-9))
    print(f"{name}: {n / sr:.3f} s, {sr} Hz, {ch} ch, {8 * sw} bit | peak {db(peak):6.1f} dBFS, RMS {db(rms):6.1f}, loudest 50 ms {db(best):6.1f} | "
          f"DC {m.mean():+.4f} | clipped {clip} | first sound at {lead * 1000:.0f} ms | audible to {tail / sr * 1000:.0f} ms")
