extends Node2D
## Hollowtide as a mystery dungeon (Claude, 2026-10-09). Preston: "We're pivoting to more mystery
## dungeon... even the combat turns etc. Take and synthesize what we've made and learned onto a
## newer and improved mystery dungeon like game." The design doc is
## docs/design/mystery-dungeon-pivot-2026-10-09.md; this is its first playable slice.
##
## Turn-based on a grid: every creature takes one action when the leader takes one. Moving,
## attacking, using a move or resting is an action; turning to face is free. Partners follow the
## leader in a chain and fight with their own judgment; wild creatures sleep until something of
## yours comes into sight. The floor comes from the Hollow generator with one-tile hallways;
## the creatures, their kits, art and essence chart come from what the arena built. Every
## number is a draft for Grok.
##
## Structure read from Explorers of Sky (docs/research/pmd-sky-references-2026-10-09.md);
## nothing copied. What is new against it: bumping into an enemy attacks it, a move with nothing
## in reach is refused instead of wasting the turn, a move aims itself at the one enemy it can
## reach, enemy strong moves show a warning the turn before, and the moves keep the arena kits.

const Arena := preload("res://scripts/arena/arena_prototype.gd")
const Gen := preload("res://scripts/hollow/hollow_gen.gd")
const Painter := preload("res://scripts/dungeon/floor_painter.gd")
const RuinPainter := preload("res://scripts/dungeon/ruin_painter.gd")
const BankPainter := preload("res://scripts/dungeon/riverbank_painter.gd")
const DungeonFinish := preload("res://scripts/dungeon/dungeon_finish.gd")
const CrewPortraitCanvas := preload("res://scripts/ui/crew_portrait_canvas.gd")
const ValleyPainter := preload("res://scripts/dungeon/valley_painter.gd")
const MoveBody := preload("res://scripts/moves/move_body.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const Jobs := preload("res://scripts/town/jobs.gd")
const BossIntro := preload("res://scripts/dungeon/boss_intro.gd")
const CrewScene := preload("res://scripts/dungeon/crew_scene.gd")
const StoneScene := preload("res://scripts/dungeon/stone_scene.gd")
const Music := preload("res://scripts/audio/music.gd")
const TOWN_SCENE := "res://scenes/hub_town.tscn"
const FONT := preload("res://assets/fonts/Silkscreen-Bold.ttf")
const UI := preload("res://scripts/ui/ui_style.gd")   # the shared look (Claude, 2026-10-10)

const T := 24                           # tile size in the low-resolution view
const VIEW := Vector2i(384, 216)
const SCALE := 3.0
const FLOORS := 3
const HP_SCALE := 0.2                   # arena HP to dungeon HP
const DMG_SCALE := 0.6                  # arena damage to dungeon damage
const SIGHT := 6                        # tiles a creature sees
const REGEN_EVERY := 4                  # turns per point of natural recovery
const STEP_TIME := 0.11                 # seconds a step takes on screen
const WILD_HP := 0.8                    # wild creatures on these early floors are weaker than yours,
const WILD_DMG := 0.7                   # as early floors are in Explorers of Sky (drafts for Grok)
const REST_TO := 0.7                    # the autopilot rests back to this share of health between fights
## The run loop (slice 2). The lantern is the run's clock: it drains a point every few turns and
## relights when you down a wild creature; its light is how far you see down a hallway (rooms
## stay lit while it burns). The bag holds ten kinds of item, is kept when a dungeon is cleared
## and lost when the leader faints. Item names are working labels.
const LIGHT_MAX := 100.0
const LIGHT_DRAIN_EVERY := 3
const LIGHT_ON_KO := 12.0
const BAG_KINDS := 10
const ITEMS := {
	"reedberry": {"name": "Reedberry", "what": "heals the leader 15", "col": Color("#c84a5a")},
	"lamp_oil": {"name": "Lamp Oil", "what": "40 light back", "col": Color("#f2c14e")},
	"river_stone": {"name": "River Stone", "what": "thrown down a line, 8 damage", "col": Color("#9aa4ae")},
	"rally_seed": {"name": "Rally Seed", "what": "the leader gets up once when it faints", "col": Color("#7fd16a")},
}
const TRAPS := {
	"snare": {"name": "Snare", "what": "held for 2 turns"},
	"silt": {"name": "Silt Pit", "what": "6 damage round it, 15 light lost"},
	"warp": {"name": "Warp Eddy", "what": "carried to another room"},
}
const MONSTER_HOUSE_WILD := 4            # the fewest a Monster House drops in
# Traps as the Mystery Dungeon games place them (Preston, 2026-10-09: "way too many warps and they
# are in the hallways"): only in rooms, never in front of a hallway opening, never in the start
# room or a Monster House, and only the leader sets one off. Drafts for Grok.
const TRAP_WARP_MAX := 1                 # warps on a floor
# Monster Houses and the boss floor (Claude, 2026-10-09; structure from Explorers of Sky and Rescue
# Team DX, nothing copied; numbers are drafts for Grok).
const MONSTER_HOUSE_MAX := 7
const MONSTER_HOUSE_PER_TILES := 12      # one more creature for every this many floor tiles of the room
const MONSTER_HOUSE_ITEMS := 3           # bait lying in the room before it springs
const MONSTER_HOUSE_LIGHT := 30.0        # clearing one relights the lantern this much
# The floor plan, as Explorers of Sky lays a dungeon out (Preston, 2026-10-09: "the boss is always
# at the top highest level dungeon floor... it would soley be boss. With usually a dialogue
# cutscene before hand"; SkyTemple: boss battles take place in fixed rooms that are the whole
# floor). FLOORS generated floors, then the boss's FIXED floor, FLOORS + 1, which is only the
# boss. A long dungeon can set `rest_floor` to a quiet fixed floor partway that heals the team.
# The first boss is the Quietwater Warden (Preston, 2026-10-10: "I want warden to be first boss"),
# Tide/Hollow, the river's keeper of stillness, escorted by two Cutbank Listeners, its own first
# stage. It replaced Scourmaw, which is leaving Hollow/Tide. Its moves are the listener line's
# (Echo Tap, Interrupt Call); the boss's strength and kit are Grok's to tune.
const BOSS := [7, 2]
const BOSS_MINIONS := [[7, 0], [7, 0]]
const BOSS_HP := 3.0                     # times a wild creature's health
const BOSS_DMG := 0.9                    # in place of WILD_DMG
const FIXED_RECIPE := {"spawns": [], "items": 0, "traps": 0, "monster_house": 0.0}   # no wild, items or traps on a fixed floor
const BOSS_ARENA := Vector2i(19, 14)     # the boss floor: one fixed room, in floor tiles (wider for the Warden's pond garden, 2026-10-10)
const REST_ROOM := Vector2i(9, 7)
# Placeholder lines (Preston writes the real scene). {partner} and {boss} are filled in.
const BOSS_TALK := [["{partner}", "The air is heavy down here... something is waiting for us."], ["{boss}", "Graaah!"], ["{partner}", "Here it comes!"]]
# Move scrolls (Claude, 2026-10-09; working name, Preston names it): a found item that teaches a
# shared signature to a teammate whose body has every part it needs (scripts/moves/move_body.gd,
# Grok's gate). Bag kinds are "scroll:<move>". Drafts for Grok.
const SCROLL_SHARE := 0.10              # share of floor items that are scrolls (Grok, 2026-10-10: a find, not one a floor)
const MOVES_MAX := 4
## Enemy warnings (slice 4): the arena's telegraph as a turn rule.
const WARN_KINDS := ["dash", "line", "burst"]
## Recruiting (slice 5): the chance a beaten wild creature asks to join, by its stage, and the team's size.
const RECRUIT_RATE := {0: 0.12, 1: 0.08, 2: 0.04}   # Grok, 2026-10-10: about one ask every three early floors, not every floor
# Position is power (Claude, 2026-10-09; structure from Into the Breach's pushes, Hoplite's
# approach and Explorers of Sky's sleeping rooms; the numbers are drafts for Grok).
const AMBUSH := 1.5                     # a hit on a sleeping creature
const PINCER := 1.5                     # a hit on a foe with one of the attacker's team on its far side
const SLAM_SHARE := 0.15                # a shoved creature that hits a wall or a body loses this share of its max HP
const SLAM_STAGGER := 1                 # and loses this many turns (and whatever it was gathering)
# Team tactics (Claude, 2026-10-09; structure from Rescue Team DX's team orders and the arena's
# Kit Sense modes). T cycles them and costs no turn. TACTIC_LEASH is how far from the leader a
# partner will go after a foe; guard also keeps it beside the leader.
const TACTICS := ["follow", "go", "guard"]
const TACTIC_NAMES := {"follow": "FOLLOW ME", "go": "GO AFTER FOES", "guard": "GUARD ME"}
const TACTIC_LEASH := {"follow": 4, "go": 99, "guard": 2}
const FLANK_REACH := 2                  # a partner walks this many tiles round to a foe's far side
const FLANK_WORTH := 0.4                # but only while the foe has more than this share of its health
const TEAM_MAX := 4
# Evolution by conditions (Claude, 2026-10-09; Preston chose option A: "for digimon do (A)").
# Structure from Digimon World Dawn/Dusk's evolution requirements (stat and battle thresholds per
# form), kept inside Hollowtide's rule of one path per line, three stages, no branches. A creature
# on your team grows as it fights; when it has met all three conditions for its stage it evolves
# on the next floor. KOs: foes it downed. FLOORS: floors it went down with the team. WAY: what its
# line grows from, read off the systems the dungeon already has:
#   flank  = hits from a pincer or on a sleeping foe   took  = damage it took for the team
#   ambush = hits on a sleeping foe                    slam  = foes it slammed into walls or bodies
# Two numbers per condition: stage 1 to 2, then stage 2 to 3. Grok, 2026-10-10: these are the numbers.
const EVO := {
	0: {"way": "flank", "kos": [3, 6], "floors": [2, 4], "need": [4, 8]},    # Kithflare line: the runner
	1: {"way": "took", "kos": [2, 5], "floors": [2, 4], "need": [60, 140]},  # Tallowroot line: the tank
	2: {"way": "ambush", "kos": [3, 6], "floors": [2, 4], "need": [2, 5]},   # Rimefin line: the ambusher
	3: {"way": "slam", "kos": [3, 6], "floors": [2, 4], "need": [2, 5]},     # Cinderhide line: the bruiser
	4: {"way": "took", "kos": [2, 5], "floors": [2, 4], "need": [60, 140]},  # Fusern line: the kiln tank
	5: {"way": "took", "kos": [3, 6], "floors": [2, 4], "need": [50, 120]},  # Preostmar line: the wall
	6: {"way": "took", "kos": [2, 5], "floors": [2, 4], "need": [50, 120]},  # Punchybun line: the protector
	7: {"way": "flank", "kos": [2, 5], "floors": [2, 4], "need": [3, 7]},    # Listener line: the controller
	8: {"way": "took", "kos": [2, 5], "floors": [2, 4], "need": [50, 120]},  # Canvaswing line: the shelter
	9: {"way": "flank", "kos": [3, 6], "floors": [2, 4], "need": [4, 8]},    # Dustkite line: the spotter
	10: {"way": "healed", "kos": [2, 5], "floors": [2, 4], "need": [40, 100]}, # Springvault line: the healer (Claude's draft for Grok, 2026-10-10)
}
# Levels (Claude, 2026-10-09; Preston: "still want to keep the evolve by leveling on top of our
# evolution rules", and chose "level, then conditions", the Digimon World way). Every foe the team
# downs gives each teammate EXP, as in Explorers of Sky; a level adds health; and a teammate
# evolves only once it has reached its stage's level AND met the EVO conditions above. A level
# belongs to the line, like IQ, so it carries through evolution. A recruit joins at the floor's
# number. DRAFT NUMBERS FOR GROK: the evolve levels, the EXP, the curve and the health a level adds.
const EVO_LEVEL := [5, 10]       # stage 1 to 2, stage 2 to 3
const LEVEL_MAX := 50
const EXP_PER_KO := 12           # for each foe downed, plus EXP_PER_STAGE for each stage it had grown
const EXP_PER_STAGE := 6
const EXP_BOSS := 60             # added for the boss
const LEVEL_HP := 0.03           # max health grows 3% a level above 1
# Learnsets (Grok, 2026-10-10: docs/creatures/learnset-draft-2026-10-10.md, its rules and tables
# exactly). One list per form: [level, move], or ["evolve", move] for the move taught on evolving
# into that form. A raised creature keeps every move its new body can still perform; slot 0 is
# the form's basic and is never forgotten; four moves at most, and a full set asks which to forget
# (the scroll panel) or lets the move go. Wild creatures and recruits use the floor as their level
# and know the list up to it. WAITING holds the moves that do nothing in the dungeon yet; they
# are not taught until the dungeon plays their real effect.
const LEARN := {
	"kithflare": [[1, "claw"], [1, "ember_feint"], [3, "fireball"]],
	"sparkwick": [["evolve", "pounce"], [6, "wick_bolt"], [8, "lantern_volley"]],
	"stormwick": [["evolve", "lantern_tackle"]],
	"tallowroot": [[1, "seed"], [1, "root_snare"]],
	"huskward": [["evolve", "club_slam"]],
	"rampartroot": [["evolve", "root_rampart"]],
	"rimefin": [[1, "needle_bite"], [1, "lunge"]],
	"riftfin": [],
	"scourmaw": [],
	"cinderhide": [[1, "cinder_claw"], [1, "vent_blast"], [3, "claw"]],
	"clinkerhide": [["evolve", "crest_ram"]],
	"ironvent": [["evolve", "vent_barrage"]],
	"fusern": [[1, "ember_pellet"]],
	"slagglass": [["evolve", "plate_lunge"]],
	"vitrecrag": [["evolve", "molten_cannon"], [12, "molten_beam"]],
	"preostmar": [[1, "jade_lance"], [1, "ground_spikes"], [3, "stone_cocoon"]],
	"oathfen": [["evolve", "slab_vortex"]],
	"oxbowarchon": [["evolve", "rail_shot"], [12, "kingstone_lift"], [14, "rail_recoil"]],
	"punchybun": [[1, "jab"]],
	"sparkjab": [["evolve", "counter_jab"]],
	"starward": [],
	"listener": [[1, "echo_tap"], [1, "interrupt_call"]],
	"caller": [],
	"warden": [],
	"canvaswing": [[1, "shear"]],
	"windcut": [],
	"galeshear": [],
	"dustkite": [[1, "whistle_dart"]],
	"waywhistle": [],
	"highsignal": [],
	# The Springvault line: Claude's draft for Grok (2026-10-10). Archroot's evolve move will be
	# Mineral Brace and Springvault's Vault Arch once the dungeon can play them.
	"troughspine": [[1, "spring_spit"], [1, "seep"]],
	# The rival crew (Claude, 2026-10-10): Play Dead waits for the boss slice.
	"mirekit": [[1, "grub_bite"], [1, "rot_spit"]],
	"whinet": [[1, "needle_jab"], [1, "drain_bite"], [3, "buzz_dart"]],
	"gruntle": [[1, "grub_bite"]],
	# The Hollow's new wilds (2026-10-10): existing moves their bodies allow, placeholders until Grok sets kits.
	"skimlet": [[1, "needle_bite"], [3, "lunge"]],
	"ozbender": [[1, "needle_bite"], [4, "lunge"]],
	"valvekin": [[1, "glass_guard"]],   # a placeholder bite until Grok sets its kit (drafts in the crew proposal)
	"archroot": [],
	"springvault": []}

const WAITING := {
	"mirekit": [[1, "play_dead"]],
	"tallowroot": [[3, "burrow"]],
	"huskward": [[6, "root_wall"]],
	"rimefin": [[3, "sinkhole"]],
	"riftfin": [["evolve", "riptide"]],
	"fusern": [[1, "glass_guard"]],
	"punchybun": [[1, "static_dance"], [3, "star_guard"]],
	"listener": [[3, "deep_brace"]],
	"caller": [["evolve", "still_water"]],
	"canvaswing": [[1, "sail_cover"], [3, "downdraft"]],
	"windcut": [["evolve", "lift"]],
	"dustkite": [[1, "signal_mark"], [3, "decoy_call"]],
	"waywhistle": [["evolve", "vantage"]]}
# Teammate IQ (Claude, 2026-10-09; Preston: "our system should have the teammate IQ system", then
# "do teammate iq task"). Structure from Explorers of Sky: a partner's IQ grows, and skills that
# change how it acts switch on at thresholds. Skill names are working names (Preston names them).
# Grok, 2026-10-10: gains stay 1, and the thresholds stay 3, 6, 10, 15, 20, 25.
# IQ belongs to the line, so it carries through evolution.
const IQ_PER_FLOOR := 1
const IQ_PER_KO := 1
const IQ_SKILLS := [
	{"id": "step_aside", "at": 3, "name": "Step Aside", "what": "steps out of a tile a wind-up has marked"},
	{"id": "finisher", "at": 6, "name": "Finisher", "what": "goes for the weakest foe, and a hit that downs it"},
	{"id": "quiet", "at": 10, "name": "Quiet Steps", "what": "does not wake sleeping creatures"},
	{"id": "ambusher", "at": 15, "name": "Ambusher", "what": "strikes a sleeping foe beside it"},
	{"id": "berry", "at": 20, "name": "Berry Sense", "what": "eats a Reedberry from the bag below 30% health"},
	{"id": "fall_back", "at": 25, "name": "Fall Back", "what": "badly hurt with no berry, stops fighting and stays by the leader"},
]
const WAY_WORDS := {"flank": "flank and ambush hits", "took": "damage taken for the team", "ambush": "ambushes", "slam": "slams"}
## The hybrid (2026-10-09): exploring is turn-based; a fight is played in real time with the
## arena engine on this same floor. An awake wild creature this close and in sight starts one;
## the wild creatures within reach of it join; running this far from every foe for a moment ends it.
const BATTLE_RANGE := 5
const BATTLE_JOIN := 8
const FLEE_TILES := 9
const FLEE_SECONDS := 1.5
const BATTLE_SECONDS_PER_TURN := 1.0    # the lantern and the turn count advance with a battle's length
const BATTLE_SCENE := "res://scenes/hollow_floor.tscn"
const HIT_TIME := 0.2
# Action animations (Claude, 2026-10-09; Preston: attack, hurt and sleep for the stage 1 starters).
# Frames from tools/arena/build_actions.py; a creature without them keeps its still. Seconds per play.
const ACT_TIME := {"attack": 0.36, "hurt": 0.3}
const SLEEP_LOOP := 1.6
# Move effects (Claude, 2026-10-09; Preston: "upgrade skill animations and vfxs with the synthesis").
# Structure from Explorers of Sky's move animations (each move: the user's animation, a projectile,
# an effect on the target, a screen effect) and Rescue Team DX's feel (shake, a hit-stop, a flash
# on a strong hit). The art is the arena's own painted Retro Diffusion sheets (16 frames each).
const FX_SECONDS := 0.45
const ESSENCE_FX := {"EMBER": "fire_burst", "TIDE": "water_burst", "STONE": "earth_burst", "GALE": "gust_lift",
	"BLOOM": "root_burst", "HOLLOW": "hush_ring", "ELECTRIC": "shock_burst", "ICE": "water_burst",
	"SINEW": "slam_shock", "LOAM": "earth_burst", "MURK": "water_burst", "BLIGHT": "root_burst"}   # the last four borrow (2026-10-10)
const ESSENCE_COL := {"EMBER": Color(1, 0.55, 0.25), "TIDE": Color(0.35, 0.75, 1), "STONE": Color(0.7, 0.6, 0.45), "GALE": Color(0.8, 0.9, 1),
	"BLOOM": Color(0.5, 0.9, 0.4), "HOLLOW": Color(0.65, 0.5, 0.9), "ELECTRIC": Color(1, 0.95, 0.4), "ICE": Color(0.75, 0.95, 1),
	"SINEW": Color(0.9, 0.45, 0.3), "LOAM": Color(0.66, 0.51, 0.35), "MURK": Color(0.35, 0.45, 0.6), "BLIGHT": Color(0.7, 0.45, 0.8)}
# Per move: "proj" travels down the line to the target, "hit" plays on each target, "area" plays
# where a burst lands. A move not listed uses its essence's burst. Chosen by what the body does.
# The impact layered under a hit, by the move's essence (Claude, 2026-10-09). Hollow has none on
# purpose: its hits are the hush, only the body's thump. Ice borrows water until it has its own.
const ESSENCE_SFX := {"EMBER": "impact_fire", "TIDE": "impact_water", "STONE": "impact_earth", "GALE": "impact_wind",
	"BLOOM": "impact_root", "ELECTRIC": "impact_shock", "ICE": "impact_water",
	# The four new essences borrow the nearest sound until their own ElevenLabs batch (2026-10-10).
	"SINEW": "impact_earth", "LOAM": "impact_earth", "MURK": "impact_water", "BLIGHT": "impact_root"}
const MOVE_FX := {
	"claw": {"hit": "light_slash"}, "cinder_claw": {"hit": "light_slash"}, "pounce": {"hit": "light_slash"},
	"ember_feint": {"hit": "fire_burst"}, "fireball": {"proj": "lantern_ball", "hit": "fire_burst"},
	"wick_bolt": {"proj": "spark_bolt", "hit": "shock_burst"}, "lantern_volley": {"proj": "lantern_ball", "hit": "lantern_flash"},
	"lantern_tackle": {"hit": "shock_burst"},
	"seed": {"proj": "seed_pod", "area": "root_burst"}, "root_snare": {"hit": "root_snare"}, "club_slam": {"hit": "slam_shock"},
	"needle_bite": {"hit": "water_burst"}, "lunge": {"hit": "water_burst"}, "riptide": {"area": "riptide_whirl"},
	"vent_barrage": {"proj": "vent_flame", "hit": "fire_burst"}, "crest_ram": {"hit": "slam_shock"},
	"vent_blast": {"hit": "vent_flame"}, "ember_pellet": {"proj": "lantern_ball", "hit": "fire_burst"},
	"molten_beam": {"hit": "glass_splash"}, "plate_lunge": {"hit": "slam_shock"}, "molten_cannon": {"proj": "molten_drip", "area": "glass_splash"},
	"jade_lance": {"proj": "jade_burst", "hit": "jade_burst"}, "ground_spikes": {"area": "jade_spikes"}, "slab_vortex": {"area": "slab_vortex"},
	"rail_shot": {"hit": "jade_burst"}, "jab": {"hit": "shock_burst"}, "counter_jab": {"hit": "shock_burst"},
	"static_dance": {"area": "spark_bolt"}, "echo_tap": {"hit": "sonar_ring"}, "interrupt_call": {"area": "sonar_ring"},
	"spring_spit": {"hit": "water_burst"},
	"shear": {"hit": "sail_slash"}, "downdraft": {"area": "downdraft_column"}, "whistle_dart": {"proj": "spark_bolt", "hit": "sonar_ring"},
}
const RECIPE := {"cols": 3, "rows": 2, "cell_w": 14, "cell_h": 10, "room_density": 0.7, "extra_halls": 0.15,
	"dead_ends": false, "hall_width": 1, "wild": 3, "spawns": [[9, 0], [8, 0]],
	"items": 5, "traps": 4, "monster_house": 0.3}   # Grok, 2026-10-10: half the floor (42x20). Wild count stays 3.
## Which stage-0 wild creatures each floor rolls (Grok, 2026-10-10). Kithflare and Tallowroot
## stay the party. The map, the wild count, the items, the traps and the house rate stay on RECIPE.
## Rootbank Warren's wilds (Preston, 2026-10-10: starters are not recruited yet; the recruitable lines are
## Preostmar, Cinderhide, Fusern, Listener, Canvaswing, Dustkite, Troughspine and the new Hollow lines).
## Stocked the Explorers of Sky way, by what lives in a dry clay riverbank: the Gale nesters in the sunny
## burrows near the top, the burrowing Ember lizard below, kiln-hard clay and buried stone at the bottom.
## Listener lives at the Warden's pond (The Hollow); plan: docs/design/pilot-story-2026-10-10.md.
const FLOOR_SPAWNS := {
	1: [[9, 0], [8, 0]],                 # Dustkite, Canvaswing
	2: [[9, 0], [8, 0], [3, 0]],         # + Cinderhide
	3: [[3, 0], [4, 0], [5, 0]],         # Cinderhide, Fusern, Preostmar
}
## The dungeons (Claude, 2026-10-10; Preston: the Warden is the second boss; the first is the rival crew's
## two grunts, easy on purpose). Each has its floors, its wild creatures by floor, the look of each floor
## ("bank": the silted banks; "ruin": the risen structure's stone, scripts/dungeon/ruin_painter.gd) and
## its boss floor. The town sends a run to the first dungeon whose boss is not beaten yet.
## The Hollow (Preston): a small sheltered valley between hills, where a structure rose out of the
## river with a stone pathway to it. Its first floor is the valley, then the stone, then the pond garden.
const CREW_TALK := [["{partner}", "There they are! Give back that parcel!", "angry"],
	["{boss}", "Finders keepers, courier. Wasn't yours to begin with.", "mischievous"],
	["Whinet", "Yeah! Keepers! Get 'em, Mirekit!", "mischievous"],
	["{partner}", "We'll take it back ourselves, then!", "angry"]]
const DUNGEONS := {
	# The first dungeon's name is Claude's pick (Preston, 2026-10-10: "you choose name for dungeon 1"):
	# tunnels dug through a river bank, roots in the walls, where the crew holes up.
	"first": {"name": "Rootbank Warren", "floors": FLOORS, "spawns": FLOOR_SPAWNS, "looks": {1: "riverbank", 2: "riverbank", 3: "riverbank", 4: "riverbank"},
		"boss": {"line": [100, 0], "minions": [[101, 0]], "hp": 1.5, "intro": false, "scene": "crew", "arena": Vector2i(13, 10), "talk": CREW_TALK}},
	"hollow": {"name": "The Hollow", "floors": 2,
		# The Warden's dungeon leans Tide, stocked the Explorers of Sky way: the place's essence plus what
		# lives at the water (Preston, 2026-10-10: Troughspine belongs here). Listener and Troughspine;
		# the Gale fliers moved out; Rimefin too (a starter's line is not met here, Preston, same day).
		# The three water-edge lines (docs/creatures/hollow-wilds-2026-10-10.md): Skimlet in the valley, Ozbender and Valvekin in the ruin.
		"spawns": {1: [[7, 0], [10, 0], [103, 0]], 2: [[7, 0], [10, 0], [104, 0], [105, 0]]},   # + Skimlet; + Ozbender, Valvekin
		"looks": {1: "valley", 2: "ruin", 3: "ruin"},
		"boss": {"line": BOSS, "minions": BOSS_MINIONS, "hp": BOSS_HP, "intro": true, "arena": BOSS_ARENA, "talk": BOSS_TALK, "stone": true}},
}
const DIRS := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1)]

