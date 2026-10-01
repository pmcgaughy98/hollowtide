# Vitrecrag sound effects: ElevenLabs prompts

Preston, 2026-09-29: Vitrecrag's signature sound should feel like a brass instrument fused with a locomotive, and the Molten Glass meltdown buildup should build from that sound.

**Where to make them:** ElevenLabs Sound Effects (elevenlabs.io, Sound Effects). Summer's own generator uses ElevenLabs too, but it needs a Summer Studio plan and returned "subscription required" on 2026-09-29.

**Settings:** set the duration shown for each prompt, and generate 3 or 4 variations of each to pick from. Save your pick as the file named, as `.mp3`, into `assets/audio/sfx/vitrecrag/`. Godot imports it on its own.

## 1. The cry: `vitrecrag_cry.mp3` (2 s)

Plays on the title card, the moment the signature announces itself.

```text
Giant armored beast bellow that sounds like a steam train horn fused with a tuba and trombone, low brassy mechanical roar with a hiss of steam at the end
```

## 2. Meltdown buildup: `meltdown_buildup.mp3` (2.6 s)

Plays from the brace to the rupture: the flood frames, then the strain with the shake and hush. It should end at its peak.

```text
A colossal steam locomotive building pressure: slow heavy chugging that speeds up faster and faster, a deep brass tuba-like horn swelling underneath and rising in pitch, hissing steam leaks, rising tension, ending in a shrill steam whistle scream
```

## 3. Rupture and pour: `meltdown_rupture.mp3` (2.5 s)

Plays when the core ruptures and the glass pours out.

```text
Molten glass bursting out of a furnace: a deep heavy whoosh eruption, loud sizzling hiss, crackling and tinkling glass, then a thick gurgling lava pour
```

## Later, same voice

- **Molten Cannon:** `A heavy iron cannon blast with a brass horn stab and a hiss of steam, deep boom and ringing metal`, 1.5 s.
- **Plate Lunge:** `A huge armored locomotive-like beast charging: heavy iron stomps, a short brass horn grunt, a crashing stone-and-metal impact`, 1.5 s.
- **Idle:** a quiet steam-and-brass breath under the mouth flames, `Low slow steam engine breathing with a faint distant brass hum, calm, looping`, 4 s.

## Hooking them in

Moves now have a **Sound** group: `sound_cues`, `sound_cue_frames` and `sound_cue_db`. Each sound starts on a chosen attack frame. Once the files exist, Molten Glass takes:
- the cry on frame 2, with the title card;
- the buildup on frame 0;
- the rupture on frame 4.

Claude wires these once the files are in the folder.

## Generated, 2026-09-29

Made through the ElevenLabs connector (`eleven_text_to_sound_v2`, prompt influence 0.5), with four takes of each sound, for 284 credits (about $0.03). The flow is https://elevenlabs.io/app/flows/xPEJTo1VIDANiC6QVpLn, and it holds the shortened prompts that were actually used.

- **The takes** are in `assets/audio/sfx/vitrecrag/takes/`: `cry_a` to `cry_d`, `buildup_a` to `buildup_d`, and `rupture_a` to `rupture_d`.
- **Wired into Molten Glass:**
  - `buildup_a` on frame 0 (0 dB): it is 2.56 s long, so its whistle lands on the rupture at 2.45 s;
  - `cry_a` on frame 2, the title card (-4 dB);
  - `rupture_a` on frame 4 (0 dB).
- **Verified** in a headless run: all three start on those frames.
- **Swapping a take:** in `data/moves/vitrecrag_molten_glass.tres`, Sound group, drag a different take into the slot.

## Physiology mixes, 2026-09-29 (live)

Preston: build the sounds as if they come from a creature whose molten-glass core is going haywire inside its body. The brass-locomotive voice is the core, and body layers surround it. The layers were generated through the ElevenLabs connector (2 takes each, about 270 credits) and saved in `assets/audio/sfx/vitrecrag/layers/`:
- `boil`: molten glass boiling;
- `stress`: glass pinging under heat;
- `rumble`: the furnace heard through the chamber walls;
- `groan`: shell plates straining;
- `crack`: the shell splitting.

`tools/build_vitrecrag_sounds.py` mixes them (it re-runs, and generates nothing):
- **`cry.wav`:** the bellow with a chest (a muffled copy under the dry voice, lightly driven), the core bubbling and the furnace underneath, and glass ticking at the tail.
- **`buildup.wav`:** the voice starts muffled inside the shell and the muffle opens as the pressure rises, while its pitch climbs. The core boils faster and higher, the furnace swells, the plates groan, and heat-stress pings thicken toward the peak. It dips for its last 0.4 s, which matches the animation's hush before release.
- **`rupture.wav`:** the shell cracks, the burst hits (its slow lead-in trimmed), the pouring glass gurgles, and cooling shards tick.

Molten Glass now plays these three instead of the raw takes. **Checked:** peaks at -1 dBFS with nothing clipped; the spectrograms show the buildup brightening over time and the burst landing at the start of the rupture; a headless run plays each on its frame. **Not checked:** how they sound. That needs Preston's ears.

## Release rebuilt from research, 2026-09-29 (live)

Preston: the buildup sounds great, but the release was only hissing and bubbling, and it sounded isolated. The rupture was rebuilt as a layered, stereo release, and the silence before it is now tied to the animation's hush. See `docs/audio/audio-research-takeaways-2026-09-29.md`. New layers in `layers/`: `body` (shell cracking open), `steam` (burst) and `shards` (glass rain), 2 takes each.
