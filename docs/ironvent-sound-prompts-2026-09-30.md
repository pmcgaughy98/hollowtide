# Ironvent sound effects: plan and ElevenLabs prompts

Preston, 2026-09-30: do Ironvent's audio the way Vitrecrag's was done, from its physiology, with the sounds tied to the
vents.

**Status: live in Furnace Roar.** The connector's run call failed on 2026-09-30, so Preston generated the takes himself
(19 files in OneDrive `HollowTide Sprites/Creature-Sounds`). They are copied to `assets/audio/sfx/ironvent/layers/`
(`roar_a`, `inhale_a/b`, `furnace_a/b`, `hiss_a/b`, `jet_a/b`, `strain_a/b`, `crack_a/b`, `geyser_a`, `slag_a/b`,
`cool_a/b`; the two roar takes are the same file). `tools/build_ironvent_sounds.py` mixes them into seven sounds in
`assets/audio/sfx/ironvent/`: `cry`, `buildup`, `vent_hiss`, `vent_jet`, `roar`, `blowdown`, `cool`.

Most takes are one second long. The mixer overlaps copies to make steady beds and slows the roar down (slower is also
deeper). Longer takes of the roar (3 s), furnace (3 s) and fire geyser (3 s) would improve the result most.

**Checked in the engine (headless):** the cry starts as the title card's close-up lands; the buildup starts with the
attack; three vent hisses play as the vents light, pitched 1.0, 1.12 and 1.24; the roar and four staggered vent jets
start on the release; the roar is faded at the hush; the blowdown starts on the finale; the cooling starts as it
settles. **Not checked:** how it sounds. That needs Preston's ears.

Flow with the prompts: https://elevenlabs.io/app/flows/xPEJTo1VIDANiC6QVpLn (the last ten nodes).

## The idea
Ironvent is a living blast furnace: a coal-and-iron reptile whose dorsal vents are organic pressure valves, not machine
chimneys. So its voice is a deep reptile roar with furnace fire in the throat, and the vents are where the pressure
shows. Vitrecrag's voice is brass and locomotive; Ironvent's is breath, fire and iron, so the two do not blur together.

## Where each sound goes in Furnace Roar

| Moment | What you see | Sound |
|---|---|---|
| Title card close-up | the enhanced picture slams in | **roar**, short, as the cry |
| Frames 0 to 4 (about 1.8 s) | chest draws breath, heat climbs vent by vent from tail to head | **inhale** under a rising **furnace** rumble and **iron strain**; one **vent hiss** as each vent lights, each pitched a step higher than the last |
| Frame 5, the release | jaws open, the vents blow | **roar** at full length; one **vent jet** per vent, staggered with the jets on screen |
| Frames 5 and 6 | geysers erupt across the field | the **fire geyser** layer, low, under the roar |
| Strain hush | everything holds | silence (the battle already fades attack sounds here) |
| Frame 7, the finale | the giant geyser under the opponent | **ground crack**, a synthesized sub drop, **fire geyser** at full, the roar pitched down, **slag rain**, open-air reverb |
| Frames 8 and 9 | it settles and cools | **cooling** sigh and ticking iron |

The vent hiss and vent jet are move settings (`vent_charge_sound`, `vent_jet_sound`, `vent_sound_db`), so the battle
plays them at the exact moment each vent lights or blows. The cry is `card_sound`, played on the title card's close-up.

## Prompts (2 takes each)

1. **Roar:** `Colossal armored reptile roar, deep guttural bellow with a roaring blast furnace fire inside its throat, rushing forced air, long and powerful`
2. **Inhale:** `Huge beast drawing one deep breath, giant forge bellows sucking in air, low hollow rushing intake that rises`
3. **Furnace:** `Blast furnace roaring heard from inside a thick iron chamber, deep low steady fire rumble`
4. **Vent hiss:** `One short sharp puff of pressurized steam from a blowhole, a hot hiss that starts hard and fades quickly`
5. **Vent jet:** `Violent jet of fire and steam blasting out of a pressure vent, screaming hiss and roaring whoosh, like a geyser blowhole`
6. **Iron strain:** `Heavy iron plates creaking, groaning and pinging as they heat up and expand under pressure`
7. **Ground crack:** `The ground splitting open explosively, a huge sharp crack of breaking rock followed by heavy crumbling`
8. **Fire geyser:** `A massive geyser of fire erupting out of the ground, a deep roaring column of flame and steam that keeps blasting`
9. **Slag rain:** `Sparks and hot slag raining down onto the ground, bright sizzling crackles and embers pattering`
10. **Cooling:** `A long slow sigh of steam fading out, with hot iron ticking and pinging as it cools and contracts`

Save the takes as `roar_a.mp3`, `roar_b.mp3` and so on into `assets/audio/sfx/ironvent/layers/`. Claude then mixes them
(a copy of `tools/build_vitrecrag_sounds.py` for Ironvent) and wires them into `data/moves/ironvent_furnace_roar.tres`.
