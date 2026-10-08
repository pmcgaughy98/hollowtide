# Arena control model, feel and readability (Claude, 2026-10-07, evening)

## Preston's control decision (2026-10-07)
Asked whether moving should cancel the creature's AI (the Gemini report's top frustration in hybrid control), Preston answered: **"The AI controls creature movements but player can choose when to activate signature move and what enemy creatures to target."** Built as:
- Your creature's AI does all footwork and uses its kit, like every other creature.
- **Left/right** cycle your target among living enemies (sorted left to right); **up** hands the choice back to the AI. Your creature's AI aims every move at your target while it stands, and the signature (K) goes to it.
- A **marker** shows who your creature is going for: a ring at its feet and a chevron bobbing over its head, red when you chose it, white when the AI did. The HUD prints `TARGET  NAME` above your box, with `(AUTO)` when it is the AI's pick.
- WASD/arrows no longer steer. The old steering stays only for the recorded test movies, which set `debug_input`.

## Feel, from the research (`docs/research/gemini-arena-fighter-research-adoption-2026-10-07.md`)
- **Hitstop:** on a hit both creatures hold for 0.07 s (about 4 frames at 60), 0.15 s for hits of 20 or more, slams and signatures. Effects keep moving. The one that was hit shivers one pixel along the blow.
- **Telegraphs:** attacks wind up before they land, and the wind-up shows on the ground. Red ring round a melee attacker (claw, Cinder Claw, Club Slam: 0.25 to 0.35 s); red ring under the target of a lobbed or rooting move (Seed Pod, Root Snare, Riptide: 0.35 to 0.4 s); red line with a "!" over the target for a shot (Ember Shot, Pressure Jet, Deep Jet, Wick Bolt, Vent Barrage: 0.3 to 0.35 s); **yellow** line for Crest Ram (0.45 s, cannot be interrupted). The shape fills as the moment nears. Paralysis or a dazzle interrupts a red wind-up (label "Interrupted", 0.8 s before it tries again). Dodges, dashes, Sinkhole, Lantern Flash and Root Wall stay instant. Phase and Flashstep AI now also read a telegraph aimed at them in its last 0.12 s.
- **Shake cap:** ordinary hits ask for 2 map pixels (6 on screen), nothing exceeds 6 (18 on screen); the signatures used to ask for 9. **V** turns shake off.

## Readability (Preston, 2026-10-07: "the smoke and black circles cover the creature for too long or entirely")
- Scorches, cracks, embers, Riptide and the whirlpools were drawn on the effects layer **above** the creatures. They now draw on the floor layer under them, so a creature standing in a scorch is never hidden.
- The scorch is smaller (0.45 of the burst instead of 0.6), flatter and lighter (alpha 0.3, was 0.45), and fades from 2 s.
- Smoke: a quarter of the puffs (size/5, was size/2.5), each shorter lived (0.6 to 1.1 s, was 1.0 to 1.8), thinner (alpha 0.22 and 0.28, was 0.35 and 0.4) and rising faster, so the plume clears the sprite inside half a second.
- Stills: `seedpod_0_4s.png` (hit flash and one puff still cross Kithflare), `seedpod_1_0s.png` (clear, faint oval scorch under it).

## Check
`tools/debug/arena_feel_check.gd` (Godot `--fixed-fps 30`): your target order held on the rival Scourmaw through 240 frames of a 3v3 (it lost 32 HP); hitstop 0.07 s after a 10-damage hit; a request for 9 shake gave 6; a rival Root Snare telegraph and your Wick Bolt telegraph were captured; Seed Pod stills saved. Stills here: `target_marker.png`, `telegraph_yours.png`, `telegraph_rival_root_snare.png`, `hitstop.png`. No script errors. Balance after these changes is in `docs/creatures/arena-balance-2026-10-07.md` (wind-ups give dodgers a window, so the numbers moved).

## The matchup picker (Preston, 2026-10-07: "make the move preview scene the new test scene for viewing matchups")
`scenes/move_preview.tscn` (`scripts/move_preview.gd`) is now the project's main scene (F5). Three steps: **your creature** (the twelve forms, one column per line, one row per stage, each with its arena sprite and role), **the enemy** (same grid), **mode** (1 v 1 or 3 v 3), then **FIGHT**. In 3v3 your pick leads your team and the enemy leads theirs; the arena fills the other slots with the other lines at the same stage. **Escape** in the fight returns to the picker. The old Ember move preview (a mirror battle in the turn-based screen) is gone from this scene; the turn-based screen itself is untouched. Check: `tools/debug/matchup_picker_check.gd` (Ironvent vs Scourmaw in 3v3 reached the arena with the right teams; Escape returned). Stills: `picker_step1..3.png`, `picker_fight.png`.

## Sounds, now ElevenLabs (later the same evening)
Preston: "we'll just use ElevenLabs for now, we get 10k a month." Through the ElevenLabs connector (`eleven_text_to_sound_v2`, two takes each, about 333 credits after a top-up): rock crack, rock break, wall slam, Crest Ram, Cinder Claw and a **match-start horn with the crowd**, now played when a match begins. `tools/build_arena_takes.py` trims the chosen take, fades it, lowers it to A = 432 and writes it over the synthesised file; the synthesised versions stay as `synth_<name>.wav` for comparison. Takes were chosen by measurement (onset, decay, brightness; the table is in `docs/audio/sources.md`), not by ear. The telegraph tick stays synthesised. **Preston:** listen and swap any pick in `PICKS`.

## Sounds, first pass (synthesised)
`tools/build_arena_sounds.py` writes `assets/audio/sfx/arena/`: **rock_crack** (a snap, a stone tock, chips falling), **rock_break** (weight, a low burst, a clatter of shards, gravel settling), **wall_slam** (contact crack, thud, dust sifting), **crest_ram** (vents roaring up with heavy feet), **cinder_claw** (a swipe, a sizzle, a hot tick on the 432 scale), **telegraph** (a soft low tick on A3 = 216 Hz when an attack starts winding up; louder when it is yours or aimed at you). All synthesised from shaped noise and tones with fixed seeds, like the other sound builders, so they are ours. The arena no longer borrows Root Rampart's or the UI's sounds for these. The Internet Archive search behind this is recorded in `docs/audio/sampled-sounds-rule-2026-10-07.md`. Loaded and played in `arena_ironvent_check.gd` with no resource errors.

## Abilities on 1-4, MOBA style (Preston, 2026-10-07, late)
"We'll have 4 abilities, MOBA style, activated with number keys 1-4, with 4 being ultimate." Asked who moves, Preston kept the AI on footwork: **the AI moves and uses the basic attack; you fire 1, 2, 3 and the ultimate (4 or K).** Each kit now splits into `moves` (the AI's, the basic) and `abilities` (yours). Dodges and dashes fire at once; attacks telegraph like everyone else's. A move can have **charges**, each on its own cooldown. An enemy creature's AI fires everything. The HUD has an **ability bar** at the bottom centre: cooldowns drain upward, charge pips, and the ultimate's meter. The old test keys 1-5 for picking a line are gone (the picker does that).

**Stormwick, rebuilt to Preston's description** (the Pikachu-versus-Onix rhythm: in, strike, straight back out):
- **Basic, Raptor Pounce** (AI): a 300 px/s dash that stops at the target, strikes (12), and reverses for 0.18 s. Range 58, cooldown 1.4 s.
- **1 Flashstep:** three charges, each on its own 3 s cooldown (Tracer). Same dash of light as before.
- **2 Lantern Volley:** hops 38 px back (the back-jump from the video), then three lantern balls in a 30-degree spread (7 each). Cooldown 6 s.
- **3 Lantern Lunge:** a fixed 70 px dash with hot claws that lands (18, carries, smoulder) only if the target is within 20 px when the dash ends; otherwise "Missed". A read, not a lock-on. Cooldown 5 s.
- **4 Stormlantern**, unchanged. Lantern Flash and Wick Bolt are out of the kit.
- Consequence seen in the check: against a kiter the AI alone cannot close (Scourmaw backs off faster than Stormwick walks), so closing is now the player's Flashstep or Lunge. That is the skill Preston asked for.

Two bugs found by the check and fixed: your own creature's AI used to fire the ultimate when its meter filled (the simulator still may); and a rematch did not cancel a signature in flight, which froze the next fight for its card. Check: `tools/debug/arena_abilities_check.gd` (three Flashstep charges then a refused fourth; volley hop and three balls; Lunge hit from 75 px and miss from 130; the AI's pounce wind-ups with the abilities untouched). Stills: `abilities_*.png`.

