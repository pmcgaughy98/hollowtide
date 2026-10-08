extends Node2D
## Arena fighter prototype (Preston's pivot, 2026-10-07; look modelled on the "Pokemon
## Arena" fan game). You against a rival on a top-down arena.
##
## How a fight works (Preston, 2026-10-07, revised that evening): "The AI controls creature
## movements but player can choose when to activate signature move and what enemy creatures
## to target." So your creature's AI does the footwork and uses its kit; you pick which enemy
## it goes for (left/right, up for its own choice) and when the signature fires (K). Kits mix
## damage, mobility and utility moves, and every form can have a passive. First to 0 HP loses.
## Abilities (Preston, 2026-10-07, late): "we'll have 4 abilities, MOBA style, activated with
## number keys 1-4, with 4 being the ultimate." Each kit names up to three ABILITIES the
## player fires (1, 2, 3) and the rest of its MOVES, which its AI uses on its own (the basic
## attack). 4 (or K) fires the signature. A move can have CHARGES, each on its own cooldown
## (Flashstep: three, like Tracer's blink). An enemy creature's AI fires everything.
## Team control (Preston, 2026-10-07, late): in a team fight you are locked onto one of your
## creatures; SPACE switches to the next one. Creatures you are not controlling use their
## whole kit, abilities included, through their AI.
##
## Stormwick's kit, second version (Preston, same evening): Flashstep has invulnerability
## frames; Lantern Volley's balls bounce off the arena edge like ping-pong balls and MARK what
## they hit (creatures, rocks, crates); his passive lets him teleport in a flash of light to
## anything marked; the third ability (placeholder name Lantern Tackle) zips between marked
## enemies, invulnerable, striking each, for a fixed time whether there is one target or
## several, and you pick where to land (left/right while it runs). Crates stand in the arena
## so there is always something to mark and teleport to in a pinch.
## Keys: left/right target (or landing, during a tackle), up auto-target, 1-3 abilities,
##       4 or K ultimate, SPACE switch creature, F your stage,
##       T rival, G rival's stage, N team size (1v1, 2v2, 3v3), B rocks on/off,
##       V shake on/off, M arena, R rematch. Your line is chosen in the matchup picker.
##
## Feel (from the 2026-10-07 arena research): a short HITSTOP freezes both creatures on a hit
## while the effects keep moving; AI attacks TELEGRAPH on the ground before they land (red: a
## hit coming, yellow: a charge that cannot be interrupted); screen shake is capped.
##
## Rocks and slams (2026-10-07, from the reference's event inventory): boulders block
## movement and shots, crack, and shatter into rubble that stays. Big hits carry the target,
## and a creature carried into a rock, a root wall or the arena wall is slammed and dazed.
##
## Teams (2026-10-07): any number of fighters, each on team 0 (yours) or team 1 (the
## rival's). Fighter 0 is always the one you steer; every other creature is AI. Each AI
## picks its own target by role, and a team wins when the other has no one standing.
##
## The fight is rendered at the arena map's own size (384 x 216 "map pixels") in a
## SubViewport and shown at 3x with no smoothing, as the reference does: creatures, every
## effect, line and puff of smoke land on one chunky pixel grid. The HUD, move names and
## the signature close-up are drawn at full screen resolution on top. Sprites: tools/arena/.
##
## PROVISIONAL: every number and every kit below is a placeholder for Grok's rules.

const ArenaSignature = preload("res://scripts/arena/arena_signature.gd")
const HOLLOW_SHADER = preload("res://scripts/arena/hollow.gdshader")

## Each starter line: its three forms (arena art folder and data file, which gives the
## name and the close-up art), its line's signature and a HUD colour.
const LINES := [
	{"forms": [["kithflare", "res://data/creatures/103_kithflare.tres"], ["sparkwick", "res://data/creatures/109_kithflare2.tres"], ["stormwick", "res://data/creatures/110_kithflare3.tres"]],
		"signature": "Stormlantern", "accent": Color("#ff8a2a")},
	{"forms": [["tallowroot", "res://data/creatures/1701_tallowroot.tres"], ["huskward", "res://data/creatures/1702_tallowroot2.tres"], ["rampartroot", "res://data/creatures/1703_tallowroot3.tres"]],
		"signature": "Verdant Roar", "accent": Color("#8fd16a"),
		"card": "res://assets/sprites/creatures/starter_material_detail_2026_10_05/rampartroot_signature_title_material_refined.png"},
	{"forms": [["rimefin", "res://data/creatures/001_rimefin.tres"], ["riftfin", "res://data/creatures/502_riftfin.tres"], ["scourmaw", "res://data/creatures/503_scourmaw.tres"]],
		"signature": "Undertow", "accent": Color("#5ec8ff")},
	# The Ironvent line (Ember/Stone), added 2026-10-07: arena art from Retro Diffusion.
	{"forms": [["cinderhide", "res://data/creatures/002_cinderhide.tres"], ["clinkerhide", "res://data/creatures/101_clinkerhide.tres"], ["ironvent", "res://data/creatures/102_ironvent.tres"]],
		"signature": "Furnace Roar", "accent": Color("#e8572a"),
		"card": "res://assets/sprites/creatures/attacks/ironvent_furnace_roar/style_matched/back_palette_2026_10_05/titlecard_official_2026_09_30.png"},
	# The Vitrecrag line (Ember kiln, then armour, then the cannon), added 2026-10-07.
	{"forms": [["fusern", "res://data/creatures/106_fusern.tres"], ["slagglass", "res://data/creatures/107_slagglass.tres"], ["vitrecrag", "res://data/creatures/108_vitrecrag.tres"]],
		"signature": "Molten Glass", "accent": Color("#ffa030")},
	# The Oxbowarchon line (Preston, 2026-10-08): the ELECTRIC GEMSTONE KING, Electric/Stone, a
	# pseudo-legendary like Ironvent (no longer Preston's personal line). Its emerald is the
	# Electric king stone, the charge between the rails, and Kingstone Rail fires its power.
	{"forms": [["preostmar", "res://data/creatures/901_preostmar.tres"], ["oathfen", "res://data/creatures/902_oathfen.tres"], ["oxbowarchon", "res://data/creatures/903_oxbowarchon.tres"]],
		"signature": "Kingstone Rail", "accent": Color("#12b76a"),
		"card": "res://assets/sprites/creatures/attacks/oxbowarchon_kingstone_rail/style_matched/titlecard.png"},
	# The Punchybuns line (Electric), Adrianna's ferret, taken over by Preston and Claude on
	# 2026-10-08 (Gabrielle is no longer involved); Claude named Sparkjab and Starward. The
	# PROTECTOR: the one line whose signature is a guard.
	{"forms": [["punchybun", "res://data/creatures/2101_punchybun.tres"], ["sparkjab", "res://data/creatures/2102_sparkjab.tres"], ["starward", "res://data/creatures/2103_starward.tres"]],
		"signature": "Starshield", "accent": Color("#ff7ad0")},
]

## Every form's kit: its moves in the order its AI considers them, its walking speed and
## its passive. Stormwick's is the first full kit; the others carry their line's basic
## attack until their kits are designed (draft proposals: docs/creatures/arena-kits-2026-10-07.md).
## Roles (Preston, 2026-10-07): melee, long range, defense piercer, tank, assassin and more;
## the role decides how the creature's AI moves ("profile") as well as its kit.
const KITS := {
	# Every stage has its own kit (Preston, 2026-10-08: "give every stage their own kits based
	# off their physiology and how they should play in Hollowtide"). Each form's moves come off
	# the parts its art shows, and each stage plays its own way, not a trimmed copy of the
	# final. Shape: stage 1 = basic + 2, stage 2 = basic + 3 + passive, stage 3 = + signature.
	# The table with the reasons: docs/creatures/arena-stage-kits-2026-10-08.md. Grok owns
	# every number; placeholder names are marked there.
	#
	# Stormwick line (Ember, then Ember/Electric with the lantern).
	# Kithflare: a small fire runner with claws and a hot tail, no lantern. A harasser: rakes up
	# close, feints out through its own embers, spits ember shots from range.
	"kithflare": {"moves": ["claw"], "abilities": ["ember_feint", "fireball"], "speed": 1.2, "profile": "skirmish"},
	# Sparkwick: the lantern has lit on its tail. A zapper that pounces: Wick Bolt from the
	# lantern, the volley, and Lantern Charge (running charges an overcharged bolt).
	"sparkwick": {"moves": ["pounce"], "abilities": ["ember_feint", "wick_bolt", "lantern_volley"], "speed": 1.3,
		"passive": "lantern_charge", "profile": "skirmish"},
	# Stormwick (Preston, 2026-10-07): an agile melee attacker like Pikachu against Onix in the
	# reference: pounce in, strike, bounce out. 1 Ember Feint (replaced Flashstep 2026-10-08),
	# 2 Lantern Volley (hops back, fires the bouncing marking balls), 3 Lantern Tackle (the zip
	# between marks). Passive Lantern Mark. 4 Stormlantern.
	"stormwick": {"role": "Skirmisher", "moves": ["pounce"], "abilities": ["ember_feint", "lantern_volley", "lantern_tackle"], "speed": 1.4,
		"passive": "lantern_mark", "profile": "skirmish"},
	# Rampartroot line (Bloom, then Bloom/Stone).
	# Tallowroot: a seed burrower. Spits seed pods, snares with roots, and burrows under the
	# ground to come up behind whatever it is fighting.
	"tallowroot": {"moves": ["seed"], "abilities": ["root_snare", "burrow"], "speed": 0.9, "hp": 1.1, "profile": "press"},
	# Huskward: the husk has hardened and the tail club has grown. A bruiser-tank: the club, the
	# snare, and Root Wall (a curve of roots behind a target that keeps its distance). Rampart.
	"huskward": {"moves": ["seed"], "abilities": ["club_slam", "root_snare", "root_wall"], "speed": 0.7, "hp": 1.4,
		"passive": "rampart", "profile": "press"},
	# Rampartroot (Preston, 2026-10-07 night): a slow-moving tank. Basic Seed Pod; 1 Tail Club
	# (a club swing with its tail that knocks back), 2 Root Snare, 3 Root Rampart (the old
	# signature, shrunk to an ability). 4 Verdant Roar, the new signature (placeholder name).
	"rampartroot": {"role": "Tank", "moves": ["seed"], "abilities": ["club_slam", "root_snare", "root_rampart"], "speed": 0.6, "hp": 1.7,
		"passive": "rampart", "profile": "press"},
	# Scourmaw line (Tide, then Tide/Hollow).
	# Rimefin: a small river fish with a pressure jet. Keeps its distance, lays a riptide, and
	# dives under the water to come up behind.
	"rimefin": {"moves": ["beam"], "abilities": ["riptide", "dive"], "profile": "kite"},
	# Riftfin: faster, the jaw growing. The dive, the riptide, and Deep Jet from range.
	"riftfin": {"moves": ["beam"], "abilities": ["riptide", "dive", "deep_jet"], "hp": 0.9, "speed": 1.1, "profile": "kite", "far_bonus": 1.15},
	# Long-range assassin: glass cannon, hit and run, keeps its distance and phases away.
	# Scourmaw (ability kit, 2026-10-07 night, a draft for Grok): basic Deep Jet (AI); 1 Phase
	# (attacks pass through; breaks roots); 2 Riptide (a current under the target); 3 Sinkhole,
	# now an ambush: it sinks and comes up behind its target, and its next Deep Jet within a
	# few seconds hits harder. Passive Absence (hits erode the target). 4 Undertow.
	"scourmaw": {"role": "Assassin", "moves": ["deep_jet"], "abilities": ["phase", "riptide", "sinkhole"], "hp": 0.85, "passive": "absence", "profile": "kite",
		"far_bonus": 1.3},
	# Ironvent line (Ember/Stone bruisers), from its turn-based moves (Crest Ram, Cinder Claw,
	# Vent Barrage, Furnace Roar).
	# Cinderhide: a small vent reptile with claws. Rakes and pounces, with a vent barrage to open.
	"cinderhide": {"moves": ["cinder_claw"], "abilities": ["vent_barrage", "pounce"], "profile": "press"},
	# Clinkerhide: the crest has come in. The ram, the barrage, Vent Blast; Stoke.
	"clinkerhide": {"moves": ["cinder_claw"], "abilities": ["crest_ram", "vent_barrage", "vent_blast"], "hp": 1.15, "speed": 0.9,
		"passive": "stoke", "profile": "press"},
	# Ironvent: basic Cinder Claw; 1 Crest Ram, 2 Vent Barrage, 3 Vent Blast (placeholder name:
	# a gout of heat from the back vents, a short cone that throws back and smoulders). Stoke.
	"ironvent": {"role": "Bruiser", "moves": ["cinder_claw"], "abilities": ["crest_ram", "vent_barrage", "vent_blast"], "speed": 0.85, "hp": 1.3,
		"passive": "stoke", "profile": "press"},
	# Vitrecrag line (Ember kiln tanks).
	# Fusern: a small round kiln beetle. Ember pellets, a short molten pour, and it can run its
	# shell molten (Glass Guard) when something closes in.
	"fusern": {"moves": ["ember_pellet"], "abilities": ["molten_beam", "glass_guard"], "hp": 1.1, "speed": 0.85, "profile": "press"},
	# Slagglass (redesigned 2026-10-08 as the brick dome, no spurs): shoves with its shell,
	# shoots furnace shards, pours, guards. Kiln Heat.
	"slagglass": {"moves": ["plate_lunge"], "abilities": ["furnace_shard", "molten_beam", "glass_guard"], "hp": 1.3, "speed": 0.75,
		"passive": "kiln", "profile": "press"},
	# Vitrecrag (Preston, 2026-10-08) is the EMBER TANK: slow and heavy, it walks up and holds
	# the line. Basic Plate Lunge (AI); 1 Molten Cannon, 2 Molten Beam, 3 Glass Guard. Kiln
	# Heat also stokes from blows it takes. 4 Molten Glass, an eruption all round it.
	"vitrecrag": {"role": "Tank", "moves": ["plate_lunge"], "abilities": ["molten_cannon", "molten_beam", "glass_guard"], "speed": 0.65, "hp": 1.6,
		"passive": "kiln", "profile": "press"},
	# Oxbowarchon line (Electric/Stone, the Electric Gemstone King), drafted from the line's own
	# move directions in docs/creatures/personal-stone-line-proposal.md.
	# Preostmar: a compact stone creature with a jade cluster on its shoulders. Shoulder shards
	# (Jade Lance), spikes from the ground, and the cocoon.
	"preostmar": {"moves": ["jade_lance"], "abilities": ["ground_spikes", "stone_cocoon"], "speed": 0.9},
	# Oathfen: the slabs have formed and the rails lie folded. A slab brawler: spikes, the
	# cocoon, the vortex; Bound Slabs.
	"oathfen": {"moves": ["jade_lance"], "abilities": ["ground_spikes", "stone_cocoon", "slab_vortex"], "hp": 1.2, "speed": 0.8,
		"passive": "bound_slabs", "profile": "press"},
	# Oxbowarchon (Preston, 2026-10-08): "more of a backline character, playing on the railgun".
	# ARTILLERY: keeps its distance, everything it fires hits harder from far. Basic Jade Lance
	# (AI); 1 Rail Shot (pierces a long line); 2 Ground Spikes (the peel); 3 Rail Recoil (fires
	# both rails at the floor to vault away, untouchable for the hop). Bound Slabs. 4 Kingstone
	# Rail. Placeholder names: Rail Shot, Rail Recoil.
	"oxbowarchon": {"role": "Artillery", "moves": ["jade_lance"], "abilities": ["rail_shot", "ground_spikes", "rail_recoil"], "speed": 0.7, "hp": 1.3,
		"passive": "bound_slabs", "profile": "kite", "far_bonus": 1.3},
	# Punchybuns line (Electric; Claude, 2026-10-08; Grok's numbers): a ferret who protects the
	# people it loves. Punchybun: the round kit: jabs, dances, and already puts its star on a
	# friend. Sparkjab: the boxer: Counter Jab arrives; Guardian. Starward: Starshield.
	"punchybun": {"moves": ["jab"], "abilities": ["static_dance", "star_guard"], "speed": 1.1, "hp": 0.95, "profile": "escort"},
	"sparkjab": {"moves": ["jab"], "abilities": ["static_dance", "star_guard", "counter_jab"], "speed": 1.15, "hp": 1.05,
		"passive": "guardian", "profile": "escort"},
	"starward": {"role": "Protector", "moves": ["jab"], "abilities": ["static_dance", "star_guard", "counter_jab"], "speed": 1.1, "hp": 1.25,
		"passive": "guardian", "profile": "escort"},
}
## Moves. "range" is how close the target must be; "cooldown" is per move.
const MOVES := {
	"fireball": {"name": "Ember Shot", "damage": 10, "cooldown": 0.9, "range": 95.0},
	"beam": {"name": "Pressure Jet", "damage": 14, "cooldown": 1.4, "range": 80.0},
	"seed": {"name": "Seed Pod", "damage": 12, "cooldown": 1.2, "range": 70.0},
	# Stormwick (Ember/Electric, all from its storm lantern)
	"wick_bolt": {"name": "Wick Bolt", "damage": 12, "cooldown": 1.3, "range": 115.0},
	# Flashstep is retired (Preston, 2026-10-08: with the AI walking the creature in it
	# teleported in place, and it never fit a stage 1). The move stays defined for the old
	# checks; no kit uses it.
	"flashstep": {"name": "Flashstep", "damage": 3, "cooldown": 3.0, "range": 0.0, "mobility": true, "charges": 3},
	# Ember Feint (placeholder name): the skirmisher hops back out of reach, untouchable for the
	# hop, and leaves burning embers where it stood, so whoever chases it walks through fire.
	# Two charges. Works at the wall: it picks the best open direction, not only straight back.
	"ember_feint": {"name": "Ember Feint", "damage": 3, "cooldown": 5.0, "range": 0.0, "mobility": true, "charges": 2},
	# Burrow (Bloom roots) and Dive (Tide): the Sinkhole mechanic without the Hollow: sink out
	# of sight and come up behind the target.
	"burrow": {"name": "Burrow", "damage": 0, "cooldown": 6.0, "range": 0.0, "mobility": true},
	"dive": {"name": "Dive", "damage": 0, "cooldown": 6.0, "range": 0.0, "mobility": true},
	"lantern_flash": {"name": "Lantern Flash", "damage": 0, "cooldown": 6.0, "range": 55.0},
	"claw": {"name": "Rake", "damage": 14, "cooldown": 1.1, "range": 24.0},
	"pounce": {"name": "Pounce", "damage": 12, "cooldown": 1.4, "range": 58.0},
	"lantern_volley": {"name": "Lantern Volley", "damage": 7, "cooldown": 6.0, "range": 120.0, "mobility": true},
	# Placeholder name (Preston: "like Volt Tackle"): teleports between marked enemies, invulnerable.
	"lantern_tackle": {"name": "Lantern Tackle", "damage": 6, "cooldown": 7.0, "range": 999.0, "mobility": true},
	# Scourmaw (Hollow)
	"phase": {"name": "Phase", "damage": 0, "cooldown": 3.0, "range": 0.0, "mobility": true},
	"deep_jet": {"name": "Deep Jet", "damage": 18, "cooldown": 1.7, "range": 150.0},
	"sinkhole": {"name": "Sinkhole", "damage": 0, "cooldown": 5.0, "range": 0.0, "mobility": true},
	"riptide": {"name": "Riptide", "damage": 0, "cooldown": 6.0, "range": 120.0},
	# Rampartroot (Bloom/Stone tank)
	"root_snare": {"name": "Root Snare", "damage": 4, "cooldown": 6.0, "range": 100.0},
	"root_wall": {"name": "Root Wall", "damage": 0, "cooldown": 9.0, "range": 140.0},
	"club_slam": {"name": "Tail Club", "damage": 16, "cooldown": 4.0, "range": 30.0},
	# The old signature as an ability: roots race to the target and a ring of root pillars erupts there.
	"root_rampart": {"name": "Root Rampart", "damage": 18, "cooldown": 9.0, "range": 110.0},
	# Ironvent line (Ember/Stone): a burst of heat shot from the back vents.
	"vent_barrage": {"name": "Vent Barrage", "damage": 12, "cooldown": 1.2, "range": 85.0},
	"crest_ram": {"name": "Crest Ram", "damage": 14, "cooldown": 4.5, "range": 95.0, "mobility": true},
	"cinder_claw": {"name": "Cinder Claw", "damage": 15, "cooldown": 1.2, "range": 26.0},
	# Vitrecrag line (Ember kiln). Molten Cannon is a lobbed mass of molten glass that carries
	# its target; Molten Beam a steady pour; Plate Lunge a shell shove up close.
	"ember_pellet": {"name": "Ember Pellet", "damage": 10, "cooldown": 1.0, "range": 90.0},
	"glass_spur": {"name": "Glass Spur", "damage": 13, "cooldown": 1.2, "range": 26.0},
	"furnace_shard": {"name": "Furnace Shard", "damage": 12, "cooldown": 1.3, "range": 100.0},
	"plate_lunge": {"name": "Plate Lunge", "damage": 14, "cooldown": 2.0, "range": 28.0},
	"molten_cannon": {"name": "Molten Cannon", "damage": 16, "cooldown": 3.5, "range": 150.0},
	"molten_beam": {"name": "Molten Beam", "damage": 12, "cooldown": 1.8, "range": 120.0},
	# Placeholder name: the tank plants and runs its shell molten for a few seconds.
	"glass_guard": {"name": "Glass Guard", "damage": 0, "cooldown": 9.0, "range": 0.0},
	# Oxbowarchon line (Bloom/Stone): moves come off the bound jade slabs and the rails.
	"jade_lance": {"name": "Jade Lance", "damage": 13, "cooldown": 1.5, "range": 110.0},
	"ground_spikes": {"name": "Ground Spikes", "damage": 14, "cooldown": 6.0, "range": 120.0},
	"stone_cocoon": {"name": "Stone Cocoon", "damage": 12, "cooldown": 10.0, "range": 0.0},
	"slab_vortex": {"name": "Slab Vortex", "damage": 15, "cooldown": 7.0, "range": 40.0},
	# Oxbowarchon as a backline railgun (Preston, 2026-10-08). Placeholder names.
	"rail_shot": {"name": "Rail Shot", "damage": 22, "cooldown": 6.0, "range": 220.0},
	"rail_recoil": {"name": "Rail Recoil", "damage": 8, "cooldown": 8.0, "range": 0.0, "mobility": true},
	# Ironvent line: a gout of heat from the back vents, a short cone that throws back and smoulders.
	"vent_blast": {"name": "Vent Blast", "damage": 11, "cooldown": 5.0, "range": 44.0},
	# Punchybuns line (Electric, the protector).
	"jab": {"name": "Spark Jab", "damage": 10, "cooldown": 0.9, "range": 26.0},
	"static_dance": {"name": "Static Dance", "damage": 0, "cooldown": 7.0, "range": 0.0},
	"star_guard": {"name": "Star Guard", "damage": 0, "cooldown": 8.0, "range": 120.0},
	"counter_jab": {"name": "Counter Jab", "damage": 12, "cooldown": 6.0, "range": 140.0, "mobility": true},
}
## The arena's essence chart (Preston, 2026-10-07). A three-way main cycle: Tide beats Ember,
## Bloom beats Tide, Ember beats Bloom. Second essences soften it, each a step weaker:
## Hollow beats Bloom, Electric beats Tide, Stone beats Electric. Each advantage runs
## backwards as a resistance. A creature with two essences multiplies both, so a move
## can be strong against one half and resisted by the other.
## This is the current chart (Preston, 2026-10-07): it replaces scripts/essence_chart.gd
## (the older turn-based cycle) and Grok is updating his rules to it. Numbers are drafts.
const MAIN_STRONG := 1.5
const MAIN_WEAK := 0.75
const SECOND_STRONG := 1.25
const SECOND_WEAK := 0.9
const E := CreatureData.Essence
const ARENA_CHART := {
	[E.TIDE, E.EMBER]: MAIN_STRONG, [E.EMBER, E.TIDE]: MAIN_WEAK,
	[E.BLOOM, E.TIDE]: MAIN_STRONG, [E.TIDE, E.BLOOM]: MAIN_WEAK,
	[E.EMBER, E.BLOOM]: MAIN_STRONG, [E.BLOOM, E.EMBER]: MAIN_WEAK,
	[E.HOLLOW, E.BLOOM]: SECOND_STRONG, [E.BLOOM, E.HOLLOW]: SECOND_WEAK,
	[E.ELECTRIC, E.TIDE]: SECOND_STRONG, [E.TIDE, E.ELECTRIC]: SECOND_WEAK,
	[E.STONE, E.ELECTRIC]: SECOND_STRONG, [E.ELECTRIC, E.STONE]: SECOND_WEAK,
}
## Each damaging move's essence (Stormwick's moves follow its lightbulb: Wick Bolt is the
## current, its claws and embers are the heat).
const MOVE_ESSENCE := {
	"fireball": E.EMBER, "beam": E.TIDE, "seed": E.BLOOM,
	"wick_bolt": E.ELECTRIC, "claw": E.EMBER, "flashstep": E.EMBER, "smoulder": E.EMBER, "ember_feint": E.EMBER,
	"pounce": E.EMBER, "lantern_volley": E.EMBER, "lantern_tackle": E.EMBER,
	"deep_jet": E.TIDE, "root_snare": E.BLOOM, "club_slam": E.STONE,
	"Stormlantern": E.EMBER, "Root Rampart": E.BLOOM, "Undertow": E.HOLLOW, "root_rampart": E.BLOOM, "Verdant Roar": E.BLOOM,
	"vent_barrage": E.EMBER, "Furnace Roar": E.EMBER, "crest_ram": E.EMBER, "cinder_claw": E.EMBER,
	"ember_pellet": E.EMBER, "glass_spur": E.EMBER, "furnace_shard": E.EMBER, "plate_lunge": E.STONE,
	"molten_cannon": E.EMBER, "molten_beam": E.EMBER, "Molten Glass": E.EMBER,
	# The jade is Stone; the Kingstone itself is Electric (Preston, 2026-10-08, later: the
	# Electric/Stone king, because a railgun runs on electromagnetism, not life).
	"jade_lance": E.STONE, "ground_spikes": E.STONE, "stone_cocoon": E.STONE, "slab_vortex": E.STONE, "Kingstone Rail": E.ELECTRIC,
	"rail_shot": E.ELECTRIC, "rail_recoil": E.STONE, "vent_blast": E.EMBER,
	"jab": E.ELECTRIC, "counter_jab": E.ELECTRIC, "Starshield": E.ELECTRIC,
}

const FACINGS := ["e", "se", "s", "sw", "w", "nw", "n", "ne"]  # clockwise from east, 45 degrees apart
const SCALE := 3.0
const SPEED := 70.0                    # map pixels a second
const WALK_FPS := 12.0
const ARENAS := [
	{"map": "res://assets/backgrounds/arena/arena_grass.png", "floor": Rect2(30, 60, 340, 150), "stands": Rect2(0, 0, 384, 30)},
	{"map": "res://assets/backgrounds/arena/arena_stone.png", "floor": Rect2(60, 52, 290, 156), "stands": Rect2(72, 4, 240, 26)},
]
const MAX_HP := 180                    # was 100; Preston (2026-10-07): fights ended too fast to use abilities
const STAGE_HP := 0.25                 # each stage above the first: +25% HP
const STAGE_POWER := 0.2               # and +20% damage
const METER_DEALT := 18
const METER_TAKEN := 10
const ACT_GAP := 0.3                   # a creature waits this long between any two moves
## Hitstop: 4 frames at 60 for an ordinary hit, 9 for a heavy one, slam or signature.
const HITSTOP_LIGHT := 0.07
const HITSTOP_HEAVY := 0.15
## Shake caps in map pixels (x3 on screen): ordinary hits small, nothing above SHAKE_MAX.
const SHAKE_HIT := 2.0
const SHAKE_MAX := 6.0
## Telegraphs: the shape drawn while a move winds up, and how long the wind-up is. Moves not
## listed are instant and silent (dodges, dashes, walls, the flash).
const TELEGRAPH := {
	"claw": ["melee", 0.25], "pounce": ["melee", 0.22], "cinder_claw": ["melee", 0.25], "club_slam": ["melee", 0.35],
	"fireball": ["line", 0.3], "beam": ["line", 0.3], "deep_jet": ["line", 0.35], "wick_bolt": ["line", 0.3], "vent_barrage": ["line", 0.3],
	"seed": ["area", 0.35], "root_snare": ["area", 0.4], "riptide": ["area", 0.4], "root_rampart": ["area", 0.45],
	"crest_ram": ["charge", 0.45],
	"ember_pellet": ["line", 0.3], "furnace_shard": ["line", 0.3], "glass_spur": ["melee", 0.25], "plate_lunge": ["melee", 0.35],
	"molten_cannon": ["area", 0.5], "molten_beam": ["line", 0.35],
	"jade_lance": ["line", 0.3], "ground_spikes": ["area", 0.45], "slab_vortex": ["melee", 0.35],
	"rail_shot": ["rail", 0.7], "vent_blast": ["melee", 0.3],
	"jab": ["melee", 0.2],
}
const AI_SLOWER := 1.3                 # the rival's cooldowns are this much longer

## Hollow essence shows as absence (Preston, 2026-10-07): Scourmaw glides over a scoured
## hollow, holes drift through its body, silt and echoes trail it, and Phase lets an attack
## pass through. It surfaces fully at the start, every few seconds and when it attacks.
const PHASE_SECONDS := 0.6
const PHASE_BREAK_COOLDOWN := 6.0      # breaking out of roots costs Phase this long a wait
const SURFACE_START := 2.0
const SURFACE_EVERY := 5.0
const SURFACE_FOR := 1.2
const SURFACE_ON_ATTACK := 0.8

## Stormwick's storm lantern (Preston, 2026-10-07: its Ember/Electric essence comes from
## the lantern, which is a lightbulb: current heats a filament and the filament glows; it
## is speedy). Every part of its kit shows all three: spark, heat and light. Wick Bolt is a
## white-hot filament bolt that leaves the target smouldering; Flashstep is a dash of pure
## light that leaves hot embers; its claws glow red-hot; the lantern's glow runs from warm
## orange to white-hot as it charges, while the arcs to its crest stay electric blue-white. Where the lantern sits on each facing, from its feet, read
## from the arena sprites. It casts a pool of light, drips embers, arcs to its crest, and
## charges as Stormwick runs (passive "lantern_charge"): full charge overcharges its next
## damaging move.
const LANTERN := {"e": Vector2(-12, -23), "se": Vector2(-9, -23), "s": Vector2(0, -22), "sw": Vector2(9, -23),
	"w": Vector2(11, -22), "nw": Vector2(8, -22), "n": Vector2(-1, -20), "ne": Vector2(-10, -22)}
const CHARGE_PER_SECOND := 22.0        # while moving
const OVERCHARGE := 1.6                # damage multiplier at full charge
const STUN_SECONDS := 2.2              # Stormlantern's paralysis
const DAZZLE_SECONDS := 1.6            # Lantern Flash
const SMOULDER_SECONDS := 1.6          # Wick Bolt's heat: a small burn over time
const SMOULDER_TICK := 0.4
const SMOULDER_DAMAGE := 2
const FLASHSTEP_DISTANCE := 62.0
## Rampartroot's roots: Root Snare holds the target in place and cripples its movement
## abilities (no Phase, no Flare Step, slower); Root Wall raises a curve of roots behind the
## target that blocks movement and stops shots. Passive Rampart: never knocked back, and
## takes less damage while above half HP (defense piercers ignore that).
## Rocks and slams (drafts for Grok).
## Sized from the reference video (2026-10-07, frames at 42 s and 89 s): its boulder is about
## 2.3 creature-widths wide and 1.7 creature-heights tall, so here a boulder is 56 x 48 map
## pixels and a stone is about creature-sized. One boulder and two stones per arena, placed
## from the floor's centre. The boulder is drawn as flat facets lit from the upper left, with
## moss on top and a heavy outline, like the reference's.
const ROCK_LAYOUT := [{"at": Vector2(0, -44), "kind": "boulder"}, {"at": Vector2(-45, 45), "kind": "stone"}, {"at": Vector2(50, 35), "kind": "stone"},
	{"at": Vector2(-125, -22), "kind": "crate"}, {"at": Vector2(128, 18), "kind": "crate"}]
const ROCK_KINDS := {"boulder": {"rx": 28.0, "h": 48.0, "hp": 60}, "stone": {"rx": 13.0, "h": 22.0, "hp": 30}, "crate": {"rx": 9.0, "h": 16.0, "hp": 20}}
const CRATE_SHADES := [Color("#c9a06a"), Color("#a67c48"), Color("#7a5631"), Color("#54391f")]
const ROCK_SHADES := [Color("#ddd6c2"), Color("#aaa69a"), Color("#7c786e"), Color("#514d47")]
const ROCK_OUTLINE := Color("#2b2824")
const MOSS := [Color("#6f9a4a"), Color("#9ccb63"), Color("#4b7334")]
## The rock's shape in unit space: x from -1 to 1 across, y from -1 (top) to 0 (the ground).
const ROCK_SHAPE := [Vector2(-0.95, -0.15), Vector2(-1.0, -0.45), Vector2(-0.85, -0.75), Vector2(-0.55, -0.95), Vector2(-0.15, -1.0),
	Vector2(0.3, -0.97), Vector2(0.7, -0.85), Vector2(0.95, -0.6), Vector2(1.0, -0.3), Vector2(0.9, -0.05), Vector2(0.6, 0.0),
	Vector2(0.0, 0.03), Vector2(-0.6, 0.0)]
## Its facets, each a polygon in unit space and a shade (0 lightest, lit from the upper left).
const ROCK_FACETS := [
	{"s": 0, "p": [Vector2(-0.85, -0.75), Vector2(-0.55, -0.95), Vector2(-0.15, -1.0), Vector2(-0.2, -0.7), Vector2(-0.55, -0.55)]},
	{"s": 1, "p": [Vector2(-0.15, -1.0), Vector2(0.3, -0.97), Vector2(0.7, -0.85), Vector2(0.45, -0.6), Vector2(-0.2, -0.7)]},
	{"s": 1, "p": [Vector2(-0.95, -0.15), Vector2(-1.0, -0.45), Vector2(-0.85, -0.75), Vector2(-0.55, -0.55), Vector2(-0.5, -0.2)]},
	{"s": 0, "p": [Vector2(-0.55, -0.55), Vector2(-0.2, -0.7), Vector2(0.1, -0.4), Vector2(0.0, -0.05), Vector2(-0.5, -0.2)]},
	{"s": 2, "p": [Vector2(-0.2, -0.7), Vector2(0.45, -0.6), Vector2(0.6, -0.25), Vector2(0.4, 0.0), Vector2(0.0, -0.05), Vector2(0.1, -0.4)]},
	{"s": 3, "p": [Vector2(0.45, -0.6), Vector2(0.7, -0.85), Vector2(0.95, -0.6), Vector2(1.0, -0.3), Vector2(0.9, -0.05), Vector2(0.6, -0.25)]},
	{"s": 2, "p": [Vector2(-0.95, -0.15), Vector2(-0.5, -0.2), Vector2(0.0, -0.05), Vector2(-0.6, 0.0)]},
]
const ROCK_MOSS := [[Vector2(-0.45, -0.88), 0.2], [Vector2(0.1, -0.95), 0.13], [Vector2(-0.78, -0.62), 0.1], [Vector2(0.5, -0.9), 0.08]]
const ROCK_CRACKS := [
	[Vector2(-0.1, -1.0), Vector2(0.05, -0.75), Vector2(-0.1, -0.55), Vector2(0.1, -0.3), Vector2(0.0, -0.05)],
	[Vector2(-0.85, -0.75), Vector2(-0.5, -0.6), Vector2(-0.3, -0.35)],
	[Vector2(0.7, -0.85), Vector2(0.45, -0.55), Vector2(0.6, -0.2)],
]
const CARRY_SECONDS := 0.25
const CARRY_PER_PUSH := 18.0           # map pixels a hit carries its target per unit of push
const CARRY_FROM := 1.5                # pushes at least this strong carry; weaker ones nudge
const SLAM_DAMAGE := 8
const SLAM_DAZE := 0.8
## Ironvent (drafts for Grok): Crest Ram is a straight charge; Stoke is its passive: every hit
## it lands heats its vents, and at full heat the next damaging move is bigger and vents it.
const RAM_SPEED := 230.0
const POUNCE_SPEED := 300.0            # Stormwick's basic: in, strike, straight back out
const INVULN_FLASHSTEP := 0.35         # invulnerability frames on Flashstep
const MARK_SECONDS := 8.0              # a lantern mark lasts this long
const BALL_BOUNCES := 3                # a volley ball bounces off the edge this many times
const TACKLE_SECONDS := 1.0            # the tackle always lasts this long, one target or many
const TACKLE_HOP := 0.125              # time between strikes
const VOLLEY_HOP := 38.0               # Lantern Volley hops back this far before firing
const RAM_SECONDS := 0.4
const RAM_PUSH := 2.2                  # carries the target (see _carry): into a wall or rock, a slam
## Kiln Heat (Vitrecrag, draft): standing still heats the crater; hot, its next shot is bigger.
const KILN_PER_SECOND := 45.0
const KILN_BONUS := 1.4
const CANNON_PUSH := 1.8               # Molten Cannon carries its target
const STOKE_PER_HIT := 25.0
const STOKE_BONUS := 1.5
const ROAR_PUSH := 4.0                 # Furnace Roar: how hard the wave blows back the rest of the cone
const ROOT_SECONDS := 1.2
const RAMPART_RUN := 0.5               # Root Rampart: roots take this long to reach the target
const RAMPART_PILLARS := 4.0           # and its ring of pillars stands this long
const ROAR_ROOT := 1.2                 # Verdant Roar roots every enemy this long
const VINES_SECONDS := 5.0             # and leaves a vine field that slows
const VINES_RADIUS := 40.0
const VINES_SLOW := 0.55
## Signature terrain (Preston, 2026-10-07 night: "environment effects, team play, only affects
## enemies"). Hazards burn and slow enemies of whoever made them and leave allies alone.
const HAZARD_TICK := 0.5
const HAZARD_BURN := 2
const POOL_SECONDS := 6.0
const POOL_RADIUS := 18.0
const POOL_SLOW := 0.6
const SEAM_SECONDS := 7.0
const SEAM_WIDTH := 9.0
const SEAM_SLOW := 0.75
const GEYSER_STUN := 1.0               # Furnace Roar's vent crowd control
## Molten glass as a status (Preston, 2026-10-08: "some sort of molten glass status effect on
## enemies"). Glassed: molten glass clings to the creature, burning it and slowing it wherever
## it goes, and when it wears off the glass SETS hard for a moment, holding it still.
const GLASSED_SECONDS := 4.0
const GLASSED_SLOW := 0.65
const GLASSED_TICK := 0.5
const GLASSED_BURN := 2
const GLASSED_SET := 0.5
const POOL_GLASS := 1.5                # standing in a glass pool keeps you Glassed this long after
## Glass Guard (Vitrecrag's third ability): planted, damage halved, melee attackers Glassed.
const GUARD_SECONDS := 2.5
const GUARD_REDUCTION := 0.5
const KILN_PER_HIT := 12.0             # the tank's kiln is stoked by every blow it takes
## Molten Glass's field: pools laid round Vitrecrag itself, [offset, radius] each.
const GLASS_FIELD := [[Vector2(0, 2), 30.0], [Vector2(-40, -8), 18.0], [Vector2(40, -6), 18.0], [Vector2(-24, 20), 17.0],
	[Vector2(26, 22), 17.0], [Vector2(2, -26), 16.0], [Vector2(-50, 12), 14.0], [Vector2(50, 14), 14.0]]
## The Oxbowarchon line (2026-10-08). Drafts for Grok.
const SPIKE_ROOT := 0.8                # Ground Spikes hold the target a moment
const COCOON_SECONDS := 1.2            # Stone Cocoon: the slabs pull tight, then burst outward
const COCOON_GUARD := 0.4
const COCOON_RADIUS := 44.0
const VORTEX_RADIUS := 36.0
const SLAB_COUNT := 2                  # Bound Slabs: blows swallowed before the slabs must re-form
const SLAB_REFORM := 7.0
const SLAB_MIN_HIT := 6                # chip damage passes the slabs
const RAIL_RADIUS := 48.0              # Kingstone Rail: everyone else this close to the impact
const RAIL_SPLASH := 0.5               # takes this much of the damage and is floored
const SHARDS_SECONDS := 7.0            # and the crater stays ringed with Kingstone shards that
const SHARDS_RADIUS := 40.0            # slow enemies and shut off their movement abilities
const SHARDS_SLOW := 0.6
const FEINT_HOP := 55.0                # Ember Feint: the hop back out of reach
const FEINT_INVULN := 0.25
const RECOIL_HOP := 70.0               # Rail Recoil: the hop away from the nearest enemy
const RECOIL_INVULN := 0.3             # untouchable for the hop
const RAIL_WIDTH := 13.0               # Rail Shot: how close to the line a creature must stand
## The Punchybuns line (2026-10-08). Drafts for Grok.
const GUARD_SHIELD := 25               # Star Guard: damage the star shield absorbs
const GUARD_SHIELD_SECONDS := 4.0
const DANCE_WINDOW := 6.0              # Static Dance: the charged jab must land inside this
const DANCE_HASTE := 3.0               # and allies close by move faster this long
const HASTE_SPEED := 1.3
const CHARGED_JAB := 1.5               # the charged jab's damage, and it stuns
const CHARGED_STUN := 0.4
const GUARDIAN_RADIUS := 40.0          # Guardian: allies this close take less
const GUARDIAN_CUT := 0.85
const STARSHIELD_SHIELD := 40          # Starshield: every ally's shield
const STARSHIELD_SECONDS := 6.0
const STARSHIELD_RADIUS := 70.0        # enemies inside are thrown out and held
const STARSHIELD_STUN := 0.6
const STAR_FIELD_SECONDS := 6.0        # the star field left behind: allies inside mend
const STAR_FIELD_RADIUS := 60.0
const STAR_FIELD_HEAL := 2
const CRIPPLE_SECONDS := 2.4
const WALL_SECONDS := 6.0
const RAMPART_GUARD := 0.75
const THORNS := 5                      # Rampart: a close attacker takes this back
## Scourmaw's Hollow decay ("consumes but cannot create"): its hits erode the target for a
## few seconds, stripping damage reduction (Rampart) and adding a little damage taken.
const ERODE_SECONDS := 3.0
const ERODE_EXTRA := 1.25
## Scourmaw's answers to speed and pressure (balance pass, 2026-10-07): Sinkhole sinks into
## its hollow and resurfaces far away; Riptide opens a current under the target that slows
## it, pulls it in and shuts off its movement abilities while it stays inside.
const SINK_SECONDS := 0.5
const SINK_DISTANCE := 110.0
const AMBUSH_SECONDS := 3.0            # after a Sinkhole, the next Deep Jet inside this window is sharpened
const AMBUSH_BONUS := 1.8              # enough to beat the distance bonus it gives up by closing in
const RIPTIDE_SECONDS := 2.5
const RIPTIDE_RADIUS := 20.0
const RIPTIDE_SLOW := 0.45

## Set by test tools to move without a keyboard.
var debug_input := Vector2.ZERO

var _world: Node2D
var _view: SubViewport                  # the low-resolution fight, shown at 3x
var _map: Sprite2D
var _fx: Node2D
var _sig: Node2D
var _hud: Node2D
var _font: Font
var _arena := 0
var _fighters: Array[Dictionary] = []   # your team first (you are fighter 0), then the rival's
var _you := 0                           # LINES index of your starter
var _rival := 1
var _you_stage := 0                     # 0, 1 or 2: which form of the line
var _rival_stage := 0
## Creatures a side: 1, 2 or 3 (N cycles). 3v3 is for watching tactics before Preston picks a main mode.
var team_size := 1
## Optional fixed teams for the simulator: [[[line, stage], ...], [[line, stage], ...]].
var teams_override: Array = []
var _clock := 0.0                       # seconds fought this match (the simulator reads it)
## The enemy you have told your creature to go for (-1: its own choice). Left/right cycle, up clears.
var player_target := -1
## Which of your creatures you control (SPACE cycles); the rest of your team is AI.
var controlled := 0
var _hitstop := 0.0
var shake_on := true
const TEAM_RING := [Color("#5ec8ff"), Color("#ff5a4a")]
const YOU_RING := Color("#ffe066")
var _effects: Array[Dictionary] = []
var _labels: Array[Dictionary] = []     # move names floating over the creature that used them
var _walls: Array[Dictionary] = []      # root structures: each piece blocks a small circle
## Rocks on the floor (B toggles them; on by default).
var rocks_on := true
var _rocks: Array[Dictionary] = []      # {pos, rx, h, big, hp, max_hp, flash, node}
var _rubble: Node2D                     # a floor layer under the creatures: rubble and wall cracks
var _rubble_bits: Array[Dictionary] = []   # fallen shards: {pos, pts, c} and craters: {pos, rx}
var _wall_marks: Array[PackedVector2Array] = []
## Hand-drawn impact animations (RD effects style, 16 frames each, tools/arena/slice_vfx.py),
## layered under the coded flash, ring and smoke.
## Painted effect sheets (Retro Diffusion rd_animation__vfx, 16 frames each, tools/arena/rd_vfx.py
## and slice_vfx.py). The first four are impacts; the VFX pass of 2026-10-07 added a looping
## lantern ball for the lantern projectiles, a light slash for pounce and tackle strikes, a
## lantern flash for teleports, a molten glass splash, stone dust, a vent flame, a root
## eruption, and a looping lantern glyph for marks.
const IMPACTS := ["fire_burst", "water_burst", "earth_burst", "shock_burst",
	"lantern_ball", "light_slash", "lantern_flash", "glass_splash", "rock_dust", "vent_flame", "root_burst", "mark_glyph"]
const IMPACT_SECONDS := 0.55
var _impact_frames := {}
var _shake := 0.0
var _cheer := 0.0
var _crowd_dots: Array[Dictionary] = []
var _crowd_t := 0.0
var _winner := -1
var _sounds: Array[AudioStreamPlayer] = []
var _sig_user := -1


func _ready() -> void:
	_font = load("res://assets/fonts/Silkscreen-Bold.ttf")
	_view = SubViewport.new()
	_view.size = Vector2i(384, 216)
	_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	add_child(_view)
	var screen := Sprite2D.new()
	screen.texture = _view.get_texture()
	screen.centered = false
	screen.scale = Vector2.ONE * SCALE
	screen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(screen)
	_world = Node2D.new()
	_view.add_child(_world)
	_map = Sprite2D.new()
	_map.centered = false
	_map.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_world.add_child(_map)
	_rubble = Node2D.new()
	_rubble.z_index = 1
	_rubble.draw.connect(_draw_rubble)
	_world.add_child(_rubble)
	_fx = Node2D.new()
	_fx.z_index = 1000
	_fx.draw.connect(_draw_effects)
	_world.add_child(_fx)
	_sig = ArenaSignature.new()
	_sig.z_index = 1001
	_sig.setup(_play, func(a: float) -> void: _shake_by(a))
	_sig.landed.connect(_on_signature_landed)
	_sig.paralyze.connect(_on_signature_paralyze)
	_sig.user_hidden.connect(func(h: bool) -> void:
		if _sig_user >= 0:
			_fighters[_sig_user]["hidden"] = h)
	_sig.user_moved.connect(func(to: Vector2) -> void:
		if _sig_user >= 0:
			_fighters[_sig_user]["body"].position = to)
	_sig.pressure_wave.connect(_on_pressure_wave)
	_sig.glass_rain.connect(_on_glass_rain)
	_sig.root_all.connect(_on_root_all)
	_sig.vine_field.connect(_on_vine_field)
	_sig.glass_pools.connect(_on_glass_pools)
	_sig.rail_impact.connect(_on_rail_impact)
	_sig.star_shield.connect(_on_star_shield)
	_sig.star_field.connect(_on_star_field)
	_sig.geysers.connect(_on_geysers)
	_sig.lava_seams.connect(_on_lava_seams)
	_sig.finished.connect(func() -> void: _sig_user = -1)
	_world.add_child(_sig)
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud = Node2D.new()
	_hud.draw.connect(_draw_hud)
	layer.add_child(_hud)
	for i in 8:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_sounds.append(p)
	for name in IMPACTS:
		var frames: Array[Texture2D] = []
		for k in 16:
			frames.append(load("res://assets/sprites/arena/vfx/%s/f%02d.png" % [name, k]))
		_impact_frames[name] = frames
	_set_arena(0)
	_new_match()


# ---------------------------------------------------------------- setup

func _load_art(folder: String) -> Dictionary:
	var still := {}
	var walk := {}
	for f in FACINGS:
		still[f] = load("res://assets/sprites/arena/%s/small/%s.png" % [folder, f])
		var frames: Array[Texture2D] = []
		for i in 8:
			var p := "res://assets/sprites/arena/%s/small/walk_%s_f%d.png" % [folder, f, i]
			if ResourceLoader.exists(p):
				frames.append(load(p))
		walk[f] = frames
	return {"still": still, "walk": walk}


func _make_fighter(line: int, stage: int, at: Vector2, facing: String, ai: bool, team := 0, is_you := false) -> Dictionary:
	var form: Array = LINES[line]["forms"][stage]
	var data: CreatureData = load(form[1])
	var kit: Dictionary = KITS[form[0]]
	var body := Node2D.new()
	body.position = at
	_world.add_child(body)
	var shadow := Polygon2D.new()
	shadow.polygon = _ellipse(Vector2.ZERO, 9 + 3 * stage, 3 + stage)
	shadow.color = Color(0, 0, 0, 0.3)
	body.add_child(shadow)
	var ring: Line2D = null
	if team_size > 1:
		# A ring at its feet tells the teams apart (yellow for the one you control).
		ring = Line2D.new()
		ring.points = _ellipse(Vector2.ZERO, 10 + 3 * stage, 4 + stage)
		ring.closed = true
		ring.width = 1.0
		ring.default_color = YOU_RING if is_you else TEAM_RING[team]
		body.add_child(ring)
	var sprite := Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body.add_child(sprite)
	var art := _load_art(form[0])
	var passive: String = kit.get("passive", "")
	if passive == "absence":
		var mat := ShaderMaterial.new()
		mat.shader = HOLLOW_SHADER
		sprite.material = mat
		shadow.visible = false   # it never touches the ground; the scour hollow is drawn instead
	sprite.texture = art["still"][facing]
	var used: Rect2i = sprite.texture.get_image().get_used_rect()
	sprite.offset = Vector2(0, sprite.texture.get_height() * 0.5 - (used.position.y + used.size.y))
	var max_hp := int(round(MAX_HP * (1.0 + STAGE_HP * stage) * kit.get("hp", 1.0)))
	var cds := {}
	var charge_cds := {}
	var abilities: Array = kit.get("abilities", [])
	for m in kit["moves"] + abilities:
		cds[m] = 0.5
		if MOVES[m].has("charges"):
			charge_cds[m] = []
			for c in MOVES[m]["charges"]:
				charge_cds[m].append(0.0)
			cds[m] = 0.0
	var essences: Array = [data.essence]
	if data.has_second_essence:
		essences.append(data.second_essence)
	var closeup: Texture2D = load(LINES[line]["card"]) if LINES[line].has("card") and stage == 2 else data.sprite
	var fighter := {"line": line, "stage": stage, "form": form[0], "name": data.creature_name, "closeup": closeup, "essences": essences,
		"body": body, "sprite": sprite, "art": art, "facing": facing, "kit": kit["moves"] + abilities, "abilities": abilities,
		"charge_cds": charge_cds, "speed": kit.get("speed", 1.0),
		"passive": passive, "hollow": passive == "absence", "lantern": passive in ["lantern_charge", "lantern_mark"],
		"hp": max_hp, "max_hp": max_hp, "power": 1.0 + STAGE_POWER * stage, "meter": 0, "cds": cds, "act": 1.0,
		"flash": 0.0, "stun": 0.0, "dazzle": 0.0, "phase": 0.0, "echo": 0.0, "solid": SURFACE_START,
		"surface_in": SURFACE_EVERY, "absence": 0.0, "charge": 0.0, "ember": 0.0, "arc": 0.5, "arc_pts": PackedVector2Array(),
		"role": kit.get("role", ""), "profile": kit.get("profile", ""), "far_bonus": kit.get("far_bonus", 1.0),
		"rooted": 0.0, "crippled": 0.0, "disengage": 0.0, "hidden": false, "smoulder": 0.0, "smoulder_tick": 0.0,
		"sink": 0.0, "sink_to": Vector2.ZERO, "eroded": 0.0,
		"walk": 0.0, "dust": 0.0, "ai": ai, "strafe": 1.0, "think": 0.0, "down": 0.0,
		"team": team, "target": -1, "retarget": 0.0, "dealt": 0, "down_at": -1.0,
		"carry": Vector2.ZERO, "carry_t": 0.0, "carried_by": -1,
		"heat": 0.0, "ram_t": 0.0, "ram_dir": Vector2.ZERO, "ram_dmg": 0,
		"windup": {}, "shiver": Vector2.ZERO,
		"ram_return": false, "ram_end_hit": false, "after": "", "after_aim": Vector2.ZERO,
		"invuln": 0.0, "marked": 0.0, "tackle": {}, "ring": ring, "ambush": 0.0,
		"guard": 0.0, "glassed": 0.0, "glassed_tick": 0.0,
		"cocoon": 0.0, "cocoon_dmg": 0, "slabs": SLAB_COUNT if passive == "bound_slabs" else 0, "slab_t": 0.0,
		"final": stage == 2,   # only a line's final stage has the signature (Preston, 2026-10-08)
		"shield": 0, "shield_t": 0.0, "charged": 0.0, "haste": 0.0}
	return fighter


func _new_match() -> void:
	for f in _fighters:
		f["body"].queue_free()
	_fighters.clear()
	_effects.clear()
	_labels.clear()
	_walls.clear()
	_winner = -1
	_clock = 0.0
	_hitstop = 0.0
	player_target = -1
	controlled = 0
	_sig.active = false   # a signature mid-flight dies with the old match
	_sig_user = -1
	var floor_rect: Rect2 = ARENAS[_arena]["floor"]
	var mid := floor_rect.get_center()
	for r in _rocks:
		r["node"].queue_free()
	_rocks.clear()
	_rubble_bits.clear()
	_wall_marks.clear()
	_rubble.queue_redraw()
	if rocks_on:
		for spot in ROCK_LAYOUT:
			var kind: Dictionary = ROCK_KINDS[spot["kind"]]
			var node := Node2D.new()
			node.position = (mid + spot["at"]).round()
			node.z_index = int(node.position.y)
			_world.add_child(node)
			var rock := {"pos": node.position, "rx": kind["rx"], "h": kind["h"], "big": spot["kind"] == "boulder", "kind": spot["kind"],
				"hp": kind["hp"], "max_hp": kind["hp"], "flash": 0.0, "node": node, "marked": 0.0}
			node.draw.connect(_draw_rock.bind(rock))
			_rocks.append(rock)
	for side in 2:
		var members: Array = []
		if teams_override.size() == 2:
			members = teams_override[side]
		else:
			# Your starter leads your team, the rival's leads theirs; the other lines fill in.
			var lead: int = _you if side == 0 else _rival
			for k in team_size:
				members.append([(lead + k) % LINES.size(), _you_stage if side == 0 else _rival_stage])
		var n := members.size()
		var offsets: Array = [[0.0], [-24.0, 24.0], [0.0, -46.0, 46.0]][clampi(n, 1, 3) - 1]
		for k in n:
			var y: float = (10.0 if side == 0 else -10.0) + (offsets[k] if k < offsets.size() else 0.0)
			var at := mid + Vector2(-90.0 if side == 0 else 90.0, y)
			_fighters.append(_make_fighter(members[k][0], members[k][1], at, "e" if side == 0 else "w", side == 1, side, side == 0 and k == 0))
	_cheer = 1.0
	if is_inside_tree():
		_play("res://assets/audio/sfx/arena/match_start.wav", -6.0)   # the horn and the crowd (ElevenLabs take)


func _set_arena(i: int) -> void:
	_arena = i
	_map.texture = load(ARENAS[i]["map"])
	_crowd_dots.clear()
	var stands: Rect2 = ARENAS[i]["stands"]
	var img: Image = _map.texture.get_image()
	for k in 220:
		var p := Vector2i(randi_range(int(stands.position.x), int(stands.end.x) - 2), randi_range(int(stands.position.y), int(stands.end.y) - 2))
		_crowd_dots.append({"p": p, "c": img.get_pixelv(p), "alt": img.get_pixelv(p + Vector2i(1, 1))})


# ---------------------------------------------------------------- input and update

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var k: int = event.physical_keycode
	if k >= KEY_1 and k <= KEY_3:
		cast(k - KEY_1)
	elif k == KEY_4:
		signature(controlled)
	elif k == KEY_SPACE:
		_switch_control()
	elif k == KEY_T:
		_rival = (_rival + 1) % LINES.size()
		if _rival == _you:
			_rival = (_rival + 1) % LINES.size()
		_new_match()
	elif k == KEY_F:
		_you_stage = (_you_stage + 1) % 3
		_new_match()
	elif k == KEY_G:
		_rival_stage = (_rival_stage + 1) % 3
		_new_match()
	elif k == KEY_B:
		rocks_on = not rocks_on
		_new_match()
	elif k == KEY_N:
		team_size = team_size % 3 + 1
		_new_match()
	elif k == KEY_M:
		_set_arena((_arena + 1) % ARENAS.size())
		_new_match()
	elif k == KEY_R:
		_new_match()
	elif k == KEY_K:
		signature(controlled)
	elif k == KEY_V:
		shake_on = not shake_on
	elif k == KEY_RIGHT or k == KEY_LEFT or k == KEY_D or k == KEY_A:
		_cycle_target(1 if k == KEY_RIGHT or k == KEY_D else -1)
	elif k == KEY_UP or k == KEY_W:
		player_target = -1
		_label(0, "Auto target")


## SPACE: control passes to the next living creature on your team.
func _switch_control() -> void:
	var mine: Array = []
	for j in _fighters.size():
		if _fighters[j]["team"] == 0 and _fighters[j]["hp"] > 0:
			mine.append(j)
	if mine.size() < 2:
		return
	var at: int = mine.find(controlled)
	controlled = mine[(at + 1) % mine.size()]
	player_target = -1
	_label(controlled, "You")
	_play("res://assets/audio/sfx/ui/confirm.wav", -10.0)


## Your order to your creature: the next (or previous) living enemy, by position left to
## right. During a Lantern Tackle it picks the landing spot instead.
func _cycle_target(step: int) -> void:
	var me: Dictionary = _fighters[controlled]
	if not me["tackle"].is_empty():
		_cycle_landing(step)
		return
	var enemies: Array = []
	for j in _fighters.size():
		if _enemies(controlled, j) and _fighters[j]["hp"] > 0:
			enemies.append(j)
	if enemies.is_empty():
		return
	enemies.sort_custom(func(a, b): return _fighters[a]["body"].position.x < _fighters[b]["body"].position.x)
	var at: int = enemies.find(player_target if player_target >= 0 else me["target"])
	player_target = enemies[(at + step + enemies.size()) % enemies.size()] if at >= 0 else enemies[0]
	me["target"] = player_target
	me["retarget"] = 0.5
	_label(controlled, "Target: " + String(_fighters[player_target]["name"]))
	_play("res://assets/audio/sfx/ui/cursor.wav", -8.0)


## The places a tackling creature may land: every marked enemy and marked object, plus its
## own target. Each is ["f", index] or ["r", index].
func _landing_spots(i: int) -> Array:
	var spots: Array = []
	for j in _fighters.size():
		if _enemies(i, j) and _fighters[j]["hp"] > 0 and (_fighters[j]["marked"] > 0.0 or j == _fighters[i]["target"]):
			spots.append(["f", j])
	for k in _rocks.size():
		if _rocks[k]["marked"] > 0.0:
			spots.append(["r", k])
	return spots


func _cycle_landing(step: int) -> void:
	var me: Dictionary = _fighters[controlled]
	var spots := _landing_spots(controlled)
	if spots.is_empty():
		return
	var at := spots.find(me["tackle"]["land"])
	me["tackle"]["land"] = spots[(at + step + spots.size()) % spots.size()] if at >= 0 else spots[0]
	_play("res://assets/audio/sfx/ui/cursor.wav", -8.0)


