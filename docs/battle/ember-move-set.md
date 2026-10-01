# Ember creature move set

These are playable first-pass move choices for the nine Forge creatures. Names, power, and uses are provisional; the anatomy and visual cues come from `creature-roster-draft.md` and Preston’s effect sheets. The Forge JPEG originals stay in `docs/HollowTide Sprites/`. No new art was generated.

Each creature has four damaging Ember moves. A basic move is unlimited; the other three have 6, 4, and 2 uses per battle. Status effects, accuracy, and sound are future work. Power is 32/40/50/60, so this pass tests pacing and visual identity rather than final balance.

| Creature | Move | Brief | Power | Uses | Effect art |
| --- | --- | --- | ---: | ---: | --- |
| Cinderhide | Ember Flick | A small controlled spark from an ember vent. | 32 | ∞ | clinker_ember → cinder_burst |
| Cinderhide | Vent Rake | A close foreclaw sweep that opens a brief line of heat. | 40 | 6 | cinder_arc → cinder_burst |
| Cinderhide | Coal Spit | A compact coal launched from the chest vents. | 50 | 4 | clinker_orb → clinker_star |
| Cinderhide | Spineflare | A warning flare along the broken spine. | 60 | 2 | cinder_arc → clinker_burst |
| Clinkerhide | Brow Shear | The swept brow shield cuts a hot arc. | 32 | ∞ | clinker_arc → clinker_star |
| Clinkerhide | Clinker Toss | A heavy clinker knocked from the tail. | 40 | 6 | clinker_rock → clinker_star |
| Clinkerhide | Vent Row | Paired vents fire in sequence along the spine. | 50 | 4 | clinker_blade → clinker_burst |
| Clinkerhide | Slagburst | Stored heat breaks through the shoulder crust. | 60 | 2 | clinker_orb → clinker_burst |
| Ironvent | Crest Ram | The ram crest drives through a narrow opening. | 32 | ∞ | iron_lance → iron_burst |
| Ironvent | Club Cinder | A tail club throws a clinker at the target. | 40 | 6 | clinker_rock → iron_star |
| Ironvent | Vent Barrage | The stepped ridge answers with repeated bursts. | 50 | 4 | iron_ember → iron_burst |
| Ironvent | Furnace Roar | A full warning vent becomes a crushing blast. | 60 | 2 | iron_lance → iron_star |
| Kithflare | Signal Spark | A quick spark that marks the route ahead. | 32 | ∞ | clinker_ember → kith_burst |
| Kithflare | Tail Brake | The forked tail snaps during a sudden stop. | 40 | 6 | kith_arc → kith_burst |
| Kithflare | Shoulder Kindle | Paired shoulder sacs flash as it changes pace. | 50 | 4 | kith_arc → way_burst |
| Kithflare | Handoff Dash | A fast handoff step carries an ember through the target. | 60 | 2 | way_arc → kith_burst |
| Wayburn | Relay Arc | A sweeping heat signal from the forward shoulder. | 32 | ∞ | way_arc → way_burst |
| Wayburn | Shoulder Drive | The layered shoulder chambers propel a direct rush. | 40 | 6 | way_lance → way_star |
| Wayburn | Tail Shutter | The tail shutter opens just long enough to flash. | 50 | 4 | kith_arc → way_star |
| Wayburn | Wayflare | A long run ends in a focused fireburst. | 60 | 2 | way_lance → way_burst |
| Coalcrest | Crest Signal | The split crest sends a distant fire signal. | 32 | ∞ | coal_spark → coal_burst |
| Coalcrest | Furnace Bolt | The shielded chest furnace fires a compact bolt. | 40 | 6 | coal_core → coal_burst |
| Coalcrest | Plate Rake | Plated haunches anchor a clawing strike. | 50 | 4 | coal_claw → coal_ultimate |
| Coalcrest | Longfire Burst | The runner releases heat saved over a long distance. | 60 | 2 | coal_spark → coal_burst |
| Fusern | Seam Spark | A thin spark escapes the furnace seam. | 32 | ∞ | fusern_spark → fusern_burst |
| Fusern | Hex Cut | The faceted shell strikes along an angular edge. | 40 | 6 | fusern_wedge → fusern_burst |
| Fusern | Ember Pellet | A small heat pellet rolls from under the shell. | 50 | 4 | fusern_ember → fusern_burst |
| Fusern | Kilnburst | The tucked chamber opens in a short blast. | 60 | 2 | fusern_coal → fusern_burst |
| Slagglass | Glass Spur | An opened glass plate throws a sharp hot spur. | 32 | ∞ | slag_spur → slag_burst |
| Slagglass | Shield Flare | The raised shield reflects a narrow heat flash. | 40 | 6 | slag_glass → slag_star |
| Slagglass | Furnace Shard | A fractured plate carries heat from the protected chamber. | 50 | 4 | fusern_coal → slag_star |
| Slagglass | Glassburst | The opened shell releases a broad asymmetric burst. | 60 | 2 | slag_spur → slag_burst |
| Vitrecrag | Fracture Dart | A small hot shard breaks from a glass shelf. | 32 | ∞ | vit_chip → vit_burst |
| Vitrecrag | Window Flare | Heat escapes through fractured chamber windows. | 40 | 6 | vit_flame → vit_burst |
| Vitrecrag | Plate Lunge | A shielding front plate becomes a piercing strike. | 50 | 4 | vit_lance → vit_burst |
| Vitrecrag | Kiln Star | The guarded heat chamber releases a wide burst. | 60 | 2 | vit_rock → vit_burst |

The effect-art names in the last column map to exact Forge source files in `docs/battle/move-effect-sources.json`. The prepared PNGs are under `assets/sprites/effects/forge/`, with one Godot animation scene and one MoveData resource per move. All battle animations still use the existing travel, impact, hitstop, shake, and damage-number timing.

The nine Godot CreatureData resources use provisional Dex IDs for forms not already numbered. Their stats remain the common prototype values. Evolution links are left unset because the victory trigger is not approved as final. Vitrecrag has a new front sprite as of this scan, but no back sprite.

## Preview in Godot

Open `scenes/move_preview.tscn` and use **Run Current Scene** (F6). Pick any form to play a mirror battle with its four moves; Flee returns to the form chooser. The main game still starts with Cinderhide and its four move choices. This preview scene is a review tool, not a location in the world.

Seven forms also use Claude’s prepared back sprites on the player side. Ironvent and Vitrecrag currently use their front art until a back view is made.
