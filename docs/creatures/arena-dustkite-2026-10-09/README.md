# The Dustkite line in the arena: Dustkite, Waywhistle, Highsignal (Claude, 2026-10-09)

**Preston, 2026-10-09:** "dustkites turn." Roster draft line 14 (the bluff whistler), the Spotter row of `arena-roles-roster-proposal-2026-10-08.md`: watchful, never the runner, never the interrupt (DESIGN_RULES). Line 9 in the arena. The stage names are the roster draft's working labels, his to approve; every number is a draft for Grok. Gale is neutral on the arena chart.

## The Spotter
- **Basic, Whistle Dart** (AI, or J): a thin fast dart down the line (9, 130 px, 0.22 s line telegraph). From a perch it reaches 30 px further.
- **1 Signal Mark:** goes at once (160 px). The target is marked for the usual mark time: the whole team's hits on it land 15% harder, and Stormwick's teleport passive can jump to it like any mark.
- **2 Decoy Call:** goes at once (160 px). A bluff: the arena shows a Whistle Dart telegraph aimed at the target and nothing fires, so an enemy that dodge-steps, dashes or Phases spends it on air. The AI calls it when the enemy's dodge, dash or Phase is ready.
- **3 Vantage** (from stage 2): goes at once, mobility. It hops onto the nearest rock within 90 px and perches there: melee sweeps cannot reach it and its dart reaches further. Steering hops it down; the AI keeps the perch up to 6 s while an enemy is within a perched dart's reach. **Counterplay:** a melee blow aimed at a perched creature lands on the rock under it instead, and when the rock breaks (a part break) the perched creature is launched off it.
- **Passive, Spotter** (from stage 2): the first enemy to come within 120 px is marked, each enemy again only after 10 s.
- **4 High Signal** (Highsignal, 2.5 s): the spotter rears with its throat lit and three rings of sound cross the floor; at the carry (1.0 s) every enemy is marked for 8 s and signalled: the team's next ability hit on each of them is doubled. Dotted tethers of light run from the spotter to every mark for two seconds.
- **Role layer:** role "Spotter", support group (regenerates when left alone, hits do not wound). Profile kite, far bonus 1.15 (1.2 on the final).
- Stages: Dustkite has Whistle Dart, Signal Mark and Decoy Call, no passive, no signature; Waywhistle adds Vantage and the Spotter passive; Highsignal adds High Signal.

## Art
- No front art existed, so the arena takes came from the brief through Retro Diffusion (`rd_creature.py front`, $0.18 a take), backgrounds stripped by the border flood fill, raw and rejected takes kept beside the finals.
- **First set rejected by me, not by Preston:** all three came back as bats (a flying squirrel, a bat, a bat-dragon) although the prompt said "not a cute bat"; the words "glider" and "membranes" pull the model there, and spread wings rotate badly anyway (the Galeshear lesson). Kept as `_bat`.
- **Second set, the one in `lineup_3x.png`:** the anchor changed to a gliding lizard (a Draco) with the flank membranes folded along the sides, every stage upright and compact. Dustkite crouched with the membranes tucked; Waywhistle lanky, long-necked, mouth open calling, ribbed membranes half folded; Highsignal rearing on its hind legs with the membranes raised into a tall crest and a swollen throat. Highsignal's first take clipped at 128 px (kept as `_clipped`); the final was generated at 160 px and shrunk with the palette-locked resample (`_160` is the full one). **Preston approved the line on 2026-10-09 evening** ("Highsignal remakes look great", take 1 of the two remakes chosen for stage 3; see `arena-remakes-2026-10-09/`). Rotations ($0.30) and walks (15 facings, $2.10) are made; all three rotation sheets read in the standard layout; `build_small.py` sizes dustkite 0.9, waywhistle 1.0, highsignal 1.1. The debris check flags Waywhistle's south frames at 0.10 to 0.18 pale share, which is its ivory chest and belly, not a white block. The anchor and Spotter checks pass with the real art.
- Sizes in `tools/arena/build_small.py` (dustkite 0.9, waywhistle 1.0, highsignal 1.1); `slice_rotations.py` and the simulator know the line. **Codex:** palette lock pending, like the other new lines.
- Data files `data/creatures/1401_dustkite.tres`, `1402_waywhistle.tres`, `1403_highsignal.tres` (Gale, essence 3) point their `sprite` at the arena south facing as a stand-in front; no back views, default stats, no turn-based moves (Grok).

## Sound
Two ElevenLabs runs (`eleven_text_to_sound_v2`, two takes each): `whistle_dart_a` (two sharp pips, cut to 0.6 s) for the dart, the mark and the decoy; `high_signal_a` (one held note, 1.75 s) for the signature. Picked by envelope, not by ear; the other takes are in `assets/audio/sfx/dustkite/takes/` (`tools/build_dustkite_sounds.py`).

## Check (`tools/debug/arena_spotter_check.gd`)
- Stage kits as above; all three read Spotter/support in the role layer.
- Whistle Dart took 9 from Stormwick. Signal Mark: a 20 hit on the marked Stormwick took 23, the same hit unmarked took 20.
- Decoy Call: the false telegraph showed; Stormwick stepped out of nothing and its dodge went on cooldown (3.9 s left).
- Vantage: perched on a stone; Ironvent's claw from 20 px took 0; the dart reaches an enemy 150 px out from the perch.
- Spotter passive: the enemy that came within 120 px was marked (7.9 s left).
- High Signal: 3 of 3 enemies marked and signalled; an ally's 20 ability hit took 46 (marked 1.15, signal 2.0), the next 23.
- AI 1v1 Highsignal against Stormwick: lost in 37 s (15 dealt). A spotter alone against the skirmisher should lose, like the other supports. 15 dealt says the perch and the kite profile keep it alive but not scoring; **Grok:** the dart's damage and the mark bonus are the levers if the line should trade better alone.
- AI 3v3 with Highsignal, Stormwick and Rampartroot against the Vitrecrag team: a draw at the 90 s cap.
- Stills here: `line_stage1..3.png`, `mark.png`, `decoy.png`, `vantage.png`, `high_signal.png`, `ai_1v1.png`, `ai_3v3.png` (stand-in art).

## Found on the way: every AI creature froze on its first dash
Last night's motion pass gave the AI a mid-dash early return in `_move_ai`, but only `_walk` runs the dash timer down, so an AI creature that dodge-stepped or dashed once stood frozen for the rest of the fight (Stormwick sat in a corner at `dash 0.13` for 30 s in the probe). Fixed: the mid-dash branch now calls the walk with no steering. **This taints the Smite-pass duel table** in `arena-balance-2026-10-08.md` (tanks never dash, which is one reason they ran the table); a fresh ten-final table is in `arena-sim-2026-10-09-dustkite.log` and the balance doc.

## Known
- The stage names are working labels; Preston decides.
- The art is at the take stage: no rotations, no walks, stand-in facings in the arena.
- A perched creature still takes shots, lobs, beams and area moves; only melee sweeps miss it.
- Turn-based: no back views, no stats, no turn-based moves; the signature needs its own attack sheet and move resource before the turn-based battle can use it.