func _process(delta: float) -> void:
	var frozen: bool = _sig.active and _sig.effect_time() < 0.0
	# Hitstop: the creatures hold still for a few frames while the effects keep moving.
	var stopped: bool = _hitstop > 0.0
	_hitstop = maxf(0.0, _hitstop - delta)
	if _winner < 0 and not frozen and not stopped:
		_clock += delta
		if not _sig.active:
			_move_rival(delta)
		for i in _fighters.size():
			_update_windup(i, delta)
			_use_moves(i, delta)
	for i in _fighters.size():
		if stopped:
			_shiver(i)
		else:
			_update_fighter(i, delta)
	if not frozen:
		_update_effects(delta)
	_shake = maxf(0.0, _shake - delta * 18.0)
	_cheer = maxf(0.0, _cheer - delta)
	_crowd_t += delta
	var s3 := (_shake if shake_on else 0.0) / SCALE
	_world.position = Vector2(randf_range(-s3, s3), randf_range(-s3, s3)).round()
	_fx.queue_redraw()
	_rubble.queue_redraw()
	_hud.queue_redraw()


## Scripted steering for the recorded test movies only (they set debug_input); in play your
## creature's AI moves it.
func _move_player(delta: float) -> void:
	_walk(0, debug_input, delta)


## Walks fighter i one step in a direction (or stands still for a zero direction).
## Paralysed creatures cannot move; dazzled ones move at half speed.
func _walk(i: int, dir: Vector2, delta: float) -> void:
	var f: Dictionary = _fighters[i]
	var floor_rect: Rect2 = ARENAS[_arena]["floor"]
	if dir.length() > 0.01 and f["stun"] <= 0.0 and f["rooted"] <= 0.0 and f["guard"] <= 0.0 and f["cocoon"] <= 0.0 and not f["hidden"] and f["hp"] > 0 and f["ram_t"] <= 0.0:
		dir = dir.normalized()
		var speed: float = SPEED * f["speed"] * (0.5 if f["dazzle"] > 0.0 else 1.0) * (0.7 if f["crippled"] > 0.0 else 1.0)
		if f["glassed"] > 0.0:
			speed *= GLASSED_SLOW
		if f["haste"] > 0.0:
			speed *= HASTE_SPEED
		if _in_riptide(i):
			speed *= RIPTIDE_SLOW
		if _in_vines(i):
			speed *= VINES_SLOW
		speed *= _hazard_slow(i)
		var step: Vector2 = dir * speed * delta
		var here: Vector2 = f["body"].position
		# Root walls block the way: slide along them where possible.
		for tryit in [step, Vector2(step.x, 0), Vector2(0, step.y)]:
			var next: Vector2 = (here + tryit).clamp(floor_rect.position, floor_rect.end)
			if not _blocked(next):
				f["body"].position = next
				break
		f["facing"] = _facing_of(dir)
		f["walk"] += delta
		f["dust"] -= delta
		if f["dust"] <= 0.0:
			f["dust"] = 0.16
			_effects.append({"kind": "dust", "pos": f["body"].position - dir * 4.0, "t": 0.0})
		if f["passive"] == "lantern_charge":
			f["charge"] = minf(100.0, f["charge"] + CHARGE_PER_SECOND * delta)
	else:
		f["walk"] = 0.0


## When true, your creature is moved by the same AI as the rival (the balance simulator).
var auto_you := false


## Every creature's footwork, yours included (a test movie steering fighter 0 is the exception).
func _move_rival(delta: float) -> void:
	for i in _fighters.size():
		if i == 0 and debug_input != Vector2.ZERO:
			_move_player(delta)
		else:
			_move_ai(i, delta)


## AI footwork for fighter i: keeps its role's distance, circles, switches direction now and then.
func _move_ai(i: int, delta: float) -> void:
	var me: Dictionary = _fighters[i]
	if me["hp"] <= 0 or me["ram_t"] > 0.0 or not me["tackle"].is_empty():
		return
	var t := _foe_of(i)
	if t < 0:
		return
	var you: Dictionary = _fighters[t]
	var to_you: Vector2 = you["body"].position - me["body"].position
	var dist := to_you.length()
	var want := 70.0
	for m in me["kit"]:
		if MOVES[m]["range"] > 0.0 and MOVES[m]["damage"] > 0:
			want = MOVES[m]["range"] * 0.8
	me["think"] -= delta
	if me["think"] <= 0.0:
		me["think"] = randf_range(0.8, 1.6)
		if randf() < 0.6:
			me["strafe"] = -me["strafe"]
	var dir := Vector2.ZERO
	match me["profile"]:
		"skirmish":
			# Never still: circles at mid range, darts in when its claw is ready, then is
			# back out (Flare Step) before it takes much in return.
			if randf() < 0.015:
				me["strafe"] = -me["strafe"]
			want = 30.0 if me["cds"].get("pounce", me["cds"].get("claw", 1.0)) <= 0.0 and me["disengage"] <= 0.0 else 55.0
			if dist > want + 8.0:
				dir = to_you.normalized()
			elif dist < want - 8.0:
				dir = -to_you.normalized()
			dir += to_you.normalized().orthogonal() * 1.1 * me["strafe"]
		"kite":
			# Keeps as far away as it can and backs off whenever anyone comes close.
			want = 135.0
			var to_near: Vector2 = _fighters[_nearest_foe(i)]["body"].position - me["body"].position
			if to_near.length() < 70.0 or dist < want - 10.0:
				# Back away from the closest enemy, toward open floor rather than into a corner.
				var floor_rect: Rect2 = ARENAS[_arena]["floor"]
				var to_middle: Vector2 = (floor_rect.get_center() - me["body"].position) / (floor_rect.size * 0.5)
				var from: Vector2 = to_near if to_near.length() < dist else to_you
				dir = (-from.normalized() + to_middle * 0.9).normalized() * (1.3 if from.length() < 70.0 else 1.0)
			elif dist > want + 20.0:
				dir = to_you.normalized() * 0.5
			dir += to_you.normalized().orthogonal() * 0.35 * me["strafe"]
		"press":
			# Walks straight at you and stays in your face.
			if dist > 20.0:
				dir = to_you.normalized()
		"escort":
			# A protector: stands beside the most hurt ally, between it and the nearest enemy,
			# and only presses the enemy itself when nobody needs guarding.
			var ward := _most_hurt_ally(i)
			if ward >= 0 and ward != i:
				var wp: Vector2 = _fighters[ward]["body"].position
				var nf := _nearest_foe(ward)
				var post: Vector2 = wp + ((_fighters[nf]["body"].position - wp).normalized() * 18.0 if nf >= 0 else Vector2.ZERO)
				var to_post: Vector2 = post - me["body"].position
				if to_post.length() > 12.0:
					dir = to_post.normalized()
				elif dist > 24.0 and dist < 40.0:
					dir = to_you.normalized() * 0.5
			elif dist > 20.0:
				dir = to_you.normalized()
		"kite_near":
			# Artillery: holds about 100 px, backs off from anything close, and otherwise
			# stands still so its kiln heats.
			want = 100.0
			if dist < 55.0:
				dir = -to_you.normalized()
			elif dist > want + 25.0:
				dir = to_you.normalized() * 0.7
		_:
			if dist > want + 10.0:
				dir = to_you.normalized()
			elif dist < want - 15.0:
				dir = -to_you.normalized()
			dir += to_you.normalized().orthogonal() * 0.6 * me["strafe"]
	# Teammates spread out instead of stacking on one spot.
	for j in _fighters.size():
		var a: Dictionary = _fighters[j]
		if j != i and a["team"] == me["team"] and a["hp"] > 0:
			var off: Vector2 = me["body"].position - a["body"].position
			if off.length() > 0.01 and off.length() < 22.0:
				dir += off.normalized() * (22.0 - off.length()) / 22.0 * 1.2
	_walk(i, dir, delta * 0.85)
	# The ultimate is the player's to fire on their own creature (the simulator excepted).
	# Molten Glass erupts round Vitrecrag itself, so its AI waits for an enemy close by.
	if me["final"] and me["meter"] >= 100 and dist < (60.0 if LINES[me["line"]]["signature"] == "Molten Glass" else 150.0) and (i != controlled or auto_you):
		signature(i)


# ---------------------------------------------------------------- the creature's AI: when to use each move

## Each creature, yours included, picks its own moves: the first one in its kit that is
## ready and whose moment has come. Paralysed or dazzled creatures cannot act.
func _use_moves(i: int, delta: float) -> void:
	var f: Dictionary = _fighters[i]
	for m in f["cds"]:
		f["cds"][m] = maxf(0.0, f["cds"][m] - delta)
	f["act"] = maxf(0.0, f["act"] - delta)
	f["disengage"] = maxf(0.0, f["disengage"] - delta)
	f["retarget"] = maxf(0.0, f["retarget"] - delta)
	for m in f["charge_cds"]:
		# Charges each recharge on their own timer; the move is ready while any charge is.
		var timers: Array = f["charge_cds"][m]
		for c in timers.size():
			timers[c] = maxf(0.0, timers[c] - delta)
		f["cds"][m] = timers.min()
	if f["hp"] <= 0 or f["stun"] > 0.0 or f["dazzle"] > 0.0 or f["act"] > 0.0 or f["hidden"] or _sig.active or not f["windup"].is_empty() or not f["tackle"].is_empty():
		return
	var t := _foe_of(i)
	if t < 0:
		return
	var foe: Dictionary = _fighters[t]
	# Abilities are weighed before the basic attack: they are the stronger, rarer tools, and a
	# basic that is nearly always ready would otherwise crowd them out (2026-10-08, after the
	# tank never guarded).
	var order: Array = f["abilities"].duplicate()
	for m in f["kit"]:
		if m not in order:
			order.append(m)
	for m in order:
		if i == controlled and not auto_you and m in f["abilities"]:
			continue   # yours to fire (1-3); your other creatures' AI fires theirs (and auto mode fires yours)
		# Roots and riptide shut off movement abilities, except Phase: roots cannot hold
		# what is not there (Preston, 2026-10-07), so Phase breaks free at the cost of its dodge.
		if MOVES[m].get("mobility", false) and m != "phase" and (f["crippled"] > 0.0 or _in_riptide(i) or _in_shards(i)):
			continue
		if f["cds"][m] <= 0.0 and _wants(i, m, foe):
			if TELEGRAPH.has(m):
				# Attacks telegraph first: the shape shows on the ground, then the move fires.
				f["windup"] = {"m": m, "kind": TELEGRAPH[m][0], "t": TELEGRAPH[m][1], "total": TELEGRAPH[m][1], "target": t}
				f["facing"] = _facing_of(foe["body"].position - f["body"].position)
				_play("res://assets/audio/sfx/arena/telegraph.wav", -10.0 if t == 0 or i == 0 else -16.0)   # louder when it concerns you
			else:
				_fire(i, m, t)
			return


## You fire ability slot 0, 1 or 2 (keys 1-3) at your creature's target. Dodges and dashes go
## at once; attacks telegraph first like everyone else's.
func cast(slot: int) -> void:
	if _fighters.is_empty() or _winner >= 0 or _sig.active:
		return
	var i := controlled
	var f: Dictionary = _fighters[i]
	if slot >= f["abilities"].size():
		return
	var m: String = f["abilities"][slot]
	if f["hp"] <= 0 or f["stun"] > 0.0 or f["dazzle"] > 0.0 or f["hidden"] or not f["windup"].is_empty() or f["ram_t"] > 0.0 or not f["tackle"].is_empty():
		return
	if f["cds"][m] > 0.0 or (MOVES[m].get("mobility", false) and m != "phase" and (f["crippled"] > 0.0 or _in_riptide(i) or _in_shards(i))):
		_play("res://assets/audio/sfx/ui/cancel.wav", -12.0)
		return
	var t := _foe_of(i)
	if t < 0:
		return
	if TELEGRAPH.has(m):
		f["windup"] = {"m": m, "kind": TELEGRAPH[m][0], "t": TELEGRAPH[m][1], "total": TELEGRAPH[m][1], "target": t}
		f["facing"] = _facing_of(_fighters[t]["body"].position - f["body"].position)
		_play("res://assets/audio/sfx/arena/telegraph.wav", -10.0)
	else:
		_fire(i, m, t)


## The move goes off, and its cooldown starts (one charge of it, for a move with charges).
func _fire(i: int, m: String, t: int) -> void:
	var f: Dictionary = _fighters[i]
	_do_move(i, m, t)
	if f["charge_cds"].has(m):
		var timers: Array = f["charge_cds"][m]
		var ready := -1
		for c in timers.size():
			if timers[c] <= 0.0 and (ready < 0 or timers[c] < timers[ready]):
				ready = c
		if ready >= 0:
			timers[ready] = MOVES[m]["cooldown"] * (AI_SLOWER if f["ai"] else 1.0)
		f["cds"][m] = timers.min()
		if f.get("phase_break", false):
			f["phase_break"] = false
		f["act"] = ACT_GAP
		return
	f["cds"][m] = MOVES[m]["cooldown"] * (AI_SLOWER if f["ai"] else 1.0)
	if f.get("phase_break", false):
		f["cds"][m] = PHASE_BREAK_COOLDOWN
		f["phase_break"] = false
	f["act"] = ACT_GAP


## A telegraphed move in its wind-up. Paralysis or a dazzle interrupts it (a charge cannot be
## interrupted); when the time is up it fires at the target it was aimed at, if still standing.
func _update_windup(i: int, delta: float) -> void:
	var f: Dictionary = _fighters[i]
	if f["windup"].is_empty():
		return
	var w: Dictionary = f["windup"]
	if f["hp"] <= 0 or f["hidden"] or ((f["stun"] > 0.0 or f["dazzle"] > 0.0) and w["kind"] != "charge"):
		f["windup"] = {}
		if f["hp"] > 0:
			f["cds"][w["m"]] = 0.8
			_label(i, "Interrupted")
		return
	w["t"] -= delta
	if w["t"] > 0.0:
		return
	f["windup"] = {}
	var t: int = w["target"]
	if t < 0 or _fighters[t]["hp"] <= 0:
		return
	if _fighters[t]["phase"] > 0.0 and w["m"] in ["claw", "cinder_claw", "club_slam", "root_snare", "riptide", "wick_bolt"]:
		# The target read the telegraph and phased: a direct move passes through nothing
		# (shots and lobs check this themselves when they arrive). The swing still costs it.
		_label(i, "Passed through")
		f["cds"][w["m"]] = MOVES[w["m"]]["cooldown"] * 0.5
		f["act"] = ACT_GAP
		return
	_fire(i, w["m"], t)


## During hitstop the one that was hit shakes a pixel along the blow.
func _shiver(i: int) -> void:
	var f: Dictionary = _fighters[i]
	if f["shiver"] == Vector2.ZERO or f["hp"] <= 0:
		return
	var sprite: Sprite2D = f["sprite"]
	var side := 1.0 if int(_hitstop * 60.0) % 2 == 0 else -1.0
	sprite.position = (f["shiver"] * side).round()
	sprite.global_position = sprite.global_position.round()


## Whether this is a good moment for move m.
func _wants(i: int, m: String, foe: Dictionary) -> bool:
	var f: Dictionary = _fighters[i]
	var to_foe: Vector2 = foe["body"].position - f["body"].position
	var dist := to_foe.length()
	match m:
		"phase":
			# Break free of roots; dodge an attack about to land; or read one coming (the enemy
			# is in range with a damaging move ready: the only way to beat an instant bolt).
			return f["rooted"] > 0.0 or _threat_near(i, 40.0) or (_foe_ready(foe, dist) and randf() < 0.05)
		"ember_feint":
			# Out through the embers when a blow is coming, or right after a strike up close.
			return _threat_near(i, 45.0) or (dist < 24.0 and foe["windup"].is_empty() and randf() < 0.15)
		"sinkhole", "burrow", "dive":
			# Ambush: when the target is a long way off, or something has closed in on it.
			return (dist > 100.0 or dist < 40.0) and foe["phase"] <= 0.0 and foe["hp"] > 0
		"riptide":
			# Catch something quick or slippery in a current, or slow something closing in.
			return dist < MOVES[m]["range"] and foe["phase"] <= 0.0 and (_has_mobility(foe) or dist < 80.0)
		"flashstep":
			# Dodge, get back out right after a strike, or close in from too far.
			return _threat_near(i, 40.0) or f["disengage"] > 0.0 or dist > 150.0
		"pounce":
			# The basic: in, strike, out. Only from pounce range, at something that is there.
			return dist < MOVES[m]["range"] and dist > 8.0 and foe["phase"] <= 0.0 and f["ram_t"] <= 0.0
		"lantern_volley":
			# Space, then shoot: when something is mid range and it has room behind it.
			return dist > 30.0 and dist < MOVES[m]["range"] and foe["phase"] <= 0.0 and f["ram_t"] <= 0.0
		"lantern_tackle":
			# Worth it with something marked, or to escape a crowd onto a single close target.
			var marked := 0
			for j in _fighters.size():
				if _enemies(i, j) and _fighters[j]["hp"] > 0 and _fighters[j]["marked"] > 0.0:
					marked += 1
			return marked > 0 or (dist < 50.0 and _threat_near(i, 40.0))
		"root_rampart":
			return dist > 35.0 and dist < MOVES[m]["range"] and foe["phase"] <= 0.0
		"root_snare":
			# Pin anything that relies on moving: evasive and slippery targets first.
			return dist < MOVES[m]["range"] and foe["rooted"] <= 0.0 and foe["phase"] <= 0.0 and (_has_mobility(foe) or dist > 50.0)
		"root_wall":
			# Cut off the escape: a curve of roots behind a target that keeps its distance.
			return dist > 45.0 and dist < MOVES[m]["range"] and not _has_walls(i)
		"lantern_flash":
			# Blind a close enemy that is about to act, or one charging its signature.
			return dist < MOVES[m]["range"] and (foe["act"] <= 0.0 or foe["meter"] >= 80) and foe["phase"] <= 0.0
		"ground_spikes":
			return dist > 30.0 and dist < MOVES[m]["range"] and foe["phase"] <= 0.0 and foe["rooted"] <= 0.0
		"rail_shot":
			# The long shot: from range, never at something that will phase through it.
			return dist > 50.0 and dist < MOVES[m]["range"] and foe["phase"] <= 0.0
		"rail_recoil":
			# Fire the rails at the floor to vault away from whatever has closed in.
			var nf := _nearest_foe(i)
			return nf >= 0 and _fighters[nf]["body"].position.distance_to(f["body"].position) < 45.0
		"vent_blast":
			return dist < MOVES[m]["range"] and foe["phase"] <= 0.0
		"static_dance":
			# Dance when a jab is coming and nothing is charged yet.
			return f["charged"] <= 0.0 and dist < 60.0
		"star_guard":
			# Shield whoever is hurt or about to be hit, itself included.
			var w := _guard_target(i)
			return w >= 0 and _fighters[w]["shield"] <= 0 and (_fighters[w]["hp"] < _fighters[w]["max_hp"] * 0.7 or _threat_near(w, 45.0))
		"counter_jab":
			# Dash to the ally in trouble when an enemy is on it.
			var w := _ally_in_trouble(i)
			return w >= 0 and w != i
		"stone_cocoon":
			# Pull tight when it is hurt and pressed, or a blow is about to land.
			return f["cocoon"] <= 0.0 and dist < 50.0 and (f["hp"] < f["max_hp"] * 0.6 or _threat_near(i, 45.0))
		"slab_vortex":
			return dist < MOVES[m]["range"] * 0.8 and foe["phase"] <= 0.0
		"glass_guard":
			# Plant when the fight is on it: something close and either hurt or about to be hit.
			return f["guard"] <= 0.0 and dist < 40.0 and (f["hp"] < f["max_hp"] * 0.7 or _threat_near(i, 45.0))
		"molten_cannon":
			# The big lob: from range, and not at something that will just phase through it.
			return dist > 40.0 and dist < MOVES[m]["range"] and foe["phase"] <= 0.0
		"plate_lunge":
			return dist < MOVES[m]["range"] and foe["phase"] <= 0.0
		"crest_ram":
			# A charge from mid range: a straight run that carries the target into whatever is behind it.
			return dist > 34.0 and dist < MOVES[m]["range"] and foe["phase"] <= 0.0 and f["ram_t"] <= 0.0
		_:
			return dist < MOVES[m]["range"] and foe["phase"] <= 0.0


func _threat_near(i: int, radius: float) -> bool:
	var me: Vector2 = _fighters[i]["body"].position
	# An enemy winding up an attack aimed at us, about to fire.
	for j in _fighters.size():
		var w: Dictionary = _fighters[j]["windup"]
		if _enemies(i, j) and not w.is_empty() and w["target"] == i and w["t"] < 0.12 and (w["kind"] != "melee" or _fighters[j]["body"].position.distance_to(me) < radius):
			return true
	for e in _effects:
		if not _enemies(e.get("owner", -1), i):
			continue
		if e.has("pos") and e["kind"] in ["fireball", "seed"] and e["pos"].distance_to(me) < radius:
			return true
		if e["kind"] == "beam" and e["len"] < 60.0 and Geometry2D.get_closest_point_to_segment(me, e["from"], e["from"] + e["dir"] * 90.0).distance_to(me) < 10.0:
			return true
	return false


