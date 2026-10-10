"""Sample Preston's Suno songs into the tracks he could not make, and cut songs into their sections
(Claude, 2026-10-09; Preston: "some of them have parts that are good and maybe you could mix it up
and sample it a bit... make everything 432 hz"). Claude cannot hear: sections are picked by measured
loudness and brightness, so every result is a draft for Preston's ears.

  python tools/audio/remix.py missing          builds the four missing tracks from the 432 Hz songs
  python tools/audio/remix.py monster          remakes Monster House from the Guardian and Monster House's best part
  python tools/audio/remix.py final            builds The Last Stand at the Hollow's Heart from three songs
  python tools/audio/remix.py sections <name>  cuts assets/audio/music/<name>.mp3 into its sections
                                               (where the sound changes), into docs/audio/sections/<name>/
All input is already at 432 Hz, and nothing here changes pitch, so the results stay at 432."""
import subprocess, sys
from pathlib import Path
import numpy as np

MUSIC = Path("assets/audio/music")
SR = 22050


def load(path: Path) -> np.ndarray:
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", str(path), "-ac", "1", "-ar", str(SR), "-f", "f32le", "-"], capture_output=True).stdout
    return np.frombuffer(raw, np.float32)


def per_second(x: np.ndarray) -> tuple:
    """Loudness and brightness (spectral centroid) for each second."""
    n = len(x) // SR
    rms, bright = np.zeros(n), np.zeros(n)
    f = np.fft.rfftfreq(SR, 1 / SR)
    for k in range(n):
        seg = x[k * SR:(k + 1) * SR]
        rms[k] = np.sqrt(np.mean(seg ** 2))
        s = np.abs(np.fft.rfft(seg * np.hanning(SR)))
        bright[k] = (s * f).sum() / max(s.sum(), 1e-9)
    return rms, bright


def window(path: Path, length: int, mode: str) -> int:
    """The start second of the `length`-second stretch that is calmest (quiet and dark) or most
    energetic (loud and bright), skipping the first and last few seconds (intros and fade-outs)."""
    rms, bright = per_second(load(path))
    score = rms / rms.max() + bright / bright.max()
    best, at = None, 0
    for s in range(4, max(5, len(score) - length - 4)):
        v = score[s:s + length].mean()
        if best is None or (v < best if mode == "calm" else v > best):
            best, at = v, s
    return at


def render(src: Path, start: int, length: int, af: str, out: Path) -> None:
    subprocess.run(["ffmpeg", "-y", "-v", "error", "-ss", str(start), "-t", str(length), "-i", str(src), "-af", af, "-c:a", "libmp3lame", "-q:a", "2", str(out)], check=True)
    print("made", out.name, "from", src.name, "at %d:%02d, %d s" % (start // 60, start % 60, length))


def missing() -> None:
    # A Quiet Floor: the calmest minute of Over the River, a little slower, softer, a warm room.
    s = window(MUSIC / "lookout_flute.mp3", 60, "calm")
    render(MUSIC / "lookout_flute.mp3", s, 60, "rubberband=tempo=0.9,lowpass=f=6000,aecho=0.8:0.6:120|260:0.25|0.15,volume=0.85,afade=t=in:d=2,afade=t=out:st=63:d=3", MUSIC / "rest_floor.mp3")
    # The Hush Gets Closer: Down Into the Hollow slowed to a crawl, muffled, echoing, with short
    # dropouts every few seconds (the Hush's missing beats).
    s = window(MUSIC / "hollow.mp3", 45, "calm")
    render(MUSIC / "hollow.mp3", s, 45, "rubberband=tempo=0.7,lowpass=f=1400,aecho=0.8:0.7:400|900:0.35|0.25,volume='if(lt(mod(t,7),6.4),1,0.08)':eval=frame,afade=t=in:d=3,afade=t=out:st=60:d=4", MUSIC / "deep_hollow.mp3")
    # Carried Home: the quietest stretch of the main theme, slowed and fading.
    s = window(MUSIC / "title.mp3", 22, "calm")
    render(MUSIC / "title.mp3", s, 22, "rubberband=tempo=0.85,lowpass=f=5000,aecho=0.8:0.5:200:0.2,afade=t=in:d=1.5,afade=t=out:st=19:d=7", MUSIC / "fainted.mp3")
    # Training Yard Spar: the most energetic half-minute of Setting Out, then of the Guardian, crossfaded.
    a, b = window(MUSIC / "setting_out.mp3", 32, "energy"), window(MUSIC / "guardian.mp3", 32, "energy")
    subprocess.run(["ffmpeg", "-y", "-v", "error", "-ss", str(a), "-t", "32", "-i", str(MUSIC / "setting_out.mp3"), "-ss", str(b), "-t", "32", "-i", str(MUSIC / "guardian.mp3"),
                    "-filter_complex", "[0:a][1:a]acrossfade=d=3:c1=tri:c2=tri,afade=t=in:d=1,afade=t=out:st=57:d=4[o]", "-map", "[o]", "-c:a", "libmp3lame", "-q:a", "2", str(MUSIC / "training_yard.mp3")], check=True)
    print("made training_yard.mp3 from setting_out.mp3 at %d:%02d and guardian.mp3 at %d:%02d" % (a // 60, a % 60, b // 60, b % 60))


def sections(name: str) -> None:
    """Cut a song where its sound changes most (loudness and brightness jumps), at least 6 s apart."""
    src = MUSIC / f"{name}.mp3"
    rms, bright = per_second(load(src))
    feat = np.stack([rms / rms.max(), bright / bright.max()], 1)
    change = np.r_[0, np.linalg.norm(np.diff(feat, axis=0), axis=1)]
    cuts = [0]
    for k in np.argsort(-change):
        if all(abs(k - c) >= 6 for c in cuts) and 3 <= k <= len(change) - 3:
            cuts.append(int(k))
        if len(cuts) >= max(4, len(change) // 9):
            break
    cuts = sorted(cuts) + [len(change)]
    out = Path("docs/audio/sections") / name
    out.mkdir(parents=True, exist_ok=True)
    for k in range(len(cuts) - 1):
        a, b = cuts[k], cuts[k + 1]
        part = out / f"{name}_part{k + 1}_{a // 60}m{a % 60:02d}s.mp3"
        subprocess.run(["ffmpeg", "-y", "-v", "error", "-ss", str(a), "-t", str(b - a), "-i", str(src), "-c:a", "libmp3lame", "-q:a", "4", str(part)], check=True)
        loud = rms[a:b].mean() / rms.max()
        print("part %d: %d:%02d to %d:%02d (%d s), loudness %.0f%%, brightness %.0f Hz" % (k + 1, a // 60, a % 60, b // 60, b % 60, b - a, 100 * loud, bright[a:b].mean()))


# ---- key and tempo, so sections from different songs can be joined (2026-10-09, second round)
MAJOR = np.array([6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88])   # Krumhansl key profiles
MINOR = np.array([6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17])
NOTES = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]


def key_of(path: Path, start: int = 0, length: int = 60) -> tuple:
    """(tonic 0..11 counted from A, 'major'|'minor') from a chroma of the section, tuned to A = 432."""
    x = load(path)[start * SR:(start + length) * SR]
    n = 8192
    chroma = np.zeros(12)
    f = np.fft.rfftfreq(n, 1 / SR)
    ok = (f > 60) & (f < 4000)
    pc = (np.round(12 * np.log2(f[ok] / 432.0)) % 12).astype(int)
    for k in range(0, len(x) - n, n // 2):
        s = np.abs(np.fft.rfft(x[k:k + n] * np.hanning(n)))[ok]
        np.add.at(chroma, pc, s)
    best = None
    for t in range(12):
        for mode, prof in (("major", MAJOR), ("minor", MINOR)):
            r = np.corrcoef(np.roll(prof, t), chroma)[0, 1]
            if best is None or r > best[0]:
                best = (r, t, mode)
    return best[1], best[2]


def bpm_of(path: Path, start: int = 0, length: int = 40) -> float:
    """Tempo from the autocorrelation of the onset envelope, 70 to 190 bpm."""
    x = load(path)[start * SR:(start + length) * SR]
    hop = 512
    env = np.array([np.sqrt(np.mean(x[k:k + hop] ** 2)) for k in range(0, len(x) - hop, hop)])
    on = np.maximum(0, np.diff(env))
    on = on - on.mean()
    ac = np.correlate(on, on, "full")[len(on) - 1:]
    fps = SR / hop
    lags = np.arange(len(ac))
    ok = (lags >= fps * 60 / 190) & (lags <= fps * 60 / 70)
    lag = lags[ok][np.argmax(ac[ok])]
    return 60.0 * fps / lag


def shift_to(src_key: tuple, dst_tonic: int) -> int:
    """Semitones (-6..5) moving src's tonic onto dst_tonic."""
    d = (dst_tonic - src_key[0]) % 12
    return d - 12 if d > 5 else d


def piece(src: Path, start: int, length: int, tempo: float, semis: int, out: Path, extra: str = "") -> None:
    af = f"rubberband=tempo={tempo:.4f}:pitch={2 ** (semis / 12):.6f}" + ("," + extra if extra else "")
    subprocess.run(["ffmpeg", "-y", "-v", "error", "-ss", str(start), "-t", str(length), "-i", str(src), "-af", af, "-c:a", "pcm_s16le", "-ar", "44100", "-ac", "2", str(out)], check=True)


def join(parts: list, fades: list, out: Path, tail_fade: float) -> None:
    """Crossfade the parts in order (fades[i] seconds between part i and i+1)."""
    inputs = []
    for p in parts:
        inputs += ["-i", str(p)]
    chain, last = [], "[0:a]"
    for i in range(1, len(parts)):
        lab = f"[x{i}]"
        chain.append(f"{last}[{i}:a]acrossfade=d={fades[i - 1]}:c1=tri:c2=tri{lab}")
        last = lab
    total = sum(float(subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(p)], capture_output=True, text=True).stdout) for p in parts) - sum(fades)
    chain.append(f"{last}afade=t=out:st={total - tail_fade:.2f}:d={tail_fade}[o]")
    subprocess.run(["ffmpeg", "-y", "-v", "error", *inputs, "-filter_complex", ";".join(chain), "-map", "[o]", "-c:a", "libmp3lame", "-q:a", "2", str(out)], check=True)
    print("made", out.name, "%.0f s" % total)


def monster() -> None:
    """Monster House, remade: the Guardian's most frantic stretch pushed toward 172 bpm, into the best
    (non-clown) part of Preston's own Monster House, key- and tempo-matched."""
    tmp = Path("docs/audio/sections/_work"); tmp.mkdir(parents=True, exist_ok=True)
    g = MUSIC / "guardian.mp3"
    mh = Path("docs/audio/sections/monster_house/monster_house_full_432.mp3")
    gs = window(g, 28, "energy")
    gk, gb = key_of(g, gs, 28), bpm_of(g, gs, 28)
    mk, mb = key_of(mh, 47, 19), bpm_of(mh, 47, 19)
    target = min(176.0, gb * 1.12, mb * 1.12)   # both can reach it without stretching past 12%
    gt, mt = target / gb, target / mb
    # The smallest shift that puts Monster House in a key that sits with the Guardian's: the same key,
    # or (if the modes differ) its relative or parallel key. A big shift sounds dull and muddy.
    options = [gk[0]] if mk[1] == gk[1] else [gk[0], (gk[0] + (3 if gk[1] == "minor" else -3)) % 12]
    ms = min((shift_to(mk, t) for t in options), key=abs)
    print("guardian %s %s %.0f bpm at %d s; monster house part 6 %s %s %.0f bpm; target %.0f bpm; monster house shifted %+d semitones" % (NOTES[gk[0]], gk[1], gb, gs, NOTES[mk[0]], mk[1], mb, target, ms))
    piece(g, gs, 28, gt, 0, tmp / "mh_a.wav", "afade=t=in:d=0.5")
    piece(mh, 47, 19, mt, ms, tmp / "mh_b.wav")
    join([tmp / "mh_a.wav", tmp / "mh_b.wav"], [1.5], MUSIC / "monster_house.mp3", 2.0)


def final() -> None:
    """The Last Stand at the Hollow's Heart: the dread of Something Is Waiting, the Guardian's most
    relentless stretch sped up, then the triumphant peak of Setting Out shifted to the Guardian's
    relative major: despair lifting to triumph (Preston's inspiration: a final-boss track)."""
    tmp = Path("docs/audio/sections/_work"); tmp.mkdir(parents=True, exist_ok=True)
    w, g, so = MUSIC / "boss_scene.mp3", MUSIC / "guardian.mp3", MUSIC / "setting_out.mp3"
    ws = window(w, 14, "energy")
    gs = window(g, 50, "energy")
    ss = window(so, 34, "energy")
    wk, gk, sk = key_of(w, ws, 14), key_of(g, gs, 50), key_of(so, ss, 34)
    gb, sb = bpm_of(g, gs, 40), bpm_of(so, ss, 34)
    target = min(176.0, gb * 1.1, sb * 1.25)   # a tempo both the Guardian and Setting Out can reach, so the join does not lurch
    home = (gk[0] + 3) % 12 if gk[1] == "minor" else gk[0]   # the Guardian's major (its relative major when it is minor)
    # The lift lands on that major's I, IV or V, whichever needs the smallest shift of Setting Out.
    major = min((home, (home + 5) % 12, (home + 7) % 12), key=lambda t: abs(shift_to(sk, t)))
    print("waiting %s %s; guardian %s %s %.0f bpm at %d s; setting out %s %s %.0f bpm at %d s; target %.0f bpm; lift to %s major (setting out %+d semitones)" % (NOTES[wk[0]], wk[1], NOTES[gk[0]], gk[1], gb, gs, NOTES[sk[0]], sk[1], sb, ss, target, NOTES[major], shift_to(sk, major)))
    piece(w, ws, 14, 1.0, shift_to(wk, gk[0]), tmp / "fs_a.wav", "afade=t=in:d=2")
    piece(g, gs, 50, min(1.2, target / gb), 0, tmp / "fs_b.wav")
    piece(so, ss, 34, min(1.25, target / sb), shift_to(sk, major), tmp / "fs_c.wav")
    join([tmp / "fs_a.wav", tmp / "fs_b.wav", tmp / "fs_c.wav"], [2.5, 3.0], MUSIC / "final_stand.mp3", 4.0)


if __name__ == "__main__":
    {"missing": lambda: missing(), "sections": lambda: sections(sys.argv[2]), "monster": lambda: monster(), "final": lambda: final()}[sys.argv[1]]()
