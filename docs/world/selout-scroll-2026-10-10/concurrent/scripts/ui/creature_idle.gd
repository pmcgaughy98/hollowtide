extends RefCounted
## The big, detailed front idle animations from the game's first battle-screen days (Preston,
## 2026-10-10: "we're going to use the front view idle animations from when we were first trying to
## make the game with bigger models and in more detail... creature summary, evolving, or whatever").
## Eight frames each, 160 to 256 px, far richer than the dungeon sprites; one place that knows where
## they live, so the party screen, an evolution scene, a recruit card or a journal can all use them.
## Only forms whose idle matches the current design are listed: Riftfin's and Scourmaw's idles show
## the designs from before the October 9 remake and stay out until they are redrawn.
##   var frames := CreatureIdle.frames("kithflare")   # [] when the form has none
##   var box := CreatureIdle.box(frames)               # the union of their drawn pixels, for steady framing

const FOLDERS := {
	"kithflare": "res://assets/sprites/creatures/starter_material_detail_2026_10_05/kithflare_idle_tail_outline_2026_10_05/",
	# Sparkwick: the first-batch idle (idle_2026_10_05/109_kithflare2), which really moves, with its colour
	# drift fixed by snapping every frame to frame 0's palette (Preston, 2026-10-10: the texture-pass
	# idle that was here only shimmered its back).
	"sparkwick": "res://assets/sprites/creatures/idle_2026_10_10/sparkwick_palette_locked/",
	"stormwick": "res://assets/sprites/creatures/idle_2026_10_05/110_kithflare3/",
	"tallowroot": "res://assets/sprites/creatures/idle_2026_10_05/1701_tallowroot/",
	"huskward": "res://assets/sprites/creatures/idle_2026_10_05/1702_tallowroot2/",
	"rampartroot": "res://assets/sprites/creatures/idle_2026_10_05/1703_tallowroot3/",
	"rimefin": "res://assets/sprites/creatures/idle_2026_10_05/001_rimefin/",
}
const FPS := 5.0   # slower than the 8 the opening used: Preston, 2026-10-10, "the idle animations are too fast"

static var _cache := {}


static func frames(form: String) -> Array:
	if _cache.has(form):
		return _cache[form]
	var out: Array = []
	if FOLDERS.has(form):
		for k in 8:
			var path: String = FOLDERS[form] + "f%d.png" % k
			if ResourceLoader.exists(path):
				out.append(load(path))
	_cache[form] = out
	return out


## The smallest box holding every frame's drawn pixels, so the creature does not jump as it moves.
static func box(list: Array) -> Rect2i:
	var r := Rect2i()
	for tex in list:
		var used: Rect2i = (tex as Texture2D).get_image().get_used_rect()
		r = used if r.size == Vector2i.ZERO else r.merge(used)
	return r


static func frame_at(list: Array, t: float) -> Texture2D:
	return list[int(t * FPS) % list.size()] if not list.is_empty() else null