## Stormwick's second kit, team control, crates (Preston, 2026-10-07, later still)
Preston replaced the Lunge an hour after it was built and tied the kit together with **marks**:
- **Flashstep has invulnerability frames** (0.35 s; a 20-damage hit during them did nothing in the check). Invulnerable creatures shimmer lantern-gold.
- **Lantern Volley's balls bounce** off the arena edge like ping-pong balls (three bounces, then they die), bounce off rocks and crates, and **mark** whatever they touch: creatures, rocks, crates. A mark lasts 8 s and shows as a small pulsing lantern glyph over the thing. Balls live 2.4 s now, so in a 3v3 a volley aimed at one enemy can mark two more on the rebound.
- **Passive, Lantern Mark** (placeholder name): he can teleport in a flash of light to anything marked. It is what the tackle and its landing use. The old Lantern Charge overcharge is gone from Stormwick.
- **3, Lantern Tackle** (placeholder name; Preston: "like Volt Tackle"): he teleports to his marked enemies, **invulnerable for a fixed 1.0 s whether there is one target or several**, striking one every 0.125 s (6 each) with an arrow of light drawn between the spots; alone, he goes back and forth on the one target. With nothing marked it works his current target. **Left/right while it runs choose the landing**: any marked enemy or object, or the target; the HUD prints `LANDING  CRATE (LEFT/RIGHT)` and the chosen spot gets a ring and the word LAND. In the check: 1.12 s invulnerable, every marked rival struck, landed 12 px from the chosen crate. Cooldown 7 s.
- **Crates:** two wooden crates stand in the arena (one near each side), 20 HP, markable, splinter into planks. There is always something to mark and teleport to in a pinch.
- **Team control:** you are locked onto one of your creatures; **SPACE** switches to the next living one. The yellow ring, the `YOU` label, the target marker and the ability bar follow control. Creatures you are not controlling fire their whole kit, abilities included, through their AI (the check saw the AI Stormwick use its abilities after control moved to Rampartroot). A creature with no `abilities` list yet (everyone but Stormwick) shows only the ultimate in your bar; its moves stay with its AI until Grok and Preston split them.
- Check: `tools/debug/arena_tackle_check.gd`; stills `tackle_*.png`. The 1v1 numbers will have moved again; not re-simulated.

## Playtest fixes (Preston played by hand, 2026-10-07 night)
- **"I think I'm still taking damage during the tackle."** True: Rampartroot's Thorns hit the attacker directly, not through the normal damage path, so invulnerability never saw it. Thorns now respect it. Check: a full tackle against Rampartroot, HP unchanged.
- **"They die too fast."** Base HP 100 to 180. AI fights now run about 38 to 39 s (were 11 to 20). Abilities and cooldowns unchanged, so there is room to use them. **Grok:** this is the pacing lever; everything else is as before.
- **"Flashstep is useless; make it teleport to marked, keep the invulnerability."** Flashstep now teleports (in a flash of light, invulnerable, three charges) to your target if it is marked, else to the nearest marked enemy, rock or crate; with nothing marked it falls back to the old dash. Check: landed 16 px from a marked crate.
- **Rampartroot, a slow-moving tank** (0.6x speed, 1.7x HP). Basic Seed Pod (AI). **1 Tail Club:** the seed-pod club on its tail swings through, a heavy blow that carries the target (37 px in the check) into whatever is behind it. **2 Root Snare.** **3 Root Rampart:** the old signature shrunk to an ability: roots race across the ground to the target, erupt (18, a short hold) and raise a ring of six root pillars for 4 s. Root Wall is out of the kit.
- **New signature, Verdant Roar** (placeholder name), built from the turn-based title card where the seed pod on its tail flares green as it roars; that card is now the close-up art. The pod flares from green to white and the arena goes green; the roar sends a shockwave across the whole field and **roots every enemy where it stands** (rings of roots erupt outward); the glowing club is raised and brought down on the target in a towering slam that leaves a **vine field** (5 s, slows to 0.55 inside). Check: 3 of 3 rivals rooted, vine field down. Stills: `rampart_roar_*.png`, `rampart_rootrun.png`, `rampart_pillars.png`, `rampart_flashstep.png`.
- Check script: `tools/debug/arena_rampart_check.gd`.

