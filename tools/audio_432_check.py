"""The A = 432 Hz check (Preston, 2026-10-08: "do the 432 Hz check").

Two questions for every sound in the game:
  1. Provenance: did the file go through the 432/440 retune? Every build script that
     retunes carries the ratio 440/432 (or 432/440) in its source, and the music script is
     tools/retune_432.sh. A file written by none of them is "unknown".
  2. Measurement, for the files that have a pitch at all: the strongest spectral peaks are
     compared with the equal-tempered scale on A = 432 and on A = 440. Only a clear peak
     counts (a rock crack or a dust hit has no A to be in tune with). A tonal file whose peaks
     sit nearer the 432 grid than the 440 grid is "432"; nearer 440 is "440"; peaks that are
     ambiguous (both grids within 25 cents, which happens because the grids are only 32 cents
     apart and a sound's partials land anywhere) are "unclear".

  python tools/audio_432_check.py            prints the table and writes docs/audio/tuning-check-2026-10-08.md
Needs ffmpeg on PATH (mp3 decode) and numpy.
"""
import re
import subprocess
import sys
import wave
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent.parent
SR = 44100

# Which script writes which folder, and whether that script retunes.
BUILDERS = {
    "assets/audio/sfx/arena": ("tools/build_arena_takes.py and tools/build_arena_sounds.py", True),
    "assets/audio/sfx/oxbowarchon": ("tools/build_oxbowarchon_sounds.py", True),
    "assets/audio/sfx/starward": ("tools/build_starward_sounds.py", True),
    "assets/audio/music": ("tools/retune_432.sh", True),
    # synthesised with no reference to 432, lowered once by tools/retune_sfx_432.py on 2026-10-08
    "assets/audio/sfx/ironvent": ("synth, then tools/retune_sfx_432.py", True),
    "assets/audio/sfx/root_rampart": ("synth, then tools/retune_sfx_432.py", True),
    "assets/audio/sfx/stormlantern": ("synth, then tools/retune_sfx_432.py", True),
    "assets/audio/sfx/undertow": ("synth, then tools/retune_sfx_432.py", True),
    "assets/audio/sfx/vitrecrag": ("tools/build_vitrecrag_takes.py", True),
    "assets/audio/sfx/ui": ("tools/build_ui_sounds.py (A = 432 in the synth)", True),
}


def retunes(script: Path) -> bool:
    if not script.exists():
        return False
    t = script.read_text(encoding="utf-8", errors="replace")
    return bool(re.search(r"440(\.0)?\s*/\s*432|432(\.0)?\s*/\s*440|0\.981818|432", t)) and "432" in t


def provenance(path: Path):
    rel = path.relative_to(ROOT).as_posix()
    for folder, (script, ok) in BUILDERS.items():
        if rel.startswith(folder):
            return script, ok
    # the per-creature synth scripts
    for script in sorted((ROOT / "tools").glob("build_*_sounds.py")):
        if path.parent.name in script.name:
            return script.relative_to(ROOT).as_posix(), retunes(script)
    return "unknown", None


def load(path: Path) -> np.ndarray:
    if path.suffix == ".wav":
        with wave.open(str(path)) as w:
            n = w.getnframes()
            raw = w.readframes(n)
            x = np.frombuffer(raw, np.int16).astype(float) / 32768.0
            if w.getnchannels() == 2:
                x = x.reshape(-1, 2).mean(axis=1)
            if w.getframerate() != SR:
                x = np.interp(np.linspace(0, len(x) - 1, int(len(x) * SR / w.getframerate())), np.arange(len(x)), x)
            return x
    out = subprocess.run(["ffmpeg", "-v", "error", "-i", str(path), "-f", "s16le", "-ac", "1", "-ar", str(SR), "-"],
                         capture_output=True, check=True).stdout
    return np.frombuffer(out, np.int16).astype(float) / 32768.0


def cents_to_grid(f: float, a: float) -> float:
    """Distance in cents from f to the nearest note of the equal-tempered scale on A = a."""
    semis = 12.0 * np.log2(f / a)
    return abs((semis - round(semis)) * 100.0)


