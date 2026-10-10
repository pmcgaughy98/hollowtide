extends RefCounted
## The move table for the arena and dungeon moves (Claude, 2026-10-09; Preston: "lets do it
## similar to [Pokemon's signature moves] rather than each pokemon having their own unique moves
## only they can use... it has to make sense for another pokemon to be able to use their move").
##
## This is Grok's rule from docs/creatures/DESIGN_RULES.md and move-body-gate.md (2026-10-02),
## carried from the old turn-based moves to the moves the arena and the dungeon use:
## - A move needs body parts. A creature may use or learn it only when its body has every one.
##   Essence is not permission, and a matching essence does not excuse a missing part.
## - A move whose parts only one line has is that line's own, by anatomy, not by a list.
##   Where a part crosses lines (claws, leaping legs, gliding sails) the move is a SHARED
##   SIGNATURE: characteristic of its first owner and still teachable, like Leaf Blade.
## - An ULTIMATE (the arena's line `signature`) takes the scene, is the final stage's alone,
##   and is never taught.
##
## Sources, per creature: G = Grok's move-body-gate.md (2026-10-02). A = Claude's read of the
## current approved arena art (2026-10-09). Grok confirmed the A parts on 2026-10-10 against
## assets/sprites/arena/<form>/se.png. Corrections: no springlegs on Cinderhide or Punchybun;
## Slagglass's glowing brick joints are a seam. Vocabulary unchanged. No new part names.

const PARTS := {
	# Kithflare line (A, confirmed 2026-10-10): clawed hands and feet, digitigrade leaping legs,
	# heat along the tail, a snout that spits. The lantern is on the tail from Sparkwick on.
	# The old signal body (marking, splittail) is not this art.
	"kithflare": ["claw", "springlegs", "hottail", "throat"],
	"sparkwick": ["claw", "springlegs", "hottail", "throat", "lantern"],
	"stormwick": ["claw", "springlegs", "hottail", "throat", "lantern"],
	# Tallowroot line (A): seed pods, roots; the husk and the club tail from stage 2.
	"tallowroot": ["seedpod", "roots"],
	"huskward": ["seedpod", "roots", "husk", "clubtail"],
	"rampartroot": ["seedpod", "roots", "husk", "clubtail"],
	# Rimefin line (G for Rimefin: fin, jaw; A for the 2026-10-09 remakes).
	"rimefin": ["fin", "jaw"],
	"riftfin": ["fin", "jaw"],
	"scourmaw": ["fin", "jaw"],
	# Cinderhide line (G). Confirmed 2026-10-10: Cinderhide's legs are short and planted, so the
	# proposed springlegs is off. Its orange back breaks stay `vent`, not a vent row and not
	# channels. Clinkerhide's raised orange crest is real; it still has no channels.
	"cinderhide": ["claw", "brow", "vent", "mouth", "ridge"],
	"clinkerhide": ["claw", "fusedbrow", "vent", "ventrow", "heavytail", "crest"],
	"ironvent": ["claw", "fusedbrow", "crest", "vent", "ventrow", "channels", "mouth", "ridge", "heavytail"],
	# Fusern line (G, confirmed 2026-10-10). Slagglass is the brick dome on buttress legs: no
	# shelf, no chamber, no mouth. The glowing joints between the bricks are a seam. Fusern's
	# legs are thin, not buttresses. Vitrecrag keeps the open chamber and the pour mouth.
	"fusern": ["shell", "hexedge", "seam"],
	"slagglass": ["shell", "buttress", "seam"],
	"vitrecrag": ["shell", "buttress", "chamber", "mouth"],
	# Preostmar line (G: rail on Oxbowarchon; A: the jade, the slabs, the Kingstone). G said slab
	# is not a part until the approved sprite is checked; it is checked here (A).
	"preostmar": ["jade"],
	"oathfen": ["jade", "slab"],
	"oxbowarchon": ["jade", "slab", "rail", "kingstone"],
	# Punchybun line (G: fist, tail, star). Springlegs confirmed 2026-10-10 on Sparkjab and
	# Starward (digitigrade, up on the toes). Punchybun is the round kit: short legs, no spring.
	"punchybun": ["fist", "tail", "star"],
	"sparkjab": ["fist", "tail", "star", "springlegs"],
	"starward": ["fist", "tail", "star", "springlegs"],
	# River Listener line (DESIGN_RULES: "paddles and gill plates, so calls and braces, not bites").
	"listener": ["paddle", "gillplate"],
	"caller": ["paddle", "gillplate"],
	"warden": ["paddle", "gillplate"],
	# Canvaswing line (A): flapping wings whose membranes are sails.
	"canvaswing": ["wing", "sail"],
	"windcut": ["wing", "sail"],
	"galeshear": ["wing", "sail"],
	# Dustkite line (A): gliding lizards: sail membranes (they glide, they do not flap), leaping
	# legs, and the whistle.
	"dustkite": ["sail", "springlegs", "whistle"],
	"waywhistle": ["sail", "springlegs", "whistle"],
	"highsignal": ["sail", "springlegs", "whistle"],
}