## The painted VFX pass (2026-10-07 night, after the commit)
Preston asked for an MCP to upgrade the VFX. The registry and the open MCP lists have nothing better than what is connected: Retro Diffusion's `rd_animation__vfx` style (which made the four impact bursts) and PixelLab's workbench; the Aseprite MCP would edit frames by hand but needs Aseprite installed. So the pass is eight more RD sheets ($0.56, 16 frames each, `tools/arena/rd_vfx.py` then `slice_vfx.py`, half-size so an effect is about creature size), wired where code used to draw shapes:
| Sheet | Where it plays |
|---|---|
| `lantern_ball` (loops) | the head of every lantern projectile (Ember Shot, Lantern Volley, Vent Barrage, Ember Pellet, Furnace Shard), over the coded trail |
| `light_slash` | under every claw strike: pounce, tackle hops, Cinder Claw, Glass Spur |
| `lantern_flash` | every teleport: Flashstep, each tackle hop and the landing |
| `glass_splash` | molten hits: Molten Cannon landing, Molten Beam contact |
| `rock_dust` | a rock or crate shattering, and every wall or rock slam |
| `vent_flame` | Stoke and Kiln venting, Vent Barrage's launch |
| `root_burst` | Root Snare, Root Rampart's eruption |
| `mark_glyph` (loops) | every lantern mark on a creature or object |
`_draw_sheet` plays a sheet at a point, looping or once. Check: `tools/debug/arena_vfx_pass_check.gd`, stills `vfx_*.png`. Known: the first `lantern_ball` take came back as a cluster of three small balls per frame, which made a volley look like nine fireballs; it was regenerated with a single-object prompt (the cluster take is kept as `lantern_ball_cluster_take1_sheet.png`). The `glass_splash` middle frames sit the molten blob on a small pedestal; acceptable at play speed. **Codex:** these twelve sheets are raw RD output, not colour-checked.

## Scourmaw's ability kit (2026-10-07 night, a draft for Grok)
Mapped from its existing arena moves; Preston asked for "Scourmaw kit" without specifics, so the one design change is Sinkhole's purpose.
- **Basic, Deep Jet** (AI): the long pressure beam, 1.3x from beyond 110 px.
- **1 Phase:** 0.6 s of absence; attacks pass through, and it slips out of roots (crippled stays). Phase now also stops a direct hit, not only shots and lobs (Undertow's jaws from below still land).
- **2 Riptide:** a current under the target that slows, pulls in and shuts off its movement abilities.
- **3 Sinkhole, now an ambush:** it sinks and comes up 30 px behind its target (the far side from where it stood), and its next Deep Jet within 3 s is sharpened (x1.8, enough to beat the distance bonus it gives up by closing in; the shot spends it, labelled "Ambush"). The AI uses it when the target is far or something has closed in. Before, Sinkhole only fled.
- **Passive, Absence:** unchanged (holes, hover, erosion: a creature it hits takes +25% for 3 s).
- **4 Undertow**, unchanged.
- Check: `tools/debug/arena_scourmaw_check.gd`: Phase, a Riptide under the target, a Sinkhole that resurfaced 33 px behind the target with the sharpened jet, and the AI firing Deep Jet as the basic. Stills `scourmaw_*.png`.

## Not done
- Sounds for the team fights themselves (a start horn, a knockout sting per creature) and a fire-crackle layer from the one usable Archive sample, pending Preston's download approval.
- A rematch and line keys still exist for testing; a real menu is not built.
- Hitstop during the signature close-up card is skipped on purpose (the card already freezes the fight).
