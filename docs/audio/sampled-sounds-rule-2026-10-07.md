# Sampled sounds from the Internet Archive (Claude, 2026-10-07)

Preston's idea (2026-10-07): pull source audio from archive.org, cut and reshape it into the sounds we need, then retune to A = 432 Hz like everything else. Yes, and the pipeline for it already half exists. The rule below keeps it shippable.

## The rule
1. **Only items whose rights field says public domain, CC0, or CC BY.** CC BY needs a credit line in the game's credits; keep the attribution text with the file. Skip anything with no licence shown, anything marked non-commercial (the BBC Sound Effects library on the Archive is personal and research use only), and every upload of game or film audio, which is ripped and still copyrighted regardless of who uploaded it.
2. **Safest sources:** US government recordings (NASA, National Park Service, USGS and NOAA field recordings are public domain as government works); pre-1929 recordings (Library of Congress National Jukebox, for tonal material); and CC0 collections. Freesound.org is not the Archive but its CC0 filter is the single best source of raw hits, scrapes, water and fire, and it needs no credit.
3. **Record every source** in `docs/audio/sources.md` (to create with the first sample): item URL, rights line as shown, what we cut from it, and the file it became. That is the proof if a licence question ever comes up.
4. **Reshape until it is ours.** Cut, pitch, layer, filter and crush each sample so the result reads as Hollowtide's sound, not as a recognisable recording. This is good practice and good design; the sound-direction doc already asks for creature sounds built from physiology, not library stings.

## The pipeline
- Download the item file (archive.org serves originals directly; `curl` is enough).
- Cut and reshape in Python the way `tools/build_ironvent_sounds.py` and the other `build_*_sounds.py` scripts already synthesise and layer (numpy, same output format), or with `ffmpeg` filters for simple trims and pitch shifts.
- **432 last.** `tools/retune_432.sh` lowers music by 432/440 (about a third of a semitone) from kept originals. Samples go through the same ratio once, at the end, so nothing is lowered twice. Keep the 440 version beside it as the scripts do for music. Note: 432 only means anything for pitched content; a rock scrape or a dust hit has no A to retune, but the same shift keeps every file consistent and does no harm.

## First use, if Preston wants it
The arena's new rock and slam sounds reuse Root Rampart's slam and eruption. A real stone crack, a boulder shatter and a wall slam are the obvious first samples. Claude can run the Archive's search API for CC0 and public-domain stone and impact recordings (the way the 2026-10-06 scan was done) and list candidates with their rights lines before anything is downloaded.

## What the first search found (Claude, 2026-10-07, same evening)
The Archive's search API, filtered to public domain and CC0: a title search returns LibriVox audiobooks ("Round the Fire Stories"), useless. A subject search ("sound effects", "foley", "field recording") returns 27,000 items, and the top ones show the trap above in practice: the "Universal Studios Sound Effects Library", "Super Mario Bros SFX", "Toy Story isolated SFX" and the Warner Bros "Crash! Bang! Boom!" are all tagged CC0 by their uploaders and are all rips. Of the three plausible self-made collections, two failed inspection: `Sound_Effects` is "pulled from Sound Library 2000, Wayzata Technology 1995" (a commercial CD-ROM) and `bbt_sfx` is a game's asset dump from a throwaway address. One passes: **`various-sound-effects`** by Patrick Lauser, CC0, self-recorded household sounds, with `fire.ogg`, `crackling.ogg`, `break-window.ogg` and `breaklock.ogg`. No stone impacts anywhere worth the risk.

**So the arena's new sounds are synthesised, not sampled** (`tools/build_arena_sounds.py`, same method as every other `build_*_sounds.py`): rock crack, rock break, wall slam, Crest Ram, Cinder Claw and the telegraph tick, all ours outright, pitched elements on A = 432. The one sample worth adding later is Lauser's fire crackle as a layer under Stoke's embers and Furnace Roar; that needs Preston's go-ahead to download (`https://archive.org/details/various-sound-effects`), and the first line of `docs/audio/sources.md` when it happens.
