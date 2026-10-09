# The Canvaswing line in the arena: Canvaswing, Windcut, Galeshear (Claude, 2026-10-08)

**Preston, 2026-10-08:** "do canvaswing line next." Roster draft line 15 (the floodplain glider), DESIGN_RULES' "Gale shelter" (more HP than the runner, less speed, no guard ultimate), the shield-support row of `arena-roles-roster-proposal-2026-10-08.md`. Line 8 in the arena. The stage names are the roster draft's working labels, his to approve; every number is a draft for Grok. Gale is neutral on the arena chart, as `THE_CONCEPT.md` says.

## The Shelter
- **Basic, Shear** (AI): a sail slash (9, 30 px, 0.22 s melee telegraph).
- **1 Sail Cover:** goes at once. A sail thrown over the most hurt ally within 120 px (itself if nobody else needs it): a shield that absorbs the next 20 for 4 s.
- **2 Downdraft:** a column of falling air over the most hurt ally (45 px, 5 s). Enemy shots (fireballs, jade lances in flight) and lobs (seeds, molten glass) that enter it are driven into the ground and do nothing. Beams and rails are instant and pass; that is the counterplay. The AI raises it when a shooter is on the other side.
- **3 Lift** (from stage 2): goes at once, mobility. It grabs the ally in the most trouble (an enemy on it, under 60% HP) and flies it 60 px away from that enemy toward the team; the lift clears roots and cripple, cancels a slam carry, and gives the ally 0.3 s of safety on landing. The glider lands beside it.
- **Passive, Windbreak** (from stage 2): allies within 30 px take 10% less.
- **4 Gale Shear** (Galeshear, 2.6 s): the light goes storm-grey, the sails open and the wind gathers in toward the glider, then one wing sweep sends a wall of wind across the whole floor: **every enemy is carried away from the glider to the arena edge** (a carry, so they slam into walls and rocks on the way and are dazed), and every ally gets a 2 s tailwind. No shield: DESIGN_RULES keeps the guard ultimate for the Protector; this one is displacement.
- **Role layer:** role "Shelter", support group (regenerates when left alone, hits do not wound). Profile escort.
- Stages: Canvaswing has Shear, Sail Cover and Downdraft, no passive, no signature; Windcut adds Lift and Windbreak; Galeshear adds Gale Shear.

## Art
- No front art existed, so the arena takes came from the brief through Retro Diffusion (`rd_creature.py front`, $0.18 a take), backgrounds stripped by the border flood fill, raw and rejected takes kept beside the finals (`_branch`, `_openwings`, `_grownstage1`, `_collar`, `_antlers`, `_lean`, `_clipped`).
- **Preston's art direction, in order:** stage 3 more powerful, like Stormwick's final (bulk, a roar, sails as a wall); stage 2 its own shape, not a slightly grown stage 1 and not a smaller stage 3, and no horns ("the horns look weird there"). The approved set: the crouched kit with folded sails; the dive-brake adolescent banking on a diagonal with notched sails; the storm giant with forked spars and a rudder tail.
- The storm giant twice came back clipped by the 128 px canvas, so the final take was generated at 160 px and shrunk to 128 with the palette-locked resample (`tools/arena/downscale.py`), which lost some of the chest-forward roar; the clipped takes are kept if a later pass wants that pose back.
- Rotations ($0.10 each) and walks, five facings each ($0.14 each), in `arena-starters-2026-10-07/forms/` and `walk/`; sizes in `tools/arena/build_small.py` (canvaswing 0.95, windcut 1.0, galeshear 1.1). **Codex:** palette lock pending, like the other new lines.
- Data files `data/creatures/1501_canvaswing.tres`, `1502_windcut.tres`, `1503_galeshear.tres` (Gale, essence 3) point their `sprite` at the arena south facing as a stand-in front; no back views, default stats, no turn-based moves (Grok).

## Sound
Two ElevenLabs runs (`eleven_text_to_sound_v2`, two takes each): `shear_a` (one canvas snap, cut round it) for Shear, Sail Cover and Lift, `gale_b` (a roar that builds to a gust and drops) for Gale Shear, with `shear` again at the sweep. Picked by envelope, not by ear; the other takes are in `assets/audio/sfx/canvaswing/takes/` (`tools/build_canvaswing_sounds.py`).

## Check (`tools/debug/arena_canvaswing_check.gd`)
- Stage kits: Canvaswing has Shear, Sail Cover and Downdraft, no passive, no signature; Windcut adds Lift and Windbreak; Galeshear adds Gale Shear. All three read Shelter/support in the role layer.
- Shear took 9 from Stormwick. Sail Cover put a 20 shield on the hurt glider; a 15 hit left its HP untouched and the shield at 5.
- Downdraft: an enemy fireball and a lob aimed through the column were both grounded; the glider took nothing (it mended 2 from the support regen meanwhile).
- Lift: the rooted ally 20 px from Ironvent went to 80 px from it with its roots cleared; the glider landed 7 px beside it.
- Windbreak: a 20 hit on the ally beside Windcut took 18; the same hit 80 px away took 20.
- Gale Shear: three enemies 50 px round Galeshear ended at 126, 78 and 78 px, two of them against a wall or rock, 11 slam damage between them; all three allies had the tailwind.
- AI 1v1 Galeshear against Stormwick: lost in 41 s (33 dealt, 324 taken). A shelter alone against the skirmisher should lose, like the Protector and the Controller do; 33 dealt says Shear's 30 px reach rarely finds a kiter. **Grok:** Shear's reach and damage are the levers if the line should trade better alone.
- AI 3v3 with Galeshear, Stormwick and Rampartroot against the Oxbowarchon team: a draw at the 90 s cap with four downdrafts raised against the railgun.
- Stills here: `line_stage1..3.png`, `downdraft.png`, `lift.png`, `gale_gather.png`, `gale_sweep.png`, `ai_1v1.png`, `ai_3v3.png`. The check was rerun after the final art and walks were imported.

## Known
- The stage names are working labels; Preston decides.
- Wing/crown clipping repaired by Codex at Preston's request; see [the wing-repair archive](../galeshear-wing-repair-2026-10-08/README.md) for the current source sheets, native evidence and preserved originals.
- Downdraft does not ground beams, rails or bolts (instant lines); that is the counterplay, not an omission.
- Turn-based: no back views, no stats, no turn-based moves; the signature needs its own attack sheet and move resource before the turn-based battle can use it.

