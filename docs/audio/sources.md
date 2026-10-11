# Sound sources

Every sampled or generated sound that is not synthesised in a `tools/build_*_sounds.py` script, with where it came from and the terms. Rule: `sampled-sounds-rule-2026-10-07.md`.

## ElevenLabs sound effects (Preston's account, commercial use under his plan)
Flow: https://elevenlabs.io/app/flows/RMxmaDwxIdMvCZBpMxiw. Model `eleven_text_to_sound_v2`, prompt influence 0.3, two takes each. Preston topped up on 2026-10-07; the four earlier attempts failed unpaid at 0 credits. Takes in `assets/audio/sfx/arena/takes/`; the chosen trims in `tools/build_arena_takes.py`.

| File | Prompt | Credits | Chosen |
|---|---|---|---|
| rock_crack_a/b | A fissure cracking open in a large boulder: a sharp dry stone snap, a short hollow stone knock, then a few small chips of rock falling and settling. Close, dry, no reverb. 0.5 seconds. | 100 | b, 0 to 0.7 s |
| rock_break_a/b | A large boulder shatters: a deep heavy crack and low thump, then a clatter of big stone shards tumbling and knocking against each other, gravel trickling and settling at the end. Outdoor stadium, dry. 1.2 seconds. | 100 | a, 0 to 1.4 s |
| wall_slam_a/b | A heavy creature slammed into a stone arena wall: a sharp crack of contact, a deep bodily thud with a low boom, then dust and grit sifting down off the wall. Punchy, short tail. 0.6 seconds. | 33 | b, 0.04 to 0.95 s |
| crest_ram_a/b | A huge armored reptile charging head-down: heavy pounding footfalls accelerating on dirt, with furnace vents on its back roaring louder as it runs, a rising whoosh of hot air. 0.7 seconds, builds to the end. | 33 | b, 0.3 to 1.15 s (the rise) |
| cinder_claw_a/b | A fast claw swipe from red-hot claws: a quick air swish, then a sizzling hiss as hot claws bite, with a tiny crackle of embers. Short and sharp. 0.4 seconds. | 33 | b, 0 to 0.6 s |
| match_start_a/b | A stadium crowd roaring as a creature battle begins, with a short deep horn blast announcing the start. Open-air arena, energetic, ends cleanly. 1.5 seconds. | 33 | b, whole |

Total this batch: about 333 credits. Picks were made by measurement (onset, decay, brightness), not by ear; Preston decides.

### Kingstone Rail (2026-10-08, same flow and model)
Takes in `assets/audio/sfx/oxbowarchon/takes/`; trims in `tools/build_oxbowarchon_sounds.py`.

| File | Prompt | Credits | Chosen |
|---|---|---|---|
| rail_charge_a/b | A giant crystal railgun charging: a deep resonant hum rising in pitch over two seconds, glassy crystalline chimes and electric crackles gathering into a sphere of energy, a tense building whine, then a sudden sharp release blast and a brief whoosh as it fires upward. Clean, dry, no music. 2.5 seconds. | 33 | b (6 s: hum, release at 5.55 s), cut 4.42 to 6.0 s so the release lands 1.15 s in, where the arena's rails fire; take a is a 2 s blast with no build |
| rail_impact_a/b | A meteor of green crystal energy slams into a stone arena floor: a brief falling whistle, then a colossal impact boom with a deep sub thump, stone cracking and shattering, a crystalline shattering ring-out, and heavy rock debris raining down and settling. Open-air stadium, huge, punchy. 2 seconds. | 33 | a (louder boom, cleaner decay), 0.4 to 1.6 s |

About 67 credits. Measured, not heard.

### Starshield (2026-10-08, same flow and model)
Takes in `assets/audio/sfx/starward/takes/`; build in `tools/build_starward_sounds.py`.

| File | Prompt | Credits | Chosen |
|---|---|---|---|
| star_guard_a/b | A protective magical star shield forming around a friend: a warm rising crystalline chime, a soft electric hum swelling into a bright shimmering pulse as the shield snaps into place, then a gentle sparkling tail. Clean, warm, hopeful, no music. 1.5 seconds. | 33 | a (1.0 s; b is 0.48 s, too short to carry the star forming), whole |
| star_guard_c/d | The same, asked for as two full seconds (Preston: "you can regenerate that ElevenLabs sound"). | 33 | **d** (3.0 s, a real swell then the pulse and a tail), 0 to 2.2 s; c came back at 1.0 s again |

Used by Star Guard and at Starshield's snap. Measured, not heard.

### Vitrecrag, replaced (2026-10-08, same flow and model)
Preston: "update Vitrecrag's sounds, the horn stuff doesn't sound great." The 2026-09-29 mixes (`build_vitrecrag_sounds.py`, brass-and-locomotive voice over glass layers) are kept as `old_mix_*.wav`; the new ones are straight takes built by `tools/build_vitrecrag_takes.py`. Takes in `assets/audio/sfx/vitrecrag/takes2/`.

| File | Prompt | Credits | Chosen |
|---|---|---|---|
| cry_a/b | The cry of a huge armoured kiln creature with a core of molten glass: a deep rumbling roar that comes from inside a thick stone shell, like a furnace drawing breath, with hot glass creaking and pinging under the strain and a hiss of steam from the seams at the end. Heavy, low, organic. No horn, no brass, no trumpet, no machinery, no music. 1.5 seconds. | 33 | a (2 s: swells from 0.2 s, peaks 0.45 to 0.65, decays by 1.8), 0.05 to 1.9 s |
| buildup_a/b | A molten glass core heating up inside an armoured shell over two seconds: thick molten glass bubbling and glugging, hot glass pinging and crackling under heat stress, a rising pressure hiss and a low furnace rumble that builds steadily louder and brighter until it is about to burst. Builds to the end, no climax yet. No horn, no brass, no machinery, no music. 2 seconds. | 33 | neither (quiet, mostly silence) |
| buildup_c/d | The same, asked for "loud and continuous for the full two seconds". | 33 | **d** (3 s), 0 to 2 s; c came back at 0.48 s |
| rupture_a/b | A thick glass and stone shell ruptures: a sharp cracking split, then a heavy burst as a column of molten glass erupts upward with a deep whoomp and a roaring hiss, followed by molten glass splattering and sizzling as it rains down and glass shards tinkling. Huge, punchy, short tail. No horn, no brass, no music. 1.5 seconds. | 33 | **b** (7 s, its real burst at 1.45 s), 1.4 to 3.2 s; a is a 1 s version |

About 133 credits. Measured, not heard; Preston's ears decide.

### The dungeon and the town (2026-10-09, flow `lgucGp7YVZlGnAPBhJ26`, same model, prompt influence 0.3)
Preston: "the synthesis should help you with game sounds from eleven labs right? Highwhistles was really ear piercing... go ham." 28 sounds, two takes each, about 16.7 credits a take (about 933 in all). Takes and `prompts.json` in `assets/audio/sfx/dungeon/takes/`; trims, filters and the 432 retune in `tools/audio/build_dungeon_sfx.py`; wired in `scripts/dungeon/dungeon.gd` (`_sfx`, `ESSENCE_SFX`) and `scripts/town/hub_town.gd`; checked by `tools/debug/dungeon_sfx_check.gd`.

The prompts follow the synthesis: Explorers of Sky marks every action with a short sound (swing, hit by strength, the move's type, stairs, item, trap, Monster House) and keeps footsteps silent. Every prompt asked for short and, where it could whistle, "no high whistle". Picks by measurement: onset, body length, and the least energy in the 2 to 6 kHz band (the whistles' problem). The two chimes (pickup, IQ) measured 88 to 99% above 2 kHz and were lowered one and two octaves.

| File | Prompt | Credits | Chosen |
|---|---|---|---|
| trap_warp_0/1 | swirling watery whoosh, like being pulled through a small whirlpool and dropped somewhere else, short | 33 | 1, 0.00 to 0.65 s |
| monster_ambush_0/1 | sudden ambush sting: a dramatic low hit followed by several small creatures dropping to the ground with thuds, short | 33 | 1, 0.20 to 2.60 s |
| lantern_low_0/1 | an old lantern flame sputtering and flickering low, short | 33 | 1, 0.00 to 0.75 s |
| faint_0/1 | a small creature collapsing to the ground, soft thud with a gentle descending tone, short | 33 | 1, 0.00 to 0.90 s |
| iq_learn_0/1 | gentle sparkling chime of learning something new, warm and soft, short | 33 | 0, 0.00 to 0.40 s |
| scroll_0/1 | an old paper scroll unrolling with a soft magical shimmer, short | 33 | 0, 0.08 to 1.30 s |
| door_0/1 | an old wooden door opening with a short creak, small town shop | 33 | 0, 0.00 to 0.65 s |
| board_paper_0/1 | a paper notice pulled off a cork pinboard, quick paper rustle, short | 33 | 1, 0.02 to 0.70 s |
| impact_shock_0/1 | electric zap impact, a short crackling static shock, not too high pitched | 33 | 1, 0.00 to 0.70 s |
| impact_earth_0/1 | rock and earth impact, stones cracking and gravel scattering, short heavy hit | 33 | 1, 0.00 to 0.60 s |
| impact_root_0/1 | roots and vines bursting out of the ground and lashing, woody snap and rustle, short | 33 | 0, 0.08 to 0.70 s |
| impact_wind_0/1 | sharp gust of wind slicing past, a quick airy cut, short, no whistle | 33 | 1, 0.25 to 1.40 s |
| step_0/1 | soft single footstep of a small creature on packed dirt, very short and quiet | 33 | neither (both a steady hiss, no footfall) |
| stairs_0/1 | a few quick footsteps going down old stone stairs, then a soft whoosh into the dark | 33 | 0, 0.10 to 1.75 s |
| pickup_0/1 | small item picked up, a gentle bright pop with a tiny warm chime, short | 33 | 1, 0.00 to 0.22 s |
| trap_snare_0/1 | wooden root snare snapping shut around a leg, creaky woody snap and tighten, short | 33 | 0, 0.28 to 0.80 s |
| trap_silt_0/1 | muddy river silt bubbling and squelching as a foot sinks in, short | 33 | 1, 0.00 to 0.70 s |
| swing_0/1 | quick light whoosh of a small creature's claw swipe through the air, short, clean, retro adventure game | 33 | 0, 0.18 to 0.75 s |
| hit_light_0/1 | soft punchy impact of a small creature being hit, short thud, clean, retro adventure game hit sound | 33 | 1, 0.18 to 0.62 s |
| hit_heavy_0/1 | heavy meaty impact hit with a deep low thump, short, powerful, retro adventure game | 33 | 1, 0.00 to 0.80 s |
| hit_super_0/1 | crisp critical hit impact, a sharp crack layered over a low boom, short and satisfying, game sound effect | 33 | 0, 0.00 to 0.60 s |
| slam_0/1 | a body slamming hard into a stone wall, dull heavy thud with crumbling grit and dust, short | 33 | 1, 0.03 to 0.60 s |
| shove_0/1 | quick shove impact then a small body skidding across dirt, short | 33 | 0, 0.00 to 0.30 s |
| miss_0/1 | quick airy whiff of a missed attack, a light swish that hits nothing, short | 33 | 0, 0.00 to 0.35 s |
| windup_0/1 | tense rising energy charge-up, a low hum swelling upward for about one second, warning of an attack, no high whistle | 33 | 1, 0.00 to 1.00 s |
| impact_fire_0/1 | small fiery impact, a burst of flame with a crackle, short, game sound effect | 33 | 1, 0.00 to 1.00 s |
| impact_water_0/1 | water splash impact, a quick heavy splash of river water hitting a creature, short | 33 | 0, 0.08 to 0.90 s |
| eat_0/1 | a small creature taking a crunchy juicy bite of a berry, short | 33 | 1, 0.00 to 0.55 s |

Measured, not heard; Preston's ears decide (change PICKS and rerun the builder).

### The second dungeon batch (2026-10-09, same flow `lgucGp7YVZlGnAPBhJ26`)

Preston: "do another elevenlabs gen from synthesis". The list of moments came from the synthesis, structure only: pokered's sound list (denied, throw, heal, wake-up alert, start menu, teleport and so on) and Explorers of Sky's habit of marking every dungeon event, checked against every message in `dungeon.gd` that still played silent. 18 sounds, two takes each, 16.7 credits a take (about 600 in all). Prompts in `takes/prompts.json`, picks in `tools/audio/build_dungeon_sfx.py`.

| Sound | Plays when | Pick |
|---|---|---|
| denied | can't do it: cooling move, nothing in reach, sealed stairs, can't learn, bag full, doesn't budge (replaced the quiet menu cancel blip) | denied_0 |
| throw | the River Stone is thrown | throw_1 |
| part_break | a wind-up is broken | part_break_0 |
| recruit_rise | a beaten creature gets back up and asks to join | recruit_rise_1 |
| hollow_fade | it is turned down and goes back into the hollow | hollow_fade_0 |
| revive | the Rally Seed works | revive_0, one octave up |
| lantern_up | lamp oil | lantern_up_0 |
| lantern_out | the light reaches zero | lantern_out_0 |
| room_clear | the Monster House is cleared | room_clear_1 |
| floor_arrive | each new floor | floor_arrive_0 |
| boss_appear | the boss is met | boss_appear_1 |
| dizzy | the leader is still reeling from a slam | dizzy_1 |
| wake | a sleeping wild creature is hit awake | wake_0 |
| escape | "You got away." | escape_0 |
| menu_open, menu_close | the bag opens and closes | menu_open_1, menu_close_1 |
| snare_struggle | stuck in the snare | snare_struggle_1 |
| evolve_ready | a creature is ready to evolve | evolve_ready_0, one octave up |

Measured, not heard: the brightest is escape (paws on dirt, lowered to 4.5 kHz and -9 dB). The revive and evolve hum sat near 100 Hz, below what a laptop speaker plays, so they went up an octave.

## The Warden's entrance (Claude, 2026-10-10)

Preston: "eleven labs synthesis it up too." 12 sounds for `scripts/dungeon/boss_intro.gd`, two takes each,
`eleven_text_to_sound_v2`, prompt influence 0.3, flow `lgucGp7YVZlGnAPBhJ26`, 16.7 credits a take
(24 takes, about 400 credits). Takes in `assets/audio/sfx/dungeon/takes/<name>_<0|1>.mp3`; picks, trims and
filters in `tools/audio/build_dungeon_sfx.py` (PICKS, the block after evolve_ready). Picked by measurement
(onset, low end, share of 2 to 6 kHz); Preston's ears overrule.

| Sound | Prompt (short) | Pick |
|---|---|---|
| pond_ambience | peaceful pond at dusk, lapping, reeds, faint crickets | 0 (16 s; looped as the garden's bed, low-passed 4.5 kHz) |
| ripple | a single drop into a still pond | 0 |
| emote_alert | two soft rising marimba notes, the "!" | 1 |
| presence_swell | low ominous drone, an unseen presence | 0 (one octave up for laptop speakers) |
| pond_rumble | underwater rumble and rising bubbles | 0 |
| pond_burst | huge creature bursting out of a pond | 0 |
| water_rain | spray raining back down on grass and water | 0 (less hiss) |
| fall_whoosh | something heavy falling from high above | 0 (one octave up; peaks at the landing) |
| heavy_land | giant creature landing, deep thud | 0 (layered with slam) |
| hop_splash | small frog leaping out of a pond | 0 |
| warden_croak | giant ancient frog croak, cavern echo | 0 |
| battle_wipe | fast whoosh sweep into an impact, battle start | 1 (almost nothing in 2 to 6 kHz) |

## New songs from ElevenLabs music (Claude, 2026-10-10)

`eleven_music_v2_5`, flow `lgucGp7YVZlGnAPBhJ26`, one version each (Preston chose one at a time), 900
credits each. The 440 Hz originals are in `assets/audio/_440hz_originals/music/`; the game's copies are
pitched to 432 by resampling (asetrate 432/440, then atempo back, so the length is kept) and listed
in `retuned.txt`. Rubberband was tried first: it left the drum hits at 440, so resampling is used, which
moves every part. Checked: Monster House's strongest bass note went from 130.0 to 127.6 Hz (x 432/440).

- **pond_garden.mp3**: the Warden's garden, the opening of the boss scene. Preston found the rest-floor
  song there "too medieval". Prompt: a hidden pond garden that looks like a safe place to rest; soft
  synth pads, electric piano, music box and harp arpeggios, glassy chimes, a faint uneasy undertone,
  72 bpm, no folk instruments. Preston: "perfect, a little loud"; lowered 5 dB to about -21 LUFS (the
  dungeon songs sit near -16, the rest floor at -24).
- **monster_house.mp3** (replaced): Preston, "you can make monster house with it next". Prompt: a room
  suddenly full of wild creatures, same modern synth sound but urgent: driving synth bass, fast glassy
  arpeggios, punchy electronic drums, alarm-like stabs, dark minor key, 150 bpm, a drop then crashing
  back in, no folk instruments. Levelled to the old track's loudness (about -16.5 LUFS). The old song is
  kept at `docs/audio/replaced/monster_house_before_2026-10-10.mp3`.

## Job Board scene sounds (Claude, 2026-10-10; Preston: "eleven lab it up as well")
ElevenLabs `eleven_text_to_sound_v2`, flow `lgucGp7YVZlGnAPBhJ26`, two takes each at 16.7 credits (about 133 in all).
Takes in `assets/audio/sfx/dungeon/takes/`; take 1 of each chosen by measurement (quick onset, least energy in
2 to 6 kHz); trimmed and lowered to A = 432 by `tools/audio/build_dungeon_sfx.py`. Played by `scripts/town/board_scene.gd`.
- `paper_tear`: "A paper notice ripped off a wooden board, one quick tearing rip of thick paper and a pin popping out, close up, dry, no music" (low-passed at 5 kHz; paper is bright).
- `hog_grunt`: "A big fat wild hog gives one short smug grunting snort through its snout, low and mean, a bully's sneer, close up, no music"
- `body_shove`: "A heavy body shove: a meaty thump of a big shoulder slamming into a small creature, then a small body tumbling and skidding onto packed dirt, cartoon game impact, no voice, no music"
- `hog_trot`: "A heavy hog trotting away on cobblestones, slow clopping trotters and a little scurrying of small feet beside it, fading into the distance, no voice, no music"

## The Shortcut Crew's theme (Claude, 2026-10-10; Preston: "use synthesis then make rival crew dialogue song")
`assets/audio/music/crew_theme.mp3`, ElevenLabs `eleven_music_v2_5`, flow `lgucGp7YVZlGnAPBhJ26`, 900 credits, 60 s.
Synthesis: handheld dungeon-crawler rival-gang themes are comic villains (swaggering bass, sly brass, staccato phrases with
pauses, a loop that sits under dialogue); Hollowtide's crew are Missouri river-bottom pests, so a muddy swamp jug-band colour.
Prompt: "Instrumental only, no vocals. A sneaky, comic villain theme for a gang of scruffy river-bottom bullies ... oompah tuba
and a plucked upright bass walking chromatically, a sly muted trumpet and a clarinet ... banjo plucks and washboard scrapes ...
cheeky woodblock hits and a sneaky bassoon on the off-beats ... loops cleanly. 60 seconds."
Retuned to A = 432 by resampling (asetrate 432/440, aresample, atempo 440/432) and levelled to -21 LUFS like `pond_garden`;
the 440 original is in `assets/audio/_440hz_originals/music/`. A spectrum match confirms the shift (best fit at 0.9818).
Plays in `board_scene.gd` (the Job Board meeting) and `crew_scene.gd` (Rootbank Warren's boss floor). Preston to approve.

## Storm cold open (Claude, 2026-10-10; ElevenLabs flow lgucGp7YVZlGnAPBhJ26, eleven_text_to_sound_v2, 2 takes each, 8 x 16.7 credits)
All retuned to 432 Hz (asetrate/aresample/atempo). Files in `assets/audio/sfx/story/`, used by `scripts/storm_open.gd`.
- `storm_rain.wav`: replaced the same day (Preston: "a lot of repeating sounds") by a 32 s synthesised loop, `tools/audio/make_storm_rain.py` (hiss, random drops, wind; no generated audio). The two 1 s rain takes are unused.
- `thunder.wav`: take B (4 s, crack then rolling rumble).
- `time_stop.wav`: take A (2 s, reversed whoosh into a ringing silence).
- `soul_descend.wav`: take B (3 s, soft shimmer; take A hit a concurrency limit), raised to -6 dB peak.

## Menu and event sounds, synthesised (Claude, 2026-10-10; `tools/audio/make_ui_sounds.py`)
Preston asked for our own sounds made from Explorers of Sky's. Its files were not used: Sky's menu effects were measured from a recording (YouTube "Pokemon Mystery Dungeon Explorers Sound Effects - Part 3"), and only the measurements guide the synth. Every sample is generated; the jingles use our own notes on A = 432.
- Measured: cursor tick about 40 ms at 1047 Hz and cancel tick 29 ms at 587 Hz, both pure square waves (overtones 1, 0.35, 0.20 at 1x, 3x, 5x); confirm (two notes, about 174 ms) and menu-open (three notes rising, about 214 ms) are 25% pulse waves (overtone 4 absent) with a quiet echo.
- Ours: `ui/cursor.wav` (C6 square tick), `ui/cancel.wav` (D5 then A4 square), `ui/confirm.wav` (A5 to D6 pulse, echo), `dungeon/menu_open.wav` (D5 A5 D6 up), `dungeon/menu_close.wav` (down).
- Events, built in the same family without a clean reference to measure (the effects videos are unlabelled; gameplay has music over them): `dungeon/stairs.wav`, `dungeon/pickup.wav`, `dungeon/level_up.wav` (new; the level-up used room_clear before), `dungeon/faint.wav`.
The files replaced are kept in `docs/audio/replaced-2026-10-10/`.
