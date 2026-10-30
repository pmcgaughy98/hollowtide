extends RefCounted
## Art slots: the Wayline Tower's parts (Claude, 2026-10-27, docs/design/wayline-tower-2026-10-27/TOWER_DESIGN.md
## sections 5, 10 and 11). Owner lane: T. The door part, the depot, keeps the old Hall's id and row
## (town.building.hall in town_buildings.gd, lane B); every other piece of the tower is here.
##
## The tower is one 432 x 720 frame (TowerParts.FRAME) assembled from these parts in a fixed order
## (TowerParts.PARTS). "frame_at" is where a body part's top-left sits in that frame; a part is painted at exactly its
## size and nothing outside it, and where two parts overlap the upper one owns the seam (its 3 px contact shadow is
## painted on it). The placeholder of every row is its coded blockout (scripts/town/tower_parts.gd:paint_slot), ported
## from mock_tower.py and laid out in mock_parts_sheet.png. One locked palette family for the whole tower,
## wayline_tower: the town's stone, timber, root, moss, brass, amber and bronze, ink #0b0e11 and the courier's teal
## #2d9e9f #12837f #07515c #00313a; 32 colours at most per part. Light from the upper left on fixed shading columns.
## Coded at runtime, never painted: the waylines, the hoist rope, the lamp's chain sway and glow, chimney smoke, the
## long shadow, the Route Board's lit pegs, and the parcel and cradle motion.
##
## Batches (section 11): Codex cx-11 the key; cx-12 depot, gable, root_foot, yard, rise_stair; cx-13 drum, hoist,
## chute, root_vein, galleries; cx-14 reel_back, ring_front, reach, lamp, vane, bell. Grok: route_lantern,
## wayline_post, basket, cradle, parcel. The Reach, the Waiting Lamp, the Route Board, the First Post and the dark
## lantern are working labels until Preston renames or cuts them.

const _PAL := {"family": "wayline_tower", "max": 32, "lock": true}
const _PAL_SMALL := {"family": "wayline_tower", "max": 24, "lock": true}
const _HOOK := "res://scripts/town/tower_parts.gd:paint_slot"
const _COMMON := "Part of the Wayline Tower: read TOWER_DESIGN.md and the key (town.building.hall.key) first. Paint exactly this cell, lit from the upper left, from the wayline_tower palette only, with no outer outline (the game rims the tower). "

const SLOTS := {
	"town.building.hall.key": {
		"owner": "codex", "kind": "building", "status": "placeholder", "lane": "T", "census": "WT00",
		"file": "res://assets/slots/town/building/hall_key.png",
		"size": Vector2i(216, 360), "anchor": Vector2i(108, 359), "anchor_mode": "foot", "edges": "all",
		"states": {"static": [1, 0]}, "palette": {"family": "wayline_tower", "max": 41, "lock": true},
		"brief": "The whole Wayline Tower at half size (432 x 720 shown as 216 x 360): the style key every part is painted to. A rooted river-stone tower built in eras round a living root, the Reach, that climbs the left face and curls over the top to hold the Waiting Lamp on its chain right above the double door. Match the blockout's layout and silhouette exactly; settle materials, light and the shading columns here once.",
		"placeholder": _HOOK,
		"notes": "refs only: never installed and never placed; the parts are painted to it (batch cx-11)",
	},
	"town.building.hall.drum": {
		"owner": "codex", "kind": "building", "status": "placeholder", "lane": "T", "census": "WT01",
		"file": "res://assets/slots/town/building/hall_drum.png",
		"size": Vector2i(225, 236), "anchor": Vector2i.ZERO, "anchor_mode": "top_left", "frame_at": Vector2i(104, 368),
		"edges": "all", "states": {"static": [1, 0]}, "palette": _PAL,
		"brief": _COMMON + "The Sorting Drum: the cream river-stone cylinder on the depot's deck, its own contact shadow on that deck, a root-beam ring, three round lit windows, the 6 x 3 sorting-cubby wall (two dark and empty), the hoist door on its right flank, moss on the lower courses, and its round deck seen from above with a working landing (rail, crate, parcel) on the right.",
		"placeholder": _HOOK,
		"notes": "order 2; overlaps the depot's roof deck and owns that seam (batch cx-13)",
	},
	"town.building.hall.hoist": {
		"owner": "codex", "kind": "building", "status": "placeholder", "lane": "T", "census": "WT02",
		"file": "res://assets/slots/town/building/hall_hoist.png",
		"size": Vector2i(88, 56), "anchor": Vector2i.ZERO, "anchor_mode": "top_left", "frame_at": Vector2i(304, 460),
		"edges": "all", "states": {"turn": [2, 4]}, "palette": _PAL,
		"brief": _COMMON + "The hoist jib out of the drum's right flank: a root-wood stub, a timber arm with iron straps, a diagonal brace and the brass pulley block at its end. Two frames turn the pulley's sheave while the rope runs (the rope and basket are coded).",
		"placeholder": _HOOK,
		"notes": "order 3; the rope hangs from TowerParts.PULLEY (batch cx-13)",
	},
	"town.building.hall.galleries": {
		"owner": "codex", "kind": "building", "status": "placeholder", "lane": "T", "census": "WT03",
		"file": "res://assets/slots/town/building/hall_galleries.png",
		"size": Vector2i(217, 206), "anchor": Vector2i.ZERO, "anchor_mode": "top_left", "frame_at": Vector2i(88, 252),
		"edges": "all", "states": {"static": [1, 0]}, "palette": _PAL,
		"brief": _COMMON + "The Galleries: a timber-and-plaster drum set left of the stone drum, stone under the plaster, timber bands and posts, five round shuttered lit windows in a 2-1-2 pattern, the timber walkway wrapping the front right where the parcel chute starts, two empty flyer landing boards and a brass ring perch on the left face, and its deck.",
		"placeholder": _HOOK,
		"notes": "order 4; owns its seam on the drum's deck (batch cx-13)",
	},
	"town.building.hall.root_vein": {
		"owner": "codex", "kind": "building", "status": "placeholder", "lane": "T", "census": "WT04",
		"file": "res://assets/slots/town/building/hall_root_vein.png",
		"size": Vector2i(60, 296), "anchor": Vector2i.ZERO, "anchor_mode": "top_left", "frame_at": Vector2i(80, 326),
		"edges": "all", "states": {"static": [1, 0]}, "palette": _PAL,
		"brief": _COMMON + "The Climb: the living root running up the tower's left face in three runs, with worn treads every few px, rootlets gripping the stone, two knots, ink lips where it dives into the stone, and moss. An overlay that hides the depot to drum and drum to galleries seams on the left.",
		"placeholder": _HOOK,
		"notes": "order 5 (batch cx-13)",
	},
	"town.building.hall.chute": {
		"owner": "codex", "kind": "building", "status": "placeholder", "lane": "T", "census": "WT05",
		"file": "res://assets/slots/town/building/hall_chute.png",
		"size": Vector2i(88, 290), "anchor": Vector2i.ZERO, "anchor_mode": "top_left", "frame_at": Vector2i(244, 336),
		"edges": "all", "states": {"static": [1, 0]}, "palette": _PAL,
		"brief": _COMMON + "The parcel chute: a timber trough with brass edges and iron brackets running from the galleries' walkway down the drum's front right to a bin on the depot's deck, with a parcel waiting at the spout. An overlay that hides the right-hand seams.",
		"placeholder": _HOOK,
		"notes": "order 6; the sliding parcel is coded (batch cx-13)",
	},
	"town.building.hall.gable": {
		"owner": "codex", "kind": "building", "status": "placeholder", "lane": "T", "census": "WT06",
		"file": "res://assets/slots/town/building/hall_gable.png",
		"size": Vector2i(104, 53), "anchor": Vector2i.ZERO, "anchor_mode": "top_left", "frame_at": Vector2i(164, 560),
		"edges": "all", "states": {"static": [1, 0]}, "palette": _PAL,
		"brief": _COMMON + "The Route Board gable over the arch: an arched stone gable with a moss lip and brick ends, holding a brass board with three waymark arms meeting at a knot and 8 dark peg sockets (two and three along the arms, one at the knot). Paint the sockets dark: the game lights the pegs.",
		"placeholder": _HOOK,
		"notes": "order 7; peg sockets at TowerParts.route_pegs() (batch cx-12)",
	},
	"town.building.hall.reel_back": {
		"owner": "codex", "kind": "building", "status": "placeholder", "lane": "T", "census": "WT07",
		"file": "res://assets/slots/town/building/hall_reel_back.png",
		"size": Vector2i(225, 93), "anchor": Vector2i.ZERO, "anchor_mode": "top_left", "frame_at": Vector2i(88, 198),
		"edges": "all", "states": {"static": [1, 0]}, "palette": _PAL,
		"brief": _COMMON + "The Reel Deck ring's back half (planks, radial joints, the back rail) and the dispatcher's loft standing in its middle: timber and brass, one big round lit window with three spokes, under a moss dome.",
		"placeholder": _HOOK,
		"notes": "order 8 (batch cx-14)",
	},
	"town.building.hall.reach": {
		"owner": "codex", "kind": "building", "status": "placeholder", "lane": "T", "census": "WT08",
		"file": "res://assets/slots/town/building/hall_reach.png",
		"size": Vector2i(104, 300), "anchor": Vector2i.ZERO, "anchor_mode": "top_left", "frame_at": Vector2i(128, 24),
		"edges": "all", "states": {"static": [1, 0]}, "palette": _PAL,
		"brief": _COMMON + "The Reach: the living root rising through the deck's moss collar with a gentle S and a flared foot, then curling over to the right like a shepherd's crook to hold the lamp's chain on the door axis (the hook at frame 216, 96). Rootlets binding the loft, three knots, moss on the lit side and along the top of the curl, three worn brass bands, two small leaf tufts and the chain hook.",
		"placeholder": _HOOK,
		"notes": "order 9 (batch cx-14)",
	},
	"town.building.hall.ring_front": {
		"owner": "codex", "kind": "building", "status": "placeholder", "lane": "T", "census": "WT09",
		"file": "res://assets/slots/town/building/hall_ring_front.png",
		"size": Vector2i(232, 60), "anchor": Vector2i.ZERO, "anchor_mode": "top_left", "frame_at": Vector2i(84, 286),
		"edges": "all", "states": {"static": [1, 0]}, "palette": _PAL,
		"brief": _COMMON + "The Reel Deck ring's front half: planks, the rim face with its brass band, the front rail at creature hip height, the 7 brass sheaves where the waylines tie off (TowerParts.sheave), and the moss collar where the Reach rises. Leave the loft's footprint clear.",
		"placeholder": _HOOK,
		"notes": "order 10 (batch cx-14)",
	},
	"town.building.hall.route_lantern": {
		"owner": "grok", "kind": "building", "status": "placeholder", "lane": "T", "census": "WT10",
		"file": "res://assets/slots/town/building/hall_route_lantern.png",
		"size": Vector2i(12, 20), "anchor": Vector2i(6, 0), "anchor_mode": "top_left", "edges": ["top"],
		"states": {"lit": [3, 6], "dark": [1, 0], "quiet": [1, 0]}, "palette": _PAL_SMALL,
		"brief": _COMMON + "A route lantern: a small brass hand lantern hung by its ring, one under each of the seven sheaves. Lit flickers over 3 frames; dark is unlit glass while the route is idle; quiet is dusty grey glass with no wick for the route that went quiet (an absence, never a ghost).",
		"placeholder": _HOOK,
		"notes": "order 11; seven are hung at TowerParts.lantern_at(i), states from the story (Grok's set)",
	},
	"town.building.hall.bell": {
		"owner": "codex", "kind": "building", "status": "placeholder", "lane": "T", "census": "WT11",
		"file": "res://assets/slots/town/building/hall_bell.png",
		"size": Vector2i(56, 90), "anchor": Vector2i.ZERO, "anchor_mode": "top_left", "frame_at": Vector2i(40, 232),
		"edges": "all", "states": {"rest": [1, 0], "swing": [4, 8]}, "palette": _PAL,
		"brief": _COMMON + "Stillwade's flood bell off the deck's left end: a timber gallows with a moss-topped hood, the bronze bell on an iron yoke, and its rope hanging down. Swing moves the bell and rope 2 px each way over 4 frames.",
		"placeholder": _HOOK,
		"notes": "order 12 (batch cx-14)",
	},
	"town.building.hall.lamp": {
		"owner": "codex", "kind": "building", "status": "placeholder", "lane": "T", "census": "WT12",
		"file": "res://assets/slots/town/building/hall_lamp.png",
		"size": Vector2i(32, 42), "anchor": Vector2i.ZERO, "anchor_mode": "top_left", "frame_at": Vector2i(200, 92),
		"edges": "all", "states": {"lit": [4, 8], "dark": [1, 0]}, "palette": _PAL,
		"brief": _COMMON + "The Waiting Lamp on its short chain from the Reach's hook: the bail, a vented brass cap, amber panes with a centre bar, and the drip pan. The glass centre is the beacon (frame 216, 118). Lit flickers over 4 frames (the hot pane changes shape); dark is cold glass with one glint. The glow and the sway are coded.",
		"placeholder": _HOOK,
		"notes": "order 13; TowerParts.BEACON (batch cx-14)",
	},
	"town.building.hall.vane": {
		"owner": "codex", "kind": "building", "status": "placeholder", "lane": "T", "census": "WT13",
		"file": "res://assets/slots/town/building/hall_vane.png",
		"size": Vector2i(48, 44), "anchor": Vector2i.ZERO, "anchor_mode": "top_left", "frame_at": Vector2i(164, 0),
		"edges": "all", "states": {"flutter": [4, 6]}, "palette": _PAL,
		"brief": _COMMON + "The three-arm route vane at the apex (its tip is the tower's top, frame 183, 1) with a teal courier pennant and its fold, which lifts and drops 1 px over 4 frames.",
		"placeholder": _HOOK,
		"notes": "order 14; TowerParts.APEX (batch cx-14)",
	},
	"town.building.hall.root_foot": {
		"owner": "codex", "kind": "building", "status": "placeholder", "lane": "T", "census": "WT14",
		"file": "res://assets/slots/town/building/hall_root_foot.png",
		"size": Vector2i(96, 120), "anchor": Vector2i(48, 119), "anchor_mode": "foot", "frame_at": Vector2i(0, 600),
		"edges": "all", "states": {"static": [1, 0]}, "palette": _PAL,
		"brief": _COMMON + "The Great Root buttress, the tower's left ground wing: the root arching out of the turf onto the depot's left corner where the Climb starts, rootlets into the turf, treads, knots, moss and a stone at its foot.",
		"placeholder": _HOOK,
		"notes": "order 15; ground layer, sorts one step in front of the body (batch cx-12)",
	},
	"town.building.hall.yard": {
		"owner": "codex", "kind": "building", "status": "placeholder", "lane": "T", "census": "WT15",
		"file": "res://assets/slots/town/building/hall_yard.png",
		"size": Vector2i(72, 104), "anchor": Vector2i(36, 103), "anchor_mode": "foot", "frame_at": Vector2i(360, 616),
		"edges": "all", "states": {"winch": [2, 4]}, "palette": _PAL,
		"brief": _COMMON + "The hoist yard, the tower's right ground wing: a timber dock on legs with the capstan winch (its handle swings over 2 frames while the rope runs), parcels, a crate, a barrow wheel and a barrel with a teal lid.",
		"placeholder": _HOOK,
		"notes": "order 16; ground layer (batch cx-12)",
	},
	"town.prop.hall.wayline_post": {
		"owner": "grok", "kind": "prop", "status": "placeholder", "lane": "T", "census": "WT16",
		"file": "res://assets/slots/town/prop/hall_wayline_post.png",
		"size": Vector2i(24, 64), "anchor": Vector2i(12, 63), "anchor_mode": "foot",
		"states": {"strung": [1, 0], "waiting": [1, 0], "quiet": [1, 0]}, "palette": _PAL_SMALL,
		"anchors": {"pulley": Vector2i(12, 7)},
		"brief": "A wayline post where a cable from the tower comes down to the ground: a boulder foot, a timber post, a brass plate with the three-route mark as a shape (no letters), a brass pulley at the top (the cable ties to it) and a small lantern on a hook. Strung: lantern lit; waiting: unlit; quiet: dusty grey glass. wayline_tower palette.",
		"placeholder": _HOOK,
		"notes": "order 17; Tower Rise stands two at tiles (2, 10) and (24, 10) (Grok's set)",
	},
	"town.prop.hall.rise_stair": {
		"owner": "codex", "kind": "prop", "status": "placeholder", "lane": "T", "census": "WT17",
		"file": "res://assets/slots/town/prop/hall_rise_stair.png",
		"size": Vector2i(48, 96), "anchor": Vector2i(24, 95), "anchor_mode": "foot", "edges": "all",
		"states": {"static": [1, 0]}, "palette": _PAL,
		"brief": "The painted stair up Tower Rise's south cliff, two tiles wide and four tall: eight worn stone steps, roots through two risers and the three-route mark inlaid in the top step as a shape. Replaces the coded steps at tile (12, 9). wayline_tower palette.",
		"placeholder": _HOOK,
		"notes": "order 18 (batch cx-12)",
	},
	"town.prop.hall.basket": {
		"owner": "grok", "kind": "prop", "status": "placeholder", "lane": "T", "census": "WT18",
		"file": "res://assets/slots/town/prop/hall_basket.png",
		"size": Vector2i(16, 16), "anchor": Vector2i(8, 0), "anchor_mode": "top_left", "edges": ["top"], "outline": "runtime_rim",
		"states": {"full": [1, 0], "empty": [1, 0]}, "palette": _PAL_SMALL,
		"brief": "The hoist basket hung from its rope by the top middle: a wicker basket on two rope slings, carrying an oilcloth parcel when full. No outer outline (the game rims it). wayline_tower palette.",
		"placeholder": _HOOK,
		"notes": "order 19; rides the hoist rope, about 10 s a round trip (Grok's set)",
	},
	"town.prop.hall.cradle": {
		"owner": "grok", "kind": "prop", "status": "placeholder", "lane": "T", "census": "WT19",
		"file": "res://assets/slots/town/prop/hall_cradle.png",
		"size": Vector2i(12, 14), "anchor": Vector2i(6, 2), "anchor_mode": "top_left", "edges": ["top"], "outline": "runtime_rim",
		"states": {"loaded": [2, 4], "empty": [2, 4]}, "palette": _PAL_SMALL,
		"brief": "A cradle riding a wayline: a brass trolley wheel on the cable (its middle is the hang point), a twine sling and an oilcloth parcel (none when empty). The sling sways 1 px over 2 frames. No outer outline (the game rims it). wayline_tower palette.",
		"placeholder": _HOOK,
		"notes": "order 20; one rides each strung line about every 12 s (Grok's set)",
	},
	"town.prop.hall.parcel": {
		"owner": "grok", "kind": "prop", "status": "placeholder", "lane": "T", "census": "WT20",
		"file": "res://assets/slots/town/prop/hall_parcel.png",
		"size": Vector2i(10, 8), "anchor": Vector2i(5, 7), "anchor_mode": "foot", "edges": "all", "outline": "runtime_rim",
		"states": {"oilcloth": [1, 0], "paper": [1, 0]}, "palette": _PAL_SMALL,
		"brief": "A parcel sliding down the tower's chute: oilcloth with a moss-green top, or brown paper, tied with twine. No outer outline (the game rims it). wayline_tower palette.",
		"placeholder": _HOOK,
		"notes": "order 21; one slides down the chute every 12 to 20 s (Grok's set)",
	},
}
