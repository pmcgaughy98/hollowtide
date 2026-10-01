# Game sound direction

Preston, 2026-09-30. How Hollowtide's sounds split, following the music's own recipe ("pixel-art bleeps meet bowed
cello", muted square lead, triangle bass, rain):

- **Menus and game feedback are soft synth tones, not raw chip beeps.** Preston, same day, after hearing a first
  square-wave set: "I don't want it to sound bit-like, more like Coromon." So the voices are a mallet-like pluck, a
  small bell chime and smooth filtered noise, each with a very short room tail: the polished handheld-era sound.
  He then clarified: "not TOO bit-like". So each note keeps a quiet, softened chip pulse under the mallet tone. The
  amount is one number, `CHIP` in the script (0 is all soft, 1 is bare chip; it is 0.35).
  Synthesized in `tools/build_ui_sounds.py` (no credits, re-runnable), saved in `assets/audio/sfx/ui/`.
- **The world and the creatures are recorded sound,** layered from how each body works (`build_vitrecrag_sounds.py`,
  `build_ironvent_sounds.py`).
- **Hits get both:** the recorded impact with a soft synth tick on top, so a hit reads at low volume.

## Tuning
Every note is from the five-note scale **G A B D E**. Measured keys: battle theme E minor; menu and victory
themes G major (the same notes as E minor); route theme C major; signature theme C minor. Those five notes fit the
first three. Over the signature theme (C minor) B and E are out of key, but the hit feedback there is mostly noise
and a low thump.

## The first set (live in battle)

| Sound | File | Plays when |
|---|---|---|
| Cursor | `cursor.wav` | the focus moves between commands (keyboard or pad) |
| Confirm | `confirm.wav` | a move is chosen |
| Cancel | `cancel.wav` | fleeing |
| Text tick | `text.wav` | every 0.05 s while a message types out, its pitch nudged a little each time |
| Hit | `hit.wav` | a neutral hit lands, over the recorded impact |
| Strong hit | `hit_strong.wav` | a strong matchup lands |
| Weak hit | `hit_weak.wav` | a weak matchup lands |
| HP run | `hp_drain.wav` | 0.12 s after a hit, as the bar slides |
| Faint | `faint.wav` | either creature faints |
| Catch reach | `catch_reach.wav` | a catch attempt starts |
| Catch success | `catch_success.wav` | caught |
| Catch fail | `catch_fail.wav` | it broke free |
| Encounter | `encounter.wav` | "A wild X appeared!" |

They play through `_ui()` in `battle_screen.gd`, straight to the Master bus (so text ticks do not duck the music),
at `ui_sounds_db` (-6 dB). Each file is already set to its own level, so the text tick is quiet in the file itself.

**Checked in the engine:** encounter, confirm, text ticks, hit, HP run, catch reach and catch fail all fired at the
right moments in a scripted battle. **Not exercised in that run:** cursor, cancel, strong and weak hits, faint, catch
success (same code path). **Not checked:** how they sound.

## Not made yet
Route sounds (footsteps, the field creature noticing you), the main menu, level or evolution jingles, party switch.