## What each arena move needs. G where Grok already ruled on the same move.
const NEEDS := {
	"claw": ["claw"],                        # Rake
	"ember_feint": ["hottail"],              # out through its own embers
	"fireball": ["throat"],                  # Ember Shot, spat
	"pounce": ["springlegs"],
	"wick_bolt": ["lantern"], "lantern_volley": ["lantern"], "lantern_tackle": ["lantern"],
	"seed": ["seedpod"],
	"root_snare": ["roots"], "burrow": ["roots"], "root_wall": ["roots"], "root_rampart": ["roots"],
	"club_slam": ["clubtail"],               # Tail Club: a club, not Ironvent's clinker tail (G: heavytail)
	"needle_bite": ["jaw"], "lunge": ["jaw"],
	"sinkhole": ["fin"], "riptide": ["fin"], # Silt Dive, Riptide
	"cinder_claw": ["claw"],                 # G
	"vent_barrage": ["channels"],            # G: the coordinated channels, Ironvent's alone
	"crest_ram": ["crest"],                  # G
	"vent_blast": ["vent"],                  # a short gout from the back vents; the vent row is not required
	"ember_pellet": ["seam"],                # G
	"molten_beam": ["chamber", "mouth"],     # G
	"glass_guard": ["shell"],
	"plate_lunge": ["shell", "buttress"],    # G
	"furnace_shard": ["shelf"],              # G. The shelf was designed off the roster; no body has one.
	"glass_spur": ["shelf"],                 # G. Same shelf. Not in any current kit.
	"molten_cannon": ["chamber", "mouth"],   # G
	"jade_lance": ["jade"], "ground_spikes": ["jade"], "stone_cocoon": ["jade"],
	"slab_vortex": ["slab"],
	"rail_shot": ["rail"], "rail_recoil": ["rail"], "kingstone_lift": ["rail", "kingstone"],
	"jab": ["fist"], "counter_jab": ["fist"],
	"static_dance": ["tail"], "star_guard": ["star"],
	"echo_tap": ["paddle"], "deep_brace": ["paddle"],
	"interrupt_call": ["gillplate"], "still_water": ["gillplate"],
	"shear": ["wing"], "downdraft": ["wing"], "lift": ["wing"],
	"sail_cover": ["sail"], "vantage": ["sail"],
	"whistle_dart": ["whistle"], "signal_mark": ["whistle"], "decoy_call": ["whistle"],
}


## The parts creature `form` is missing for move m (empty: it may use or learn it). A move with
## no entry is not gated yet (Grok's "Strike" rule).
static func missing(form: String, m: String) -> Array:
	var have: Array = PARTS.get(form, [])
	var out: Array = []
	for p in NEEDS.get(m, []):
		if not p in have:
			out.append(p)
	return out


static func can_learn(form: String, m: String) -> bool:
	return PARTS.has(form) and missing(form, m).is_empty()


## Every form whose body passes move m.
static func learners(m: String) -> Array:
	var out: Array = []
	for form in PARTS:
		if can_learn(form, m):
			out.append(form)
	return out


## The lines (by index in `lines`, the arena's LINES) whose forms can learn move m.
static func lines_of(m: String, lines: Array) -> Array:
	var out: Array = []
	for li in lines.size():
		for f in lines[li]["forms"]:
			if can_learn(f[0], m) and not li in out:
				out.append(li)
	return out


## Shared signatures: moves more than one line can honestly use.
static func shared(lines: Array) -> Array:
	var out: Array = []
	for m in NEEDS:
		if lines_of(m, lines).size() >= 2:
			out.append(m)
	return out
