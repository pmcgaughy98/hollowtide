# The Warden's entrance (Claude, 2026-10-10)

Preston's storyboard, built as a scripted scene on the boss floor (`scripts/dungeon/boss_intro.gd`).
Pacing taken from Explorers of Sky's Manectric and Electrike scene (Amp Clearing), studied from
Preston's reference video (8:57 to 9:53): structure only, nothing copied.

## What plays (about 36 seconds with lines read at a normal pace)
1. Fade in on the empty pond garden and hold: fish circle, lily rings spread, fireflies drift.
2. The camera comes down; the team walks in five tiles from below.
3. The partner, charmed: the place looks like a safe spot to rest.
4. A ripple crosses the water; a "!" pops over the partner ("...Huh?").
5. The voice from nowhere: the room dims, the music turns, the team looks round for it. The box shows
   "???" and no portrait.
6. A great shadow rises under the pond; the fish vanish; the ground trembles.
7. It bursts out unseen: white flash, a column of water, the team knocked flat, the fireflies gone.
8. Dazed stars; the team gets up.
9. Its shadow grows on the ground in front of them; the Warden drops onto it and slams the team back.
10. Two Listeners hop out of the pond to its sides.
11. The Warden speaks (portrait); the partner answers; the Warden's last line.
12. Light streaks wipe across the screen into a white flash, and the fight begins.

## What was taken from the Manectric scene (structure)
- Open on the empty location and hold before the team walks in.
- The partner reacts first, with a portrait; a "!" over its head marks the moment it notices.
- The unseen voice dims the screen and speaks without a name; the team turns to look round.
- Short lines, about two seconds each.
- Streak wipe into a white flash before the fight.

## Sound (ElevenLabs, same day)
Twelve new sounds, one per beat: a looping pond bed under the garden (it goes quiet when the voice
speaks and stops at the burst), the ripple, the "!" pop, a low swell as the room dims, the rumble, the
burst, water raining back, the falling whoosh, the heavy landing, the Listeners' hop-splash, the
Warden's croak before it speaks, and the whoosh into the fight. Prompts, picks and trims:
`docs/audio/sources.md`; built by `tools/audio/build_dungeon_sfx.py`. About 400 credits.
The music starts on the calm rest track (the place sounds safe), turns to the scene track with the
voice, and to the Guardian theme when the fight begins.

## The room
The boss room is 19 by 14 now (was 15 by 11). The pond is 9 by 3 tiles (4 rows put the shore under the Warden's back) and does not walk; the meadow
round it is decoration and walks like floor. All of it is drawn in code, pixel by pixel, at the world's
1x: no generated art.

## Proposals waiting on Preston
- **The Warden's voice and temper** (`VOICE`, `AFTER`, `OPEN`, `NOTICE` in `boss_intro.gd`): old,
  patient, possessive of its garden, scornful of noise; creatures that rest there "forget to leave".
- Emotion portraits (the partner's "Waah" face in the reference) wait on Codex's portrait job.

## Also fixed here
- **Troughspine's back view floated** (Preston): from behind its tail hangs below its legs, and the
  ground line was found at the tail tip. `FOOT_FIX` in `dungeon.gd` puts it at the legs for the back
  view (still, walk and action frames move together), and `FOOTPRINT_SHADOW` fits its shadow to the whole
  body in each pose, a little in front of the middle, so it lies flat instead of rearing up (Preston: "looks
  like it's standing on hind legs" with the shadow only at its feet). Sheet: `troughspine_ground.png` (all eight sides).

## Checks and captures
- `tools/debug/boss_intro_capture.gd`: plays the scene, saves a still per beat, checks the fight starts.
  With `--write-movie` it records; `warden_entrance.mp4` is that recording.
- `tools/debug/troughspine_ground_capture.gd`: the eight-side sheet.
- A floor freed mid-scene stops the scene quietly (`_alive`).
- `dungeon.gd` `boss_intro = false` skips the scene (the dialogue capture uses it).