var party: Array = [[0, 0], [1, 0]]     # your team, [line, stage]; the first one leads
var floor_n := 1
var floor_seed := 0
var autopilot := false
var poll_input := true                  # the checks turn this off and call act_* themselves
var turn := 0
var busy := false
var cleared := 0
var faints := 0
var light := LIGHT_MAX
var bag := {"reedberry": 1}
var last_sfx := {}   # sound name -> the turn it last played (read by tools/debug/dungeon_sfx_check.gd)
var bag_open := false
var bag_sel := 0
var floor_items: Array[Dictionary] = []   # {pos, kind}
var traps: Array[Dictionary] = []         # {pos, kind, seen}
var monster_room := Rect2i()              # the Monster House this floor (empty when none)
var monster_sprung := false
var house_cleared := false
var boss := -1                            # ents index of the boss on the boss floor, or -1
var boss_room := Rect2i()
var boss_met := false
var _banner := {"text": "", "sub": "", "at": -100000, "col": Color.WHITE}
var rest_floor := 0                       # a quiet fixed floor partway through a long dungeon; 0 = none
var talk: Array = []                      # dialogue lines still to show, [speaker, text]
var jobs: Array = []                      # the Job Board requests the team carries (scripts/town/jobs.gd)
var rank := 0                             # Courier Rank points; only the board changes them, the run carries them
var clients: Array = []                   # this floor's job clients waiting in a room: {id, pos, node}
var boss_intro := true                    # play the Warden's entrance (scripts/dungeon/boss_intro.gd); off = straight to its talk
var cutscene := false                     # a scene is playing: no turns, J only reads the lines
var intro := {}                           # the entrance's state for drawing (pond shadow, ground shadow, daze)
var cam_focus: Variant = null             # a scene points the camera here instead of at the leader
var pond := Rect2i()                      # the boss room's pond (no walking on it), or empty
var dungeon := "first"                    # which of DUNGEONS this run is in (the town sets it)
var beaten: Array = []                    # dungeons whose boss the team has beaten (carried by TeamState)
var story := {}                           # the pilot's story state: "stone" is "", "carried" or "installed" (docs/design/pilot-story-2026-10-10.md)


func floors() -> int:
	return int(DUNGEONS[dungeon]["floors"])


func boss_cfg() -> Dictionary:
	return DUNGEONS[dungeon]["boss"]


## The boss floor plays the Warden's entrance only in a dungeon whose boss has one.
func intro_here() -> bool:
	return boss_intro and boss_cfg().get("intro", false)


## The Shortcut Crew's own scene (scripts/dungeon/crew_scene.gd): the parcel, the flop, the getaway.
func crew_scene_here() -> bool:
	return boss_intro and boss_cfg().get("scene", "") == "crew"
var _finishing := false
var visible_tiles := {}                   # tiles the leader can see this turn
var dodged := 0                           # wind-ups that landed on nobody (for the checks)
var recruit_override := -1.0              # the checks force the chance (0..1); below zero uses RECRUIT_RATE
var asking := -1                          # the creature waiting for your answer, or -1
var roster: Array = []                    # creatures waiting at the courier hall, [line, stage]
var tactic := "follow"                    # the partners' order (T cycles it)
var pincers := 0                          # hits your partners landed from a pincer (for the checks)
var taught := {}                          # "line:stage" -> the moves a teammate knows after a scroll
var growth := {}                          # "line:stage" -> {kos, floors, flank, ambush, took, slam}: what it has done toward evolving
var iq := {}                              # line -> IQ points (a partner's line keeps them through evolution)
var levels := {}                          # line -> {"lv": level, "exp": EXP toward the next}
var pending_learn: Array = []             # [line, stage, move] an evolution in town could not fit yet
var learn_queue: Array = []               # [ents index, move]: moves a teammate is offered, one at a time
var focus: Dictionary = {}                # the foe the leader is fighting (Team Sense), or {}
var evolved_log: Array = []               # [old name, new name] for each evolution (for the checks)
var teach_kind := ""                      # the scroll being read, or "" when the teach panel is shut
var teach_sel := 0
var teach_learner := -1                   # chosen learner (ents index) while choosing a move to forget
var _party_at_start: Array = []           # the team the run began with (a faint returns to it)
var return_to_town := false              # set by the town: a clear or a faint goes back to Highbank (off when the dungeon runs alone)
var real_time_battles := false            # Preston, 2026-10-09: dungeon fights stay turn-based; the arena is its own mode. On: fights hand over to the arena engine (kept, built that night)
var in_battle := false
var battles := 0
var _battle: Node2D = null
var _battle_ids: Array = []               # ents index of each arena fighter, in the arena's order
var _battle_t := 0.0
var _flee_t := 0.0
var _screen: Sprite2D
var _hud_layer: CanvasLayer
var _roster_at_start: Array = []
var _floor_fx: Node2D                     # warning tiles, drawn on the floor under the creatures
var data: Dictionary = {}
var ents: Array[Dictionary] = []        # every creature on the floor; ents[0] is the leader
var log_lines: Array[String] = []
var explored := PackedByteArray()
var _fields := {}
var _pops: Array[Dictionary] = []       # floating numbers and words
var _shots: Array[Dictionary] = []      # a move's projectile in flight
var _vfx: Array[Dictionary] = []        # painted effects playing: {name, pos, t, to (a projectile's end), dur}
var _fx_frames := {}                    # effect name -> its 16 frames, loaded on first use
var _ghosts: Array[Dictionary] = []     # a dash's afterimages: {tex, pos, t, flip}
var _shake := 0.0                       # screen shake, decays each frame
var _flash := 0.0                       # a white flash on a strong hit
var _heavy := false                     # this action landed a heavy hit (a hit-stop follows)
var _stop := 0.08                        # how long that hit-stop is (longer for a super-effective hit)
# The VFX pass (Claude, 2026-10-10): sparks, rings and motes drawn in the world, so every essence,
# the new ones too, shows on contact. Structure from fighting games' hit feedback (hit-stop that
# scales with the blow) and Mystery Dungeon DX's popping damage numbers; all drawn in code.
var _parts: Array = []                   # {pos, vel, t, life, col, size, grav}
var _rings: Array = []                   # {pos, t, life, r, col}
var _hold := 0.0                        # a first key press waits this long so two keys can make a diagonal
var turn_mode := false                  # Shift is held: the leader turns in place and the arrows show
var _shift_turned := false              # a direction was pressed during this Shift hold (so it was no tap)
var _was_dir := Vector2i.ZERO
var _keys_was := {}

var _view: SubViewport
var _world: Node2D
var _map: Sprite2D
var _fx: Node2D
var _hud: Node2D
var _fade: ColorRect


func _ready() -> void:
	if floor_seed == 0:
		floor_seed = randi()
	_party_at_start = party.duplicate(true)
	_roster_at_start = roster.duplicate(true)
	_view = SubViewport.new()
	_view.size = VIEW
	_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	add_child(_view)
	var screen := Sprite2D.new()
	screen.texture = _view.get_texture()
	screen.centered = false
	screen.scale = Vector2.ONE * SCALE
	screen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(screen)
	_screen = screen
	_world = Node2D.new()
	_view.add_child(_world)
	_map = Sprite2D.new()
	_map.centered = false
	_world.add_child(_map)
	_floor_fx = Node2D.new()
	_floor_fx.draw.connect(_draw_floor_fx)
	_world.add_child(_floor_fx)
	_fx = Node2D.new()
	_fx.z_index = 4000
	_fx.draw.connect(_draw_fx)
	_world.add_child(_fx)
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud_layer = layer
	_hud = Node2D.new()
	_hud.draw.connect(_draw_hud)
	layer.add_child(_hud)
	var crew_portraits := CrewPortraitCanvas.new()
	crew_portraits.name = "CrewPortraitFinish"
	_hud.add_child(crew_portraits)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.size = Vector2(1152, 648)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_fade)
	_build_floor(true)


# ---------------------------------------------------------------- the floor

func _build_floor(fresh_team: bool) -> void:
	var keep: Array = []
	if not fresh_team:
		for e in ents:
			if e["team"] == 0:
				keep.append(e["hp"])
	for e in ents:
		e["node"].queue_free()
	ents.clear()
	_fields.clear()
	_pops.clear()
	_shots.clear()
	boss = -1
	boss_met = false
	talk.clear()
	pond = Rect2i()
	intro = {}
	cutscene = false
	cam_focus = null
	data = Gen.generate(floor_seed, RECIPE) if floor_kind() == "normal" else _fixed_floor(floor_kind())
	if floor_kind() == "boss" and intro_here():
		pond = BossIntro.pond_rect(data["stairs"])
	var look: String = DUNGEONS[dungeon]["looks"].get(floor_n, "bank")
	var painter: Variant = {"ruin": RuinPainter, "riverbank": BankPainter, "valley": ValleyPainter}.get(look, Painter)
	_map.texture = ImageTexture.create_from_image(painter.paint(data, T, floor_seed))
	DungeonFinish.apply(_map, data, T, look)
	explored = PackedByteArray()
	explored.resize(data["w"] * data["h"])
	# Your team round the start, the leader on it.
	var start: Vector2i = data["start"]
	var spots: Array[Vector2i] = [start]
	for d in [Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 1), Vector2i(1, 1)]:
		if _floor_at(start + d):
			spots.append(start + d)
	for k in party.size():
		var e := _make(party[k][0], party[k][1], 0, spots[mini(k, spots.size() - 1)])
		if k < keep.size():
			e["hp"] = mini(keep[k], e["max_hp"])
			if e["hp"] <= 0:
				e["node"].modulate.a = 0.0   # a partner that fainted stays down for the rest of the run
		ents.append(e)
	# The wild creatures, asleep in their rooms.
	var rng := RandomNumberGenerator.new()
	rng.seed = floor_seed + 7
	for sp in data["spawns"]:
		if _occupant(sp) >= 0:
			continue
		var pick: Array = recipe()["spawns"][rng.randi_range(0, recipe()["spawns"].size() - 1)]
		var w := _make(pick[0], pick[1], 1, sp)
		w["max_hp"] = maxi(6, int(round(w["max_hp"] * WILD_HP)))
		w["hp"] = w["max_hp"]
		w["awake"] = false
		w["facing"] = Arena.FACINGS[rng.randi_range(0, 7)]
		ents.append(w)
	if floor_kind() == "boss":
		_place_boss()
	for e in ents:
		_place(e)
	_stock_floor(rng)
	_reveal()
	_say("B%dF" % floor_n)
	_sfx("floor_arrive", -4.0)
	if floor_n == 1 and String(DUNGEONS[dungeon]["name"]) != "":
		_banner_show(String(DUNGEONS[dungeon]["name"]).to_upper(), "B1F", Color(0.95, 0.85, 0.6))   # the place, on arrival
	if not pending_learn.is_empty():
		_offer_pending.call_deferred()   # moves an evolution at the Growth Shrine could not fit
	_music_update()
	preload("res://scripts/ui/game_pause_menu.gd").attach(self)
	if floor_kind() == "rest":
		for e in ents:
			if e["team"] == 0:
				e["hp"] = e["max_hp"]
		light = LIGHT_MAX
		_say("A quiet floor. The team rests, and the lantern is refilled.")
		_banner_show("REST", "B%dF" % floor_n, Color(0.6, 0.9, 1.0))
	elif floor_kind() == "boss" and boss >= 0 and intro_here():
		BossIntro.setup(self)
		(func() -> void: BossIntro.run(self)).call_deferred()
	elif floor_kind() == "boss" and boss >= 0 and crew_scene_here():
		CrewScene.setup(self)
		(func() -> void: CrewScene.run(self)).call_deferred()
	elif floor_kind() == "boss" and boss >= 0:
		var pe: Dictionary = ents[1] if ents.size() > 1 and ents[1]["team"] == 0 else ents[0]
		var partner: String = pe["name"]
		# They are awake for their scene, facing the team; the camera leans toward them while they talk.
		for e in ents:
			if e.get("boss", false) or e.get("minion", false):
				e["awake"] = true
				e["facing"] = "s"
				_place(e)
		cam_focus = ents[boss]["node"].position.lerp(ents[0]["node"].position, 0.4)
		for line in boss_cfg().get("talk", BOSS_TALK):
			# The third field is whose dialogue portrait shows (assets/sprites/ui/dialogue/<form>.png).
			var form: String = String(pe["form"]) if line[0] == "{partner}" else (String(ents[boss]["form"]) if line[0] == "{boss}" else String(line[0]).to_lower())
			if line.size() > 2:
				form += ":" + String(line[2])   # the line's face
			talk.append([String(line[0]).replace("{partner}", partner).replace("{boss}", ents[boss]["name"]), line[1], form])


## Items in the rooms, hidden traps on the floor, and sometimes a Monster House.
func _stock_floor(rng: RandomNumberGenerator) -> void:
	floor_items.clear()
	traps.clear()
	monster_room = Rect2i()
	monster_sprung = false
	var taken := {data["start"]: true, data["stairs"]: true}
	for e in ents:
		taken[e["pos"]] = true
	var rooms: Array = data["rooms"]
	var kinds: Array = ITEMS.keys()
	house_cleared = false
	for k in recipe()["items"]:
		var room: Rect2i = rooms[rng.randi_range(0, rooms.size() - 1)]
		var p := Vector2i(rng.randi_range(room.position.x, room.end.x - 1), rng.randi_range(room.position.y, room.end.y - 1))
		if taken.has(p) or not _floor_at(p):
			continue
		taken[p] = true
		var kind: String = kinds[rng.randi_range(0, kinds.size() - 1)]
		if rng.randf() < SCROLL_SHARE:
			var pool := scroll_pool()
			if not pool.is_empty():
				kind = "scroll:" + pool[rng.randi_range(0, pool.size() - 1)]
		floor_items.append({"pos": p, "kind": kind})
	var trap_kinds: Array = TRAPS.keys()
	var warps := 0
	var tries := 0
	while traps.size() < recipe()["traps"] and tries < 400:
		tries += 1
		var room: Rect2i = rooms[rng.randi_range(0, rooms.size() - 1)]
		if room.grow(1).has_point(data["start"]):
			continue
		var p := Vector2i(rng.randi_range(room.position.x, room.end.x - 1), rng.randi_range(room.position.y, room.end.y - 1))
		if taken.has(p) or not _floor_at(p) or _cheb(p, data["stairs"]) < 2 or _by_opening(p, room):
			continue
		var kind: String = trap_kinds[rng.randi_range(0, trap_kinds.size() - 1)]
		if kind == "warp" and warps >= TRAP_WARP_MAX:
			kind = "snare" if rng.randf() < 0.5 else "silt"
		if kind == "warp":
			warps += 1
		taken[p] = true
		traps.append({"pos": p, "kind": kind, "seen": false})
	if rng.randf() < recipe()["monster_house"]:
		for room in rooms:
			if not room.grow(1).has_point(data["start"]) and not room.has_point(data["stairs"]):
				monster_room = room
				break
		traps = traps.filter(func(tr: Dictionary) -> bool: return not monster_room.has_point(tr["pos"]))
		# Bait: a few items lying in the room before it springs.
		var bait := 0
		for tries2 in 60:
			if bait >= MONSTER_HOUSE_ITEMS or monster_room.size == Vector2i.ZERO:
				break
			var q := Vector2i(rng.randi_range(monster_room.position.x, monster_room.end.x - 1), rng.randi_range(monster_room.position.y, monster_room.end.y - 1))
			if taken.has(q) or not _floor_at(q):
				continue
			taken[q] = true
			floor_items.append({"pos": q, "kind": kinds[rng.randi_range(0, kinds.size() - 1)]})
			bait += 1
	_place_jobs(rng, taken)


## The Job Board's requests for this floor (scripts/town/jobs.gd): a lost client waits in a room away
## from the start, or the item a client lost lies there. Reaching it finishes the job.
func _place_jobs(rng: RandomNumberGenerator, taken: Dictionary) -> void:
	for c in clients:
		c["node"].queue_free()
	clients.clear()
	if floor_kind() != "normal":
		return
	var rooms: Array = data["rooms"]
	for j in jobs:
		if j.get("done", false) or int(j["floor"]) != floor_n:
			continue
		for tries in 80:
			var room: Rect2i = rooms[rng.randi_range(0, rooms.size() - 1)]
			if rooms.size() > 1 and room.grow(1).has_point(data["start"]):
				continue
			if monster_room.has_point(room.position):
				continue
			var p := Vector2i(rng.randi_range(room.position.x, room.end.x - 1), rng.randi_range(room.position.y, room.end.y - 1))
			if taken.has(p) or not _floor_at(p) or _occupant(p) >= 0 or _by_opening(p, room):
				continue
			taken[p] = true
			if j["kind"] == "lost_item":
				floor_items.append({"pos": p, "kind": j["item"], "job": j["id"]})
			else:
				clients.append({"id": j["id"], "pos": p, "node": _client_node(j, p)})
			break


## A waiting client: its dungeon sprite with the creature finish and a shadow, facing the camera.
func _client_node(j: Dictionary, p: Vector2i) -> Node2D:
	var node := Node2D.new()
	_world.add_child(node)
	var shadow := Polygon2D.new()
	var pts := PackedVector2Array()
	for k in 12:
		pts.append(Vector2(cos(k * TAU / 12.0) * 8.0, sin(k * TAU / 12.0) * 3.0))
	shadow.polygon = pts
	shadow.color = Color(0, 0, 0, 0.3)
	node.add_child(shadow)
	var sprite := Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(sprite)
	preload("res://scripts/arena/creature_finish.gd").apply(sprite)
	var art := _load_art(Jobs.client_form(j))
	var tex: Texture2D = art["still"]["s"]
	sprite.texture = tex
	sprite.offset = Vector2(0, tex.get_height() * 0.5 - art["foot"].get(tex, float(tex.get_height())))
	node.position = _tile_px(p)
	node.z_index = int(node.position.y)
	return node


func _client_at(p: Vector2i) -> int:
	for k in clients.size():
		if clients[k]["pos"] == p:
			return k
	return -1


func _job(id: String) -> Dictionary:
	for j in jobs:
		if j["id"] == id:
			return j
	return {}


## Walking into a waiting client: it thanks the team (the scene box, with its portrait when it has
## one) and goes home to Highbank; the job is done and is paid at the board.
func _meet_client(k: int) -> void:
	var c: Dictionary = clients[k]
	var j := _job(c["id"])
	j["done"] = true
	clients.remove_at(k)
	var who := Jobs.client_name(j)
	_say("Found %s! Job done; the reward waits at the Job Board." % who)
	_sfx("recruit_rise", -4.0)
	talk.append([who, "You came all this way for me? Thank you. I can find the way up to Highbank from here.", Jobs.client_form(j)])
	var tw := create_tween()
	tw.tween_interval(0.2)
	tw.tween_property(c["node"], "modulate:a", 0.0, 0.6)
	tw.tween_callback(c["node"].queue_free)


func _floor_at(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < data["w"] and p.y < data["h"] and data["tiles"][p.y * data["w"] + p.x] == Gen.FLOOR and not pond.has_point(p)


func _occupant(p: Vector2i) -> int:
	for k in ents.size():
		if ents[k]["hp"] > 0 and ents[k]["pos"] == p:
			return k
	return -1


## A step from `from` in `d` is possible: open floor, and a diagonal may not cut a wall corner.
func can_step(from: Vector2i, d: Vector2i) -> bool:
	var to := from + d
	if not _floor_at(to) or _client_at(to) >= 0:
		return false
	if d.x != 0 and d.y != 0 and (not _floor_at(from + Vector2i(d.x, 0)) or not _floor_at(from + Vector2i(0, d.y))):
		return false
	return true


func _sees(a: Vector2i, b: Vector2i) -> bool:
	return _sees_r(a, b, SIGHT)


func _sees_r(a: Vector2i, b: Vector2i, reach: int) -> bool:
	if maxi(absi(a.x - b.x), absi(a.y - b.y)) > reach:
		return false
	var n: int = maxi(absi(a.x - b.x), absi(a.y - b.y))
	for k in range(1, n):
		var p := Vector2i(roundi(lerpf(a.x, b.x, float(k) / n)), roundi(lerpf(a.y, b.y, float(k) / n)))
		if not _floor_at(p):
			return false
	return true


func _cheb(a: Vector2i, b: Vector2i) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))


## One step toward `goal` around the walls, not onto anyone; ZERO when there is none.
## The step for creature i that brings it closest to goal, or ZERO. With through_team, a tile held
## by its own team counts as open (the leader swaps places with a partner in the way, never one
## behind it: swapping with whoever came first made the pair trade tiles forever in a hallway,
## Preston, 2026-10-09).
func _step_toward(i: int, goal: Vector2i, through_team := false) -> Vector2i:
	var from: Vector2i = ents[i]["pos"]
	if not _floor_at(goal) or not _floor_at(from):
		return Vector2i.ZERO   # no path to or from a tile that is not open floor
	var key: int = goal.y * data["w"] + goal.x
	if not _fields.has(key):
		if _fields.size() > 32:
			_fields.clear()
		_fields[key] = Gen.distances(data["tiles"], data["w"], data["h"], goal)
	var field: PackedInt32Array = _fields[key]
	var here: int = field[from.y * data["w"] + from.x]
	if here < 0:
		return Vector2i.ZERO
	var best := Vector2i.ZERO
	var best_d := here
	for d in DIRS:
		if not can_step(from, d):
			continue
		var q: Vector2i = from + d
		var dq: int = field[q.y * data["w"] + q.x]
		var o := _occupant(q)
		if dq < 0 or dq >= best_d or (o >= 0 and not (through_team and ents[o]["team"] == ents[i]["team"] and o != 0)):   # never through the leader
			continue
		best = d
		best_d = dq
	return best


# ---------------------------------------------------------------- creatures

