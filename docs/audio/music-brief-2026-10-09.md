# Hollowtide music brief, for making tracks in Suno (Claude, 2026-10-09)

**Preston, 2026-10-09:** "Pokemon Sky has some of the most banger songs ever. Synthesize that onto Hollowtide. I'm going to make them in Suno."

## How to use this
- Each track below has a **Title** and a **Style** to paste into Suno. Turn **Instrumental** on.
- The style lines never name a game, song or composer. Suno blocks those, and the goal is Hollowtide's own melodies, not imitations.
- **Start with three:** Highbank, the Hollow, and the Guardian (the boss). Those cover most of what the game plays today. Do the rest one at a time.
- **When a track is good,** download it and drop it in `assets/audio/music/` with its file name from the table. Claude wires it to its place in the game and trims the loop point.
- **Generate a few takes** and keep the one whose first 8 bars already sound like the place. A loop should not get tiring by its third time round.

## What Explorers of Sky does, as structure (from memory of the game; check by ear)
- **Every place has its own theme,** and it tells you where you are before anything happens. A dungeon's deepest floors often switch to a more urgent variant.
- **The hub town theme is warm and bouncy:** light percussion, a woodwind or bell lead, a long loop that never wears thin, because the player hears it for hours.
- **The guild theme is a cheerful march:** busy, communal, a little comic.
- **Dungeon themes match their terrain.** Bells and shimmer for crystal caves, woodwinds for forests, wind and strings for heights. They are mid-tempo and exploratory: they keep moving without rushing you.
- **Boss themes are where it goes big:** driving drums, string ostinatos, brass stabs, a minor key, fast.
- **Story moments get piano and strings,** slow and emotional, and the main melodies come back changed (a leitmotif).
- **Short jingles mark events:** an item, a recruit, an evolution, a clear, a faint.
- **The palette is soft synth strings, flute, piano, bells and light drums.** Melodic and clear rather than chiptune.

## Hollowtide's own sound (the synthesis)
- **Place:** a Missouri river town on the bluffs, a ferry crossing, rail and market history, flood memory (the world bible). So river Americana colours the DS-era warmth: acoustic guitar, fiddle, dobro (slide guitar), harmonica, upright bass, alongside flute, music box and soft strings.
- **The Hollowtide** is "a recurring hush... sounds carry strangely... some messages reach the landing with a sentence missing." Put it in the music:
  - a melody that **drops a note or a beat** where you expect one;
  - **echoes that answer from the wrong side** (ping-pong delay, reversed reverb swells);
  - moments where **everything thins to near-silence**, then comes back.
- **Two motifs to reuse:**
  - **The Wayline:** a bright three-note figure, like the three-dot route mark. Use it in the town, the Hall and the victory.
  - **The Hush:** a falling phrase that stops one note short. Use it in the Hollow, the boss and story moments.
- **2026, not 2008:** real instrument timbres, wider stereo and more dynamics than the DS could do, but keep the melodies as clear and hummable as the DS ones.

## The tracks

| # | File name | Where it plays | Title | Style (paste into Suno) | Notes |
|---|---|---|---|---|---|
| 1 | `highbank.mp3` | the hub town | Highbank on the Bluff | warm cheerful town theme, acoustic guitar and fiddle lead with flute counter-melody, light brushed drums, upright bass, music box sparkles, bright major key, 100 bpm, cozy river town morning, hummable melody, instrumental loop | Start here. It should feel like home. The Wayline three-note figure as the hook. |
| 2 | `hollow.mp3` | the Hollow, B1F to B3F | Down Into the Hollow | mysterious exploratory dungeon theme, plucked dobro and harp arpeggios, soft synth strings, low flute melody, gentle hand percussion, river water ambience, minor key with hopeful turns, 92 bpm, echoes that answer from the side, instrumental loop | The main dungeon. Steady and curious, never rushing. The Hush motif in the melody. |
| 3 | `guardian.mp3` | the boss fight | The Guardian of the Hollow | intense boss battle theme, driving drums and taiko, fast string ostinato, brass stabs, distorted slide guitar riff, choir pads, dark minor key, 160 bpm, epic and urgent, sudden drops to silence then crashing back, instrumental | The big one. Ask for the near-silence drops: that's the Hollowtide in it. |
| 4 | `wayline_hall.mp3` | Wayline Hall, the job board | The Wayline Hall | upbeat bustling guild march, snare and woodblock, harmonica and clarinet lead, tuba bass, playful and proud, major key, 116 bpm, busy community hall, instrumental loop | The Wayline figure as a march. |
| 5 | `ferry_landing.mp3` | the Old Ferry Landing, before a run | The Old Ferry Landing | quiet anticipatory theme, solo fingerpicked acoustic guitar, distant fiddle, river water and wind ambience, sparse, bittersweet, 80 bpm, before a journey, instrumental | The breath before the dungeon. |
| 6 | `monster_house.mp3` | a Monster House | Monster House | frantic short battle loop, fast snare rolls, staccato strings, honky-tonk piano stabs, alarm-like brass, 172 bpm, chaotic and fun, instrumental loop | Short, 30-45 s is fine. |
| 7 | `deep_hollow.mp3` | low lantern or the floor before the boss | The Hush Gets Closer | tense dark ambient dungeon theme, low cello drones, heartbeat kick, sparse music box with missing notes, reversed swells, whispery pads, 70 bpm, uneasy and quiet, instrumental | The Hush motif slowed down. |
| 8 | `rest_floor.mp3` | a rest floor | A Quiet Floor | calm resting theme, soft piano and warm strings, gentle music box, slow harmonica, peaceful, major key, 68 bpm, safe and tired, instrumental loop | A sigh of relief. |
| 9 | `boss_scene.mp3` | the dialogue before the boss | Something Is Waiting | ominous build-up, low strings tremolo, timpani rolls, choir swell, rising tension, dark minor key, 60 bpm building, no resolution, instrumental | 30-60 s. It should end unresolved, leading into the boss. |
| 10 | `victory.mp3` | the dungeon cleared | The Hollow Is Quiet | triumphant victory jingle, full brass fanfare, fiddle flourish, snare roll, bright major key, joyful, 120 bpm, short and complete, instrumental | 10-20 s. The Wayline figure in the fanfare. |
| 11 | `evolution.mp3` | a creature evolves | Growing | magical evolution jingle, rising harp glissando, shimmering bells, swelling strings, wonder, resolving to major key, short, instrumental | 8-15 s. |
| 12 | `recruit.mp3` | a creature joins | A New Partner | happy short jingle, plucked guitar and glockenspiel, warm, welcoming, major key, short, instrumental | 4-8 s. |
| 13 | `fainted.mp3` | carried back after a faint | Carried Home | sad short theme, solo piano and soft strings, slow, gentle, minor key resolving to hope, instrumental | 15-30 s. |
| 14 | `title.mp3` | the title and creature village menu | Hollowtide | main theme, sweeping and emotional, piano and acoustic guitar intro, full strings and fiddle melody, warm brass, the feeling of a river at dawn, major key with a bittersweet turn, 90 bpm, adventurous, instrumental | Make this one after you have a few others, so it can borrow their best melody. |
| 15 | `training_yard.mp3` | the arena side mode | Training Yard Spar | energetic battle theme, rock drums, electric slide guitar riff, fiddle runs, fast and fun, major key, 150 bpm, friendly rivalry, instrumental loop | The real-time arena, which is the town's dojo. |
| 16 | `lookout_flute.mp3` | the Bluff Lookout, story moments | Over the River | lyrical solo wooden flute melody, soft sustained strings, gentle fingerpicked guitar, wistful and hopeful, major key with a minor turn, 76 bpm, wide river view at golden hour, breathy and expressive, instrumental | Flute-led. A slow, singing melody; the Wayline figure can turn up as a quiet phrase. |
| 17 | `hollow_flute.mp3` | a later Hollow (woods along the bluffs) | Hollow in the Cottonwoods | flowing woodland dungeon theme, bright flute and piccolo lead, pizzicato strings, marimba, light shaker, rustling leaves ambience, adventurous minor key, 104 bpm, curious and lively, instrumental loop | Flute-led dungeon, for the next Hollow after the first. |
| 18 | `morning_call.mp3` | Wayline Hall, the start of each day | Morning at the Hall | bright trumpet reveille call, then a cheerful march, snare drum, tuba, clarinet, morning energy, major key, 112 bpm, short and rousing, instrumental | Trumpet-led, 20-40 s. The day's opening bugle, with the Wayline figure as the call. |
| 19 | `setting_out.mp3` | leaving town, the road east, the region map | Setting Out | heroic adventure theme, soaring trumpet lead, full strings, french horns, timpani, driving acoustic guitar strum, triumphant and hopeful, major key, 128 bpm, the start of a journey, instrumental loop | Trumpet-led, the big hopeful one. |
| 20 | `final_stand.mp3` | the last boss of a big dungeon, or the story's climax | The Last Stand at the Hollow's Heart | epic climactic final battle theme, desperate and heroic, relentless fast string ostinato, pounding drums and timpani, soaring brass melody, full choir, rapid piano runs, minor key that lifts to a triumphant major near the end, 172 bpm, emotional and urgent, never lets up, orchestral, instrumental | For October 30 (Suno downloads reset). Preston's reference for the feel is a final-boss track from Explorers of Sky; this asks for the same drive and lift, with Hollowtide's own melody (the Hush motif turning triumphant would be ideal). |

## Status, October 9
- **Made by Preston (15):** every track except A Quiet Floor, The Hush Gets Closer, Carried Home and Training Yard Spar. Installed in `assets/audio/music/` under the file names above.
- **Those four were sampled by Claude** from Preston's songs (`tools/audio/remix.py missing`): A Quiet Floor from Over the River, The Hush Gets Closer from Down Into the Hollow, Carried Home from Hollowtide, Training Yard Spar from Setting Out and The Guardian. They are drafts for his ears.
- **All game audio is at A = 432 Hz** (`tools/audio/retune_432.py`): the songs, the older music, and every sound effect, 172 files, with lengths unchanged. A test tone measured 440 in, 432.00 out. The 440 Hz originals are in `assets/audio/_440hz_originals/`.
- **Preston's edits:**
  - Monster House: parts 2 and 3 (0:09 to 0:28) sounded like "a wack clown show", so they were cut and the intro joins part 4 with a 1 s crossfade (51 s now). The uncut 432 Hz version is `docs/audio/sections/monster_house/monster_house_full_432.mp3`.
  - Carried Home: starts at the draft's strongest onset near 4 s ("the part that starts around 4-5 seconds is best"). The first draft is `docs/audio/sections/fainted_first_draft.mp3`.
  - The other three sampled tracks: "sound good".
- **Remade by sampling, second round** (`tools/audio/remix.py monster` and `final`). Each source's key and tempo are estimated, then sections are stretched to a shared tempo and shifted by the fewest semitones into matching keys; whole-semitone shifts keep the 432 tuning.
  - Monster House (43 s): the Guardian's most frantic stretch at 176 bpm, into Monster House's best non-clown part (0:47 to 1:06), shifted 3 semitones.
  - The Last Stand at the Hollow's Heart (86 s, `final_stand.mp3`): Something Is Waiting's dread, then the Guardian's most relentless 50 s at 161 bpm, then Setting Out's triumphant peak stretched to 161 bpm and shifted 1 semitone to the Guardian key's major fifth.
  - Both are drafts for Preston's ears.
- **Suno downloads reset October 30.** Next: track 20, and redoing any draft Preston wants made properly.

## Next on Claude's side
Wire a music player when the first track lands: each scene and situation picks its track, crossfades on scene changes, ducks for the boss scene, and plays the jingles over the dungeon theme. Each file is trimmed to a clean loop.
