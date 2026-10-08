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