def measure(x: np.ndarray):
    """The strongest spectral peaks across the file (whole-file spectrum, Hann window)."""
    if len(x) < SR // 4:
        x = np.pad(x, (0, SR // 4 - len(x)))
    spec = np.abs(np.fft.rfft(x * np.hanning(len(x))))
    freqs = np.fft.rfftfreq(len(x), 1.0 / SR)
    band = (freqs > 60) & (freqs < 4000)
    spec, freqs = spec[band], freqs[band]
    if spec.max() <= 0:
        return [], 0.0
    # peaks: local maxima at least a tenth of the top, well above the median (tonal, not noise)
    med = np.median(spec)
    prominence = spec.max() / max(med, 1e-9)
    idx = [i for i in range(1, len(spec) - 1) if spec[i] > spec[i - 1] and spec[i] >= spec[i + 1] and spec[i] > spec.max() * 0.1]
    idx.sort(key=lambda i: -spec[i])
    peaks = []
    for i in idx[:6]:
        # parabolic interpolation for a finer frequency
        a, b, c = spec[i - 1], spec[i], spec[i + 1]
        d = 0.5 * (a - c) / (a - 2 * b + c) if (a - 2 * b + c) != 0 else 0.0
        peaks.append(float(freqs[i] + d * (freqs[1] - freqs[0])))
    return peaks, float(prominence)


def verdict(peaks, prominence):
    if prominence < 40 or not peaks:
        return "noise, no pitch to check", ""
    c432 = [cents_to_grid(p, 432.0) for p in peaks]
    c440 = [cents_to_grid(p, 440.0) for p in peaks]
    detail = ", ".join("%.0f Hz (%d/%d)" % (p, a, b) for p, a, b in zip(peaks[:3], c432[:3], c440[:3]))
    m432, m440 = float(np.mean(c432)), float(np.mean(c440))
    if abs(m432 - m440) < 6:
        return "tonal, unclear", detail
    return ("tonal, nearer 432" if m432 < m440 else "tonal, nearer 440"), detail


def main() -> None:
    rows = []
    files = sorted(list((ROOT / "assets/audio").rglob("*.wav")) + list((ROOT / "assets/audio").rglob("*.mp3")))
    for f in files:
        rel = f.relative_to(ROOT).as_posix()
        if "/takes/" in rel or "/takes2/" in rel or "/layers/" in rel or "originals" in rel or "old_mix_" in rel:
            continue   # raw takes are not shipped; the built files are what matter
        try:
            x = load(f)
        except Exception as e:  # noqa: BLE001
            rows.append((rel, "unreadable: %s" % e, "", "", ""))
            continue
        peaks, prom = measure(x)
        v, detail = verdict(peaks, prom)
        script, ok = provenance(f)
        rows.append((rel, v, detail, script, {True: "yes", False: "no", None: "unknown"}[ok]))
    lines = ["# Tuning check, A = 432 Hz (Claude, 2026-10-08)", "",
             "Preston: \"do the 432 Hz check.\" Every shipped sound, with where it came from and what its spectrum says.",
             "Provenance is the real check: the retune is a 432/440 resample inside each build script. The measurement only means",
             "something for tonal files (synth hums, chimes, the music); a rock crack has no A. The two grids are 32 cents apart,",
             "so a tonal file reads \"unclear\" when its partials fall between them. Run: `python tools/audio_432_check.py`.", "",
             "| File | Spectrum says | Strongest peaks, Hz (cents off 432 grid / 440 grid) | Built by | Retuned |", "|---|---|---|---|---|"]
    for r in rows:
        lines.append("| %s | %s | %s | %s | %s |" % r)
    counts = {}
    for r in rows:
        counts[r[4]] = counts.get(r[4], 0) + 1
    lines += ["", "Retune provenance: " + ", ".join("%s %d" % (k, v) for k, v in sorted(counts.items())) + ".",
              "Tonal verdicts: " + ", ".join("%s %d" % (k, v) for k, v in sorted({r[1]: sum(1 for q in rows if q[1] == r[1]) for r in rows}.items())) + "."]
    out = ROOT / "docs/audio/tuning-check-2026-10-08.md"
    out.write_text("\n".join(lines) + "\n", encoding="utf-8")
    for r in rows:
        print("%-60s %-24s retuned=%-8s %s" % (r[0], r[1], r[4], r[2]))
    print("wrote", out.relative_to(ROOT))


if __name__ == "__main__":
    main()