func _do_move(i: int, m: String, t: int) -> void:
	var foe: Dictionary = _fighters[t]
	var f: Dictionary = _fighters[i]
	var to_foe: Vector2 = foe["body"].position - f["body"].position
	var aim := to_foe.normalized()
	f["facing"] = _facing_of(aim)
	var mouth: Vector2 = f["body"].position + Vector2(0, -10) + aim * 8.0
	var hot: bool = f["passive"] in ["stoke", "kiln"] and f["heat"] >= 100.0 and MOVES[m]["damage"] > 0   # Stoke or Kiln Heat spent on this move
	var dmg := _dmg(m, i, t)
	_label(i, MOVES[m]["name"])
	match m:
		"fireball":
			_effects.append({"kind": "fireball", "owner": i, "pos": mouth, "vel": aim * 170.0, "life": 0.75, "trail": [], "damage": dmg})
			_play("res://assets/audio/sfx/stormlantern/throw.wav", -10.0)
		"vent_barrage":
			# A gout of heat from the back vents, arcing over the head toward the target.
			var vent: Vector2 = f["body"].position + Vector2(0, -18 - 3 * f["stage"])
			_effects.append({"kind": "fireball", "owner": i, "pos": vent, "vel": aim * 150.0, "life": 0.8, "trail": [], "damage": dmg})
			_effects.append({"kind": "impact", "anim": "vent_flame", "pos": vent + Vector2(0, 6), "t": 0.0})
			_play("res://assets/audio/sfx/ironvent/vent_jet.wav", -14.0)
		"beam":
			_effects.append({"kind": "beam", "owner": i, "from": mouth, "dir": aim, "len": 0.0, "life": 0.55, "damage": dmg})
			_play("res://assets/audio/sfx/undertow/surge.wav", -12.0)
		"seed":
			_effects.append({"kind": "seed", "owner": i, "from": mouth, "to": foe["body"].position, "t": 0.0, "damage": dmg})
			_play("res://assets/audio/sfx/root_rampart/slam.wav", -14.0)
		"phase":
			f["phase"] = PHASE_SECONDS
			if f["rooted"] > 0.0:
				# Phasing slips out of the roots' hold, so it can move again; it stays crippled
				# (no Sinkhole until that wears off), so the tank keeps its edge.
				f["rooted"] = 0.0
				_label(i, "Slipped free")
				f["phase_break"] = true   # costs a longer cooldown (set after this move)
				for e in _effects:
					if e["kind"] == "snare" and e["who"] == i:
						e["t"] = ROOT_SECONDS
			_play("res://assets/audio/sfx/undertow/plunge.wav", -12.0)
		"wick_bolt":
			# Lightning straight from the lantern to the target: it lands at once.
			var from: Vector2 = _lantern_point(f)
			var to: Vector2 = foe["body"].position + Vector2(0, -8)
			var wall := _wall_on_line(from, to)
			var rock := _rock_on_line(from, to)
			if wall >= 0:
				# A root wall in the way takes the bolt and loses a pillar.
				to = _walls[wall]["pos"] + Vector2(0, -8)
				_walls.remove_at(wall)
			elif rock >= 0:
				# So does a rock, which takes the damage.
				to = _rocks[rock]["pos"] + Vector2(0, -_rocks[rock]["h"] * 0.5)
				_hit_rock(rock, dmg)
				wall = rock
			_effects.append({"kind": "bolt", "pts": _jagged(from, to, 7, 5.0), "t": 0.0, "big": f["charge"] >= 100.0})
			_spend_charge(f)
			if wall < 0:
				_hurt(t, dmg, aim, i)
				_fighters[t]["smoulder"] = SMOULDER_SECONDS
			_burst(to, Color("#fffbe0"), Color("#ffd23a"), 16.0, false, "shock_burst")
			_play("res://assets/audio/sfx/stormlantern/crack.wav", -10.0)
		"flashstep":
			# Preston (2026-10-07 night): a blind dash was useless. Flashstep now teleports to a
			# marked thing (your target if it is marked, else the nearest mark: enemy, rock or
			# crate), invulnerable, in a flash of light. With nothing marked it falls back to the dash.
			var spot := _mark_spot(i)
			if spot != Vector2.INF:
				f["invuln"] = INVULN_FLASHSTEP
				var start2: Vector2 = f["body"].position
				_effects.append({"kind": "arrow", "from": start2 + Vector2(0, -10), "to": spot + Vector2(0, -10), "t": 0.0})
				_effects.append({"kind": "flash", "pos": start2 + Vector2(0, -10), "t": 0.2})
				_effects.append({"kind": "flash", "pos": spot + Vector2(0, -10), "t": 0.1})
				_effects.append({"kind": "tele", "pos": start2 + Vector2(0, -10), "t": 0.0})
				_effects.append({"kind": "tele", "pos": spot + Vector2(0, -10), "t": 0.0})
				f["body"].position = spot
				f["facing"] = _facing_of(foe["body"].position - spot)
				_play("res://assets/audio/sfx/stormlantern/throw.wav", -8.0)
				if f["hollow"]:
					f["solid"] = maxf(f["solid"], SURFACE_ON_ATTACK)
				return
			var away := aim.orthogonal() * (1.0 if randf() < 0.5 else -1.0)
			if f["disengage"] > 0.0:
				away = (-aim + away * 0.5).normalized()
				f["disengage"] = 0.0
			elif not _threat_near(i, 40.0):
				away = -aim if to_foe.length() < 26.0 else aim
			f["invuln"] = INVULN_FLASHSTEP
			var start: Vector2 = f["body"].position
			var floor_rect: Rect2 = ARENAS[_arena]["floor"]
			var end := (start + away * FLASHSTEP_DISTANCE).clamp(floor_rect.position, floor_rect.end)
			if _blocked(end):
				end = start
			for k in 6:
				_effects.append({"kind": "fire_patch", "owner": i, "pos": start.lerp(end, k / 5.0), "t": 0.0, "tick": 0.0, "damage": dmg})
			var tex: Texture2D = f["sprite"].texture
			_effects.append({"kind": "streak", "from": start, "to": end, "t": 0.0, "tex": tex, "off": f["sprite"].offset})
			f["body"].position = end
			f["facing"] = _facing_of(away)
			f["charge"] = minf(100.0, f["charge"] + 15.0)
			_play("res://assets/audio/sfx/stormlantern/throw.wav", -8.0)
		"lantern_flash":
			# A blinding burst of lantern light: close enemies are dazzled, so they cannot
			# act and move at half speed for a moment. No damage.
			var at: Vector2 = _lantern_point(f)
			_effects.append({"kind": "flash", "pos": at, "t": 0.0})
			for j in _fighters.size():
				if _enemies(i, j) and _fighters[j]["body"].position.distance_to(f["body"].position) < MOVES[m]["range"] + 10.0:
					_fighters[j]["dazzle"] = DAZZLE_SECONDS
					_label(j, "Dazzled")
			_play("res://assets/audio/sfx/stormlantern/crackle.wav", -8.0)
		"claw":
			# Raptor Rake: a fast claw swipe up close; then Flare Step wants it straight back out.
			_effects.append({"kind": "claw", "pos": foe["body"].position + Vector2(0, -8), "dir": aim, "t": 0.0})
			_spend_charge(f)
			_hurt(t, dmg, aim, i)
			f["disengage"] = 0.6
			_play("res://assets/audio/sfx/ui/hit_weak.wav", -6.0)
		"deep_jet":
			# Scourmaw's long-range jet: a narrow, very long pressure beam. After a Sinkhole it is
			# the sharpened ambush shot, and spends the ambush.
			_effects.append({"kind": "beam", "owner": i, "from": mouth, "dir": aim, "len": 0.0, "life": 0.6, "damage": dmg, "reach": 160.0, "push": 1.6})
			if f["ambush"] > 0.0:
				f["ambush"] = 0.0
				_label(i, "Ambush")
			_play("res://assets/audio/sfx/undertow/surge.wav", -10.0)
		"ember_feint":
			# The hop back out of reach: the best open direction away from the target (straight
			# back, angled, or along the wall when the back is against it), untouchable for the
			# hop, embers left burning where it stood.
			var floor_rect: Rect2 = ARENAS[_arena]["floor"]
			var start: Vector2 = f["body"].position
			var best: Vector2 = start
			var best_gain := -1.0
			for ang in [0.0, 0.9, -0.9, 1.5708, -1.5708]:
				var cand: Vector2 = (start + (-aim).rotated(ang) * FEINT_HOP).clamp(floor_rect.position, floor_rect.end)
				if _blocked(cand):
					continue
				var gain: float = cand.distance_to(foe["body"].position) - start.distance_to(foe["body"].position)
				if gain > best_gain:
					best_gain = gain
					best = cand
			f["invuln"] = maxf(f["invuln"], FEINT_INVULN)
			# Three patches spaced along the first half of the hop, so a chaser crosses them one at
			# a time instead of standing in a stack (the first check stacked four for 42 damage).
			for k in 3:
				_effects.append({"kind": "fire_patch", "owner": i, "pos": start.lerp(best, 0.1 + k * 0.2), "t": 0.0, "tick": 0.0, "damage": dmg})
			_effects.append({"kind": "streak", "from": start, "to": best, "t": 0.0, "tex": f["sprite"].texture, "off": f["sprite"].offset})
			_effects.append({"kind": "dust", "pos": best, "t": 0.0})
			f["body"].position = best
			f["facing"] = _facing_of(foe["body"].position - best)
			_play("res://assets/audio/sfx/stormlantern/throw.wav", -12.0)
		"sinkhole", "burrow", "dive":
			# Sinks into its hollow and resurfaces behind the target (the far side from where it
			# was), sharpening its next Deep Jet: the assassin's ambush.
			var floor_rect: Rect2 = ARENAS[_arena]["floor"]
			var best: Vector2 = (foe["body"].position + aim * 30.0).clamp(floor_rect.position, floor_rect.end)
			for tries in 6:
				if not _blocked(best):
					break
				best = (foe["body"].position + aim.rotated(tries * 0.6) * 30.0).clamp(floor_rect.position, floor_rect.end)
			f["ambush"] = AMBUSH_SECONDS + SINK_SECONDS
			_effects.append({"kind": "whirl", "pos": f["body"].position, "t": 0.0})
			_effects.append({"kind": "whirl", "pos": best, "t": -SINK_SECONDS * 0.6})
			f["hidden"] = true
			f["sink"] = SINK_SECONDS
			f["sink_to"] = best
			_play("res://assets/audio/sfx/undertow/plunge.wav", -10.0)
		"riptide":
			# A current opens under the target: slowed, pulled in, no movement abilities while inside.
			_effects.append({"kind": "riptide", "owner": i, "pos": foe["body"].position, "t": 0.0})
			_label(t, "Caught")
			_play("res://assets/audio/sfx/undertow/whirlpool.wav", -10.0)
		"root_snare":
			# Roots burst up round the target: held in place, movement abilities crippled.
			var j := t
			_fighters[j]["rooted"] = ROOT_SECONDS
			_fighters[j]["crippled"] = CRIPPLE_SECONDS
			_effects.append({"kind": "snare", "who": j, "t": 0.0})
			_effects.append({"kind": "impact", "anim": "root_burst", "pos": _fighters[j]["body"].position + Vector2(0, -4), "t": 0.0})
			_hurt(j, dmg, Vector2.ZERO, i)
			_label(j, "Rooted")
			_play("res://assets/audio/sfx/root_rampart/rootwave.wav", -10.0)
		"root_rampart":
			# Roots tear across the ground to the target; where they arrive, the ground erupts: a
			# hit, a short hold, and a ring of root pillars round the spot.
			_effects.append({"kind": "rootrun", "owner": i, "from": f["body"].position + Vector2(0, 4), "to": foe["body"].position, "t": 0.0, "damage": dmg})
			_play("res://assets/audio/sfx/root_rampart/rootwave.wav", -6.0)
		"root_wall":
			# A curve of root pillars on the far side of the target, blocking its retreat and its shots.
			var c: Vector2 = foe["body"].position
			var back: Vector2 = (c - f["body"].position).normalized()
			for k in 9:
				var a := back.angle() + (k - 4) * 0.28
				var p := c + Vector2.RIGHT.rotated(a) * 22.0
				_walls.append({"pos": p.round(), "t": 0.0, "owner": i})
			_play("res://assets/audio/sfx/root_rampart/eruption.wav", -12.0)
		"club_slam":
			# Tail Club: the seed-pod club on its tail swings through; a heavy blow that carries the target.
			_burst(foe["body"].position + Vector2(0, -6), Color("#d8c08a"), Color("#7a5a32"), 18.0, false, "earth_burst")
			_hurt(t, dmg, aim * 2.6, i)
			_play("res://assets/audio/sfx/root_rampart/slam.wav", -8.0)
		"crest_ram":
			# Head down, vents roaring: a straight charge (see _update_ram for the hit).
			f["ram_t"] = RAM_SECONDS
			f["ram_dir"] = aim
			f["ram_dmg"] = dmg
			for k in 3:
				_effects.append({"kind": "dust", "pos": f["body"].position - aim * (4.0 + k * 3.0), "t": 0.0})
			_play("res://assets/audio/sfx/arena/crest_ram.wav", -6.0)
		"ember_pellet", "furnace_shard":
			# Small hot shots from the seams of the shell.
			_effects.append({"kind": "fireball", "owner": i, "pos": mouth, "vel": aim * 160.0, "life": 0.75, "trail": [], "damage": dmg})
			_play("res://assets/audio/sfx/stormlantern/throw.wav", -12.0)
		"glass_spur":
			# A jab with a glass spur from the shell's edge.
			_effects.append({"kind": "claw", "pos": foe["body"].position + Vector2(0, -8), "dir": aim, "t": 0.0})
			_hurt(t, dmg, aim * 0.8, i)
			_play("res://assets/audio/sfx/ui/hit_weak.wav", -6.0)
		"jade_lance":
			# A jade spike breaks free of its hip and pierces straight at the target.
			_effects.append({"kind": "fireball", "owner": i, "pos": f["body"].position + Vector2(0, -8) + aim * 10.0, "vel": aim * 190.0, "life": 0.7, "trail": [], "damage": dmg, "jade": true})
			_play("res://assets/audio/sfx/arena/rock_crack.wav", -12.0)
		"ground_spikes":
			# Jade erupts from the ground under the target: a hit and a short hold.
			_effects.append({"kind": "spikes", "pos": foe["body"].position, "t": 0.0})
			_burst(foe["body"].position + Vector2(0, -6), Color("#7cf5b8"), Color("#206349"), 18.0, false, "earth_burst")
			_hurt(t, dmg, Vector2.ZERO, i)
			if foe["hp"] > 0 and foe["phase"] <= 0.0 and foe["invuln"] <= 0.0:
				foe["rooted"] = maxf(foe["rooted"], SPIKE_ROOT)
				_label(t, "Spiked")
			_play("res://assets/audio/sfx/arena/rock_break.wav", -10.0)
		"stone_cocoon":
			# The slabs pull tight round it; in a moment they burst outward as shrapnel.
			f["cocoon"] = COCOON_SECONDS
			f["cocoon_dmg"] = dmg
			f["walk"] = 0.0
			_label(i, "Cocoon")
			_play("res://assets/audio/sfx/arena/rock_crack.wav", -8.0)
		"slab_vortex":
			# It rears and spins its plates: everything close is struck and thrown back.
			var struck := false
			for j in _fighters.size():
				var o: Dictionary = _fighters[j]
				if _enemies(i, j) and o["hp"] > 0 and o["body"].position.distance_to(f["body"].position) < VORTEX_RADIUS:
					var away: Vector2 = (o["body"].position - f["body"].position).normalized()
					_hurt(j, _dmg(m, i, j), away * 2.2, i)
					_burst(o["body"].position + Vector2(0, -8), Color("#afe8b8"), Color("#31353d"), 14.0, false, "rock_dust")
					struck = true
			_effects.append({"kind": "vortex", "who": i, "t": 0.0})
			_play("res://assets/audio/sfx/arena/wall_slam.wav" if struck else "res://assets/audio/sfx/arena/rock_crack.wav", -8.0)
		"rail_shot":
			# The rails fire a jade slug down the line: it pierces everything on it out to the
			# end of its range, and Oxbowarchon recoils a step. Everything it fires hits harder
			# from far away (the kit's far bonus, in _dmg).
			var a: Vector2 = f["body"].position + aim * 6.0
			var b: Vector2 = a + aim * MOVES[m]["range"]
			var struck := 0
			for j in _fighters.size():
				var o: Dictionary = _fighters[j]
				if not _enemies(i, j) or o["hp"] <= 0 or o["phase"] > 0.0 or o["invuln"] > 0.0:
					continue
				var c: Vector2 = o["body"].position + Vector2(0, -6)
				if Geometry2D.get_closest_point_to_segment(c, a, b).distance_to(c) < RAIL_WIDTH:
					_hurt(j, _dmg(m, i, j), aim * 1.4, i)
					_burst(c, Color("#7cf5b8"), Color("#206349"), 14.0, false, "")
					struck += 1
			_effects.append({"kind": "rail_beam", "from": f["body"].position + Vector2(0, -22), "to": b + Vector2(0, -6), "t": 0.0})
			_effects.append({"kind": "dust", "pos": f["body"].position, "t": 0.0})
			var floor_rect: Rect2 = ARENAS[_arena]["floor"]
			f["body"].position = (f["body"].position - aim * 5.0).clamp(floor_rect.position, floor_rect.end)
			_shake_by(3.0 + struck)
			_play("res://assets/audio/sfx/oxbowarchon/rail_impact.wav", -6.0 if struck > 0 else -14.0)
		"rail_recoil":
			# Both rails fire at the ground: the recoil throws it back away from the nearest
			# enemy (a short hop, untouchable for a moment) and the blast throws that enemy off.
			var nf := _nearest_foe(i)
			var away: Vector2 = -aim if nf < 0 else (f["body"].position - _fighters[nf]["body"].position).normalized()
			if away.length() < 0.01:
				away = -aim
			var floor_rect: Rect2 = ARENAS[_arena]["floor"]
			var here: Vector2 = f["body"].position
			var land: Vector2 = (here + away * RECOIL_HOP).clamp(floor_rect.position, floor_rect.end)
			for tries in 5:
				if not _blocked(land):
					break
				land = (here + away.rotated((tries + 1) * 0.5 * (1.0 if tries % 2 == 0 else -1.0)) * RECOIL_HOP).clamp(floor_rect.position, floor_rect.end)
			for j in _fighters.size():
				var o: Dictionary = _fighters[j]
				if _enemies(i, j) and o["hp"] > 0 and o["body"].position.distance_to(here) < 32.0:
					_hurt(j, _dmg(m, i, j), (o["body"].position - here).normalized() * 2.0, i)
			_effects.append({"kind": "rail_beam", "from": here + Vector2(0, -22), "to": here + Vector2(0, 2), "t": 0.0})
			_burst(here + Vector2(0, -2), Color("#afe8b8"), Color("#206349"), 18.0, false, "rock_dust")
			_effects.append({"kind": "dust", "pos": land, "t": 0.0})
			f["body"].position = land
			f["invuln"] = maxf(f["invuln"], RECOIL_INVULN)
			_play("res://assets/audio/sfx/oxbowarchon/rail_impact.wav", -10.0)
		"vent_blast":
			# A gout of heat from the back vents, a short cone in front: thrown back and smouldering.
			for j in _fighters.size():
				var o: Dictionary = _fighters[j]
				if not _enemies(i, j) or o["hp"] <= 0:
					continue
				var to_o: Vector2 = o["body"].position - f["body"].position
				if to_o.length() < MOVES[m]["range"] and to_o.normalized().dot(aim) > 0.5:
					_hurt(j, _dmg(m, i, j), to_o.normalized() * 1.6, i)
					if o["phase"] <= 0.0 and o["invuln"] <= 0.0:
						o["smoulder"] = SMOULDER_SECONDS
			for k in 3:
				_effects.append({"kind": "impact", "anim": "vent_flame", "pos": f["body"].position + aim * (14.0 + k * 12.0) + Vector2(0, -6), "t": 0.0})
			_play("res://assets/audio/sfx/ironvent/vent_jet.wav", -8.0)
		"jab":
			# A quick electric punch; charged by the dance, it hits harder and stuns.
			var jab_dmg := dmg
			if f["charged"] > 0.0:
				jab_dmg = int(round(dmg * CHARGED_JAB))
				f["charged"] = 0.0
				if foe["phase"] <= 0.0 and foe["invuln"] <= 0.0:
					foe["stun"] = maxf(foe["stun"], CHARGED_STUN)
				_label(i, "Charged Jab")
			_effects.append({"kind": "impact", "anim": "shock_burst", "pos": foe["body"].position + Vector2(0, -8), "t": 0.0})
			_effects.append({"kind": "impact", "anim": "light_slash", "pos": foe["body"].position + Vector2(0, -2), "t": 0.0})
			_hurt(t, jab_dmg, aim * 0.9, i)
			_play("res://assets/audio/sfx/stormlantern/crack.wav", -12.0)
		"static_dance":
			# The ferret war dance: static builds for its next jab, and every ally close by is
			# carried along a moment faster.
			f["charged"] = DANCE_WINDOW
			for j in _fighters.size():
				var o: Dictionary = _fighters[j]
				if o["team"] == f["team"] and o["hp"] > 0 and o["body"].position.distance_to(f["body"].position) < 50.0:
					o["haste"] = maxf(o["haste"], DANCE_HASTE)
					if j != i:
						_label(j, "Hasted")
			for k in 6:
				_effects.append({"kind": "burst", "pos": f["body"].position + Vector2.RIGHT.rotated(k * TAU / 6.0) * 10.0 + Vector2(0, -8), "core": Color("#fffbe0"), "rim": Color("#ffd23a"), "size": 5.0, "t": -k * 0.05, "bits": [Vector2(12, -12), Vector2(-12, -12)]})
			_play("res://assets/audio/sfx/stormlantern/crackle.wav", -10.0)
		"star_guard":
			# A pink star shield on the most hurt ally in reach (itself if nobody else needs it).
			var w := _guard_target(i)
			if w >= 0:
				_shield(w, GUARD_SHIELD, GUARD_SHIELD_SECONDS)
				_effects.append({"kind": "impact", "anim": "lantern_flash", "pos": _fighters[w]["body"].position + Vector2(0, -4), "t": 0.0})
			_play("res://assets/audio/sfx/starward/star_guard.wav", -8.0)
		"counter_jab":
			# It dashes to the ally in the most trouble and punches the enemy on it away.
			var w := _ally_in_trouble(i)
			if w < 0:
				w = _most_hurt_ally(i)
			var nf := _nearest_foe(w) if w >= 0 else t
			if w >= 0 and w != i:
				var floor_rect: Rect2 = ARENAS[_arena]["floor"]
				var wp: Vector2 = _fighters[w]["body"].position
				var side: Vector2 = (_fighters[nf]["body"].position - wp).normalized() if nf >= 0 else aim
				_effects.append({"kind": "impact", "anim": "lantern_flash", "pos": f["body"].position + Vector2(0, -4), "t": 0.0})
				f["body"].position = (wp + side * 14.0).clamp(floor_rect.position, floor_rect.end)
				_effects.append({"kind": "impact", "anim": "lantern_flash", "pos": f["body"].position + Vector2(0, -4), "t": 0.0})
			if nf >= 0 and _fighters[nf]["hp"] > 0 and _fighters[nf]["body"].position.distance_to(f["body"].position) < 44.0:
				var push: Vector2 = (_fighters[nf]["body"].position - f["body"].position).normalized()
				f["facing"] = _facing_of(push)
				_effects.append({"kind": "impact", "anim": "shock_burst", "pos": _fighters[nf]["body"].position + Vector2(0, -8), "t": 0.0})
				_hurt(nf, _dmg(m, i, nf), push * 2.2, i)
			_play("res://assets/audio/sfx/stormlantern/crack.wav", -8.0)
		"glass_guard":
			# Plants and runs its shell molten: a glass guard round it for a few seconds.
			f["guard"] = GUARD_SECONDS
			f["walk"] = 0.0
			_effects.append({"kind": "guard", "who": i, "t": 0.0})
			_label(i, "Guard")
			_play("res://assets/audio/sfx/vitrecrag/buildup.wav", -10.0)
		"plate_lunge":
			# The shell shoves forward: a heavy shove that carries the target.
			_burst(foe["body"].position + Vector2(0, -6), Color("#f0d8b0"), Color("#6a4a3a"), 16.0, false, "earth_burst")
			_hurt(t, dmg, aim * 2.0, i)
			_play("res://assets/audio/sfx/root_rampart/slam.wav", -10.0)
		"molten_cannon":
			# A mass of molten glass lobbed from the crater onto the target's spot; it carries whoever it lands on.
			var crater: Vector2 = f["body"].position + Vector2(0, -22 - 3 * f["stage"])
			_effects.append({"kind": "seed", "owner": i, "from": crater, "to": foe["body"].position, "t": 0.0, "damage": dmg, "molten": true, "push": CANNON_PUSH})
			_play("res://assets/audio/sfx/vitrecrag/buildup.wav", -12.0)
		"molten_beam":
			# A pour of molten glass straight from the mouth: a short, bright beam.
			_effects.append({"kind": "beam", "owner": i, "from": mouth, "dir": aim, "len": 0.0, "life": 0.5, "damage": dmg, "reach": 125.0, "molten": true})
			_play("res://assets/audio/sfx/ironvent/vent_jet.wav", -12.0)
		"pounce":
			# In, strike, straight back out (the Pikachu rhythm): a short fast dash that stops
			# at the target, hits, then reverses for a moment.
			f["ram_t"] = minf(0.3, maxf(0.06, (to_foe.length() - 10.0) / POUNCE_SPEED))
			f["ram_dir"] = aim
			f["ram_dmg"] = dmg
			f["ram_return"] = true
			f["ram_end_hit"] = false
			_spend_charge(f)
			_effects.append({"kind": "dust", "pos": f["body"].position - aim * 4.0, "t": 0.0})
			_play("res://assets/audio/sfx/stormlantern/throw.wav", -14.0)
		"lantern_volley":
			# Hops back (the back-jump from the reference), then the lantern balls go out in a spread.
			f["ram_t"] = VOLLEY_HOP / POUNCE_SPEED
			f["ram_dir"] = -aim
			f["ram_dmg"] = 0
			f["ram_return"] = false
			f["ram_end_hit"] = false
			f["after"] = "volley"
			f["after_aim"] = aim
			f["after_dmg"] = dmg
			_effects.append({"kind": "dust", "pos": f["body"].position + aim * 4.0, "t": 0.0})
			_play("res://assets/audio/sfx/stormlantern/throw.wav", -10.0)
		"lantern_tackle":
			# Teleports to its marked enemies, invulnerable, striking one every TACKLE_HOP for a
			# fixed TACKLE_SECONDS whether there is one or several; with none marked it works
			# its target alone. Left/right while it runs choose where it lands (_cycle_landing).
			var targets: Array = []
			for j in _fighters.size():
				if _enemies(i, j) and _fighters[j]["hp"] > 0 and _fighters[j]["marked"] > 0.0:
					targets.append(j)
			if targets.is_empty():
				targets.append(t)
			f["tackle"] = {"t": TACKLE_SECONDS, "hop": 0.0, "targets": targets, "k": 0, "side": 1.0, "dmg": dmg,
				"land": ["f", player_target if i == controlled and player_target >= 0 else t], "from": f["body"].position}
			f["invuln"] = TACKLE_SECONDS + 0.15
			_play("res://assets/audio/sfx/stormlantern/crackle.wav", -6.0)
		"cinder_claw":
			# Claws hot from the vents: a close swipe that leaves the target smouldering.
			_effects.append({"kind": "claw", "pos": foe["body"].position + Vector2(0, -8), "dir": aim, "t": 0.0})
			_hurt(t, dmg, aim * 0.8, i)
			_fighters[t]["smoulder"] = SMOULDER_SECONDS
			for k in 4:
				_effects.append({"kind": "ember", "pos": foe["body"].position + Vector2(randf_range(-6, 6), -10), "vel": Vector2(randf_range(-10, 10), -16), "t": 0.0})
			_play("res://assets/audio/sfx/arena/cinder_claw.wav", -5.0)
	if hot:
		# Full heat spent on that move: the vents blow it out.
		f["heat"] = 0.0
		_burst(f["body"].position + Vector2(0, -18 - 3 * f["stage"]), Color("#fff1c0"), Color("#ff6a1a"), 14.0, false, "vent_flame")
		_label(i, "Kiln blast" if f["passive"] == "kiln" else "Vented")
	if f["hollow"]:
		f["solid"] = maxf(f["solid"], SURFACE_ON_ATTACK)


## Whether the enemy, at this distance, has a damaging move ready to fire at us.
func _foe_ready(foe: Dictionary, dist: float) -> bool:
	if foe["act"] > 0.0 or foe["stun"] > 0.0 or foe["dazzle"] > 0.0:
		return false
	for m in foe["kit"]:
		if MOVES[m]["damage"] > 0 and MOVES[m]["range"] > 0.0 and foe["cds"][m] <= 0.0 and dist < MOVES[m]["range"]:
			return true
	return false


## Whether fighter i stands in an enemy's vine field (Verdant Roar).
## The ally (itself included) with the smallest share of its HP left; -1 with nobody alive.
func _most_hurt_ally(i: int) -> int:
	var best := -1
	for j in _fighters.size():
		var o: Dictionary = _fighters[j]
		if o["team"] == _fighters[i]["team"] and o["hp"] > 0 and (best < 0 or float(o["hp"]) / o["max_hp"] < float(_fighters[best]["hp"]) / _fighters[best]["max_hp"]):
			best = j
	return best


## Who Star Guard goes on: the most hurt ally within reach, itself if that is nobody else.
func _guard_target(i: int) -> int:
	var best := -1
	for j in _fighters.size():
		var o: Dictionary = _fighters[j]
		if o["team"] == _fighters[i]["team"] and o["hp"] > 0 and o["body"].position.distance_to(_fighters[i]["body"].position) < MOVES["star_guard"]["range"]:
			if best < 0 or float(o["hp"]) / o["max_hp"] < float(_fighters[best]["hp"]) / _fighters[best]["max_hp"]:
				best = j
	return best


## The ally (not itself) with an enemy right on it, the most hurt first; -1 when none.
func _ally_in_trouble(i: int) -> int:
	var best := -1
	for j in _fighters.size():
		var o: Dictionary = _fighters[j]
		if j == i or o["team"] != _fighters[i]["team"] or o["hp"] <= 0 or o["body"].position.distance_to(_fighters[i]["body"].position) > MOVES["counter_jab"]["range"]:
			continue
		var nf := _nearest_foe(j)
		if nf >= 0 and _fighters[nf]["body"].position.distance_to(o["body"].position) < 40.0:
			if best < 0 or float(o["hp"]) / o["max_hp"] < float(_fighters[best]["hp"]) / _fighters[best]["max_hp"]:
				best = j
	return best


## A star shield on fighter j: absorbs `amount` before HP, for `seconds`.
func _shield(j: int, amount: int, seconds: float) -> void:
	var f: Dictionary = _fighters[j]
	if f["hp"] <= 0:
		return
	f["shield"] = maxi(f["shield"], amount)
	f["shield_t"] = maxf(f["shield_t"], seconds)
	_label(j, "Shielded")


## Starshield: every ally is shielded and cleansed; every enemy inside the star is thrown
## out of it and held a moment.
func _on_star_shield(at: Vector2, radius: float) -> void:
	for j in _fighters.size():
		var f: Dictionary = _fighters[j]
		if f["hp"] <= 0:
			continue
		if f["team"] == _fighters[_sig_user]["team"]:
			_shield(j, STARSHIELD_SHIELD, STARSHIELD_SECONDS)
			f["glassed"] = 0.0
			f["rooted"] = 0.0
			f["crippled"] = 0.0
			f["smoulder"] = 0.0
			f["dazzle"] = 0.0
			f["stun"] = 0.0
		else:
			var d: Vector2 = f["body"].position - at
			if d.length() < radius:
				var out: Vector2 = d.normalized() if d.length() > 0.01 else Vector2.RIGHT
				_hurt(j, 1, out * 3.0, _sig_user)
				if f["phase"] <= 0.0 and f["invuln"] <= 0.0:
					f["stun"] = maxf(f["stun"], STARSHIELD_STUN)
					_label(j, "Repelled")
	_hitstop = maxf(_hitstop, HITSTOP_HEAVY)


## Starshield's star field: allies standing in it mend (the first ally-only terrain).
func _on_star_field(at: Vector2) -> void:
	_effects.append({"kind": "star_field", "owner": _sig_user, "pos": at, "t": 0.0, "tick": HAZARD_TICK})


## Whether fighter i stands among an enemy's Kingstone shards (Kingstone Rail's crater).
func _in_shards(i: int) -> bool:
	for e in _effects:
		if e["kind"] == "shards" and _enemies(e["owner"], i) and _fighters[i]["body"].position.distance_to(e["pos"]) < SHARDS_RADIUS:
			return true
	return false


func _in_vines(i: int) -> bool:
	for e in _effects:
		if e["kind"] == "vines" and _enemies(e["owner"], i) and _fighters[i]["body"].position.distance_to(e["pos"]) < VINES_RADIUS:
			return true
	return false


## Whether fighter i stands in an enemy's Riptide.
func _in_riptide(i: int) -> bool:
	for e in _effects:
		if e["kind"] == "riptide" and _enemies(e["owner"], i) and e["t"] > 0.0 and _fighters[i]["body"].position.distance_to(e["pos"]) < RIPTIDE_RADIUS:
			return true
	return false


## The first root pillar on the straight line between two points, or -1.
func _wall_on_line(a: Vector2, b: Vector2) -> int:
	for k in _walls.size():
		var q: Vector2 = _walls[k]["pos"] + Vector2(0, -8)
		if Geometry2D.get_closest_point_to_segment(q, a, b).distance_to(q) < 5.0:
			return k
	return -1


func _has_mobility(f: Dictionary) -> bool:
	for m in f["kit"]:
		if MOVES[m].get("mobility", false):
			return true
	return false


func _has_walls(i: int) -> bool:
	for w in _walls:
		if w["owner"] == i:
			return true
	return false


## Whether a point is inside a root wall piece (a creature cannot stand there).
func _blocked(p: Vector2) -> bool:
	for w in _walls:
		if w["pos"].distance_to(p) < 7.0:
			return true
	return _rock_near(p, 0.0) >= 0


## The standing rock whose footprint (an ellipse at its base) is within `pad` of a point, or -1.
func _rock_near(p: Vector2, pad: float) -> int:
	for k in _rocks.size():
		var r: Dictionary = _rocks[k]
		var d: Vector2 = (p - r["pos"]) / Vector2(r["rx"] + pad, r["rx"] * 0.42 + pad)
		if d.length() < 1.0:
			return k
	return -1


## Whether a point on screen lies on a rock's body (the dome above its base).
func _rock_body_has(r: Dictionary, p: Vector2) -> bool:
	var d: Vector2 = (p - (r["pos"] + Vector2(0, -r["h"] * 0.45))) / Vector2(r["rx"], r["h"] * 0.52)
	return d.length() < 1.0


## The rock a shot at this point has run into, or -1.
func _rock_at(p: Vector2) -> int:
	for k in _rocks.size():
		if _rock_body_has(_rocks[k], p):
			return k
	return -1


## The first rock whose body the straight line between two points crosses, or -1.
func _rock_on_line(a: Vector2, b: Vector2) -> int:
	for k in _rocks.size():
		var c: Vector2 = _rocks[k]["pos"] + Vector2(0, -_rocks[k]["h"] * 0.45)
		if _rock_body_has(_rocks[k], Geometry2D.get_closest_point_to_segment(c, a, b)):
			return k
	return -1


## Damage to a rock: it cracks at two thirds and one third, and shatters at zero.
func _hit_rock(k: int, damage: int) -> void:
	var r: Dictionary = _rocks[k]
	var before := _rock_stage(r)
	r["hp"] = maxi(0, r["hp"] - damage)
	r["flash"] = 0.12
	r["node"].queue_redraw()
	if r["hp"] <= 0:
		_break_rock(k)
		return
	if _rock_stage(r) != before:
		# A crack opens: a few small shards fall off.
		for c in 4:
			_chunk(r["pos"] + Vector2(randf_range(-r["rx"] * 0.5, r["rx"] * 0.5), -r["h"] * 0.5), r["rx"] * 0.18, Vector2.RIGHT.rotated(randf() * TAU) * randf_range(20, 45))
		_play("res://assets/audio/sfx/arena/rock_crack.wav", -6.0)


func _rock_stage(r: Dictionary) -> int:
	return 0 if r["hp"] * 3 > r["max_hp"] * 2 else (1 if r["hp"] * 3 > r["max_hp"] else 2)


## A rock shatters: big angular shards fly out and land as rubble that stays for the rest
## of the fight (the reference's debris pieces are each half a creature or more), dust goes
## up, and a dark crater is left where it stood.
func _break_rock(k: int) -> void:
	var r: Dictionary = _rocks[k]
	var at: Vector2 = r["pos"]
	var rx: float = r["rx"]
	_breaking_crate = r["kind"] == "crate"
	var n := 15 if r["big"] else 8
	for c in n:
		var size: float = rx * (0.28 if c % 3 == 0 else (0.2 if c % 3 == 1 else 0.36))
		_chunk(at + Vector2(randf_range(-rx * 0.6, rx * 0.6), randf_range(-r["h"] * 0.8, -r["h"] * 0.2)), size,
			Vector2.RIGHT.rotated(randf() * TAU) * randf_range(rx * 1.5, rx * 3.6))
	_breaking_crate = false
	_rubble_bits.append({"pos": at, "rx": rx})
	_burst(at + Vector2(0, -r["h"] * 0.4), Color("#e8e0d0"), Color("#6e665c"), rx * 1.4, false, "rock_dust")
	_rubble.queue_redraw()
	r["node"].queue_free()
	_rocks.remove_at(k)
	_shake_by(5.0 if r["big"] else 3.0)
	_cheer = maxf(_cheer, 0.8)
	_play("res://assets/audio/sfx/arena/rock_break.wav", -2.0 if r["big"] else -8.0)


## A flying shard of rock: an angular polygon in one of the rock's facet shades.
func _chunk(at: Vector2, size: float, vel: Vector2) -> void:
	var pts := PackedVector2Array()
	var corners := 3 + randi() % 3
	var a0 := randf() * TAU
	for c in corners:
		var a := a0 + c * TAU / corners + randf_range(-0.3, 0.3)
		pts.append(Vector2.RIGHT.rotated(a) * size * randf_range(0.6, 1.0))
	_effects.append({"kind": "chunk", "pos": at, "vel": vel, "h": 4.0, "vh": randf_range(60, 110), "s": size, "t": 0.0,
		"pts": pts, "c": (CRATE_SHADES if _breaking_crate else ROCK_SHADES)[randi() % 4], "spin": randf_range(-6.0, 6.0)})


var _breaking_crate := false   # set while a crate's shards are made, so they come out as planks


func _draw_shard(on: CanvasItem, pts: PackedVector2Array, c: Color) -> void:
	on.draw_colored_polygon(pts, c)
	var outline := PackedVector2Array(pts)
	outline.append(pts[0])
	on.draw_polyline(outline, ROCK_OUTLINE, 1.0)


## The wall piece a shot at this point has run into (shots fly at chest height), or -1.
func _wall_at(p: Vector2) -> int:
	for k in _walls.size():
		if _walls[k]["pos"].distance_to(p + Vector2(0, 8)) < 7.0:
			return k
	return -1


## How hard an attack of essence `attacker` lands on fighter j (both its essences multiply).
func _essence_mult(attacker: int, j: int) -> float:
	var m := 1.0
	for d in _fighters[j]["essences"]:
		m *= ARENA_CHART.get([attacker, d], 1.0)
	return m


## A move's damage from fighter i: its stage, and Stormwick's overcharge at full charge.
func _dmg(m: String, i: int, t: int) -> int:
	var f: Dictionary = _fighters[i]
	var d: float = MOVES[m]["damage"] * f["power"]
	if f["lantern"] and f["charge"] >= 100.0 and m != "flashstep":
		d *= OVERCHARGE
	# Assassins strike harder from a distance.
	if f["far_bonus"] > 1.0 and f["body"].position.distance_to(_fighters[t]["body"].position) > 110.0:
		d *= f["far_bonus"]
	if m == "deep_jet" and f["ambush"] > 0.0:
		d *= AMBUSH_BONUS
	if f["passive"] == "stoke" and f["heat"] >= 100.0:
		d *= STOKE_BONUS
	if f["passive"] == "kiln" and f["heat"] >= 100.0:
		d *= KILN_BONUS
	if MOVE_ESSENCE.has(m):
		d *= _essence_mult(MOVE_ESSENCE[m], t)
	return int(round(d))


## Screen shake, capped: ordinary hits ask for SHAKE_HIT, nothing exceeds SHAKE_MAX.
func _shake_by(amount: float) -> void:
	_shake = minf(SHAKE_MAX, maxf(_shake, amount))


func _spend_charge(f: Dictionary) -> void:
	if f["lantern"] and f["charge"] >= 100.0:
		f["charge"] = 0.0
		_shake_by(5.0)


## Fighter i's signature, once its meter is full. You choose when; the rival's AI fires its own.
func signature(i: int) -> void:
	var f: Dictionary = _fighters[i]
	if not f["final"] or f["meter"] < 100 or f["hp"] <= 0 or f["stun"] > 0.0 or _winner >= 0 or _sig.active:
		return
	f["meter"] = 0
	_sig_user = i
	var target := _pick_target(i)
	var from: Vector2 = _lantern_point(f) if f["lantern"] else f["body"].position
	_sig.start(LINES[f["line"]]["signature"], from, _fighters[target]["body"].position, target)
	_cheer = 2.5


## The one opponent a single-target signature hits: the weakest, then the nearest.
func _pick_target(i: int) -> int:
	if i == controlled and player_target >= 0 and _fighters[player_target]["hp"] > 0:
		return player_target
	var best := -1
	for j in _fighters.size():
		if not _enemies(i, j) or _fighters[j]["hp"] <= 0:
			continue
		if best < 0 or _fighters[j]["hp"] < _fighters[best]["hp"] or (_fighters[j]["hp"] == _fighters[best]["hp"] and \
				_fighters[j]["body"].position.distance_to(_fighters[i]["body"].position) < _fighters[best]["body"].position.distance_to(_fighters[i]["body"].position)):
			best = j
	return best


## Molten Glass's rain cools into a wide field of glass pools round Vitrecrag itself
## (Preston, 2026-10-08: "more AoE around it, so the pool effect is wider"; team play, since
## only enemies are hurt by it and its own team can fight from inside).
func _on_glass_pools(at: Vector2) -> void:
	var floor_rect: Rect2 = ARENAS[_arena]["floor"]
	for pool in GLASS_FIELD:
		var p: Vector2 = (at + pool[0]).clamp(floor_rect.position, floor_rect.end)
		_effects.append({"kind": "glass_pool", "owner": _sig_user, "pos": p, "r": pool[1], "t": 0.0, "tick": HAZARD_TICK})


## Kingstone Rail's impact: everyone else near where the meteor lands takes part of the
## damage, is floored and thrown back, and the crater stays ringed with Kingstone shards
## that slow enemies and shut off their movement abilities (enemy-only terrain).
func _on_rail_impact(at: Vector2) -> void:
	var dmg: float = _sig.DAMAGE * _fighters[_sig_user]["power"] * RAIL_SPLASH
	for j in _fighters.size():
		var f: Dictionary = _fighters[j]
		if not _enemies(_sig_user, j) or f["hp"] <= 0 or j == _sig._target:
			continue
		var d: Vector2 = f["body"].position - at
		if d.length() < RAIL_RADIUS:
			_hurt(j, maxi(1, int(round(dmg * _essence_mult(E.BLOOM, j)))), d.normalized() * 2.5, _sig_user)
			f["dazzle"] = maxf(f["dazzle"], 1.0)
			_label(j, "Floored")
	_effects.append({"kind": "shards", "owner": _sig_user, "pos": at, "t": 0.0})
	_hitstop = maxf(_hitstop, HITSTOP_HEAVY)


## Molten glass clings to fighter j: Glassed (see GLASSED_*). Phased or invulnerable
## creatures shed it.
func _glass(j: int, seconds: float) -> void:
	var f: Dictionary = _fighters[j]
	if f["hp"] <= 0 or f["phase"] > 0.0 or f["invuln"] > 0.0:
		return
	if f["glassed"] <= 0.0:
		f["glassed_tick"] = GLASSED_TICK
		_label(j, "Glassed")
	f["glassed"] = maxf(f["glassed"], seconds)


## Furnace Roar's vent crowd control: a heat geyser erupts under every enemy on the field,
## stunning it and setting it smouldering.
func _on_geysers() -> void:
	var any := false
	for j in _fighters.size():
		var f: Dictionary = _fighters[j]
		if _enemies(_sig_user, j) and f["hp"] > 0:
			_effects.append({"kind": "geyser", "pos": f["body"].position, "t": 0.0})
			if f["phase"] <= 0.0 and f["invuln"] <= 0.0:
				f["stun"] = maxf(f["stun"], GEYSER_STUN)
				f["smoulder"] = SMOULDER_SECONDS
				_label(j, "Vented")
				any = true
	if any:
		_hitstop = maxf(_hitstop, HITSTOP_HEAVY)


## Furnace Roar splits the floor: lava seams along the cone that stay burning.
func _on_lava_seams(origin: Vector2, dir: Vector2) -> void:
	var floor_rect: Rect2 = ARENAS[_arena]["floor"]
	for k in 3:
		var a: Vector2 = dir.rotated((k - 1) * 0.42)
		var pts := PackedVector2Array()
		var p: Vector2 = origin + Vector2(0, 4)
		pts.append(p.round())
		for step in 7:
			p = (p + a.rotated(sin((k + step) * 2.1) * 0.35) * 18.0).clamp(floor_rect.position, floor_rect.end)
			pts.append(p.round())
		_effects.append({"kind": "lava_seam", "owner": _sig_user, "pts": pts, "t": 0.0, "tick": HAZARD_TICK})


## The slow a fighter suffers from standing in enemy terrain (1.0 when clear).
func _hazard_slow(i: int) -> float:
	var slow := 1.0
	var me: Vector2 = _fighters[i]["body"].position
	for e in _effects:
		if e["kind"] == "glass_pool" and _enemies(e["owner"], i) and me.distance_to(e["pos"]) < e.get("r", POOL_RADIUS):
			slow = minf(slow, POOL_SLOW)
		elif e["kind"] == "lava_seam" and _enemies(e["owner"], i) and _near_seam(e["pts"], me) < SEAM_WIDTH:
			slow = minf(slow, SEAM_SLOW)
		elif e["kind"] == "shards" and _enemies(e["owner"], i) and me.distance_to(e["pos"]) < SHARDS_RADIUS:
			slow = minf(slow, SHARDS_SLOW)
	return slow


func _near_seam(pts: PackedVector2Array, p: Vector2) -> float:
	var best := INF
	for k in pts.size() - 1:
		best = minf(best, Geometry2D.get_closest_point_to_segment(p, pts[k], pts[k + 1]).distance_to(p))
	return best


## Verdant Roar's roar: every opponent on the field is rooted for a moment.
func _on_root_all() -> void:
	for j in _fighters.size():
		if _enemies(_sig_user, j) and _fighters[j]["hp"] > 0:
			_fighters[j]["rooted"] = maxf(_fighters[j]["rooted"], ROAR_ROOT)
			_effects.append({"kind": "snare", "who": j, "t": 0.0})
			_label(j, "Rooted")


## Verdant Roar's slam leaves a vine field that slows whoever walks through it.
func _on_vine_field(at: Vector2) -> void:
	_effects.append({"kind": "vines", "owner": _sig_user, "pos": at, "t": 0.0})


## Molten Glass's eruption: every opponent inside the ring round Vitrecrag takes the
## signature damage and is Glassed (the ring is drawn squashed, so the test is too).
func _on_glass_rain(at: Vector2, radius: float, damage: int) -> void:
	for j in _fighters.size():
		var f: Dictionary = _fighters[j]
		if not _enemies(_sig_user, j) or f["hp"] <= 0:
			continue
		var d: Vector2 = f["body"].position - at
		if Vector2(d.x, d.y / 0.6).length() < radius:
			_hurt(j, maxi(1, int(round(damage * _fighters[_sig_user]["power"] * _essence_mult(E.EMBER, j)))), Vector2.ZERO, _sig_user)
			_glass(j, GLASSED_SECONDS)


## Furnace Roar's wave: every opponent in the cone (other than the target, which takes the
## damage) is blown back and briefly loses its footing.
func _on_pressure_wave(origin: Vector2, dir: Vector2) -> void:
	for j in _fighters.size():
		var f: Dictionary = _fighters[j]
		if not _enemies(_sig_user, j) or f["hp"] <= 0 or j == _sig._target:
			continue
		var to: Vector2 = f["body"].position - origin
		if to.length() < ArenaSignature.ROAR_REACH + 20.0 and absf(dir.angle_to(to)) < ArenaSignature.ROAR_CONE:
			_carry(j, to.normalized() * ROAR_PUSH, _sig_user)
			f["dazzle"] = maxf(f["dazzle"], 0.6)
			_label(j, "Blown back")


## Crest Ram in flight: Ironvent runs straight at RAM_SPEED. The first enemy it reaches takes
## the damage and is carried (so a wall or rock behind it means a slam); a rock, root wall
## or the arena edge stops the run.
func _update_ram(i: int, delta: float) -> void:
	var f: Dictionary = _fighters[i]
	if f["ram_t"] <= 0.0 or f["hp"] <= 0:
		return
	f["ram_t"] -= delta
	var floor_rect: Rect2 = ARENAS[_arena]["floor"]
	var speed: float = RAM_SPEED if f["form"] in ["ironvent", "clinkerhide"] else POUNCE_SPEED
	var next: Vector2 = f["body"].position + f["ram_dir"] * speed * delta
	var hit := -1 if (f["ram_dmg"] <= 0 or f["ram_end_hit"]) else _hit_at(next + Vector2(0, -6), 14.0, i)
	if hit >= 0:
		f["ram_t"] = 0.0
		if f["ram_return"]:
			# The pounce lands: a quick strike, then straight back out.
			_effects.append({"kind": "claw", "pos": _fighters[hit]["body"].position + Vector2(0, -8), "dir": f["ram_dir"], "t": 0.0})
			_hurt(hit, f["ram_dmg"], f["ram_dir"] * 0.8, i)
			_play("res://assets/audio/sfx/ui/hit_weak.wav", -6.0)
			f["ram_dir"] = -f["ram_dir"]
			f["ram_t"] = 0.18
			f["ram_dmg"] = 0
			f["ram_return"] = false
			f["disengage"] = 0.4
		else:
			_burst(_fighters[hit]["body"].position + Vector2(0, -8), Color("#ffd9a0"), Color("#d8401a"), 20.0, false, "fire_burst")
			_hurt(hit, f["ram_dmg"], f["ram_dir"] * RAM_PUSH, i)
			_play("res://assets/audio/sfx/ui/hit_strong.wav", -4.0)
		return
	if f["ram_t"] <= 0.0:
		_ram_ended(i)
		return
	if not floor_rect.has_point(next) or _blocked(next):
		f["ram_t"] = 0.0
		_effects.append({"kind": "dust", "pos": f["body"].position, "t": 0.0})
		_shake_by(2.0)
		_ram_ended(i)
		return
	f["body"].position = next
	if f["ram_dmg"] > 0 or f["after"] == "":
		f["facing"] = _facing_of(f["ram_dir"])
	f["walk"] += delta
	if int(f["ram_t"] * 60.0) % 3 == 0:
		_effects.append({"kind": "dust", "pos": next - f["ram_dir"] * 5.0, "t": 0.0})


## A dash ran its full length: Lantern Lunge lands only if the target is in reach now; a
## pounce that found nothing just stops; Lantern Volley fires after its hop.
func _ram_ended(i: int) -> void:
	var f: Dictionary = _fighters[i]
	if f["ram_end_hit"]:
		f["ram_end_hit"] = false
		var hit := _hit_at(f["body"].position + f["ram_dir"] * 6.0 + Vector2(0, -6), 20.0, i)
		if hit >= 0:
			_burst(_fighters[hit]["body"].position + Vector2(0, -8), Color("#fff1a8"), Color("#ff7a1a"), 22.0, false, "fire_burst")
			_hurt(hit, f["ram_dmg"], f["ram_dir"] * 1.6, i)
			_fighters[hit]["smoulder"] = SMOULDER_SECONDS
			_play("res://assets/audio/sfx/ui/hit_strong.wav", -4.0)
		else:
			_label(i, "Missed")
			_effects.append({"kind": "dust", "pos": f["body"].position, "t": 0.0})
	f["ram_return"] = false
	if f["after"] == "volley":
		f["after"] = ""
		var aim: Vector2 = f["after_aim"]
		var from: Vector2 = _lantern_point(f) if f["lantern"] else f["body"].position + Vector2(0, -10)
		for k in 3:
			var dir: Vector2 = aim.rotated((k - 1) * 0.26)
			_effects.append({"kind": "fireball", "owner": i, "pos": from + dir * 6.0, "vel": dir * 175.0, "life": 2.4, "trail": [], "damage": f["after_dmg"],
				"bounce": BALL_BOUNCES, "mark": true})
		f["facing"] = _facing_of(aim)
		_spend_charge(f)
		_play("res://assets/audio/sfx/stormlantern/throw.wav", -8.0)


## Where a Flashstep teleport goes: beside the controlled creature's target if it is marked,
## else beside the nearest marked enemy, rock or crate. Vector2.INF when nothing is marked.
func _mark_spot(i: int) -> Vector2:
	var me: Vector2 = _fighters[i]["body"].position
	var best := Vector2.INF
	var best_d := INF
	var t: int = _fighters[i]["target"]
	if t >= 0 and _fighters[t]["hp"] > 0 and _fighters[t]["marked"] > 0.0:
		var tp: Vector2 = _fighters[t]["body"].position
		return tp + (me - tp).normalized() * 22.0 if me.distance_to(tp) > 1.0 else tp + Vector2(22, 0)
	for j in _fighters.size():
		if _enemies(i, j) and _fighters[j]["hp"] > 0 and _fighters[j]["marked"] > 0.0:
			var jp: Vector2 = _fighters[j]["body"].position
			if me.distance_to(jp) < best_d:
				best_d = me.distance_to(jp)
				best = jp + (me - jp).normalized() * 22.0
	for r in _rocks:
		if r["marked"] > 0.0 and me.distance_to(r["pos"]) < best_d:
			best_d = me.distance_to(r["pos"])
			best = r["pos"] + Vector2(0, r["rx"] * 0.45 + 10.0)
	if best != Vector2.INF:
		var floor_rect: Rect2 = ARENAS[_arena]["floor"]
		best = best.clamp(floor_rect.position, floor_rect.end)
		if _blocked(best):
			return Vector2.INF
	return best


## Lantern Tackle in flight: every TACKLE_HOP it flashes to the next marked enemy (alternating
## sides of a lone target, so it reads as back and forth), strikes it, and leaves an arrow of
## light between the two spots. When the time is up it lands at the chosen spot.
func _update_tackle(i: int, delta: float) -> void:
	var f: Dictionary = _fighters[i]
	if f["tackle"].is_empty() or f["hp"] <= 0:
		return
	var tk: Dictionary = f["tackle"]
	tk["t"] -= delta
	tk["hop"] -= delta
	if tk["hop"] <= 0.0 and tk["t"] > 0.0:
		tk["hop"] = TACKLE_HOP
		# Drop targets that have fallen; with none left, it works the current target.
		var live: Array = tk["targets"].filter(func(j): return _fighters[j]["hp"] > 0)
		if live.is_empty():
			live = [f["target"]] if f["target"] >= 0 and _fighters[f["target"]]["hp"] > 0 else []
		if not live.is_empty():
			var j: int = live[tk["k"] % live.size()]
			tk["k"] += 1
			tk["side"] = -tk["side"]
			var was: Vector2 = f["body"].position
			var at: Vector2 = _fighters[j]["body"].position + Vector2(16.0 * tk["side"], 2.0)
			var floor_rect: Rect2 = ARENAS[_arena]["floor"]
			f["body"].position = at.clamp(floor_rect.position, floor_rect.end)
			f["facing"] = _facing_of(_fighters[j]["body"].position - f["body"].position)
			_effects.append({"kind": "arrow", "from": was + Vector2(0, -10), "to": f["body"].position + Vector2(0, -10), "t": 0.0})
			_effects.append({"kind": "flash", "pos": was + Vector2(0, -10), "t": 0.2})
			_effects.append({"kind": "tele", "pos": was + Vector2(0, -10), "t": 0.0})
			_effects.append({"kind": "claw", "pos": _fighters[j]["body"].position + Vector2(0, -8), "dir": Vector2(-tk["side"], 0), "t": 0.0})
			_hurt(j, tk["dmg"], Vector2(-tk["side"] * 0.3, 0), i)
			_play("res://assets/audio/sfx/stormlantern/crack.wav", -14.0)
	if tk["t"] <= 0.0:
		# Land where you chose: beside a marked enemy or object, or beside the target.
		var land: Array = tk["land"]
		var spot: Vector2 = f["body"].position
		if land[0] == "f" and land[1] >= 0 and land[1] < _fighters.size() and _fighters[land[1]]["hp"] > 0:
			var tp: Vector2 = _fighters[land[1]]["body"].position
			spot = tp + (f["body"].position - tp).normalized() * 22.0 if f["body"].position.distance_to(tp) > 1.0 else tp + Vector2(22, 0)
		elif land[0] == "r" and land[1] >= 0 and land[1] < _rocks.size():
			var r: Dictionary = _rocks[land[1]]
			spot = r["pos"] + Vector2(0, r["rx"] * 0.45 + 10.0)
		var floor_rect2: Rect2 = ARENAS[_arena]["floor"]
		spot = spot.clamp(floor_rect2.position, floor_rect2.end)
		if _blocked(spot):
			spot = f["body"].position
		_effects.append({"kind": "arrow", "from": f["body"].position + Vector2(0, -10), "to": spot + Vector2(0, -10), "t": 0.0})
		_effects.append({"kind": "flash", "pos": spot + Vector2(0, -10), "t": 0.1})
		_effects.append({"kind": "tele", "pos": spot + Vector2(0, -10), "t": 0.0})
		f["body"].position = spot
		f["tackle"] = {}
		f["disengage"] = 0.3
		_play("res://assets/audio/sfx/stormlantern/throw.wav", -10.0)


## A big hit carries fighter i along `push` for a moment (see _update_carry).
func _carry(i: int, push: Vector2, by: int) -> void:
	var f: Dictionary = _fighters[i]
	if f["passive"] == "rampart" or f["guard"] > 0.0 or f["cocoon"] > 0.0 or f["hp"] <= 0:
		return
	f["carry"] = push.normalized() * push.length() * CARRY_PER_PUSH / CARRY_SECONDS
	f["carry_t"] = CARRY_SECONDS
	f["carried_by"] = by


## A carried creature slides; if it runs into a rock, a root wall or the arena wall, it is
## slammed: slam damage (credited to whoever hit it), a short daze with stars, dust, and a
## crack mark on the wall or damage to the rock.
func _update_carry(i: int, delta: float) -> void:
	var f: Dictionary = _fighters[i]
	if f["carry_t"] <= 0.0 or f["hp"] <= 0:
		return
	f["carry_t"] -= delta
	var floor_rect: Rect2 = ARENAS[_arena]["floor"]
	var here: Vector2 = f["body"].position
	var next: Vector2 = here + f["carry"] * delta
	var rock := _rock_near(next, 3.0)
	var wall := -1
	for k in _walls.size():
		if _walls[k]["pos"].distance_to(next) < 8.0:
			wall = k
	if rock >= 0 or wall >= 0 or not floor_rect.has_point(next):
		f["carry_t"] = 0.0
		var contact: Vector2 = next.clamp(floor_rect.position, floor_rect.end)
		if rock >= 0:
			contact = _rocks[rock]["pos"] + (here - _rocks[rock]["pos"]).normalized() * _rocks[rock]["rx"]
			_hit_rock(rock, SLAM_DAMAGE * 2)
		elif wall >= 0:
			contact = _walls[wall]["pos"]
			_walls.remove_at(wall)
		else:
			_wall_marks.append(_jagged(contact, contact + f["carry"].normalized().orthogonal() * 10.0, 4, 2.0))
			_wall_marks.append(_jagged(contact, contact - f["carry"].normalized() * 6.0 + f["carry"].normalized().orthogonal() * -5.0, 3, 2.0))
			_rubble.queue_redraw()
		f["body"].position = here
		_burst(contact + Vector2(0, -6), Color("#f0e6d0"), Color("#7a6a52"), 16.0, false, "rock_dust")
		_hurt(i, SLAM_DAMAGE, Vector2.ZERO, f["carried_by"])
		_hitstop = maxf(_hitstop, HITSTOP_HEAVY)
		f["dazzle"] = maxf(f["dazzle"], SLAM_DAZE)
		_effects.append({"kind": "stars", "who": i, "t": 0.0})
		_label(i, "Slammed")
		_shake_by(7.0)
		_play("res://assets/audio/sfx/arena/wall_slam.wav", -2.0)
		return
	f["body"].position = next
	if int(f["carry_t"] * 40.0) % 3 == 0:
		_effects.append({"kind": "dust", "pos": next, "t": 0.0})


## Stormlantern's flash: every opponent on the field is paralysed.
func _on_signature_paralyze() -> void:
	for j in _fighters.size():
		if _enemies(_sig_user, j) and _fighters[j]["hp"] > 0:
			_fighters[j]["stun"] = STUN_SECONDS
			_label(j, "Paralyzed")


func _on_signature_landed(target: int, damage: int) -> void:
	var sig: String = LINES[_fighters[_sig_user]["line"]]["signature"]
	var pierce: bool = sig == "Undertow"   # jaws from below
	var d: float = damage * _fighters[_sig_user]["power"] * _essence_mult(MOVE_ESSENCE[sig], target)
	_hurt(target, int(round(d)), Vector2.ZERO, _sig_user, pierce)


## Whether fighters a and b are on opposite teams (-1, "no one", is nobody's enemy).
func _enemies(a: int, b: int) -> bool:
	return a >= 0 and b >= 0 and _fighters[a]["team"] != _fighters[b]["team"]


func _nearest_foe(i: int) -> int:
	var best := -1
	for j in _fighters.size():
		if _enemies(i, j) and _fighters[j]["hp"] > 0 and (best < 0 or \
				_fighters[j]["body"].position.distance_to(_fighters[i]["body"].position) < _fighters[best]["body"].position.distance_to(_fighters[i]["body"].position)):
			best = j
	return best


## Fighter i's current target, kept for half a second and then chosen again (-1 if no
## enemy is standing). Draft team tactics for Grok, by role: assassins pick off the
## weakest enemy in reach; tanks peel, going for the enemy nearest their most hurt
## teammate; skirmishers follow up on an enemy that cannot act; the rest take the nearest.
func _foe_of(i: int) -> int:
	var f: Dictionary = _fighters[i]
	if i == controlled and player_target >= 0:
		# Your order stands while that enemy is up.
		if _fighters[player_target]["hp"] > 0 and _enemies(i, player_target):
			f["target"] = player_target
			return player_target
		player_target = -1
	var t: int = f["target"]
	if t >= 0 and _fighters[t]["hp"] > 0 and f["retarget"] > 0.0:
		return t
	f["retarget"] = 0.5
	var me: Vector2 = f["body"].position
	var guard: Vector2 = me
	var lowest := 2.0
	for j in _fighters.size():
		var a: Dictionary = _fighters[j]
		if a["team"] == f["team"] and a["hp"] > 0 and float(a["hp"]) / a["max_hp"] < lowest:
			lowest = float(a["hp"]) / a["max_hp"]
			guard = a["body"].position
	var best := -1
	var best_score := INF
	for j in _fighters.size():
		var e: Dictionary = _fighters[j]
		if not _enemies(i, j) or e["hp"] <= 0:
			continue
		var d: float = e["body"].position.distance_to(me)
		var hp_k: float = float(e["hp"]) / e["max_hp"]
		var score := d
		match f["profile"]:
			"kite":
				score = d * 0.5 + 120.0 * hp_k + (200.0 if d > 160.0 else 0.0)
			"press":
				score = e["body"].position.distance_to(guard)
			"skirmish":
				var helpless: bool = e["stun"] > 0.0 or e["rooted"] > 0.0 or e["dazzle"] > 0.0
				score = d - (60.0 if helpless else 0.0) - 40.0 * (1.0 - hp_k)
		if j == t:
			score -= 15.0   # a little loyalty, so it does not flip between two close targets
		if score < best_score:
			best_score = score
			best = j
	f["target"] = best
	return best


## A team wins when the other has no one standing. If the last two fall together,
## `fallback` (a team) takes it.
func _check_winner(fallback: int) -> void:
	var alive := [false, false]
	for f in _fighters:
		if f["hp"] > 0:
			alive[f["team"]] = true
	if alive[0] and alive[1]:
		return
	_winner = fallback if alive[0] == alive[1] else (0 if alive[0] else 1)


# ---------------------------------------------------------------- per-frame state

func _update_fighter(i: int, delta: float) -> void:
	var f: Dictionary = _fighters[i]
	# Creatures turn to face their target while they stand.
	f["shiver"] = Vector2.ZERO
	if f["walk"] == 0.0 and f["hp"] > 0 and f["stun"] <= 0.0 and f["target"] >= 0 and f["windup"].is_empty():
		var to_other: Vector2 = _fighters[f["target"]]["body"].position - f["body"].position
		if to_other.length() > 1.0:
			f["facing"] = _facing_of(to_other)
	f["flash"] = maxf(0.0, f["flash"] - delta)
	f["phase"] = maxf(0.0, f["phase"] - delta)
	f["stun"] = maxf(0.0, f["stun"] - delta)
	f["dazzle"] = maxf(0.0, f["dazzle"] - delta)
	f["rooted"] = maxf(0.0, f["rooted"] - delta)
	f["eroded"] = maxf(0.0, f["eroded"] - delta)
	f["crippled"] = maxf(0.0, f["crippled"] - delta)
	f["invuln"] = maxf(0.0, f["invuln"] - delta)
	f["marked"] = maxf(0.0, f["marked"] - delta)
	f["ambush"] = maxf(0.0, f["ambush"] - delta)
	f["guard"] = maxf(0.0, f["guard"] - delta)
	f["charged"] = maxf(0.0, f["charged"] - delta)
	f["haste"] = maxf(0.0, f["haste"] - delta)
	if f["shield"] > 0:
		f["shield_t"] -= delta
		if f["shield_t"] <= 0.0:
			f["shield"] = 0
	if f["cocoon"] > 0.0 and not _sig.active:
		f["cocoon"] -= delta
		if f["cocoon"] <= 0.0 and f["hp"] > 0:
			# The cocoon bursts: the slabs fly outward as shrapnel into everyone round it.
			for j in _fighters.size():
				var o: Dictionary = _fighters[j]
				if _enemies(i, j) and o["hp"] > 0 and o["body"].position.distance_to(f["body"].position) < COCOON_RADIUS:
					var away: Vector2 = (o["body"].position - f["body"].position).normalized()
					_hurt(j, f["cocoon_dmg"], away * 1.5, i)
					_burst(o["body"].position + Vector2(0, -8), Color("#afe8b8"), Color("#206349"), 12.0, false, "rock_dust")
			_effects.append({"kind": "shrapnel", "pos": f["body"].position, "t": 0.0})
			_label(i, "Burst")
			_play("res://assets/audio/sfx/arena/rock_break.wav", -8.0)
			_shake_by(4.0)
	if f["passive"] == "bound_slabs" and f["slabs"] < SLAB_COUNT and f["hp"] > 0:
		f["slab_t"] -= delta
		if f["slab_t"] <= 0.0:
			# The Kingstone's pull gathers a new slab to the hip.
			f["slabs"] += 1
			f["slab_t"] = SLAB_REFORM
			_effects.append({"kind": "burst", "pos": f["body"].position + Vector2(0, -12), "core": Color("#7cf5b8"), "rim": Color("#206349"), "size": 8.0, "t": 0.0, "bits": [Vector2(14, -14), Vector2(-14, -14)]})
	if f["ring"] != null and f["team"] == 0:
		f["ring"].default_color = YOU_RING if i == controlled else TEAM_RING[0]
	if not (_sig.active and _sig.effect_time() < 0.0):
		_update_carry(i, delta)
		_update_ram(i, delta)
		_update_tackle(i, delta)
	if f["passive"] == "kiln" and f["hp"] > 0:
		# Kiln Heat: the crater heats while it stands, and cools a little while it walks.
		f["heat"] = clampf(f["heat"] + (KILN_PER_SECOND * (2.0 if f["guard"] > 0.0 else 1.0) if f["walk"] == 0.0 else -KILN_PER_SECOND * 0.5) * delta, 0.0, 100.0)
	if f["passive"] in ["stoke", "kiln"] and f["hp"] > 0 and f["heat"] >= 50.0 and randf() < (0.08 if f["heat"] < 100.0 else 0.25):
		# Hot vents shed embers; at full heat they stream.
		_effects.append({"kind": "ember", "pos": f["body"].position + Vector2(randf_range(-6, 6), -20 - 3 * f["stage"]), "vel": Vector2(randf_range(-3, 3), -14), "t": 0.0})
	if f["sink"] > 0.0:
		f["sink"] -= delta
		if f["sink"] <= 0.0:
			f["body"].position = f["sink_to"]
			f["hidden"] = false
			f["solid"] = maxf(f["solid"], SURFACE_ON_ATTACK)
	if f["smoulder"] > 0.0 and f["hp"] > 0 and not _sig.active:
		f["smoulder"] -= delta
		f["smoulder_tick"] -= delta
		if f["smoulder_tick"] <= 0.0:
			f["smoulder_tick"] = SMOULDER_TICK
			_hurt(i, maxi(1, int(round(SMOULDER_DAMAGE * _essence_mult(MOVE_ESSENCE["smoulder"], i)))), Vector2.ZERO, -1)
			f["flash"] = 0.0
			_effects.append({"kind": "ember", "pos": f["body"].position + Vector2(randf_range(-5, 5), -12), "vel": Vector2(randf_range(-4, 4), -12), "t": 0.0})
	if f["glassed"] > 0.0 and f["hp"] > 0 and not _sig.active:
		# Glassed: the molten glass burns while it clings, then sets hard for a moment.
		f["glassed"] -= delta
		f["glassed_tick"] -= delta
		if f["glassed_tick"] <= 0.0:
			f["glassed_tick"] = GLASSED_TICK
			_hurt(i, maxi(1, int(round(GLASSED_BURN * _essence_mult(E.EMBER, i)))), Vector2.ZERO, -1)
			f["flash"] = 0.0
			_effects.append({"kind": "ember", "pos": f["body"].position + Vector2(randf_range(-6, 6), -10), "vel": Vector2(randf_range(-3, 3), -10), "t": 0.0})
		if f["glassed"] <= 0.0 and f["hp"] > 0:
			f["stun"] = maxf(f["stun"], GLASSED_SET)
			_label(i, "Set")
			_burst(f["body"].position + Vector2(0, -8), Color("#ffe8c0"), Color("#7a4a2a"), 10.0, false, "glass_splash")
	f["sprite"].visible = not f["hidden"]
	var sprite: Sprite2D = f["sprite"]
	var frames: Array = f["art"]["walk"][f["facing"]]
	sprite.position = Vector2.ZERO
	if f["walk"] > 0.0 and not frames.is_empty():
		sprite.texture = frames[int(f["walk"] * WALK_FPS * f["speed"]) % frames.size()]
	else:
		sprite.texture = f["art"]["still"][f["facing"]]
		if f["walk"] > 0.0:
			sprite.position.y = -float(int(f["walk"] * 8.0) % 2)
	if f["hp"] <= 0:
		f["down"] += delta
		sprite.modulate = Color(1, 1, 1, maxf(0.35, 1.0 - f["down"]))
		sprite.rotation = minf(PI / 2.0, f["down"] * 4.0) * (1.0 if f["team"] == 0 else -1.0)
	else:
		sprite.rotation = 0.0
		if f["invuln"] > 0.0 and int(f["invuln"] * 30) % 2 == 0:
			# Invulnerable: a lantern-light shimmer.
			sprite.modulate = Color(1.8, 1.7, 1.2, 0.85)
		elif f["flash"] > 0.0 and int(f["flash"] * 30) % 2 == 0:
			sprite.modulate = Color(3, 3, 3)
		elif f["stun"] > 0.0:
			# Paralysed: flickers electric blue-white and trembles.
			# (Toned down 2026-10-08: the old 1.6x washed pale creatures like Starward to pure white.)
			sprite.modulate = Color(1.25, 1.25, 1.7) if int(f["stun"] * 20) % 2 == 0 else Color(0.8, 0.85, 1.2)
			sprite.position.x = float(int(f["stun"] * 40) % 2)
		elif f["glassed"] > 0.0:
			# Glassed: amber molten glass over it, with a passing shine.
			sprite.modulate = Color(1.6, 1.3, 0.9) if int(f["glassed"] * 6) % 3 == 0 else Color(1.3, 0.85, 0.55)
		elif f["cocoon"] > 0.0:
			# Cocooned: dim behind the pulled-tight slabs.
			sprite.modulate = Color(0.75, 0.9, 0.82)
		elif f["guard"] > 0.0:
			# Guarding: the shell runs molten.
			sprite.modulate = Color(1.3, 1.05, 0.85) if int(f["guard"] * 10) % 2 == 0 else Color(1.15, 0.95, 0.8)
		else:
			sprite.modulate = Color.WHITE
	if f["hollow"]:
		_update_hollow(f, delta)
	if f["lantern"]:
		_update_lantern(f, delta)
	f["body"].z_index = int(f["body"].position.y)
	sprite.global_position = sprite.global_position.round()


## Absence: the form floats a few pixels up, bobbing slowly; more of it goes missing while
## it moves and nearly all of it while it phases; it sheds silt and leaves echoes.
func _update_hollow(f: Dictionary, delta: float) -> void:
	var sprite: Sprite2D = f["sprite"]
	sprite.position.y = -3.0 - round(sin(_crowd_t * 2.4) * 1.5)
	var moving: bool = f["walk"] > 0.0
	f["solid"] = maxf(0.0, f["solid"] - delta)
	f["surface_in"] -= delta
	if f["surface_in"] <= 0.0:
		f["surface_in"] = SURFACE_EVERY
		f["solid"] = maxf(f["solid"], SURFACE_FOR)
	var target := 0.3
	if moving:
		target = 0.38
	if f["solid"] > 0.0:
		target = 0.0
	if f["phase"] > 0.0:
		target = 0.82
	f["absence"] = move_toward(f["absence"], target, delta * (3.0 if f["phase"] > 0.0 else 1.2))
	var mat: ShaderMaterial = sprite.material
	mat.set_shader_parameter("time_s", _crowd_t)
	mat.set_shader_parameter("absence", f["absence"])
	f["echo"] -= delta
	if (moving or f["phase"] > 0.0) and f["solid"] <= 0.0 and f["echo"] <= 0.0 and f["hp"] > 0:
		f["echo"] = 0.1
		var at: Vector2 = f["body"].position + sprite.position + sprite.offset
		_effects.append({"kind": "echo", "tex": sprite.texture, "pos": at, "t": 0.0})
		for k in 3:
			var edge := Vector2(randf_range(-14, 14), randf_range(-22, -2))
			_effects.append({"kind": "silt", "pos": f["body"].position + edge, "vel": Vector2(randf_range(-6, 6), randf_range(4, 14)), "t": 0.0})


## The storm lantern: embers drip from it (more as it charges, and a trail while running),
## and every so often lightning arcs from the lantern to the crest.
func _update_lantern(f: Dictionary, delta: float) -> void:
	if f["hp"] <= 0:
		return
	var lamp := _lantern_point(f)
	f["ember"] -= delta
	if f["ember"] <= 0.0:
		f["ember"] = 0.18 - 0.1 * f["charge"] / 100.0
		_effects.append({"kind": "ember", "pos": lamp + Vector2(randf_range(-2, 2), 2), "vel": Vector2(randf_range(-5, 5), randf_range(-14, -4)), "t": 0.0})
		if f["walk"] > 0.0:
			_effects.append({"kind": "ember", "pos": f["body"].position + Vector2(randf_range(-4, 4), -1), "vel": Vector2(0, -3), "t": 0.0})
	f["arc"] -= delta
	if f["arc"] <= 0.0:
		var charged: bool = f["charge"] >= 100.0
		f["arc"] = randf_range(0.25, 0.5) if charged else randf_range(0.7, 1.5)
		var crest: Vector2 = f["body"].position + Vector2(-(lamp.x - f["body"].position.x) * 0.9, -27)
		f["arc_pts"] = _jagged(lamp, crest, 5, 3.0)
		f["arc_t"] = 0.12


func _lantern_point(f: Dictionary) -> Vector2:
	return f["body"].position + LANTERN.get(f["facing"], Vector2(0, -22)) + f["sprite"].position