func _make(line: int, stage: int, team: int, pos: Vector2i) -> Dictionary:
	var form: Array = line_data(line)["forms"][stage]
	var cdata: CreatureData = load(form[1])
	var kit: Dictionary = Arena.KITS[form[0]]
	var moves: Array[String] = []
	for m in moves_for(line, stage, level_of(line) if team == 0 else clampi(floor_n, 1, LEVEL_MAX)):
		moves.append(m)
	var hp := maxi(10, int(round(Arena.MAX_HP * (1.0 + Arena.STAGE_HP * stage) * kit.get("hp", 1.0) * HP_SCALE)))
	var essences: Array = [cdata.essence]
	if cdata.has_second_essence:
		essences.append(cdata.second_essence)
	var node := Node2D.new()
	_world.add_child(node)
	var shadow := Polygon2D.new()
	var pts := PackedVector2Array()
	for k in 12:
		pts.append(Vector2(cos(k * TAU / 12.0) * 8.0, sin(k * TAU / 12.0) * 3.0))
	shadow.polygon = pts
	shadow.color = Color(0, 0, 0, 0.3)
	node.add_child(shadow)
	var sprite := Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(sprite)
	# Codex's Hollowtide Sprite finish (2026-10-08): the near-black outline and edge repair every
	# creature wears in the arena, worn in the dungeon too (Preston, 2026-10-09).
	preload("res://scripts/arena/creature_finish.gd").apply(sprite)
	var key := "%d:%d" % [line, stage]
	if team == 0 and taught.has(key):
		moves.clear()
		for m in taught[key]:
			moves.append(m)   # what a scroll taught it stays across floors
	var cds := {}
	for m in moves:
		cds[m] = 0
	if team == 0 and not growth.has(key):
		growth[key] = {"kos": 0, "floors": 0, "flank": 0, "ambush": 0, "took": 0, "slam": 0, "healed": 0}
	var base_hp := hp
	if team == 0:
		hp = _hp_at_level(base_hp, level_of(line))
	if form[0] in FOOTPRINT_SHADOW:
		shadow.color = Color(0, 0, 0, 0.34)
	return {"line": line, "stage": stage, "form": form[0], "name": cdata.creature_name, "team": team, "pos": pos,
		"facing": "s", "hp": hp, "max_hp": hp, "base_hp": base_hp, "moves": moves, "cds": cds, "essences": essences, "awake": true,
		"node": node, "sprite": sprite, "art": _load_art(form[0]), "walk_t": 0.0, "flash": 0.0, "warn": ""}


## Ground lines set by eye where the lowest solid row is not the feet (Preston, 2026-10-10: Troughspine's
## back view floated). Its tail hangs below its legs from behind, so the tail tip used to stand on the
## ground. "form/set" -> {facing: the row its feet stand on}; walk and action frames move with it.
## Lines that fight only in the dungeon (Claude, 2026-10-10): the rival crew, numbered from 100 so the
## arena's LINES (and everything that loops over it) never meets them. Later stages join with their art.
const Lines := preload("res://scripts/creatures/lines.gd")
const CREW_LINES := Lines.EXTRA   # the lines made for the dungeon and the story (scripts/creatures/lines.gd)


static func line_data(line: int) -> Dictionary:
	return CREW_LINES[line] if CREW_LINES.has(line) else Arena.LINES[line]


const FOOT_FIX := {"troughspine/dungeon": {"n": 31, "nw": 31, "ne": 31}}   # the diagonals too (Preston, same day)
## Long, low bodies get a shadow fitted to the whole body in each pose (Preston, 2026-10-10:
## Troughspine "needs shadow", then "looks like it's standing on hind legs" with the shadow only at its
## feet). A lizard lying flat shades the ground under all of it, so the oval is sized from the pose's
## outline and centred a little in front of the body's middle.
const FOOTPRINT_SHADOW := ["troughspine"]
var _shadow_fit := {}


func _load_art(folder: String, want := "dungeon") -> Dictionary:
	# The dungeon set: one size per stage (tools/arena/build_dungeon_set.py, Preston 2026-10-09);
	# the arena's tuned small set when a creature has none yet. `want` asks for a bigger set: "boss"
	# for the boss, "escort" for its escort (Preston, 2026-10-10: bosses tower, as in Mystery Dungeon).
	var set := want if ResourceLoader.exists("res://assets/sprites/arena/%s/%s/s.png" % [folder, want]) else ("dungeon" if ResourceLoader.exists("res://assets/sprites/arena/%s/dungeon/s.png" % folder) else "small")
	var still := {}
	var walk := {}
	var foot := {}
	for f in Arena.FACINGS:
		still[f] = load("res://assets/sprites/arena/%s/%s/%s.png" % [folder, set, f])
		foot[still[f]] = _foot_row(still[f])
		var frames: Array[Texture2D] = []
		for i in 8:
			var p := "res://assets/sprites/arena/%s/%s/walk_%s_f%d.png" % [folder, set, f, i]
			if ResourceLoader.exists(p):
				frames.append(load(p))
		var rows: Array[float] = []
		for tex in frames:
			rows.append(_foot_row(tex))
		rows.sort()
		var planted := 0.0
		if not rows.is_empty():
			var median: float = rows[rows.size() / 2]
			for r in rows:
				if r <= median + 4.0:
					planted = maxf(planted, r)
		for tex in frames:
			foot[tex] = planted
		var fix: Dictionary = FOOT_FIX.get("%s/%s" % [folder, set], {})
		if fix.has(f):
			var lift: float = foot[still[f]] - float(fix[f])
			foot[still[f]] = float(fix[f])
			for tex in frames:
				foot[tex] -= lift
		walk[f] = frames
	var acts := {}
	for act in ["attack", "hurt", "sleep"]:
		var by_facing := {}
		for f in Arena.FACINGS:
			var got: Array[Texture2D] = []
			for i in 8:
				var p := "res://assets/sprites/arena/%s/%s/%s_%s_f%d.png" % [folder, set, act, f, i]
				if ResourceLoader.exists(p):
					got.append(load(p))
			for tex in got:
				foot[tex] = foot[still[f]]   # the same ground line as its still, so an action never hops
			if not got.is_empty():
				by_facing[f] = got
		if not by_facing.is_empty():
			acts[act] = by_facing
	return {"still": still, "walk": walk, "foot": foot, "acts": acts}


func _foot_row(tex: Texture2D) -> float:
	var img: Image = tex.get_image()
	for y in range(img.get_height() - 1, -1, -1):
		var n := 0
		for x in img.get_width():
			if img.get_pixel(x, y).a > 0.1:
				n += 1
		if n >= 4:
			return float(y + 1)
	return float(img.get_height())


func _tile_px(p: Vector2i) -> Vector2:
	return Vector2(p) * T + Vector2(T * 0.5, T * 0.78)


func _place(e: Dictionary) -> void:
	# A step still sliding would put the creature back where it was on its last frame (a warp
	# trap sprung on a step did exactly that): stop it first.
	if e.get("tw") is Tween and e["tw"].is_valid():
		e["tw"].kill()
	e["node"].position = _tile_px(e["pos"])
	e["node"].z_index = int(e["node"].position.y)
	_set_tex(e, e["art"]["still"][e["facing"]])


func _set_tex(e: Dictionary, tex: Texture2D) -> void:
	var s: Sprite2D = e["sprite"]
	s.texture = tex
	var foot: float = e["art"]["foot"].get(tex, float(tex.get_height()))
	s.offset = Vector2(0, tex.get_height() * 0.5 - foot)
	if e["form"] in FOOTPRINT_SHADOW:
		_fit_shadow(e, tex, foot)


## The footprint shadow for this pose: centre and size from the opaque outline (cached per frame).
## A sprite pixel row r sits at y = r - foot on the creature's node, column c at x = c - width / 2.
func _fit_shadow(e: Dictionary, tex: Texture2D, foot: float) -> void:
	if not _shadow_fit.has(tex):
		var used: Rect2i = tex.get_image().get_used_rect()
		var c := Vector2(used.position) + Vector2(used.size) * 0.5
		var at := Vector2(c.x - tex.get_width() * 0.5, (c.y - foot) * 0.5 + 2.0)
		var radii := Vector2(used.size.x * 0.45, maxf(3.0, used.size.y * 0.28))
		_shadow_fit[tex] = [at, radii / Vector2(8.0, 3.0)]   # the base oval is 8 by 3
	var shadow: Node2D = e["node"].get_child(0)
	shadow.position = _shadow_fit[tex][0]
	shadow.scale = _shadow_fit[tex][1]


func _facing_of(d: Vector2i) -> String:
	return Arena.FACINGS[int(round(fposmod(Vector2(d).angle(), TAU) / (TAU / 8.0))) % 8]


func _dir_of(facing: String) -> Vector2i:
	return DIRS[Arena.FACINGS.find(facing)]


## Whether j is a live enemy of i. A beaten creature asking to join is nobody's target: hit again
## while it asked, it fainted, its tile emptied, and a yes revived it under another creature
## (found 2026-10-09 by dungeon_check's overlap count).
func _foes(i: int, j: int) -> bool:
	return ents[i]["team"] != ents[j]["team"] and ents[j]["hp"] > 0 and j != asking


# ---------------------------------------------------------------- moves

## How a move reaches on the grid, from its arena telegraph: a front tile, a dash along a line,
## a shot down a line, or a burst on a target in sight and the tiles round it.
static func move_reach(m: String) -> Dictionary:
	var mv: Dictionary = Arena.MOVES[m]
	var tiles: int = clampi(int(round(mv["range"] / T)), 1, 8)
	var kind: String = Arena.TELEGRAPH[m][0] if Arena.TELEGRAPH.has(m) else ("dash" if mv.get("mobility", false) else ("front" if mv["range"] <= 34.0 else "line"))
	match kind:
		"melee":
			return {"kind": "front", "n": 1}
		"charge":
			return {"kind": "dash", "n": clampi(tiles, 2, 6)}
		"area":
			return {"kind": "burst", "n": clampi(tiles, 2, 6)}
		"line", "rail":
			return {"kind": "line", "n": clampi(tiles, 2, 8)}
	return {"kind": kind, "n": clampi(tiles, 1, 6)}


## Who move m from creature i facing d would hit first ([-1] when nobody), and where i ends up.
func move_hits(i: int, m: String, d: Vector2i) -> Dictionary:
	var e: Dictionary = ents[i]
	var r := move_reach(m)
	var p: Vector2i = e["pos"]
	match r["kind"]:
		"front":
			if can_step(p, d) or _floor_at(p + d):
				var o := _occupant(p + d)
				if o >= 0 and _foes(i, o) and can_step(p, d) == true or (o >= 0 and _foes(i, o) and (d.x == 0 or d.y == 0)):
					return {"hits": [o], "end": p}
			return {"hits": [], "end": p}
		"dash":
			var at := p
			for k in r["n"]:
				if not can_step(at, d):
					break
				var o := _occupant(at + d)
				if o >= 0:
					return {"hits": [o] if _foes(i, o) else [], "end": at}
				at += d
			return {"hits": [], "end": at}
		"line":
			var at := p
			for k in r["n"]:
				if not _floor_at(at + d):
					break
				at += d
				var o := _occupant(at)
				if o >= 0 and _foes(i, o):
					return {"hits": [o], "end": p}
			return {"hits": [], "end": p}
		"burst":
			# The nearest enemy in sight within reach, along this facing's half of the room, and its neighbours.
			var best := -1
			for j in ents.size():
				if _foes(i, j) and _cheb(p, ents[j]["pos"]) <= r["n"] and _sees(p, ents[j]["pos"]) and Vector2(ents[j]["pos"] - p).dot(Vector2(d)) > 0.0:
					if best < 0 or _cheb(p, ents[j]["pos"]) < _cheb(p, ents[best]["pos"]):
						best = j
			if best < 0:
				return {"hits": [], "end": p}
			var hits: Array = [best]
			for j in ents.size():
				if j != best and _foes(i, j) and _cheb(ents[j]["pos"], ents[best]["pos"]) <= 1:
					hits.append(j)
			return {"hits": hits, "end": p}
	return {"hits": [], "end": p}


## The tiles move m from creature i facing d covers: the next tile, the run of a dash or a shot,
## or the burst's target tile and the tiles round it. This is what a warning marks.
func move_tiles(i: int, m: String, d: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var p: Vector2i = ents[i]["pos"]
	var r := move_reach(m)
	match r["kind"]:
		"front":
			out.append(p + d)
		"dash", "line":
			var at := p
			for k in r["n"]:
				if not (can_step(at, d) if r["kind"] == "dash" else _floor_at(at + d)):
					break
				at += d
				out.append(at)
		"burst":
			var hits: Array = move_hits(i, m, d)["hits"]
			if not hits.is_empty():
				var c: Vector2i = ents[hits[0]]["pos"]
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						if _floor_at(c + Vector2i(dx, dy)):
							out.append(c + Vector2i(dx, dy))
	return out


## The best direction for move m from creature i (the aiming help: a move turns to an enemy it can reach).
## Ranked, not first-found (Claude, 2026-10-10; Preston: "fix aiming system using synthesis"). Structure
## from Rescue Team DX (a move turns to the nearest foe) and Explorers of Sky (your facing is your aim):
##   1. the current facing, when it hits someone: Shift-turning to a foe always wins;
##   2. the foe this creature last hit, while it is still in reach (no flipping between two foes);
##   3. the nearest foe, then the facing that hits more of them, then the smallest turn from now.
func aim(i: int, m: String) -> Vector2i:
	var cur := _dir_of(ents[i]["facing"])
	if not move_hits(i, m, cur)["hits"].is_empty():
		return cur
	var mark := _marked(i)
	var best := Vector2i.ZERO
	var best_score := INF
	for d in DIRS:
		var hits: Array = move_hits(i, m, d)["hits"]
		if hits.is_empty():
			continue
		var score := _cheb(ents[i]["pos"], ents[hits[0]]["pos"]) * 10.0 - hits.size() * 3.0
		score += absf(angle_difference(Vector2(cur).angle(), Vector2(d).angle()))
		if mark >= 0 and hits.has(mark):
			score -= 1000.0
		if score < best_score:
			best_score = score
			best = d
	return best


## The foe creature i last hit, as an index into ents (-1 when none, or it is gone or down).
## Kept by node, not index: the list changes as creatures join and fall.
func _marked(i: int) -> int:
	var node: Variant = ents[i].get("target_node")
	if node == null or not is_instance_valid(node):
		return -1
	for j in ents.size():
		if ents[j]["node"] == node and ents[j]["hp"] > 0 and _foes(i, j):
			return j
	return -1


## Who the leader's basic attack would hit right now, with the aiming help (-1 when nobody).
func aim_target() -> int:
	if ents.is_empty() or ents[0]["hp"] <= 0:
		return -1
	var m: String = ents[0]["moves"][0]
	var d := aim(0, m)
	if d == Vector2i.ZERO:
		return -1
	var hits: Array = move_hits(0, m, d)["hits"]
	return -1 if hits.is_empty() else int(hits[0])


func damage(i: int, j: int, m: String) -> int:
	var e: Dictionary = ents[i]
	var ess: int = Arena.MOVE_ESSENCE.get(m, e["essences"][0])
	var mult := 1.0
	for d in ents[j]["essences"]:
		mult *= Arena.ARENA_CHART.get([ess, d], 1.0)
	var base: float = Arena.MOVES[m]["damage"] * (1.0 + Arena.STAGE_POWER * e["stage"]) * DMG_SCALE * mult * ((BOSS_DMG if e.get("boss", false) else WILD_DMG) if e["team"] == 1 else 1.0)
	return maxi(1, int(round(base * randf_range(0.9, 1.1))))


func _mult(i: int, j: int, m: String) -> float:
	var ess: int = Arena.MOVE_ESSENCE.get(m, ents[i]["essences"][0])
	var mult := 1.0
	for d in ents[j]["essences"]:
		mult *= Arena.ARENA_CHART.get([ess, d], 1.0)
	return mult


func _turns_of(m: String, i: int) -> int:
	if m == ents[i]["moves"][0]:
		return 0
	return maxi(1, int(ceil(Arena.MOVES[m]["cooldown"])))


# ---------------------------------------------------------------- one action

## Creature i takes move m toward d. Plays out on screen; returns false when nothing happened.
func use_move(i: int, m: String, d: Vector2i) -> bool:
	var e: Dictionary = ents[i]
	if Arena.MOVES[m].get("heal", 0) > 0:
		return await _seep(i, m)
	var res := move_hits(i, m, d)
	if not res["hits"].is_empty():
		e["target_node"] = ents[res["hits"][0]]["node"]   # aim() keeps to this foe while it is in reach
	e["facing"] = _facing_of(d)
	_set_tex(e, e["art"]["still"][e["facing"]])
	e["cds"][m] = _turns_of(m, i)
	_say("%s used %s!" % [e["name"], Arena.MOVES[m]["name"]])
	_callout(e, m)
	_play_act(e, "attack")
	_sfx("swing", -4.0)
	var r := move_reach(m)
	if r["kind"] == "dash" and res["end"] != e["pos"]:
		_trail(e, e["node"].position, _tile_px(res["end"]))
		e["pos"] = res["end"]
		await _slide(e, _tile_px(e["pos"])).finished
		e["node"].z_index = int(e["node"].position.y)
	var origin: Vector2 = _tile_px(e["pos"])
	var lunge: Vector2 = Vector2(d).normalized() * 6.0
	if e.get("tw") is Tween and e["tw"].is_valid():
		e["tw"].kill()
	var tw2 := create_tween()
	e["tw"] = tw2
	tw2.tween_property(e["node"], "position", origin + lunge, HIT_TIME * 0.4)
	tw2.tween_property(e["node"], "position", origin, HIT_TIME * 0.6)
	if r["kind"] in ["line", "burst"] and not res["hits"].is_empty():
		_launch(origin + Vector2(0, -10), ents[res["hits"][0]]["node"].position + Vector2(0, -10), m, r["kind"] == "burst", e)
	await get_tree().create_timer(HIT_TIME * 0.5).timeout
	if res["hits"].is_empty():
		_say("It missed.")
		_sfx("miss", -4.0)
	if i == 0 and not res["hits"].is_empty():
		focus = ents[res["hits"][0]]   # the team follows the leader's lead (Team Sense)
	for j in res["hits"]:
		_hit(i, j, m)
	if _heavy:
		_heavy = false
		await get_tree().create_timer(_stop).timeout   # the hit-stop
		_stop = 0.08
	if tw2.is_valid() and tw2.is_running():
		await tw2.finished   # (the hit-stop can outlast the lunge; waiting on a finished tween hung the dungeon, 2026-10-09)
	if r["kind"] == "dash" and not res["hits"].is_empty():
		await _shove(i, res["hits"][0], d)
	return true


## A wind-up lands on the tiles it marked last turn: a dash runs down them until something is in
## the way, a shot takes the first enemy on them, a burst takes every enemy on them. Whoever
## stepped out is missed.
func _fire_windup(i: int) -> void:
	var e: Dictionary = ents[i]
	var w: Dictionary = e["windup"]
	e.erase("windup")
	var m: String = w["m"]
	var d: Vector2i = w["d"]
	var tiles: Array = w["tiles"]
	var kind: String = move_reach(m)["kind"]
	var hits: Array = []
	_say("%s used %s!" % [e["name"], Arena.MOVES[m]["name"]])
	_callout(e, m)
	_play_act(e, "attack")
	_sfx("swing", -4.0)
	if kind == "dash":
		var end: Vector2i = e["pos"]
		for t in tiles:
			var o := _occupant(t)
			if o >= 0:
				if _foes(i, o):
					hits.append(o)
				break
			end = t
		if end != e["pos"]:
			_trail(e, e["node"].position, _tile_px(end))
			e["pos"] = end
			await _slide(e, _tile_px(end)).finished
	else:
		for t in tiles:
			var o := _occupant(t)
			if o >= 0 and _foes(i, o):
				hits.append(o)
				if kind == "line":
					break
	var origin: Vector2 = _tile_px(e["pos"])
	var tw := _slide(e, origin + Vector2(d).normalized() * 6.0)
	tw.tween_property(e["node"], "position", origin, HIT_TIME * 0.6)
	if kind in ["line", "burst"] and not tiles.is_empty():
		var aim_at: Vector2 = _tile_px(tiles[-1] if kind == "line" else tiles[tiles.size() / 2]) + Vector2(0, -10)
		if not hits.is_empty():
			aim_at = ents[hits[0]]["node"].position + Vector2(0, -10)
		_launch(origin + Vector2(0, -10), aim_at, m, kind == "burst", e)
	await get_tree().create_timer(HIT_TIME * 0.5).timeout
	if hits.is_empty():
		dodged += 1
		_say("It missed: nobody was where it struck.")
		_sfx("miss", -4.0)
	for j in hits:
		_hit(i, j, m)
	if _heavy:
		_heavy = false
		await get_tree().create_timer(0.08).timeout
	if tw.is_valid() and tw.is_running():
		await tw.finished
	if kind == "dash" and not hits.is_empty():
		await _shove(i, hits[0], d)


func _hit(i: int, j: int, m: String) -> void:
	var o: Dictionary = ents[j]
	var tags := position_tags(i, j)
	var bonus := 1.0
	for t in tags:
		bonus *= AMBUSH if t == "AMBUSH" else PINCER
	var dmg := maxi(1, int(round(damage(i, j, m) * bonus)))
	var mult := _mult(i, j, m)
	for k in tags.size():
		_pops.append({"pos": o["node"].position + Vector2(0, -38 - 9 * k), "text": tags[k] + "!", "t": 0.0, "col": Color(1, 0.6, 0.35)})
	if "PINCER" in tags and ents[i]["team"] == 0 and i != 0:
		pincers += 1
	if ents[i]["team"] == 0 and not tags.is_empty():
		_grow(ents[i], "flank", 1)
		if "AMBUSH" in tags:
			_grow(ents[i], "ambush", 1)
	var why := ""
	if "AMBUSH" in tags:
		why += " An ambush!"
	if "PINCER" in tags:
		why += " Caught in a pincer!"
	_say("%s took %d damage.%s%s" % [o["name"], dmg, " It's super effective!" if mult > 1.0 else (" It's not very effective." if mult < 1.0 else ""), why])
	_sfx("hit_super" if mult > 1.0 else ("hit_heavy" if not tags.is_empty() else "hit_light"), -4.0)
	var ess_sfx: String = ESSENCE_SFX.get(_ess_name(m, ents[i]), "")
	if ess_sfx != "" and MOVE_FX.get(m, {}).get("hit", "") != "light_slash":   # a plain claw or pounce is only the body's thump
		_sfx(ess_sfx, -8.0)
	_wound(i, j, dmg, Color(1, 0.95, 0.6) if mult > 1.0 else (Color(0.7, 0.75, 0.8) if mult < 1.0 else Color(1, 1, 1)))
	_crew_effects(i, j, m, dmg)
	var fx: String = MOVE_FX.get(m, {}).get("hit", "")
	if fx == "" and not MOVE_FX.get(m, {}).has("area"):
		fx = ESSENCE_FX.get(_ess_name(m, ents[i]), "")
	if fx != "":
		_vfx_at(fx, o["node"].position + Vector2(0, -10))
	var at: Vector2 = o["node"].position + Vector2(0, -12)
	var ecol: Color = ESSENCE_COL.get(_ess_name(m, ents[i]), Color(1, 0.95, 0.8))
	_burst(at, ecol, 14 if mult > 1.0 else 8, 70.0 if mult > 1.0 else 50.0, 0.35, 160.0, 2.0 if mult > 1.0 else 1.0)
	_ring(at, ecol if mult <= 1.0 else Color(1, 1, 1), 16.0 if mult > 1.0 else 10.0, 0.22)
	if mult > 1.0 or not tags.is_empty():
		_shake = maxf(_shake, 2.5)
		_flash = maxf(_flash, 0.12 if mult > 1.0 else 0.0)
		_heavy = true
		_stop = 0.13 if mult > 1.0 else 0.09
	else:
		_shake = maxf(_shake, 1.0)


## The essence name of move m used by e (for its fallback effect and colour).
func _ess_name(m: String, e: Dictionary) -> String:
	var ess: int = Arena.MOVE_ESSENCE.get(m, e["essences"][0])
	return CreatureData.Essence.keys()[ess] if ess >= 0 and ess < CreatureData.Essence.size() else ""


func _fx_sheet(name: String) -> Array:
	if not _fx_frames.has(name):
		var frames: Array[Texture2D] = []
		for k in 16:
			var path := "res://assets/sprites/arena/vfx/%s/f%02d.png" % [name, k]
			if ResourceLoader.exists(path):
				frames.append(load(path))
		_fx_frames[name] = frames
	return _fx_frames[name]


func _vfx_at(name: String, at: Vector2) -> void:
	if not _fx_sheet(name).is_empty():
		_vfx.append({"name": name, "pos": at, "t": 0.0, "dur": FX_SECONDS})


## A shot: the move's painted projectile flies to the target (the old dot when it has none), and a
## burst's area effect plays where it lands.
func _launch(from: Vector2, to: Vector2, m: String, burst: bool, e: Dictionary) -> void:
	var spec: Dictionary = MOVE_FX.get(m, {})
	if spec.has("proj") and not _fx_sheet(spec["proj"]).is_empty():
		_vfx.append({"name": spec["proj"], "pos": from, "to": to, "t": 0.0, "dur": 0.15})
	else:
		_shots.append({"from": from, "to": to, "t": 0.0, "burst": burst, "col": ESSENCE_COL.get(_ess_name(m, e), Color(1, 0.95, 0.7))})
	if spec.has("area"):
		_vfx.append({"name": spec["area"], "pos": to, "t": -0.12, "dur": FX_SECONDS})


## A dash leaves three fading afterimages along its path.
func _trail(e: Dictionary, from: Vector2, to: Vector2) -> void:
	var sp: Sprite2D = e["sprite"]
	for k in 3:
		_ghosts.append({"tex": sp.texture, "pos": from.lerp(to, k / 3.0) + sp.position, "t": -0.04 * k, "flip": sp.flip_h})


## Play an action animation once on creature e (attack, hurt), when its art has one.
func _play_act(e: Dictionary, name: String) -> void:
	if e["art"]["acts"].has(name):
		e["act"] = {"name": name, "t": 0.0}


## The move's name over the creature using it, as Rescue Team DX shows it (structure only), so a
## player reads who did what without the log. The basic attack stays quiet.
func _callout(e: Dictionary, m: String) -> void:
	if m == e["moves"][0]:
		return
	_pops.append({"pos": e["node"].position + Vector2(-float(Arena.MOVES[m]["name"].length()) * 2.5, -44), "text": Arena.MOVES[m]["name"] + "!", "t": 0.0, "col": Color(1, 1, 1) if e["team"] == 0 else Color(1, 0.75, 0.6)})


## Where the attacker stands decides the bonus: AMBUSH on a creature still asleep, PINCER when
## one of the attacker's team stands on the tile right behind the target, seen from the attacker.
## Both work against your team too.
func position_tags(i: int, j: int) -> Array[String]:
	var tags: Array[String] = []
	var o: Dictionary = ents[j]
	if o["team"] == 1 and not o["awake"]:
		tags.append("AMBUSH")
	var away: Vector2i = o["pos"] - ents[i]["pos"]
	var behind: Vector2i = o["pos"] + Vector2i(signi(away.x), signi(away.y))
	var k := _occupant(behind)
	if k >= 0 and k != i and ents[k]["team"] == ents[i]["team"]:
		tags.append("PINCER")
	return tags


## A charge shoves the creature it hits one tile further along. Open floor: it slides there. A wall
## or another creature: it SLAMS, losing a share of its health and its next turn, and anything it
## was gathering is broken; a creature it slams into takes the same knock.
func _shove(i: int, j: int, d: Vector2i) -> void:
	var o: Dictionary = ents[j]
	if o["hp"] <= 0 or j == asking:
		return
	if o.has("seep"):
		_say("%s is rooted to its spring and doesn't budge!" % o["name"])
		_sfx("denied", -4.0)
		return
	if o.get("boss", false):
		# A boss does not budge, but a charge into it while it gathers still breaks the move.
		if o.has("windup"):
			_say("Its %s was broken!" % Arena.MOVES[o["windup"]["m"]]["name"])
			_sfx("part_break", -3.0)
			_pops.append({"pos": o["node"].position + Vector2(0, -50), "text": "BROKEN!", "t": 0.0, "col": Color(1, 0.8, 0.3)})
			o.erase("windup")
		else:
			_say("%s doesn't budge!" % o["name"])
			_sfx("denied", -4.0)
		return
	var to: Vector2i = o["pos"] + d
	var into := _occupant(to)
	if can_step(o["pos"], d) and into < 0:
		o["pos"] = to
		_say("%s was knocked back!" % o["name"])
		_sfx("shove", -4.0)
		await _slide(o, _tile_px(to)).finished
		o["node"].z_index = int(o["node"].position.y)
		return
	var at: Vector2 = _tile_px(o["pos"])
	var tw := _slide(o, at + Vector2(d) * 5.0)
	tw.tween_property(o["node"], "position", at, HIT_TIME * 0.5)
	_pops.append({"pos": o["node"].position + Vector2(0, -38), "text": "SLAM!", "t": 0.0, "col": Color(1, 0.45, 0.3)})
	_say("%s slammed into %s!" % [o["name"], ents[into]["name"] if into >= 0 else "the wall"])
	_vfx_at("slam_shock", o["node"].position + Vector2(d) * 8.0)
	_vfx_at("rock_dust", o["node"].position + Vector2(d) * 10.0 + Vector2(0, 4))
	_shake = maxf(_shake, 3.5)
	_sfx("slam", -1.0)
	if o.has("windup"):
		_say("Its %s was broken!" % Arena.MOVES[o["windup"]["m"]]["name"])
		_sfx("part_break", -3.0)
		o.erase("windup")
	o["stagger"] = SLAM_STAGGER
	if ents[i]["team"] == 0:
		_grow(ents[i], "slam", 1)
	_wound(i, j, maxi(2, int(round(o["max_hp"] * SLAM_SHARE))), Color(1, 0.55, 0.4))
	if into >= 0 and into != i:
		_wound(i, into, maxi(2, int(round(ents[into]["max_hp"] * SLAM_SHARE))), Color(1, 0.55, 0.4))
	await tw.finished


## Creature j loses dmg health to creature i: the number, the flash, waking, fainting and the
## chance a beaten wild creature asks to join.
func _wound(i: int, j: int, dmg: int, col: Color) -> void:
	var o: Dictionary = ents[j]
	if o["team"] == 0:
		_grow(o, "took", mini(dmg, o["hp"]))
	o["hp"] = maxi(0, o["hp"] - dmg)
	o["flash"] = 0.25
	if o["hp"] > 0:
		_play_act(o, "hurt")
	if o["team"] == 1 and not o["awake"] and o["hp"] > 0:
		_sfx("wake", -4.0)
	o["awake"] = true
	if j == 0 and i >= 0 and ents[i]["team"] == 1 and (focus.is_empty() or focus["hp"] <= 0):
		focus = ents[i]   # whoever hits the leader becomes the team's target
	_pops.append({"pos": o["node"].position + Vector2(0, -26), "text": str(dmg), "t": 0.0, "col": col})
	if o["hp"] <= 0:
		_burst(o["node"].position + Vector2(0, -4), Color(0.75, 0.72, 0.66), 12, 28.0, 0.6, -20.0, 1.0)   # a puff of dust
		o.erase("windup")
		_say("%s fainted!" % o["name"])
		_sfx("faint", -4.0)
		if o.get("boss", false):
			if not (boss_intro and boss_cfg().get("stone", false)):   # the Warden is not beaten: the stand-off (stone_scene.gd)
				_banner_show("VICTORY!", "%s is beaten" % o["name"], Color(1, 0.9, 0.4))
				Music.play(get_tree(), "")
				Music.jingle(get_tree(), "victory")
			_fade.color = Color(1, 1, 1, 0.85)   # the white flash as it falls (Rescue Team DX's boss finish)
			var flash := create_tween()
			flash.tween_property(_fade, "color:a", 0.0, 0.6)
			flash.tween_callback(func() -> void: _fade.color = Color(0, 0, 0, 0))
			if crew_scene_here():
				cutscene = true   # now, so no one takes another turn before the scene starts
				(func() -> void: CrewScene.after(self)).call_deferred()
			elif boss_intro and boss_cfg().get("stone", false):
				cutscene = true   # the stone rises from the Warden's pond (scripts/dungeon/stone_scene.gd)
				(func() -> void: StoneScene.after(self)).call_deferred()
			else:
				_finish_after_boss.call_deferred()
		if o["team"] == 1:
			_gain_exp(EXP_PER_KO + EXP_PER_STAGE * int(o["stage"]) + (EXP_BOSS if o.get("boss", false) else 0))
			if ents[i]["team"] == 0:
				_grow(ents[i], "kos", 1)
				_gain_iq(ents[i], IQ_PER_KO)
			light = minf(LIGHT_MAX, light + LIGHT_ON_KO)   # beating an opponent lights the floor (the Battle Pyramid)
			if ents[i]["team"] == 0 and asking < 0 and not o.get("boss", false) and randf() < (recruit_override if recruit_override >= 0.0 else RECRUIT_RATE.get(o["stage"], 0.05)):
				# It gets back up and asks to come along.
				asking = j
				o["hp"] = 1
				o["awake"] = false   # it waits for your answer and takes no turns
				o["flash"] = 0.0
				_pops.append({"pos": o["node"].position + Vector2(0, -30), "text": "?", "t": 0.0, "col": Color(1, 0.9, 0.5)})
				_say("%s got back up! It wants to come with you. (Y join / N leave)" % o["name"])
				_sfx("recruit_rise", -4.0)
				_play("res://assets/audio/sfx/ui/confirm.wav", -8.0)
				return
		if o.get("boss", false) and (crew_scene_here() or (boss_intro and boss_cfg().get("stone", false))):
			return   # Mirekit only plays dead, and the Warden only seems beaten: each stays on screen for its scene
		var tw := create_tween()
		tw.tween_property(o["node"], "modulate:a", 0.0, 0.35)


func _step(i: int, d: Vector2i) -> Tween:
	var e: Dictionary = ents[i]
	e["pos"] += d
	e["moved"] = true
	e["facing"] = _facing_of(d)
	e["walk_t"] = STEP_TIME
	return _slide(e, _tile_px(e["pos"]))


## Every movement of a creature's sprite goes through here: a new slide stops the one before it,
## so a held key never lets the last frame of the previous step pull the creature back a tile
## (Preston, 2026-10-09: "the creature is going back and forth").
func _slide(e: Dictionary, to: Vector2) -> Tween:
	if e.get("tw") is Tween and e["tw"].is_valid():
		e["tw"].kill()
	var tw := create_tween()
	tw.tween_property(e["node"], "position", to, STEP_TIME)
	e["tw"] = tw
	return tw


# ---------------------------------------------------------------- the player's actions

## The leader moves one tile in d: into an enemy it attacks (bump), into a partner it swaps places.
func act_move(d: Vector2i) -> void:
	if busy or asking >= 0 or d == Vector2i.ZERO or ents.is_empty() or ents[0]["hp"] <= 0:
		return
	var lead: Dictionary = ents[0]
	if lead.get("stagger", 0) > 0:
		await _player_turn(func() -> bool: return true)   # _player_turn spends the turn reeling
		return
	if lead.get("snared", 0) > 0:
		_say("%s struggles in the snare." % lead["name"])
		_sfx("snare_struggle", -4.0)
		await _player_turn(func() -> bool: return true)
		return
	var ci := _client_at(lead["pos"] + d)
	if ci >= 0:
		lead["facing"] = _facing_of(d)
		_set_tex(lead, lead["art"]["still"][lead["facing"]])
		_meet_client(ci)
		return
	if not can_step(lead["pos"], d):
		lead["facing"] = _facing_of(d)
		_set_tex(lead, lead["art"]["still"][lead["facing"]])
		return
	var o := _occupant(lead["pos"] + d)
	if o >= 0 and _foes(0, o):
		await _player_turn(func() -> bool: return await use_move(0, lead["moves"][0], d))
		return
	busy = true
	var tweens: Array = []
	if o >= 0:
		# Swap places with a partner.
		ents[o]["pos"] = lead["pos"]
		ents[o]["facing"] = _facing_of(-d)
		ents[o]["walk_t"] = STEP_TIME
		tweens.append(_slide(ents[o], _tile_px(ents[o]["pos"])))
	tweens.append(_step(0, d))
	await _world_turn(tweens)
	busy = false


func act_face(d: Vector2i) -> void:
	if busy or d == Vector2i.ZERO:
		return
	ents[0]["facing"] = _facing_of(d)
	_set_tex(ents[0], ents[0]["art"]["still"][ents[0]["facing"]])


## Turn the leader to the nearest foe it can see (a tap of Shift). Free, like any turn in place.
func act_face_nearest() -> void:
	if busy or ents.is_empty() or ents[0]["hp"] <= 0:
		return
	var p: Vector2i = ents[0]["pos"]
	var best := -1
	for j in ents.size():
		if _foes(0, j) and ents[j]["hp"] > 0 and visible_tiles.has(ents[j]["pos"]) and (best < 0 or _cheb(p, ents[j]["pos"]) < _cheb(p, ents[best]["pos"])):
			best = j
	if best >= 0:
		act_face(_dir_of(_facing_of(ents[best]["pos"] - p)))


## Slot 0 is the basic attack, 1 to 3 the moves. A move with nobody in reach is refused and
## costs nothing; a move that can reach one enemy turns to it.
func act_attack(slot: int) -> void:
	if busy or asking >= 0 or ents.is_empty() or ents[0]["hp"] <= 0 or slot >= ents[0]["moves"].size():
		return
	var lead: Dictionary = ents[0]
	var m: String = lead["moves"][slot]
	if lead["cds"][m] > 0:
		_say("%s needs %d more turn%s." % [Arena.MOVES[m]["name"], lead["cds"][m], "" if lead["cds"][m] == 1 else "s"])
		_sfx("denied", -4.0)
		return
	var d := aim(0, m)
	if Arena.MOVES[m].get("heal", 0) > 0:
		d = _dir_of(lead["facing"])   # a heal needs no target
	if d == Vector2i.ZERO:
		if slot == 0:
			d = _dir_of(lead["facing"])   # a basic swing into the air still takes the turn, like a swing
		else:
			_say("Nothing in reach for %s." % Arena.MOVES[m]["name"])
			_sfx("denied", -4.0)
			return
	await _player_turn(func() -> bool: return await use_move(0, m, d))


func act_rest() -> void:
	if busy or asking >= 0:
		return
	await _player_turn(func() -> bool: return true)


func act_stairs() -> void:
	if busy or _finishing or ents.is_empty() or ents[0]["pos"] != data["stairs"]:
		return
	if boss_alive():
		_say("The stairs are sealed while %s stands." % ents[boss]["name"])
		_sfx("denied", -4.0)
		return
	busy = true
	_sfx("stairs", -2.0)
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 1.0, 0.3)
	await tw.finished
	floor_n += 1
	for e in ents:
		if e["team"] == 0 and e["hp"] > 0:
			_grow(e, "floors", 1)
			_gain_iq(e, IQ_PER_FLOOR)
	if floor_n > floors() + 1:
		cleared += 1
		floor_n = 1
		light = LIGHT_MAX
		_party_at_start = party.duplicate(true)   # the run's recruits are yours now
		_roster_at_start = roster.duplicate(true)
		_say("%s is cleared! The bag and the new partners are kept." % DUNGEONS[dungeon]["name"])
	floor_seed = randi()
	_build_floor(floor_n == 1)   # Preston, 2026-10-09: health carries between floors; only a new run starts fresh (this read "!=" before, so every floor healed)
	tw = create_tween()
	tw.tween_property(_fade, "color:a", 0.0, 0.3)
	await tw.finished
	busy = false


## Hand the fight to the arena engine: your whole team, and every wild creature awake within
## reach of the leader (or asleep in the leader's room), from where they stand with the health
## they have. The arena draws the same floor picture, so nothing jumps.
func _start_battle() -> void:
	if _battle != null or ents.is_empty():
		return
	var lead_pos: Vector2i = ents[0]["pos"]
	var room := Rect2i()
	for r in data["rooms"]:
		if r.grow(1).has_point(lead_pos):
			room = r.grow(1)
	var sides := [[], []]
	var ids := [[], []]
	for k in ents.size():
		var e: Dictionary = ents[k]
		if e["hp"] <= 0:
			continue
		if e["team"] == 1:
			var near: bool = e["awake"] and _cheb(e["pos"], lead_pos) <= BATTLE_JOIN
			var roommate: bool = room.size != Vector2i.ZERO and room.has_point(e["pos"])
			if not (near or roommate):
				continue
			e["awake"] = true
		e.erase("windup")
		sides[e["team"]].append({"line": e["line"], "stage": e["stage"], "px": _tile_px(e["pos"]),
			"frac": float(e["hp"]) / e["max_hp"], "facing": e["facing"]})
		ids[e["team"]].append(k)
	if sides[1].is_empty():
		in_battle = false
		return
	var b: Node2D = load(BATTLE_SCENE).instantiate()
	b.battle_mode = true
	b.tile = T
	b._data = {"w": data["w"], "h": data["h"], "tiles": data["tiles"], "stairs": Vector2i(-99, -99), "start": lead_pos, "spawns": [], "rooms": data["rooms"]}
	b.given_texture = _map.texture
	b.spec = sides
	b.party = []
	b.control_slot = 0
	b.poll_input = poll_input
	b.auto_you = autopilot
	_battle_ids = ids[0] + ids[1]
	_battle = b
	_battle_t = 0.0
	_flee_t = 0.0
	battles += 1
	_say("A battle! %d wild creature%s." % [sides[1].size(), "" if sides[1].size() == 1 else "s"])
	_screen.visible = false
	_hud_layer.visible = false
	add_child(b)
	b.match_over.connect(_end_battle)


## The fight is over (or you ran): everyone goes back on the grid at the tile nearest where they
## stood, with the health they kept. Downed wild creatures may ask to join, as in a turn fight.
func _end_battle(winner: int) -> void:
	if _battle == null:
		return
	var b: Node2D = _battle
	_battle = null
	var taken := {}
	var downed: Array = []
	for n in mini(b._fighters.size(), _battle_ids.size()):
		var f: Dictionary = b._fighters[n]
		var k: int = _battle_ids[n]
		var e: Dictionary = ents[k]
		var frac: float = float(maxi(0, f["hp"])) / maxf(1.0, f["max_hp"])
		e["hp"] = 0 if f["hp"] <= 0 else maxi(1, int(round(e["max_hp"] * frac)))
		e["facing"] = f["facing"]
		if e["hp"] > 0:
			e["pos"] = _snap(f["body"].position, taken)
			taken[e["pos"]] = true
		elif e["team"] == 1:
			downed.append(k)
		for m in e["cds"]:
			e["cds"][m] = 0
	var seconds := _battle_t
	turn += int(seconds / BATTLE_SECONDS_PER_TURN)
	light = maxf(0.0, light - seconds / BATTLE_SECONDS_PER_TURN / LIGHT_DRAIN_EVERY)
	for k in downed:
		light = minf(LIGHT_MAX, light + LIGHT_ON_KO)
		ents[k]["node"].modulate.a = 0.0
	b.queue_free()
	_screen.visible = true
	_hud_layer.visible = true
	in_battle = false
	for e in ents:
		_place(e)
		e["node"].modulate.a = 1.0 if e["hp"] > 0 else 0.0
	_reveal()
	if winner == 0:
		_say("The battle is won! (%d s)" % int(seconds))
	elif winner == 1:
		_say("%s is down." % ents[0]["name"])
	else:
		_say("You got away.")
		_sfx("escape", -4.0)
	# A beaten wild creature may get up and ask to join.
	if winner == 0 and asking < 0:
		for k in downed:
			if randf() < (recruit_override if recruit_override >= 0.0 else RECRUIT_RATE.get(ents[k]["stage"], 0.05)):
				asking = k
				ents[k]["hp"] = 1
				ents[k]["awake"] = false
				ents[k]["node"].modulate.a = 1.0
				_say("%s got back up! It wants to come with you. (Y join / N leave)" % ents[k]["name"])
				_sfx("recruit_rise", -4.0)
				break
	if ents[0]["hp"] <= 0:
		_end_turn()   # the faint rules


## The nearest open floor tile to a point, not one already taken.
func _snap(px: Vector2, taken: Dictionary) -> Vector2i:
	var t0 := Vector2i(floori(px.x / T), floori(px.y / T))
	for r in range(0, 6):
		var best := Vector2i(-1, -1)
		var best_d := INF
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				var q := t0 + Vector2i(dx, dy)
				if _floor_at(q) and not taken.has(q) and (Vector2(q) * T + Vector2(T, T) * 0.5).distance_to(px) < best_d:
					best = q
					best_d = (Vector2(q) * T + Vector2(T, T) * 0.5).distance_to(px)
		if best.x >= 0:
			return best
	return data["start"]


## While a battle runs: count its length, and end it if your leader has run far from every foe.
func _watch_battle(delta: float) -> void:
	if _battle == null or _battle._fighters.is_empty() or _battle._winner >= 0:
		return
	_battle_t += delta
	var lead: Dictionary = _battle._fighters[0]
	var far := true
	for f in _battle._fighters:
		if f["team"] == 1 and f["hp"] > 0 and f["body"].position.distance_to(lead["body"].position) < FLEE_TILES * T:
			far = false
	_flee_t = _flee_t + delta if far else 0.0
	if _flee_t >= FLEE_SECONDS:
		_end_battle(-1)


## Your answer to a creature asking to join. Answering costs no turn.
func act_recruit(accept: bool) -> void:
	if asking < 0 or asking >= ents.size():
		asking = -1
		return
	var o: Dictionary = ents[asking]
	asking = -1
	if not accept:
		o["hp"] = 0
		_say("%s goes back into the hollow." % o["name"])
		_sfx("hollow_fade", -4.0)
		create_tween().tween_property(o["node"], "modulate:a", 0.0, 0.35)
		return
	var team_now := 0
	for e in ents:
		if e["team"] == 0:
			team_now += 1   # a fainted partner still holds its place (the team went to 5 before, 2026-10-09)
	if team_now >= TEAM_MAX:
		# No room on this run: it waits at the courier hall once the run is cleared.
		o["hp"] = 0
		o["node"].visible = false
		roster.append([o["line"], o["stage"]])
		_say("The team is full. %s will wait at the courier hall." % o["name"])
	else:
		o["team"] = 0
		o["awake"] = true
		o["hp"] = maxi(1, o["max_hp"] / 2)
		o["node"].modulate.a = 1.0
		for m in o["cds"]:
			o["cds"][m] = 0
		party.append([o["line"], o["stage"]])
		if not levels.has(o["line"]):
			levels[o["line"]] = {"lv": clampi(floor_n, 1, LEVEL_MAX), "exp": 0}
		var rkey := "%d:%d" % [o["line"], o["stage"]]
		if taught.has(rkey):
			o["moves"].clear()
			o["cds"].clear()
			for m in taught[rkey]:
				o["moves"].append(m)
				o["cds"][m] = 0
		else:
			_store_moves(o)
		_say("%s joined the team!" % o["name"])
		Music.jingle(get_tree(), "recruit")
	_play("res://assets/audio/sfx/ui/confirm.wav", -4.0)


func _player_turn(action: Callable) -> void:
	busy = true
	if ents[0].get("stagger", 0) > 0:
		ents[0]["stagger"] -= 1
		_say("%s is still reeling from the slam!" % ents[0]["name"])
		_sfx("dizzy", -4.0)
		await _world_turn([])
		busy = false
		return
	var ok: bool = await action.call()
	if ok:
		await _world_turn([])
	busy = false


# ---------------------------------------------------------------- everyone else's turn

## After the leader acts, every other creature takes one action: steps all happen together,
## attacks one after another (the order Explorers of Sky shows them in).
func _world_turn(lead_tweens: Array) -> void:
	turn += 1
	var tweens: Array = lead_tweens.duplicate()
	for i in range(1, ents.size()):
		var e: Dictionary = ents[i]
		if e["hp"] <= 0 or (e["team"] == 1 and not e["awake"]):
			continue
		if e.get("snared", 0) > 0:
			e.erase("windup")   # held fast, it loses the move it was gathering
			continue
		if e.get("stagger", 0) > 0:
			e["stagger"] -= 1   # slammed: it spends this turn getting its footing back
			continue
		if e.has("windup"):
			if not tweens.is_empty():
				await get_tree().create_timer(STEP_TIME).timeout
				tweens.clear()
			await _fire_windup(i)
			if ents[0]["hp"] <= 0:
				break
			continue
		var plan := _decide(i)
		if plan["kind"] == "windup":
			e["facing"] = _facing_of(plan["d"])
			_set_tex(e, e["art"]["still"][e["facing"]])
			e["windup"] = {"m": plan["m"], "d": plan["d"], "tiles": move_tiles(i, plan["m"], plan["d"])}
			e["cds"][plan["m"]] = _turns_of(plan["m"], i) + 1
			_say("%s is gathering itself for %s!" % [e["name"], Arena.MOVES[plan["m"]]["name"]])
			_sfx("windup", -6.0)
			continue
		if plan["kind"] == "eat":
			_take("reedberry")
			var heal: int = mini(15, e["max_hp"] - e["hp"])
			e["hp"] += heal
			_say("%s ate a Reedberry from the bag: %d back. (Berry Sense)" % [e["name"], heal])
			_sfx("eat", -4.0)
			_pops.append({"pos": e["node"].position + Vector2(0, -26), "text": "+%d" % heal, "t": 0.0, "col": Color(0.5, 1, 0.5)})
			continue
		if plan["kind"] == "move":
			var into := _occupant(e["pos"] + plan["d"])
			if into >= 0 and ents[into]["team"] == e["team"]:
				# Swap places with the teammate in the way.
				ents[into]["pos"] = e["pos"]
				ents[into]["facing"] = _facing_of(-plan["d"])
				ents[into]["walk_t"] = STEP_TIME
				tweens.append(_slide(ents[into], _tile_px(ents[into]["pos"])))
			tweens.append(_step(i, plan["d"]))
		elif plan["kind"] == "attack":
			if not tweens.is_empty():
				await get_tree().create_timer(STEP_TIME).timeout
				tweens.clear()
			await use_move(i, plan["m"], plan["d"])
			if ents[0]["hp"] <= 0:
				break
	if not tweens.is_empty():
		await get_tree().create_timer(STEP_TIME).timeout
	_end_turn()


func _decide(i: int) -> Dictionary:
	var e: Dictionary = ents[i]
	if e["team"] == 0 and i != 0:
		var smart := _iq_plan(i)
		if not smart.is_empty():
			return smart
	var heal_plan := _heal_plan(i)
	if not heal_plan.is_empty():
		return heal_plan
	if not (e["team"] == 0 and i == 0):
		var sense := _team_sense(i)
		if not sense.is_empty():
			return sense
	var t := _target(i)
	if t >= 0:
		var best := {}
		var best_score := 0.0
		var fj := _focus_index(i)
		for m in e["moves"]:
			if e["cds"][m] > 0 or Arena.MOVES[m].get("heal", 0) > 0:
				continue
			for d in DIRS:   # every facing, so a hit on the team's focus can win over the nearest
				var hits: Array = move_hits(i, m, d)["hits"]
				if hits.is_empty():
					continue
				var score := 0.0
				for j in hits:
					var bonus := 1.0
					for tag in position_tags(i, j):
						bonus *= AMBUSH if tag == "AMBUSH" else PINCER
					if j == fj:
						bonus *= FOCUS_BONUS
					score += Arena.MOVES[m]["damage"] * _mult(i, j, m) * bonus
					if has_iq(e, "finisher") and damage_guess(i, j, m) >= ents[j]["hp"]:
						score *= 1.5   # Finisher: a hit that downs it
				if m != e["moves"][0]:
					score *= 1.15   # a move over the basic when both reach (Kit Sense's lean, kept)
				if d == _dir_of(e["facing"]):
					score *= 1.01   # a tie keeps the current facing
				if score > best_score:
					best_score = score
					best = {"kind": "attack", "m": m, "d": d, "j": hits[0], "why": "focus" if hits[0] == fj else "best hit"}
		# No overkill: when the basic downs the target anyway, save the stronger move's cooldown.
		var basic: String = e["moves"][0]
		if not best.is_empty() and best["m"] != basic and e["cds"].get(basic, 0) == 0 and damage_guess(i, best["j"], basic) >= ents[best["j"]]["hp"]:
			for d in DIRS:
				if best["j"] in move_hits(i, basic, d)["hits"]:
					best = {"kind": "attack", "m": basic, "d": d, "j": best["j"], "why": "no overkill"}
					break
		if not best.is_empty() and e["team"] == 0 and not "PINCER" in position_tags(i, best["j"]):
			# A short walk round to a healthy foe's far side beats ordinary hits: every hit after is a PINCER.
			var q := pincer_tile(i, best["j"])
			var foe: Dictionary = ents[best["j"]]
			if q != Vector2i(-1, -1) and q != e["pos"] and _cheb(e["pos"], q) <= FLANK_REACH and foe["hp"] > foe["max_hp"] * FLANK_WORTH:
				var st := _step_toward(i, q)
				if st != Vector2i.ZERO:
					return {"kind": "move", "d": st}
		if not best.is_empty():
			if e["team"] == 1 and best["m"] != e["moves"][0] and move_reach(best["m"])["kind"] in WARN_KINDS:
				best["kind"] = "windup"   # a wild creature's strong move warns first
			return best
		var step := Vector2i.ZERO
		if e["team"] == 0:
			var flank := pincer_tile(i, t)
			if flank != e["pos"] and flank != Vector2i(-1, -1):
				step = _step_toward(i, flank)   # round to the far side of the foe
		if step == Vector2i.ZERO:
			step = _step_toward(i, ents[t]["pos"])
		if step != Vector2i.ZERO:
			return {"kind": "move", "d": step}
	if e["team"] == 0 and tactic == "guard" and _cheb(e["pos"], ents[0]["pos"]) > 1:
		var back := _step_toward(i, ents[0]["pos"], true)
		if back != Vector2i.ZERO:
			return {"kind": "move", "d": back}
	if e["team"] == 0:
		# A partner follows the one ahead of it in the chain.
		var ahead: int = 0
		for k in range(i - 1, -1, -1):
			if ents[k]["team"] == 0 and ents[k]["hp"] > 0:
				ahead = k
				break
		if _cheb(e["pos"], ents[ahead]["pos"]) > 1:
			# Through teammates: a recruit that joined in a hallway between a partner and the
			# leader blocked it, and both waited forever (Preston, 2026-10-09: "after the first
			# battle they stay there").
			var step := _step_toward(i, ents[ahead]["pos"], true)
			if step != Vector2i.ZERO:
				return {"kind": "move", "d": step}
	return {"kind": "wait"}


## The tile on the far side of foe t from one of i's teammates already beside it: standing there
## makes every hit a PINCER. (-1, -1) when there is none open; i's own tile when it is already there.
func pincer_tile(i: int, t: int) -> Vector2i:
	var best := Vector2i(-1, -1)
	var tp: Vector2i = ents[t]["pos"]
	for k in ents.size():
		if k == i or ents[k]["hp"] <= 0 or ents[k]["team"] != ents[i]["team"] or _cheb(ents[k]["pos"], tp) != 1:
			continue
		var away: Vector2i = tp - ents[k]["pos"]
		var q: Vector2i = tp + Vector2i(signi(away.x), signi(away.y))
		if q == ents[i]["pos"]:
			return q
		if not _floor_at(q) or _occupant(q) >= 0:
			continue
		if best == Vector2i(-1, -1) or _cheb(ents[i]["pos"], q) < _cheb(ents[i]["pos"], best):
			best = q
	return best


## Whether p is a room tile in front of a hallway opening (a floor tile just outside the room
## touches it): no trap there, so a hallway never ends on one.
func _by_opening(p: Vector2i, room: Rect2i) -> bool:
	for d in DIRS:
		var q: Vector2i = p + d
		if not room.has_point(q) and _floor_at(q):
			return true
	return false


## The floor's recipe: the usual Hollow on a normal floor; a fixed floor (rest, boss) has no wild, items or traps.
func recipe() -> Dictionary:
	if floor_kind() != "normal":
		return FIXED_RECIPE
	var r := RECIPE.duplicate()
	var sp: Dictionary = DUNGEONS[dungeon]["spawns"]
	r["spawns"] = sp.get(floor_n, sp[1])
	return r


func floor_kind() -> String:
	if floor_n == floors() + 1:
		return "boss"
	if floor_n == rest_floor:
		return "rest"
	return "normal"


## A fixed floor: one hand-set room that is the whole floor (the boss's arena, or a rest floor),
## the team arriving at the bottom and the stairs at the top.
func _fixed_floor(kind: String) -> Dictionary:
	var size: Vector2i = boss_cfg()["arena"] if kind == "boss" else REST_ROOM
	var w: int = size.x + 6
	var h: int = size.y + 6
	var tiles := PackedByteArray()
	tiles.resize(w * h)   # all wall
	var room := Rect2i(Vector2i(3, 3), size)
	for y in range(room.position.y, room.end.y):
		for x in range(room.position.x, room.end.x):
			tiles[y * w + x] = Gen.FLOOR
	var cx: int = room.position.x + size.x / 2
	return {"w": w, "h": h, "tiles": tiles, "rooms": [room], "start": Vector2i(cx, room.end.y - 2),
		"stairs": Vector2i(cx, room.position.y), "spawns": [], "links": []}


func boss_alive() -> bool:
	return boss >= 0 and boss < ents.size() and ents[boss]["hp"] > 0


## Back to Highbank, carrying the team's record (TeamState).
func _go_to_town(news: String) -> void:
	TeamState.take_from(self, news)
	if is_inside_tree() and get_tree().current_scene == self:
		var town: Node = load(TOWN_SCENE).instantiate()
		TeamState.give_to(town)
		get_tree().change_scene_to_node(town)
	else:
		set_meta("went_to_town", news)   # the checks read this instead of leaving the scene


## The floor's track (the music brief, docs/audio/music-brief-2026-10-09.md): the Hollow's theme; the
## deep one on the floor before the boss or when the lantern runs low; a rest floor's calm; the
## Monster House while one is sprung; on the boss floor the scene's dread, then the Guardian.
func music_track() -> String:
	if floor_kind() == "boss":
		return "" if boss >= 0 and boss_met and not boss_alive() else ("guardian" if boss_met else "boss_scene")
	if floor_kind() == "rest":
		return "rest_floor"
	if monster_sprung and not house_cleared:
		return "monster_house"
	if floor_n == floors() or light < 25.0:
		return "deep_hollow"
	return "hollow"


func _music_update() -> void:
	if ents.is_empty() or ents[0]["hp"] <= 0:
		return
	Music.play(get_tree(), music_track())


## Show the next line of the scene; when the last one is read, the fight starts.
func act_talk() -> void:
	if talk.is_empty():
		return
	if not UI.line_done(String(talk[0][1])):
		UI.finish_line()   # the first press shows the rest of the typed line, the next moves on
		return
	talk.pop_front()
	if talk.is_empty() and boss >= 0 and not boss_met and not cutscene:
		_meet_boss()


func _meet_boss() -> void:
	boss_met = true
	cam_focus = null   # the fight: the camera follows the leader again
	Music.play(get_tree(), "guardian")
	for e in ents:
		if e["team"] == 1 and (e.get("boss", false) or e.get("minion", false)):
			e["awake"] = true
	_banner_show(String(ents[boss]["name"]).to_upper(), "BOSS", Color(1, 0.35, 0.35))
	_play("res://assets/audio/sfx/ui/hit_strong.wav", -2.0)
	_sfx("boss_appear", -2.0)


## The boss and its helpers at the top of the arena, before the sealed stairs.
func _place_boss() -> void:
	for room in data["rooms"]:
		if room.has_point(data["stairs"]):
			boss_room = room
	var spots: Array[Vector2i] = []
	var where := [Vector2i(0, 3), Vector2i(-2, 3), Vector2i(2, 3)]
	if intro_here():   # the entrance lands the Warden in front of its pond, the Listeners to its sides
		where = [Vector2i(0, BossIntro.LAND_ROW), Vector2i(-3, BossIntro.LAND_ROW), Vector2i(3, BossIntro.LAND_ROW)]
	for d in where:
		var q: Vector2i = data["stairs"] + d
		if _floor_at(q) and _occupant(q) < 0:
			spots.append(q)
	var cfg := boss_cfg()
	var minions: Array = cfg["minions"]
	if spots.size() < 1 + minions.size():
		return
	var b := _make(cfg["line"][0], cfg["line"][1], 1, spots[0])
	b["max_hp"] = maxi(20, int(round(b["max_hp"] * WILD_HP * float(cfg["hp"]))))
	b["hp"] = b["max_hp"]
	b["awake"] = false
	b["boss"] = true
	b["facing"] = "s"
	_size_up(b, "boss", 1.9)
	ents.append(b)
	boss = ents.size() - 1
	for k in minions.size():
		var m := _make(minions[k][0], minions[k][1], 1, spots[1 + k])
		m["max_hp"] = maxi(6, int(round(m["max_hp"] * WILD_HP)))
		m["hp"] = m["max_hp"]
		m["awake"] = false
		m["minion"] = true
		m["facing"] = "s"
		_size_up(m, "escort", 1.35)
		ents.append(m)


## A boss or its escort wears its bigger set (built from the full-size art, so the pixels stay
## square) and a shadow to match.
func _size_up(e: Dictionary, set_name: String, k: float) -> void:
	e["art"] = _load_art(e["form"], set_name)
	# Its shadow covers the body's whole footprint (Preston, 2026-10-10: the Warden looked as if it
	# floated, its back half hanging, on tiptoe). Its front view is drawn nearly from above, frog-flat,
	# so the ground under it is the whole body, front toes to back legs, not a spot at the toes.
	var body: Texture2D = e["art"]["still"]["s"]
	var used: Rect2i = body.get_image().get_used_rect()
	var foot: float = e["art"]["foot"].get(body, float(body.get_height()))
	var body_h: float = foot - used.position.y        # from the top of the drawn body down to its feet
	var rx: float = used.size.x * 0.5
	var ry: float = body_h * 0.36
	var shadow: Node2D = e["node"].get_child(0)
	shadow.scale = Vector2(maxf(k, rx / 8.0), ry / 3.0)   # the plain shadow is an 8 by 3 oval
	shadow.position.y = -ry + 3.0                          # the toes rest just inside its near rim
	_place(e)


## After the boss falls: the banner stays a moment, then the dungeon is cleared and the team
## goes home (back to the first floor until the courier hall exists).
func _finish_after_boss() -> void:
	if _finishing:
		return
	_finishing = true
	await get_tree().create_timer(2.2).timeout
	busy = true
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 1.0, 0.4)
	await tw.finished
	cleared += 1
	if not dungeon in beaten:
		beaten.append(dungeon)   # the town sends the next run on to the next dungeon
	if boss_cfg().get("stone", false) and story.get("stone", "") == "":
		story["stone"] = "carried"   # the team brings the pond stone home for the Growth Shrine
	floor_n = 1
	light = LIGHT_MAX
	_party_at_start = party.duplicate(true)   # the run's recruits are yours now
	_roster_at_start = roster.duplicate(true)
	if return_to_town:
		_go_to_town("cleared")
		return
	floor_seed = randi()
	_build_floor(true)
	_say("%s is cleared! The bag and the new partners are kept." % DUNGEONS[dungeon]["name"])
	tw = create_tween()
	tw.tween_property(_fade, "color:a", 0.0, 0.4)
	await tw.finished
	busy = false
	_finishing = false


## A big line across the screen for two seconds: a Monster House, a boss, a win.
func _banner_show(text: String, sub: String, col: Color) -> void:
	_banner = {"text": text, "sub": sub, "at": Time.get_ticks_msec(), "col": col}


## Teammate IQ: the points a creature's line has, whether a skill is on, and the plans the skills
## make before the usual fighting and following.
func iq_of(e: Dictionary) -> int:
	return iq.get(e["line"], 0)


func has_iq(e: Dictionary, id: String) -> bool:
	if e["team"] != 0 or e == ents[0]:
		return false   # the leader is the player
	for sk in IQ_SKILLS:
		if sk["id"] == id:
			return iq_of(e) >= sk["at"]
	return false


func _gain_iq(e: Dictionary, n: int) -> void:
	if e == ents[0]:
		return
	var was := iq_of(e)
	iq[e["line"]] = was + n
	for sk in IQ_SKILLS:
		if was < sk["at"] and iq[e["line"]] >= sk["at"]:
			_say("%s learned an IQ skill: %s (%s)." % [e["name"], sk["name"], sk["what"]])
			_sfx("iq_learn", -6.0)
			_pops.append({"pos": e["node"].position + Vector2(0, -46), "text": "IQ: %s!" % sk["name"], "t": 0.0, "col": Color(0.55, 0.85, 1.0)})


## Roughly what move m from i does to j, without the dice (for the Finisher).
func damage_guess(i: int, j: int, m: String) -> int:
	var e: Dictionary = ents[i]
	return int(Arena.MOVES[m]["damage"] * (1.0 + Arena.STAGE_POWER * e["stage"]) * DMG_SCALE * _mult(i, j, m))


## Team Sense (Claude, 2026-10-10; Preston: "partner and wild AI... start looking our unique legit
## game"). Habits a team shows, layered on Kit Sense's move scoring and the IQ skills, for your
## partners and for wild creatures alike. Structure from Explorers of Sky's partner orders and the
## arena's Kit Sense (focus a called target, protect the healer, ranged keeps range), nothing copied.
##   focus        partners favour the foe the leader is fighting (FOCUS_BONUS, FOCUS_REACH)
##   no overkill  the basic finishes a foe it would down anyway, saving the stronger move
##   keep range   a support with a ranged move steps out of melee while a teammate holds the foe
##   to the hurt  a healer walks toward a teammate under half health it cannot reach yet
##   to a healer  a creature under a third of its health moves toward its team's healer
## Every plan carries "why", for the checks and a later decision log. Numbers are drafts for Grok.
const FOCUS_BONUS := 1.3
const FOCUS_REACH := 2
const SUPPORT_PROFILES := ["kite", "escort"]


## The foe i's team is focusing: the leader's for your side; wild creatures have none.
func _focus_index(i: int) -> int:
	if ents[i]["team"] != 0 or focus.is_empty() or focus["hp"] <= 0:
		return -1
	var j := ents.find(focus)
	return j if j >= 0 and _foes(i, j) else -1


func _awake_foes_beside(i: int, at: Vector2i) -> Array:
	var out: Array = []
	for j in ents.size():
		if _foes(i, j) and ents[j]["hp"] > 0 and (ents[j]["team"] == 0 or ents[j]["awake"]) and _cheb(at, ents[j]["pos"]) == 1:
			out.append(j)
	return out


func _team_sense(i: int) -> Dictionary:
	var e: Dictionary = ents[i]
	var beside := _awake_foes_beside(i, e["pos"])
	var heal_m := ""
	for m in e["moves"]:
		if Arena.MOVES[m].get("heal", 0) > 0:
			heal_m = m
	# To the hurt: a healer whose heal is ready walks to the teammate that needs it.
	if heal_m != "" and e["cds"][heal_m] == 0 and not e.has("seep") and beside.is_empty():
		var worst := -1
		for k in ents.size():
			var o: Dictionary = ents[k]
			if k == i or o["team"] != e["team"] or o["hp"] <= 0 or o["hp"] * 2 >= o["max_hp"]:
				continue
			var dist := _cheb(o["pos"], e["pos"])
			if dist >= 2 and dist <= 5 and _sees(e["pos"], o["pos"]) and (worst < 0 or o["hp"] * ents[worst]["max_hp"] < ents[worst]["hp"] * o["max_hp"]):
				worst = k
		if worst >= 0:
			var st := _step_toward(i, ents[worst]["pos"], true)
			if st != Vector2i.ZERO:
				return {"kind": "move", "d": st, "why": "to the hurt"}
	# To a healer: badly hurt, with a healer on the team that can still help.
	if e["hp"] * 3 < e["max_hp"] and heal_m == "":
		for k in ents.size():
			var h: Dictionary = ents[k]
			if k == i or h["team"] != e["team"] or h["hp"] <= 0:
				continue
			var can_heal := h.has("seep")
			for m in h["moves"]:
				if Arena.MOVES[m].get("heal", 0) > 0 and h["cds"][m] == 0:
					can_heal = true
			var dist := _cheb(h["pos"], e["pos"])
			if can_heal and dist >= 2 and dist <= 6:
				var st := _step_toward(i, h["pos"], true)
				if st != Vector2i.ZERO:
					return {"kind": "move", "d": st, "why": "to a healer"}
	# Keep range: a support with a ranged move ready leaves melee to the teammate holding the foe.
	var profile: String = Arena.KITS.get(e["form"], {}).get("profile", "")
	if profile in SUPPORT_PROFILES and not beside.is_empty() and not e.has("seep"):
		var ranged := false
		for m in e["moves"]:
			if e["cds"][m] == 0 and move_reach(m)["kind"] in ["line", "burst"]:
				ranged = true
		var held := true
		for j in beside:
			var others := false
			for k in ents.size():
				if k != i and ents[k]["team"] == e["team"] and ents[k]["hp"] > 0 and _cheb(ents[k]["pos"], ents[j]["pos"]) == 1:
					others = true
			held = held and others
		if ranged and held:
			for d in DIRS:
				var q: Vector2i = e["pos"] + d
				if can_step(e["pos"], d) and _occupant(q) < 0 and _awake_foes_beside(i, q).is_empty():
					return {"kind": "move", "d": d, "why": "keep range"}
	return {}


func _iq_plan(i: int) -> Dictionary:
	var e: Dictionary = ents[i]
	if has_iq(e, "step_aside") and _warned(e["pos"]):
		for d in DIRS:
			var q: Vector2i = e["pos"] + d
			if can_step(e["pos"], d) and _occupant(q) < 0 and not _warned(q):
				return {"kind": "move", "d": d}
	var low: bool = float(e["hp"]) / e["max_hp"] < 0.3
	if low and has_iq(e, "berry") and bag.get("reedberry", 0) > 0:
		return {"kind": "eat"}
	if float(e["hp"]) / e["max_hp"] < 0.25 and has_iq(e, "fall_back"):
		if _cheb(e["pos"], ents[0]["pos"]) > 1:
			var back := _step_toward(i, ents[0]["pos"], true)
			if back != Vector2i.ZERO:
				return {"kind": "move", "d": back}
		return {"kind": "wait"}
	return {}


## Count something a teammate did toward evolving.
func _grow(e: Dictionary, what: String, n: int) -> void:
	var key := "%d:%d" % [e["line"], e["stage"]]
	if not growth.has(key) or e["stage"] >= 2:
		return
	var was := evo_ready(e["line"], e["stage"])
	growth[key][what] = growth[key].get(what, 0) + n
	_tell_ready(e, was)


## Say so when a teammate has just become ready to evolve (`was`: whether it was ready before).
func _tell_ready(e: Dictionary, was: bool) -> void:
	if not was and evo_ready(e["line"], e["stage"]):
		if story.get("stone", "") == "installed":
			_say("%s is ready to evolve! Take it to the Growth Shrine in Highbank." % e["name"])
		else:
			_say("%s feels ready to change... but nothing in Highbank can help it yet." % e["name"])
		_sfx("evolve_ready", -4.0)
		_pops.append({"pos": e["node"].position + Vector2(0, -40), "text": "READY!", "t": 0.0, "col": Color(0.8, 0.6, 1.0)})
		_rise(e["node"].position, Color(0.8, 0.6, 1.0), 16)


func level_of(line: int) -> int:
	return int(levels.get(line, {}).get("lv", 1))


## EXP a line needs to go from level lv to the next (draft for Grok).
static func exp_to_next(lv: int) -> int:
	return 10 * lv + 10


## The form folder of line's stage, and its basic (slot 0, never forgotten).
static func form_of(line: int, stage: int) -> String:
	return line_data(line)["forms"][stage][0]


static func basic_of(form: String) -> String:
	return Arena.KITS[form]["moves"][0]


## What a creature of line's stage knows at level lv when nobody chose for it (a wild creature, a
## recruit, a teammate with nothing stored): every LEARN move from its first form through this
## one up to lv, each evolve move on the way, minus what this body cannot perform; the basic first,
## then the most recent three (Grok's rule 12).
static func moves_for(line: int, stage: int, lv: int) -> Array:
	var known: Array = []
	for st in stage + 1:
		for entry in LEARN.get(form_of(line, st), []):
			var due: bool = (st > 0) if entry[0] is String else int(entry[0]) <= lv
			if due and not entry[1] in known:
				known.append(entry[1])
	var form := form_of(line, stage)
	var basic := basic_of(form)
	var rest: Array = known.filter(func(m: String) -> bool: return m != basic and MoveBody.can_learn(form, m))
	return [basic] + rest.slice(maxi(0, rest.size() - (MOVES_MAX - 1)))


func _store_moves(e: Dictionary) -> void:
	taught["%d:%d" % [e["line"], e["stage"]]] = e["moves"].duplicate()


## Offer move m to teammate i. With room it learns at once; with four it asks at the teach panel
## which to forget, or lets the move go. Offers wait their turn in learn_queue. On autopilot the
## oldest move after the basic makes room, so a run is never stuck on a question.
func _offer(i: int, m: String) -> void:
	learn_queue.append([i, m])
	if teach_kind == "":
		_next_offer()


func _next_offer() -> void:
	while not learn_queue.is_empty():
		var item: Array = learn_queue.pop_front()
		var i: int = item[0]
		var m: String = item[1]
		if i < 0 or i >= ents.size() or ents[i]["team"] != 0 or m in ents[i]["moves"] or not MoveBody.can_learn(ents[i]["form"], m):
			continue
		var e: Dictionary = ents[i]
		if e["moves"].size() < MOVES_MAX:
			e["moves"].append(m)
			e["cds"][m] = 0
			_store_moves(e)
			_say("%s learned %s!" % [e["name"], Arena.MOVES[m]["name"]])
			_pops.append({"pos": e["node"].position + Vector2(0, -38), "text": "NEW MOVE!", "t": 0.0, "col": Color(0.85, 0.95, 0.6)})
			_sfx("scroll", -4.0)
			continue
		teach_kind = "learn:" + m
		teach_learner = i
		teach_sel = 0
		_say("%s wants to learn %s, but it knows four moves." % [e["name"], Arena.MOVES[m]["name"]])
		if autopilot:
			act_teach(i, 1)
		return


func _hp_at_level(base_hp: int, lv: int) -> int:
	return int(round(base_hp * (1.0 + LEVEL_HP * (lv - 1))))


## Every teammate still standing gets n EXP (once per line: two of a species share a level).
## A level up adds health to the max and to what it has now, the way a level does in Explorers.
func _gain_exp(n: int) -> void:
	var done := {}
	for e in ents:
		if e["team"] != 0 or e["hp"] <= 0 or done.has(e["line"]):
			continue
		done[e["line"]] = true
		var rec: Dictionary = levels.get(e["line"], {"lv": 1, "exp": 0})
		levels[e["line"]] = rec
		if rec["lv"] >= LEVEL_MAX:
			continue
		var was := evo_ready(e["line"], e["stage"])
		var old_lv: int = rec["lv"]
		rec["exp"] += n
		var grew := false
		while rec["lv"] < LEVEL_MAX and rec["exp"] >= exp_to_next(rec["lv"]):
			rec["exp"] -= exp_to_next(rec["lv"])
			rec["lv"] += 1
			grew = true
		if not grew:
			continue
		for t in ents:
			if t["team"] == 0 and t["line"] == e["line"]:
				var new_max := _hp_at_level(int(t.get("base_hp", t["max_hp"])), rec["lv"])
				if t["hp"] > 0:
					t["hp"] += new_max - t["max_hp"]
				t["max_hp"] = new_max
		_say("%s grew to Lv. %d!" % [e["name"], rec["lv"]])
		_sfx("room_clear", -4.0)
		_pops.append({"pos": e["node"].position + Vector2(0, -34), "text": "LV %d" % rec["lv"], "t": 0.0, "col": Color(0.6, 0.9, 1.0)})
		_rise(e["node"].position, Color(1, 0.85, 0.4), 14)
		_ring(e["node"].position + Vector2(0, 2), Color(1, 0.85, 0.4), 18.0, 0.5)
		_tell_ready(e, was)
		for k in ents.size():
			if ents[k]["team"] == 0 and ents[k]["line"] == e["line"] and ents[k]["hp"] > 0:
				for entry in LEARN.get(ents[k]["form"], []):
					if entry[0] is int and entry[0] > old_lv and entry[0] <= rec["lv"]:
						_offer(k, entry[1])


## How far line's stage is toward evolving, 0 to 1 (the slowest of its three conditions and its level).
func evo_progress(line: int, stage: int) -> float:
	var key := "%d:%d" % [line, stage]
	if stage >= 2 or not EVO.has(line) or not growth.has(key):
		return 0.0
	var r: Dictionary = EVO[line]
	var g: Dictionary = growth[key]
	var conditions := minf(minf(float(g["kos"]) / r["kos"][stage], float(g["floors"]) / r["floors"][stage]), float(g.get(r["way"], 0)) / r["need"][stage])
	return minf(conditions, float(level_of(line)) / EVO_LEVEL[stage])


func evo_ready(line: int, stage: int) -> bool:
	return evo_progress(line, stage) >= 1.0


## Evolving happens in Highbank at the Growth Shrine (scripts/town/evolution.gd; Preston, 2026-10-10:
## "we'll keep that you evolve outside dungeon at a specific location"). In the Hollow a teammate only
## becomes ready (_tell_ready). Moves its evolution could not fit wait in pending_learn and are offered
## here when the next run starts, through the learn panel.
func _offer_pending() -> void:
	var left: Array = []
	for item in pending_learn:
		var found := false
		for k in ents.size():
			if ents[k]["team"] == 0 and ents[k]["line"] == int(item[0]) and ents[k]["stage"] == int(item[1]):
				_offer(k, String(item[2]))
				found = true
				break
		if not found:
			left.append(item)   # its creature is not on this run's team; it waits for the next
	pending_learn = left


## Seep (Claude, 2026-10-10; Preston chose the healer line and asked how its arches and roots
## work): the healer plants its roots and a spring wells up under it. It heals itself and every
## teammate beside it at once and again at the end of each turn it stays on that tile, for
## SEEP_TURNS turns; while it seeps it cannot be knocked back; moving pulls the roots up and the
## spring sinks. Numbers are drafts for Grok ("heal" on the move, SEEP_TURNS).
const SEEP_TURNS := 3


func _seep(i: int, m: String) -> bool:
	var e: Dictionary = ents[i]
	e["cds"][m] = _turns_of(m, i)
	_say("%s used %s! A spring wells up under it." % [e["name"], Arena.MOVES[m]["name"]])
	_callout(e, m)
	_sfx("revive", -6.0)
	var pool := Polygon2D.new()
	var pts := PackedVector2Array()
	for k in 16:
		pts.append(Vector2(cos(k * TAU / 16.0) * 18.0, sin(k * TAU / 16.0) * 7.0))
	pool.polygon = pts
	pool.color = Color(0.45, 0.8, 0.85, 0.45)
	pool.position = _tile_px(e["pos"]) + Vector2(0, 2)
	pool.z_index = -1
	_world.add_child(pool)
	if e.has("seep") and is_instance_valid(e["seep"]["node"]):
		e["seep"]["node"].queue_free()
	e["seep"] = {"turns": SEEP_TURNS, "pos": e["pos"], "heal": int(Arena.MOVES[m]["heal"]), "node": pool}
	_heal_around(i)
	await get_tree().create_timer(HIT_TIME).timeout
	return true


## The spring heals the healer and every teammate beside it (8 tiles round).
## Healing a Blighted creature receives is halved (Rot Spit; the answer to Seep and berries).
## The face a talk line asks for ("kithflare:angry" -> "angry"; plain -> "normal").
func _face_of(line: Array) -> String:
	var f: String = String(line[2]) if line.size() > 2 else ""
	return f.get_slice(":", 1) if ":" in f else "normal"


func healed(e: Dictionary, n: int) -> int:
	return n / 2 if e.get("blighted", 0) > 0 else n


## The rival crew's move effects (Claude, 2026-10-10): Drain heals the biter; Rot Spit Blights the
## target; each with its own drawn effect on the dungeon's particles.
func _crew_effects(i: int, j: int, m: String, dmg: int) -> void:
	var mv: Dictionary = Arena.MOVES[m]
	var a: Dictionary = ents[i]
	var o: Dictionary = ents[j]
	var at: Vector2 = o["node"].position + Vector2(0, -10)
	var from: Vector2 = a["node"].position + Vector2(0, -10)
	match m:
		"grub_bite":
			_bite_fx(at, Color("#e9e2cf"), Color("#6b5a3e"))
		"needle_jab":
			_bite_fx(at, Color("#f2f0e6"), Color("#c8d8e0"))
		"buzz_dart":
			for k in 8:   # wing streaks left in the air along the dart
				_parts.append({"pos": from + Vector2(randf_range(-10, 10), randf_range(-8, 4)), "vel": Vector2(randf_range(-30, 30), 0), "t": -0.02 * k, "life": 0.25, "col": Color(0.9, 0.95, 1.0, 0.8), "size": 1.0, "grav": 0.0})
	if mv.get("blight", 0) > 0 and o["hp"] > 0:
		o["blighted"] = int(mv["blight"])
		# A glob of rot down the line (staggered motes), then the splash and drips.
		var d: Vector2 = at - from
		for k in 10:
			_parts.append({"pos": from + d * (k / 10.0), "vel": Vector2.ZERO, "t": -0.025 * k, "life": 0.18, "col": Color("#9bbf4a").lerp(Color("#7a4a8a"), randf() * 0.5), "size": 3.0, "grav": 0.0})
		_burst(at, Color("#9bbf4a"), 14, 60.0, 0.6, 120.0, 2.0)
		_burst(at, Color("#7a4a8a"), 8, 40.0, 0.7, 160.0, 1.0)
		_pops.append({"pos": o["node"].position + Vector2(-14, -46), "text": "BLIGHTED", "t": 0.0, "col": Color("#b6d86a")})
		_say("%s is Blighted: healing is halved for %d turns." % [o["name"], mv["blight"]])
	if mv.get("drain", 0.0) > 0.0 and a["hp"] > 0 and dmg > 0:
		var back: int = mini(healed(a, maxi(1, int(round(dmg * float(mv["drain"]))))), a["max_hp"] - a["hp"])
		# Red motes flow from the bitten back into the biter.
		var d2: Vector2 = from - at
		for k in 12:
			var start := at + Vector2(randf_range(-6, 6), randf_range(-6, 6))
			_parts.append({"pos": start, "vel": d2 / 0.45, "t": -0.03 * k, "life": 0.45, "col": Color("#d8342c").lerp(Color("#ff8a7a"), randf()), "size": 2.5, "grav": 0.0})
		if back > 0:
			a["hp"] += back
			_pops.append({"pos": a["node"].position + Vector2(0, -30), "text": "+%d" % back, "t": 0.0, "col": Color("#ff8a7a")})
			_say("%s drained %d back." % [a["name"], back])


## A quick bite: two jaw-white chevrons snapping shut, and a puff of mud or spark.
func _bite_fx(at: Vector2, tooth: Color, puff: Color) -> void:
	for k in 6:
		var x := -5.0 + k * 2.0
		_parts.append({"pos": at + Vector2(x, -7), "vel": Vector2(0, 40), "t": 0.0, "life": 0.12, "col": tooth, "size": 2.0, "grav": 0.0})
		_parts.append({"pos": at + Vector2(x, 7), "vel": Vector2(0, -40), "t": 0.0, "life": 0.12, "col": tooth, "size": 2.0, "grav": 0.0})
	_burst(at, puff, 8, 45.0, 0.45, 140.0, 1.5)


func _heal_around(i: int) -> void:
	var e: Dictionary = ents[i]
	var total := 0
	for o in ents:
		if o["team"] != e["team"] or o["hp"] <= 0 or o["hp"] >= o["max_hp"] or _cheb(o["pos"], e["pos"]) > 1:
			continue
		var n: int = mini(healed(o, e["seep"]["heal"]), o["max_hp"] - o["hp"])
		o["hp"] += n
		total += n
		_pops.append({"pos": o["node"].position + Vector2(0, -26), "text": "+%d" % n, "t": 0.0, "col": Color(0.55, 0.95, 0.85)})
		_rise(o["node"].position, Color(0.55, 0.95, 0.85), 6)
	_ring(e["node"].position + Vector2(0, 2), Color(0.55, 0.85, 0.9), 22.0, 0.6)
	_ring(e["node"].position + Vector2(0, 2), Color(0.55, 0.85, 0.9), 14.0, 0.45)
	if total > 0 and e["team"] == 0:
		_grow(e, "healed", total)


## End of a turn: each spring heals again, or sinks when its healer moved, fainted or ran dry.
func _springs() -> void:
	for k in ents.size():
		var e: Dictionary = ents[k]
		if not e.has("seep"):
			continue
		var s: Dictionary = e["seep"]
		if e["hp"] <= 0 or e["pos"] != s["pos"]:
			if e["hp"] > 0:
				_say("%s pulled its roots up; the spring sinks." % e["name"])
			_end_seep(e)
			continue
		_heal_around(k)
		s["turns"] -= 1
		if s["turns"] <= 0:
			_end_seep(e)


func _end_seep(e: Dictionary) -> void:
	if is_instance_valid(e["seep"]["node"]):
		e["seep"]["node"].queue_free()
	e.erase("seep")


## A healer's choice (any creature that knows a heal, wild or yours): seep when it and the
## teammates beside it are missing at least one full heal between them (the spring keeps
## healing for SEEP_TURNS more), and it is not already on a spring.
func _heal_plan(i: int) -> Dictionary:
	var e: Dictionary = ents[i]
	if e.has("seep"):
		return {}
	for m in e["moves"]:
		var heal: int = Arena.MOVES[m].get("heal", 0)
		if heal <= 0 or e["cds"][m] > 0:
			continue
		var missing := 0
		for o in ents:
			if o["team"] == e["team"] and o["hp"] > 0 and _cheb(o["pos"], e["pos"]) <= 1:
				missing += mini(heal, o["max_hp"] - o["hp"])
		if missing >= heal:
			return {"kind": "attack", "m": m, "d": _dir_of(e["facing"])}
	return {}


## An item's name, colour and line: the fixed ITEMS, or a scroll made from its move.
func item_info(kind: String) -> Dictionary:
	if kind.begins_with("scroll:"):
		var m := kind.substr(7)
		return {"name": "%s Scroll" % Arena.MOVES[m]["name"], "what": "teaches it to a body with %s" % " and ".join(MoveBody.NEEDS.get(m, [])), "col": Color("#d8c08a")}
	return ITEMS[kind]


## The shared signatures a scroll can hold: moves more than one line's bodies can use, that
## deal damage (the dungeon's moves are attacks for now).
func scroll_pool() -> Array:
	var out: Array = []
	for m in MoveBody.shared(Arena.LINES):
		if Arena.MOVES.has(m) and Arena.MOVES[m]["damage"] > 0:
			out.append(m)
	return out


## The teach panel's rows: first every teammate and whether it can learn the scroll's move,
## then (once one is chosen and its moves are full) the moves it could forget.
func teach_rows() -> Array:
	var m := teach_kind.get_slice(":", 1)
	var rows: Array = []
	if teach_learner < 0:
		for i in ents.size():
			var e: Dictionary = ents[i]
			if e["team"] != 0 or e["hp"] <= 0:
				continue
			var why := ""
			if m in e["moves"]:
				why = "ALREADY KNOWS IT"
			elif not MoveBody.can_learn(e["form"], m):
				why = "NO %s" % " OR ".join(MoveBody.missing(e["form"], m)).to_upper()
			rows.append({"i": i, "text": "%s   %s" % [String(e["name"]).to_upper(), why if why != "" else "CAN LEARN"], "ok": why == ""})
	else:
		var e: Dictionary = ents[teach_learner]
		for slot in range(1, e["moves"].size()):   # the basic attack is never forgotten
			rows.append({"slot": slot, "text": "FORGET %s" % String(Arena.MOVES[e["moves"][slot]]["name"]).to_upper(), "ok": true})
		if teach_kind.begins_with("learn:"):
			rows.append({"slot": -2, "text": "DON'T LEARN %s" % String(Arena.MOVES[m]["name"]).to_upper(), "ok": true})
	return rows


## Teach the open scroll's move to teammate i. With four moves already, it needs the slot to
## forget (1 to 3); without one, the panel asks. Costs no turn. Returns what happened.
func act_teach(i: int, forget := -1) -> String:
	var m := teach_kind.get_slice(":", 1)
	var e: Dictionary = ents[i]
	var level_learn := teach_kind.begins_with("learn:")   # offered by a level or an evolution, not a scroll
	if level_learn and forget == -2:
		_say("%s did not learn %s." % [e["name"], Arena.MOVES[m]["name"]])
		teach_kind = ""
		teach_learner = -1
		_next_offer()
		return "refused"
	if m in e["moves"]:
		_say("%s already knows %s." % [e["name"], Arena.MOVES[m]["name"]])
		return "knows"
	if not MoveBody.can_learn(e["form"], m):
		_say("%s can't learn %s: it has no %s." % [e["name"], Arena.MOVES[m]["name"], " or ".join(MoveBody.missing(e["form"], m))])
		_sfx("denied", -4.0)
		return "body"
	if e["moves"].size() >= MOVES_MAX:
		if forget < 1 or forget >= e["moves"].size():
			teach_learner = i
			teach_sel = 0
			_say("%s knows four moves. Which should it forget?" % e["name"])
			return "full"
		var old: String = e["moves"][forget]
		e["cds"].erase(old)
		e["moves"][forget] = m
		_say("%s forgot %s and learned %s!" % [e["name"], Arena.MOVES[old]["name"], Arena.MOVES[m]["name"]])
	else:
		e["moves"].append(m)
		_say("%s learned %s!" % [e["name"], Arena.MOVES[m]["name"]])
	e["cds"][m] = 0
	_store_moves(e)
	if not level_learn:
		_take(teach_kind)
	teach_kind = ""
	teach_learner = -1
	_pops.append({"pos": e["node"].position + Vector2(0, -38), "text": "NEW MOVE!", "t": 0.0, "col": Color(0.85, 0.95, 0.6)})
	_sfx("scroll", -4.0)
	if level_learn:
		_next_offer()
	return "learned"


## Cycle the partners' order: follow me, go after foes, guard me. Costs no turn.
func act_tactic() -> void:
	tactic = TACTICS[(TACTICS.find(tactic) + 1) % TACTICS.size()]
	_say("Team: %s." % String(TACTIC_NAMES[tactic]).capitalize())
	_play("res://assets/audio/sfx/ui/confirm.wav", -10.0)


## The enemy creature i goes for: the nearest one it can see (a partner only chases what is within
## its order's reach of the leader: 4 tiles following, any distance going after foes, 2 guarding).
func _target(i: int) -> int:
	var e: Dictionary = ents[i]
	var best := -1
	var weakest := has_iq(e, "finisher")
	for j in ents.size():
		if not _foes(i, j):
			continue
		if ents[j]["team"] == 1 and not ents[j]["awake"] and not (has_iq(e, "ambusher") and _cheb(e["pos"], ents[j]["pos"]) == 1):
			continue   # sleepers are left alone, except by an Ambusher standing beside one
		if not _sees(e["pos"], ents[j]["pos"]):
			continue
		if e["team"] == 0 and _cheb(ents[j]["pos"], ents[0]["pos"]) > TACTIC_LEASH[tactic]:
			continue
		if best < 0:
			best = j
		elif weakest and ents[j]["hp"] != ents[best]["hp"]:
			if ents[j]["hp"] < ents[best]["hp"]:
				best = j
		elif _cheb(e["pos"], ents[j]["pos"]) < _cheb(e["pos"], ents[best]["pos"]):
			best = j
	var fj := _focus_index(i)
	if fj >= 0 and best >= 0 and not weakest and fj != best and _sees(e["pos"], ents[fj]["pos"]) and _cheb(e["pos"], ents[fj]["pos"]) <= _cheb(e["pos"], ents[best]["pos"]) + FOCUS_REACH:
		best = fj   # the leader's fight, when it is about as near
	return best


func _end_turn() -> void:
	_springs()
	for e in ents:
		for m in e["cds"]:
			e["cds"][m] = maxi(0, e["cds"][m] - 1)
		if e["hp"] > 0 and e["team"] == 0 and turn % REGEN_EVERY == 0 and e.get("blighted", 0) <= 0:
			e["hp"] = mini(e["max_hp"], e["hp"] + 1)
		e["snared"] = maxi(0, e.get("snared", 0) - 1)
		if e.get("blighted", 0) > 0:
			e["blighted"] -= 1
			if e["blighted"] == 0 and e["hp"] > 0:
				_say("The rot on %s wore off." % e["name"])
	if turn % LIGHT_DRAIN_EVERY == 0:
		var was_light := light
		light = maxf(0.0, light - 1.0)
		if was_light >= 25.0 and light < 25.0:
			_sfx("lantern_low", -4.0)
		if was_light > 0.0 and light == 0.0:
			_sfx("lantern_out", -4.0)
		if light < 25.0 and music_track() == "deep_hollow":
			_music_update()
		if light == 0.0 and turn % (LIGHT_DRAIN_EVERY * 10) == 0:
			_say("The lantern is out. Only what is close can be seen.")
	_pick_up()
	_spring_traps()
	_monster_house()
	if monster_sprung and not house_cleared and ents.any(func(e: Dictionary) -> bool: return e.get("house", false)) and ents.filter(func(e: Dictionary) -> bool: return e.get("house", false) and e["hp"] > 0).is_empty():
		house_cleared = true
		light = minf(LIGHT_MAX, light + MONSTER_HOUSE_LIGHT)
		_say("The Monster House is cleared! The lantern burns brighter.")
		_sfx("room_clear", -3.0)
		_banner_show("CLEARED!", "the Monster House", Color(0.6, 1, 0.6))
	_music_update()   # back to the floor's track, or to the deep one when the lantern runs low
	for e in ents:
		e["moved"] = false
	# Wild creatures wake when one of yours comes into sight.
	for w in ents:
		if w["team"] != 1 or w["hp"] <= 0 or w["awake"]:
			continue
		for e in ents:
			if e["team"] == 0 and e["hp"] > 0 and not (e != ents[0] and has_iq(e, "quiet")) and _sees(e["pos"], w["pos"]) and _cheb(e["pos"], w["pos"]) <= SIGHT - 1:
				w["awake"] = true
				_pops.append({"pos": w["node"].position + Vector2(0, -30), "text": "!", "t": 0.0, "col": Color(1, 0.4, 0.3)})
				break
	if boss >= 0 and not boss_met and talk.is_empty() and ents[boss]["hp"] > 0 and ents[boss]["awake"]:
		_meet_boss()
	_reveal()
	if ents[0]["hp"] <= 0 and bag.get("rally_seed", 0) > 0:
		_take("rally_seed")
		ents[0]["hp"] = ents[0]["max_hp"] / 2
		ents[0]["node"].modulate.a = 1.0
		_say("The Rally Seed! %s gets back up." % ents[0]["name"])
		_sfx("revive", -3.0)
	if ents[0]["hp"] <= 0:
		faints += 1
		bag = {"reedberry": 1}   # fainting loses the bag (Explorers of Sky); a fresh run starts with one berry
		party = _party_at_start.duplicate(true)   # and the run's recruits: they never reached the hall
		roster = _roster_at_start.duplicate(true)
		asking = -1
		light = LIGHT_MAX
		_say("%s fainted! The team is carried back to the entrance." % ents[0]["name"])
		Music.play(get_tree(), "")
		Music.jingle(get_tree(), "fainted")
		floor_n = 1
		floor_seed = randi()
		if return_to_town:
			call_deferred("_go_to_town", "fainted")
		else:
			call_deferred("_build_floor", true)
	elif ents[0]["pos"] == data["stairs"]:
		_say("Stairs. Press E to go down.")
	if real_time_battles and not in_battle and ents[0]["hp"] > 0 and asking < 0:
		for w in ents:
			if w["team"] == 1 and w["hp"] > 0 and w["awake"] and _cheb(w["pos"], ents[0]["pos"]) <= BATTLE_RANGE and _sees(ents[0]["pos"], w["pos"]):
				in_battle = true
				call_deferred("_start_battle")
				break


## How far the lantern lets the leader see down a hallway.
func light_radius() -> int:
	return 1 + int(ceil(light / 20.0))


