"""Turn the ElevenLabs takes into the dungeon's and the town's sounds (Claude, 2026-10-09).

Preston (2026-10-09): "the synthesis should help you with game sounds from eleven labs right?
Highwhistles was really ear piercing... go ham there should be a good amount of credits to make all
the game sounds we need." The 56 takes (28 sounds, two each, `eleven_text_to_sound_v2`, prompt
influence 0.3) are in assets/audio/sfx/dungeon/takes/ with their prompts in prompts.json; the flow
and credits are in docs/audio/sources.md.

One take per sound was chosen by measurement, since Claude cannot listen: a quick onset for hits,
a body that fits the moment, and the least energy in the 2 to 6 kHz band where the ear is most
sensitive (the whistles' problem). Preston's ears overrule: change PICKS and run it again.

Each pick is decoded through ffmpeg with its filters (a high-pass under the sub-bass a laptop
speaker cannot play; a low-pass on bright ones), trimmed, faded, lowered by 432/440 so it sits at
A = 432 with the rest of the game (and an octave or two further for the two chimes, which measured
88 to 99% above 2 kHz), normalised and written to assets/audio/sfx/dungeon/<name>.wav.

  python tools/audio/build_dungeon_sfx.py
"""
import subprocess
import wave
from pathlib import Path

import numpy as np

SR = 44100
ROOT = Path(__file__).resolve().parents[2]
TAKES = ROOT / "assets" / "audio" / "sfx" / "dungeon" / "takes"
OUT = ROOT / "assets" / "audio" / "sfx" / "dungeon"
RETUNE = 440.0 / 432.0   # play this much slower: pitch drops to A = 432
HP = "highpass=f=45"
SOFT = "lowpass=f=6500"

# name: (take, start s, end s, fade in s, fade out s, peak dB, ffmpeg filters, octaves down)
PICKS = {
    # combat
    "swing": ("swing_0", 0.18, 0.75, 0.01, 0.12, -7.0, f"{HP},lowpass=f=3500,lowpass=f=3500", 0),
    "miss": ("miss_0", 0.00, 0.35, 0.005, 0.10, -8.0, "highpass=f=120", 0),
    "hit_light": ("hit_light_1", 0.18, 0.62, 0.002, 0.10, -4.0, HP, 0),
    "hit_heavy": ("hit_heavy_1", 0.00, 0.80, 0.002, 0.20, -2.0, HP, 0),
    "hit_super": ("hit_super_0", 0.00, 0.60, 0.002, 0.15, -1.0, HP, 0),
    "slam": ("slam_1", 0.03, 0.60, 0.002, 0.12, -2.0, HP, 0),
    "shove": ("shove_0", 0.00, 0.30, 0.002, 0.08, -5.0, f"{HP},{SOFT}", 0),
    "windup": ("windup_1", 0.00, 1.00, 0.05, 0.15, -6.0, HP, 0),
    # one impact per essence, layered under the hit
    "impact_fire": ("impact_fire_1", 0.00, 1.00, 0.002, 0.30, -4.0, HP, 0),
    "impact_water": ("impact_water_0", 0.08, 0.90, 0.005, 0.25, -5.0, f"{HP},{SOFT}", 0),
    "impact_shock": ("impact_shock_1", 0.00, 0.70, 0.002, 0.20, -8.0, f"{HP},lowpass=f=5000", 0),
    "impact_earth": ("impact_earth_1", 0.00, 0.60, 0.002, 0.20, -3.0, HP, 0),
    "impact_root": ("impact_root_0", 0.08, 0.70, 0.005, 0.20, -6.0, f"{HP},{SOFT}", 0),
    "impact_wind": ("impact_wind_1", 0.25, 1.40, 0.05, 0.30, -5.0, HP, 0),
    # the floor
    "stairs": ("stairs_0", 0.10, 1.75, 0.02, 0.30, -5.0, HP, 0),
    "pickup": ("pickup_1", 0.00, 0.22, 0.002, 0.08, -11.0, "lowpass=f=9000", 2),
    "eat": ("eat_1", 0.00, 0.55, 0.002, 0.10, -7.0, "lowpass=f=7000", 0),
    "trap_snare": ("trap_snare_0", 0.28, 0.80, 0.002, 0.12, -4.0, HP, 0),
    "trap_silt": ("trap_silt_1", 0.00, 0.70, 0.01, 0.15, -4.0, HP, 0),
    "trap_warp": ("trap_warp_1", 0.00, 0.65, 0.01, 0.20, -4.0, HP, 0),
    "monster_ambush": ("monster_ambush_1", 0.20, 2.60, 0.01, 0.40, -2.0, HP, 0),
    "lantern_low": ("lantern_low_1", 0.00, 0.75, 0.01, 0.15, -6.0, HP, 0),
    "faint": ("faint_1", 0.00, 0.90, 0.005, 0.25, -3.0, HP, 0),
    "iq_learn": ("iq_learn_0", 0.00, 0.40, 0.005, 0.12, -10.0, "", 1),
    "scroll": ("scroll_0", 0.08, 1.30, 0.02, 0.30, -9.0, f"{HP},lowpass=f=5000", 0),
    # the town
    "door": ("door_0", 0.00, 0.65, 0.005, 0.12, -6.0, HP, 0),
    "board_paper": ("board_paper_1", 0.02, 0.70, 0.005, 0.12, -7.0, HP, 0),
    # Second batch (2026-10-09, "do another elevenlabs gen from synthesis"): the moments pokered's
    # sound list and Explorers of Sky give a sound that Hollowtide still played silent.
    # Negative octaves raise a sound: the revive and the evolve hum centred near 100 Hz, which a
    # laptop speaker barely plays, so they go up one octave (still A = 432).
    "denied": ("denied_0", 0.03, 0.45, 0.003, 0.10, -8.0, HP, 0),
    "throw": ("throw_1", 0.93, 1.35, 0.01, 0.10, -7.0, "highpass=f=100", 0),
    "part_break": ("part_break_0", 0.62, 1.00, 0.002, 0.12, -5.0, f"{HP},{SOFT}", 0),
    "recruit_rise": ("recruit_rise_1", 0.03, 0.69, 0.02, 0.15, -8.0, f"{HP},lowpass=f=4000", 0),
    "hollow_fade": ("hollow_fade_0", 0.00, 1.60, 0.05, 0.80, -6.0, HP, 0),
    "revive": ("revive_0", 0.05, 1.25, 0.01, 0.30, -5.0, HP, -1),
    "lantern_up": ("lantern_up_0", 0.00, 1.00, 0.005, 0.30, -6.0, HP, 0),
    "lantern_out": ("lantern_out_0", 0.15, 0.81, 0.005, 0.20, -7.0, "lowpass=f=7000", 0),
    "room_clear": ("room_clear_1", 0.00, 1.40, 0.003, 0.40, -6.0, HP, 0),
    "floor_arrive": ("floor_arrive_0", 1.08, 1.40, 0.003, 0.10, -6.0, HP, 0),
    "boss_appear": ("boss_appear_1", 0.00, 2.40, 0.02, 0.50, -2.0, HP, 0),
    "dizzy": ("dizzy_1", 0.00, 1.00, 0.01, 0.25, -7.0, HP, 0),
    "wake": ("wake_0", 0.05, 0.90, 0.005, 0.15, -7.0, f"{HP},{SOFT}", 0),
    "escape": ("escape_0", 0.55, 1.60, 0.02, 0.30, -9.0, f"{HP},lowpass=f=4500", 0),
    "menu_open": ("menu_open_1", 0.00, 0.41, 0.003, 0.08, -10.0, f"{HP},{SOFT}", 0),
    "menu_close": ("menu_close_1", 0.30, 0.75, 0.003, 0.10, -10.0, HP, 0),
    "snare_struggle": ("snare_struggle_1", 0.00, 1.00, 0.02, 0.20, -8.0, f"{HP},{SOFT}", 0),
    "evolve_ready": ("evolve_ready_0", 0.00, 1.60, 0.10, 0.50, -6.0, HP, -1),
    # the Warden's entrance (Claude, 2026-10-10; Preston: "eleven labs synthesis it up too"): 12 sounds,
    # two takes each, 16.7 credits a take, flow lgucGp7YVZlGnAPBhJ26; picked by measurement
    "pond_ambience": ("pond_ambience_0", 0.50, 12.50, 1.00, 2.00, -3.0, f"{HP},lowpass=f=4500", 0),
    "ripple": ("ripple_0", 0.14, 1.60, 0.005, 0.40, -8.0, f"{HP},{SOFT}", 0),
    "emote_alert": ("emote_alert_1", 0.00, 0.60, 0.002, 0.15, -8.0, "lowpass=f=6000", 0),
    "presence_swell": ("presence_swell_0", 0.00, 2.00, 0.30, 0.60, -4.0, HP, -1),
    "pond_rumble": ("pond_rumble_0", 0.00, 1.00, 0.10, 0.25, -3.0, HP, 0),
    "pond_burst": ("pond_burst_0", 0.00, 2.00, 0.002, 0.60, -1.0, f"{HP},{SOFT}", 0),
    "water_rain": ("water_rain_0", 0.00, 1.00, 0.05, 0.40, -9.0, f"{HP},lowpass=f=5000", 0),
    "fall_whoosh": ("fall_whoosh_0", 0.00, 1.70, 0.20, 0.08, -3.0, HP, -1),
    "heavy_land": ("heavy_land_0", 0.00, 1.00, 0.002, 0.40, -1.0, HP, 0),
    "hop_splash": ("hop_splash_0", 0.00, 0.80, 0.002, 0.20, -8.0, f"{HP},lowpass=f=5000", 0),
    "warden_croak": ("warden_croak_0", 0.00, 2.00, 0.01, 0.50, -2.0, HP, 0),
    "battle_wipe": ("battle_wipe_1", 0.90, 2.40, 0.05, 0.30, -3.0, HP, 0),
}
# Not used: step (both takes were a steady hiss with no footfall; the dungeon stays quiet underfoot,
# as Explorers of Sky does).


def decode(take: str, filters: str) -> np.ndarray:
    args = ["ffmpeg", "-v", "error", "-i", str(TAKES / f"{take}.mp3")]
    if filters:
        args += ["-af", filters]
    out = subprocess.run(args + ["-f", "s16le", "-ac", "1", "-ar", str(SR), "-"], capture_output=True, check=True).stdout
    return np.frombuffer(out, np.int16).astype(float) / 32768.0


def fade(x: np.ndarray, fin: float, fout: float) -> np.ndarray:
    x = x.copy()
    a, b = max(1, int(fin * SR)), max(1, int(fout * SR))
    x[:a] *= np.linspace(0, 1, min(a, len(x)))
    x[-b:] *= np.linspace(1, 0, min(b, len(x)))
    return x


def slow(x: np.ndarray, ratio: float) -> np.ndarray:
    n = int(len(x) * ratio)
    return np.interp(np.linspace(0, len(x) - 1, n), np.arange(len(x)), x)


def save(path: Path, x: np.ndarray, peak_db: float) -> None:
    x = x / max(1e-9, np.abs(x).max()) * 10 ** (peak_db / 20)
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((x * 32767).astype(np.int16).tobytes())


if __name__ == "__main__":
    for name, (take, a, b, fin, fout, peak, filters, octaves) in PICKS.items():
        x = fade(decode(take, filters)[int(a * SR):int(b * SR)], fin, fout)
        x = slow(x, RETUNE * 2 ** octaves)
        save(OUT / f"{name}.wav", x, peak)
        print(f"{name:15} <- {take} [{a:.2f}, {b:.2f}] s, {len(x) / SR:.2f} s at 432{f' ({octaves} octave down)' if octaves > 0 else (f' ({-octaves} octave up)' if octaves < 0 else '')}")
