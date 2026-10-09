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
	# The River Listener line (Tide, then Tide/Hollow; Preston's 2026-09 brief, the Controller row
	# of arena-roles-roster-proposal-2026-10-08.md; Claude, 2026-10-08). Working names.
	{"forms": [["listener", "res://data/creatures/601_listener.tres"], ["caller", "res://data/creatures/602_caller.tres"], ["warden", "res://data/creatures/603_warden.tres"]],
		"signature": "Hush", "accent": Color("#3fb0a8")},
	# The Canvaswing line (Gale; roster draft line 15, DESIGN_RULES "Gale shelter", the shield
	# support row of arena-roles-roster-proposal-2026-10-08.md; Claude, 2026-10-08). Working names.
	{"forms": [["canvaswing", "res://data/creatures/1501_canvaswing.tres"], ["windcut", "res://data/creatures/1502_windcut.tres"], ["galeshear", "res://data/creatures/1503_galeshear.tres"]],
		"signature": "Gale Shear", "accent": Color("#a9bfd4")},
	# The Dustkite line (Gale; roster draft line 14, the Spotter row of the roles proposal;
	# Claude, 2026-10-09). Working names.
	{"forms": [["dustkite", "res://data/creatures/1401_dustkite.tres"], ["waywhistle", "res://data/creatures/1402_waywhistle.tres"], ["highsignal", "res://data/creatures/1403_highsignal.tres"]],
		"signature": "High Signal", "accent": Color("#e8e2cf")},
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
	# The Rimefin line, rekit from its remade physiology (Preston, 2026-10-09): a long low
	# catfish ambusher that lies in the silt, lunges, grips and drags. Basic Needle Bite; 1 Lunge
	# (a rush that bites and flings the target back behind it); 2 Silt Dive (the old Sinkhole:
	# under the riverbed, up behind the target, the next bite sharpened); 3 Riptide (from stage
	# 2); passive Ambush (from stage 2: the first bite out of the silt, or on an enemy that is
	# not watching it, hits harder); 4 Undertow. Phase, Deep Jet, Pressure Jet and the hover
	# are gone. Role Ambusher, damage group. Drafts for Grok.
	"rimefin": {"moves": ["needle_bite"], "abilities": ["lunge", "sinkhole"], "profile": "skirmish"},
	"riftfin": {"moves": ["needle_bite"], "abilities": ["lunge", "sinkhole", "riptide"], "hp": 1.0, "speed": 1.1, "passive": "ambush", "profile": "skirmish"},
	"scourmaw": {"role": "Ambusher", "moves": ["needle_bite"], "abilities": ["lunge", "sinkhole", "riptide"], "hp": 1.15, "speed": 1.0, "passive": "ambush", "profile": "skirmish"},
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
	"oxbowarchon": {"role": "Artillery", "moves": ["jade_lance"], "abilities": ["rail_shot", "kingstone_lift", "rail_recoil"], "speed": 0.7, "hp": 1.3,
		"passive": "bound_slabs", "profile": "kite", "far_bonus": 1.3},
	# Punchybuns line (Electric; Claude, 2026-10-08; Grok's numbers): a ferret who protects the
	# people it loves. Punchybun: the round kit: jabs, dances, and already puts its star on a
	# friend. Sparkjab: the boxer: Counter Jab arrives; Guardian. Starward: Starshield.
	"punchybun": {"moves": ["jab"], "abilities": ["static_dance", "star_guard"], "speed": 1.1, "hp": 0.95, "profile": "escort"},
	"sparkjab": {"moves": ["jab"], "abilities": ["static_dance", "star_guard", "counter_jab"], "speed": 1.15, "hp": 1.05,
		"passive": "chain", "profile": "escort"},
	"starward": {"role": "Protector", "moves": ["jab"], "abilities": ["static_dance", "star_guard", "counter_jab"], "speed": 1.1, "hp": 1.25,
		"passive": "chain", "profile": "escort"},
	# River Listener line (Tide, Tide/Hollow at the final; Claude, 2026-10-08; Grok's numbers): the
	# defensive scout Preston chose guards and interruptions for, the arena's Controller. Cutbank
	# Listener taps and calls: Echo Tap, Interrupt Call, Deep Brace. Bend Caller lays Still Water
	# and listens (enemy telegraphs near it take longer). Quietwater Warden: Hush.
	"listener": {"moves": ["echo_tap"], "abilities": ["interrupt_call", "deep_brace"], "speed": 1.15, "hp": 0.95, "profile": "escort"},
	"caller": {"moves": ["echo_tap"], "abilities": ["interrupt_call", "deep_brace", "still_water"], "speed": 1.05, "hp": 1.1,
		"passive": "listening", "profile": "escort"},
	"warden": {"role": "Controller", "moves": ["echo_tap"], "abilities": ["interrupt_call", "deep_brace", "still_water"], "speed": 0.95, "hp": 1.3,
		"passive": "listening", "profile": "escort"},
	# Canvaswing line (Gale; Claude, 2026-10-08; Grok's numbers): the Gale shelter (DESIGN_RULES:
	# more HP than the runner, less speed, no guard ultimate). Canvaswing covers and breaks shots:
	# Shear, Sail Cover, Downdraft. Windcut lifts a pressed ally out and breaks the wind for
	# those beside it. Galeshear: Gale Shear, one wing sweep that throws every enemy to the edge.
	"canvaswing": {"moves": ["shear"], "abilities": ["sail_cover", "downdraft"], "speed": 1.2, "hp": 0.9, "profile": "escort"},
	"windcut": {"moves": ["shear"], "abilities": ["sail_cover", "downdraft", "lift"], "speed": 1.15, "hp": 1.05,
		"passive": "windbreak", "profile": "escort"},
	"galeshear": {"role": "Shelter", "moves": ["shear"], "abilities": ["sail_cover", "downdraft", "lift"], "speed": 1.1, "hp": 1.2,
		"passive": "windbreak", "profile": "escort"},
	# Dustkite line (Gale; Claude, 2026-10-09; Grok's numbers): the Spotter. Watchful, never the
	# runner, never the interrupt (DESIGN_RULES). Dustkite darts, marks and bluffs; Waywhistle
	# perches and spots; Highsignal: High Signal.
	"dustkite": {"moves": ["whistle_dart"], "abilities": ["signal_mark", "decoy_call"], "speed": 1.25, "hp": 0.85, "profile": "kite", "far_bonus": 1.15},
	"waywhistle": {"moves": ["whistle_dart"], "abilities": ["signal_mark", "decoy_call", "vantage"], "speed": 1.2, "hp": 1.0,
		"passive": "spotter", "profile": "kite", "far_bonus": 1.15},
	"highsignal": {"role": "Spotter", "moves": ["whistle_dart"], "abilities": ["signal_mark", "decoy_call", "vantage"], "speed": 1.15, "hp": 1.15,
		"passive": "spotter", "profile": "kite", "far_bonus": 1.2},
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
	# The Rimefin line (Tide, Hollow as silt). Phase and Deep Jet stay defined for old data and
	# checks but no kit carries them (2026-10-09).
	"needle_bite": {"name": "Needle Bite", "damage": 11, "cooldown": 1.0, "range": 30.0},
	"lunge": {"name": "Lunge", "damage": 12, "cooldown": 6.0, "range": 110.0, "mobility": true},
	"phase": {"name": "Phase", "damage": 0, "cooldown": 3.0, "range": 0.0, "mobility": true},
	"deep_jet": {"name": "Deep Jet", "damage": 18, "cooldown": 1.7, "range": 150.0},
	"sinkhole": {"name": "Silt Dive", "damage": 0, "cooldown": 5.0, "range": 0.0, "mobility": true},
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
	"jab": {"name": "Spark Jab", "damage": 10, "cooldown": 0.7, "range": 26.0},
	"static_dance": {"name": "Static Dance", "damage": 0, "cooldown": 7.0, "range": 0.0},
	"star_guard": {"name": "Star Guard", "damage": 0, "cooldown": 8.0, "range": 120.0},
	"counter_jab": {"name": "Counter Jab", "damage": 12, "cooldown": 6.0, "range": 140.0, "mobility": true},
	# River Listener line: a sonar tap, a call that cancels wind-ups, a brace, still water.
	"echo_tap": {"name": "Echo Tap", "damage": 8, "cooldown": 1.1, "range": 80.0},
	"interrupt_call": {"name": "Interrupt Call", "damage": 6, "cooldown": 8.0, "range": 0.0},
	"deep_brace": {"name": "Deep Brace", "damage": 0, "cooldown": 10.0, "range": 0.0},
	"still_water": {"name": "Still Water", "damage": 0, "cooldown": 12.0, "range": 120.0},
	# Canvaswing line: a sail slash, a sail over an ally, a downdraft that grounds shots, a lift.
	"shear": {"name": "Shear", "damage": 9, "cooldown": 1.0, "range": 30.0},
	"sail_cover": {"name": "Sail Cover", "damage": 0, "cooldown": 8.0, "range": 120.0},
	"downdraft": {"name": "Downdraft", "damage": 0, "cooldown": 10.0, "range": 120.0},
	"lift": {"name": "Lift", "damage": 0, "cooldown": 9.0, "range": 140.0, "mobility": true},
	# Oxbowarchon's Kingstone Lift: the nearest rock rises and is thrown at the target; with no rock
	# in reach the target itself is seized and flung (the reference video's psychic lift).
	"kingstone_lift": {"name": "Kingstone Lift", "damage": 10, "cooldown": 11.0, "range": 150.0},
	# Dustkite line: a whistling dart, a mark, a bluff, a perch.
	"whistle_dart": {"name": "Whistle Dart", "damage": 9, "cooldown": 1.0, "range": 130.0},
	"signal_mark": {"name": "Signal Mark", "damage": 0, "cooldown": 7.0, "range": 160.0},
	"decoy_call": {"name": "Decoy Call", "damage": 0, "cooldown": 9.0, "range": 160.0},
	"vantage": {"name": "Vantage", "damage": 0, "cooldown": 10.0, "range": 0.0, "mobility": true},
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
	"fireball": E.EMBER, "beam": E.TIDE, "seed": E.BLOOM, "needle_bite": E.TIDE, "lunge": E.TIDE,
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
	"echo_tap": E.TIDE, "interrupt_call": E.TIDE, "Hush": E.HOLLOW,
	"shear": E.GALE, "Gale Shear": E.GALE, "kingstone_lift": E.ELECTRIC,
	"whistle_dart": E.GALE, "High Signal": E.GALE,
}

const FACINGS := ["e", "se", "s", "sw", "w", "nw", "n", "ne"]  # clockwise from east, 45 degrees apart
const SCALE := 3.0
const SPEED := 70.0                    # map pixels a second
## Movement model (Preston, 2026-10-08 night: "more dynamic like the 2D arena video"): creatures
## carry momentum, every creature owns a short dash, the AI circles in arcs and steps out of a
## telegraph it sees coming. Drafts for Grok.
const ACCEL := 6.0                     # reaches full speed in about a sixth of a second (times SPEED)
const DECEL := 9.0
const DASH_SPEED := 260.0
const DASH_SECONDS := 0.18             # about 47 px
const DASH_COOLDOWN := 3.0
const DODGE_SECONDS := 0.13            # the sidestep: about 34 px
const DODGE_COOLDOWN := 4.0
const DODGE_INVULN := 0.2
const DODGE_WINDOW := 0.16             # it steps when the telegraph has this long left
## The camera (same request): a drop-in at the start, a lean toward the action, punch-ins on
## signatures and knockouts, and a crowd banner on a big hit.
const CAM_ENTRY_ZOOM := 1.6
const CAM_ACTION_ZOOM := 1.12
const CAM_ACTION_SPAN := 150.0         # the fighters inside this span pull the camera in
const BANNER_HIT := 25                 # a hit this big gets "WHAT A HIT!"
## Charms, after Smite's relics (Preston, 2026-10-08 night: "bring Smite combat and synthesize it"):
## every creature carries one active on a long cooldown, picked before the fight (yours in the
## picker, the AI's by role). Names are placeholders; numbers are drafts for Grok.
const CHARMS := {
	"beads": {"name": "Beads", "cooldown": 50.0, "what": "breaks every hold on it, 1 s of immunity"},
	"blink": {"name": "Blink", "cooldown": 45.0, "what": "teleports 90 px the way it goes"},
	"aegis": {"name": "Aegis", "cooldown": 60.0, "what": "1.5 s untouchable, and still"},
	"thorns": {"name": "Thorns", "cooldown": 55.0, "what": "3 s: whoever hits it takes 40% back"},
	"spear": {"name": "Spear", "cooldown": 50.0, "what": "its target takes 20% more from everyone for 5 s"},
	"emblem": {"name": "Emblem", "cooldown": 50.0, "what": "enemies within 45 px slowed 40% for 3 s"},
	"shell": {"name": "Shell", "cooldown": 55.0, "what": "allies within 60 px shielded 15% of max HP for 4 s"},
	"wings": {"name": "Wings", "cooldown": 55.0, "what": "allies within 60 px hasted 3 s"},
}
const CHARM_BY_ROLE := {"Tank": "thorns", "Bruiser": "beads", "Skirmisher": "blink", "Assassin": "blink", "Ambusher": "beads", "Artillery": "aegis",
	"Protector": "shell", "Controller": "beads", "Shelter": "wings"}
const BLINK_DISTANCE := 90.0
const AEGIS_SECONDS := 1.5
const THORNS_SECONDS := 3.0
const THORNS_BACK := 0.4
const SPEAR_SECONDS := 5.0
const SPEAR_MORE := 1.2
const EMBLEM_RADIUS := 45.0
const EMBLEM_SECONDS := 3.0
const EMBLEM_SLOW := 0.6
const SHELL_RADIUS := 60.0
const SHELL_SHIELD := 0.15
const SHELL_SECONDS := 4.0
const WINGS_SECONDS := 3.0
const BEADS_IMMUNE := 1.0
## The physical verbs (Preston, 2026-10-08 night, item 3 of "more dynamic like the video"):
## a grab that holds and hurls, a rock lifted and thrown, a beam that pins to the wall and
## drags, and two beams clashing. Drafts for Grok.
const GRAB_HOLD := 0.35                # seized: held over the grabber this long, then thrown
const GRAB_FLING := 3.0                # the throw's push (a carry: it slams into walls and rocks)
const LIFT_REACH := 80.0               # Kingstone Lift takes the nearest rock this close
const LIFT_RISE := 0.5                 # seconds rising
const LIFT_FLIGHT := 0.35              # seconds in the air to the target
const LIFT_HEIGHT := 30.0
const ROCK_THROW_DAMAGE := {"boulder": 22, "stone": 14, "crate": 9}
const ROCK_THROW_RADIUS := 26.0
const PIN_PUSH := 70.0                 # px/s a pinning beam shoves its target along its line
const PIN_TICK := 0.15                 # damage ticks while pinned to the wall
const PIN_TICK_DAMAGE := 3
const PIN_TURN := 1.6                  # rad/s the beam swings after a target, dragging it along the wall
const CLASH_PUSH := 40.0               # px/s the stronger beam pushes the clash point
## Moves as hitboxes (item 4): a melee move is a sweep in front of its user with an active
## moment; the target must be inside the arc then, or the move whiffs. Area moves and lobs land
## on the spot the telegraph showed. Drafts for Grok.
const SWEEP_ACTIVE := 0.07             # seconds after the telegraph ends before the sweep connects
const SWEEP_ARC := 1.25                # radians either side of the aim
const SWEEP_REACH_EXTRA := 8.0
## Terrain in motion (item 5): a burrow leaves a trench along its tunnel, a riptide drifts.
const TRENCH_SECONDS := 8.0
const TRENCH_WIDTH := 9.0              # px either side of the tunnel line
const TRENCH_SLOW := 0.6               # enemies crossing it (allies cross free, no dashes over it)
const RIPTIDE_DRIFT := 18.0            # px/s a whirlpool hunts the nearest enemy
const RIPTIDE_HUNT := 90.0             # within this far
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
	"echo_tap": ["line", 0.25], "still_water": ["area", 0.4],   # Interrupt Call and Deep Brace go at once
	"shear": ["melee", 0.22], "downdraft": ["area", 0.3],      # Sail Cover and Lift go at once
	"kingstone_lift": ["area", 0.5],
	"whistle_dart": ["line", 0.22],   # Signal Mark, Decoy Call and Vantage go at once
	"needle_bite": ["melee", 0.2], "lunge": ["charge", 0.3],
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
## Kit Sense (Claude, 2026-10-08): how a creature's AI chooses, after the shape of Valve's Dota
## 2 bot layer (modes with desires, per-ability "consider" desires, the highest wins) and
## utility scoring, rebuilt for Hollowtide. docs/research/combat-ai-references-2026-10-08.md
## Essence combos (Claude, 2026-10-08, "combat upgrades"), after the shape of Genshin's
## elemental reactions (an element applied becomes an aura on the target; a second element
## reacts with it, consuming it; some reactions multiply the hit, some do their own thing):
## our statuses are the auras. Stone SHATTERS the glass on a Glassed target (x1.5, glass
## gone); Ember KINDLES roots away (x1.3, roots gone); Tide QUENCHES a smouldering target in
## scalding steam (x1.3, a daze, smoulder gone); Electric CONDUCTS through a riptide to
## everyone else standing in it; Bloom OVERGROWS a target standing in water (a short root).
## The combo is read off the attacker's last move's essence. docs/research/combat-references-2026-10-08.md
const SHATTER_BONUS := 1.5
const KINDLE_BONUS := 1.3
const QUENCH_BONUS := 1.3              # the steam scalds
const QUENCH_DAZE := 0.5
const CONDUCT_SHARE := 0.5
const OVERGROW_ROOT := 0.6             # Bloom on a target standing in water: the growth takes hold
const KO_HITSTOP := 0.3                # the KO beat: a long hitstop, a ring, the drop
## Crowd control after League's taxonomy, knockback after Smash, the match after Unite
## (docs/research/combat-references-2026-10-08.md, sections 3 to 5). Drafts for Grok.
const AIRBORNE_LIFT := 14.0            # how high a launched creature is drawn
const TENACITY := 1.4                  # Tanks shed stuns, roots and dazes this much faster
const KNOCKBACK_GROWTH := 0.6          # a push grows by up to this much as the target's HP falls
const MATCH_SECONDS := 120.0           # team fights end on points after this
const CREST_RADIUS := 38.0             # the centre circle: the one objective
const CREST_METER := 6.0               # meter a second for a final holding it alone
const CREST_HEAL := 1                  # HP every half second for everyone holding it alone
## Frame data after Street Fighter, role passives after Overwatch, part breaks after Monster
## Hunter (docs/research/combat-references-2026-10-08.md, sections 6 to 8). Drafts for Grok.
const RECOVERY := {"melee": 0.2, "line": 0.3, "area": 0.4, "charge": 0.45, "rail": 0.6, "": 0.15}   # by telegraph kind; untelegraphed (dashes, guards) recover fastest
const RECOVERY_OF := {"jab": 0.15, "claw": 0.2, "pounce": 0.25, "club_slam": 0.45, "plate_lunge": 0.45, "slab_vortex": 0.4,
	"molten_cannon": 0.55, "ground_spikes": 0.45, "root_rampart": 0.5, "rail_shot": 0.6, "vent_blast": 0.35, "counter_jab": 0.2,
	"echo_tap": 0.2, "interrupt_call": 0.3, "still_water": 0.4, "shear": 0.2, "downdraft": 0.35, "lift": 0.25, "kingstone_lift": 0.5,
	"whistle_dart": 0.2, "signal_mark": 0.2, "decoy_call": 0.1, "vantage": 0.25, "needle_bite": 0.2, "lunge": 0.35}
const AMBUSH_MULT := 1.3               # the Ambush passive: the first bite out of the silt, or on an enemy not watching it
## The Dustkite line (Claude, 2026-10-09). Drafts for Grok.
const MARK_BONUS := 1.15               # the team's hits on a marked enemy land this much harder
const DECOY_SECONDS := 0.5             # a false telegraph lasts this long
const VANTAGE_REACH := 90.0            # the nearest rock this close is a perch
const VANTAGE_RANGE := 30.0            # a perched dart reaches this much further
const SPOTTER_RANGE := 120.0           # the passive marks the first enemy this close
const SPOTTER_AGAIN := 10.0            # and the same enemy again only after this long
const SIGNAL_SECONDS := 8.0            # High Signal's marks
const SIGNAL_DOUBLE := 2.0             # the team's next ability on each marked enemy
const PERCH_SECONDS := 6.0             # the AI holds a perch this long at most
const PERCH_WORTH := 160.0             # and only while an enemy is within a perched dart's reach

