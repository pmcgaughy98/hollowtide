extends RefCounted
## Art slots: Title and launch rows (Claude, 2026-10-26, placeholder factory contract). Owner lane: codex-wire: registered by lane U, wired by Codex in its own launch files.
## Rows use the fields of docs/design/placeholder-factory-2026-10-26/03-spec-format.md 2.1. ArtSlots
## (scripts/art/art_slots.gd) finds every .gd in this folder by itself, so a lane adds rows here and nothing else.
## size is one cell in file pixels; a keep row's legacy is today's file at that size. Kind defaults (alpha, edges,
## outline, tiling, light, forbid) live in ArtSlots.KINDS and are only written here when a row differs.

const SLOTS := {
	"title.backdrop.launch": {
		"owner": "codex",
		"kind": "backdrop",
		"status": "placeholder",
		"lane": "codex-wire",
		"census": "T01",
		"file": "res://assets/slots/title/backdrop/launch.png",
		"size": Vector2i(384, 216),
		"anchor": Vector2i(0, 0),
		"anchor_mode": "top_left",
		"states": {"static": [1, 0]},
		"palette": {"family": "night_bank", "max": 48},
		"tint": "#18172c",
		"brief": "The launch card's night: the river valley before the title, dark greens and river blues in a few calm bands, with no text.",
		"placeholder": "",
		"notes": "today a flat #18172c fill (opening_flow.gd:27); placeholder: that fill in 3 stepped bands",
	},
	"title.backdrop.village": {
		"owner": "codex",
		"kind": "backdrop",
		"status": "keep",
		"lane": "codex-wire",
		"census": "T04",
		"file": "res://assets/slots/title/backdrop/village.png",
		"legacy": "res://assets/sprites/menu/creature_village_2026_10_09.png",
		"size": Vector2i(256, 144),
		"drawn_at": 4.5,
		"anchor": Vector2i(0, 0),
		"anchor_mode": "top_left",
		"states": {"static": [1, 0]},
		"palette": {"family": "as_installed", "max": 0},
		"brief": "Finished Codex art, registered as it is; the loader serves today's file.",
		"placeholder": "",
		"notes": "drawn at 4.5x, not a whole scale (Preston call 8). Retired from the title 2026-10-27; kept as the reference for a future town on another map (Preston). The title now draws title.backdrop.highbank.",
	},
	# Claude, 2026-10-27 (Preston: "the town on the title screen has to be a real town in game", with Wayline Tower
	# prominent). Replaces the village on the title; creature_opening.gd draws it at 3x over the 1152 x 648 screen.
	"title.backdrop.highbank": {
		"owner": "codex",
		"kind": "backdrop",
		"status": "installed",
		"lane": "codex-wire",
		"census": "T16",
		"file": "res://assets/slots/title/backdrop/highbank.png",
		"size": Vector2i(384, 216),
		"drawn_at": 3,
		"anchor": Vector2i(0, 0),
		"anchor_mode": "top_left",
		"states": {"static": [1, 0]},
		"palette": {"family": "highbank_title", "max": 48},
		# shade_end: the title's canopy shade covers x 0 to 311, rows 0 to 49 (creature_opening.gd reads this); the
		# picture paints everything past it already shaded (the sky one band darker, the Stack darkened) to match.
		# Layout A (Claude, 2026-10-28): no lamp in frame, so the lamp anchor is gone; door is the giant's doors.
		"anchors": {"door": Vector2i(333, 160), "shade_end": Vector2i(312, 50)},
		"brief": "Highbank seen from across the river at the golden hour, the old title village's time of day and mood. Layout A of docs/design/vast-scale-2026-10-27/VAST_SCALE_DESIGN.md (the target is this slot's placeholder; the mock final/title_1x.png there still has the older off-centre crown and floating root). The Wayline Tower is the hero at its full 480 tiles, so only its foot fits: the round Stack (2.6 px a tile, west face at x 313) runs off the top and the right edge and comes down to Tower Rise on its two plinth steps (x 289 and 302 to the edge, foot on row 167), with brass rails on the ledges, the doors at the top of the Rise stair (x 327 to 339), the Low Reel deck at y 80 with its ring (no cables leave it here), and the great tree's root coming up out of the Rise at the first step's west corner, short roots gripping the ground either side, then up the steps and the Stack's west face off the top; no lamp in frame. Behind the town the great tree with its whole crown, one even dome centred on its trunk (x 130 to 288, top y 6), a short stretch of trunk and four limbs under it spreading both ways, painted only over sky and far hills, lit low from the west. Below, along the bluff, the edge of the woods and no buildings at all (the Tower stands alone; Preston, 2026-10-29), the Crossroads and the Rise stair under the Tower's doors, no waylines, cables or posts (Preston, 2026-10-29: \"get rid of those wires too\"), the bluff face with the switchbacks and the ferry dock, and the river in front. Keep the sky calm behind the wordmark (x 90 to 295, y 0 to 52; the crown there is only its dark body and a 1 px rim) and keep the Stack right of x 312, where the title's canopy shade stops; paint everything right of x 312 above row 50 already shaded (the sky one band darker, the Stack and root about x0.62) so it meets the shaded sky with no edge; the lower left (x 0 to 140, y 100 down) sits under the menu and its dark wash, so keep it quiet. No text.",
		"placeholder": "res://scripts/art/placeholders/title_highbank.gd:paint",
		"notes": "Placeholder (layout A, Preston 2026-10-28): the giant Tower's foot and the great tree painted in code by title_giants.gd from the vast-scale mock's numbers; the house slot pictures shrunk to 0.225 and placed from the Street's area data; sky, hills, bluff and river painted in code (45 colours, PALETTE in the painter). The old shrunken tower blockout is no longer drawn here. The tower names are working labels.",
	},
	"title.hud_piece.menu_cursor": {
		"owner": "grok",
		"kind": "hud_piece",
		"status": "placeholder",
		"lane": "codex-wire",
		"census": "T10",
		"file": "res://assets/slots/title/hud_piece/menu_cursor.png",
		"size": Vector2i(8, 9),
		"anchor": Vector2i(0, 4),
		"anchor_mode": "left_middle",
		"states": {"static": [1, 0]},
		"palette": {"family": "brass_ui", "max": 16},
		"brief": "The main menu's pointer: a small brass arrowhead pointing right, lit from the upper left.",
		"placeholder": "",
		"notes": "Polygon2D today (main_menu.gd:366); the bounce stays coded",
	},
}