func _reveal() -> void:
	var lead: Vector2i = ents[0]["pos"]
	var w: int = data["w"]
	visible_tiles.clear()
	var r := light_radius()
	for y in range(lead.y - r, lead.y + r + 1):
		for x in range(lead.x - r, lead.x + r + 1):
			var p := Vector2i(x, y)
			if x >= 0 and y >= 0 and x < w and y < data["h"] and (p == lead or _sees_r(lead, p, r)):
				visible_tiles[p] = true
	if light > 0.0:
		for room in data["rooms"]:
			if room.grow(1).has_point(lead):
				for y in range(room.position.y - 1, room.end.y + 1):
					for x in range(room.position.x - 1, room.end.x + 1):
						visible_tiles[Vector2i(x, y)] = true
	for p in visible_tiles:
		if p.x >= 0 and p.y >= 0 and p.x < w and p.y < data["h"]:
			explored[p.y * w + p.x] = 1
	for e in ents:
		e["node"].visible = (e["team"] == 0 or visible_tiles.has(e["pos"])) and not e.get("hidden", false)
	for room in data["rooms"]:
		if room.grow(1).has_point(lead):
			for y in range(room.position.y - 1, room.end.y + 1):
				for x in range(room.position.x - 1, room.end.x + 1):
					if x >= 0 and y >= 0 and x < w and y < data["h"]:
						explored[y * w + x] = 1
	for y in range(lead.y - 2, lead.y + 3):
		for x in range(lead.x - 2, lead.x + 3):
			if x >= 0 and y >= 0 and x < w and y < data["h"]:
				explored[y * w + x] = 1


# ---------------------------------------------------------------- the run loop

func _pick_up() -> void:
	var lead: Dictionary = ents[0]
	for k in range(floor_items.size() - 1, -1, -1):
		var it: Dictionary = floor_items[k]
		if it["pos"] != lead["pos"]:
			continue
		if it.has("job"):
			var j := _job(String(it["job"]))
			floor_items.remove_at(k)
			if not j.is_empty():
				j["done"] = true
				_say("Recovered %s's %s! Job done; the reward waits at the Job Board." % [Jobs.client_name(j), item_info(it["kind"])["name"]])
			_sfx("pickup", -6.0)
			continue
		if not bag.has(it["kind"]) and bag.size() >= BAG_KINDS:
			_say("The bag is full; the %s stays on the floor." % item_info(it["kind"])["name"])
			_sfx("denied", -6.0)
			continue
		bag[it["kind"]] = bag.get(it["kind"], 0) + 1
		floor_items.remove_at(k)
		_say("Picked up a %s." % item_info(it["kind"])["name"])
		_sfx("pickup", -6.0)


func _spring_traps() -> void:
	for e in ents:
		if e != ents[0] or e["hp"] <= 0 or not e.get("moved", false):
			continue   # only the leader sets a trap off; partners walking the chain used to be snared and warped away
		for tr in traps:
			if tr["pos"] != e["pos"]:
				continue
			tr["seen"] = true
			_say("%s stepped on a %s!" % [e["name"], TRAPS[tr["kind"]]["name"]])
			_sfx("trap_" + String(tr["kind"]), -3.0)
			match tr["kind"]:
				"snare":
					e["snared"] = 3   # this turn's tick takes one, so it holds for 2 turns
				"silt":
					light = maxf(0.0, light - 15.0)
					for o in ents:
						if o["team"] == 0 and o["hp"] > 0 and _cheb(o["pos"], e["pos"]) <= 1:
							o["hp"] = maxi(1, o["hp"] - 6)
							_pops.append({"pos": o["node"].position + Vector2(0, -26), "text": "6", "t": 0.0, "col": Color(0.85, 0.75, 0.55)})
				"warp":
					var rooms: Array = data["rooms"]
					for tries in 30:
						var room: Rect2i = rooms[randi() % rooms.size()]
						var p := room.get_center()
						if not room.grow(1).has_point(e["pos"]) and _occupant(p) < 0 and _floor_at(p):
							e["pos"] = p
							_place(e)
							break


func _monster_house() -> void:
	if monster_sprung or monster_room.size == Vector2i.ZERO or not monster_room.has_point(ents[0]["pos"]):
		return
	monster_sprung = true
	_say("It's a Monster House!")
	Music.play(get_tree(), "monster_house")
	_banner_show("MONSTER HOUSE!", "", Color(1, 0.45, 0.3))
	_sfx("monster_ambush", -2.0)
	var area := 0
	for y in range(monster_room.position.y, monster_room.end.y):
		for x in range(monster_room.position.x, monster_room.end.x):
			if _floor_at(Vector2i(x, y)):
				area += 1
	var want := clampi(area / MONSTER_HOUSE_PER_TILES, MONSTER_HOUSE_WILD, MONSTER_HOUSE_MAX)
	var spawned := 0
	var rng := RandomNumberGenerator.new()
	rng.seed = floor_seed + 99
	for tries in 80:
		if spawned >= want:
			break
		var p := Vector2i(rng.randi_range(monster_room.position.x, monster_room.end.x - 1), rng.randi_range(monster_room.position.y, monster_room.end.y - 1))
		if _occupant(p) >= 0 or not _floor_at(p) or _cheb(p, ents[0]["pos"]) < 2:
			continue
		var pick: Array = recipe()["spawns"][rng.randi_range(0, recipe()["spawns"].size() - 1)]
		var w := _make(pick[0], pick[1], 1, p)
		w["max_hp"] = maxi(6, int(round(w["max_hp"] * WILD_HP)))
		w["hp"] = w["max_hp"]
		w["awake"] = true
		w["facing"] = _facing_of(ents[0]["pos"] - p)
		w["house"] = true
		ents.append(w)
		_place(w)
		# It drops in from above, one after another.
		var land: Vector2 = w["node"].position
		w["node"].position = land + Vector2(0, -70)
		w["node"].modulate.a = 0.0
		var tw := create_tween()
		tw.tween_interval(0.06 * spawned)
		tw.tween_property(w["node"], "modulate:a", 1.0, 0.05)
		tw.tween_property(w["node"], "position", land, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		spawned += 1


func _take(kind: String) -> void:
	bag[kind] = bag.get(kind, 0) - 1
	if bag[kind] <= 0:
		bag.erase(kind)


## Use an item from the bag. Using one is the leader's action for the turn; one that cannot do
## anything (a stone with nobody in its line) is refused for free.
func act_use_item(kind: String) -> void:
	if busy or not bag.has(kind) or ents[0]["hp"] <= 0:
		return
	var lead: Dictionary = ents[0]
	if kind.begins_with("scroll:"):
		teach_kind = kind   # reading a scroll costs no turn; the panel chooses who learns
		teach_sel = 0
		teach_learner = -1
		return
	match kind:
		"reedberry":
			_take(kind)
			await _player_turn(func() -> bool:
				var heal: int = mini(healed(lead, 15), lead["max_hp"] - lead["hp"])
				lead["hp"] += heal
				_say("%s ate a Reedberry: %d back." % [lead["name"], heal])
				_sfx("eat", -4.0)
				return true)
		"lamp_oil":
			_take(kind)
			await _player_turn(func() -> bool:
				light = minf(LIGHT_MAX, light + 40.0)
				_say("The lantern burns brighter.")
				_sfx("lantern_up", -4.0)
				_reveal()
				return true)
		"river_stone":
			var d := Vector2i.ZERO
			for dd in [_dir_of(lead["facing"])] + DIRS:
				if _stone_target(dd) >= 0:
					d = dd
					break
			if d == Vector2i.ZERO:
				_say("Nothing in a line to throw the stone at.")
				_sfx("denied", -4.0)
				return
			_take(kind)
			await _player_turn(func() -> bool:
				var j := _stone_target(d)
				lead["facing"] = _facing_of(d)
				_set_tex(lead, lead["art"]["still"][lead["facing"]])
				_shots.append({"from": lead["node"].position + Vector2(0, -10), "to": ents[j]["node"].position + Vector2(0, -10), "t": 0.0, "burst": false})
				ents[j]["hp"] = maxi(0, ents[j]["hp"] - 8)
				ents[j]["flash"] = 0.25
				ents[j]["awake"] = true
				_pops.append({"pos": ents[j]["node"].position + Vector2(0, -26), "text": "8", "t": 0.0, "col": Color(1, 1, 1)})
				_say("%s threw a River Stone: %s took 8 damage." % [lead["name"], ents[j]["name"]])
				_sfx("throw", -4.0)
				if ents[j]["hp"] <= 0:
					_say("%s fainted!" % ents[j]["name"])
					light = minf(LIGHT_MAX, light + LIGHT_ON_KO)
					create_tween().tween_property(ents[j]["node"], "modulate:a", 0.0, 0.35)
				return true)
		"rally_seed":
			_say("The Rally Seed works by itself when the leader faints.")


## Whether any wild creature's wind-up marks tile p.
func _warned(p: Vector2i) -> bool:
	for e in ents:
		if e["hp"] > 0 and e.has("windup") and p in e["windup"]["tiles"]:
			return true
	return false


func _stone_target(d: Vector2i) -> int:
	var at: Vector2i = ents[0]["pos"]
	for k in 8:
		if not _floor_at(at + d):
			return -1
		at += d
		var o := _occupant(at)
		if o >= 0:
			return o if _foes(0, o) else -1
	return -1


# ---------------------------------------------------------------- per frame

func _process(delta: float) -> void:
	if ents.is_empty():
		return
	if in_battle:
		_watch_battle(delta)
		return
	for e in ents:
		e["flash"] = maxf(0.0, e["flash"] - delta)
		e["sprite"].modulate = Color(3, 3, 3) if e["flash"] > 0.12 else (Color(0.82, 1.0, 0.7) if e.get("blighted", 0) > 0 else Color(1, 1, 1))   # Blighted: a sickly green
		if e.get("down", false):
			# Knocked flat in a scene: the sleep pose (or the end of the hurt one) until it gets up.
			var lie: Array = e["art"]["acts"].get("sleep", {}).get("s", [])
			if lie.is_empty():
				lie = e["art"]["acts"].get("hurt", {}).get(e["facing"], [])
			if not lie.is_empty():
				_set_tex(e, lie[0] if e["art"]["acts"].has("sleep") else lie[-1])
			e["node"].z_index = int(e["node"].position.y)
			continue
		if e.has("act"):
			var a: Dictionary = e["act"]
			a["t"] += delta
			var af: Array = e["art"]["acts"][a["name"]].get(e["facing"], [])
			if a["t"] >= ACT_TIME[a["name"]] or af.is_empty():
				e.erase("act")
				_set_tex(e, e["art"]["still"][e["facing"]])
			else:
				_set_tex(e, af[mini(af.size() - 1, int(a["t"] / ACT_TIME[a["name"]] * af.size()))])
			e["node"].z_index = int(e["node"].position.y)
			continue
		if e["team"] == 1 and not e["awake"] and e["hp"] > 0 and e["art"]["acts"].has("sleep"):
			var sf: Array = e["art"]["acts"]["sleep"]["s"]
			e["sleeping"] = true
			_set_tex(e, sf[int(fmod(Time.get_ticks_msec() / 1000.0 + e["pos"].x * 0.37, SLEEP_LOOP) / SLEEP_LOOP * sf.size()) % sf.size()])
			e["node"].z_index = int(e["node"].position.y)
			continue
		if e.get("sleeping", false):
			e.erase("sleeping")   # it woke: back to its standing pose
			_set_tex(e, e["art"]["still"][e["facing"]])
		if e["walk_t"] > 0.0:
			e["walk_t"] = maxf(0.0, e["walk_t"] - delta)
			var frames: Array = e["art"]["walk"][e["facing"]]
			if not frames.is_empty():
				_set_tex(e, frames[int((1.0 - e["walk_t"] / STEP_TIME) * 4.0 + turn * 4) % frames.size()])
			if e["walk_t"] <= 0.0:
				_set_tex(e, e["art"]["still"][e["facing"]])
		e["node"].z_index = int(e["node"].position.y)
	for p in _pops:
		p["t"] += delta
	_pops = _pops.filter(func(p: Dictionary) -> bool: return p["t"] < 0.9)
	for q in _parts:
		q["t"] += delta
		q["vel"].y += q["grav"] * delta
		q["pos"] += q["vel"] * delta
	_parts = _parts.filter(func(q: Dictionary) -> bool: return q["t"] < q["life"])
	for r in _rings:
		r["t"] += delta
	_rings = _rings.filter(func(r: Dictionary) -> bool: return r["t"] < r["life"])
	for s in _shots:
		s["t"] += delta
	_shots = _shots.filter(func(s: Dictionary) -> bool: return s["t"] < 0.3)
	for v in _vfx:
		v["t"] += delta
	_vfx = _vfx.filter(func(v: Dictionary) -> bool: return v["t"] < v["dur"])
	for g in _ghosts:
		g["t"] += delta
	_ghosts = _ghosts.filter(func(g: Dictionary) -> bool: return g["t"] < 0.25)
	_shake = maxf(0.0, _shake - delta * 14.0)
	_flash = maxf(0.0, _flash - delta)
	var menu := get_node_or_null("GamePauseMenu")
	if menu != null and menu.hint != null:
		menu.hint.visible = not cutscene   # a scene hides the Menu button with the rest of the HUD
	if poll_input:
		_poll(delta)
	if autopilot and not busy:
		_autopilot()
	var focus: Vector2 = cam_focus if cam_focus is Vector2 else ents[0]["node"].position + Vector2(0, -12)
	var size := Vector2(data["w"], data["h"]) * T
	var half := Vector2(VIEW) * 0.5
	focus = focus.clamp(half, size - half)
	_world.position = (half - focus + Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _shake).round()
	_fx.queue_redraw()
	_floor_fx.queue_redraw()
	_hud.queue_redraw()


func _poll(delta: float) -> void:
	if cutscene:   # a scene plays itself; J reads its lines
		if not talk.is_empty() and (_tapped(KEY_J) or _tapped(KEY_ENTER) or _tapped(KEY_SPACE)):
			act_talk()
		return
	if busy:
		return
	if asking >= 0:
		if _tapped(KEY_Y) or _tapped(KEY_ENTER):
			act_recruit(true)
		elif _tapped(KEY_N) or _tapped(KEY_ESCAPE):
			act_recruit(false)
		return
	if not talk.is_empty():
		if _tapped(KEY_J) or _tapped(KEY_ENTER) or _tapped(KEY_SPACE):
			act_talk()
		return
	if teach_kind != "":
		var rows := teach_rows()
		if _tapped(KEY_W) or _tapped(KEY_UP):
			teach_sel = maxi(0, teach_sel - 1)
		elif _tapped(KEY_S) or _tapped(KEY_DOWN):
			teach_sel = mini(rows.size() - 1, teach_sel + 1)
		elif (_tapped(KEY_J) or _tapped(KEY_ENTER)) and not rows.is_empty():
			if teach_learner < 0:
				act_teach(rows[teach_sel]["i"])
			else:
				act_teach(teach_learner, rows[teach_sel]["slot"])
		elif _tapped(KEY_ESCAPE) or _tapped(KEY_I):
			if teach_kind.begins_with("learn:"):
				act_teach(teach_learner, -2)   # letting a level's move go
			else:
				teach_kind = ""
				teach_learner = -1
		return
	if bag_open:
		# The bag: W and S choose, J or Enter uses, I or Escape closes.
		var kinds: Array = bag.keys()
		if _tapped(KEY_W) or _tapped(KEY_UP):
			bag_sel = maxi(0, bag_sel - 1)
		elif _tapped(KEY_S) or _tapped(KEY_DOWN):
			bag_sel = mini(kinds.size() - 1, bag_sel + 1)
		elif (_tapped(KEY_J) or _tapped(KEY_ENTER)) and not kinds.is_empty():
			bag_open = false
			act_use_item(kinds[clampi(bag_sel, 0, kinds.size() - 1)])
		elif _tapped(KEY_I) or _tapped(KEY_ESCAPE):
			bag_open = false
			_sfx("menu_close", -4.0)
		return
	var d := Vector2i(int(_key(KEY_D) or _key(KEY_RIGHT)) - int(_key(KEY_A) or _key(KEY_LEFT)), int(_key(KEY_S) or _key(KEY_DOWN)) - int(_key(KEY_W) or _key(KEY_UP)))
	if d == Vector2i.ZERO:
		_hold = 0.0
		_was_dir = Vector2i.ZERO
	else:
		if _was_dir == Vector2i.ZERO:
			_hold += delta
			if _hold < 0.07:
				return   # a moment for the second key of a diagonal
		_was_dir = d
		if Input.is_key_pressed(KEY_SHIFT):
			_shift_turned = true
			act_face(d)
		else:
			act_move(d)
		return
	# Shift held is turn mode (arrows show round the leader); a tap of Shift alone faces the nearest foe.
	var shift := Input.is_key_pressed(KEY_SHIFT)
	if shift and not turn_mode:
		_shift_turned = false
	elif not shift and turn_mode and not _shift_turned:
		act_face_nearest()
	turn_mode = shift
	for pair in [[KEY_J, 0], [KEY_SPACE, 0], [KEY_1, 1], [KEY_2, 2], [KEY_3, 3]]:
		if _tapped(pair[0]):
			act_attack(pair[1])
			return
	if _tapped(KEY_I):
		bag_open = not bag_open
		bag_sel = 0
		_sfx("menu_open", -4.0)
		return
	if _tapped(KEY_Z) or _tapped(KEY_PERIOD):
		act_rest()
	elif _tapped(KEY_E):
		act_stairs()
	elif _tapped(KEY_T):
		act_tactic()
	elif _tapped(KEY_TAB):
		autopilot = not autopilot
		_say("Autopilot %s." % ("on" if autopilot else "off"))


func _unhandled_input(event: InputEvent) -> void:
	if in_battle:
		return
	if poll_input and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		act_attack(0)


func _key(k: int) -> bool:
	return Input.is_physical_key_pressed(k)


func _tapped(k: int) -> bool:
	var now := Input.is_physical_key_pressed(k)
	var was: bool = _keys_was.get(k, false)
	_keys_was[k] = now
	return now and not was


## Tab: the leader plays itself: the nearest wild creature it knows of, then the stairs.
func _autopilot() -> void:
	var lead: Dictionary = ents[0]
	if cutscene:
		if not talk.is_empty():
			act_talk()
		return
	if lead["hp"] <= 0 or _finishing:
		return
	if not talk.is_empty():
		act_talk()
		return
	if asking >= 0:
		act_recruit(true)
		return
	if lead["pos"] == data["stairs"] and ents.filter(func(e: Dictionary) -> bool: return e["team"] == 1 and e["hp"] > 0).is_empty():
		act_stairs()
		return
	var awake_near := false
	for j in ents.size():
		if ents[j]["team"] == 1 and ents[j]["hp"] > 0 and ents[j]["awake"] and _sees(lead["pos"], ents[j]["pos"]):
			awake_near = true
	if _warned(lead["pos"]):
		# Step out of a marked tile before anything else (what a player should learn to do).
		for dd in DIRS:
			var q: Vector2i = lead["pos"] + dd
			if can_step(lead["pos"], dd) and _occupant(q) < 0 and not _warned(q):
				act_move(dd)
				return
	if float(lead["hp"]) / lead["max_hp"] < 0.4 and bag.has("reedberry"):
		act_use_item("reedberry")
		return
	if light < 25.0 and bag.has("lamp_oil"):
		act_use_item("lamp_oil")
		return
	if not awake_near and float(lead["hp"]) / lead["max_hp"] < REST_TO:
		act_rest()   # catch its breath before the next room
		return
	var t := -1
	for j in ents.size():
		if ents[j]["team"] == 1 and ents[j]["hp"] > 0 and (t < 0 or _cheb(lead["pos"], ents[j]["pos"]) < _cheb(lead["pos"], ents[t]["pos"])):
			t = j
	if t >= 0:
		for slot in range(lead["moves"].size() - 1, -1, -1):
			var m: String = lead["moves"][slot]
			if lead["cds"][m] == 0 and aim(0, m) != Vector2i.ZERO:
				act_attack(slot)
				return
		var d := _step_toward(0, ents[t]["pos"], true)
		if d != Vector2i.ZERO:
			act_move(d)
		else:
			act_rest()
		return
	var goal: Vector2i = data["stairs"]
	for it in floor_items:
		if explored[it["pos"].y * data["w"] + it["pos"].x] == 1 and (goal == data["stairs"] or _cheb(lead["pos"], it["pos"]) < _cheb(lead["pos"], goal)):
			goal = it["pos"]   # pick up what it has seen before the stairs
	var d2 := _step_toward(0, goal, true)
	if d2 != Vector2i.ZERO:
		act_move(d2)
	else:
		act_rest()


# ---------------------------------------------------------------- drawing

## Warning tiles: red, pulsing, on the floor under the creatures, where the leader can see.
func _draw_floor_fx() -> void:
	if pond.size != Vector2i.ZERO:
		BossIntro.draw_floor(self, _floor_fx)
	CrewScene.draw(self, _floor_fx, false)
	var k: float = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 130.0)
	if boss_alive() and visible_tiles.has(data["stairs"]) and not cutscene:
		# Sealed stairs: a dark slab with a cross over them.
		var sr := Rect2(Vector2(data["stairs"]) * T, Vector2(T, T))
		_floor_fx.draw_rect(sr, Color(0.04, 0.04, 0.07, 0.85))
		_floor_fx.draw_line(sr.position + Vector2(4, 4), sr.end - Vector2(4, 4), Color(1, 0.35, 0.35, 0.8), 2.0)
		_floor_fx.draw_line(Vector2(sr.end.x - 4, sr.position.y + 4), Vector2(sr.position.x + 4, sr.end.y - 4), Color(1, 0.35, 0.35, 0.8), 2.0)
	_draw_aim(k)
	for e in ents:
		if e["hp"] <= 0 or not e.has("windup"):
			continue
		for t in e["windup"]["tiles"]:
			if not visible_tiles.has(t):
				continue
			var r := Rect2(Vector2(t) * T + Vector2(1, 1), Vector2(T - 2, T - 2))
			_floor_fx.draw_rect(r, Color(0.9, 0.15, 0.1, 0.18 + 0.17 * k))
			_floor_fx.draw_rect(r, Color(1.0, 0.35, 0.25, 0.75), false, 1.0)
		# The one gathering itself glows in its move's colour (Into the Breach shows who acts).
		var glow: Color = ESSENCE_COL.get(_ess_name(e["windup"]["m"], e), Color(1, 0.4, 0.3))
		var c: Vector2 = e["node"].position + Vector2(0, -2)
		_floor_fx.draw_circle(c, 9.0 + 2.0 * k, Color(glow, 0.18 + 0.12 * k))
		_floor_fx.draw_arc(c, 10.0 + 2.0 * k, 0, TAU, 20, Color(glow, 0.7), 1.0)


## The aim, shown before you commit (Into the Breach's rule: never guess what a button will hit):
## pale corner brackets on the foe the basic attack would hit now; while Shift is held, eight arrows
## round the leader (Explorers of Sky's turn mode), the faced one bright, and its front tile outlined.
func _draw_aim(k: float) -> void:
	if cutscene or busy or ents.is_empty() or ents[0]["hp"] <= 0:
		return
	var who := aim_target()
	if who >= 0:
		var r := Rect2(Vector2(ents[who]["pos"]) * T, Vector2(T, T))
		var c := Color(1.0, 0.93, 0.62, 0.65 + 0.3 * k)
		var l := 5.0
		for corner in [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]:
			var sx := 1.0 if corner.x == r.position.x else -1.0
			var sy := 1.0 if corner.y == r.position.y else -1.0
			_floor_fx.draw_line(corner, corner + Vector2(l * sx, 0), c, 1.0)
			_floor_fx.draw_line(corner, corner + Vector2(0, l * sy), c, 1.0)
	if not turn_mode:
		return
	var p: Vector2i = ents[0]["pos"]
	var front := Rect2(Vector2(p + _dir_of(ents[0]["facing"])) * T + Vector2(1, 1), Vector2(T - 2, T - 2))
	_floor_fx.draw_rect(front, Color(1.0, 0.95, 0.7, 0.5 + 0.3 * k), false, 1.0)


## Turn mode's eight arrows, over the creatures so none hides them: dark-edged, the faced one gold and larger.
func _draw_turn_arrows() -> void:
	if not turn_mode or cutscene or busy or ents.is_empty() or ents[0]["hp"] <= 0:
		return
	var mid := Vector2(ents[0]["pos"]) * T + Vector2(T, T) * 0.5
	var faced := _dir_of(ents[0]["facing"])
	for d in DIRS:
		var on: bool = d == faced
		var v := Vector2(d).normalized()
		var size := 7.0 if on else 5.0
		var tip := mid + v * (T * 0.5 + 8.0)
		var side := Vector2(-v.y, v.x) * size * 0.6
		var tri := PackedVector2Array([tip, tip - v * size + side, tip - v * size - side])
		_fx.draw_colored_polygon(tri, Color(1.0, 0.86, 0.42) if on else Color(0.92, 0.94, 0.96, 0.8))
		tri.append(tip)
		_fx.draw_polyline(tri, Color(0.10, 0.08, 0.06, 0.9), 1.0)


func _draw_fx() -> void:
	_draw_turn_arrows()
	if not intro.is_empty():
		BossIntro.draw_over(self, _fx)
		CrewScene.draw(self, _fx, true)
		StoneScene.draw_over(self, _fx)
		StoneScene.draw_standoff(self, _fx)
	# Rot bubbles rising off a Blighted creature while the Blight lasts.
	var tb := Time.get_ticks_msec() / 1000.0
	for e in ents:
		if e.get("blighted", 0) > 0 and e["hp"] > 0 and e["node"].visible:
			var top: float = -float(e["sprite"].texture.get_height()) * 0.5 + e["sprite"].offset.y   # the sprite's top
			for k in 3:
				var ph := fmod(tb * 0.8 + k * 0.33, 1.0)
				var bp: Vector2 = (e["node"].position + Vector2(-7 + k * 7, top - 2 - ph * 14)).round()
				var a := 1.0 - ph
				_fx.draw_rect(Rect2(bp, Vector2(3, 3)), Color(0.36, 0.5, 0.18, a))
				_fx.draw_rect(Rect2(bp, Vector2(2, 2)), Color(0.66, 0.82, 0.32, a))
				_fx.draw_rect(Rect2(bp, Vector2(1, 1)), Color(0.9, 1.0, 0.7, a))
	for it in floor_items:
		var c: Vector2 = (Vector2(it["pos"]) * T + Vector2(T, T) * 0.5).round()
		_fx.draw_circle(c + Vector2(0, 2), 5.0, Color(0, 0, 0, 0.3))
		_fx.draw_circle(c, 4.0, item_info(it["kind"])["col"])
		_fx.draw_circle(c + Vector2(-1, -1), 1.5, Color(1, 1, 1, 0.6))
	for tr in traps:
		if tr["seen"]:
			var c2: Vector2 = (Vector2(tr["pos"]) * T + Vector2(T, T) * 0.5).round()
			_fx.draw_line(c2 + Vector2(-5, -5), c2 + Vector2(5, 5), Color(0.75, 0.2, 0.2), 2.0)
			_fx.draw_line(c2 + Vector2(-5, 5), c2 + Vector2(5, -5), Color(0.75, 0.2, 0.2), 2.0)
	# The dark: every tile in view the lantern does not reach.
	var origin: Vector2 = -_world.position
	var t0 := Vector2i(floori(origin.x / T) - 1, floori(origin.y / T) - 1)
	for ty in range(t0.y, t0.y + VIEW.y / T + 3):
		for tx in range(t0.x, t0.x + VIEW.x / T + 3):
			if not visible_tiles.has(Vector2i(tx, ty)):
				_fx.draw_rect(Rect2(Vector2(tx, ty) * T, Vector2(T, T)), Color(0.02, 0.02, 0.04, 0.82))
	# Sleeping wild creatures breathe a "z".
	for e in ents:
		if e["team"] == 1 and e["hp"] > 0 and not e["awake"] and visible_tiles.has(e["pos"]) and not e.get("hidden", false) and not cutscene:
			var p: Vector2 = e["node"].position + Vector2(8, -30 - 2.0 * sin(Time.get_ticks_msec() / 300.0))
			_fx.draw_string(FONT, p.round(), "z", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.85, 0.9, 1.0, 0.85))
	# The leader's facing: a small chevron on the tile ahead.
	if not ents.is_empty() and ents[0]["hp"] > 0:
		var ahead: Vector2 = _tile_px(ents[0]["pos"] + _dir_of(ents[0]["facing"])) + Vector2(0, -T * 0.28)
		_fx.draw_arc(ahead.round(), 4.0, 0, TAU, 12, Color(1, 0.85, 0.4, 0.55), 1.0)
	for s in _shots:
		var k: float = clampf(s["t"] / 0.15, 0.0, 1.0)
		var at: Vector2 = s["from"].lerp(s["to"], k)
		var col: Color = s.get("col", Color(1, 0.95, 0.7))
		_fx.draw_circle(at.round(), 3.0 if not s["burst"] else 2.0 + 8.0 * k, Color(col, 1.0 - k * 0.5))
	for g in _ghosts:
		if g["t"] >= 0.0 and g["tex"] != null:
			var sz: Vector2 = g["tex"].get_size()
			_fx.draw_texture_rect(g["tex"], Rect2((g["pos"] - sz * 0.5).round(), sz * Vector2(-1 if g["flip"] else 1, 1)), false, Color(1, 1, 1, 0.45 * (1.0 - g["t"] / 0.25)))
	for v in _vfx:
		if v["t"] < 0.0:
			continue
		var frames: Array = _fx_sheet(v["name"])
		var k2: float = clampf(v["t"] / v["dur"], 0.0, 0.999)
		var tex: Texture2D = frames[int(k2 * frames.size())] if not v.has("to") else frames[int(v["t"] * 30.0) % frames.size()]
		var at2: Vector2 = v["pos"] if not v.has("to") else v["pos"].lerp(v["to"], k2)
		var sz2: Vector2 = tex.get_size()
		_fx.draw_texture(tex, (at2 - sz2 * 0.5).round())
	for r in _rings:
		var k3: float = r["t"] / r["life"]
		_fx.draw_arc(r["pos"].round(), 2.0 + r["r"] * (1.0 - pow(1.0 - k3, 2.0)), 0, TAU, 24, Color(r["col"], 0.9 * (1.0 - k3)), 1.0)
	for q in _parts:
		if q["t"] < 0.0:
			continue
		var k4: float = q["t"] / q["life"]
		var sz: float = q["size"]
		_fx.draw_rect(Rect2(q["pos"].round(), Vector2(sz, sz)), Color(q["col"], 1.0 - k4 * k4))
	# Damage numbers, the Mystery Dungeon DX way: they pop up, overshoot, settle, then fade; outlined in
	# the creatures' near-black so they read on any floor; a super-effective one is bigger.
	for p in _pops:
		var a: float = clampf((0.9 - p["t"]) / 0.3, 0.0, 1.0)
		var lift: float = 16.0 * (1.0 - pow(1.0 - minf(p["t"] / 0.25, 1.0), 3.0)) - 3.0 * sin(minf(p["t"] / 0.25, 1.0) * PI)
		var big: bool = p["col"] == Color(1, 0.95, 0.6)
		var size := 8   # Silkscreen's own pixel size: on the art's grid (9 and 12 were off it)
		var txt: String = String(p["text"]) + ("!" if big and String(p["text"]).is_valid_int() else "")
		var col: Color = Color(1, 0.7, 0.3) if big else p["col"]
		var at3: Vector2 = (p["pos"] + Vector2(-6, -lift)).round()
		for off in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
			_fx.draw_string(FONT, at3 + off, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(0.1, 0.08, 0.06, a))
		_fx.draw_string(FONT, at3, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(col, a))


## Sparks flying out from a point (n of them, at up to `speed`, falling with `grav`).
func _burst(at: Vector2, col: Color, n: int, speed: float, life: float, grav: float, size: float) -> void:
	for k in n:
		var a := randf() * TAU
		var v := Vector2(cos(a), sin(a) * 0.7) * speed * randf_range(0.4, 1.0) + Vector2(0, -speed * 0.35)
		_parts.append({"pos": at, "vel": v, "t": 0.0, "life": life * randf_range(0.7, 1.1), "col": col.lerp(Color.WHITE, randf() * 0.35), "size": size, "grav": grav})


## A ring that widens and fades.
func _ring(at: Vector2, col: Color, r: float, life: float) -> void:
	_rings.append({"pos": at, "t": 0.0, "life": life, "r": r, "col": col})


## Motes rising from a creature's feet (healing, levelling up, ready to evolve).
func _rise(at: Vector2, col: Color, n: int) -> void:
	for k in n:
		_parts.append({"pos": at + Vector2(randf_range(-9, 9), randf_range(-4, 2)), "vel": Vector2(randf_range(-4, 4), -randf_range(18, 34)),
			"t": -randf() * 0.25, "life": randf_range(0.6, 0.95), "col": col.lerp(Color.WHITE, randf() * 0.4), "size": 1.0, "grav": 0.0})


var _portraits := {}


## A creature's small square portrait, or null when its form has none yet.
func portrait_of(form: String) -> Texture2D:
	if not _portraits.has(form):
		var path := "res://assets/sprites/arena/%s/portrait.png" % form
		_portraits[form] = load(path) if ResourceLoader.exists(path) else null
	return _portraits[form]


func _draw_hud() -> void:
	_hud.get_node("CrewPortraitFinish").clear()
	# One look for every screen (scripts/ui/ui_style.gd, Codex's title and pause menu colours), laid
	# out the way Explorers of Sky lays its dungeon out: the floor and the team at the top left, the
	# message box at the bottom with names in colour, the map at the top right. Claude, 2026-10-10.
	if ents.is_empty():
		return
	var h := _hud
	if _flash > 0.0:
		h.draw_rect(Rect2(0, 0, 1152, 648), Color(1, 1, 1, _flash * 2.0))   # a strong hit flashes the screen
	if cutscene:
		# A scene: cinema bars and its lines only, as Explorers of Sky clears its HUD for a cutscene.
		# An unseen voice dims the room (boss_intro.gd sets intro["dim"]).
		var dim: float = intro.get("dim", 0.0)
		if dim > 0.0:
			h.draw_rect(Rect2(0, 0, 1152, 648), Color(0.02, 0.03, 0.06, dim))
		h.draw_rect(Rect2(0, 0, 1152, 54), Color(0, 0, 0, 0.92))
		h.draw_rect(Rect2(0, 594, 1152, 54), Color(0, 0, 0, 0.92))
		if not talk.is_empty():
			var sbox := Rect2(196, 446, 760, 116)
			var sface: Texture2D = UI.dialogue_portrait(String(talk[0][2])) if talk[0].size() > 2 else null
			UI.dialogue(h, sbox, String(talk[0][0]), String(talk[0][1]), sface, Time.get_ticks_msec() / 1000.0, 20, _face_of(talk[0]))
		if intro.has("wipe_at"):
			# Into the fight: streaks of light race across the screen, thicker and brighter as it goes.
			var wt: float = (Time.get_ticks_msec() - int(intro["wipe_at"])) / 700.0
			var rng := RandomNumberGenerator.new()
			rng.seed = 77
			for k in 34:
				var y := rng.randf_range(0.0, 648.0)
				var speed := rng.randf_range(0.8, 1.6)
				var x := -400.0 + (wt * speed + rng.randf()) * 1700.0
				var thick := 3.0 if rng.randf() < 0.7 else 6.0
				h.draw_rect(Rect2(x - 360.0, y, 360.0, thick), Color(0.85, 0.9, 1.0, 0.35 + 0.5 * wt))
				h.draw_rect(Rect2(x - 120.0, y, 120.0, thick), Color(1, 1, 1, 0.6 + 0.4 * wt))
			h.draw_rect(Rect2(0, 0, 1152, 648), Color(1, 1, 1, clampf((wt - 0.6) * 2.0, 0.0, 1.0)))
		return
	var since: float = (Time.get_ticks_msec() - int(_banner["at"])) / 1000.0
	if since < 2.2 and _banner["text"] != "":
		var a: float = clampf(minf(since / 0.15, (2.2 - since) / 0.4), 0.0, 1.0)
		h.draw_rect(Rect2(0, 226, 1152, 100), Color(UI.PANEL, 0.78 * a))
		h.draw_rect(Rect2(0, 226, 1152, 2), Color(UI.EDGE, a))
		h.draw_rect(Rect2(0, 324, 1152, 2), Color(UI.EDGE, a))
		UI.say(h, Vector2(0, 292), _banner["text"], "title", Color(_banner["col"], a), 1152, HORIZONTAL_ALIGNMENT_CENTER)   # place names: the title face
		if _banner["sub"] != "":
			UI.say(h, Vector2(0, 316), String(_banner["sub"]), "label", Color(UI.TEXT, 0.85 * a), 1152, HORIZONTAL_ALIGNMENT_CENTER)
	# The floor and the lantern.
	UI.panel(h, Rect2(6, 6, 346, 54))
	UI.say(h, Vector2(28, 44), "B%dF" % floor_n, "button", UI.EDGE_LIGHT)
	UI.text(h, Vector2(104, 29), "Lantern", 15, UI.MUTED)
	UI.bar(h, Rect2(104, 36, 170, 9), light / LIGHT_MAX, UI.LIGHT)
	UI.text(h, Vector2(282, 46), "%d" % int(light), 17, UI.LIGHT)
	# The team: name, level, health, and a sliver of the way to evolving.
	var team: Array = ents.filter(func(e: Dictionary) -> bool: return e["team"] == 0)
	UI.panel(h, Rect2(6, 62, 346, 56 + 50 * team.size()))
	var y := 76.0
	for e in team:
		var k: float = float(e["hp"]) / e["max_hp"]
		var down: bool = e["hp"] <= 0
		# Its portrait (tools/arena/build_portraits.py: a 48 px square cut from its own front sprite).
		var face := portrait_of(e["form"])
		h.draw_rect(Rect2(28, y + 1, 48, 48), Color(UI.PORTRAIT_BG, 0.55) if down else UI.PORTRAIT_BG)
		if face != null:
			h.draw_texture(face, Vector2(28, y + 1), Color(0.45, 0.45, 0.45, 0.8) if down else Color.WHITE)
		h.draw_rect(Rect2(28, y + 1, 48, 48), UI.EDGE_LIGHT if e == ents[0] else UI.EDGE, false, 1.0)
		UI.text(h, Vector2(84, y + 20), String(e["name"]), 19, UI.HP_LOW if down else (UI.EDGE_LIGHT if e == ents[0] else UI.TEXT))
		var tag := "Lv %d" % level_of(e["line"]) + ("" if e == ents[0] else "   IQ %d" % iq_of(e))
		UI.say(h, Vector2(84, y + 20), tag, "label", UI.MUTED, 246, HORIZONTAL_ALIGNMENT_RIGHT)
		UI.bar(h, Rect2(84, y + 27, 170, 9), k, UI.hp_col(k))
		UI.say(h, Vector2(262, y + 38), "%d/%d" % [e["hp"], e["max_hp"]], "number", UI.TEXT)
		if e["stage"] < 2:
			var g: float = evo_progress(e["line"], e["stage"])
			h.draw_rect(Rect2(84, y + 40, 170, 3), Color(0, 0, 0, 0.5))
			h.draw_rect(Rect2(84, y + 40, 170 * g, 3), UI.EVO if g < 1.0 else UI.TEXT)
		y += 50.0
	var bag_n := 0
	for kk in bag:
		bag_n += bag[kk]
	UI.text(h, Vector2(30, y + 20), "Bag %d    Orders: %s" % [bag_n, String(TACTIC_NAMES[tactic]).capitalize()], 15, UI.MUTED)
	if boss_alive() and boss_met:
		var bb: Dictionary = ents[boss]
		UI.panel(h, Rect2(396, 10, 360, 46))
		UI.text(h, Vector2(396, 32), String(bb["name"]), 19, UI.FOE, 360, HORIZONTAL_ALIGNMENT_CENTER)
		UI.bar(h, Rect2(412, 40, 328, 9), float(bb["hp"]) / bb["max_hp"], UI.HP_LOW)
	# The leader's moves, two by two at the bottom left.
	var lead: Dictionary = ents[0]
	for s in lead["moves"].size():
		var m: String = lead["moves"][s]
		var box := Rect2(8 + (s % 2) * 164, 528 + (s / 2) * 58, 160, 54)
		var ready: bool = lead["cds"].get(m, 0) == 0
		UI.panel(h, box, 0.9 if ready else 0.7)
		if not ready:
			h.draw_rect(box.grow(-12.0), Color(0, 0, 0, 0.35))
		# The move's essence, in Hollowtide's own icon (tools/ui/build_icons.py), and its key.
		var ess_icon := UI.essence_icon(_ess_name(m, lead))
		if ess_icon != null:
			h.draw_texture(ess_icon, box.position + Vector2(14, 11), Color(1, 1, 1, 1.0 if ready else 0.4))
		UI.text(h, box.position + Vector2(0, 19), "J" if s == 0 else str(s), 14, UI.EDGE_LIGHT if ready else UI.MUTED, 144, HORIZONTAL_ALIGNMENT_RIGHT)
		UI.text(h, box.position + Vector2(50, 25), String(Arena.MOVES[m]["name"]), 17, Color(UI.TEXT, 1.0 if ready else 0.55), 96)
		var r := move_reach(m)
		var sub: String = ("%s %d" % [String(r["kind"]).capitalize(), r["n"]]) if ready else ("%d turn%s" % [lead["cds"][m], "" if lead["cds"][m] == 1 else "s"])
		if Arena.MOVES[m].get("heal", 0) > 0 and ready:
			sub = "Heal"
		UI.text(h, box.position + Vector2(50, 42), sub, 14, UI.MUTED if ready else UI.HP_MID, 108)
	# The message box (hidden while a scene's dialogue is showing), names in colour.
	if talk.is_empty():
		var lb := Rect2(342, 526, 600, 108)
		UI.panel(h, lb, 0.86)
		var marks := {}
		for e in ents:
			if not marks.has(e["name"]):
				marks[e["name"]] = UI.ALLY if e["team"] == 0 else UI.FOE
		var shown: Array = log_lines.slice(maxi(0, log_lines.size() - 4))
		for k in shown.size():
			UI.rich(h, lb.position + Vector2(24, 32 + k * 21), shown[k], 16, marks, 0.6 + 0.4 * float(k + 1) / shown.size(), 568)
	# The keys, short; the full list is under the menu's Controls.
	for k in 3:
		UI.text(h, Vector2(946, 546 + k * 17), ["J attack   1 2 3 moves", "I bag   T orders   Z rest", "E stairs   Tab autopilot"][k], 14, Color(UI.MUTED, 0.85), 194, HORIZONTAL_ALIGNMENT_RIGHT)
	# A scene's dialogue.
	if not talk.is_empty():
		var box := Rect2(196, 412, 760, 116)
		var face: Texture2D = UI.dialogue_portrait(String(talk[0][2])) if talk[0].size() > 2 else null
		UI.dialogue(h, box, String(talk[0][0]), String(talk[0][1]), face, Time.get_ticks_msec() / 1000.0, 20, _face_of(talk[0]))
	# A beaten creature asking to join.
	if asking >= 0 and asking < ents.size():
		var ask_box := Rect2(336, 196, 480, 88)
		UI.panel(h, ask_box, 0.96)
		UI.text(h, ask_box.position + Vector2(20, 34), "%s wants to join your team" % String(ents[asking]["name"]), 21, UI.EDGE_LIGHT, 440)
		UI.text(h, ask_box.position + Vector2(20, 66), "Y  welcome it          N  let it go", 18, UI.TEXT, 440)
	if bag_open:
		var kinds: Array = bag.keys()
		var box := Rect2(336, 120, 480, 64 + 40 * maxi(1, kinds.size()))
		UI.panel(h, box, 0.96)
		UI.text(h, box.position + Vector2(20, 32), "Bag", 22, UI.EDGE_LIGHT)
		UI.text(h, box.position + Vector2(20, 32), "W/S choose   J use   I close", 14, UI.MUTED, 440, HORIZONTAL_ALIGNMENT_RIGHT)
		if kinds.is_empty():
			UI.text(h, box.position + Vector2(20, 70), "Empty", 18, UI.MUTED)
		for k in kinds.size():
			var it: Dictionary = item_info(kinds[k])
			var yy: float = box.position.y + 74 + k * 40
			if k == bag_sel:
				h.draw_rect(Rect2(box.position.x + 8, yy - 26, box.size.x - 16, 36), UI.FOCUS)
				h.draw_rect(Rect2(box.position.x + 8, yy - 26, box.size.x - 16, 36), UI.EDGE_LIGHT, false, 1.0)
			var it_icon := UI.item_icon(String(kinds[k]))
			if it_icon != null:
				h.draw_texture(it_icon, Vector2(box.position.x + 14, yy - 24))
			else:
				h.draw_circle(Vector2(box.position.x + 30, yy - 8), 7.0, it["col"])
			UI.text(h, Vector2(box.position.x + 54, yy), "%s  x%d" % [String(it["name"]), bag[kinds[k]]], 18, UI.TEXT, 190)
			UI.text(h, Vector2(box.position.x + 248, yy), String(it["what"]), 14, UI.MUTED, 216)
	if teach_kind != "":
		var rows := teach_rows()
		var tbox := Rect2(336, 120, 480, 84 + 32 * maxi(1, rows.size()))
		UI.panel(h, tbox, 0.96)
		var title: String = ("%s: %s" % [ents[teach_learner]["name"], Arena.MOVES[teach_kind.get_slice(":", 1)]["name"]]) if teach_kind.begins_with("learn:") else item_info(teach_kind)["name"]
		UI.text(h, tbox.position + Vector2(20, 32), title, 21, UI.EDGE_LIGHT, 440)
		UI.text(h, tbox.position + Vector2(20, 56), "Who learns it?" if teach_learner < 0 else "It knows four moves. Forget one?", 16, UI.TEXT, 300)
		UI.text(h, tbox.position + Vector2(20, 56), "W/S choose   J pick   Esc close", 14, UI.MUTED, 440, HORIZONTAL_ALIGNMENT_RIGHT)
		for k in rows.size():
			var yy: float = tbox.position.y + 92 + k * 32
			if k == teach_sel:
				h.draw_rect(Rect2(tbox.position.x + 8, yy - 21, tbox.size.x - 16, 28), UI.FOCUS)
				h.draw_rect(Rect2(tbox.position.x + 8, yy - 21, tbox.size.x - 16, 28), UI.EDGE_LIGHT, false, 1.0)
			UI.text(h, Vector2(tbox.position.x + 24, yy), String(rows[k]["text"]).capitalize(), 17, UI.TEXT if rows[k]["ok"] else UI.FOE, 430)
	# The minimap: explored floor, the stairs once seen, your team, the wild creatures in sight.
	var mm := Vector2(1136 - data["w"] * 3, 44)
	UI.panel(h, Rect2(mm - Vector2(8, 8), Vector2(data["w"] * 3, data["h"] * 3) + Vector2(16, 16)), 0.55)
	for ty in data["h"]:
		for tx in data["w"]:
			var k2: int = ty * data["w"] + tx
			if explored[k2] == 1 and data["tiles"][k2] == Gen.FLOOR:
				h.draw_rect(Rect2(mm + Vector2(tx, ty) * 3, Vector2(3, 3)), Color(0.55, 0.7, 0.85, 0.55))
	for it in floor_items:
		if explored[it["pos"].y * data["w"] + it["pos"].x] == 1:
			h.draw_rect(Rect2(mm + Vector2(it["pos"]) * 3, Vector2(3, 3)), item_info(it["kind"])["col"])
	var st: Vector2i = data["stairs"]
	if explored[st.y * data["w"] + st.x] == 1:
		h.draw_rect(Rect2(mm + Vector2(st) * 3 - Vector2(1, 1), Vector2(5, 5)), Color(1, 0.85, 0.3))
	for e in ents:
		if e["hp"] <= 0:
			continue
		if e["team"] == 1 and not _sees(ents[0]["pos"], e["pos"]) or e.get("hidden", false):
			continue
		h.draw_rect(Rect2(mm + Vector2(e["pos"]) * 3 - Vector2(1, 1), Vector2(4, 4)), Color("#ffb347") if e == ents[0] else (Color("#7fd0ff") if e["team"] == 0 else Color("#ff5a4a")))


func _say(text: String) -> void:
	log_lines.append(text)
	if log_lines.size() > 40:
		log_lines.pop_front()


## Play one of the dungeon's ElevenLabs sounds (assets/audio/sfx/dungeon/<name>.wav, built at
## 432 Hz by tools/audio/build_dungeon_sfx.py). The last sound of each name is kept in last_sfx so
## the checks can see what played.
func _sfx(name: String, db: float) -> void:
	last_sfx[name] = turn
	_play("res://assets/audio/sfx/dungeon/%s.wav" % name, db)


func _play(path: String, db: float) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.volume_db = db
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)