func _jagged(a: Vector2, b: Vector2, steps: int, wobble: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for k in steps + 1:
		var p := a.lerp(b, float(k) / steps)
		if k > 0 and k < steps:
			p += (b - a).normalized().orthogonal() * randf_range(-wobble, wobble)
		pts.append(p.round())
	return pts


func _facing_of(dir: Vector2) -> String:
	return FACINGS[int(round(fposmod(dir.angle(), TAU) / (TAU / 8.0))) % 8]


func _label(i: int, text: String) -> void:
	# Names over the same creature stack upward instead of printing on top of each other.
	var slot := 0
	for l in _labels:
		if l["who"] == i:
			slot = maxi(slot, l["slot"] + 1)
	_labels.append({"who": i, "text": text.to_upper(), "t": 0.0, "slot": slot % 3})


# ---------------------------------------------------------------- effects

func _update_effects(delta: float) -> void:
	var keep: Array[Dictionary] = []
	var floor_rect: Rect2 = ARENAS[_arena]["floor"]
	for e in _effects:
		match e["kind"]:
			"fireball":
				e["trail"].append(e["pos"])
				if e["trail"].size() > 12:
					e["trail"].pop_front()
				e["pos"] += e["vel"] * delta
				e["life"] -= delta
				var hit := _hit_at(e["pos"], 10.0, e["owner"])
				var wall := _wall_at(e["pos"])
				if wall >= 0:
					_walls.remove_at(wall)   # the shot breaks one root pillar
				var rock := _rock_at(e["pos"]) if hit < 0 else -1
				if e.get("mark", false):
					# A lantern ball: it marks what it touches, bounces off objects and the arena
					# edge like a ping-pong ball (a few times), and ends only on a creature or when it dies.
					if rock >= 0:
						_rocks[rock]["marked"] = MARK_SECONDS
						_rocks[rock]["node"].queue_redraw()
						var away: Vector2 = (e["pos"] - (_rocks[rock]["pos"] + Vector2(0, -_rocks[rock]["h"] * 0.45))).normalized()
						e["vel"] = e["vel"].bounce(-away) if e["vel"].dot(away) < 0.0 else e["vel"]
						e["pos"] += away * 4.0
						rock = -1
					var edge: Rect2 = floor_rect.grow(6)
					if e["bounce"] > 0 and not edge.has_point(e["pos"]):
						if e["pos"].x < edge.position.x or e["pos"].x > edge.end.x:
							e["vel"].x = -e["vel"].x
						if e["pos"].y < edge.position.y or e["pos"].y > edge.end.y:
							e["vel"].y = -e["vel"].y
						e["pos"] = e["pos"].clamp(edge.position, edge.end)
						e["bounce"] -= 1
						_effects.append({"kind": "dust", "pos": e["pos"], "t": 0.0})
						_play("res://assets/audio/sfx/ui/cursor.wav", -16.0)
					if hit >= 0:
						_fighters[hit]["marked"] = MARK_SECONDS
						_label(hit, "Marked")
				elif rock >= 0:
					_hit_rock(rock, e["damage"])   # rocks take shots meant for whoever hides behind them
				if hit >= 0 or wall >= 0 or rock >= 0 or e["life"] <= 0.0 or not floor_rect.grow(20).has_point(e["pos"]):
					if e.get("jade", false):
						_burst(e["pos"], Color("#afe8b8"), Color("#206349"), 20.0, false, "rock_dust")
					else:
						_burst(e["pos"], Color("#ffb347"), Color("#ff5a1f"), 26.0, true, "fire_burst")
					if hit >= 0:
						_hurt(hit, e["damage"], e["vel"].normalized(), e["owner"])
					continue
			"beam":
				e["len"] = minf(e.get("reach", 90.0), e["len"] + 520.0 * delta)
				e["life"] -= delta
				var tip: Vector2 = e["from"] + e["dir"] * e["len"]
				# A root pillar in the way stops the beam there.
				for w in _walls:
					var q: Vector2 = w["pos"] + Vector2(0, -8)
					if Geometry2D.get_closest_point_to_segment(q, e["from"], tip).distance_to(q) < 5.0:
						e["len"] = minf(e["len"], e["from"].distance_to(q))
						tip = e["from"] + e["dir"] * e["len"]
				# So does a rock, which takes the beam's damage once.
				var rock := _rock_on_line(e["from"], tip)
				if rock >= 0:
					e["len"] = minf(e["len"], e["from"].distance_to(_rocks[rock]["pos"] + Vector2(0, -_rocks[rock]["h"] * 0.45)) - _rocks[rock]["rx"] * 0.6)
					tip = e["from"] + e["dir"] * e["len"]
					if not e.has("hit"):
						e["hit"] = true
						_burst(tip, Color("#e8fbff"), Color("#5ec8ff"), 14.0, false)
						_hit_rock(rock, e["damage"])
				var hit := _hit_along(e["from"], tip, 8.0, e["owner"])
				if hit >= 0 and not e.has("hit"):
					e["hit"] = true
					_hurt(hit, e["damage"], e["dir"] * e.get("push", 1.0), e["owner"])
					if e.get("molten", false):
						_burst(_fighters[hit]["body"].position + Vector2(0, -8), Color("#fff1b0"), Color("#ff6a1a"), 20.0, false, "glass_splash")
					else:
						_burst(_fighters[hit]["body"].position + Vector2(0, -8), Color("#e8fbff"), Color("#5ec8ff"), 20.0, false, "water_burst")
				if e["life"] <= 0.0:
					continue
			"seed":
				e["t"] += delta / 0.5
				if e["t"] >= 1.0:
					if e.get("molten", false):
						_burst(e["to"], Color("#ffe6a0"), Color("#ff6a1a"), 30.0, true, "glass_splash")
					else:
						_burst(e["to"], Color("#b7e07a"), Color("#7a5a32"), 28.0, true, "earth_burst")
					var hit := _hit_at(e["to"], 18.0, e["owner"])
					if hit >= 0:
						_hurt(hit, e["damage"], (e["to"] - e["from"]).normalized() * e.get("push", 1.0), e["owner"])
					continue
			"fire_patch":
				# Flare Step's embers burn anyone standing in them, a little at a time.
				e["t"] += delta
				e["tick"] -= delta
				if e["tick"] <= 0.0:
					e["tick"] = 0.35
					var hit := _hit_at(e["pos"] + Vector2(0, -6), 9.0, e["owner"])
					if hit >= 0:
						_hurt(hit, e["damage"], Vector2.ZERO, e["owner"])
				if e["t"] > 1.6:
					continue
			"burst", "flash":
				e["t"] += delta
				if e["t"] > 0.45:
					continue
			"tele":
				e["t"] += delta
				if e["t"] > 0.4:
					continue
			"bolt", "claw", "streak":
				e["t"] += delta
				if e["t"] > (0.3 if e["kind"] == "streak" else 0.25):
					continue
			"arrow":
				e["t"] += delta
				if e["t"] > 0.2:
					continue
			"snare":
				e["t"] += delta
				if e["t"] > ROOT_SECONDS:
					continue
			"dust", "echo":
				e["t"] += delta
				if e["t"] > 0.4:
					continue
			"silt", "ember":
				e["t"] += delta
				e["pos"] += e["vel"] * delta
				if e["kind"] == "ember":
					e["vel"].y += 30.0 * delta
				if e["t"] > 0.7:
					continue
			"scorch", "cracks":
				e["t"] += delta
				if e["t"] > 4.0:
					continue
			"ring":
				e["t"] += delta
				if e["t"] > 0.35:
					continue
			"impact":
				e["t"] += delta
				if e["t"] > IMPACT_SECONDS:
					continue
			"whirl":
				e["t"] += delta
				if e["t"] > 0.6:
					continue
			"riptide":
				e["t"] += delta
				# The current drags anyone inside toward its centre.
				for j in _fighters.size():
					if _enemies(e["owner"], j) and _fighters[j]["hp"] > 0 and _fighters[j]["body"].position.distance_to(e["pos"]) < RIPTIDE_RADIUS:
						var pull: Vector2 = (e["pos"] - _fighters[j]["body"].position) * 1.5 * delta
						if not _blocked(_fighters[j]["body"].position + pull):
							_fighters[j]["body"].position += pull
				if e["t"] > RIPTIDE_SECONDS:
					continue
			"smoke":
				e["t"] += delta
				if e["t"] > 0.0:
					e["pos"] += e["vel"] * delta
					e["vel"] *= 0.97
					e["vel"].x += randf_range(-4.0, 4.0) * delta
				if e["t"] > e["life"]:
					continue
			"flame":
				e["t"] += delta
				if e["t"] > 2.6:
					continue
			"chunk":
				# A flying piece of rock; where it lands it stays as rubble.
				e["t"] += delta
				e["pos"] += e["vel"] * delta
				e["vel"] *= 0.98
				e["h"] += e["vh"] * delta
				e["vh"] -= 300.0 * delta
				if e["h"] <= 0.0:
					if floor_rect.has_point(e["pos"]):
						_rubble_bits.append({"pos": e["pos"].round(), "pts": e["pts"], "c": e["c"]})
						_rubble.queue_redraw()
						_effects.append({"kind": "dust", "pos": e["pos"], "t": 0.0})
					continue
			"stars":
				e["t"] += delta
				if e["t"] > SLAM_DAZE:
					continue
			"rootrun":
				e["t"] += delta
				if e["t"] >= RAMPART_RUN:
					# Arrival: the eruption.
					_burst(e["to"], Color("#d8f0a0"), Color("#5a3f22"), 30.0, false, "root_burst")
					var hit := _hit_at(e["to"], 20.0, e["owner"])
					if hit >= 0:
						_hurt(hit, e["damage"], Vector2.ZERO, e["owner"])
						_fighters[hit]["rooted"] = maxf(_fighters[hit]["rooted"], 0.8)
						_effects.append({"kind": "snare", "who": hit, "t": 0.0})
						_label(hit, "Rooted")
					for k in 6:
						var a := k * TAU / 6.0 + 0.5
						_walls.append({"pos": (e["to"] + Vector2(cos(a) * 20.0, sin(a) * 10.0)).round(), "t": WALL_SECONDS - RAMPART_PILLARS, "owner": e["owner"]})
					_shake_by(5.0)
					_play("res://assets/audio/sfx/root_rampart/eruption.wav", -6.0)
					continue
			"vines":
				e["t"] += delta
				if e["t"] > VINES_SECONDS:
					continue
			"geyser":
				e["t"] += delta
				if e["t"] > 0.7:
					continue
			"guard":
				e["t"] += delta
				if _fighters[e["who"]]["guard"] <= 0.0 or _fighters[e["who"]]["hp"] <= 0:
					continue
			"spikes":
				e["t"] += delta
				if e["t"] > 0.8:
					continue
			"vortex", "shrapnel":
				e["t"] += delta
				if e["t"] > 0.5:
					continue
			"rail_beam":
				e["t"] += delta
				if e["t"] > 0.3:
					continue
			"shards":
				e["t"] += delta
				if e["t"] > SHARDS_SECONDS:
					continue
			"star_field":
				e["t"] += delta
				e["tick"] -= delta
				if e["tick"] <= 0.0:
					e["tick"] = HAZARD_TICK
					for j in _fighters.size():
						var f: Dictionary = _fighters[j]
						if f["team"] == _fighters[e["owner"]]["team"] and f["hp"] > 0 and f["hp"] < f["max_hp"] and f["body"].position.distance_to(e["pos"]) < STAR_FIELD_RADIUS:
							f["hp"] = mini(f["max_hp"], f["hp"] + STAR_FIELD_HEAL)
							_effects.append({"kind": "burst", "pos": f["body"].position + Vector2(randf_range(-6, 6), -14), "core": Color("#ffd6ef"), "rim": Color("#ff7ad0"), "size": 3.0, "t": 0.0, "bits": [Vector2(0, -16)]})
				if e["t"] > STAR_FIELD_SECONDS:
					continue
			"glass_pool", "lava_seam":
				e["t"] += delta
				e["tick"] -= delta
				if e["tick"] <= 0.0:
					e["tick"] = HAZARD_TICK
					for j in _fighters.size():
						var f: Dictionary = _fighters[j]
						if not _enemies(e["owner"], j) or f["hp"] <= 0:
							continue   # terrain only ever hurts the enemy
						var inside: bool = f["body"].position.distance_to(e["pos"]) < e.get("r", POOL_RADIUS) if e["kind"] == "glass_pool" else _near_seam(e["pts"], f["body"].position) < SEAM_WIDTH
						if inside and e["kind"] == "glass_pool":
							_glass(j, POOL_GLASS)   # standing in the glass keeps it molten on you
						elif inside:
							_hurt(j, maxi(1, int(round(HAZARD_BURN * _essence_mult(E.EMBER, j)))), Vector2.ZERO, e["owner"])
							f["flash"] = 0.0
							_effects.append({"kind": "ember", "pos": f["body"].position + Vector2(randf_range(-5, 5), -10), "vel": Vector2(randf_range(-4, 4), -14), "t": 0.0})
				if e["t"] > (POOL_SECONDS if e["kind"] == "glass_pool" else SEAM_SECONDS):
					continue
		keep.append(e)
	for r in _rocks:
		r["marked"] = maxf(0.0, r["marked"] - delta)
		if r["flash"] > 0.0:
			r["flash"] = maxf(0.0, r["flash"] - delta)
			r["node"].queue_redraw()
	_effects = keep
	var standing: Array[Dictionary] = []
	for w in _walls:
		w["t"] += delta
		if w["t"] < WALL_SECONDS:
			standing.append(w)
	_walls = standing
	var live: Array[Dictionary] = []
	for l in _labels:
		l["t"] += delta
		if l["t"] < 0.9:
			live.append(l)
	_labels = live
	for f in _fighters:
		if f.has("arc_t"):
			f["arc_t"] = maxf(0.0, f["arc_t"] - delta)


## An impact in the reference's style: a white flash, a thin shock ring, sparks and speed
## lines; big ones also crack the floor, leave a scorch with small flames, and throw up a
## plume of chunky smoke that rises and lingers.
func _burst(at: Vector2, core: Color, rim: Color, size: float, scorch: bool, anim := "") -> void:
	if anim != "":
		_effects.append({"kind": "impact", "anim": anim, "pos": at, "t": 0.0})
	var bits := []
	for k in 18:
		bits.append(Vector2.RIGHT.rotated(randf() * TAU) * randf_range(30.0, 90.0))
	_effects.append({"kind": "burst", "pos": at, "core": core, "rim": rim, "size": size, "t": 0.0, "bits": bits})
	var lines := []
	for k in 10:
		lines.append(randf() * TAU)
	_effects.append({"kind": "ring", "pos": at, "size": size, "t": 0.0, "lines": lines, "rim": rim})
	# A plume: puffs released over half a second, each rising, swelling and thinning, so
	# together they climb into a column like the reference's smoke and steam.
	# Kept thin (Preston, 2026-10-07): the plume must never hide the creature under it.
	var puffs: int = int(size / 5.0) if scorch else 2
	for k in puffs:
		_effects.append({"kind": "smoke", "pos": at + Vector2(randf_range(-5, 5), randf_range(-3, 2)),
			"vel": Vector2(randf_range(-8, 8), randf_range(-48, -30)), "size": randf_range(2.0, 3.5) + size * 0.04,
			"t": -k * 0.05 - randf_range(0.0, 0.05), "life": randf_range(0.6, 1.1), "warm": scorch and rim.r > 0.8})
	if scorch:
		_effects.append({"kind": "scorch", "pos": at, "size": size * 0.45, "t": 0.0})
		var cracks := []
		for k in 5:
			cracks.append(_jagged(at, at + Vector2.RIGHT.rotated(randf() * TAU) * Vector2(1.0, 0.5) * randf_range(size * 0.5, size * 0.9), 4, 2.0))
		_effects.append({"kind": "cracks", "lines": cracks, "t": 0.0})
		if rim.r > 0.8 and rim.g < 0.6:
			for k in 3:
				_effects.append({"kind": "flame", "pos": at + Vector2(randf_range(-6, 6), randf_range(-3, 3)), "t": -k * 0.1})
	_shake_by(4.0)


## A chunky fire blob as in the reference: dark red rim, orange body, yellow-white core.
func _blob(at: Vector2, r: float, a := 1.0) -> void:
	_fx.draw_circle(at.round(), r + 1.0, Color(0.55, 0.12, 0.05, a))
	_fx.draw_circle(at.round(), r, Color(1.0, 0.45, 0.12, a))
	_fx.draw_circle((at + Vector2(-r * 0.25, -r * 0.25)).round(), r * 0.55, Color(1.0, 0.85, 0.35, a))
	if r >= 3.0:
		_fx.draw_circle((at + Vector2(-r * 0.3, -r * 0.3)).round(), r * 0.25, Color(1, 1, 0.85, a))


func _hit_at(p: Vector2, radius: float, owner: int) -> int:
	for i in _fighters.size():
		if _enemies(owner, i) and _fighters[i]["hp"] > 0 and _fighters[i]["phase"] <= 0.0 and _fighters[i]["invuln"] <= 0.0 and (_fighters[i]["body"].position + Vector2(0, -6)).distance_to(p) < radius:
			return i
	return -1


func _hit_along(a: Vector2, b: Vector2, radius: float, owner: int) -> int:
	for i in _fighters.size():
		var c: Vector2 = _fighters[i]["body"].position + Vector2(0, -6)
		if _enemies(owner, i) and _fighters[i]["hp"] > 0 and _fighters[i]["phase"] <= 0.0 and _fighters[i]["invuln"] <= 0.0 and Geometry2D.get_closest_point_to_segment(c, a, b).distance_to(c) < radius:
			return i
	return -1


func _hurt(i: int, damage: int, push: Vector2, by: int, pierce := false) -> void:
	var f: Dictionary = _fighters[i]
	if f["hp"] <= 0 or damage <= 0 or f["hidden"] or f["invuln"] > 0.0 or (f["phase"] > 0.0 and not pierce):
		return   # absent, hidden or invulnerable: nothing lands (Undertow's jaws from below still do)
	if f["slabs"] > 0 and by >= 0 and by != i and not pierce and damage >= SLAB_MIN_HIT:
		# Bound Slabs: a floating jade slab takes the blow and shatters; it re-forms in time.
		f["slabs"] -= 1
		if f["slab_t"] <= 0.0:
			f["slab_t"] = SLAB_REFORM
		f["flash"] = 0.15
		_label(i, "Slab")
		_burst(f["body"].position + Vector2(0, -12), Color("#afe8b8"), Color("#206349"), 14.0, false, "rock_dust")
		_play("res://assets/audio/sfx/arena/rock_crack.wav", -8.0)
		_hitstop = maxf(_hitstop, HITSTOP_LIGHT)
		return
	if f["eroded"] > 0.0:
		damage = int(round(damage * ERODE_EXTRA))
		pierce = true   # eroded: its damage reduction is gone
	if by >= 0 and by != i and _fighters[by]["passive"] == "absence":
		f["eroded"] = ERODE_SECONDS
	if f["passive"] == "rampart":
		push = Vector2.ZERO
		if not pierce and f["hp"] > f["max_hp"] / 2:
			damage = maxi(1, int(round(damage * RAMPART_GUARD)))
		# Thorns: whoever hit it from up close takes some back.
		if by >= 0 and by != i and not _sig.active and _fighters[by]["hp"] > 0 and _fighters[by]["invuln"] <= 0.0 and _fighters[by]["body"].position.distance_to(f["body"].position) < 32.0:
			var att: Dictionary = _fighters[by]
			att["hp"] = maxi(0, att["hp"] - THORNS)
			f["dealt"] += THORNS
			att["flash"] = 0.15
			_effects.append({"kind": "burst", "pos": att["body"].position + Vector2(0, -8), "core": Color("#a4e07a"), "rim": Color("#5a3f22"), "size": 8.0, "t": 0.0, "bits": [Vector2(20, -20), Vector2(-20, -20)]})
			if att["hp"] <= 0:
				att["down_at"] = _clock
				_check_winner(f["team"])
	if f["shield"] > 0:
		# A star shield takes the blow before anything else does.
		var absorbed: int = mini(damage, f["shield"])
		f["shield"] -= absorbed
		damage -= absorbed
		f["flash"] = 0.15
		if f["shield"] <= 0:
			_label(i, "Shield broke")
			_burst(f["body"].position + Vector2(0, -10), Color("#ffd6ef"), Color("#ff7ad0"), 12.0, false, "")
		if damage <= 0:
			return
	if by >= 0 and by != i and f["passive"] != "guardian":
		# Guardian: an ally beside a protector takes less.
		for j in _fighters.size():
			var gfr: Dictionary = _fighters[j]
			if j != i and gfr["team"] == f["team"] and gfr["hp"] > 0 and gfr["passive"] == "guardian" and gfr["body"].position.distance_to(f["body"].position) < GUARDIAN_RADIUS:
				damage = maxi(1, int(round(damage * GUARDIAN_CUT)))
				break
	if f["cocoon"] > 0.0:
		# Stone Cocoon: the slabs pulled tight take most of it, and nothing moves it.
		push = Vector2.ZERO
		if not pierce:
			damage = maxi(1, int(round(damage * COCOON_GUARD)))
	if f["guard"] > 0.0:
		# Glass Guard: planted and halved; molten glass splashes whoever strikes it up close.
		push = Vector2.ZERO
		if not pierce:
			damage = maxi(1, int(round(damage * GUARD_REDUCTION)))
		if by >= 0 and by != i and not _sig.active and _fighters[by]["hp"] > 0 and _fighters[by]["body"].position.distance_to(f["body"].position) < 32.0:
			_glass(by, GLASSED_SECONDS * 0.5)
	if by >= 0 and by != i:
		_fighters[by]["dealt"] += mini(damage, f["hp"])
		if _fighters[by]["passive"] == "stoke":
			_fighters[by]["heat"] = minf(100.0, _fighters[by]["heat"] + STOKE_PER_HIT)
		if f["passive"] == "kiln":
			f["heat"] = minf(100.0, f["heat"] + KILN_PER_HIT)   # the tank's kiln is stoked by the blow
	f["hp"] = maxi(0, f["hp"] - damage)
	f["flash"] = 0.3
	_hitstop = maxf(_hitstop, HITSTOP_HEAVY if damage >= 20 else HITSTOP_LIGHT)
	f["shiver"] = push.normalized() if push.length() > 0.01 else Vector2.RIGHT
	if f["final"]:
		f["meter"] = mini(100, f["meter"] + METER_TAKEN)
	if by >= 0 and by != i:
		if _fighters[by]["final"]:
			_fighters[by]["meter"] = mini(100, _fighters[by]["meter"] + METER_DEALT)
	if push.length() >= CARRY_FROM:
		_carry(i, push, by)
	else:
		var floor_rect: Rect2 = ARENAS[_arena]["floor"]
		var pushed: Vector2 = (f["body"].position + push * 8.0).clamp(floor_rect.position, floor_rect.end)
		if not _blocked(pushed):
			f["body"].position = pushed
	_shake_by(SHAKE_HIT)
	_cheer = maxf(_cheer, 0.6)
	_play("res://assets/audio/sfx/ui/hit_strong.wav" if damage >= 20 else "res://assets/audio/sfx/ui/hit.wav", -6.0)
	if f["hp"] <= 0:
		f["down_at"] = _clock
		_check_winner(1 - f["team"])
		_cheer = 3.0
		_play("res://assets/audio/sfx/ui/faint.wav", -4.0)


func _play(path: String, db: float) -> void:
	for p in _sounds:
		if not p.playing:
			p.stream = load(path)
			p.volume_db = db
			p.play()
			return


# ---------------------------------------------------------------- drawing

## The crowd shifts as people move; when it cheers, the stands bounce a pixel.
func _draw_crowd() -> void:
	var tick := int(_crowd_t * (14.0 if _cheer > 0.0 else 4.0))
	for k in _crowd_dots.size():
		var d: Dictionary = _crowd_dots[k]
		if (k + tick) % 3 == 0:
			_fx.draw_rect(Rect2(Vector2(d["p"]), Vector2(1, 1)), d["alt"])
	if _cheer > 0.0 and tick % 2 == 0:
		var stands: Rect2 = ARENAS[_arena]["stands"]
		_fx.draw_texture_rect_region(_map.texture, Rect2(stands.position + Vector2(0, -1), stands.size), stands)


func _draw_effects() -> void:
	_draw_crowd()
	for w in _walls:
		_draw_root_pillar(w)
	for e in _effects:
		if e["kind"] == "snare" and _fighters[e["who"]]["hp"] > 0:
			var at: Vector2 = _fighters[e["who"]]["body"].position
			var k: float = clampf(e["t"] / 0.15, 0.0, 1.0)
			for r in 6:
				var a := r * TAU / 6.0 + 0.4
				var base := at + Vector2(cos(a) * 9.0, sin(a) * 3.0)
				_fx.draw_line(base.round(), (base + Vector2(-cos(a) * 3.0, -9.0 * k)).round(), Color("#5a3f22"), 2.0)
				_fx.draw_rect(Rect2((base + Vector2(-cos(a) * 3.0, -9.0 * k)).round(), Vector2(1, 1)), Color("#a4e07a"))
	for f in _fighters:
		if f["hp"] <= 0:
			continue
		if f["hollow"]:
			_draw_scour(f["body"].position)
		if f["lantern"]:
			_draw_lantern_light(f)
		if f["passive"] == "bound_slabs":
			_draw_slabs(f)
		if f["shield"] > 0:
			_draw_star_shield(f)
	for i in _fighters.size():
		if not _fighters[i]["windup"].is_empty() and _fighters[i]["hp"] > 0:
			_draw_telegraph(i)
	_draw_target_marker()
	_draw_marks()
	for e in _effects:
		match e["kind"]:
			"scorch", "riptide", "whirl", "cracks", "fire_patch":
				pass   # ground marks: drawn on the floor layer under the creatures (_draw_ground)
			"flame":
				# Small fires left burning in a scorch: two flickering flame pixels-tall tongues.
				if e["t"] > 0.0:
					var life: float = clampf(1.0 - (e["t"] - 2.0) / 0.6, 0.0, 1.0)
					var h: float = (3.0 + 2.0 * float(int(e["t"] * 10.0 + e["pos"].x) % 2)) * life
					_fx.draw_rect(Rect2((e["pos"] + Vector2(-1, -h)).round(), Vector2(3, h)), Color(1, 0.45, 0.1, 0.9 * life))
					_fx.draw_rect(Rect2((e["pos"] + Vector2(0, -h + 1)).round(), Vector2(1, h - 1)), Color(1, 0.9, 0.4, life))
			"silt":
				var k: float = e["t"] / 0.7
				_fx.draw_rect(Rect2(e["pos"].round(), Vector2(1, 1)), Color(0.16, 0.2, 0.24, 0.9 * (1.0 - k)))
			"echo":
				var k: float = e["t"] / 0.4
				var tex: Texture2D = e["tex"]
				_fx.draw_texture(tex, (e["pos"] - tex.get_size() * 0.5).round(), Color(0.35, 0.75, 1.0, 0.3 * (1.0 - k)))
			"dust":
				var k: float = e["t"] / 0.4
				_fx.draw_circle(e["pos"].round(), 2.0 + 3.0 * k, Color(0.85, 0.8, 0.65, 0.5 * (1.0 - k)))
			"geyser":
				# A column of heat bursting from the floor under an enemy: the painted vent flame
				# over a coded column and a ring of embers.
				var kg: float = e["t"] / 0.7
				var hcol: float = 40.0 * minf(1.0, kg * 4.0) * (1.0 - kg * 0.5)
				_fx.draw_rect(Rect2((e["pos"] + Vector2(-6, -hcol)).round(), Vector2(12, hcol)), Color(1.0, 0.45, 0.1, 0.7 * (1.0 - kg)))
				_fx.draw_rect(Rect2((e["pos"] + Vector2(-2, -hcol)).round(), Vector2(4, hcol)), Color(1.0, 0.95, 0.7, 0.9 * (1.0 - kg)))
				_draw_sheet(_fx, "vent_flame", e["pos"] + Vector2(0, 6), e["t"], false, 0.7)
				for i in 8:
					var a := i * TAU / 8.0
					var d := Vector2(cos(a), sin(a) * 0.5) * (8.0 + 30.0 * kg)
					_fx.draw_rect(Rect2((e["pos"] + d).round(), Vector2(2, 2)), Color(1.0, 0.7, 0.3, 1.0 - kg))
			"rootrun":
				# Roots tearing along the ground toward the target: spikes rising in a line.
				var along: float = clampf(e["t"] / RAMPART_RUN, 0.0, 1.0)
				var n := int(along * 12.0)
				for k in n:
					var q: Vector2 = e["from"].lerp(e["to"], (k + 1) / 13.0)
					var h: float = 6.0 + 3.0 * (k % 3)
					_fx.draw_colored_polygon(PackedVector2Array([q.round() + Vector2(-3, 0), q.round() + Vector2(3, 0), q.round() + Vector2(0, -h)]), Color("#5a3f22"))
					_fx.draw_rect(Rect2(q.round() + Vector2(-1, -h), Vector2(2, 3)), Color("#8fd16a"))
					_fx.draw_rect(Rect2(q.round() + Vector2(-5, 0), Vector2(10, 2)), Color(0.2, 0.14, 0.08, 0.6))
			"tele":
				_draw_sheet(_fx, "lantern_flash", e["pos"] + Vector2(0, 10), e["t"], false, 0.4)
			"arrow":
				# An arrow of light between two teleport points: a bright shaft that fades.
				var k: float = e["t"] / 0.2
				_fx.draw_line(e["from"].round(), e["to"].round(), Color(1.0, 0.75, 0.3, 0.6 * (1.0 - k)), 4.0)
				_fx.draw_line(e["from"].round(), e["to"].round(), Color(1.0, 0.98, 0.85, 1.0 - k), 2.0)
				var head: Vector2 = e["to"]
				var d: Vector2 = (e["to"] - e["from"]).normalized()
				_fx.draw_colored_polygon(PackedVector2Array([head.round(), (head - d * 6.0 + d.orthogonal() * 3.0).round(), (head - d * 6.0 - d.orthogonal() * 3.0).round()]), Color(1.0, 0.98, 0.85, 1.0 - k))
			"chunk":
				# A flying shard: its shadow stays on the floor while it arcs.
				_fx.draw_set_transform(e["pos"].round(), 0.0, Vector2(1.0, 0.4))
				_fx.draw_circle(Vector2.ZERO, e["s"] * 0.8, Color(0, 0, 0, 0.25))
				_fx.draw_set_transform((e["pos"] + Vector2(0, -e["h"])).round(), e["spin"] * e["t"], Vector2.ONE)
				_draw_shard(_fx, e["pts"], e["c"])
				_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"stars":
				# Dazed: three little stars circling over its head.
				var f: Dictionary = _fighters[e["who"]]
				if f["hp"] > 0:
					var top: Vector2 = f["body"].position + Vector2(0, -26 - 4 * f["stage"])
					for s in 3:
						var a: float = e["t"] * 9.0 + s * TAU / 3.0
						var p: Vector2 = (top + Vector2(cos(a) * 8.0, sin(a) * 3.0)).round()
						_fx.draw_rect(Rect2(p - Vector2(1, 0), Vector2(3, 1)), Color("#ffe066"))
						_fx.draw_rect(Rect2(p - Vector2(0, 1), Vector2(1, 3)), Color("#fff6c0"))
	for f in _fighters:
		if f["lantern"] and f["hp"] > 0 and f.get("arc_t", 0.0) > 0.0:
			_fx.draw_polyline(f["arc_pts"], Color(0.45, 0.7, 1.0, 0.6), 3.0)    # current: electric blue-white
			_fx.draw_polyline(f["arc_pts"], Color(0.92, 0.97, 1.0), 1.0)
		if f["stun"] > 0.0 and f["hp"] > 0:
			# Paralysis: little bolts crackle around the body.
			var c: Vector2 = f["body"].position + Vector2(0, -10)
			for k in 3:
				var a := randf() * TAU
				_fx.draw_polyline(_jagged(c + Vector2.RIGHT.rotated(a) * 6.0, c + Vector2.RIGHT.rotated(a + 0.6) * 15.0, 3, 2.0), Color(1, 0.95, 0.5), 1.0)
		if f["eroded"] > 0.0 and f["hp"] > 0 and int(_crowd_t * 10.0) % 3 == 0:
			# Eroded by Hollow: specks of it crumbling away.
			_effects.append({"kind": "silt", "pos": f["body"].position + Vector2(randf_range(-8, 8), randf_range(-18, -4)), "vel": Vector2(randf_range(-5, 5), randf_range(3, 10)), "t": 0.0})
		if f["smoulder"] > 0.0 and f["hp"] > 0:
			# Smouldering from Wick Bolt's heat: little flames licking up its body.
			for k in 2:
				var p: Vector2 = f["body"].position + Vector2(-4 + k * 7, -6 - k * 5)
				var h := 3.0 + float(int(_crowd_t * 12.0 + k) % 2)
				_fx.draw_rect(Rect2((p + Vector2(0, -h)).round(), Vector2(2, h)), Color(1, 0.5, 0.1, 0.9))
				_fx.draw_rect(Rect2((p + Vector2(0, -h + 1)).round(), Vector2(1, h - 1)), Color(1, 0.9, 0.4))
		if f["dazzle"] > 0.0 and f["hp"] > 0:
			# Dazzled: sparkles circle its head.
			for k in 3:
				var a := _crowd_t * 6.0 + k * TAU / 3.0
				var p: Vector2 = f["body"].position + Vector2(cos(a) * 9.0, -24 + sin(a) * 3.0)
				_fx.draw_rect(Rect2(p.round(), Vector2(2, 2)), Color(1, 0.95, 0.6))
	for e in _effects:
		match e["kind"]:
			"ember":
				var k: float = e["t"] / 0.7
				_fx.draw_rect(Rect2(e["pos"].round(), Vector2(1, 1)), Color(1, 0.6 - 0.4 * k, 0.15, 1.0 - k))
			"claw":
				# Three raking claw marks across the target, over the painted light slash.
				_draw_sheet(_fx, "light_slash", e["pos"] + Vector2(0, 10), e["t"], false, 0.25)
				var k: float = e["t"] / 0.25
				var side: Vector2 = e["dir"].orthogonal()
				for c in 3:
					var o: Vector2 = side * (c - 1) * 4.0
					var a: Vector2 = (e["pos"] + o - e["dir"] * 8.0 + side * 6.0).round()
					var b: Vector2 = (e["pos"] + o + e["dir"] * 8.0 - side * 6.0).round()
					_fx.draw_line(a, b, Color(1, 0.4, 0.1, 1.0 - k), 3.0)       # red-hot claws
					_fx.draw_line(a, b, Color(1, 0.95, 0.75, 1.0 - k), 1.0)
					_fx.draw_rect(Rect2(b + side * randf_range(1, 4), Vector2(1, 1)), Color(1, 0.8, 0.3, 1.0 - k))
			"bolt":
				# A white-hot filament: orange heat haze, yellow glow, white core, and
				# blue-white electric crackle flicking off it.
				var w := 2.0 if e["big"] else 1.0
				_fx.draw_polyline(e["pts"], Color(1, 0.45, 0.1, 0.45), 5.0 * w)
				_fx.draw_polyline(e["pts"], Color(1, 0.85, 0.35), 3.0 * w)
				_fx.draw_polyline(e["pts"], Color(1, 1, 0.95), 1.0 * w)
				for k in range(1, e["pts"].size() - 1, 2):
					var p: Vector2 = e["pts"][k]
					var side := Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(3.0, 6.0)
					_fx.draw_line(p, (p + side).round(), Color(0.75, 0.9, 1.0), 1.0)
			"streak":
				# Flashstep: a white-gold beam of light from where it was to where it is,
				# with glowing afterimages along it.
				var k: float = e["t"] / 0.3
				_fx.draw_line(e["from"] + Vector2(0, -10), e["to"] + Vector2(0, -10), Color(1, 0.8, 0.35, 0.5 * (1.0 - k)), 9.0)
				_fx.draw_line(e["from"] + Vector2(0, -10), e["to"] + Vector2(0, -10), Color(1, 1, 0.9, 1.0 - k), 3.0)
				var tex: Texture2D = e["tex"]
				for j in 3:
					var p: Vector2 = e["from"].lerp(e["to"], (j + 1) / 4.0) + e["off"]
					_fx.draw_texture(tex, (p - tex.get_size() * 0.5).round(), Color(1.6, 1.4, 0.8, 0.45 * (1.0 - k) * (j + 1) / 3.0))
			"flash":
				var k: float = e["t"] / 0.45
				_fx.draw_circle(e["pos"].round(), 6.0 + 60.0 * k, Color(1, 0.95, 0.7, 0.45 * (1.0 - k)))
				_fx.draw_arc(e["pos"].round(), 6.0 + 60.0 * k, 0, TAU, 40, Color(1, 0.9, 0.5, 1.0 - k), 2.0)
			"fireball":
				if e.get("jade", false):
					# A jade spike in flight: a long faceted sliver pointing along its path, trailing emerald light.
					var dir: Vector2 = e["vel"].normalized()
					for k in range(0, e["trail"].size(), 3):
						_fx.draw_circle(e["trail"][k].round(), 1.5, Color(0.48, 0.96, 0.72, 0.25))
					_fx.draw_set_transform(e["pos"].round(), dir.angle(), Vector2.ONE)
					_fx.draw_colored_polygon(PackedVector2Array([Vector2(9, 0), Vector2(-7, -3), Vector2(-9, 0), Vector2(-7, 3)]), Color("#53986e"))
					_fx.draw_colored_polygon(PackedVector2Array([Vector2(8, 0), Vector2(-6, -1), Vector2(-6, 1)]), Color("#afe8b8"))
					_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
				else:
					# A chain of fire blobs, smallest at the tail, wobbling a little; the head is the
					# painted lantern ball (looping), so every lantern projectile reads the same.
					var n: int = e["trail"].size()
					for k in n:
						if k % 3 == 2 and k < n - 2:
							var p: Vector2 = e["trail"][k] + Vector2(0, sin(k * 1.7 + _crowd_t * 20.0))
							_blob(p, 0.8 + 2.2 * k / maxf(1, n), 0.6)
					_fx.draw_circle(e["pos"].round(), 9.0, Color(1, 0.55, 0.15, 0.18))
					_draw_sheet(_fx, "lantern_ball", e["pos"] + Vector2(0, 8), _crowd_t + e["pos"].x * 0.01, true)
			"beam":
				# Two streams twisting round each other, white cores with blue edges, as in the reference.
				var tip: Vector2 = e["from"] + e["dir"] * e["len"]
				var fade: float = clampf(e["life"] / 0.2, 0.0, 1.0)
				var side: Vector2 = e["dir"].orthogonal()
				# Water beams are blue with white cores; a molten pour (Vitrecrag) is orange with a yellow core.
				var molten: bool = e.get("molten", false)
				var halo := Color(1.0, 0.45, 0.1, 0.3 * fade) if molten else Color(0.25, 0.55, 1.0, 0.3 * fade)
				var edge := Color(1.0, 0.5, 0.15, fade) if molten else Color(0.3, 0.6, 1.0, fade)
				var core := Color(1.0, 0.95, 0.7, fade) if molten else Color(0.9, 0.98, 1.0, fade)
				_fx.draw_line(e["from"].round(), tip.round(), halo, 9.0)
				for strand in 2:
					var pts := PackedVector2Array()
					var steps := int(e["len"] / 4.0) + 1
					for k in steps + 1:
						var along := float(k) / steps
						var wob := sin(along * 9.0 + _crowd_t * 25.0 + strand * PI) * 2.0 * minf(1.0, along * 4.0)
						pts.append((e["from"].lerp(tip, along) + side * wob).round())
					_fx.draw_polyline(pts, edge, 4.0)
					_fx.draw_polyline(pts, core, 2.0)
				for k in 3:
					_fx.draw_circle((e["from"] + Vector2(randf_range(-2, 2), randf_range(-2, 2))).round(), 3.0, Color(core, 0.9 * fade))
				_fx.draw_circle(tip.round(), 5.0, Color(core, 0.85 * fade))
				_fx.draw_set_transform(tip.round(), e["dir"].angle(), Vector2(0.35, 1.0))
				_fx.draw_arc(Vector2.ZERO, 7.0, 0, TAU, 20, Color(1, 0.9, 0.4, 0.9 * fade), 1.0)
				_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"seed":
				var t: float = e["t"]
				var p: Vector2 = e["from"].lerp(e["to"], t) + Vector2(0, -sin(t * PI) * 26.0)
				_fx.draw_circle(e["to"].round(), 4.0 * t, Color(0, 0, 0, 0.25))
				if e.get("molten", false):
					# A glowing mass of molten glass, trailing sparks.
					_fx.draw_circle(p.round(), 6.0, Color("#ff6a1a"))
					_fx.draw_circle(p.round(), 3.5, Color("#fff1b0"))
					for k in 3:
						_fx.draw_rect(Rect2((p + Vector2(randf_range(-6, 6), randf_range(-2, 8))).round(), Vector2(1, 1)), Color("#ffb347"))
				else:
					_fx.draw_circle(p.round(), 5.0, Color("#5a3f22"))
					_fx.draw_circle(p.round(), 4.0, Color("#8a6a3a"))
					_fx.draw_rect(Rect2((p - Vector2(1, 9)).round(), Vector2(3, 5)), Color("#8fd16a"))
			"impact":
				# Played once, quickly, fading over its last quarter; bottom-centred on the hit.
				var frames: Array = _impact_frames[e["anim"]]
				var k: float = e["t"] / IMPACT_SECONDS
				var tex: Texture2D = frames[mini(frames.size() - 1, int(k * frames.size()))]
				var at: Vector2 = (e["pos"] - Vector2(tex.get_width() * 0.5, tex.get_height() * 0.75)).round()
				_fx.draw_texture(tex, at, Color(1, 1, 1, clampf((1.0 - k) / 0.25, 0.0, 1.0)))
			"rail_beam":
				# Rail Shot: a bright jade streak down the whole line with a white core, and a
				# flash at the muzzle, gone in a third of a second.
				var k: float = e["t"] / 0.3
				_fx.draw_line(e["from"].round(), e["to"].round(), Color(0.07, 0.72, 0.42, 0.35 * (1.0 - k)), 9.0)
				_fx.draw_line(e["from"].round(), e["to"].round(), Color(0.49, 0.96, 0.72, 0.9 * (1.0 - k)), 4.0)
				_fx.draw_line(e["from"].round(), e["to"].round(), Color(1.0, 1.0, 1.0, 0.9 * (1.0 - k)), 1.5)
				_fx.draw_circle(e["from"].round(), 7.0 * (1.0 - k), Color(0.49, 0.96, 0.72, 0.9))
			"spikes":
				# Ground Spikes: jade erupts in a ring round the target's feet, then crumbles.
				var k: float = clampf(e["t"] / 0.2, 0.0, 1.0)
				var fade: float = clampf((0.8 - e["t"]) / 0.3, 0.0, 1.0)
				for sp in 6:
					var a: float = sp * TAU / 6.0 + 0.4
					var base: Vector2 = e["pos"] + Vector2(cos(a) * 11.0, sin(a) * 5.0 + 2.0)
					var h: float = (10.0 + 5.0 * absf(sin(sp * 2.3))) * k
					_fx.draw_colored_polygon(PackedVector2Array([base.round() + Vector2(-3, 0), base.round() + Vector2(3, 0), base.round() + Vector2(0, -h)]), Color(0.33, 0.6, 0.43, fade))
					_fx.draw_line(base.round() + Vector2(0, -h), base.round() + Vector2(0, -h * 0.4), Color(0.69, 0.91, 0.72, fade), 1.0)
			"vortex":
				# Slab Vortex: the plates whirl round it twice, with a shock ring on the ground.
				var k: float = e["t"] / 0.5
				var c: Vector2 = _fighters[e["who"]]["body"].position + Vector2(0, -10)
				for sp in 4:
					var a: float = k * TAU * 2.0 + sp * TAU / 4.0
					var p: Vector2 = c + Vector2(cos(a) * 24.0, sin(a) * 10.0)
					_fx.draw_colored_polygon(PackedVector2Array([p.round() + Vector2(0, -6), p.round() + Vector2(4, 0), p.round() + Vector2(0, 6), p.round() + Vector2(-4, 0)]), Color(0.33, 0.6, 0.43, 1.0 - k * 0.5))
				_fx.draw_set_transform(c.round() + Vector2(0, 10), 0.0, Vector2(1.0, 0.45))
				_fx.draw_arc(Vector2.ZERO, 26.0 + 12.0 * k, 0, TAU, 32, Color(0.49, 0.96, 0.72, 0.8 * (1.0 - k)), 2.0)
				_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"shrapnel":
				# Stone Cocoon bursting: jade bits fly out in a ring.
				var k: float = e["t"] / 0.5
				for sp in 14:
					var a: float = sp * TAU / 14.0 + 0.2
					var p: Vector2 = e["pos"] + Vector2(cos(a), sin(a) * 0.6) * COCOON_RADIUS * k + Vector2(0, -10.0 + 10.0 * k * k)
					_fx.draw_rect(Rect2(p.round(), Vector2(3, 2)), Color(0.69, 0.91, 0.72, 1.0 - k))
				_fx.draw_set_transform(e["pos"].round(), 0.0, Vector2(1.0, 0.5))
				_fx.draw_arc(Vector2.ZERO, COCOON_RADIUS * k, 0, TAU, 40, Color(0.49, 0.96, 0.72, 0.8 * (1.0 - k)), 2.0)
				_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"burst":
				var k: float = e["t"] / 0.45
				if k < 0.3:
					_fx.draw_circle(e["pos"].round(), e["size"] * 0.55 * (1.0 - k), Color(1, 1, 0.95, 1.0 - k * 2.0))
					_fx.draw_circle(e["pos"].round(), e["size"] * 0.35 * (1.0 - k), e["core"])
				for b in e["bits"]:
					var bp: Vector2 = e["pos"] + b * e["t"]
					_fx.draw_rect(Rect2(bp.round(), Vector2(1, 1)), Color(e["rim"].lightened(0.3), 1.0 - k))
			"ring":
				# A thin shock ring flattened onto the ground, and speed lines shooting out.
				var k: float = e["t"] / 0.35
				_fx.draw_set_transform(e["pos"].round(), 0.0, Vector2(1.0, 0.55))
				_fx.draw_arc(Vector2.ZERO, e["size"] * (0.3 + 0.9 * k), 0, TAU, 32, Color(1, 0.9, 0.45, 1.0 - k), 1.0)
				_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
				for a in e["lines"]:
					var d := Vector2.RIGHT.rotated(a)
					var r0: float = e["size"] * (0.3 + 0.8 * k)
					_fx.draw_line((e["pos"] + d * r0).round(), (e["pos"] + d * (r0 + 5.0)).round(), Color(1, 1, 0.9, 1.0 - k), 1.0)
	_draw_smoke()


## One pillar of a Root Wall: woody roots twisting up from the ground, rising as it grows and
## sinking back as it withers.
## Lantern marks: a small lantern glyph over anything a lantern ball touched, pulsing, so the
## player can see where a tackle or a landing can go. During a tackle the chosen landing
## spot gets a brighter ring.
func _draw_marks() -> void:
	var land: Array = []
	if not _fighters.is_empty() and not _fighters[controlled]["tackle"].is_empty():
		land = _fighters[controlled]["tackle"]["land"]
	var pulse: float = 0.6 + 0.4 * sin(_crowd_t * 8.0)
	for j in _fighters.size():
		var f: Dictionary = _fighters[j]
		if f["marked"] > 0.0 and f["hp"] > 0:
			_draw_mark(f["body"].position + Vector2(0, -38 - 4 * f["stage"]), pulse, land == ["f", j])
	for k in _rocks.size():
		var r: Dictionary = _rocks[k]
		if r["marked"] > 0.0:
			_draw_mark(r["pos"] + Vector2(0, -r["h"] - 8), pulse, land == ["r", k])


func _draw_mark(at: Vector2, pulse: float, chosen: bool) -> void:
	var p: Vector2 = at.round()
	_draw_sheet(_fx, "mark_glyph", p + Vector2(0, 10), _crowd_t, true, IMPACT_SECONDS, Color(1, 1, 1, 0.6 + 0.4 * pulse), 10.0)
	if chosen:
		_fx.draw_arc(p + Vector2(0.5, -1.5), 8.0, 0, TAU, 16, Color(1.0, 0.98, 0.85, 0.95), 1.0)
		_fx.draw_string(_font if _font else ThemeDB.fallback_font, p + Vector2(-12, -10), "LAND", HORIZONTAL_ALIGNMENT_CENTER, 24, 6, Color(1.0, 0.98, 0.85))


## The ground shape an attack shows while it winds up. Red: a hit is coming (a ring round a
## melee attacker, a ring under the target of a lobbed or rooting move, a line with a "!"
## for a shot). Yellow: a charge that cannot be interrupted. The shape fills as the moment nears.
func _draw_telegraph(i: int) -> void:
	var f: Dictionary = _fighters[i]
	var w: Dictionary = f["windup"]
	var t: int = w["target"]
	if t < 0 or _fighters[t]["hp"] <= 0:
		return
	var k: float = 1.0 - w["t"] / w["total"]
	var col := Color(1.0, 0.85, 0.2) if w["kind"] == "charge" else Color(1.0, 0.25, 0.18)
	var me: Vector2 = f["body"].position
	var at: Vector2 = _fighters[t]["body"].position
	var blink := 1.0 if int(k * 10.0) % 2 == 0 or k < 0.6 else 0.6
	match w["kind"]:
		"melee":
			_ring(me, MOVES[w["m"]]["range"], col, k, blink)
		"area":
			_ring(at, 16.0, col, k, blink)
		"line", "charge", "rail":
			var dir: Vector2 = (at - me).normalized()
			var end: Vector2 = at if w["kind"] == "line" else (me + dir * MOVES[w["m"]]["range"] if w["kind"] == "rail" else me + dir * RAM_SPEED * RAM_SECONDS)
			var side: Vector2 = dir.orthogonal() * (3.0 if w["kind"] == "line" else 8.0)
			var box := PackedVector2Array([(me + side).round(), (end + side).round(), (end - side).round(), (me - side).round()])
			_fx.draw_colored_polygon(box, Color(col, 0.12 + 0.18 * k))
			box.append(box[0])
			_fx.draw_polyline(box, Color(col, 0.9 * blink), 1.0)
			if w["kind"] == "line":
				# The "!" over the target: a fast shot is coming.
				var top: Vector2 = at + Vector2(0, -30 - 3 * _fighters[t]["stage"])
				_fx.draw_rect(Rect2(top.round() + Vector2(-1, 0), Vector2(3, 6)), col)
				_fx.draw_rect(Rect2(top.round() + Vector2(-1, 8), Vector2(3, 2)), col)


func _ring(at: Vector2, r: float, col: Color, k: float, blink: float) -> void:
	_fx.draw_set_transform(at.round(), 0.0, Vector2(1.0, 0.45))
	_fx.draw_circle(Vector2.ZERO, r, Color(col, 0.1 + 0.2 * k))
	_fx.draw_arc(Vector2.ZERO, r, 0, TAU, 32, Color(col, 0.9 * blink), 1.0)
	_fx.draw_arc(Vector2.ZERO, r * k, 0, TAU, 32, Color(col, 0.5), 1.0)
	_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## The enemy your creature is going for: a ring at its feet and a chevron bobbing over its
## head. Red when you chose it, white when the AI did.
func _draw_target_marker() -> void:
	if _fighters.is_empty() or _fighters[controlled]["hp"] <= 0:
		return
	var tg: int = _fighters[controlled]["target"]
	if tg < 0 or _fighters[tg]["hp"] <= 0:
		return
	var chosen: bool = player_target == tg
	var col := Color("#ff4a3a") if chosen else Color(1, 1, 1, 0.7)
	var p: Vector2 = _fighters[tg]["body"].position
	_fx.draw_set_transform(p.round() + Vector2(0, 1), 0.0, Vector2(1.0, 0.45))
	_fx.draw_arc(Vector2.ZERO, 11.0 + 2.0 * _fighters[tg]["stage"], 0, TAU, 24, col, 1.0)
	_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var top: Vector2 = (p + Vector2(0, -34 - 4 * _fighters[tg]["stage"] - 2.0 * sin(_crowd_t * 6.0))).round()
	_fx.draw_colored_polygon(PackedVector2Array([top + Vector2(-4, -6), top + Vector2(4, -6), top]), col)
	if chosen:
		_fx.draw_polyline(PackedVector2Array([top + Vector2(-4, -6), top + Vector2(4, -6), top, top + Vector2(-4, -6)]), Color(0.2, 0.05, 0.05), 1.0)


## Marks on the floor: scorches, cracks, embers, currents and whirlpools. They live on the
## floor layer so a creature standing in them is never hidden (Preston, 2026-10-07: the
## smoke and black circles after Seed Pod covered the creature; the player must see what is
## going on).
func _draw_ground() -> void:
	var on: CanvasItem = _rubble
	for e in _effects:
		match e["kind"]:
			"scorch":
				on.draw_set_transform(e["pos"].round(), 0.0, Vector2(1.0, 0.6))
				on.draw_circle(Vector2.ZERO, e["size"], Color(0.12, 0.08, 0.05, 0.3 * clampf(1.0 - (e["t"] - 2.0) / 2.0, 0.0, 1.0)))
				on.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"riptide":
				var k: float = clampf(e["t"] / 0.3, 0.0, 1.0) * clampf((RIPTIDE_SECONDS - e["t"]) / 0.4, 0.0, 1.0)
				on.draw_set_transform(e["pos"].round(), 0.0, Vector2(1.0, 0.45))
				on.draw_circle(Vector2.ZERO, RIPTIDE_RADIUS * k, Color(0.1, 0.3, 0.5, 0.45))
				for r in 4:
					var spin: float = e["t"] * (5.0 - r) + r
					on.draw_arc(Vector2.ZERO, (5.0 + r * 4.5) * k, spin, spin + 3.6, 20, Color(0.55, 0.85, 1.0, 0.75 - r * 0.12), 1.0)
				on.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"whirl":
				if e["t"] > 0.0:
					var k: float = 1.0 - absf(e["t"] / 0.6 - 0.5) * 2.0
					on.draw_set_transform(e["pos"].round(), 0.0, Vector2(1.0, 0.4))
					on.draw_circle(Vector2.ZERO, 12.0 * k, Color(0.02, 0.06, 0.12, 0.7))
					for r in 3:
						var spin: float = e["t"] * (8.0 - r) + r
						on.draw_arc(Vector2.ZERO, (5.0 + r * 4.0) * k, spin, spin + 4.0, 20, Color(0.45, 0.8, 1.0, 0.8 - r * 0.2), 1.0)
					on.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"cracks":
				var fade: float = clampf(1.0 - (e["t"] - 2.0) / 2.0, 0.0, 1.0)
				for line in e["lines"]:
					on.draw_polyline(line, Color(0.05, 0.04, 0.03, 0.7 * fade), 1.0)
			"fire_patch":
				var k: float = e["t"] / 1.6
				var flick := 1.0 if int(e["t"] * 12) % 2 == 0 else 0.7
				on.draw_rect(Rect2((e["pos"] - Vector2(3, 2)).round(), Vector2(6, 3)), Color(1, 0.45, 0.1, 0.7 * (1.0 - k) * flick))
				on.draw_rect(Rect2((e["pos"] - Vector2(1, 4)).round(), Vector2(2, 3)), Color(1, 0.85, 0.3, 0.8 * (1.0 - k) * flick))
			"glass_pool":
				# Molten glass cooling on the floor: orange and bright, then amber, then dark glass with a shine.
				var kp: float = clampf(e["t"] / POOL_SECONDS, 0.0, 1.0)
				var fade: float = clampf((POOL_SECONDS - e["t"]) / 0.8, 0.0, 1.0)
				var pr: float = e.get("r", POOL_RADIUS)
				var col := Color(1.0, 0.55, 0.15).lerp(Color(0.25, 0.12, 0.08), kp)
				on.draw_set_transform(e["pos"].round(), 0.0, Vector2(1.0, 0.5))
				on.draw_circle(Vector2.ZERO, pr, Color(col, 0.85 * fade))
				on.draw_circle(Vector2(-4, -3) * pr / 18.0, pr * 0.45, Color(1.0, 0.95, 0.75).lerp(Color(0.6, 0.5, 0.45), kp) * Color(1, 1, 1, 0.7 * fade))
				on.draw_arc(Vector2.ZERO, pr, 0, TAU, 28, Color(0.5, 0.2, 0.05, 0.9 * fade), 1.0)
				if kp < 0.5 and int(e["t"] * 8.0) % 2 == 0:
					on.draw_circle(Vector2(5, 2) * pr / 18.0, 2.0, Color(1.0, 0.95, 0.7, (0.5 - kp) * 2.0 * fade))
				on.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"star_field":
				# Starshield's star field: a soft pink five-point star on the floor, turning slowly,
				# where allies mend.
				var kf: float = clampf(e["t"] / 0.3, 0.0, 1.0) * clampf((STAR_FIELD_SECONDS - e["t"]) / 0.6, 0.0, 1.0)
				on.draw_set_transform(e["pos"].round() + Vector2(0, 2), 0.0, Vector2(1.0, 0.5))
				on.draw_colored_polygon(_star_points(Vector2.ZERO, STAR_FIELD_RADIUS * kf, STAR_FIELD_RADIUS * 0.45 * kf, e["t"] * 0.3), Color(1.0, 0.48, 0.82, 0.22))
				on.draw_polyline(_star_points(Vector2.ZERO, STAR_FIELD_RADIUS * kf, STAR_FIELD_RADIUS * 0.45 * kf, e["t"] * 0.3, true), Color(1.0, 0.84, 0.94, 0.8), 1.5)
				on.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"shards":
				# Kingstone Rail's crater: scorched ground ringed with jade shards, pulsing emerald,
				# fading as the Kingstone's pull lets go of them.
				var ks: float = clampf((SHARDS_SECONDS - e["t"]) / 0.8, 0.0, 1.0) * clampf(e["t"] / 0.2, 0.0, 1.0)
				on.draw_set_transform(e["pos"].round() + Vector2(0, 2), 0.0, Vector2(1.0, 0.5))
				on.draw_circle(Vector2.ZERO, SHARDS_RADIUS, Color(0.12, 0.1, 0.09, 0.6 * ks))
				on.draw_arc(Vector2.ZERO, SHARDS_RADIUS, 0, TAU, 40, Color(0.2, 0.39, 0.29, 0.9 * ks), 1.5)
				on.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
				var pulse: float = 0.5 + 0.5 * sin(e["t"] * 5.0)
				for sp in 12:
					var a: float = sp * TAU / 12.0 + 0.25
					var base: Vector2 = e["pos"] + Vector2(cos(a) * SHARDS_RADIUS * 0.9, sin(a) * SHARDS_RADIUS * 0.45 + 2.0)
					var h: float = 7.0 + 4.0 * absf(sin(sp * 1.9))
					on.draw_colored_polygon(PackedVector2Array([base.round() + Vector2(-3, 0), base.round() + Vector2(3, 0), base.round() + Vector2(0, -h)]), Color(0.33, 0.6, 0.43, ks))
					on.draw_rect(Rect2(base.round() + Vector2(-1, -h), Vector2(2, 2)), Color(0.49, 0.96, 0.72, (0.5 + 0.5 * pulse) * ks))
			"guard":
				# Glass Guard: a molten ring round the planted tank, pulsing with its kiln.
				var gf: Dictionary = _fighters[e["who"]]
				var pulse: float = 0.5 + 0.5 * sin(e["t"] * 9.0)
				on.draw_set_transform(gf["body"].position.round() + Vector2(0, 2), 0.0, Vector2(1.0, 0.5))
				on.draw_circle(Vector2.ZERO, 20.0, Color(1.0, 0.5, 0.15, 0.18 + 0.1 * pulse))
				on.draw_arc(Vector2.ZERO, 20.0 + pulse, 0, TAU, 32, Color(1.0, 0.8, 0.4, 0.9), 2.0)
				on.draw_arc(Vector2.ZERO, 16.0, 0, TAU, 24, Color(1.0, 0.95, 0.75, 0.5 + 0.4 * pulse), 1.0)
				on.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"lava_seam":
				# A crack in the arena floor glowing with heat, dimming as it cools.
				var ks: float = clampf(e["t"] / SEAM_SECONDS, 0.0, 1.0)
				var glow := Color(1.0, 0.5 + 0.3 * sin(e["t"] * 10.0), 0.1).lerp(Color(0.3, 0.1, 0.05), ks)
				on.draw_polyline(e["pts"], Color(0.08, 0.03, 0.0, 0.9), 5.0)
				on.draw_polyline(e["pts"], Color(glow, 1.0 - ks * 0.6), 2.0)
			"vines":
				# Verdant Roar's vine field: a dark green patch laced with tendrils that slows anyone in it.
				var k: float = clampf(e["t"] / 0.3, 0.0, 1.0) * clampf((VINES_SECONDS - e["t"]) / 0.6, 0.0, 1.0)
				on.draw_set_transform(e["pos"].round(), 0.0, Vector2(1.0, 0.45))
				on.draw_circle(Vector2.ZERO, VINES_RADIUS * k, Color(0.1, 0.25, 0.08, 0.5))
				for r in 7:
					var a: float = r * TAU / 7.0 + e["t"] * 0.4
					var tip: Vector2 = Vector2.RIGHT.rotated(a) * VINES_RADIUS * k * 0.95
					on.draw_line(Vector2.ZERO, tip, Color(0.35, 0.6, 0.2, 0.8), 2.0)
					on.draw_circle(tip, 2.5, Color(0.56, 0.82, 0.42, 0.9))
				on.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## One frame of a painted sheet at a point (bottom-centred like the impacts), looping on
## `t` at `fps` frames a second when `loop` is true, otherwise playing once over `seconds`.
func _draw_sheet(on: CanvasItem, anim: String, at: Vector2, t: float, loop: bool, seconds: float = IMPACT_SECONDS, tint: Color = Color.WHITE, fps: float = 14.0) -> void:
	var frames: Array = _impact_frames.get(anim, [])
	if frames.is_empty():
		return
	var idx: int = int(t * fps) % frames.size() if loop else mini(frames.size() - 1, int(clampf(t / seconds, 0.0, 0.999) * frames.size()))
	var tex: Texture2D = frames[idx]
	on.draw_texture(tex, (at - Vector2(tex.get_width() * 0.5, tex.get_height() * 0.75)).round(), tint)


## A rock, drawn on its own node so it sorts with the creatures by height on screen. Flat
## facets lit from the upper left (cream to dark), moss on top, facet seams and a heavy
## outline; cracks spread as it weakens, and it flashes white when hit.
func _draw_rock(r: Dictionary) -> void:
	var node: Node2D = r["node"]
	if r["kind"] == "crate":
		_draw_crate(r)
		return
	var sx: float = r["rx"]
	var sy: float = r["h"]
	var stage := _rock_stage(r)
	var flash: bool = r["flash"] > 0.0
	var dim := 1.0 - 0.08 * stage
	node.draw_set_transform(Vector2(3, 1), 0.0, Vector2(1.0, 0.42))
	node.draw_circle(Vector2.ZERO, sx * 1.1, Color(0, 0, 0, 0.3))
	node.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var shape := PackedVector2Array()
	for u in ROCK_SHAPE:
		shape.append(Vector2(u.x * sx, u.y * sy).round())
	node.draw_colored_polygon(shape, Color.WHITE if flash else ROCK_SHADES[1] * dim)
	if not flash:
		for f in ROCK_FACETS:
			var pts := PackedVector2Array()
			for u in f["p"]:
				pts.append(Vector2(u.x * sx, u.y * sy).round())
			node.draw_colored_polygon(pts, ROCK_SHADES[f["s"]] * dim)
			var seam := PackedVector2Array(pts)
			seam.append(pts[0])
			node.draw_polyline(seam, Color(ROCK_OUTLINE, 0.55), 1.0)
		for m in ROCK_MOSS:
			if not r["big"] and m[1] < 0.1:
				continue
			var c: Vector2 = Vector2(m[0].x * sx, m[0].y * sy).round()
			node.draw_set_transform(c, 0.0, Vector2(1.0, 0.6))
			node.draw_circle(Vector2.ZERO, m[1] * sx * 1.6, MOSS[0])
			node.draw_circle(Vector2(-1, -1), m[1] * sx * 0.9, MOSS[1])
			node.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			node.draw_rect(Rect2(c + Vector2(m[1] * sx * 0.8, 1), Vector2(2, 1)), MOSS[2])
	var outline := PackedVector2Array(shape)
	outline.append(shape[0])
	node.draw_polyline(outline, ROCK_OUTLINE, 1.0)
	for k in mini(stage * 2 - 1 if stage > 0 else 0, ROCK_CRACKS.size()):
		var line := PackedVector2Array()
		for u in ROCK_CRACKS[k]:
			line.append(Vector2(u.x * sx, u.y * sy).round())
		node.draw_polyline(line, ROCK_OUTLINE, 1.0)
	if stage >= 2 and not flash:
		# Nearly broken: the seams gape dark.
		node.draw_polyline(outline, Color(ROCK_OUTLINE, 0.5), 2.0)


## A wooden crate (the reference has them round the pitch): planks, a cross brace, a heavy
## outline; it splinters as it weakens and flashes when hit.
func _draw_crate(r: Dictionary) -> void:
	var node: Node2D = r["node"]
	var w: float = r["rx"]
	var h: float = r["h"]
	var flash: bool = r["flash"] > 0.0
	node.draw_set_transform(Vector2(2, 1), 0.0, Vector2(1.0, 0.42))
	node.draw_circle(Vector2.ZERO, w * 1.2, Color(0, 0, 0, 0.3))
	node.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var box := Rect2(Vector2(-w, -h), Vector2(w * 2.0, h))
	node.draw_rect(box, Color.WHITE if flash else CRATE_SHADES[1])
	if not flash:
		node.draw_rect(Rect2(Vector2(-w, -h), Vector2(w * 2.0, 3)), CRATE_SHADES[0])
		for k in 3:
			node.draw_line(Vector2(-w, -h + 4 + k * 4), Vector2(w, -h + 4 + k * 4), CRATE_SHADES[2], 1.0)
		node.draw_line(Vector2(-w + 1, -h + 1), Vector2(w - 1, -1), CRATE_SHADES[3], 1.0)
		node.draw_line(Vector2(w - 1, -h + 1), Vector2(-w + 1, -1), CRATE_SHADES[3], 1.0)
	node.draw_rect(box, ROCK_OUTLINE, false, 1.0)
	var stage := _rock_stage(r)
	if stage >= 1:
		node.draw_polyline(PackedVector2Array([Vector2(-2, -h), Vector2(0, -h * 0.6), Vector2(-1, -h * 0.3), Vector2(1, 0)]), ROCK_OUTLINE, 1.0)
	if stage >= 2:
		node.draw_polyline(PackedVector2Array([Vector2(w * 0.6, -h), Vector2(w * 0.3, -h * 0.5), Vector2(w * 0.5, 0)]), ROCK_OUTLINE, 1.0)


## The floor layer under the creatures: craters and fallen shards from broken rocks, and
## cracks where creatures were slammed into the arena wall. All of it stays for the fight.
func _draw_rubble() -> void:
	_draw_ground()
	for b in _rubble_bits:
		if b.has("rx"):
			_rubble.draw_set_transform(b["pos"].round(), 0.0, Vector2(1.0, 0.42))
			_rubble.draw_circle(Vector2.ZERO, b["rx"] * 0.9, Color(0.1, 0.07, 0.05, 0.45))
			_rubble.draw_circle(Vector2(2, 1), b["rx"] * 0.5, Color(0.05, 0.03, 0.02, 0.5))
			_rubble.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for b in _rubble_bits:
		if b.has("pts"):
			_rubble.draw_set_transform(b["pos"], 0.0, Vector2.ONE)
			_draw_shard(_rubble, b["pts"], b["c"])
			_rubble.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for m in _wall_marks:
		_rubble.draw_polyline(m, Color(0.08, 0.06, 0.04, 0.85), 1.0)


func _draw_root_pillar(w: Dictionary) -> void:
	var up: float = clampf(w["t"] / 0.2, 0.0, 1.0) * clampf((WALL_SECONDS - w["t"]) / 0.4, 0.0, 1.0)
	var p: Vector2 = w["pos"]
	_fx.draw_circle(p + Vector2(0, 1), 5.0, Color(0.15, 0.1, 0.05, 0.4 * up))
	var h := 14.0 * up
	if h < 2.0:
		return   # still sprouting or nearly gone: nothing tall enough to draw
	_fx.draw_colored_polygon(PackedVector2Array([p + Vector2(-4, 0), p + Vector2(4, 0), p + Vector2(1, -h), p + Vector2(-2, -h + 2)]), Color("#5a3f22"))
	_fx.draw_line(p + Vector2(-3, -2), p + Vector2(-1, -h * 0.7), Color("#7a5a32"), 1.0)
	_fx.draw_rect(Rect2((p + Vector2(0, -h - 1)).round(), Vector2(2, 2)), Color("#8fd16a"))


## Rising smoke and steam: chunky grey puffs that grow, drift up and thin out.
func _draw_smoke() -> void:
	for e in _effects:
		if e["kind"] == "smoke" and e["t"] > 0.0:
			var k: float = e["t"] / e["life"]
			var r: float = e["size"] * (1.0 + 1.8 * k)
			var c := Color(0.62, 0.58, 0.55) if e["warm"] else Color(0.85, 0.9, 0.95)
			_fx.draw_circle(e["pos"].round(), r, Color(c.darkened(0.25), 0.22 * (1.0 - k)))
			_fx.draw_circle((e["pos"] + Vector2(-1, -1)).round(), r * 0.7, Color(c, 0.28 * (1.0 - k)))


## The lantern's warm pool of light on the ground, brighter as it charges, and a halo round
## the lantern itself that pulses white at full charge.
## A five-point star as a polygon (closed when `close`), for the shields and the star field.
func _star_points(c: Vector2, r_out: float, r_in: float, rot: float, close := false) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for k in 10:
		var r: float = r_out if k % 2 == 0 else r_in
		pts.append(c + Vector2.RIGHT.rotated(rot - PI / 2.0 + k * TAU / 10.0) * r)
	if close:
		pts.append(pts[0])
	return pts


## A star shield round a fighter: a turning pink star with a brighter rim, shrinking as it
## wears thin.
func _draw_star_shield(f: Dictionary) -> void:
	var at: Vector2 = f["body"].position + Vector2(0, -12)
	var k: float = clampf(float(f["shield"]) / STARSHIELD_SHIELD, 0.4, 1.0)
	var r: float = 15.0 + 6.0 * k
	_fx.draw_colored_polygon(_star_points(at.round(), r, r * 0.5, _crowd_t * 0.8), Color(1.0, 0.48, 0.82, 0.16))
	_fx.draw_polyline(_star_points(at.round(), r, r * 0.5, _crowd_t * 0.8, true), Color(1.0, 0.84, 0.94, 0.9), 1.5)
	_fx.draw_polyline(_star_points(at.round(), r - 2.0, (r - 2.0) * 0.5, -_crowd_t * 0.5, true), Color(1.0, 0.48, 0.82, 0.6), 1.0)


## Bound Slabs: Oxbowarchon's jade slabs float at its hips, each bound to it by a seam of
## emerald light; while it cocoons they are pulled tight into a shell round it.
func _draw_slabs(f: Dictionary) -> void:
	var at: Vector2 = f["body"].position
	if f["cocoon"] > 0.0:
		var kc: float = clampf(f["cocoon"] / COCOON_SECONDS, 0.0, 1.0)
		_fx.draw_set_transform(at.round() + Vector2(0, -10), 0.0, Vector2(1.0, 0.8))
		_fx.draw_arc(Vector2.ZERO, 16.0, 0, TAU, 24, Color(0.33, 0.6, 0.43, 0.9), 3.0)
		_fx.draw_arc(Vector2.ZERO, 16.0 + sin(_crowd_t * 30.0), 0, TAU, 24, Color(0.49, 0.96, 0.72, 0.5 + 0.4 * (1.0 - kc)), 1.0)
		_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	for sl in f["slabs"]:
		var side: float = -1.0 if sl == 0 else 1.0
		var p: Vector2 = (at + Vector2(side * 16.0, -12.0 + sin(_crowd_t * 3.0 + sl) * 1.5)).round()
		_fx.draw_line(at.round() + Vector2(side * 8.0, -12.0), p, Color(0.49, 0.96, 0.72, 0.5), 1.0)
		_fx.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -6), p + Vector2(3, 0), p + Vector2(0, 6), p + Vector2(-3, 0)]), Color("#53986e"))
		_fx.draw_line(p + Vector2(0, -5), p + Vector2(0, 5), Color("#afe8b8"), 1.0)


func _draw_lantern_light(f: Dictionary) -> void:
	var lamp := _lantern_point(f)
	var c: float = f["charge"] / 100.0
	var flick := 0.85 + 0.15 * sin(_crowd_t * 17.0) * sin(_crowd_t * 7.0)
	_fx.draw_set_transform(Vector2(lamp.x, f["body"].position.y).round(), 0.0, Vector2(1.0, 0.4))
	_fx.draw_circle(Vector2.ZERO, 16.0 + 8.0 * c, Color(1, 0.7, 0.3, (0.12 + 0.1 * c) * flick))
	_fx.draw_circle(Vector2.ZERO, 9.0 + 4.0 * c, Color(1, 0.8, 0.4, (0.12 + 0.1 * c) * flick))
	_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var full: bool = f["charge"] >= 100.0
	# Like a filament heating up: warm orange at rest, white-hot at full charge.
	var heat := Color(1, 0.55, 0.2).lerp(Color(1, 0.97, 0.85), c)
	var halo := Color(1, 1, 1, 0.6) if full and int(_crowd_t * 10) % 2 == 0 else Color(heat, (0.3 + 0.2 * c) * flick)
	_fx.draw_circle(lamp.round(), 4.0 + 2.0 * c, halo)
	_fx.draw_circle(lamp.round(), 1.5 + c, Color(heat.lightened(0.3), 0.9))


## The scour hollow a Hollow form glides over: a dark worn patch with rings rippling
## outward like water, drawn flattened onto the ground.
func _draw_scour(at: Vector2) -> void:
	_fx.draw_set_transform(at.round(), 0.0, Vector2(1.0, 0.35))
	_fx.draw_circle(Vector2.ZERO, 12.0, Color(0.03, 0.05, 0.08, 0.5))
	for r in 3:
		var k := fposmod(_crowd_t * 0.8 + r / 3.0, 1.0)
		_fx.draw_arc(Vector2.ZERO, 8.0 + k * 18.0, 0, TAU, 28, Color(0.5, 0.85, 1.0, 0.45 * (1.0 - k)), 2.0)
	_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Name, HP and signature meter for each side (and Stormwick's lantern charge), the move
## names as creatures use them, the win banner, and the signature close-up.
func _draw_hud() -> void:
	# One box per creature: one big box a side in 1v1, a stack of small ones in team fights.
	var per_side := [0, 0]
	for f in _fighters:
		per_side[f["team"]] += 1
	var row := [0, 0]
	for idx in _fighters.size():
		var f: Dictionary = _fighters[idx]
		var side: int = f["team"]
		var big: bool = per_side[side] == 1
		var w: float = 360.0 if big else 280.0
		var h: float = 72.0 if big else 40.0
		var x: float = 16.0 if side == 0 else 1152.0 - 16.0 - w
		var y: float = 560.0 if big else 648.0 - 10.0 - (per_side[side] - row[side]) * (h + 4.0)
		row[side] += 1
		var u := h / 72.0   # vertical scale of the bars
		var accent: Color = LINES[f["line"]]["accent"]
		var box := Rect2(x, y, w, h)
		_hud.draw_rect(box, Color(0.07, 0.09, 0.11, 0.85))
		_hud.draw_rect(box, (YOU_RING if idx == controlled else TEAM_RING[side]) if not big else Color("#75604D"), false, 3.0 if big else 2.0)
		var who := "YOU  " if idx == controlled else ("ALLY  " if side == 0 else "RIVAL  ")
		var label: String = who + String(f["name"]).to_upper()
		if f["role"] != "":
			label += "  " + String(f["role"]).to_upper()
		var dim := 1.0 if f["hp"] > 0 else 0.4
		_hud.draw_string(_font, Vector2(x + 14, y + (24 if big else 15)), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16 if big else 11, Color(0.94, 0.96, 0.97, dim))
		var bw := w - 28.0
		var hp_k: float = float(f["hp"]) / f["max_hp"]
		_hud.draw_rect(Rect2(x + 14, y + 34 * u, bw, 14 * u), Color("#0e1316"))
		var hp_col := Color("#1B8E78") if hp_k > 0.5 else (Color("#d9a441") if hp_k > 0.2 else Color("#d9483b"))
		_hud.draw_rect(Rect2(x + 16, y + 36 * u, (bw - 4) * hp_k, 10 * u), hp_col)
		var m_k: float = f["meter"] / 100.0
		_hud.draw_rect(Rect2(x + 14, y + 52 * u, bw, 8 * u), Color("#0e1316"))
		var full: bool = f["meter"] >= 100
		if f["final"]:   # earlier stages have no signature, so no meter
			_hud.draw_rect(Rect2(x + 16, y + 53 * u, (bw - 4) * m_k, 6 * u), accent.lightened(0.4) if full and int(_crowd_t * 8) % 2 == 0 else accent)
		if f["passive"] == "lantern_charge":
			_hud.draw_rect(Rect2(x + 14, y + 63 * u, bw * f["charge"] / 100.0, maxf(2.0, 3 * u)), Color(1, 0.9, 0.4) if f["charge"] >= 100.0 else Color(1, 0.6, 0.2))
		elif f["passive"] in ["stoke", "kiln"]:
			_hud.draw_rect(Rect2(x + 14, y + 63 * u, bw * f["heat"] / 100.0, maxf(2.0, 3 * u)), Color(1, 0.95, 0.6) if f["heat"] >= 100.0 else Color(0.9, 0.3, 0.1))
		if idx == controlled and not f["tackle"].is_empty():
			var land: Array = f["tackle"]["land"]
			var where: String = String(_fighters[land[1]]["name"]) if land[0] == "f" else String(_rocks[land[1]]["kind"])
			_hud.draw_string(_font, Vector2(x + 14, y - 6), "LANDING  " + where.to_upper() + "  (LEFT/RIGHT)", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#ffe066"))
		elif idx == controlled:
			var tg: int = f["target"]
			var tname: String = ("AUTO" if player_target < 0 else "") if tg < 0 else String(_fighters[tg]["name"]).to_upper() + ("" if player_target >= 0 else "  (AUTO)")
			_hud.draw_string(_font, Vector2(x + 14, y - 6), "TARGET  " + tname, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#ff4a3a") if player_target >= 0 else Color(1, 1, 1, 0.7))
		if full and f["final"] and idx == controlled:
			_hud.draw_string(_font, Vector2(x + w - 170, y + (24 if big else 15)), "K: " + String(LINES[f["line"]]["signature"]).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 12 if big else 10, accent.lightened(0.3))
	_draw_ability_bar()
	_hud.draw_string(_font, Vector2(16, 24), "TARGET LEFT/RIGHT  UP AUTO   ABILITIES 1 2 3   ULTIMATE 4   SPACE SWITCH CREATURE   (IT MOVES AND USES ITS BASIC ATTACK ON ITS OWN)   STAGE F   RIVAL T   RIVAL STAGE G   TEAM SIZE N   ROCKS B   SHAKE V   ARENA M   REMATCH R   ESC MENU", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1, 1, 1, 0.75))
	for l in _labels:
		var f: Dictionary = _fighters[l["who"]]
		var p: Vector2 = (f["body"].position + Vector2(0, -34) + _world.position) * SCALE + Vector2(0, -l["t"] * 20.0 - l["slot"] * 15.0)
		var a: float = clampf(1.0 - (l["t"] - 0.6) / 0.3, 0.0, 1.0)
		_hud.draw_string(_font, p + Vector2(-100, 2), l["text"], HORIZONTAL_ALIGNMENT_CENTER, 200, 13, Color(0, 0, 0, 0.7 * a))
		_hud.draw_string(_font, p + Vector2(-100, 0), l["text"], HORIZONTAL_ALIGNMENT_CENTER, 200, 13, Color(1, 1, 1, a))
	if _sig_user >= 0:
		var f: Dictionary = _fighters[_sig_user]
		_sig.draw_card(_hud, f["closeup"], LINES[f["line"]]["signature"], LINES[f["line"]]["accent"], _font)
	if _winner >= 0 and not _sig.active:
		var w: Dictionary = _fighters[_winner]   # 1v1: fighter index and team match
		var text: String = ("YOU WIN!  " if _winner == 0 else "RIVAL WINS  ") + String(w["name"]).to_upper()
		var col: Color = LINES[w["line"]]["accent"].lightened(0.3)
		if team_size > 1 or teams_override.size() == 2:
			text = "YOUR TEAM WINS!" if _winner == 0 else "RIVAL TEAM WINS"
			col = TEAM_RING[_winner].lightened(0.3)
		_hud.draw_rect(Rect2(0, 260, 1152, 90), Color(0, 0, 0, 0.6))
		_hud.draw_string(_font, Vector2(0, 312), text, HORIZONTAL_ALIGNMENT_CENTER, 1152, 40, col)
		_hud.draw_string(_font, Vector2(0, 340), "R: REMATCH", HORIZONTAL_ALIGNMENT_CENTER, 1152, 16, Color("#F0F4F8"))


## Four slots at the bottom centre: your three abilities (cooldown drains upward, charge pips
## for a move with charges) and the ultimate with its meter.
func _draw_ability_bar() -> void:
	if _fighters.is_empty():
		return
	var f: Dictionary = _fighters[controlled]
	var accent: Color = LINES[f["line"]]["accent"]
	var x0 := 576.0 - 2.0 * 66.0
	for slot in 4:
		var box := Rect2(x0 + slot * 66.0, 580.0, 60.0, 52.0)
		var ready := false
		var fill := 0.0
		var name := ""
		var pips: Array = []
		if slot < 3:
			if slot >= f["abilities"].size():
				continue
			var m: String = f["abilities"][slot]
			name = String(MOVES[m]["name"]).split(" ")[-1].to_upper()
			if f["charge_cds"].has(m):
				pips = f["charge_cds"][m]
				ready = f["cds"][m] <= 0.0
				fill = 1.0 - clampf(pips.min() / MOVES[m]["cooldown"], 0.0, 1.0)
			else:
				ready = f["cds"][m] <= 0.0
				fill = 1.0 - clampf(f["cds"][m] / MOVES[m]["cooldown"], 0.0, 1.0)
		else:
			if not f["final"]:
				continue   # no signature before the final stage
			name = String(LINES[f["line"]]["signature"]).split(" ")[-1].to_upper()
			ready = f["meter"] >= 100
			fill = f["meter"] / 100.0
		_hud.draw_rect(box, Color(0.07, 0.09, 0.11, 0.85))
		_hud.draw_rect(Rect2(box.position + Vector2(0, box.size.y * (1.0 - fill)), Vector2(box.size.x, box.size.y * fill)), Color(accent, 0.35 if not ready else 0.6))
		_hud.draw_rect(box, (accent.lightened(0.4) if int(_crowd_t * 8) % 2 == 0 else accent) if ready else Color("#75604D"), false, 2.0)
		_hud.draw_string(_font, box.position + Vector2(5, 14), str(slot + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#F0F4F8"))
		_hud.draw_string(_font, box.position + Vector2(0, 44), name.left(8), HORIZONTAL_ALIGNMENT_CENTER, 60, 7, Color(1, 1, 1, 0.9 if ready else 0.5))
		for c in pips.size():
			_hud.draw_rect(Rect2(box.position + Vector2(38 + c * 6, 6), Vector2(4, 4)), accent.lightened(0.3) if pips[c] <= 0.0 else Color(0.3, 0.3, 0.3))


func _ellipse(c: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for k in 16:
		var a := TAU * k / 16.0
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts
