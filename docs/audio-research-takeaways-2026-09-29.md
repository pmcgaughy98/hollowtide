# Game audio: what the Gemini research changed

**Source:** `docs/Gemini DeepResearch(Hollowtide)/Creature Sound Design in Godot.docx` (Preston, 2026-09-29), from `docs/gemini-prompt-game-audio-layering-2026-09-29.md`. Treat it as research, not canon.

**Source quality:** the Godot docs, the Sony ASWG loudness standard and the layering guides are solid. Several game anecdotes cite Reddit, TV Tropes or Quora, and its Hollow Knight and Dead Cells notes describe the composers, not the sound designers. Its "Preostmar, the Nature turtle" is stale: it is Stone now, and no longer a turtle.

## Applied (2026-09-29)

1. **Layered release** (`rupture.wav`, now stereo, built by `tools/build_vitrecrag_sounds.py`). Each layer has one job in its own band:

   | Layer | Source | Band | Timing | Level |
   |---|---|---|---|---|
   | Transient | the shell cracking | above 1 kHz, hard-clipped | first 0.12 s | 0 dB |
   | Sub drop | synthesized sine, 80 to 30 Hz | 20-80 Hz | 0.45 s | -2 dB |
   | Body | the carapace breaking | 200 Hz - 1 kHz | about 0.7 s | -4 dB |
   | Voice | Vitrecrag's brass-locomotive bellow, pitched up sharply: a driven sub copy under a bright copy | full | about 0.7 s | -3 dB |
   | Material | the glass burst, the pour and cooling ticks | mixed | the aftermath | -6 to -14 dB |
   | Sweeteners | steam and raining glass shards, the right side delayed 12-15 ms for width | above 3-4 kHz | about 1.5 s | -10 dB |
   | Space | the dry hit convolved with a synthetic stone-cavern reverb, done with numpy's FFT (no scipy needed) | full | 3 s tail | -12 dB |

   Measured: the sub is present at the hit (-12 dB) and decays; the body is strong for 0.5 s; the crack starts within 0.1 ms; there is stereo width from the sweeteners and reverb. The new layers `body`, `steam` and `shards` came from ElevenLabs (2 takes each, about 94 credits).
2. **The vacuum.** When the strain frame's hush begins, the battle fades out that attack's sounds (`_hush_cues` in `battle_screen.gd`), so picture and sound go silent together and the release lands out of silence. It is timed off the hush itself because frame timing drifts by about 0.1 s; a gap baked into the file came out 150 ms long instead of 60.
3. **Bus layout** (`default_bus_layout.tres`):
   - **Master:** a limiter at -1 dB.
   - **SFX:** all battle sounds (`_play_sound`).
   - **Music:** a compressor that ducks the music under SFX (ratio 8, fastest attack, 320 ms release). It is ready for when music exists.

**Verified in the engine:**
- buildup at 2.40 s, cry at 2.86 s;
- both faded out by 4.75 s;
- rupture at 4.94 s;
- all three on the SFX bus.

**Not verified:** how it sounds. That needs Preston's ears.

## Not done yet

- **Loudness target:** about -18 LUFS integrated with a -1 dBTP ceiling, the portable standard; the report recommends it for Steam Deck-class play. Files are peak-normalized for now, and a loudness pass needs a LUFS meter. Adding `pyloudnorm` would do it.
- **AudioStreamRandomizer** (random pitch 1.1, volume variation 1.5 dB, no repeats) for sounds that repeat, such as multi-hit moves, so they do not machine-gun.
- **Evolution scaling:** a line's cry stays recognisable from stage to stage, pitched down, with more sub and more space at each stage. Useful for Preostmar to Oathfen to Oxbowarchon.
- **Multiband compression and transient shaping:** these genuinely need audio software (a DAW). The numpy mixer approximates them with filters, clipping and envelopes.