## The Canvaswing line (Claude, 2026-10-08). Drafts for Grok.
const SAIL_SHIELD := 20                # Sail Cover: the shield on an ally
const SAIL_SECONDS := 4.0
const DOWNDRAFT_RADIUS := 45.0         # Downdraft: enemy shots and lobs that enter it are grounded
const DOWNDRAFT_SECONDS := 5.0
const LIFT_DISTANCE := 60.0            # Lift: the ally is flown this far toward its team
const WINDBREAK_RADIUS := 30.0         # passive Windbreak: allies this close take less
const WINDBREAK_CUT := 0.9
const GALE_PUSH := 4.0                 # Gale Shear: every enemy is carried to the edge with this push
const GALE_TAILWIND := 2.0             # and allies get haste this long
## The River Listener line (Claude, 2026-10-08). Drafts for Grok.
const CALL_RADIUS := 55.0              # Interrupt Call: every enemy this close loses its wind-up
const CALL_STUN := 0.5
const BRACE_SECONDS := 2.5             # Deep Brace: planted, halved, pushes come back
const BRACE_GUARD := 0.5
const STILL_RADIUS := 50.0             # Still Water: enemy cooldowns run at half speed in it
const STILL_SECONDS := 4.0
const STILL_RATE := 0.5
const LISTEN_RADIUS := 60.0            # passive Listening: enemy telegraphs this close take longer
const LISTEN_FACTOR := 1.3
const HUSH_SECONDS := 3.0              # Hush: every enemy wind-up cancelled, abilities locked
const HUSH_DAZE := 0.5
const HUSH_RADIUS := 220.0             # and still water over the whole floor
const HITSTUN := 0.25                  # a real blow (HITSTUN_FROM or more) stops the one hit acting this long
const HITSTUN_FROM := 8
const COUNTER_BONUS := 1.25            # a hit that lands during the target's wind-up
const COUNTER_BREAK := 12              # and one this big breaks the wind-up (charges and armoured tanks excepted)
const PUNISH_BONUS := 1.15             # a hit that lands while the target recovers from its own move
const TANK_METER_GIVEN := 0.6          # hits on a Tank charge the attacker's meter this much
const TANK_KNOCKBACK := 0.7            # and move it this much
const KO_HASTE := 2.5                  # a Damage-role KO: haste this long
const WOUND_SECONDS := 3.0             # a Damage-role hit: the target's mending is cut for this long
const WOUND_CUT := 0.7
const REGEN_DELAY := 1.5               # a Protector mends itself after this long unhit
const REGEN_TICK := 0.4
const REGEN_HP := 1
const BREAK_WEAK := 1.25               # a cracked rock takes this much more: its weakness is exposed
const SHARD_LIFE := 8.0                # a break reward lies on the floor this long
const SHARD_METER := 10                # taken by a final
const SHARD_HP := 4                    # or by anyone else
const DESIRE_LOW := 0.25
const DESIRE_MODERATE := 0.5
const DESIRE_HIGH := 0.75
const DESIRE_VERYHIGH := 0.9
const DESIRE_BASIC := 0.4              # the basic attack's own score: an ability needs a reason to beat it
const CALL_SECONDS := 2.0              # a newly held enemy is its opponents' called target this long
const CALL_REACH := 160.0              # and damage dealers this close switch to it
const FINISH_REACH := 130.0            # a kill on the table within this is the finish mode
const PEEL_MOVES := ["club_slam", "counter_jab", "star_guard", "ground_spikes", "root_snare", "vent_blast", "slab_vortex", "plate_lunge", "glass_guard", "interrupt_call", "sail_cover", "lift"]
const FEINT_HOP := 55.0                # Ember Feint: the hop back out of reach
const FEINT_INVULN := 0.25
const RECOIL_HOP := 70.0               # Rail Recoil: the hop away from the nearest enemy
const RECOIL_INVULN := 0.3             # untouchable for the hop
const RAIL_WIDTH := 13.0               # Rail Shot: how close to the line a creature must stand
## The Punchybuns line (2026-10-08). Drafts for Grok.
const GUARD_SHIELD := 25               # Star Guard: damage the star shield absorbs
const GUARD_SHIELD_SECONDS := 4.0
## Punchybuns after Smite's Ravana (Preston, 2026-10-08: "the passive and the basic attacking
## punching at least"). The basic is a three-punch chain whose third punch hooks through
## everyone in front; every hit the line lands adds to its Chain, and at CHAIN_PAYOUT the
## chain pays out (stage 2 up): a shield worth a share of max HP on it and on the allies beside
## it, and a burst of speed, stacking to CHAIN_STACKS. Drafts for Grok.
const CHAIN_PAYOUT := 8                # hits per payout
const CHAIN_STACKS := 3                # shields stack this many times
const CHAIN_SHIELD := 0.07             # of max HP, each payout
const CHAIN_SHIELD_SECONDS := 6.0
const CHAIN_HASTE := 2.0
const CHAIN_RESET := 2.0               # the punch chain restarts after this long without a punch
const HOOK_BONUS := 1.3                # the third punch
const HOOK_ARC := 1.3                  # radians either side of the aim it reaches
## Crowd control diminishing returns after Smite: each hard hold a creature takes adds a stack
## that shortens the holds after it by DR_STEP, for DR_SECONDS, up to DR_MAX stacks.
const DR_STEP := 0.2
const DR_SECONDS := 15.0
const DR_MAX := 4
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
## Story mode (Claude, 2026-10-09): the arena inside the world's first fight. The debug keys
## that restart or reshape the match are off, the hint line is the player's controls only, and
## match_over fires once the result has had its moment.
var story_mode := false
var picker_redirect := true            # run alone, the arena opens the matchup picker; a Hollow floor turns this off
var match_horn := true                 # the crowd horn at the start of a match; a Hollow floor has no crowd
signal match_over(winner: int)
var _over_t := 0.0
var _over_sent := false
const OVER_SECONDS := 2.2
var _clock := 0.0                       # seconds fought this match (the simulator reads it)
## The enemy you have told your creature to go for (-1: its own choice). Left/right cycle, up clears.
var player_target := -1
var control_slot := 0                  # which of your team you steer (the picker sets it)
var charm_pick := ""                   # your creature's charm (the picker sets it; "" means its role's)
var _aim_point := Vector2(INF, INF)    # where the telegraph showed an area move landing; INF when not firing from one
var _player_dir := Vector2.ZERO        # WASD / arrows, polled every frame
var poll_input := true                 # the checks turn this off and set _player_dir and _attack_held themselves
var _attack_held := false              # J or the left mouse button: the basic attack (Preston, 2026-10-09)
var _attack_was := false               # last frame's button, to see a tap
## Mouse aim (Preston, 2026-10-09, item 3): while the mouse is live, your creature aims at it.
var mouse_override := Vector2(INF, INF)   # the checks put the cursor here (a world point)
var _mouse_live := 0.0                 # the mouse counts as the aim for this long after it moved or clicked
const MOUSE_LIVE := 1.5
const AIM_CONE := 0.6                  # radians either side of the cursor line in which an enemy is the target
const LOCK_REACH := 40.0               # right click locks the enemy this close to the cursor
## Your reach on the floor (item 4): the basic's ring, the ghost toward the cursor, and the
## reach of an ability refused for range.
var _range_hint := {"r": 0.0, "t": 0.0}
const RANGE_HINT_SECONDS := 0.6
const AREA_SPOT := 16.0                # the landing spot drawn for lobs and area moves
## Follow-ups (item 5, Claude 2026-10-09; drafts for Grok): an ability that lands opens a window;
## a basic that lands inside it hits harder and refunds some of that ability's cooldown.
const FOLLOW_WINDOW := 0.9             # an ability's recovery plus the basic's telegraph is about 0.5 s, so 0.4 could never be met
const FOLLOW_MORE := 1.3
const FOLLOW_REFUND := 0.5
## Cast feedback (Preston, 2026-10-09: "I don't feel when I use my moves"): per card, how long
## it still lights after a good press and shakes after a failed one; and the reason line.
var _card_flash := {0: 0.0, 1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0}
var _card_shake := {0: 0.0, 1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0}
var _why := ""                         # why the last press failed, shown over the bar
var _why_t := 0.0
const CARD_FLASH := 0.25
const CARD_SHAKE := 0.3
const WHY_SECONDS := 1.0
const PRESS_PITCH := {-1: 0.9, 0: 1.0, 1: 1.12, 2: 1.25, 3: 0.8, 4: 1.4}   # the cast sound per slot (-1: the basic)
const YOUR_HEAVY := 15                 # a hit of yours this big nudges the camera
const YOUR_HITSTOP_EXTRA := 0.05
var _attack_buffer := 0.0              # a tap waits this long for the creature to be free (an input buffer, after fighting games)
var _aim_override := Vector2.ZERO      # a free swing: the direction the player chose instead of the target's
const ATTACK_BUFFER := 0.3
var _cam_zoom := 1.0
var _cam_zoom_to := 1.0
var _cam_focus := Vector2(192, 108)
var _cam_focus_to := Vector2(192, 108)
var _cam_punch_t := 0.0
var _cam_punch_zoom := 1.0
var _cam_punch_at := Vector2.ZERO
var _banner := ""
var _banner_t := 0.0
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
var start_arena := 0                   # the map the picker chose
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
	"lantern_ball", "light_slash", "lantern_flash", "glass_splash", "rock_dust", "vent_flame", "root_burst", "mark_glyph",
	# VFX pass 2 (2026-10-08, Preston: "use diffusion to upgrade all kits"): one-shots for the
	# newer kits, loops for statuses and zones. A sheet that is not on disk is simply not drawn.
	"sonar_ring", "sail_slash", "gust_lift", "jade_burst", "slam_shock", "steam_puff", "ember_patch", "spark_bolt",
	"star_shield", "molten_drip", "smoulder", "cocoon_stone", "seed_pod", "jade_spikes", "slab_vortex", "root_snare",
	"sail_cover", "riptide_whirl", "still_water", "downdraft_column", "glass_pool", "star_field"]
const IMPACT_SECONDS := 0.55
var _impact_frames := {}
var _shake := 0.0
var _cheer := 0.0
var _crowd_dots: Array[Dictionary] = []
var _crowd_t := 0.0
var _winner := -1
var _sounds: Array[AudioStreamPlayer] = []
var _sig_user := -1


## The walkable floor of the current map. A subclass with its own map (the Hollow dungeon
## floors, 2026-10-09) returns its own rectangle; every move, clamp and spawn asks this.
func _floor() -> Rect2:
	return ARENAS[_arena]["floor"]


func _ready() -> void:
	if picker_redirect and get_tree().current_scene == self:
		# Run on its own (Play, or F6 on this scene), the arena opens the matchup picker instead
		# of a default fight (Preston, 2026-10-09: "it auto starts a Tallowroot vs Kithflare battle").
		get_tree().call_deferred("change_scene_to_file", "res://scenes/move_preview.tscn")
		return
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
	_sig.hush.connect(_on_hush)
	_sig.gale_sweep.connect(_on_gale_sweep)
	_sig.high_signal.connect(_on_high_signal)
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
			var path := "res://assets/sprites/arena/vfx/%s/f%02d.png" % [name, k]
			if ResourceLoader.exists(path):
				frames.append(load(path))
		if frames.size() == 16:
			_impact_frames[name] = frames
	_set_arena(start_arena)
	_new_match()


# ---------------------------------------------------------------- setup

func _load_art(folder: String) -> Dictionary:
	var still := {}
	var walk := {}
	var foot := {}
	for f in FACINGS:
		still[f] = load("res://assets/sprites/arena/%s/small/%s.png" % [folder, f])
		foot[still[f]] = _foot_row(still[f])
		var frames: Array[Texture2D] = []
		for i in 8:
			var p := "res://assets/sprites/arena/%s/small/walk_%s_f%d.png" % [folder, f, i]
			if ResourceLoader.exists(p):
				frames.append(load(p))
				foot[frames[-1]] = _foot_row(frames[-1])
		# A walk cycle stands on its planted stance: every frame of it shares the deepest feet
		# row, so a lifted foot lifts and the body does not drop with it (Preston, 2026-10-09:
		# "the Warden still looks like it's floating when it walks"). The still is anchored alone.
		# The planted row is the deepest lowest row among the frames near the cycle's median: a
		# planted foot sets the stance, while a glider's wing tip dipping far below in one frame
		# does not lift the body for the other seven.
		if not frames.is_empty():
			var rows: Array[float] = []
			for tex in frames:
				rows.append(foot[tex])
			rows.sort()
			var median: float = rows[rows.size() / 2]
			var planted := 0.0
			for r in rows:
				if r <= median + 4.0:
					planted = maxf(planted, r)
			for tex in frames:
				foot[tex] = planted
		walk[f] = frames
	var used: Rect2i = still["s"].get_image().get_used_rect()
	return {"still": still, "walk": walk, "foot": foot, "width": float(used.size.x), "height": float(used.size.y)}


## The feet row of a sprite: the lowest row with a few opaque pixels, so a stray claw tip or a
## tail pixel does not set where the creature stands (the floating pass, 2026-10-09).
func _foot_row(tex: Texture2D) -> float:
	var img: Image = tex.get_image()
	var w: int = img.get_width()
	for y in range(img.get_height() - 1, -1, -1):
		var n := 0
		for x in w:
			if img.get_pixel(x, y).a > 0.03:
				n += 1
				if n >= 4:
					return float(y + 1)
	var used: Rect2i = img.get_used_rect()
	return float(used.position.y + used.size.y)


## Shows `tex` on fighter f with its feet on the body origin: every facing and every walk
## frame has its own feet row, so the anchor moves with the picture.
func _set_texture(f: Dictionary, tex: Texture2D) -> void:
	var sprite: Sprite2D = f["sprite"]
	if sprite.texture != tex:
		sprite.texture = tex
	sprite.offset = Vector2(0, tex.get_height() * 0.5 - f["art"]["foot"].get(tex, float(tex.get_height())))


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
	sprite.offset = Vector2(0, sprite.texture.get_height() * 0.5 - art["foot"][sprite.texture])
	# The shadow fits the body: wider creatures cast wider shadows, so nothing reads as floating.
	# A long low body (wider than it is tall: the frogs, the quadrupeds) casts its shadow under
	# the whole body, lifted toward its middle, instead of a disc hanging off its toes.
	var low: bool = art["width"] >= art["height"] * 1.1
	var depth: float = art["height"] * 0.22 if low else 0.0
	shadow.polygon = _ellipse(Vector2(0, -depth), maxf(9 + 3 * stage, art["width"] * 0.36), maxf(3 + stage, art["width"] * 0.13 + depth * 0.6))
	if ring:
		ring.points = _ellipse(Vector2.ZERO, maxf(10 + 3 * stage, art["width"] * 0.38), maxf(4 + stage, art["width"] * 0.14))
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
	# Role passives (after Overwatch): a line's earlier stages play the role its final plays.
	var role: String = kit.get("role", KITS[LINES[line]["forms"][2][0]].get("role", ""))
	var group: String = "tank" if role == "Tank" else ("support" if role in ["Protector", "Controller", "Shelter", "Spotter"] else "damage")
	var fighter := {"line": line, "stage": stage, "form": form[0], "name": data.creature_name, "closeup": closeup, "essences": essences,
		"body": body, "sprite": sprite, "art": art, "facing": facing, "kit": kit["moves"] + abilities, "abilities": abilities,
		"charge_cds": charge_cds, "speed": kit.get("speed", 1.0),
		"passive": passive, "hollow": passive == "absence", "lantern": passive in ["lantern_charge", "lantern_mark"],
		"hp": max_hp, "max_hp": max_hp, "power": 1.0 + STAGE_POWER * stage, "meter": 0, "cds": cds, "act": 1.0,
		"flash": 0.0, "stun": 0.0, "dazzle": 0.0, "phase": 0.0, "echo": 0.0, "solid": SURFACE_START,
		"surface_in": SURFACE_EVERY, "absence": 0.0, "charge": 0.0, "ember": 0.0, "arc": 0.5, "arc_pts": PackedVector2Array(),
		"role": role, "group": group, "profile": kit.get("profile", ""), "far_bonus": kit.get("far_bonus", 1.0),
		"recovering": "", "since_hit": 99.0, "wound": 0.0, "regen_tick": 0.0, "mend_acc": 0.0,
		"brace": 0.0, "hush": 0.0,
		"chain": 0, "chain_hits": 0, "chain_t": 0.0, "chain_stacks": 0, "dr": 0, "dr_t": 0.0,
		"vel": Vector2.ZERO, "dash": 0.0, "dash_dir": Vector2.ZERO, "dash_cd": 0.0, "dodge_cd": 0.0, "echo_t": 0.0,
		"charm": CHARM_BY_ROLE.get(role, "beads"), "charm_cd": 0.0, "thorns": 0.0, "sunder": 0.0, "slowed": 0.0, "aegis": 0.0, "cc_immune": 0.0,
		"grabbed": 0.0, "grab_by": -1, "grab_dir": Vector2.RIGHT, "pinned": 0.0, "pin_tick": 0.0,
		"perched": -1, "perch_t": 0.0, "spot_cd": {}, "signal": 0,
		"follow_t": 0.0, "follow_m": "",
		"rooted": 0.0, "crippled": 0.0, "disengage": 0.0, "hidden": false, "smoulder": 0.0, "smoulder_tick": 0.0,
		"sink": 0.0, "sink_to": Vector2.ZERO, "sink_from": Vector2.ZERO, "eroded": 0.0,
		"walk": 0.0, "dust": 0.0, "ai": ai, "strafe": 1.0, "think": 0.0, "down": 0.0,
		"team": team, "target": -1, "retarget": 0.0, "dealt": 0, "down_at": -1.0,
		"carry": Vector2.ZERO, "carry_t": 0.0, "carried_by": -1,
		"heat": 0.0, "ram_t": 0.0, "ram_dir": Vector2.ZERO, "ram_dmg": 0,
		"windup": {}, "shiver": Vector2.ZERO,
		"ram_return": false, "ram_end_hit": false, "ram_grip": false, "after": "", "after_aim": Vector2.ZERO,
		"invuln": 0.0, "marked": 0.0, "tackle": {}, "ring": ring, "ambush": 0.0,
		"guard": 0.0, "glassed": 0.0, "glassed_tick": 0.0,
		"cocoon": 0.0, "cocoon_dmg": 0, "slabs": SLAB_COUNT if passive == "bound_slabs" else 0, "slab_t": 0.0,
		"final": stage == 2,   # only a line's final stage has the signature (Preston, 2026-10-08)
		"shield": 0, "shield_t": 0.0, "shield_anim": "star_shield", "charged": 0.0, "haste": 0.0,
		"mode": "engage", "held_was": false,
		"anim": "", "anim_t": 0.0, "anim_len": 0.0, "anim_dir": Vector2.RIGHT, "last_move": "",
		"airborne": 0.0, "airborne_len": 0.0, "crest_acc": 0.0}
	return fighter


func _new_match() -> void:
	for f in _fighters:
		f["body"].queue_free()
	_fighters.clear()
	_effects.clear()
	_called = {0: {"target": -1, "until": 0.0}, 1: {"target": -1, "until": 0.0}}
	ai_log.clear()
	_crest_team = -1
	_on_points = false
	_labels.clear()
	_walls.clear()
	_winner = -1
	_over_t = 0.0
	_over_sent = false
	_clock = 0.0
	controlled = clampi(control_slot, 0, team_size - 1)
	player_target = -1
	# The camera drops in from above at the start.
	_cam_zoom = CAM_ENTRY_ZOOM
	_cam_focus = Vector2(192, 108)
	_cam_punch_t = 0.0
	_banner_t = 0.0
	_hitstop = 0.0
	player_target = -1
	_sig.active = false   # a signature mid-flight dies with the old match
	_sig_user = -1
	var floor_rect: Rect2 = _floor()
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
			_fighters.append(_make_fighter(members[k][0], members[k][1], at, "e" if side == 0 else "w", side == 1, side, side == 0 and k == controlled))
	if charm_pick != "" and CHARMS.has(charm_pick) and controlled < _fighters.size():
		_fighters[controlled]["charm"] = charm_pick
	_cheer = 1.0
	if is_inside_tree() and match_horn:
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
	if event is InputEventMouseMotion:
		_mouse_live = MOUSE_LIVE
		return
	if event is InputEventMouseButton and event.pressed:
		_mouse_live = MOUSE_LIVE
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_lock_under_cursor()
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var k: int = event.physical_keycode
	if story_mode and k in [KEY_F, KEY_G, KEY_T, KEY_N, KEY_B, KEY_M, KEY_R]:
		return   # the story fight is what it is: no restarts, no swaps
	if k >= KEY_1 and k <= KEY_3:
		cast(k - KEY_1)
	elif k == KEY_4:
		_press_signature()
	elif k == KEY_SPACE:
		_player_dash()
	elif k == KEY_C:
		if not _fighters.is_empty() and not auto_you:
			if _use_charm(controlled):
				_press_ok(4)
			else:
				var cf: Dictionary = _fighters[controlled]
				_press_fail(4, ("%s IN %.0f S" % [String(CHARMS[cf["charm"]]["name"]).to_upper(), cf["charm_cd"]]) if cf["charm_cd"] > 0.0 else "NO MOMENT FOR IT")
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
	elif k == KEY_L:
		show_ai_log = not show_ai_log
	elif k == KEY_E or k == KEY_Q:
		_cycle_target(1 if k == KEY_E else -1)
	elif k == KEY_TAB:
		player_target = -1
		_label(controlled, "Auto target")


## 4: your ultimate, with the reason when it cannot go.
func _press_signature() -> void:
	if _fighters.is_empty() or _winner >= 0 or _sig.active:
		return
	var f: Dictionary = _fighters[controlled]
	if not f["final"]:
		_press_fail(3, "NO ULTIMATE YET")
		return
	if f["meter"] < 100:
		_press_fail(3, "ULTIMATE %d%%" % int(f["meter"]))
		return
	if f["hp"] <= 0 or f["stun"] > 0.0:
		_press_fail(3, "HELD")
		return
	_press_ok(3)
	signature(controlled)


## SPACE: your creature dashes the way you are steering (or the way it faces), with the same
## short safety a dodge has. Dashes and dodges share one cooldown.
func _player_dash() -> void:
	if _fighters.is_empty() or auto_you:
		return
	var f: Dictionary = _fighters[controlled]
	var dir: Vector2 = _player_dir if _player_dir.length() > 0.01 else _facing_vector(f["facing"])
	if _dash(controlled, dir, DASH_SECONDS, DODGE_INVULN):
		_label(controlled, "Dash")


func _facing_vector(facing: String) -> Vector2:
	var idx: int = FACINGS.find(facing)
	return Vector2.RIGHT.rotated(idx * TAU / 8.0) if idx >= 0 else Vector2.RIGHT


## Where an area move lands: the spot the telegraph showed, or the target's spot when the move
## went off without one (a direct call from a check, an untelegraphed cast).
func _spot(foe: Dictionary) -> Vector2:
	return _aim_point if _aim_point.x != INF else foe["body"].position


## Fighter i seizes fighter t: held over i (airborne, cannot act) for GRAB_HOLD, then hurled
## along `dir` as a carry. `afar` holds it in the air where it stands instead (a psychic lift).
## False when the target cannot be grabbed (phased, untouchable, or a rampart).
func _grab(i: int, t: int, dir: Vector2, afar := false) -> bool:
	var o: Dictionary = _fighters[t]
	if o["hp"] <= 0 or o["phase"] > 0.0 or o["invuln"] > 0.0 or o["passive"] == "rampart" or o["cocoon"] > 0.0 or o["aegis"] > 0.0:
		return false
	o["grabbed"] = GRAB_HOLD
	o["grab_by"] = -1 if afar else i
	o["grab_dir"] = dir.normalized() if dir.length() > 0.01 else Vector2.RIGHT
	o["windup"] = {}
	o["tackle"] = {}
	o["ram_t"] = 0.0
	o["carry_t"] = 0.0
	o["airborne"] = maxf(o["airborne"], GRAB_HOLD + 0.05)
	o["airborne_len"] = o["airborne"]
	_label(t, "Seized")
	return true


## The nearest standing rock within `pad` of a point (not a lifted one), or -1.
func _rock_near_point(p: Vector2, pad: float) -> int:
	var best := -1
	var best_d := INF
	for k in _rocks.size():
		var r: Dictionary = _rocks[k]
		if r.get("lift", 0.0) > 0.0:
			continue
		var d: float = r["pos"].distance_to(p)
		if d < pad and d < best_d:
			best = k
			best_d = d
	return best


## Fighter i uses its charm. False when it cannot (down, cooling down, or the charm has no
## moment: Blink needs a direction, Spear a target).
func _use_charm(i: int) -> bool:
	var f: Dictionary = _fighters[i]
	if f["hp"] <= 0 or f["charm_cd"] > 0.0 or f["hidden"] or _sig.active:
		return false
	var charm: String = f["charm"]
	var at: Vector2 = f["body"].position
	match charm:
		"beads":
			if f["stun"] <= 0.0 and f["rooted"] <= 0.0 and f["dazzle"] <= 0.0 and f["crippled"] <= 0.0 and f["slowed"] <= 0.0 and f["airborne"] <= 0.0 and f["carry_t"] <= 0.0:
				if i == controlled and not auto_you:
					_play("res://assets/audio/sfx/ui/cancel.wav", -12.0)
				return false
			f["stun"] = 0.0; f["rooted"] = 0.0; f["dazzle"] = 0.0; f["crippled"] = 0.0; f["slowed"] = 0.0; f["airborne"] = 0.0; f["carry_t"] = 0.0; f["glassed"] = 0.0
			f["cc_immune"] = BEADS_IMMUNE
			_effects.append({"kind": "impact", "anim": "lantern_flash", "pos": at + Vector2(0, -4), "t": 0.0, "scale": 1.3})
			_label(i, "Beads")
		"blink":
			var dir: Vector2
			if i == controlled and not auto_you:
				dir = _player_dir if _player_dir.length() > 0.01 else _facing_vector(f["facing"])
			else:
				var nf := _nearest_foe(i)
				var t := _foe_of(i)
				var away: Vector2 = (at - _fighters[nf]["body"].position).normalized() if nf >= 0 else Vector2.RIGHT
				dir = away if (nf >= 0 and float(f["hp"]) / f["max_hp"] < 0.4) else ((_fighters[t]["body"].position - at).normalized() if t >= 0 else away)
			if f["stun"] > 0.0 or f["airborne"] > 0.0 or f["crippled"] > 0.0:
				return false
			var floor_rect: Rect2 = _floor()
			var to: Vector2 = (at + dir.normalized() * BLINK_DISTANCE).clamp(floor_rect.position, floor_rect.end)
			if _blocked(to):
				to = (at + dir.normalized() * BLINK_DISTANCE * 0.5).clamp(floor_rect.position, floor_rect.end)
			_effects.append({"kind": "streak", "from": at, "to": to, "t": 0.0, "tex": f["sprite"].texture, "off": f["sprite"].offset})
			f["body"].position = to
			f["windup"] = {}
			f["rooted"] = 0.0
			f["carry_t"] = 0.0
			_effects.append({"kind": "impact", "anim": "lantern_flash", "pos": to + Vector2(0, -4), "t": 0.0})
			_anim(i, "land", 0.15, Vector2.ZERO)
			_label(i, "Blink")
		"aegis":
			f["aegis"] = AEGIS_SECONDS
			f["invuln"] = maxf(f["invuln"], AEGIS_SECONDS)
			f["windup"] = {}
			f["carry_t"] = 0.0
			_effects.append({"kind": "ring", "pos": at, "size": 16.0, "t": 0.0, "lines": [], "rim": Color(1.0, 0.85, 0.3)})
			_label(i, "Aegis")
		"thorns":
			f["thorns"] = THORNS_SECONDS
			_effects.append({"kind": "impact", "anim": "root_burst", "pos": at + Vector2(0, 4), "t": 0.0})
			_label(i, "Thorns")
		"spear":
			var t := _foe_of(i)
			if t < 0:
				return false
			_fighters[t]["sunder"] = SPEAR_SECONDS
			_effects.append({"kind": "bolt", "pts": _jagged(at + Vector2(0, -14), _fighters[t]["body"].position + Vector2(0, -10), 5, 4.0), "t": 0.0, "big": false})
			_effects.append({"kind": "impact", "anim": "spark_bolt", "pos": _fighters[t]["body"].position + Vector2(0, 2), "t": 0.0})
			_label(t, "Sundered")
		"emblem":
			var n := 0
			for j in _fighters.size():
				var o: Dictionary = _fighters[j]
				if _enemies(i, j) and o["hp"] > 0 and o["body"].position.distance_to(at) < EMBLEM_RADIUS and o["phase"] <= 0.0 and o["invuln"] <= 0.0:
					o["slowed"] = maxf(o["slowed"], EMBLEM_SECONDS)
					_label(j, "Slowed")
					n += 1
			_effects.append({"kind": "ring", "pos": at, "size": EMBLEM_RADIUS, "t": 0.0, "lines": [], "rim": Color(0.6, 0.3, 0.8)})
			_label(i, "Emblem")
		"shell":
			for j in _fighters.size():
				var o: Dictionary = _fighters[j]
				if o["team"] == f["team"] and o["hp"] > 0 and o["body"].position.distance_to(at) < SHELL_RADIUS:
					_shield(j, int(round(o["max_hp"] * SHELL_SHIELD)), SHELL_SECONDS, "star_shield")
			_effects.append({"kind": "ring", "pos": at, "size": SHELL_RADIUS, "t": 0.0, "lines": [], "rim": Color(0.6, 0.85, 1.0)})
			_label(i, "Shell")
		"wings":
			for j in _fighters.size():
				var o: Dictionary = _fighters[j]
				if o["team"] == f["team"] and o["hp"] > 0 and o["body"].position.distance_to(at) < SHELL_RADIUS:
					o["haste"] = maxf(o["haste"], WINGS_SECONDS)
					_effects.append({"kind": "impact", "anim": "gust_lift", "pos": o["body"].position + Vector2(0, -4), "t": 0.0})
			_label(i, "Wings")
		_:
			return false
	f["charm_cd"] = CHARMS[charm]["cooldown"]
	_log_ai(i, "uses %s" % CHARMS[charm]["name"])
	_play("res://assets/audio/sfx/starward/star_guard.wav", -12.0)
	return true


## When the AI reaches for its charm.
func _ai_charm(i: int) -> void:
	var f: Dictionary = _fighters[i]
	if f["hp"] <= 0 or f["charm_cd"] > 0.0 or _sig.active:
		return
	var frac: float = float(f["hp"]) / f["max_hp"]
	var nf := _nearest_foe(i)
	var near: float = _fighters[nf]["body"].position.distance_to(f["body"].position) if nf >= 0 else INF
	var want := false
	match f["charm"]:
		"beads":
			want = f["stun"] > 0.4 or f["rooted"] > 0.6 or f["dazzle"] > 0.4 or (f["slowed"] > 1.0 and near < 50.0)
		"aegis":
			want = frac < 0.35 and (_threat_near(i, 45.0) or near < 30.0)
		"blink":
			var t := _foe_of(i)
			want = (frac < 0.35 and near < 45.0) or (f["role"] in ["Assassin", "Skirmisher"] and t >= 0 and float(_fighters[t]["hp"]) / _fighters[t]["max_hp"] < 0.45 and _fighters[t]["body"].position.distance_to(f["body"].position) > 80.0)
		"thorns":
			var pressing := 0
			for j in _fighters.size():
				if _enemies(i, j) and _fighters[j]["hp"] > 0 and _fighters[j]["body"].position.distance_to(f["body"].position) < 40.0:
					pressing += 1
			want = pressing >= 2 or (frac < 0.6 and _threat_near(i, 45.0))
		"spear":
			var t := _foe_of(i)
			want = t >= 0 and float(_fighters[t]["hp"]) / _fighters[t]["max_hp"] > 0.5 and _called[f["team"]]["target"] == t and _clock < _called[f["team"]]["until"]
		"emblem":
			var close := 0
			for j in _fighters.size():
				if _enemies(i, j) and _fighters[j]["hp"] > 0 and _fighters[j]["body"].position.distance_to(f["body"].position) < EMBLEM_RADIUS:
					close += 1
			want = close >= 2 or (close >= 1 and frac < 0.4)
		"shell":
			for j in _fighters.size():
				var o: Dictionary = _fighters[j]
				if o["team"] == f["team"] and o["hp"] > 0 and o["shield"] <= 0 and float(o["hp"]) / o["max_hp"] < 0.5 and o["body"].position.distance_to(f["body"].position) < SHELL_RADIUS and _threat_near(j, 45.0):
					want = true
		"wings":
			var t := _foe_of(i)
			want = f["mode"] == "crest" or (t >= 0 and _fighters[t]["body"].position.distance_to(f["body"].position) > 130.0)
	if want:
		_use_charm(i)


## A dash: fighter i covers ground fast along `dir` for `seconds`, untouchable for `invuln` of
## it, leaving afterimages. False when it cannot (held, cooling down, mid-move).
func _dash(i: int, dir: Vector2, seconds: float, invuln: float) -> bool:
	var f: Dictionary = _fighters[i]
	if f["hp"] <= 0 or f["dash"] > 0.0 or f["dash_cd"] > 0.0 or f["stun"] > 0.0 or f["rooted"] > 0.0 or f["airborne"] > 0.0 or f["guard"] > 0.0 or f["cocoon"] > 0.0 or f["brace"] > 0.0 or f["ram_t"] > 0.0 or not f["tackle"].is_empty() or f["hidden"] or dir.length() < 0.01:
		return false
	if f["crippled"] > 0.0 or _in_riptide(i) or _in_shards(i) or _in_trench(i):
		return false
	f["dash"] = seconds
	f["dash_dir"] = dir.normalized()
	f["dash_cd"] = DASH_COOLDOWN
	f["invuln"] = maxf(f["invuln"], invuln)
	f["windup"] = {}
	f["facing"] = _facing_of(f["dash_dir"])
	f["echo_t"] = 0.0
	_effects.append({"kind": "dust", "pos": f["body"].position, "t": 0.0})
	_effects.append({"kind": "ring", "pos": f["body"].position, "size": 10.0, "t": 0.0, "lines": [f["dash_dir"].angle() + PI - 0.4, f["dash_dir"].angle() + PI, f["dash_dir"].angle() + PI + 0.4], "rim": Color(1, 1, 1)})
	_play("res://assets/audio/sfx/ui/cursor.wav", -14.0)
	return true
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
	if _winner >= 0 and not _over_sent:
		_over_t += delta
		if _over_t >= OVER_SECONDS:
			_over_sent = true
			match_over.emit(_winner)
	for slot in _card_flash:
		_card_flash[slot] = maxf(0.0, _card_flash[slot] - delta)
		_card_shake[slot] = maxf(0.0, _card_shake[slot] - delta)
	_why_t = maxf(0.0, _why_t - delta)
	_mouse_live = maxf(0.0, _mouse_live - delta)
	_range_hint["t"] = maxf(0.0, _range_hint["t"] - delta)
	if poll_input and not auto_you and debug_input == Vector2.ZERO:
		_player_dir = Vector2(float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
			float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
		_attack_held = Input.is_physical_key_pressed(KEY_J) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_mouse_live = MOUSE_LIVE
		if _attack_held and not _attack_was:
			_attack_buffer = ATTACK_BUFFER   # a tap: it fires now, or the moment the creature is free
		_attack_was = _attack_held
	if _winner < 0 and not frozen and not stopped:
		_clock += delta
		if not _sig.active:
			_move_rival(delta)
			_player_attack(delta)
		for i in _fighters.size():
			_update_windup(i, delta)
			_use_moves(i, delta)
		_update_crest(delta)
		if team_size > 1 and _clock >= MATCH_SECONDS:
			_decide_on_points()
	for i in _fighters.size():
		if stopped:
			_shiver(i)
		else:
			_update_fighter(i, delta)
	if not frozen:
		_update_effects(delta)
	_shake = maxf(0.0, _shake - delta * 18.0)
	_cheer = maxf(0.0, _cheer - delta)
	_banner_t = maxf(0.0, _banner_t - delta)
	_crowd_t += delta
	_update_camera(delta)
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
	var floor_rect: Rect2 = _floor()
	var here: Vector2 = f["body"].position
	if f["dash"] > 0.0 and f["hp"] > 0:
		# A dash: fast along its line, sliding along anything in the way, afterimages behind it.
		f["dash"] = maxf(0.0, f["dash"] - delta)
		var step: Vector2 = f["dash_dir"] * DASH_SPEED * delta
		for tryit in [step, Vector2(step.x, 0), Vector2(0, step.y)]:
			var next: Vector2 = (here + tryit).clamp(floor_rect.position, floor_rect.end)
			if not _blocked(next):
				f["body"].position = next
				break
		f["vel"] = f["dash_dir"] * SPEED * f["speed"]
		f["walk"] += delta
		f["echo_t"] -= delta
		if f["echo_t"] <= 0.0:
			f["echo_t"] = 0.04
			var sprite: Sprite2D = f["sprite"]
			_effects.append({"kind": "echo", "tex": sprite.texture, "pos": f["body"].position + sprite.offset + sprite.position, "t": 0.0, "tint": Color(1, 1, 1)})
		return
	var can_move: bool = f["stun"] <= 0.0 and f["rooted"] <= 0.0 and f["airborne"] <= 0.0 and f["guard"] <= 0.0 and f["cocoon"] <= 0.0 and f["brace"] <= 0.0 and f["aegis"] <= 0.0 and f["pinned"] <= 0.0 and not f["hidden"] and f["hp"] > 0 and f["ram_t"] <= 0.0
	var speed: float = SPEED * f["speed"] * (0.5 if f["dazzle"] > 0.0 else 1.0) * (0.7 if f["crippled"] > 0.0 else 1.0) * (EMBLEM_SLOW if f["slowed"] > 0.0 else 1.0)
	if f["glassed"] > 0.0:
		speed *= GLASSED_SLOW
	if f["haste"] > 0.0:
		speed *= HASTE_SPEED
	if _in_riptide(i):
		speed *= RIPTIDE_SLOW
	if _in_vines(i):
		speed *= VINES_SLOW
	speed *= _hazard_slow(i)
	if f["perched"] >= 0 and (i != controlled or auto_you) and f["perch_t"] < PERCH_SECONDS and _nearest_foe(i) >= 0 and _fighters[_nearest_foe(i)]["body"].position.distance_to(here) < PERCH_WORTH:
		dir = Vector2.ZERO   # the AI keeps its perch while an enemy is close enough to dart (the player hops down by steering)
	if f["perched"] >= 0 and dir.length() > 0.01 and can_move:
		# Steering off the perch: it hops down beside the rock.
		var pr: Dictionary = _rocks[f["perched"]] if f["perched"] < _rocks.size() else {}
		if not pr.is_empty():
			f["body"].position = (pr["pos"] + dir.normalized() * (pr["rx"] + 6.0) + Vector2(0, 4)).clamp(floor_rect.position, floor_rect.end)
		f["perched"] = -1
		_anim(i, "land", 0.15, Vector2.ZERO)
		here = f["body"].position
	var want_vel: Vector2 = dir.normalized() * speed if (dir.length() > 0.01 and can_move) else Vector2.ZERO
	# Momentum: speed is gained and lost over a few frames, so turns lean and stops skid.
	var was: Vector2 = f["vel"]
	var rate: float = (ACCEL if want_vel.length() > 0.01 else DECEL) * SPEED * f["speed"]
	f["vel"] = was.move_toward(want_vel, rate * delta)
	if not can_move:
		f["vel"] = Vector2.ZERO
	if was.length() > speed * 0.5 and want_vel.length() > 0.01 and was.normalized().dot(want_vel.normalized()) < 0.2:
		_effects.append({"kind": "dust", "pos": here - was.normalized() * 3.0, "t": 0.0})   # a skid on a hard turn
	if f["vel"].length() > 1.0:
		var step: Vector2 = f["vel"] * delta
		# Root walls block the way: slide along them where possible.
		for tryit in [step, Vector2(step.x, 0), Vector2(0, step.y)]:
			var next: Vector2 = (here + tryit).clamp(floor_rect.position, floor_rect.end)
			if not _blocked(next):
				f["body"].position = next
				break
		if want_vel.length() > 0.01:
			f["facing"] = _facing_of(dir)
		f["walk"] += delta
		f["dust"] -= delta
		if f["dust"] <= 0.0:
			f["dust"] = 0.16
			_effects.append({"kind": "dust", "pos": f["body"].position - f["vel"].normalized() * 4.0, "t": 0.0})
		if f["passive"] == "lantern_charge" and want_vel.length() > 0.01:
			f["charge"] = minf(100.0, f["charge"] + CHARGE_PER_SECOND * delta)
	else:
		f["walk"] = 0.0


## When true, your creature is moved by the same AI as the rival (the balance simulator).
var auto_you := false
var _called := {0: {"target": -1, "until": 0.0}, 1: {"target": -1, "until": 0.0}}   # Kit Sense: each team's called target
var ai_log: Array[String] = []         # the AI explaining itself; L shows it
var show_ai_log := false
var _conducting := false               # a Conduct hit is spreading; its own hits do not conduct again
var _crest_team := -1                  # who holds the Crest alone this frame (-1: nobody or contested)
var _crest_tick := 0.0
var _on_points := false                # the match ended on the clock


## Every creature's footwork, yours included (a test movie steering fighter 0 is the exception).
func _move_rival(delta: float) -> void:
	for i in _fighters.size():
		if i == 0 and debug_input != Vector2.ZERO:
			_move_player(delta)
		elif i == controlled and not auto_you:
			_walk(i, _player_dir, delta)   # yours: you steer it (Preston, 2026-10-08 night)
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
	if me["dash"] > 0.0:
		# Mid-dash: it goes where it was sent. The walk runs the dash down; skipping it froze
		# every AI creature on its first dodge (found 2026-10-09 on the Dustkite line).
		_walk(i, Vector2.ZERO, delta)
		return
	if _ai_dodge(i):
		return
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
	var profile: String = me["profile"]
	if me["mode"] == "kite":
		profile = "kite"
	elif me["mode"] == "peel" and me["role"] == "Protector":
		profile = "escort"
	elif me["mode"] == "crest":
		profile = "crest"
	match profile:
		"crest":
			# To the centre circle, to hold it.
			var to_crest: Vector2 = _floor().get_center() - me["body"].position
			if to_crest.length() > 12.0:
				dir = to_crest.normalized()
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
				var floor_rect: Rect2 = _floor()
				var to_middle: Vector2 = (floor_rect.get_center() - me["body"].position) / (floor_rect.size * 0.5)
				var from: Vector2 = to_near if to_near.length() < dist else to_you
				dir = (-from.normalized() + to_middle * 0.9).normalized() * (1.3 if from.length() < 70.0 else 1.0)
			elif dist > want + 20.0:
				dir = to_you.normalized() * 0.5
			dir += to_you.normalized().orthogonal() * 0.35 * me["strafe"]
		"press":
			# Walks straight at you and stays in your face, circling once it is there.
			if dist > 20.0:
				dir = to_you.normalized()
			if dist < 34.0:
				dir += to_you.normalized().orthogonal() * 0.6 * me["strafe"]
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
			dir += to_you.normalized().orthogonal() * 0.9 * me["strafe"]   # arcs, not a standstill
	# Teammates spread out instead of stacking on one spot.
	for j in _fighters.size():
		var a: Dictionary = _fighters[j]
		if j != i and a["team"] == me["team"] and a["hp"] > 0:
			var off: Vector2 = me["body"].position - a["body"].position
			if off.length() > 0.01 and off.length() < 22.0:
				dir += off.normalized() * (22.0 - off.length()) / 22.0 * 1.2
	# A dash to close a long gap, or to open one when it is a kiter with someone on it.
	if me["dash_cd"] <= 0.0 and me["windup"].is_empty() and me["act"] <= 0.0:
		if profile in ["kite", "kite_near"] and _nearest_foe(i) >= 0 and _fighters[_nearest_foe(i)]["body"].position.distance_to(me["body"].position) < 45.0 and dir.length() > 0.01:
			if _dash(i, dir, DASH_SECONDS, 0.0):
				_log_ai(i, "dashes clear")
				return
		elif profile not in ["kite", "kite_near", "crest"] and dist > want + 70.0 and randf() < 0.05:
			if _dash(i, to_you, DASH_SECONDS, 0.0):
				_log_ai(i, "dashes in on %s" % you["name"])
				return
	_walk(i, dir, delta * 0.85)
	# The ultimate is the player's to fire on their own creature (the simulator excepted).
	# Molten Glass erupts round Vitrecrag itself, so its AI waits for an enemy close by.
	if me["final"] and me["meter"] >= 100 and dist < (60.0 if LINES[me["line"]]["signature"] == "Molten Glass" else 150.0) and (i != controlled or auto_you):
		signature(i)


## The dodge step: an enemy's telegraph aimed at fighter i is about to land (a melee, line or
## area it can step out of), so it sidesteps with a moment of safety. Tanks hold their ground;
## bruisers step half the time; everyone else steps when they can; a listener always hears it.
func _ai_dodge(i: int) -> bool:
	var me: Dictionary = _fighters[i]
	if me["dodge_cd"] > 0.0 or me["dash_cd"] > 0.0 or me["role"] == "Tank" or not me["windup"].is_empty():
		return false
	for j in _fighters.size():
		var o: Dictionary = _fighters[j]
		if not _enemies(i, j) or o["hp"] <= 0 or o["windup"].is_empty():
			continue
		var w: Dictionary = o["windup"]
		if w["target"] != i or w["t"] > DODGE_WINDOW or w["kind"] in ["charge", "rail"]:
			continue
		var chance: float = 0.8 if me["passive"] == "listening" else (0.3 if me["role"] == "Bruiser" else 0.55)
		if randf() > chance:
			me["dodge_cd"] = DODGE_COOLDOWN * 0.5   # it saw it and did not step: no second look at this one
			return false
		var away: Vector2 = (me["body"].position - o["body"].position).normalized()
		var side: Vector2 = away.orthogonal() * (1.0 if randf() < 0.5 else -1.0)
		if _dash(i, (side + away * 0.3).normalized(), DODGE_SECONDS, DODGE_INVULN):
			me["dodge_cd"] = DODGE_COOLDOWN
			_label(i, "Dodge")
			_log_ai(i, "steps out of %s" % MOVES[w["m"]]["name"])
			return true
	return false


# ---------------------------------------------------------------- the creature's AI: when to use each move

## Each creature, yours included, picks its own moves: the first one in its kit that is
## ready and whose moment has come. Paralysed or dazzled creatures cannot act.
func _use_moves(i: int, delta: float) -> void:
	var f: Dictionary = _fighters[i]
	var cd_rate: float = STILL_RATE if _in_still(i) else 1.0   # Still Water: cooldowns crawl
	for m in f["cds"]:
		f["cds"][m] = maxf(0.0, f["cds"][m] - delta * cd_rate)
	f["act"] = maxf(0.0, f["act"] - delta)
	if f["act"] <= 0.0:
		f["recovering"] = ""
	f["disengage"] = maxf(0.0, f["disengage"] - delta)
	f["retarget"] = maxf(0.0, f["retarget"] - delta)
	for m in f["charge_cds"]:
		# Charges each recharge on their own timer; the move is ready while any charge is.
		var timers: Array = f["charge_cds"][m]
		for c in timers.size():
			timers[c] = maxf(0.0, timers[c] - delta * cd_rate)
		f["cds"][m] = timers.min()
	if f["hp"] > 0 and (not f["windup"].is_empty() or f["act"] > 0.0) and f["airborne"] <= 0.0 and f["stun"] <= 0.0 and f["dazzle"] <= 0.0 and f["hush"] <= 0.0 and f["tackle"].is_empty() and "interrupt_call" in f["abilities"] and f["cds"]["interrupt_call"] <= 0.0 and (i != controlled or auto_you):
		# The call cuts in (a cancel, after fighting games): a listener drops its own wind-up to
		# call off an enemy's, because the enemy's move is the one that matters.
		var tc := _foe_of(i)
		if tc >= 0 and _wants(i, "interrupt_call", _fighters[tc]):
			if not f["windup"].is_empty():
				f["cds"][f["windup"]["m"]] = 0.0
				f["windup"] = {}
			_log_ai(i, "cuts in: Interrupt Call on %s" % _fighters[tc]["name"])
			_fire(i, "interrupt_call", tc)
			return
	if i != controlled or auto_you:
		_ai_charm(i)   # beads work through a stun, so this comes before the gate
	if f["hp"] <= 0 or f["stun"] > 0.0 or f["dazzle"] > 0.0 or f["airborne"] > 0.0 or f["act"] > 0.0 or f["aegis"] > 0.0 or f["pinned"] > 0.0 or f["hidden"] or _sig.active or not f["windup"].is_empty() or not f["tackle"].is_empty():
		return
	var t := _foe_of(i)
	if t < 0:
		return
	# Kit Sense (2026-10-08): first the mode this think (finish, peel, kite, hold, engage), which
	# may change who it goes for; then every ready move scored by desire, and the highest
	# fires. The basic attack has its own score, so an ability needs a reason to beat it.
	var mode := _mode_of(i, t)
	f["mode"] = mode
	var manual: bool = i == controlled and not auto_you   # yours: your target stands, no mode retargeting
	if mode == "finish" and not manual:
		var k := _finish_target(i)
		if k >= 0:
			t = k
			f["target"] = k
			f["retarget"] = 1.0
	elif mode == "peel" and not manual:
		var w := _ally_in_trouble(i)
		var nf := _nearest_foe(w) if w >= 0 else -1
		if nf >= 0:
			t = nf
			f["target"] = nf
			f["retarget"] = 1.0
	var foe: Dictionary = _fighters[t]
	var best_m := ""
	var best_d := 0.0
	for m in f["kit"]:
		if i == controlled and not auto_you:
			continue   # yours: the basic goes on press (_player_attack), abilities on 1-3; auto mode fires everything
		if f["hush"] > 0.0 and m in f["abilities"]:
			continue   # hushed: only the basic
		# Roots and riptide shut off movement abilities, except Phase: roots cannot hold
		# what is not there (Preston, 2026-10-07), so Phase breaks free at the cost of its dodge.
		if MOVES[m].get("mobility", false) and m != "phase" and (f["crippled"] > 0.0 or _in_riptide(i) or _in_shards(i)):
			continue
		if f["cds"][m] > 0.0:
			continue
		var d := _desire(i, m, t, mode)
		if d > best_d:
			best_d = d
			best_m = m
	if best_m == "":
		return
	_log_ai(i, "%s: %s (%.2f) on %s" % [mode, MOVES[best_m]["name"], best_d, foe["name"]])
	if TELEGRAPH.has(best_m):
		# Attacks telegraph first: the shape shows on the ground, then the move fires.
		var wt: float = TELEGRAPH[best_m][1] * _listen_factor(i)
		f["windup"] = {"m": best_m, "kind": TELEGRAPH[best_m][0], "t": wt, "total": wt, "target": t, "at": foe["body"].position}
		f["facing"] = _facing_of(foe["body"].position - f["body"].position)
		_anim(i, "wind", wt, (foe["body"].position - f["body"].position).normalized())
		_play("res://assets/audio/sfx/arena/telegraph.wav", -10.0 if t == 0 or i == 0 else -16.0)   # louder when it concerns you
	else:
		_fire(i, best_m, t)
	return


## The cursor as a point on the floor (the checks set mouse_override). The floor lives in a
## SubViewport shown at SCALE, so the sub-viewport never sees the mouse itself (its answer is
## always the origin, which sent every aim to the top-left on 2026-10-09): take the arena's own
## mouse position, divide by the screen scale, and undo the camera's world transform.
func _mouse_world() -> Vector2:
	if mouse_override.x != INF:
		return mouse_override
	var sub: Vector2 = get_local_mouse_position() / SCALE
	return _world.get_transform().affine_inverse() * sub


## Whether fighter i aims with the mouse right now: yours, steered, and the mouse recently moved or clicked.
func _mouse_aim(i: int) -> bool:
	return i == controlled and not auto_you and _mouse_live > 0.0


## The enemy to hit along the cursor line: the locked one if it is in the cone, else the nearest
## living enemy within reach and inside AIM_CONE of `aim`. -1 when nobody is there.
func _cone_target(i: int, aim: Vector2, reach: float) -> int:
	var f: Dictionary = _fighters[i]
	var best := -1
	var best_d := INF
	for j in _fighters.size():
		var o: Dictionary = _fighters[j]
		if not _enemies(i, j) or o["hp"] <= 0 or o["phase"] > 0.0:
			continue
		var d: Vector2 = o["body"].position - f["body"].position
		if d.length() <= reach and absf(d.angle_to(aim)) <= AIM_CONE:
			if j == player_target:
				return j
			if d.length() < best_d:
				best = j
				best_d = d.length()
	return best


## Right click: lock the enemy under the cursor, or clear the lock on empty ground.
func _lock_under_cursor() -> void:
	if _fighters.is_empty() or auto_you:
		return
	var at := _mouse_world()
	var best := -1
	var best_d := LOCK_REACH
	for j in _fighters.size():
		var o: Dictionary = _fighters[j]
		if not _enemies(controlled, j) or o["hp"] <= 0:
			continue
		var d: float = (o["body"].position + Vector2(0, -10)).distance_to(at)
		if d < best_d:
			best = j
			best_d = d
	if best >= 0:
		player_target = best
		_fighters[controlled]["target"] = best
		_label(controlled, "Locked: " + String(_fighters[best]["name"]))
		_play("res://assets/audio/sfx/ui/cursor.wav", -8.0)
	elif player_target >= 0:
		player_target = -1
		_label(controlled, "Auto target")
		_play("res://assets/audio/sfx/ui/cancel.wav", -14.0)


## A press of yours that went through: the card lights, a ring of your line's colour at the
## creature's feet, the cast sound pitched for the slot (-1 is the basic, 3 the ultimate, 4 the charm).
func _press_ok(slot: int) -> void:
	if _card_flash.has(slot):
		_card_flash[slot] = CARD_FLASH
	var f: Dictionary = _fighters[controlled]
	_effects.append({"kind": "ring", "pos": f["body"].position, "size": 14.0, "t": 0.0, "lines": [], "rim": LINES[f["line"]]["accent"]})
	_play_pitched("res://assets/audio/sfx/arena/telegraph.wav", -8.0 if slot != -1 else -14.0, PRESS_PITCH.get(slot, 1.0))


## A press of yours that could not go: the card shakes and the reason shows over the bar.
func _press_fail(slot: int, why: String) -> void:
	if _card_shake.has(slot):
		_card_shake[slot] = CARD_SHAKE
	_why = why
	_why_t = WHY_SECONDS
	_play("res://assets/audio/sfx/ui/cancel.wav", -12.0)


## Your basic attack is a button (Preston, 2026-10-09: "I don't feel when I use my moves"). A tap
## starts it at once: at your target when it is in reach, otherwise down the line you are
## steering (or the way you face), a free swing that whiffs or hits whoever is there. A tap
## during recovery is kept for ATTACK_BUFFER and fires the moment the creature is free; holding
## repeats on the move's own rhythm (telegraph, recovery, cooldown).
func _player_attack(delta: float) -> void:
	_attack_buffer = maxf(0.0, _attack_buffer - delta)
	if _fighters.is_empty() or auto_you or _winner >= 0 or _sig.active:
		return
	var i := controlled
	var f: Dictionary = _fighters[i]
	var mouse := _mouse_aim(i)
	var cursor := _mouse_world()
	if mouse and _attack_held and f["hp"] > 0 and f["windup"].is_empty() and (cursor - f["body"].position).length() > 2.0:
		f["facing"] = _facing_of(cursor - f["body"].position)   # the button held: it faces the cursor
	if _attack_buffer <= 0.0 and not _attack_held:
		return
	if f["hp"] <= 0 or f["stun"] > 0.0 or f["dazzle"] > 0.0 or f["airborne"] > 0.0 or f["hidden"] or f["act"] > 0.0 or f["aegis"] > 0.0 or f["pinned"] > 0.0 or f["grabbed"] > 0.0 or not f["windup"].is_empty() or f["ram_t"] > 0.0 or not f["tackle"].is_empty():
		return   # busy: the buffer keeps the tap
	var m: String = f["kit"][0]
	if f["cds"][m] > 0.0:
		return
	_attack_buffer = 0.0
	var t := _foe_of(i)
	if t < 0:
		return
	var foe: Dictionary = _fighters[t]
	var to_foe: Vector2 = foe["body"].position - f["body"].position
	var reach: float = MOVES[m]["range"] + (VANTAGE_RANGE if f["perched"] >= 0 else 0.0)
	var in_reach: bool = to_foe.length() <= reach + SWEEP_REACH_EXTRA and foe["phase"] <= 0.0
	var aim: Vector2 = to_foe.normalized()
	var at: Vector2 = foe["body"].position
	if mouse:
		# Mouse aim: the swing or shot goes toward the cursor; the enemy in the cone along that
		# line is the target (the locked one first); nobody there makes it a free shot.
		var to_c: Vector2 = cursor - f["body"].position
		aim = to_c.normalized() if to_c.length() > 2.0 else _facing_vector(f["facing"])
		var ct := _cone_target(i, aim, reach + SWEEP_REACH_EXTRA)
		in_reach = ct >= 0
		if in_reach:
			t = ct
			foe = _fighters[t]
			f["target"] = t
			f["retarget"] = 0.5
		at = f["body"].position + to_c.limit_length(reach)
	elif not in_reach:
		aim = _player_dir.normalized() if _player_dir.length() > 0.01 else _facing_vector(f["facing"])
		at = f["body"].position + aim * MOVES[m]["range"]
	f["facing"] = _facing_of(aim)
	_press_ok(-1)
	var free: bool = mouse or not in_reach   # a free swing takes whoever is in its arc
	if TELEGRAPH.has(m):
		var wt: float = TELEGRAPH[m][1] * _listen_factor(i)
		f["windup"] = {"m": m, "kind": TELEGRAPH[m][0], "t": wt, "total": wt, "target": t, "at": at, "aim": aim, "free": free}
		_anim(i, "wind", wt, aim)
	else:
		_aim_override = aim if free else Vector2.ZERO
		_aim_point = at if mouse else Vector2(INF, INF)
		_fire(i, m, t)
		_aim_override = Vector2.ZERO
		_aim_point = Vector2(INF, INF)


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
	if f["hp"] <= 0:
		return
	# A press that cannot go says why (Preston, 2026-10-09).
	if f["stun"] > 0.0 or f["dazzle"] > 0.0 or f["airborne"] > 0.0:
		_press_fail(slot, "HELD")
		return
	if f["hidden"] or not f["windup"].is_empty() or f["ram_t"] > 0.0 or not f["tackle"].is_empty():
		_press_fail(slot, "NOT YET")
		return
	if f["cds"][m] > 0.0:
		_press_fail(slot, "%s IN %.1f S" % [String(MOVES[m]["name"]).to_upper(), f["cds"][m]])
		return
	if f["hush"] > 0.0:
		_press_fail(slot, "HUSHED")
		return
	if MOVES[m].get("mobility", false) and m != "phase" and (f["crippled"] > 0.0 or _in_riptide(i) or _in_shards(i)):
		_press_fail(slot, "ROOTED")
		return
	var t := _foe_of(i)
	if t < 0:
		_press_fail(slot, "NO TARGET")
		return
	var shaped: bool = MOVES[m]["damage"] > 0 and MOVES[m]["range"] > 0.0 and not MOVES[m].get("mobility", false)
	var aim: Vector2 = Vector2.ZERO
	var at: Vector2 = _fighters[t]["body"].position
	var free := false
	if _mouse_aim(i):
		# Mouse aim: the enemy in the cone along the cursor line is the target; a shaped attack
		# with nobody there goes to the cursor as a free shot (a skillshot). Other moves keep their target.
		var to_c: Vector2 = _mouse_world() - f["body"].position
		aim = to_c.normalized() if to_c.length() > 2.0 else _facing_vector(f["facing"])
		var ct := _cone_target(i, aim, MOVES[m]["range"] + SWEEP_REACH_EXTRA) if MOVES[m]["range"] > 0.0 else -1
		if ct >= 0:
			t = ct
			f["target"] = t
			f["retarget"] = 0.5
			at = _fighters[t]["body"].position
		elif shaped:
			free = true
			at = f["body"].position + to_c.limit_length(MOVES[m]["range"])
	var dist: float = _fighters[t]["body"].position.distance_to(f["body"].position)
	if shaped and not free and dist > MOVES[m]["range"] + SWEEP_REACH_EXTRA:
		# An attack with a reach, pressed with the target beyond it: refused, nothing spent.
		_press_fail(slot, "OUT OF RANGE (%d PX)" % int(dist - MOVES[m]["range"]))
		_range_hint = {"r": MOVES[m]["range"] + SWEEP_REACH_EXTRA, "t": RANGE_HINT_SECONDS}
		return
	_press_ok(slot)
	var face: Vector2 = aim if free else (_fighters[t]["body"].position - f["body"].position).normalized()
	f["facing"] = _facing_of(face)
	if TELEGRAPH.has(m):
		var wt: float = TELEGRAPH[m][1] * _listen_factor(i)
		f["windup"] = {"m": m, "kind": TELEGRAPH[m][0], "t": wt, "total": wt, "target": t, "at": at, "aim": aim, "free": free}
		_anim(i, "wind", wt, face)
	else:
		_aim_override = aim if free else Vector2.ZERO
		_aim_point = at if free else Vector2(INF, INF)
		_fire(i, m, t)
		_aim_override = Vector2.ZERO
		_aim_point = Vector2(INF, INF)


## Frame data (after Street Fighter): a move's recovery, the time after it goes off before the
## creature can act again. Light basics recover fast and are plus on hit (hitstun outlasts
## them); heavy moves are minus, so a whiffed slam can be punished.
func _recovery(m: String) -> float:
	if RECOVERY_OF.has(m):
		return RECOVERY_OF[m]
	return RECOVERY[TELEGRAPH[m][0] if TELEGRAPH.has(m) else ""]


## Armour: a charge, or a tank with its passive, is not broken out of a wind-up by a counter hit.
func _armoured(i: int) -> bool:
	var f: Dictionary = _fighters[i]
	return (not f["windup"].is_empty() and f["windup"]["kind"] == "charge") or f["passive"] in ["rampart", "kiln"]


## Mending through the role layer: a wounded creature (hit by a Damage role lately) mends 30% less.
func _mend(i: int, amount: int) -> void:
	var f: Dictionary = _fighters[i]
	if f["hp"] <= 0:
		return
	f["mend_acc"] += float(amount) * (WOUND_CUT if f["wound"] > 0.0 else 1.0)
	var whole := int(f["mend_acc"])
	f["mend_acc"] -= whole
	f["hp"] = mini(f["max_hp"], f["hp"] + whole)


## Starts move m for fighter i at its target the way the AI and J do: telegraph first, then the
## sweep or the move. A hook for the checks.
func cast_as(i: int, m: String) -> void:
	var f: Dictionary = _fighters[i]
	var t := _foe_of(i)
	if t < 0 or f["hp"] <= 0:
		return
	if TELEGRAPH.has(m):
		var wt: float = TELEGRAPH[m][1] * _listen_factor(i)
		f["windup"] = {"m": m, "kind": TELEGRAPH[m][0], "t": wt, "total": wt, "target": t, "at": _fighters[t]["body"].position}
		f["facing"] = _facing_of(_fighters[t]["body"].position - f["body"].position)
		_anim(i, "wind", wt, (_fighters[t]["body"].position - f["body"].position).normalized())
	else:
		_fire(i, m, t)


## The move goes off, and its cooldown starts (one charge of it, for a move with charges).
## Then the creature recovers for the move's own recovery time.
func _fire(i: int, m: String, t: int) -> void:
	_do_move(i, m, t)
	_spend(i, m)


## The move's cost: its cooldown (one charge, for a move with charges) and its recovery.
func _spend(i: int, m: String) -> void:
	var f: Dictionary = _fighters[i]
	f["recovering"] = m
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
		f["act"] = _recovery(m)
		return
	f["cds"][m] = MOVES[m]["cooldown"] * (AI_SLOWER if f["ai"] else 1.0)
	if f.get("phase_break", false):
		f["cds"][m] = PHASE_BREAK_COOLDOWN
		f["phase_break"] = false
	f["act"] = _recovery(m)


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
	if w.get("decoy", false):
		_label(i, "Decoy")
		_log_ai(i, "the decoy passes")
		return
	_aim_point = w.get("at", Vector2(INF, INF))
	var free: bool = w.get("free", false)   # the player's swing down a chosen line, not at the target
	if w["kind"] == "melee":
		# A melee move is a sweep: it connects a moment after the telegraph, on whoever is still
		# inside the arc in front of its user; a target that stepped out makes it whiff.
		var aim: Vector2 = w["aim"] if free else (_fighters[t]["body"].position - f["body"].position).normalized()
		f["facing"] = _facing_of(aim)
		_anim(i, "strike", 0.18, aim)
		_effects.append({"kind": "sweep", "owner": i, "m": w["m"], "target": t, "t": 0.0, "dir": aim, "reach": MOVES[w["m"]]["range"] + SWEEP_REACH_EXTRA, "free": free})
		_spend(i, w["m"])
	else:
		_aim_override = w["aim"] if free else Vector2.ZERO
		_fire(i, w["m"], t)
		_aim_override = Vector2.ZERO
	_aim_point = Vector2(INF, INF)


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
## Kit Sense: the mode a creature is in this think. Desires are the named levels; the
## highest wins. finish: a kill is on the table. peel: an ally is in trouble and this is the
## kind of creature that answers that. kite: a blow is coming, or it is low, and it is not a
## tank. hold: the enemy stands in our terrain. engage: the default.
func _mode_of(i: int, t: int) -> String:
	var f: Dictionary = _fighters[i]
	var foe: Dictionary = _fighters[t]
	var dist: float = foe["body"].position.distance_to(f["body"].position)
	var desires := {"engage": DESIRE_MODERATE, "finish": 0.0, "peel": 0.0, "kite": 0.0, "hold": 0.0, "crest": 0.0}
	if _finish_target(i) >= 0:
		desires["finish"] = DESIRE_VERYHIGH
	if f["role"] in ["Protector", "Tank", "Bruiser"] and _ally_in_trouble(i) >= 0:
		desires["peel"] = DESIRE_HIGH
	if f["role"] not in ["Tank", "Bruiser", "Wall", "Protector"] and dist < 45.0:
		if f["hp"] < f["max_hp"] * 0.5:
			desires["kite"] = DESIRE_HIGH
		elif _threat_near(i, 45.0):
			desires["kite"] = DESIRE_MODERATE + 0.1
	if f["role"] in ["Tank", "Bruiser"] and _hazard_slow(t) < 1.0:
		desires["hold"] = DESIRE_MODERATE + 0.05
	if team_size > 1 and f["final"] and f["meter"] < 100 and dist > 70.0 and not _threat_near(i, 60.0) and _crest_team != f["team"]:
		desires["crest"] = DESIRE_MODERATE + 0.05   # nothing to fight: go charge at the Crest
	var best := "engage"
	for k in desires:
		if desires[k] > desires[best]:
			best = k
	return best


## The enemy within reach that this creature's ready moves could kill right now, else -1.
func _finish_target(i: int) -> int:
	var f: Dictionary = _fighters[i]
	var best := -1
	for j in _fighters.size():
		var o: Dictionary = _fighters[j]
		if not _enemies(i, j) or o["hp"] <= 0 or o["phase"] > 0.0 or o["invuln"] > 0.0 or o["hidden"]:
			continue
		if o["body"].position.distance_to(f["body"].position) > FINISH_REACH:
			continue
		if o["hp"] + o["shield"] <= _combo_damage(i, j) and (best < 0 or o["hp"] < _fighters[best]["hp"]):
			best = j
	return best


## What every ready damaging move of fighter i would do to fighter j together.
func _combo_damage(i: int, j: int) -> int:
	var f: Dictionary = _fighters[i]
	var total := 0
	for m in f["kit"]:
		if MOVES[m]["damage"] > 0 and f["cds"][m] <= 0.0:
			total += _dmg(m, i, j)
	return total


## How long fighter j stays held (stunned, rooted, dazed or Glassed), 0 when it is free.
func _held_for(j: int) -> float:
	var o: Dictionary = _fighters[j]
	return maxf(maxf(o["stun"], o["rooted"]), maxf(o["dazzle"], o["glassed"]))


## Kit Sense: how much fighter i wants move m on fighter t in this mode, 0 to 1. The
## existing "wants" rule is the gate (0.5 when it says yes), then the considerations.
func _desire(i: int, m: String, t: int, mode: String) -> float:
	var f: Dictionary = _fighters[i]
	var foe: Dictionary = _fighters[t]
	var ability: bool = m in f["abilities"]
	if not _wants(i, m, foe):
		return 0.0
	var d: float = DESIRE_MODERATE if ability else DESIRE_BASIC
	var hits: bool = MOVES[m]["damage"] > 0
	if hits and foe["phase"] > 0.0:
		return 0.0   # it would pass through
	if hits and foe["hp"] + foe["shield"] <= _dmg(m, i, t):
		d = maxf(d, DESIRE_VERYHIGH)   # kill-secure
	var windup: float = TELEGRAPH[m][1] if TELEGRAPH.has(m) else 0.0
	if hits and _held_for(t) > windup:
		d *= 1.4   # it cannot dodge or phase this
	var call: Dictionary = _called[f["team"]]
	if hits and call["target"] == t and _clock < call["until"]:
		d *= 1.2   # the team is on it
	if hits and _combo_of(m, t) != "":
		d *= 1.3   # a combo is on the table (shatter, kindle, quench, conduct)
	if hits and not ability and f["follow_t"] > 0.0:
		d *= 1.4   # a follow-up: its ability just landed, the basic now hits harder and refunds it
	if hits and not foe["windup"].is_empty() and not _armoured(t) and windup < foe["windup"]["t"]:
		d *= 1.25   # a counter hit: this lands inside its wind-up
	elif hits and foe["act"] > 0.0 and foe["recovering"] != "" and windup < foe["act"]:
		d *= 1.2    # a punish: it is still recovering from its own move
	match mode:
		"kite":
			d *= 1.5 if MOVES[m].get("mobility", false) else 0.7
		"peel":
			d *= 1.5 if m in PEEL_MOVES else 1.0
		"finish":
			d *= 1.2 if hits else 0.6
	return minf(d, 1.0)


## Airborne (after League's taxonomy): launched, it cannot move or act, its ram or tackle is
## cancelled, ground hazards miss it, and tenacity does not shorten it.
func _launch(j: int, seconds: float) -> void:
	var f: Dictionary = _fighters[j]
	if f["hp"] <= 0 or f["phase"] > 0.0 or f["invuln"] > 0.0:
		return
	f["airborne"] = maxf(f["airborne"], seconds)
	f["airborne_len"] = f["airborne"]
	f["ram_t"] = 0.0
	f["tackle"] = {}
	f["windup"] = {}
	_label(j, "Launched")


## The Crest: the centre circle. A team holding it alone charges its finals' meters and
## mends a little; contested, nothing. Pulls fights to the middle (after Unite's objectives).
func _update_crest(delta: float) -> void:
	var centre: Vector2 = _floor().get_center()
	var inside := [[], []]
	for j in _fighters.size():
		var f: Dictionary = _fighters[j]
		if f["hp"] > 0 and not f["hidden"] and f["body"].position.distance_to(centre) < CREST_RADIUS:
			inside[f["team"]].append(j)
	_crest_team = -1
	if inside[0].is_empty() == inside[1].is_empty():
		return   # empty or contested
	_crest_team = 0 if not inside[0].is_empty() else 1
	_crest_tick -= delta
	for j in inside[_crest_team]:
		var f: Dictionary = _fighters[j]
		if f["final"] and f["meter"] < 100:
			f["crest_acc"] += CREST_METER * delta   # the meter is whole numbers; bank the fractions
			while f["crest_acc"] >= 1.0:
				f["crest_acc"] -= 1.0
				f["meter"] = mini(100, f["meter"] + 1)
		if _crest_tick <= 0.0 and f["hp"] < f["max_hp"]:
			_mend(j, CREST_HEAL)
	if _crest_tick <= 0.0:
		_crest_tick = 0.5


## The clock ran out: the team with more of its HP left wins on points.
func _decide_on_points() -> void:
	var left := [0.0, 0.0]
	for f in _fighters:
		left[f["team"]] += float(f["hp"]) / f["max_hp"]
	_winner = 0 if left[0] >= left[1] else 1
	_on_points = true
	_cheer = 3.0
	for j in _fighters.size():
		if _fighters[j]["team"] == _winner and _fighters[j]["hp"] > 0:
			_label(j, "On points")
			break


## Start one procedural animation on fighter i (wind, strike, flinch, land, ko).
func _anim(i: int, kind: String, seconds: float, dir: Vector2) -> void:
	var f: Dictionary = _fighters[i]
	f["anim"] = kind
	f["anim_t"] = seconds
	f["anim_len"] = seconds
	f["anim_dir"] = dir if dir.length() > 0.01 else Vector2.RIGHT


## The essence combo move m would make on fighter t right now, or "".
func _combo_of(m: String, t: int) -> String:
	if t < 0 or not MOVE_ESSENCE.has(m):
		return ""
	var ess: int = MOVE_ESSENCE[m]
	var o: Dictionary = _fighters[t]
	if ess == E.STONE and o["glassed"] > 0.0:
		return "shatter"
	if ess == E.EMBER and o["rooted"] > 0.0:
		return "kindle"
	if ess == E.TIDE and o["smoulder"] > 0.0:
		return "quench"
	if ess == E.ELECTRIC and _in_riptide(t):
		return "conduct"
	if ess == E.BLOOM and _in_riptide(t) and o["rooted"] <= 0.0:
		return "overgrow"
	return ""


## Kit Sense: an enemy that has just been held becomes its opponents' called target.
func _call_target(j: int) -> void:
	var team: int = 1 - _fighters[j]["team"]
	var again: bool = _called[team]["target"] == j and _clock < _called[team]["until"]
	_called[team] = {"target": j, "until": _clock + CALL_SECONDS}
	if not again:
		_log_ai(j, "held, so the other team calls it")   # a hold refreshed on the same target only extends the call


## A line of the AI explaining itself (L shows the last few in the arena).
func _log_ai(i: int, text: String) -> void:
	ai_log.append("%5.1f %s: %s" % [_clock, _fighters[i]["name"], text])
	if ai_log.size() > 60:
		ai_log.pop_front()


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
		"lunge":
			# From mid range at something that can be gripped: the rush closes, bites and flings it back.
			return dist > 30.0 and dist < MOVES[m]["range"] and foe["phase"] <= 0.0 and f["ram_t"] <= 0.0 and foe["passive"] != "rampart" and foe["cocoon"] <= 0.0
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
		"echo_tap":
			return dist < MOVES[m]["range"] and foe["phase"] <= 0.0
		"interrupt_call":
			# Call when an enemy in reach is winding something up (not a charge: those cannot be stopped).
			for j in _fighters.size():
				var o: Dictionary = _fighters[j]
				if _enemies(i, j) and o["hp"] > 0 and not o["windup"].is_empty() and o["windup"]["kind"] != "charge" and o["body"].position.distance_to(f["body"].position) < CALL_RADIUS:
					return true
			return false
		"deep_brace":
			# Brace when a blow is about to land on it and it cannot call it off.
			return f["brace"] <= 0.0 and _threat_near(i, 45.0)
		"still_water":
			# Lay still water under an enemy that is not already in some.
			return dist < MOVES[m]["range"] and not _in_still(_fighters.find(foe))
		"shear":
			return dist < MOVES[m]["range"] and foe["phase"] <= 0.0
		"whistle_dart":
			return dist < MOVES[m]["range"] + (VANTAGE_RANGE if f["perched"] >= 0 else 0.0) and foe["phase"] <= 0.0
		"signal_mark":
			# Mark whoever the team is on, or the target, when it is not marked yet.
			return foe["marked"] <= 0.0 and dist < MOVES[m]["range"]
		"decoy_call":
			# Bluff when the enemy has a dodge, a Phase or a dash ready and is close enough to spend it.
			return dist < MOVES[m]["range"] and (foe["dodge_cd"] <= 0.0 or foe["dash_cd"] <= 0.0 or foe["cds"].get("phase", 1.0) <= 0.0) and foe["windup"].is_empty()
		"vantage":
			# Up onto a rock when one is near and an enemy is closing.
			return f["perched"] < 0 and _rock_near_point(f["body"].position, VANTAGE_REACH) >= 0 and _nearest_foe(i) >= 0 and _fighters[_nearest_foe(i)]["body"].position.distance_to(f["body"].position) < 80.0
		"kingstone_lift":
			# A rock in reach to throw, or a target close enough to seize.
			return foe["phase"] <= 0.0 and (( _rock_near_point(f["body"].position, LIFT_REACH) >= 0 and dist < MOVES[m]["range"]) or dist < 60.0)
		"sail_cover":
			# A sail over whoever is hurt or about to be hit, itself included.
			var w := _guard_target(i)
			return w >= 0 and _fighters[w]["shield"] <= 0 and (_fighters[w]["hp"] < _fighters[w]["max_hp"] * 0.7 or _threat_near(w, 45.0))
		"downdraft":
			# Ground the shots when a shooter is up and nobody is covered yet.
			var shooter := false
			for j in _fighters.size():
				var o: Dictionary = _fighters[j]
				if _enemies(i, j) and o["hp"] > 0 and (o["profile"] in ["kite", "kite_near"] or o["role"] == "Artillery"):
					shooter = true
			var w := _most_hurt_ally(i)
			return shooter and w >= 0 and not _in_downdraft(_fighters[w]["body"].position, f["team"])
		"lift":
			# Fly out the ally that is pressed and hurt.
			var w := _ally_in_trouble(i)
			return w >= 0 and w != i and _fighters[w]["hp"] < _fighters[w]["max_hp"] * 0.6
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
	var aim := _aim_override if _aim_override != Vector2.ZERO else to_foe.normalized()   # a free swing goes where the player aimed
	f["facing"] = _facing_of(aim)
	var mouth: Vector2 = f["body"].position + Vector2(0, -10) + aim * 8.0
	var hot: bool = f["passive"] in ["stoke", "kiln"] and f["heat"] >= 100.0 and MOVES[m]["damage"] > 0   # Stoke or Kiln Heat spent on this move
	var dmg := _dmg(m, i, t)
	_label(i, MOVES[m]["name"])
	f["last_move"] = m
	_anim(i, "strike", 0.18, aim)
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
			_effects.append({"kind": "seed", "owner": i, "from": mouth, "to": _spot(foe), "t": 0.0, "damage": dmg})
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
			_effects.append({"kind": "impact", "anim": "spark_bolt", "pos": to + Vector2(0, 8), "t": 0.0})
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
			var floor_rect: Rect2 = _floor()
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
		"needle_bite":
			# The ambusher's bite: a snap of needle teeth up close.
			_effects.append({"kind": "claw", "pos": foe["body"].position + Vector2(0, -8), "dir": aim, "t": 0.0})
			_hurt(t, dmg, aim * 0.5, i)
			_play("res://assets/audio/sfx/ui/hit_weak.wav", -8.0)
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
			var floor_rect: Rect2 = _floor()
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
			_anim(i, "land", 0.15, Vector2.ZERO)
			_play("res://assets/audio/sfx/stormlantern/throw.wav", -12.0)
		"sinkhole", "burrow", "dive":
			# Sinks into its hollow and resurfaces behind the target (the far side from where it
			# was), sharpening its next Deep Jet: the assassin's ambush.
			var floor_rect: Rect2 = _floor()
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
			f["sink_from"] = f["body"].position
			_play("res://assets/audio/sfx/undertow/plunge.wav", -10.0)
		"riptide":
			# A current opens under the target: slowed, pulled in, no movement abilities while inside.
			var rpos: Vector2 = _spot(foe)
			_effects.append({"kind": "riptide", "owner": i, "pos": rpos, "t": 0.0})
			if foe["body"].position.distance_to(rpos) < RIPTIDE_RADIUS:
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
			_effects.append({"kind": "rootrun", "owner": i, "from": f["body"].position + Vector2(0, 4), "to": _spot(foe), "t": 0.0, "damage": dmg})
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
			_effects.append({"kind": "impact", "anim": "slam_shock", "pos": foe["body"].position + Vector2(0, 6), "t": 0.0, "scale": 1.4})
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
			var spot: Vector2 = _spot(foe)
			_effects.append({"kind": "spikes", "pos": spot, "t": 0.0})
			_effects.append({"kind": "impact", "anim": "jade_spikes", "pos": spot + Vector2(0, 6), "t": 0.0, "scale": 1.3})
			_burst(spot + Vector2(0, -6), Color("#7cf5b8"), Color("#206349"), 18.0, false, "earth_burst")
			var spiked := _hit_at(spot, 18.0, i)
			if spiked >= 0:
				_hurt(spiked, dmg, Vector2.ZERO, i)
				var sf: Dictionary = _fighters[spiked]
				if sf["hp"] > 0 and sf["phase"] <= 0.0 and sf["invuln"] <= 0.0:
					sf["rooted"] = maxf(sf["rooted"], SPIKE_ROOT)
					_label(spiked, "Spiked")
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
					_launch(j, 0.45)
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
			var floor_rect: Rect2 = _floor()
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
			var floor_rect: Rect2 = _floor()
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
					_launch(j, 0.4)
			_effects.append({"kind": "rail_beam", "from": here + Vector2(0, -22), "to": here + Vector2(0, 2), "t": 0.0})
			_burst(here + Vector2(0, -2), Color("#afe8b8"), Color("#206349"), 18.0, false, "jade_burst")
			_effects.append({"kind": "dust", "pos": land, "t": 0.0})
			f["body"].position = land
			f["invuln"] = maxf(f["invuln"], RECOIL_INVULN)
			_anim(i, "land", 0.15, Vector2.ZERO)
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
			# A quick electric punch, the first or second of a chain; the third is a hook that
			# goes through everyone in front (after Ravana's hit chain). Charged by the dance,
			# a punch hits harder and stuns.
			var jab_dmg := dmg
			if f["charged"] > 0.0:
				jab_dmg = int(round(dmg * CHARGED_JAB))
				f["charged"] = 0.0
				if foe["phase"] <= 0.0 and foe["invuln"] <= 0.0:
					foe["stun"] = maxf(foe["stun"], CHARGED_STUN)
				_label(i, "Charged Jab")
			f["chain_hits"] = (f["chain_hits"] + 1) if f["chain_t"] > 0.0 else 1
			f["chain_t"] = CHAIN_RESET
			if f["chain_hits"] >= 3:
				f["chain_hits"] = 0
				var hook := int(round(jab_dmg * HOOK_BONUS))
				var n := 0
				for j in _fighters.size():
					var o: Dictionary = _fighters[j]
					if _enemies(i, j) and o["hp"] > 0 and o["body"].position.distance_to(f["body"].position) < MOVES[m]["range"] + 20.0:   # the hook reaches past a pushed target
						var d: Vector2 = (o["body"].position - f["body"].position).normalized()
						if j == t or absf(d.angle_to(aim)) < HOOK_ARC:
							_effects.append({"kind": "impact", "anim": "shock_burst", "pos": o["body"].position + Vector2(0, -8), "t": 0.0, "scale": 1.4})
							_hurt(j, hook, d * 1.4, i)
							n += 1
				_label(i, "Hook" if n <= 1 else "Hook x%d" % n)
				_play("res://assets/audio/sfx/stormlantern/crack.wav", -6.0)
			else:
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
				var floor_rect: Rect2 = _floor()
				var wp: Vector2 = _fighters[w]["body"].position
				var side: Vector2 = (_fighters[nf]["body"].position - wp).normalized() if nf >= 0 else aim
				_effects.append({"kind": "impact", "anim": "lantern_flash", "pos": f["body"].position + Vector2(0, -4), "t": 0.0})
				f["body"].position = (wp + side * 14.0).clamp(floor_rect.position, floor_rect.end)
				_effects.append({"kind": "impact", "anim": "lantern_flash", "pos": f["body"].position + Vector2(0, -4), "t": 0.0})
				_anim(i, "land", 0.15, Vector2.ZERO)
			if nf >= 0 and _fighters[nf]["hp"] > 0 and _fighters[nf]["body"].position.distance_to(f["body"].position) < 44.0:
				var push: Vector2 = (_fighters[nf]["body"].position - f["body"].position).normalized()
				f["facing"] = _facing_of(push)
				_effects.append({"kind": "impact", "anim": "shock_burst", "pos": _fighters[nf]["body"].position + Vector2(0, -8), "t": 0.0})
				_hurt(nf, _dmg(m, i, nf), push * 2.2, i)
			_play("res://assets/audio/sfx/stormlantern/crack.wav", -8.0)
		"shear":
			# A sail slash: the membrane snaps through the target.
			_effects.append({"kind": "impact", "anim": "sail_slash", "pos": foe["body"].position + Vector2(0, -4), "t": 0.0})
			_hurt(t, dmg, aim * 0.8, i)
			_play("res://assets/audio/sfx/canvaswing/shear.wav", -8.0)
		"sail_cover":
			# A sail thrown over the most hurt ally in reach (itself if nobody else needs it).
			var w := _guard_target(i)
			if w >= 0:
				_shield(w, SAIL_SHIELD, SAIL_SECONDS, "sail_cover")
				_effects.append({"kind": "impact", "anim": "gust_lift", "pos": _fighters[w]["body"].position + Vector2(0, -4), "t": 0.0})
			_play("res://assets/audio/sfx/canvaswing/shear.wav", -14.0)
		"downdraft":
			# A column of falling air over the most hurt ally: enemy shots and lobs that enter it drop.
			var w := _most_hurt_ally(i)
			var at: Vector2 = _fighters[w]["body"].position if w >= 0 else f["body"].position
			_effects.append({"kind": "downdraft", "owner": i, "pos": at, "t": 0.0})
			_burst(at + Vector2(0, -10), Color("#e8eef4"), Color("#8ea4b8"), 16.0, false, "")
			_play("res://assets/audio/sfx/stormlantern/throw.wav", -14.0)
		"lift":
			# It grabs the ally in the most trouble and flies it toward the team, out of roots and reach.
			var w := _ally_in_trouble(i)
			if w < 0:
				w = _most_hurt_ally(i)
			if w >= 0 and w != i:
				var o: Dictionary = _fighters[w]
				var floor_rect: Rect2 = _floor()
				var nf := _nearest_foe(w)
				var away: Vector2 = (o["body"].position - _fighters[nf]["body"].position).normalized() if nf >= 0 else -aim
				var to: Vector2 = (o["body"].position + away * LIFT_DISTANCE).clamp(floor_rect.position, floor_rect.end)
				if _blocked(to):
					to = (o["body"].position + away * LIFT_DISTANCE * 0.5).clamp(floor_rect.position, floor_rect.end)
				_effects.append({"kind": "impact", "anim": "gust_lift", "pos": o["body"].position + Vector2(0, -4), "t": 0.0})
				o["body"].position = to
				f["body"].position = (to + away * 12.0).clamp(floor_rect.position, floor_rect.end)
				o["rooted"] = 0.0
				o["crippled"] = 0.0
				o["carry_t"] = 0.0
				o["invuln"] = maxf(o["invuln"], 0.3)
				_anim(w, "land", 0.15, Vector2.ZERO)
				_anim(i, "land", 0.15, Vector2.ZERO)
				_effects.append({"kind": "impact", "anim": "gust_lift", "pos": to + Vector2(0, -4), "t": 0.0})
				_label(w, "Lifted")
			_play("res://assets/audio/sfx/canvaswing/shear.wav", -10.0)
		"whistle_dart":
			# A whistling dart: a thin fast shot down the line.
			_effects.append({"kind": "fireball", "owner": i, "pos": mouth, "vel": aim * 230.0, "life": 0.7, "trail": [], "damage": dmg, "dart": true})
			_play("res://assets/audio/sfx/dustkite/whistle_dart.wav", -10.0)
		"signal_mark":
			# The mark: the whole team's hits on it land harder, and Stormwick can teleport to it.
			foe["marked"] = MARK_SECONDS
			_label(t, "Marked")
			_effects.append({"kind": "impact", "anim": "lantern_flash", "pos": foe["body"].position + Vector2(0, -24), "t": 0.0})
			_play("res://assets/audio/sfx/dustkite/whistle_dart.wav", -6.0)
		"decoy_call":
			# A bluff: it shows a telegraph at the target and fires nothing, so the enemy spends
			# its dodge, its Phase or its dash on air.
			f["windup"] = {"m": "whistle_dart", "kind": "line", "t": DECOY_SECONDS, "total": DECOY_SECONDS, "target": t, "at": foe["body"].position, "decoy": true}
			_play("res://assets/audio/sfx/dustkite/whistle_dart.wav", -14.0)
		"vantage":
			# Up onto the nearest rock: out of melee reach, a longer dart, until it moves or the rock breaks.
			var rk := _rock_near_point(f["body"].position, VANTAGE_REACH)
			if rk >= 0:
				var r: Dictionary = _rocks[rk]
				f["perched"] = rk
				f["perch_t"] = 0.0
				f["body"].position = r["pos"] + Vector2(0, -r["h"] * 0.55)
				f["vel"] = Vector2.ZERO
				_anim(i, "land", 0.15, Vector2.ZERO)
				_effects.append({"kind": "dust", "pos": r["pos"], "t": 0.0})
				_label(i, "Vantage")
			_play("res://assets/audio/sfx/ui/cursor.wav", -12.0)
		"echo_tap":
			# A sonar tap down the line: the pulse lands and rings back off the target.
			_effects.append({"kind": "impact", "anim": "sonar_ring", "pos": foe["body"].position + Vector2(0, 6), "t": 0.0})
			_burst(foe["body"].position + Vector2(0, -8), Color("#e8f6ff"), Color("#3fb0a8"), 8.0, false, "water_burst")
			_hurt(t, dmg, aim * 0.6, i)
			_play("res://assets/audio/sfx/listener/echo_tap.wav", -8.0)
		"interrupt_call":
			# The call: a ring of sound round it; every enemy in it loses its wind-up and reels.
			var n := _call_out(i, CALL_RADIUS, dmg, CALL_STUN)
			_effects.append({"kind": "ring", "pos": f["body"].position, "size": CALL_RADIUS, "t": 0.0, "lines": [], "rim": Color("#9fe8e0")})
			_effects.append({"kind": "impact", "anim": "sonar_ring", "pos": f["body"].position + Vector2(0, 8), "t": 0.0, "scale": 2.5})
			_label(i, "Call" if n == 0 else "Call: %d" % n)
			_play("res://assets/audio/sfx/listener/echo_tap.wav", -2.0)
		"deep_brace":
			# It plants in the current: takes half, cannot be moved, and pushes come back on the pusher.
			f["brace"] = BRACE_SECONDS
			f["walk"] = 0.0
			_effects.append({"kind": "impact", "anim": "sonar_ring", "pos": f["body"].position + Vector2(0, 8), "t": 0.0, "scale": 1.4})
			_label(i, "Brace")
			_play("res://assets/audio/sfx/undertow/plunge.wav", -12.0)
		"still_water":
			# Still water under the target: enemy cooldowns crawl while they stand in it.
			var wpos: Vector2 = _spot(foe)
			_effects.append({"kind": "still_water", "owner": i, "pos": wpos, "r": STILL_RADIUS, "t": 0.0, "life": STILL_SECONDS})
			_burst(wpos, Color("#cfeeea"), Color("#1f5a58"), 12.0, false, "water_burst")
			_play("res://assets/audio/sfx/undertow/plunge.wav", -8.0)
		"glass_guard":
			# Plants and runs its shell molten: a glass guard round it for a few seconds.
			f["guard"] = GUARD_SECONDS
			f["walk"] = 0.0
			_effects.append({"kind": "guard", "who": i, "t": 0.0})
			_label(i, "Guard")
			_play("res://assets/audio/sfx/vitrecrag/buildup.wav", -10.0)
		"plate_lunge":
			# The shell shoves forward and seizes: the target is hoisted over the shell a moment,
			# then hurled the way Vitrecrag faces (a carry, so it slams into walls and rocks).
			_burst(foe["body"].position + Vector2(0, -6), Color("#f0d8b0"), Color("#6a4a3a"), 16.0, false, "earth_burst")
			_effects.append({"kind": "impact", "anim": "slam_shock", "pos": foe["body"].position + Vector2(0, 6), "t": 0.0, "scale": 1.3})
			_hurt(t, dmg, Vector2.ZERO, i)
			if not _grab(i, t, aim):
				_carry(t, aim * 2.0, i)   # what cannot be seized is still shoved
			_play("res://assets/audio/sfx/root_rampart/slam.wav", -10.0)
		"kingstone_lift":
			# The Kingstone's pull: the nearest rock rises beside Oxbowarchon and is thrown onto
			# the target; with no rock in reach, the target itself is seized and flung.
			var rk := _rock_near_point(f["body"].position, LIFT_REACH)
			if rk >= 0 and _rocks[rk].get("lift", 0.0) <= 0.0:
				var r: Dictionary = _rocks[rk]
				r["lift"] = 0.01
				_effects.append({"kind": "lifted_rock", "rock": rk, "owner": i, "target": t, "t": 0.0, "from": r["pos"], "to": foe["body"].position})
				_effects.append({"kind": "ring", "pos": r["pos"], "size": r["rx"] + 6.0, "t": 0.0, "lines": [], "rim": Color("#7cf5b8")})
				_label(i, "Lift")
				_play("res://assets/audio/sfx/oxbowarchon/rail_charge.wav", -8.0)
			else:
				_hurt(t, dmg, Vector2.ZERO, i)
				var away: Vector2 = (foe["body"].position - f["body"].position).normalized()
				if _grab(i, t, away, true):
					_play("res://assets/audio/sfx/oxbowarchon/rail_charge.wav", -8.0)
		"molten_cannon":
			# A mass of molten glass lobbed from the crater onto the target's spot; it carries whoever it lands on.
			var crater: Vector2 = f["body"].position + Vector2(0, -22 - 3 * f["stage"])
			_effects.append({"kind": "seed", "owner": i, "from": crater, "to": _spot(foe), "t": 0.0, "damage": dmg, "molten": true, "push": CANNON_PUSH})
			_play("res://assets/audio/sfx/vitrecrag/buildup.wav", -12.0)
		"molten_beam":
			# A pour of molten glass straight from the mouth: a short, bright beam.
			_effects.append({"kind": "beam", "owner": i, "from": mouth, "dir": aim, "len": 0.0, "life": 0.9, "damage": dmg, "reach": 125.0, "molten": true, "pin": true, "target": t, "tick": 0.0, "mark": 0.0})
			_play("res://assets/audio/sfx/ironvent/vent_jet.wav", -12.0)
		"lunge":
			# The ambusher's rush: low and fast at the target; on contact it bites and flings
			# the target back the way it came (the grab verb), then stands over the spot.
			f["ram_t"] = minf(0.45, maxf(0.08, (to_foe.length() - 8.0) / POUNCE_SPEED))
			f["ram_dir"] = aim
			f["ram_dmg"] = dmg
			f["ram_return"] = false
			f["ram_end_hit"] = false
			f["ram_grip"] = true
			_effects.append({"kind": "dust", "pos": f["body"].position - aim * 4.0, "t": 0.0})
			_play("res://assets/audio/sfx/undertow/surge.wav", -10.0)
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


## Chain of Blows (after Ravana): every hit the Punchybuns line lands adds one; at the payout
## a stage 2 or 3 form shields itself and the allies beside it for a share of its max HP (the
## shields stack to CHAIN_STACKS) and gets a burst of speed. Stage 1 only counts.
func _chain_hit(i: int) -> void:
	var f: Dictionary = _fighters[i]
	f["chain"] += 1
	if f["chain"] < CHAIN_PAYOUT:
		return
	f["chain"] = 0
	if f["passive"] != "chain":
		return
	f["chain_stacks"] = mini(CHAIN_STACKS, f["chain_stacks"] + 1)
	var amount := int(round(f["max_hp"] * CHAIN_SHIELD))
	for j in _fighters.size():
		var o: Dictionary = _fighters[j]
		if o["team"] == f["team"] and o["hp"] > 0 and (j == i or o["body"].position.distance_to(f["body"].position) < GUARDIAN_RADIUS):
			o["shield"] = mini(amount * CHAIN_STACKS, o["shield"] + amount)   # stacks, capped
			o["shield_t"] = maxf(o["shield_t"], CHAIN_SHIELD_SECONDS)
			o["shield_anim"] = "star_shield"
	f["haste"] = maxf(f["haste"], CHAIN_HASTE)
	_label(i, "Chain x%d" % f["chain_stacks"])
	_effects.append({"kind": "impact", "anim": "spark_bolt", "pos": f["body"].position + Vector2(0, 4), "t": 0.0, "scale": 1.3})
	_play("res://assets/audio/sfx/starward/star_guard.wav", -10.0)


## A star shield on fighter j: absorbs `amount` before HP, for `seconds`.
func _shield(j: int, amount: int, seconds: float, anim := "star_shield") -> void:
	var f: Dictionary = _fighters[j]
	if f["hp"] <= 0:
		return
	f["shield"] = maxi(f["shield"], amount)
	f["shield_t"] = maxf(f["shield_t"], seconds)
	f["shield_anim"] = anim
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


## Hush (Quietwater Warden): the river goes still. Every enemy wind-up is cancelled, every
## enemy is dazed and its abilities are locked for a few seconds, and still water lies over
## the whole floor so their cooldowns crawl. Hollow: the sound is taken away, not added.
func _on_hush(at: Vector2) -> void:
	for j in _fighters.size():
		var f: Dictionary = _fighters[j]
		if f["hp"] <= 0 or f["team"] == _fighters[_sig_user]["team"]:
			continue
		if not f["windup"].is_empty():
			f["cds"][f["windup"]["m"]] = 0.8
			f["windup"] = {}
		f["tackle"] = {}
		f["hush"] = HUSH_SECONDS
		if f["phase"] <= 0.0 and f["invuln"] <= 0.0:
			f["dazzle"] = maxf(f["dazzle"], HUSH_DAZE)
		_label(j, "Hushed")
	_effects.append({"kind": "still_water", "owner": _sig_user, "pos": at, "r": HUSH_RADIUS, "t": 0.0, "life": HUSH_SECONDS})
	_hitstop = maxf(_hitstop, HITSTOP_HEAVY)


## Gale Shear (Galeshear): one wing sweep. Every enemy is carried away from the glider to the
## arena edge (a carry, so they slam into walls and rocks on the way); allies get a tailwind.
## No shield: DESIGN_RULES keeps the guard ultimate for the Protector.
func _on_gale_sweep(from: Vector2) -> void:
	var centre: Vector2 = _floor().get_center()
	for j in _fighters.size():
		var f: Dictionary = _fighters[j]
		if f["hp"] <= 0:
			continue
		if f["team"] == _fighters[_sig_user]["team"]:
			f["haste"] = maxf(f["haste"], GALE_TAILWIND)
			_effects.append({"kind": "impact", "anim": "gust_lift", "pos": f["body"].position + Vector2(0, -4), "t": 0.0, "scale": 1.3})
			if j != _sig_user:
				_label(j, "Tailwind")
			continue
		var d: Vector2 = f["body"].position - from
		if d.length() < 1.0:
			d = f["body"].position - centre
		var dir: Vector2 = d.normalized() if d.length() > 0.01 else Vector2.RIGHT
		f["windup"] = {}
		f["tackle"] = {}
		f["ram_t"] = 0.0
		_hurt(j, 1, Vector2.ZERO, _sig_user)
		_carry(j, dir * GALE_PUSH, _sig_user)
		_effects.append({"kind": "impact", "anim": "sail_slash", "pos": f["body"].position + Vector2(0, -4), "t": 0.0, "scale": 1.5})
		_label(j, "Swept")
	_hitstop = maxf(_hitstop, HITSTOP_HEAVY)


## High Signal (Highsignal): every enemy is marked and the team's next ability on each is
## doubled; tethers of light run from the spotter to every mark for a moment.
func _on_high_signal(at: Vector2) -> void:
	for j in _fighters.size():
		var f: Dictionary = _fighters[j]
		if f["hp"] <= 0 or f["team"] == _fighters[_sig_user]["team"]:
			continue
		f["marked"] = SIGNAL_SECONDS
		f["signal"] = 1
		_label(j, "Signalled")
		_effects.append({"kind": "impact", "anim": "lantern_flash", "pos": f["body"].position + Vector2(0, -24), "t": 0.0})
	_effects.append({"kind": "tethers", "owner": _sig_user, "t": 0.0})
	_cheer = maxf(_cheer, 2.0)


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


## Whether fighter i stands in an enemy's Still Water (its cooldowns crawl there).
func _in_still(i: int) -> bool:
	for e in _effects:
		if e["kind"] == "still_water" and _enemies(e["owner"], i) and _fighters[i]["body"].position.distance_to(e["pos"]) < e["r"]:
			return true
	return false


## Whether a point lies in a downdraft owned by `team` (its shots are not grounded by its own air).
func _in_downdraft(p: Vector2, team: int) -> bool:
	for e in _effects:
		if e["kind"] == "downdraft" and _fighters[e["owner"]]["team"] == team and p.distance_to(e["pos"]) < DOWNDRAFT_RADIUS:
			return true
	return false


## Listening (the River Listener line's passive): a telegraph wound up near a listening enemy
## takes longer, because it reads the move coming and the caller has to go round it.
func _listen_factor(i: int) -> float:
	for j in _fighters.size():
		var o: Dictionary = _fighters[j]
		if _enemies(i, j) and o["hp"] > 0 and o["passive"] == "listening" and o["body"].position.distance_to(_fighters[i]["body"].position) < LISTEN_RADIUS:
			return LISTEN_FACTOR
	return 1.0


## Interrupt Call: every enemy within reach of fighter i winding up a move loses it and reels.
## Returns how many were interrupted.
func _call_out(i: int, radius: float, dmg: int, stun: float) -> int:
	var f: Dictionary = _fighters[i]
	var n := 0
	for j in _fighters.size():
		var o: Dictionary = _fighters[j]
		if not _enemies(i, j) or o["hp"] <= 0 or o["body"].position.distance_to(f["body"].position) > radius:
			continue
		if not o["windup"].is_empty() and o["windup"]["kind"] != "charge":
			o["cds"][o["windup"]["m"]] = 0.8
			o["windup"] = {}
			_label(j, "Interrupted")
			n += 1
		if o["phase"] <= 0.0 and o["invuln"] <= 0.0:
			o["stun"] = maxf(o["stun"], stun)
		if dmg > 0:
			var away: Vector2 = (o["body"].position - f["body"].position).normalized()
			_hurt(j, dmg, away * 0.5, i)
	return n


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
		if r.get("lift", 0.0) > 0.0:
			continue   # a lifted rock is in the air
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


## Damage to a rock: it cracks at two thirds and one third, and shatters at zero. Part breaks
## (after Monster Hunter): each crack is a break that drops a reward shard and exposes the
## rock's weakness, so it takes more from then on.
func _hit_rock(k: int, damage: int) -> void:
	var r: Dictionary = _rocks[k]
	var before := _rock_stage(r)
	if before > 0:
		damage = int(round(damage * BREAK_WEAK))
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
		_drop_shard(r)


## A break reward: a shard that lies beside the rock for whoever walks over it (a final takes
## meter, anyone else mends a little).
func _drop_shard(r: Dictionary) -> void:
	var a: float = randf() * TAU
	_effects.append({"kind": "shard", "pos": r["pos"] + Vector2(cos(a), sin(a) * 0.5) * (r["rx"] + 10.0), "t": 0.0})


func _rock_stage(r: Dictionary) -> int:
	return 0 if r["hp"] * 3 > r["max_hp"] * 2 else (1 if r["hp"] * 3 > r["max_hp"] else 2)


## A rock shatters: big angular shards fly out and land as rubble that stays for the rest
## of the fight (the reference's debris pieces are each half a creature or more), dust goes
## up, and a dark crater is left where it stood.
func _break_rock(k: int) -> void:
	var r: Dictionary = _rocks[k]
	for j in _fighters.size():
		var pf: Dictionary = _fighters[j]
		if pf["perched"] == k:
			pf["perched"] = -1
			pf["body"].position = r["pos"] + Vector2(0, 4)
			_launch(j, 0.3)
		elif pf["perched"] > k:
			pf["perched"] -= 1   # the rock list shifts down
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
	_drop_shard(r)
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
	if f["passive"] == "ambush" and MOVES[m]["damage"] > 0 and (f["ambush"] > 0.0 or _fighters[t]["target"] != i):
		d *= AMBUSH_MULT   # the Ambush passive: out of the silt, or on an enemy not watching it
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


## The camera: the world layer is scaled about a focus point. It drops in at the start, leans
## in a little when the fighters cluster, punches in on a signature or a knockout, and shakes.
func _update_camera(delta: float) -> void:
	var view := Vector2(_view.size)
	if _cam_punch_t > 0.0:
		_cam_punch_t = maxf(0.0, _cam_punch_t - delta)
		_cam_zoom_to = _cam_punch_zoom
		_cam_focus_to = _cam_punch_at
	else:
		var lo := Vector2(INF, INF)
		var hi := Vector2(-INF, -INF)
		var n := 0
		for f in _fighters:
			if f["hp"] > 0:
				lo = lo.min(f["body"].position)
				hi = hi.max(f["body"].position)
				n += 1
		if n >= 2 and maxf(hi.x - lo.x, hi.y - lo.y) < CAM_ACTION_SPAN:
			_cam_zoom_to = CAM_ACTION_ZOOM
			_cam_focus_to = (lo + hi) * 0.5 + Vector2(0, -8)
		else:
			_cam_zoom_to = 1.0
			_cam_focus_to = view * 0.5
	var ease := 1.0 - exp(-delta * 5.0)
	_cam_zoom = lerpf(_cam_zoom, _cam_zoom_to, ease)
	_cam_focus = _cam_focus.lerp(_cam_focus_to, ease)
	var z: float = _cam_zoom
	var half: Vector2 = view * 0.5 / z
	var focus: Vector2 = _cam_focus.clamp(half, view - half) if z > 1.0 else view * 0.5
	var s3 := (_shake if shake_on else 0.0) / SCALE
	_world.scale = Vector2.ONE * z
	_world.position = (view * 0.5 - focus * z).round() + Vector2(randf_range(-s3, s3), randf_range(-s3, s3)).round()


func _cam_punch(at: Vector2, zoom: float, seconds: float) -> void:
	_cam_punch_t = seconds
	_cam_punch_zoom = zoom
	_cam_punch_at = at


## The crowd's banner: a big hit or a knockout gets a cutaway line over the stands.
func _show_banner(text: String, seconds: float) -> void:
	_banner = text
	_banner_t = seconds
	_cheer = maxf(_cheer, 2.0)


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
	_cam_punch(f["body"].position + Vector2(0, -10), 1.35, 0.5)
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
	var floor_rect: Rect2 = _floor()
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
	var floor_rect: Rect2 = _floor()
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
		elif e["kind"] == "trench" and _enemies(e["owner"], i) and Geometry2D.get_closest_point_to_segment(me, e["from"], e["to"]).distance_to(me) < TRENCH_WIDTH:
			slow = minf(slow, TRENCH_SLOW)
	return slow


## Whether fighter i stands in an enemy's trench (its dashes cannot cross broken ground).
func _in_trench(i: int) -> bool:
	var me: Vector2 = _fighters[i]["body"].position
	for e in _effects:
		if e["kind"] == "trench" and _enemies(e["owner"], i) and Geometry2D.get_closest_point_to_segment(me, e["from"], e["to"]).distance_to(me) < TRENCH_WIDTH:
			return true
	return false


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
	var floor_rect: Rect2 = _floor()
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
		elif f.get("ram_grip", false):
			# The lunge lands: a bite, then the target is seized and flung back behind the ambusher.
			f["ram_grip"] = false
			_effects.append({"kind": "claw", "pos": _fighters[hit]["body"].position + Vector2(0, -8), "dir": f["ram_dir"], "t": 0.0})
			_hurt(hit, f["ram_dmg"], Vector2.ZERO, i)
			if _grab(i, hit, -f["ram_dir"]):
				_label(hit, "Dragged")
			_play("res://assets/audio/sfx/ui/hit_strong.wav", -6.0)
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
	f["ram_grip"] = false   # a lunge that met nothing grips nothing
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
		var floor_rect: Rect2 = _floor()
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
			var floor_rect: Rect2 = _floor()
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
		var floor_rect2: Rect2 = _floor()
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
	var floor_rect: Rect2 = _floor()
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
	# Kit Sense: the team's called target (an enemy someone just held) pulls everyone but the
	# protector onto it while the hold lasts.
	var call: Dictionary = _called[f["team"]]
	if call["target"] >= 0 and _clock < call["until"] and _fighters[call["target"]]["hp"] > 0 and _enemies(i, call["target"]) \
			and f["role"] != "Protector" and _fighters[call["target"]]["body"].position.distance_to(f["body"].position) < CALL_REACH:
		f["target"] = call["target"]
		return call["target"]
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
	if f["walk"] == 0.0 and f["hp"] > 0 and f["stun"] <= 0.0 and f["target"] >= 0 and f["windup"].is_empty() and not (_mouse_aim(i) and _attack_held):
		var to_other: Vector2 = _fighters[f["target"]]["body"].position - f["body"].position
		if to_other.length() > 1.0:
			f["facing"] = _facing_of(to_other)
	f["flash"] = maxf(0.0, f["flash"] - delta)
	f["phase"] = maxf(0.0, f["phase"] - delta)
	var ten: float = TENACITY if f["role"] == "Tank" else 1.0   # tenacity: tanks shed holds faster
	f["stun"] = maxf(0.0, f["stun"] - delta * ten)
	f["dazzle"] = maxf(0.0, f["dazzle"] - delta * ten)
	f["rooted"] = maxf(0.0, f["rooted"] - delta * ten)
	f["airborne"] = maxf(0.0, f["airborne"] - delta)
	f["eroded"] = maxf(0.0, f["eroded"] - delta)
	f["crippled"] = maxf(0.0, f["crippled"] - delta)
	f["invuln"] = maxf(0.0, f["invuln"] - delta)
	f["marked"] = maxf(0.0, f["marked"] - delta)
	f["ambush"] = maxf(0.0, f["ambush"] - delta)
	f["guard"] = maxf(0.0, f["guard"] - delta)
	f["charged"] = maxf(0.0, f["charged"] - delta)
	f["haste"] = maxf(0.0, f["haste"] - delta)
	f["wound"] = maxf(0.0, f["wound"] - delta)
	f["chain_t"] = maxf(0.0, f["chain_t"] - delta)
	if f["chain_t"] <= 0.0:
		f["chain_hits"] = 0
	if f["shield"] <= 0:
		f["chain_stacks"] = 0
	f["dr_t"] = maxf(0.0, f["dr_t"] - delta)
	f["dash_cd"] = maxf(0.0, f["dash_cd"] - delta)
	f["dodge_cd"] = maxf(0.0, f["dodge_cd"] - delta)
	f["charm_cd"] = maxf(0.0, f["charm_cd"] - delta)
	f["thorns"] = maxf(0.0, f["thorns"] - delta)
	f["sunder"] = maxf(0.0, f["sunder"] - delta)
	f["slowed"] = maxf(0.0, f["slowed"] - delta)
	f["aegis"] = maxf(0.0, f["aegis"] - delta)
	f["cc_immune"] = maxf(0.0, f["cc_immune"] - delta)
	f["pinned"] = maxf(0.0, f["pinned"] - delta)
	f["follow_t"] = maxf(0.0, f["follow_t"] - delta)
	if f["passive"] == "spotter" and f["hp"] > 0:
		# The first enemy to come into range is marked (each enemy again only after a while).
		for key in f["spot_cd"].keys():
			f["spot_cd"][key] = maxf(0.0, f["spot_cd"][key] - delta)
		for j in _fighters.size():
			var o: Dictionary = _fighters[j]
			if _enemies(i, j) and o["hp"] > 0 and o["marked"] <= 0.0 and f["spot_cd"].get(j, 0.0) <= 0.0 and o["body"].position.distance_to(f["body"].position) < SPOTTER_RANGE:
				o["marked"] = MARK_SECONDS
				f["spot_cd"][j] = SPOTTER_AGAIN
				_label(j, "Spotted")
				break
	if f["perched"] >= 0 and f["perched"] < _rocks.size():
		f["perch_t"] += delta
		f["body"].position = _rocks[f["perched"]]["pos"] + Vector2(0, -_rocks[f["perched"]]["h"] * 0.55)
	if f["grabbed"] > 0.0 and f["hp"] > 0:
		# Seized: it rides over the grabber (or hangs where it was taken) until the throw.
		f["grabbed"] -= delta
		if f["grab_by"] >= 0 and _fighters[f["grab_by"]]["hp"] > 0:
			var g: Dictionary = _fighters[f["grab_by"]]
			f["body"].position = g["body"].position + Vector2(0, -4)
		f["vel"] = Vector2.ZERO
		if f["grabbed"] <= 0.0:
			f["grabbed"] = 0.0
			f["airborne"] = 0.0
			var thrower: int = f["grab_by"] if f["grab_by"] >= 0 else -1
			_carry(i, f["grab_dir"] * GRAB_FLING, thrower)
			_label(i, "Thrown")
			_effects.append({"kind": "impact", "anim": "gust_lift", "pos": f["body"].position + Vector2(0, -4), "t": 0.0})
			_shake_by(3.0)
	if f["cc_immune"] > 0.0:
		f["stun"] = 0.0; f["rooted"] = 0.0; f["dazzle"] = 0.0; f["airborne"] = 0.0; f["crippled"] = 0.0; f["slowed"] = 0.0
	if f["dr_t"] <= 0.0:
		f["dr"] = 0
	var hard_now: bool = f["hp"] > 0 and (f["stun"] > 0.0 or f["rooted"] > 0.0 or f["dazzle"] > 0.0 or f["airborne"] > 0.0)
	if hard_now and not f.get("hard_was", false):
		# Diminishing returns (after Smite): a creature held again inside DR_SECONDS is held
		# for less, each stack taking DR_STEP off, up to DR_MAX stacks.
		var cut: float = 1.0 - DR_STEP * f["dr"]
		f["stun"] *= cut
		f["rooted"] *= cut
		f["dazzle"] *= cut
		f["dr"] = mini(DR_MAX, f["dr"] + 1)
		f["dr_t"] = DR_SECONDS
		if f["dr"] > 1:
			_label(i, "Resisting")
	f["hard_was"] = hard_now
	f["brace"] = maxf(0.0, f["brace"] - delta)
	f["hush"] = maxf(0.0, f["hush"] - delta)
	f["since_hit"] += delta
	if f["group"] == "support" and f["hp"] > 0 and f["hp"] < f["max_hp"] and f["since_hit"] >= REGEN_DELAY:
		# Role passive (after Overwatch's Support): left alone, a Protector mends itself.
		f["regen_tick"] -= delta
		if f["regen_tick"] <= 0.0:
			f["regen_tick"] = REGEN_TICK
			_mend(i, REGEN_HP)
	var held_now: bool = f["hp"] > 0 and (f["stun"] > 0.0 or f["rooted"] > 0.0 or f["dazzle"] > 0.0 or f["glassed"] > 0.0)
	if held_now and not f["held_was"]:
		_call_target(i)
	f["held_was"] = held_now
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
					_burst(o["body"].position + Vector2(0, -8), Color("#afe8b8"), Color("#206349"), 12.0, false, "jade_burst")
			_effects.append({"kind": "shrapnel", "pos": f["body"].position, "t": 0.0})
			_effects.append({"kind": "impact", "anim": "jade_burst", "pos": f["body"].position + Vector2(0, 4), "t": 0.0, "scale": 2.0})
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
	if f["sink"] > 0.0 and f["sink"] - delta <= 0.0:
		# Surfacing: the tunnel it dug stays as a trench (water for the Tide line, earth for the rest).
		_effects.append({"kind": "trench", "owner": i, "from": f["sink_from"], "to": f["sink_to"], "t": 0.0, "water": f["essences"][0] == E.TIDE})
		_rubble.queue_redraw()
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
		_set_texture(f, frames[int(f["walk"] * WALK_FPS * f["speed"]) % frames.size()])
	else:
		_set_texture(f, f["art"]["still"][f["facing"]])
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
	# Procedural animation (2026-10-08): no new art, one layer of offsets and squash on top
	# of the still or walk frame: a lean back while a move winds up, a lunge as it strikes, a
	# flinch when hit, a squash on landing, a drop at the KO. Scaled about the feet.
	if f["grabbed"] > 0.0:
		var sprite_g: Sprite2D = f["sprite"]
		sprite_g.position.y -= 18.0   # hoisted
	elif f["airborne"] > 0.0:
		# Launched: an arc up and back down, the shadow staying on the floor.
		var ka0: float = 1.0 - f["airborne"] / maxf(0.01, f["airborne_len"])
		sprite.position.y -= AIRBORNE_LIFT * sin(ka0 * PI)
	if f["anim"] != "":
		f["anim_t"] -= delta
		var ka: float = 1.0 - clampf(f["anim_t"] / maxf(0.01, f["anim_len"]), 0.0, 1.0)
		var da: Vector2 = f["anim_dir"]
		match f["anim"]:
			"wind":
				sprite.position += (-da * 3.0 * ka).round()
				sprite.scale = Vector2(1.0 - 0.06 * ka, 1.0 + 0.08 * ka)
			"strike":
				var sa: float = sin(ka * PI)
				sprite.position += (da * 7.0 * sa).round()
				sprite.scale = Vector2(1.0 + 0.1 * sa, 1.0 - 0.1 * sa)
			"flinch":
				var sf: float = 1.0 - ka
				sprite.position += (da * 4.0 * sf).round()
				sprite.scale = Vector2(1.0 + 0.08 * sf, 1.0 - 0.08 * sf)
			"land":
				var sl: float = sin(ka * PI)
				sprite.scale = Vector2(1.0 + 0.14 * sl, 1.0 - 0.14 * sl)
			"ko":
				sprite.position += (da * 6.0 * (1.0 - ka)).round()
		if f["anim_t"] <= 0.0:
			f["anim"] = ""
			sprite.scale = Vector2.ONE
	else:
		sprite.scale = Vector2.ONE
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
	var floor_rect: Rect2 = _floor()
	for e in _effects:
		match e["kind"]:
			"fireball":
				if e.get("downed", false):
					continue   # grounded by a downdraft
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
						_burst(e["pos"], Color("#afe8b8"), Color("#206349"), 20.0, false, "jade_burst")
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
				# Two beams from enemies meeting head-on clash: both stop at the meeting point and the
				# stronger pushes it toward the weaker caster (the reference's beam clash).
				for o in _effects:
					if o == e or o["kind"] != "beam" or o["life"] <= 0.0 or o.get("clash_dead", false) or not _enemies(e["owner"], o["owner"]):
						continue
					if e["dir"].dot(o["dir"]) > -0.3:
						continue
					var otip: Vector2 = o["from"] + o["dir"] * o["len"]
					# Head-on beams run along one line, so a crossing test finds nothing; the clash is
					# where this beam's tip has reached the other beam.
					var near: Vector2 = Geometry2D.get_closest_point_to_segment(tip, o["from"], otip)
					if near.distance_to(tip) > 8.0:
						continue
					var p: Vector2 = (tip + near) * 0.5
					var found := false
					for c in _effects:
						if c["kind"] == "clash" and c["pos"].distance_to(p) < 24.0:
							found = true
							c["t"] = 0.0
							c["pos"] = p
					if not found:
						_effects.append({"kind": "clash", "pos": p, "t": 0.0, "strong": e["owner"] if e["damage"] >= o["damage"] else o["owner"], "weak": o["owner"] if e["damage"] >= o["damage"] else e["owner"], "a": e, "b": o})
						_shake_by(2.0)
						_show_banner("BEAM CLASH!", 1.0)
					e["len"] = minf(e["len"], e["from"].distance_to(p))
					o["len"] = minf(o["len"], o["from"].distance_to(p))
					tip = e["from"] + e["dir"] * e["len"]
					e["clashing"] = true
				var hit := _hit_along(e["from"], tip, 8.0, e["owner"])
				if e.get("pin", false) and hit >= 0:
					# A pinning beam: it shoves its target along its line, pins it against the arena
					# wall, swings after it as it is dragged, and burns it there in ticks.
					var tf: Dictionary = _fighters[hit]
					if tf["passive"] != "rampart" and tf["cocoon"] <= 0.0 and tf["aegis"] <= 0.0:
						var next: Vector2 = tf["body"].position + e["dir"] * PIN_PUSH * delta
						var clamped: Vector2 = next.clamp(floor_rect.position, floor_rect.end)
						if not _blocked(clamped):
							tf["body"].position = clamped
						if clamped != next:
							tf["pinned"] = 0.12
							if not tf.get("pin_said", false):
								_label(hit, "Pinned")
								tf["pin_said"] = true
							e["mark"] -= delta
							if e["mark"] <= 0.0:
								e["mark"] = 0.08
								_wall_marks.append(_jagged(clamped, clamped + e["dir"].orthogonal() * 6.0, 3, 1.5))
								_rubble.queue_redraw()
						tf["windup"] = {}
					e["tick"] -= delta
					if e["tick"] <= 0.0:
						e["tick"] = PIN_TICK
						if not e.has("hit"):
							e["hit"] = true
							_hurt(hit, e["damage"], Vector2.ZERO, e["owner"])
							_burst(tf["body"].position + Vector2(0, -8), Color("#fff1b0"), Color("#ff6a1a"), 20.0, false, "glass_splash")
						else:
							_hurt(hit, PIN_TICK_DAMAGE, Vector2.ZERO, e["owner"])
					# The beam swings after its target.
					var want: Vector2 = (tf["body"].position + Vector2(0, -6) - e["from"]).normalized()
					var ang: float = e["dir"].angle_to(want)
					e["dir"] = e["dir"].rotated(clampf(ang, -PIN_TURN * delta, PIN_TURN * delta))
				elif hit >= 0 and not e.has("hit"):
					e["hit"] = true
					_hurt(hit, e["damage"], e["dir"] * e.get("push", 1.0), e["owner"])
					if e.get("molten", false):
						_burst(_fighters[hit]["body"].position + Vector2(0, -8), Color("#fff1b0"), Color("#ff6a1a"), 20.0, false, "glass_splash")
					else:
						_burst(_fighters[hit]["body"].position + Vector2(0, -8), Color("#e8fbff"), Color("#5ec8ff"), 20.0, false, "water_burst")
				if e["life"] <= 0.0:
					if e.get("pin", false):
						for pf in _fighters:
							pf["pin_said"] = false
					continue
			"lifted_rock":
				# Kingstone Lift: the rock rises beside its lifter, then flies to the target's spot and
				# comes down on it: broken, everyone round the landing hurt and launched.
				e["t"] += delta
				var r: Dictionary = _rocks[e["rock"]] if e["rock"] < _rocks.size() else {}
				if r.is_empty() or r.get("lift", 0.0) <= 0.0:
					continue
				if e["t"] < LIFT_RISE:
					r["lift"] = maxf(0.01, LIFT_HEIGHT * (e["t"] / LIFT_RISE))
					r["pos"] = e["from"]
					if _fighters[e["target"]]["hp"] > 0:
						e["to"] = _fighters[e["target"]]["body"].position
				elif e["t"] < LIFT_RISE + LIFT_FLIGHT:
					var k: float = (e["t"] - LIFT_RISE) / LIFT_FLIGHT
					r["lift"] = LIFT_HEIGHT * (1.0 - k * k) + 6.0 * (1.0 - k)
					r["pos"] = e["from"].lerp(e["to"], k)
				else:
					r["pos"] = e["to"]
					r["lift"] = 0.0
					var dmgr: int = ROCK_THROW_DAMAGE.get(r["kind"], 10)
					for j in _fighters.size():
						var o: Dictionary = _fighters[j]
						if j != e["owner"] and o["hp"] > 0 and o["body"].position.distance_to(e["to"]) < ROCK_THROW_RADIUS + r["rx"] * 0.5:
							var away: Vector2 = (o["body"].position - e["to"]).normalized() if o["body"].position.distance_to(e["to"]) > 1.0 else Vector2.RIGHT
							_hurt(j, dmgr, away * 1.2, e["owner"])
							_launch(j, 0.4)
					_effects.append({"kind": "impact", "anim": "slam_shock", "pos": e["to"] + Vector2(0, 6), "t": 0.0, "scale": 2.0})
					_show_banner("WHAT A HIT!", 1.0)
					_hit_rock(e["rock"], 999)   # it shatters on landing
					continue
				r["node"].position = (r["pos"] + Vector2(0, -r["lift"])).round()
				r["node"].z_index = int(r["pos"].y)
			"clash":
				# The clash point: pushed by the stronger beam; when it reaches the weaker caster, the
				# stronger beam breaks through and lands.
				e["t"] += delta
				var a: Dictionary = e["a"]
				var b: Dictionary = e["b"]
				if e["t"] > 0.12 or a["life"] <= 0.0 or b["life"] <= 0.0:
					continue
				var strong_beam: Dictionary = a if a["owner"] == e["strong"] else b
				e["pos"] += strong_beam["dir"] * CLASH_PUSH * delta
				a["life"] = maxf(a["life"], 0.1)
				b["life"] = maxf(b["life"], 0.1)
				if _fighters[e["weak"]]["hp"] > 0 and e["pos"].distance_to(_fighters[e["weak"]]["body"].position + Vector2(0, -6)) < 12.0 and not strong_beam.has("hit"):
					strong_beam["hit"] = true
					_hurt(e["weak"], strong_beam["damage"], strong_beam["dir"] * 1.5, e["strong"])
					_label(e["weak"], "Overpowered")
					continue
			"seed":
				if e.get("downed", false):
					continue   # grounded by a downdraft
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
				# The whirlpool hunts: it drifts toward the nearest enemy within reach.
				var hunt := -1
				var hunt_d := RIPTIDE_HUNT
				for j in _fighters.size():
					if _enemies(e["owner"], j) and _fighters[j]["hp"] > 0 and _fighters[j]["body"].position.distance_to(e["pos"]) < hunt_d:
						hunt = j
						hunt_d = _fighters[j]["body"].position.distance_to(e["pos"])
				if hunt >= 0 and hunt_d > 4.0:
					e["pos"] += (_fighters[hunt]["body"].position - e["pos"]).normalized() * RIPTIDE_DRIFT * delta
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
			"still_water":
				e["t"] += delta
				if e["t"] > e["life"]:
					continue
			"trench":
				e["t"] += delta
				if e["t"] > TRENCH_SECONDS:
					_rubble.queue_redraw()
					continue
			"tethers":
				e["t"] += delta
				if e["t"] > 2.0:
					continue
			"sweep":
				# The active moment: the move lands on its target if it is still inside the arc, else whiffs.
				e["t"] += delta
				if e["t"] >= SWEEP_ACTIVE and not e.has("done"):
					e["done"] = true
					var sw: Dictionary = _fighters[e["owner"]]
					if e.get("free", false):
						# A free swing: whoever stands inside the arc is the target, nearest first.
						var best := -1
						var best_d := INF
						for j in _fighters.size():
							var o: Dictionary = _fighters[j]
							var od: Vector2 = o["body"].position - sw["body"].position
							if _enemies(e["owner"], j) and o["hp"] > 0 and o["phase"] <= 0.0 and od.length() <= e["reach"] and od.length() < best_d and absf(od.angle_to(e["dir"])) <= SWEEP_ARC:
								best = j
								best_d = od.length()
						if best >= 0:
							e["target"] = best
					var tg: Dictionary = _fighters[e["target"]]
					var d: Vector2 = tg["body"].position - sw["body"].position
					var inside: bool = tg["hp"] > 0 and sw["hp"] > 0 and d.length() <= e["reach"] and absf(d.angle_to(e["dir"])) <= SWEEP_ARC
					if inside and tg["perched"] >= 0:
						# Out of reach on its perch: the blow lands on the rock under it instead (a part break drops it).
						_label(e["owner"], "Rock")
						_log_ai(e["owner"], "%s hits the rock under %s" % [MOVES[e["m"]]["name"], tg["name"]])
						_hit_rock(tg["perched"], _dmg(e["m"], e["owner"], e["target"]))
						_spend(e["owner"], e["m"])
					elif inside:
						_do_move(e["owner"], e["m"], e["target"])
					else:
						_label(e["owner"], "Whiff")
						_log_ai(e["owner"], "%s whiffs" % MOVES[e["m"]]["name"])
						_effects.append({"kind": "impact", "anim": "light_slash", "pos": sw["body"].position + e["dir"] * (e["reach"] * 0.6) + Vector2(0, -2), "t": 0.0})
						_play("res://assets/audio/sfx/ui/cursor.wav", -16.0)
				if e["t"] > 0.2:
					continue
			"downdraft":
				# Falling air: enemy shots and lobs that pass through it are driven into the ground.
				e["t"] += delta
				if e["t"] > DOWNDRAFT_SECONDS:
					continue
				for o in _effects:
					if o.get("downed", false) or not o["kind"] in ["fireball", "seed"] or not _enemies(e["owner"], o["owner"]):
						continue
					var at: Vector2 = o["pos"] if o["kind"] == "fireball" else o["from"].lerp(o["to"], clampf(o["t"], 0.0, 1.0))
					if at.distance_to(e["pos"]) < DOWNDRAFT_RADIUS:
						o["downed"] = true
						_burst(at, Color("#e8eef4"), Color("#8ea4b8"), 10.0, false, "")
						_effects.append({"kind": "dust", "pos": at, "t": 0.0})
			"shard":
				# A part-break reward lying on the floor: whoever walks over it takes it.
				e["t"] += delta
				if e["t"] > SHARD_LIFE:
					continue
				var taken := false
				for j in _fighters.size():
					var fs: Dictionary = _fighters[j]
					if fs["hp"] > 0 and not fs["hidden"] and fs["body"].position.distance_to(e["pos"]) < 10.0:
						if fs["final"]:
							fs["meter"] = mini(100, fs["meter"] + SHARD_METER)
							_label(j, "Shard +%d" % SHARD_METER)
						else:
							_mend(j, SHARD_HP)
							_label(j, "Shard")
						_burst(e["pos"] + Vector2(0, -6), Color("#f4f0e4"), Color("#8a8276"), 8.0, false, "rock_dust")
						_play("res://assets/audio/sfx/arena/rock_crack.wav", -14.0)
						taken = true
						break
				if taken:
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
							_mend(j, STAR_FIELD_HEAL)
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
						if not _enemies(e["owner"], j) or f["hp"] <= 0 or f["airborne"] > 0.0:
							continue   # terrain only ever hurts the enemy, and never one in the air
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
		_burst(f["body"].position + Vector2(0, -12), Color("#afe8b8"), Color("#206349"), 14.0, false, "jade_burst")
		_play("res://assets/audio/sfx/arena/rock_crack.wav", -8.0)
		_hitstop = maxf(_hitstop, HITSTOP_LIGHT)
		return
	if f["eroded"] > 0.0:
		damage = int(round(damage * ERODE_EXTRA))
		pierce = true   # eroded: its damage reduction is gone
	if f["sunder"] > 0.0:
		damage = int(round(damage * SPEAR_MORE))   # the Spear charm: it takes more from everyone
	if by >= 0 and by != i and _fighters[by]["hp"] > 0:
		var hitter: Dictionary = _fighters[by]
		var lm: String = hitter["last_move"]
		if hitter["passive"] == "ambush" and hitter["ambush"] > 0.0 and damage > 0:
			hitter["ambush"] = 0.0   # the Ambush passive is spent on this hit
		if lm in hitter["abilities"]:
			# An ability landed: the window for a follow-up opens.
			hitter["follow_t"] = FOLLOW_WINDOW
			hitter["follow_m"] = lm
		elif hitter["follow_t"] > 0.0 and lm == hitter["kit"][0]:
			# A basic inside the window: the follow-up. Harder, and some of the ability comes back.
			damage = int(round(damage * FOLLOW_MORE))
			var fm: String = hitter["follow_m"]
			if hitter["cds"].has(fm):
				hitter["cds"][fm] = maxf(0.0, hitter["cds"][fm] - FOLLOW_REFUND)
				if hitter["charge_cds"].has(fm):
					var timers: Array = hitter["charge_cds"][fm]
					var slowest := 0
					for c in timers.size():
						if timers[c] > timers[slowest]:
							slowest = c
					timers[slowest] = maxf(0.0, timers[slowest] - FOLLOW_REFUND)
			hitter["follow_t"] = 0.0
			_label(i, "Follow-up")
			_log_ai(by, "follow-up: %s after %s on %s" % [MOVES[lm]["name"], MOVES[fm]["name"], f["name"]])
			if by == controlled and not auto_you:
				var slot: int = hitter["abilities"].find(fm)
				if _card_flash.has(slot):
					_card_flash[slot] = CARD_FLASH
				_play_pitched("res://assets/audio/sfx/ui/hit_strong.wav", -8.0, 1.3)
	if f["marked"] > 0.0 and by >= 0 and by != i:
		damage = int(round(damage * MARK_BONUS))   # a marked enemy: the team's hits land harder
		if f["signal"] > 0 and _fighters[by]["last_move"] in _fighters[by]["abilities"]:
			damage = int(round(damage * SIGNAL_DOUBLE))   # High Signal: the next ability on it is doubled
			f["signal"] = 0
			_label(i, "Signalled")
	if f["thorns"] > 0.0 and by >= 0 and by != i and not _sig.active and _fighters[by]["hp"] > 0 and _fighters[by]["invuln"] <= 0.0:
		# The Thorns charm: whoever hits it takes a share back.
		var back := maxi(1, int(round(damage * THORNS_BACK)))
		var att: Dictionary = _fighters[by]
		att["hp"] = maxi(0, att["hp"] - back)
		att["flash"] = 0.15
		_label(by, "Thorns")
		if att["hp"] <= 0:
			att["down_at"] = _clock
			_check_winner(f["team"])
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
			if j != i and gfr["team"] == f["team"] and gfr["hp"] > 0 and gfr["passive"] == "windbreak" and gfr["body"].position.distance_to(f["body"].position) < WINDBREAK_RADIUS:
				damage = maxi(1, int(round(damage * WINDBREAK_CUT)))   # Windbreak: the glider's sails take the edge off
				break
	if f["cocoon"] > 0.0:
		# Stone Cocoon: the slabs pulled tight take most of it, and nothing moves it.
		push = Vector2.ZERO
		if not pierce:
			damage = maxi(1, int(round(damage * COCOON_GUARD)))
	if f["ram_t"] > 0.0:
		push = Vector2.ZERO   # unstoppable: a creature mid-ram is not knocked off its line
	if f["brace"] > 0.0:
		# Deep Brace: planted in the current, it takes half, and whoever shoves it is shoved instead.
		if not pierce:
			damage = maxi(1, int(round(damage * BRACE_GUARD)))
		if push.length() > 0.01 and by >= 0 and by != i and _fighters[by]["ram_t"] <= 0.0 and _fighters[by]["hp"] > 0 and _fighters[by]["body"].position.distance_to(f["body"].position) < 48.0:
			var back: Vector2 = (_fighters[by]["body"].position - f["body"].position).normalized() * push.length()
			var floor_rect: Rect2 = _floor()
			var shoved: Vector2 = (_fighters[by]["body"].position + back * 8.0).clamp(floor_rect.position, floor_rect.end)
			if not _blocked(shoved):
				_fighters[by]["body"].position = shoved
			_label(by, "Shoved back")
		push = Vector2.ZERO
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
	if by >= 0 and by != i and not _conducting:
		# Frame data (after Street Fighter): a hit during the target's wind-up is a counter hit,
		# worth more, and a real one breaks the wind-up unless the move is armoured; a hit while
		# the target recovers from its own move is a punish.
		if not f["windup"].is_empty() and not _armoured(i):
			damage = int(round(damage * COUNTER_BONUS))
			_label(i, "Counter")
			_log_ai(by, "counter hit on %s" % f["name"])
			if damage >= COUNTER_BREAK:
				f["cds"][f["windup"]["m"]] = 0.8
				f["windup"] = {}
		elif f["act"] > 0.0 and f["recovering"] != "":
			damage = int(round(damage * PUNISH_BONUS))
			_label(i, "Punish")
		if _fighters[by]["group"] == "damage":
			f["wound"] = WOUND_SECONDS   # role passive (after Overwatch's Damage): mending cut
	f["since_hit"] = 0.0
	if by >= 0 and by != i and not _conducting:
		var combo := _combo_of(_fighters[by]["last_move"], i)
		var top: Vector2 = f["body"].position + Vector2(0, -10)
		match combo:
			"shatter":
				damage = int(round(damage * SHATTER_BONUS))
				f["glassed"] = 0.0
				_label(i, "Shattered")
				_burst(top, Color("#ffe8c0"), Color("#7a4a2a"), 16.0, false, "glass_splash")
			"kindle":
				damage = int(round(damage * KINDLE_BONUS))
				f["rooted"] = 0.0
				_label(i, "Kindled")
				_burst(top, Color("#ffb347"), Color("#ff5a1f"), 14.0, false, "fire_burst")
			"quench":
				damage = int(round(damage * QUENCH_BONUS))
				f["smoulder"] = 0.0
				f["dazzle"] = maxf(f["dazzle"], QUENCH_DAZE)
				_label(i, "Quenched")
				_burst(top, Color("#e8f6ff"), Color("#3a8ad8"), 14.0, false, "steam_puff")
			"overgrow":
				if f["phase"] <= 0.0 and f["invuln"] <= 0.0:
					f["rooted"] = maxf(f["rooted"], OVERGROW_ROOT)
				_label(i, "Overgrown")
				_effects.append({"kind": "impact", "anim": "root_burst", "pos": f["body"].position + Vector2(0, -4), "t": 0.0})
			"conduct":
				_label(i, "Conducted")
				_conducting = true
				for j in _fighters.size():
					if j != i and _enemies(by, j) and _fighters[j]["hp"] > 0 and _in_riptide(j):
						_effects.append({"kind": "bolt", "pts": _jagged(top, _fighters[j]["body"].position + Vector2(0, -10), 7, 5.0), "t": 0.0, "big": false})
						_effects.append({"kind": "impact", "anim": "spark_bolt", "pos": _fighters[j]["body"].position + Vector2(0, 2), "t": 0.0})
						_hurt(j, maxi(1, int(round(damage * CONDUCT_SHARE))), Vector2.ZERO, by)
				_conducting = false
		if combo != "":
			_log_ai(by if by >= 0 else i, "%s on %s" % [combo, f["name"]])
	var was_up: bool = f["hp"] > 0
	f["hp"] = maxi(0, f["hp"] - damage)
	f["flash"] = 0.3
	if by >= 0 and by != i and "jab" in _fighters[by]["kit"]:
		_chain_hit(by)
	_hitstop = maxf(_hitstop, HITSTOP_HEAVY if damage >= 20 else HITSTOP_LIGHT)
	if by == controlled and not auto_you and by != i and damage >= YOUR_HEAVY and _fighters[by]["last_move"] in _fighters[by]["abilities"]:
		# A heavy ability of yours landing: a touch more hitstop and a camera nudge, so you feel it.
		_hitstop += YOUR_HITSTOP_EXTRA
		_cam_punch(f["body"].position + Vector2(0, -8), 1.06, 0.18)
		_shake_by(1.5)
	f["shiver"] = push.normalized() if push.length() > 0.01 else Vector2.RIGHT
	_anim(i, "flinch", 0.2, f["shiver"])
	if damage >= HITSTUN_FROM and f["windup"].is_empty() and f["hp"] > 0:
		# Hitstun: the one hit cannot act for a moment, so a fast move is plus on hit and a slow one minus.
		f["act"] = maxf(f["act"], HITSTUN)
		f["recovering"] = ""
	if f["final"]:
		f["meter"] = mini(100, f["meter"] + METER_TAKEN)
	if by >= 0 and by != i:
		if _fighters[by]["final"]:
			# Role passive (after Overwatch's Tank): hits on a tank charge the attacker less.
			_fighters[by]["meter"] = mini(100, _fighters[by]["meter"] + int(round(METER_DEALT * (TANK_METER_GIVEN if f["group"] == "tank" else 1.0))))
	# Knockback grows as the target gets hurt (after Smash): the same hit sends a creature at a
	# quarter of its HP nearly half again as far, so slams and carries come as fights go on.
	push *= 1.0 + KNOCKBACK_GROWTH * (1.0 - float(f["hp"]) / f["max_hp"])
	if f["group"] == "tank":
		push *= TANK_KNOCKBACK   # role passive: tanks are moved less
	if push.length() >= CARRY_FROM:
		_carry(i, push, by)
	else:
		var floor_rect: Rect2 = _floor()
		var pushed: Vector2 = (f["body"].position + push * 8.0).clamp(floor_rect.position, floor_rect.end)
		if not _blocked(pushed):
			f["body"].position = pushed
	_shake_by(SHAKE_HIT)
	_cheer = maxf(_cheer, 0.6)
	if damage >= BANNER_HIT and f["hp"] > 0 and _banner_t <= 0.0:
		_show_banner("WHAT A HIT!", 1.2)
	_play("res://assets/audio/sfx/ui/hit_strong.wav" if damage >= 20 else "res://assets/audio/sfx/ui/hit.wav", -6.0)
	if f["hp"] <= 0:
		f["down_at"] = _clock
		_check_winner(1 - f["team"])
		_cheer = 3.0
		_play("res://assets/audio/sfx/ui/faint.wav", -4.0)
		if was_up and by >= 0 and by != i and _fighters[by]["group"] == "damage" and _fighters[by]["hp"] > 0:
			# Role passive (after Overwatch's Damage): a KO puts a spring in the killer's step.
			_fighters[by]["haste"] = maxf(_fighters[by]["haste"], KO_HASTE)
			_label(by, "Haste")
		if was_up:
			# The KO beat: the fight hangs for a moment, a white ring, and the creature drops.
			_hitstop = maxf(_hitstop, KO_HITSTOP)
			_label(i, "KO")
			_cam_punch(f["body"].position + Vector2(0, -8), 1.3, 0.5)
			_show_banner("KNOCKOUT!", 1.6)
			var lines := []
			for k in 10:
				lines.append(randf() * TAU)
			_effects.append({"kind": "ring", "pos": f["body"].position, "size": 30.0, "t": 0.0, "lines": lines, "rim": Color("#ffffff")})
			_anim(i, "ko", 0.5, f["shiver"])
			_shake_by(5.0)


func _play(path: String, db: float) -> void:
	_play_pitched(path, db, 1.0)


func _play_pitched(path: String, db: float, pitch: float) -> void:
	for p in _sounds:
		if not p.playing:
			p.stream = load(path)
			p.volume_db = db
			p.pitch_scale = pitch
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
	if team_size > 1:
		# The Crest: the centre circle lit in the holder's colour, white when contested or empty.
		var cc: Vector2 = _floor().get_center()
		var ccol: Color = (TEAM_RING[0] if _crest_team == 0 else Color("#ff4a3a")) if _crest_team >= 0 else Color(1, 1, 1, 0.35)
		_fx.draw_set_transform(cc.round(), 0.0, Vector2(1.0, 0.55))
		_fx.draw_arc(Vector2.ZERO, CREST_RADIUS + 1.0 + sin(_crowd_t * 3.0), 0, TAU, 40, Color(ccol, 0.8), 1.5)
		_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for w in _walls:
		_draw_root_pillar(w)
	for e in _effects:
		if e["kind"] == "snare" and _fighters[e["who"]]["hp"] > 0:
			var at: Vector2 = _fighters[e["who"]]["body"].position
			var k: float = clampf(e["t"] / 0.15, 0.0, 1.0)
			_draw_sheet(_fx, "root_snare", at + Vector2(0, 8), e["t"], true, IMPACT_SECONDS, Color(1, 1, 1, 0.9 * k), 10.0, 1.2)
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
		# Painted statuses (VFX pass 2): molten glass on the Glassed, smoulder on the smouldering,
		# the stone cocoon, still rings round a braced listener.
		if f["glassed"] > 0.0:
			_draw_sheet(_fx, "molten_drip", f["body"].position + Vector2(0, -6), _crowd_t + f["body"].position.x * 0.01, true, IMPACT_SECONDS, Color(1, 1, 1, 0.85), 10.0, 0.8)
		if f["smoulder"] > 0.0:
			_draw_sheet(_fx, "smoulder", f["body"].position + Vector2(0, -10), _crowd_t + f["body"].position.y * 0.01, true, IMPACT_SECONDS, Color(1, 1, 1, 0.85), 12.0, 0.8)
		if f["cocoon"] > 0.0:
			_draw_sheet(_fx, "cocoon_stone", f["body"].position + Vector2(0, 8), _crowd_t, true, IMPACT_SECONDS, Color(1, 1, 1, 0.95), 8.0, 1.4)
		if f["brace"] > 0.0:
			_draw_sheet(_fx, "sonar_ring", f["body"].position + Vector2(0, 8), _crowd_t, true, IMPACT_SECONDS, Color(1, 1, 1, 0.5), 6.0, 1.4)
		if f["aegis"] > 0.0:
			# The Aegis charm: a gold shell, turning.
			_fx.draw_set_transform(f["body"].position.round() + Vector2(0, -10), _crowd_t * 2.0, Vector2(1.0, 1.2))
			_fx.draw_arc(Vector2.ZERO, 16.0, 0, TAU, 24, Color(1.0, 0.85, 0.3, 0.9), 2.0)
			_fx.draw_arc(Vector2.ZERO, 12.0, 0, TAU, 20, Color(1.0, 0.95, 0.7, 0.5), 1.0)
			_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		if f["thorns"] > 0.0:
			_draw_sheet(_fx, "root_snare", f["body"].position + Vector2(0, 8), _crowd_t, true, IMPACT_SECONDS, Color(1, 1, 1, 0.7), 8.0, 1.0)
		if f["sunder"] > 0.0:
			var sp: Vector2 = f["body"].position.round() + Vector2(0, -30 - 4 * f["stage"])
			_fx.draw_colored_polygon(PackedVector2Array([sp + Vector2(-4, -6), sp + Vector2(4, -6), sp]), Color(1.0, 0.35, 0.3, 0.9))
	_draw_player_reach()
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
				var tint: Color = e.get("tint", Color(0.35, 0.75, 1.0))
				_fx.draw_texture(tex, (e["pos"] - tex.get_size() * 0.5).round(), Color(tint, 0.3 * (1.0 - k)))
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
			"tethers":
				# High Signal's tethers: dotted ivory lines from the spotter to every marked enemy.
				var so: Dictionary = _fighters[e["owner"]]
				var ka: float = clampf((2.0 - e["t"]) / 0.5, 0.0, 1.0)
				for j in _fighters.size():
					var o: Dictionary = _fighters[j]
					if o["hp"] <= 0 or not _enemies(e["owner"], j) or o["marked"] <= 0.0:
						continue
					var a: Vector2 = so["body"].position + Vector2(0, -14)
					var b: Vector2 = o["body"].position + Vector2(0, -12)
					var n: int = maxi(2, int(a.distance_to(b) / 6.0))
					for k in n:
						if (k + int(_crowd_t * 12.0)) % 2 == 0:
							_fx.draw_rect(Rect2(a.lerp(b, float(k) / n).round(), Vector2(2, 2)), Color(0.91, 0.89, 0.81, 0.9 * ka))
			"sweep":
				# The arc the move will cover, bright at the active moment.
				var sw: Dictionary = _fighters[e["owner"]]
				var ks: float = clampf(1.0 - absf(e["t"] - SWEEP_ACTIVE) / 0.08, 0.0, 1.0)
				var c: Vector2 = sw["body"].position.round() + Vector2(0, 2)
				_fx.draw_set_transform(c, e["dir"].angle(), Vector2(1.0, 0.55))
				_fx.draw_arc(Vector2.ZERO, e["reach"], -SWEEP_ARC, SWEEP_ARC, 16, Color(1, 1, 0.9, 0.35 + 0.55 * ks), 1.5)
				_fx.draw_line(Vector2.ZERO, Vector2.RIGHT.rotated(-SWEEP_ARC) * e["reach"], Color(1, 1, 0.9, 0.2 + 0.3 * ks), 1.0)
				_fx.draw_line(Vector2.ZERO, Vector2.RIGHT.rotated(SWEEP_ARC) * e["reach"], Color(1, 1, 0.9, 0.2 + 0.3 * ks), 1.0)
				_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"lifted_rock":
				# The shadow stays on the floor while the rock is up (the reference's lift).
				if e["rock"] < _rocks.size():
					var r: Dictionary = _rocks[e["rock"]]
					if r.get("lift", 0.0) > 0.0:
						_fx.draw_set_transform(r["pos"].round() + Vector2(3, 1), 0.0, Vector2(1.0, 0.42))
						_fx.draw_circle(Vector2.ZERO, r["rx"] * 1.1, Color(0, 0, 0, 0.3 * clampf(1.0 - r["lift"] / 60.0, 0.3, 1.0)))
						_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
						_fx.draw_arc(r["pos"].round() + Vector2(0, -r["lift"] - r["h"] * 0.4), r["rx"] + 4.0 + sin(_crowd_t * 12.0) * 2.0, 0, TAU, 28, Color(0.49, 0.96, 0.72, 0.7), 1.0)
			"clash":
				# The clash point: a white core, two rings, sparks thrown both ways, steam up.
				var pc: Vector2 = e["pos"].round()
				_fx.draw_circle(pc, 9.0 + sin(_crowd_t * 30.0) * 2.0, Color(1, 1, 1, 0.9))
				_fx.draw_arc(pc, 15.0, 0, TAU, 24, Color(1.0, 0.9, 0.5, 0.9), 2.0)
				_fx.draw_arc(pc, 22.0 + fmod(_crowd_t * 40.0, 10.0), 0, TAU, 24, Color(1.0, 0.95, 0.8, 0.5), 1.0)
				for k in 10:
					var a: float = _crowd_t * 7.0 + k * TAU / 10.0
					var pr: float = 12.0 + fmod(k * 3.7 + _crowd_t * 60.0, 16.0)
					_fx.draw_rect(Rect2((pc + Vector2(cos(a), sin(a) * 0.6) * pr).round(), Vector2(2, 2)), Color(1.0, 0.95, 0.7, 0.9))
				for k in 3:
					_fx.draw_circle(pc + Vector2(randf_range(-4, 4), -14.0 - k * 8.0 - fmod(_crowd_t * 30.0, 8.0)), 4.0 + k * 1.5, Color(1, 1, 1, 0.25))
			"downdraft":
				# Falling air: a pale column seen from above, dashes streaming down into a flattened ring.
				var kd: float = minf(1.0, e["t"] * 4.0) * clampf((DOWNDRAFT_SECONDS - e["t"]) / 0.6, 0.0, 1.0)
				_draw_zone(_fx, "downdraft_column", e["pos"], e["t"], DOWNDRAFT_RADIUS, Color(1, 1, 1, 0.9 * kd), 12.0)
				_fx.draw_set_transform(e["pos"].round(), 0.0, Vector2(1.0, 0.5))
				_fx.draw_circle(Vector2.ZERO, DOWNDRAFT_RADIUS, Color(0.85, 0.9, 0.95, 0.12 * kd))
				_fx.draw_arc(Vector2.ZERO, DOWNDRAFT_RADIUS, 0, TAU, 40, Color(0.85, 0.9, 0.95, 0.6 * kd), 1.0)
				_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
				for q in 10:
					var a: float = q * TAU / 10.0 + e["t"] * 0.4
					var rr: float = DOWNDRAFT_RADIUS * (0.3 + 0.6 * fmod(q * 0.37, 1.0))
					var base: Vector2 = e["pos"] + Vector2(cos(a) * rr, sin(a) * rr * 0.5)
					var fall: float = fmod(e["t"] * 2.0 + q * 0.17, 1.0)
					var top: Vector2 = base + Vector2(0, -22.0 + 22.0 * fall)
					_fx.draw_line(top.round(), (top + Vector2(0, 5)).round(), Color(0.9, 0.94, 1.0, 0.7 * kd * (1.0 - fall)), 1.0)
			"still_water":
				# Still water: a dark calm disc where the current has stopped, with slow rings that
				# never quite reach its edge; it fades in its last second.
				var ka: float = minf(1.0, e["t"] * 3.0) * clampf((e["life"] - e["t"]) / 1.0, 0.0, 1.0)
				_draw_zone(_fx, "still_water", e["pos"], e["t"], e["r"], Color(1, 1, 1, 0.8 * ka), 6.0)
				_fx.draw_set_transform(e["pos"].round(), 0.0, Vector2(1.0, 0.5))
				_fx.draw_circle(Vector2.ZERO, e["r"], Color(0.08, 0.3, 0.3, 0.35 * ka))
				_fx.draw_arc(Vector2.ZERO, e["r"], 0, TAU, 40, Color(0.62, 0.9, 0.88, 0.5 * ka), 1.0)
				for q in 3:
					var kr: float = fmod(e["t"] * 0.25 + q / 3.0, 1.0)
					_fx.draw_arc(Vector2.ZERO, e["r"] * kr, 0, TAU, 32, Color(0.62, 0.9, 0.88, 0.35 * ka * (1.0 - kr)), 1.0)
				_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"shard":
				# A break reward: a grey shard glinting on the floor, bobbing, blinking before it goes.
				var bob: float = sin(e["t"] * 6.0) * 1.5
				var a: float = 1.0 if e["t"] < SHARD_LIFE - 1.5 else (0.3 + 0.7 * float(int(e["t"] * 8.0) % 2))
				var p: Vector2 = e["pos"].round()
				_fx.draw_set_transform(p, 0.0, Vector2(1.0, 0.4))
				_fx.draw_circle(Vector2.ZERO, 5.0, Color(0, 0, 0, 0.25))
				_fx.draw_set_transform(p + Vector2(0, -4 + bob), 0.6 + e["t"] * 0.5, Vector2.ONE)
				_draw_shard(_fx, PackedVector2Array([Vector2(-3, 1), Vector2(0, -4), Vector2(3, 1), Vector2(1, 3), Vector2(-2, 3)]), Color(ROCK_SHADES[0], a))
				_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
				_fx.draw_rect(Rect2(p + Vector2(1, -8 + bob), Vector2(1, 1)), Color(1, 1, 1, a * (0.5 + 0.5 * sin(e["t"] * 10.0))))
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
				if e.get("dart", false):
					# A whistling dart: a thin ivory sliver along its path with a short grey trail.
					var dd: Vector2 = e["vel"].normalized()
					for k in range(0, e["trail"].size(), 2):
						_fx.draw_circle(e["trail"][k].round(), 1.0, Color(0.8, 0.82, 0.85, 0.3))
					_fx.draw_set_transform(e["pos"].round(), dd.angle(), Vector2.ONE)
					_fx.draw_colored_polygon(PackedVector2Array([Vector2(7, 0), Vector2(-5, -2), Vector2(-6, 0), Vector2(-5, 2)]), Color("#e8e2cf"))
					_fx.draw_line(Vector2(-6, 0), Vector2(-10, 0), Color(0.55, 0.6, 0.68, 0.8), 1.0)
					_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
				elif e.get("jade", false):
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
					var steps := maxi(1, int(e["len"] / 4.0) + 1)   # never fewer than two points (the sim log filled with polyline errors)
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
				elif _impact_frames.has("seed_pod"):
					_draw_sheet(_fx, "seed_pod", p + Vector2(0, 8), t, true, IMPACT_SECONDS, Color.WHITE, 24.0, 0.7)
				else:
					_fx.draw_circle(p.round(), 5.0, Color("#5a3f22"))
					_fx.draw_circle(p.round(), 4.0, Color("#8a6a3a"))
					_fx.draw_rect(Rect2((p - Vector2(1, 9)).round(), Vector2(3, 5)), Color("#8fd16a"))
			"impact":
				# Played once, quickly, fading over its last quarter; bottom-centred on the hit.
				var frames: Array = _impact_frames.get(e["anim"], [])
				if frames.is_empty():
					continue
				var k: float = e["t"] / IMPACT_SECONDS
				var tex: Texture2D = frames[mini(frames.size() - 1, int(k * frames.size()))]
				var sc: float = e.get("scale", 1.0)
				var size: Vector2 = tex.get_size() * sc
				_fx.draw_texture_rect(tex, Rect2((e["pos"] - Vector2(size.x * 0.5, size.y * 0.75)).round(), size.round()), false, Color(1, 1, 1, clampf((1.0 - k) / 0.25, 0.0, 1.0)))
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
				_draw_sheet(_fx, "slab_vortex", c + Vector2(0, 18), e["t"], true, IMPACT_SECONDS, Color(1, 1, 1, 1.0 - k * 0.5), 16.0, 1.4)
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
	_draw_cursor()
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
## The shape a wind-up of yours will take, for the drawing and the checks: kind "wedge" (a
## melee arc along `dir`), "line" (to `at`), "spot" (a landing spot at `at`), "charge" (a run
## along `dir`); `r` is the reach.
func _telegraph_shape(i: int) -> Dictionary:
	var f: Dictionary = _fighters[i]
	var w: Dictionary = f["windup"]
	if w.is_empty():
		return {}
	var me: Vector2 = f["body"].position
	var t: int = w["target"]
	var at: Vector2 = w.get("at", _fighters[t]["body"].position if t >= 0 else me)
	var dir: Vector2 = w.get("aim", Vector2.ZERO)
	if dir.length() < 0.01:
		dir = (at - me).normalized() if at.distance_to(me) > 0.5 else _facing_vector(f["facing"])
	var r: float = MOVES[w["m"]]["range"] + SWEEP_REACH_EXTRA
	match w["kind"]:
		"melee":
			return {"kind": "wedge", "at": me, "dir": dir, "r": r + (VANTAGE_RANGE if f["perched"] >= 0 else 0.0)}
		"area":
			return {"kind": "spot", "at": at, "dir": dir, "r": AREA_SPOT}
		"charge":
			return {"kind": "charge", "at": me + dir * RAM_SPEED * RAM_SECONDS, "dir": dir, "r": RAM_SPEED * RAM_SECONDS}
		_:
			return {"kind": "line", "at": at if w.get("free", false) or t < 0 else _fighters[t]["body"].position, "dir": dir, "r": r}


## A filled wedge on the floor: the arc a melee move covers, squashed like the rings.
func _wedge(at: Vector2, dir: Vector2, r: float, half: float, col: Color, fill_a: float, line_a: float) -> void:
	var pts := PackedVector2Array([Vector2.ZERO])
	for k in 13:
		pts.append(Vector2.RIGHT.rotated(dir.angle() - half + 2.0 * half * k / 12.0) * r)
	_fx.draw_set_transform(at.round() + Vector2(0, 2), 0.0, Vector2(1.0, 0.55))
	_fx.draw_colored_polygon(pts, Color(col, fill_a))
	pts.append(Vector2.ZERO)
	_fx.draw_polyline(pts, Color(col, line_a), 1.0)
	_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Your reach on the floor (item 4): a faint ring at the basic's reach under the creature you
## steer; with the mouse live, a ghost of the basic's shape toward the cursor so you see what a
## press will do; and, after an out-of-range refusal, the reach of that ability for a moment.
func _draw_player_reach() -> void:
	if _fighters.is_empty() or auto_you or _winner >= 0:
		return
	var f: Dictionary = _fighters[controlled]
	if f["hp"] <= 0:
		return
	var accent: Color = LINES[f["line"]]["accent"].lightened(0.3)
	var m: String = f["kit"][0]
	var reach: float = MOVES[m]["range"] + SWEEP_REACH_EXTRA + (VANTAGE_RANGE if f["perched"] >= 0 else 0.0)
	var me: Vector2 = f["body"].position
	var live: bool = _mouse_live > 0.0
	_fx.draw_set_transform(me.round() + Vector2(0, 2), 0.0, Vector2(1.0, 0.55))
	if f["follow_t"] > 0.0:
		# The follow-up window: the ring goes gold and shrinks with the time left.
		var kf: float = f["follow_t"] / FOLLOW_WINDOW
		_fx.draw_arc(Vector2.ZERO, reach, 0, TAU, 40, Color(1.0, 0.85, 0.3, 0.95), 2.0)
		_fx.draw_arc(Vector2.ZERO, reach, -PI * 0.5, -PI * 0.5 + TAU * kf, 40, Color(1.0, 0.95, 0.7, 0.9), 1.0)
	else:
		_fx.draw_arc(Vector2.ZERO, reach, 0, TAU, 40, Color(accent, 0.4 if live else 0.22), 1.0)
	_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if _range_hint["t"] > 0.0:
		var kh: float = _range_hint["t"] / RANGE_HINT_SECONDS
		_fx.draw_set_transform(me.round() + Vector2(0, 2), 0.0, Vector2(1.0, 0.55))
		_fx.draw_arc(Vector2.ZERO, _range_hint["r"], 0, TAU, 48, Color(1.0, 0.45, 0.35, 0.9 * kh), 1.0)
		_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if not live or not f["windup"].is_empty():
		return
	# The ghost: what the basic will do if you press now, toward the cursor.
	var to_c: Vector2 = _mouse_world() - me
	var dir: Vector2 = to_c.normalized() if to_c.length() > 2.0 else _facing_vector(f["facing"])
	var kind: String = TELEGRAPH[m][0] if TELEGRAPH.has(m) else "line"
	match kind:
		"melee":
			_wedge(me, dir, reach, SWEEP_ARC, accent, 0.1, 0.45)
		"area":
			var spot: Vector2 = me + to_c.limit_length(MOVES[m]["range"])
			_fx.draw_set_transform(spot.round(), 0.0, Vector2(1.0, 0.45))
			_fx.draw_arc(Vector2.ZERO, AREA_SPOT, 0, TAU, 24, Color(accent, 0.5), 1.0)
			_fx.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		_:
			var end: Vector2 = me + dir * reach
			var side: Vector2 = dir.orthogonal() * 3.0
			var box := PackedVector2Array([(me + side).round(), (end + side).round(), (end - side).round(), (me - side).round()])
			_fx.draw_colored_polygon(box, Color(accent, 0.08))
			box.append(box[0])
			_fx.draw_polyline(box, Color(accent, 0.4), 1.0)


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
	if i == controlled and not auto_you:
		# Yours: your line's colour, and the shape it will really take (a wedge along your aim,
		# a spot where the lob lands, a line to the cursor), filling as the wind-up runs.
		var s := _telegraph_shape(i)
		var mine: Color = LINES[f["line"]]["accent"].lightened(0.3)
		match s["kind"]:
			"wedge":
				_wedge(me, s["dir"], s["r"], SWEEP_ARC, mine, 0.12 + 0.25 * k, 0.9 * blink)
			"spot":
				_ring(s["at"], s["r"], mine, k, blink)
			_:
				var side: Vector2 = s["dir"].orthogonal() * (3.0 if s["kind"] == "line" else 8.0)
				var end: Vector2 = s["at"]
				var box := PackedVector2Array([(me + side).round(), (end + side).round(), (end - side).round(), (me - side).round()])
				_fx.draw_colored_polygon(box, Color(mine, 0.12 + 0.2 * k))
				box.append(box[0])
				_fx.draw_polyline(box, Color(mine, 0.9 * blink), 1.0)
		return
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
## The cursor on the floor while the mouse is the aim: a small reticle, brighter while the
## attack button is held.
func _draw_cursor() -> void:
	if _fighters.is_empty() or auto_you or _mouse_live <= 0.0 or _winner >= 0:
		return
	var c: Vector2 = _mouse_world().round()
	var col := Color(1, 1, 1, 0.9 if _attack_held else 0.55)
	_fx.draw_arc(c, 4.0, 0, TAU, 12, col, 1.0)
	for d in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]:
		_fx.draw_line(c + d * 6.0, c + d * 9.0, col, 1.0)


func _draw_target_marker() -> void:
	if _fighters.is_empty() or _fighters[controlled]["hp"] <= 0:
		return
	var tg: int = _fighters[controlled]["target"]
	if tg < 0 or _fighters[tg]["hp"] <= 0:
		return
	var chosen: bool = player_target == tg
	var col := Color("#ff4a3a") if chosen else Color(1, 1, 1, 0.7)
	var p: Vector2 = _fighters[tg]["body"].position
	if chosen:
		# A locked enemy wears a bracket: four corners round its body.
		var hw: float = 12.0 + 3.0 * _fighters[tg]["stage"]
		var top_y: float = -28.0 - 5.0 * _fighters[tg]["stage"]
		var bot_y: float = 6.0
		for sx in [-1.0, 1.0]:
			for sy in [0, 1]:
				var cx: Vector2 = (p + Vector2(sx * hw, top_y if sy == 0 else bot_y)).round()
				_fx.draw_line(cx, cx + Vector2(-sx * 5.0, 0), col, 1.0)
				_fx.draw_line(cx, cx + Vector2(0, (5.0 if sy == 0 else -5.0)), col, 1.0)
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
			"trench":
				# The tunnel's scar: a dark torn line with broken edges, water-dark for the Tide line,
				# earth-dark for the rest, fading in its last second.
				var kt: float = clampf((TRENCH_SECONDS - e["t"]) / 1.0, 0.0, 1.0) * clampf(e["t"] / 0.2, 0.0, 1.0)
				var a: Vector2 = e["from"]
				var b: Vector2 = e["to"]
				var dark := Color(0.05, 0.12, 0.2, 0.75 * kt) if e["water"] else Color(0.14, 0.09, 0.05, 0.8 * kt)
				var edge := Color(0.3, 0.55, 0.75, 0.6 * kt) if e["water"] else Color(0.45, 0.33, 0.2, 0.7 * kt)
				on.draw_line(a.round(), b.round(), dark, TRENCH_WIDTH * 1.6)
				on.draw_line(a.round(), b.round(), edge, 1.0)
				var n: int = maxi(2, int(a.distance_to(b) / 7.0))
				for k in n:
					var p: Vector2 = a.lerp(b, (k + 0.5) / n)
					var side: Vector2 = (b - a).normalized().orthogonal() * (TRENCH_WIDTH * (0.9 if k % 2 == 0 else -0.9))
					on.draw_rect(Rect2((p + side).round(), Vector2(2, 2)), edge)
			"scorch":
				on.draw_set_transform(e["pos"].round(), 0.0, Vector2(1.0, 0.6))
				on.draw_circle(Vector2.ZERO, e["size"], Color(0.12, 0.08, 0.05, 0.3 * clampf(1.0 - (e["t"] - 2.0) / 2.0, 0.0, 1.0)))
				on.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"riptide":
				var k: float = clampf(e["t"] / 0.3, 0.0, 1.0) * clampf((RIPTIDE_SECONDS - e["t"]) / 0.4, 0.0, 1.0)
				_draw_zone(on, "riptide_whirl", e["pos"], e["t"], RIPTIDE_RADIUS * 1.3, Color(1, 1, 1, k))
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
				_draw_sheet(on, "ember_patch", e["pos"] + Vector2(0, 5), e["t"] + e["pos"].x * 0.01, true, IMPACT_SECONDS, Color(1, 1, 1, 1.0 - k), 12.0, 0.6)
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
				on.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
				_draw_zone(on, "glass_pool", e["pos"], e["t"], pr * 1.1, Color(1, 1, 1, (1.0 - kp * 0.7) * fade), 8.0)
				on.draw_set_transform(e["pos"].round(), 0.0, Vector2(1.0, 0.5))
				on.draw_circle(Vector2(-4, -3) * pr / 18.0, pr * 0.45, Color(1.0, 0.95, 0.75).lerp(Color(0.6, 0.5, 0.45), kp) * Color(1, 1, 1, 0.7 * fade))
				on.draw_arc(Vector2.ZERO, pr, 0, TAU, 28, Color(0.5, 0.2, 0.05, 0.9 * fade), 1.0)
				if kp < 0.5 and int(e["t"] * 8.0) % 2 == 0:
					on.draw_circle(Vector2(5, 2) * pr / 18.0, 2.0, Color(1.0, 0.95, 0.7, (0.5 - kp) * 2.0 * fade))
				on.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"star_field":
				# Starshield's star field: a soft pink five-point star on the floor, turning slowly,
				# where allies mend.
				var kf: float = clampf(e["t"] / 0.3, 0.0, 1.0) * clampf((STAR_FIELD_SECONDS - e["t"]) / 0.6, 0.0, 1.0)
				_draw_zone(on, "star_field", e["pos"], e["t"], STAR_FIELD_RADIUS * kf, Color(1, 1, 1, 0.8 * kf), 8.0)
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
func _draw_sheet(on: CanvasItem, anim: String, at: Vector2, t: float, loop: bool, seconds: float = IMPACT_SECONDS, tint: Color = Color.WHITE, fps: float = 14.0, scale: float = 1.0) -> void:
	var frames: Array = _impact_frames.get(anim, [])
	if frames.is_empty():
		return
	var idx: int = int(t * fps) % frames.size() if loop else mini(frames.size() - 1, int(clampf(t / seconds, 0.0, 0.999) * frames.size()))
	var tex: Texture2D = frames[idx]
	if scale == 1.0:
		on.draw_texture(tex, (at - Vector2(tex.get_width() * 0.5, tex.get_height() * 0.75)).round(), tint)
	else:
		var size: Vector2 = tex.get_size() * scale
		on.draw_texture_rect(tex, Rect2((at - Vector2(size.x * 0.5, size.y * 0.75)).round(), size.round()), false, tint)


## A painted zone: one looping frame centred on a floor point, scaled so the sheet covers
## the zone's radius (the sheets are 48 px across), flattened a little by the camera angle.
func _draw_zone(on: CanvasItem, anim: String, centre: Vector2, t: float, radius: float, tint: Color = Color.WHITE, fps: float = 10.0) -> void:
	var frames: Array = _impact_frames.get(anim, [])
	if frames.is_empty():
		return
	var tex: Texture2D = frames[int(t * fps) % frames.size()]
	var size := Vector2(radius * 2.0, radius * 2.0 * 0.6)
	on.draw_texture_rect(tex, Rect2((centre - size * 0.5).round(), size.round()), false, tint)


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
	if f.get("shield_anim", "star_shield") == "sail_cover":
		# A sail draped over the ally: the painted sheet alone.
		_draw_sheet(_fx, "sail_cover", f["body"].position + Vector2(0, 10), _crowd_t, true, IMPACT_SECONDS, Color(1, 1, 1, 0.9), 10.0, 1.4)
		return
	_draw_sheet(_fx, "star_shield", f["body"].position + Vector2(0, 8), _crowd_t, true, IMPACT_SECONDS, Color(1, 1, 1, 0.8), 10.0, 1.3)
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
	if _banner_t > 0.0:
		# The crowd's cutaway: a dark strip over the stands with the line in gold, sliding in and out.
		var kb: float = clampf(minf(_banner_t / 0.2, (2.0 - _banner_t) / 0.2), 0.0, 1.0) if _banner_t < 2.0 else 1.0
		var y: float = 48.0 - 30.0 * (1.0 - kb)
		_hud.draw_rect(Rect2(0, y, 1152, 44), Color(0, 0, 0, 0.7 * kb))
		_hud.draw_string(_font, Vector2(0, y + 32), _banner, HORIZONTAL_ALIGNMENT_CENTER, 1152, 26, Color(1.0, 0.85, 0.3, kb))
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
	if team_size > 1:
		var left_s: int = maxi(0, int(ceil(MATCH_SECONDS - _clock)))
		_hud.draw_string(_font, Vector2(576 - 30, 40), "%d:%02d" % [left_s / 60, left_s % 60], HORIZONTAL_ALIGNMENT_CENTER, 60, 16, Color("#F0F4F8") if left_s > 15 else Color("#ff4a3a"))
		if _on_points and _winner >= 0:
			_hud.draw_string(_font, Vector2(576 - 120, 64), ("YOUR TEAM" if _winner == 0 else "THE RIVALS") + " WIN ON POINTS", HORIZONTAL_ALIGNMENT_CENTER, 240, 14, Color("#ffe066"))
	if show_ai_log:
		# Kit Sense's log: the last eight decisions, newest at the bottom.
		var n: int = mini(8, ai_log.size())
		_hud.draw_rect(Rect2(8, 40, 520, 14 * n + 10), Color(0.05, 0.06, 0.08, 0.8))
		for k in n:
			_hud.draw_string(_font, Vector2(14, 54 + k * 14), ai_log[ai_log.size() - n + k], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#F0F4F8"))
	_draw_ability_bar()
	if story_mode:
		_hud.draw_string(_font, Vector2(16, 24), "MOVE WASD   AIM MOUSE   ATTACK J / CLICK   DASH SPACE   ABILITIES 1 2 3   CHARM C   LOCK RIGHT CLICK   TAB AUTO", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1, 1, 1, 0.75))
	else:
		_hud.draw_string(_font, Vector2(16, 24), "MOVE WASD   AIM MOUSE   ATTACK J / CLICK   DASH SPACE   ABILITIES 1 2 3   ULTIMATE 4   CHARM C   LOCK RIGHT CLICK / Q/E  TAB AUTO   STAGE F   RIVAL T   RIVAL STAGE G   TEAM SIZE N   ROCKS B   SHAKE V   ARENA M   REMATCH R   ESC MENU", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1, 1, 1, 0.75))
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
		if _card_shake[slot] > 0.0:
			box.position.x += round(sin(_card_shake[slot] * 70.0) * 3.0)   # a failed press: the card shakes
		_hud.draw_rect(box, Color(0.07, 0.09, 0.11, 0.85))
		_hud.draw_rect(Rect2(box.position + Vector2(0, box.size.y * (1.0 - fill)), Vector2(box.size.x, box.size.y * fill)), Color(accent, 0.35 if not ready else 0.6))
		if _card_flash[slot] > 0.0:
			_hud.draw_rect(box, Color(1, 1, 1, 0.7 * _card_flash[slot] / CARD_FLASH))   # a good press: the card lights
		_hud.draw_rect(box, (accent.lightened(0.4) if int(_crowd_t * 8) % 2 == 0 else accent) if ready else (Color(1, 0.5, 0.4) if _card_shake[slot] > 0.0 else Color("#75604D")), false, 2.0)
		_hud.draw_string(_font, box.position + Vector2(5, 14), str(slot + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#F0F4F8"))
		_hud.draw_string(_font, box.position + Vector2(0, 44), name.left(8), HORIZONTAL_ALIGNMENT_CENTER, 60, 7, Color(1, 1, 1, 0.9 if ready else 0.5))
		for c in pips.size():
			_hud.draw_rect(Rect2(box.position + Vector2(38 + c * 6, 6), Vector2(4, 4)), accent.lightened(0.3) if pips[c] <= 0.0 else Color(0.3, 0.3, 0.3))
	# The charm slot: C, beside the four.
	var cbox := Rect2(x0 + 4 * 66.0 + 12.0, 580.0, 60.0, 52.0)
	if _card_shake[4] > 0.0:
		cbox.position.x += round(sin(_card_shake[4] * 70.0) * 3.0)
	var cname: String = f["charm"]
	var ccd: float = CHARMS[cname]["cooldown"]
	var cready: bool = f["charm_cd"] <= 0.0
	var cfill: float = 1.0 - clampf(f["charm_cd"] / ccd, 0.0, 1.0)
	_hud.draw_rect(cbox, Color(0.07, 0.09, 0.11, 0.85))
	_hud.draw_rect(Rect2(cbox.position + Vector2(0, cbox.size.y * (1.0 - cfill)), Vector2(cbox.size.x, cbox.size.y * cfill)), Color(1.0, 0.85, 0.3, 0.3 if not cready else 0.5))
	_hud.draw_rect(cbox, Color(1.0, 0.85, 0.3) if cready else Color("#75604D"), false, 2.0)
	if _card_flash[4] > 0.0:
		_hud.draw_rect(cbox, Color(1, 1, 1, 0.7 * _card_flash[4] / CARD_FLASH))
	_hud.draw_string(_font, cbox.position + Vector2(5, 14), "C", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#F0F4F8"))
	_hud.draw_string(_font, cbox.position + Vector2(0, 44), String(CHARMS[cname]["name"]).to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 60, 7, Color(1, 1, 1, 0.9 if cready else 0.5))
	if _why_t > 0.0 and _why != "":
		# Why the last press failed, over the bar, fading.
		var ka: float = clampf(_why_t / 0.3, 0.0, 1.0)
		_hud.draw_string(_font, Vector2(x0 - 20.0, 572.0), _why, HORIZONTAL_ALIGNMENT_CENTER, 5 * 66 + 52, 10, Color(1, 0.6, 0.5, ka))


func _ellipse(c: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for k in 16:
		var a := TAU * k / 16.0
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts
