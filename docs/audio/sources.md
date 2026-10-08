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

