extends Node2D
## Rooms inside Highbank's buildings (Claude, 2026-10-10; Preston: "do this for interiors too, I noticed
## main house and courier hall rooms were super small"). Walk in through the Home's or the Wayline Hall's
## door and the team stands in a room at the town's own scale (24 px tiles, the same creatures), painted
## in code like the dungeons (scripts/town/room_painter.gd), with things to use and the door back out.
## Codex's older courier-era rooms (scenes/courier_hall.tscn, courtyard_home.tscn) are untouched.
##   var room = load("res://scenes/town_room.tscn").instantiate(); room.room_id = "home"

const StoragePanel := preload("res://scripts/town/storage_panel.gd")
const StorageArt := preload("res://scripts/town/storage_room_art.gd")
const Objective := preload("res://scripts/town/objective.gd")
const Arena := preload("res://scripts/arena/arena_prototype.gd")
const Lines := preload("res://scripts/creatures/lines.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const GuildCrew := preload("res://scripts/town/guild_crew.gd")
const Painter := preload("res://scripts/town/room_painter.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const SceneKit := preload("res://scripts/town/scene_kit.gd")
const GuildScene := preload("res://scripts/town/guild_scene.gd")
const T := 24
const VIEW := Vector2i(384, 216)
const SCALE := 3.0
const STEP_TIME := 0.13
const WALK_FPS := 12.0
const DIRS := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1)]

## Each room: its size in tiles (walls included), its door (on the bottom wall), the furniture that
## blocks walking, and the spots that answer E. The texts are Claude's drafts. A spot's "what_if" is
## [story flag, text]: the text it shows once that flag is set (Claude, 2026-10-22, CR-02).
const ROOMS := {
	"storage": {"name": "Storage", "w": 17, "h": 13, "door": Vector2i(8,12), "town_door": "storage", "floor_top": 3,
		"exit_rect": Rect2i(7,12,3,1),
		"solid": [Rect2i(2,3,3,2), Rect2i(12,3,3,2), Rect2i(6,5,5,2), Rect2i(2,9,2,2), Rect2i(13,9,2,2)],
		"spots": [{"id": "store_counter", "rect": Rect2i(6,5,5,2), "name": "Storage", "service": "storage"}]},

	"home": {"name": "Home", "w": 14, "h": 10, "door": Vector2i(7, 9), "town_door": "home",
		"solid": [Rect2i(1, 2, 3, 2), Rect2i(9, 2, 4, 1), Rect2i(6, 4, 3, 2), Rect2i(1, 7, 2, 2), Rect2i(11, 6, 2, 2)],
		"spots": [
			{"id": "bed", "rect": Rect2i(1, 2, 3, 2), "name": "Moss Bed", "what": "Rest here and the day ends: the team wakes up whole."},
			{"id": "hearth", "rect": Rect2i(9, 2, 4, 1), "name": "Hearth", "what": "Warm stones and a kettle. The light the house is built round."},
			{"id": "table", "rect": Rect2i(6, 4, 3, 2), "name": "Table", "what": "A lantern, a map of the river, the parcel slip from the first job."},
			{"id": "shelf", "rect": Rect2i(1, 7, 2, 2), "name": "Shelf", "what": "Jars of reedberries and a stack of old Wayline reports."},
			{"id": "plants", "rect": Rect2i(11, 6, 2, 2), "name": "Planters", "what": "Clover and a stubborn fern. Someone waters them."}]},
	"hall": {"name": "Wayline Hall", "w": 22, "h": 14, "door": Vector2i(11, 13), "town_door": "hall",
		"solid": [Rect2i(7, 3, 8, 2), Rect2i(2, 2, 2, 1), Rect2i(18, 2, 2, 1), Rect2i(3, 6, 1, 1), Rect2i(18, 6, 1, 1), Rect2i(3, 10, 1, 1), Rect2i(18, 10, 1, 1),
			Rect2i(1, 8, 1, 3), Rect2i(20, 8, 1, 3), Rect2i(5, 7, 2, 2), Rect2i(15, 7, 2, 2), Rect2i(2, 12, 2, 1), Rect2i(18, 12, 2, 1),
			Rect2i(4, 6, 1, 1), Rect2i(17, 6, 1, 1)],
		"spots": [
			{"id": "counter", "rect": Rect2i(7, 3, 8, 2), "name": "Dispatch Counter", "what": "The dispatcher hands out the board's requests and takes reports.", "service": "jobs"},
			{"id": "notices", "rect": Rect2i(2, 2, 2, 1), "name": "Notice Wall", "what": "Sightings, closures, a warning about a crew poaching deliveries."},
			{"id": "roster", "rect": Rect2i(18, 2, 2, 1), "name": "Roster Board", "what": "Every team on the Wayline, by rank. Yours is near the bottom, for now."},
			{"id": "benches", "rect": Rect2i(1, 8, 1, 3), "name": "Bench", "what": "Where couriers wait for the river to settle."},
			{"id": "benches2", "rect": Rect2i(20, 8, 1, 3), "name": "Bench", "what": "Scratched initials and a forgotten glove."},
			{"id": "chart", "rect": Rect2i(5, 7, 2, 2), "name": "Chart Table", "what": "The river and its Hollows, pinned where couriers have gone. A new pin sits on the water near Highbank."},
			{"id": "scrolls", "rect": Rect2i(15, 7, 2, 2), "name": "Report Table", "what": "Reports waiting to be filed. One is stamped LATE in red."},
			{"id": "crates", "rect": Rect2i(2, 12, 2, 1), "name": "Parcels", "what": "Deliveries waiting for a runner."},
			{"id": "crates2", "rect": Rect2i(18, 12, 2, 1), "name": "Parcels", "what": "Undeliverable mail. The labels have washed out."}],
		# Down to the Hall floor (Preston, 2026-10-10: two floors, like the guild in Sky).
		"links": [{"rect": Rect2i(14, 10, 2, 2), "to": "hall_low", "at": Vector2i(24, 14), "facing": "w", "sfx": "stairs"}]},
	# The Hall floor, below the work floor (Claude, 2026-10-10; Preston chose two floors, like Sky's guild:
	# public work upstairs, the Guildmaster's chamber, the morning roll call, crew rooms and the mess hall
	# below). Taken from Sky as structure only. Names and lines are Claude's drafts for Preston.
	"hall_low": {"name": "Wayline Hall, lower floor", "w": 30, "h": 18, "door": Vector2i(-1, -1), "landing": Vector2i(24, 14), "hint": "Stairs up, bottom right",
		"solid": [Rect2i(9, 5, 1, 1), Rect2i(20, 5, 1, 1), Rect2i(9, 12, 1, 1), Rect2i(20, 12, 1, 1), Rect2i(3, 12, 6, 2),
			Rect2i(12, 2, 1, 1), Rect2i(17, 2, 1, 1), Rect2i(27, 2, 1, 1), Rect2i(1, 8, 1, 2)],
		"spots": [
			{"id": "chamber_door", "rect": Rect2i(14, 1, 2, 1), "name": "Postmaster's Chamber", "what": "Starward's door."},
			{"id": "rollcall", "rect": Rect2i(12, 7, 6, 4), "name": "Sorting Floor", "what": "The Wayline's mark, set in brass. Every morning the mail is sorted round it and the routes go out."},
			{"id": "duty", "rect": Rect2i(9, 1, 2, 1), "name": "Duty Board", "what": "Today's duties: the door watch, the kitchen, the sweeping. Your names aren't on it yet."},
			{"id": "window_w", "rect": Rect2i(3, 1, 2, 1), "name": "River Window", "what": "The Hall is cut into the bank. Through the glass the river runs a long way down."},
			{"id": "window_e", "rect": Rect2i(25, 1, 2, 1), "name": "River Window", "what": "Rain on the glass, and the far bank green after the flood."},
			{"id": "crew_room", "rect": Rect2i(0, 5, 1, 2), "name": "Crew Room", "what": "Bunks for the Hall's crew. Someone is snoring."},
			{"id": "runners_room", "rect": Rect2i(29, 5, 1, 2), "name": "Runners' Room", "what": "Runners only. The door is locked.",
				"what_if": ["runner", "Your bunks now. Rest here or go on."]},
			{"id": "mess", "rect": Rect2i(3, 12, 6, 2), "name": "Mess Hall", "what": "The long table. Supper is at the end of the day, for whoever made it back."},
			{"id": "hatch", "rect": Rect2i(1, 8, 1, 2), "name": "Kitchen Hatch", "what": "Something with river greens in it is simmering."},
			{"id": "shelf", "rect": Rect2i(27, 2, 1, 1), "name": "Supply Shelf", "what": "Rope, lantern oil, spare satchels, a jar of reedberries."}],
		"links": [{"rect": Rect2i(14, 1, 2, 1), "to": "chamber", "at": Vector2i(8, 8), "facing": "n", "sfx": "door"},
			{"rect": Rect2i(25, 13, 2, 2), "to": "hall", "at": Vector2i(13, 10), "facing": "w", "sfx": "stairs"},
			{"rect": Rect2i(29, 5, 1, 2), "to": "runners", "at": Vector2i(1, 5), "facing": "e", "sfx": "door", "needs": "runner"}]},
	# The runners' room, off the lower floor's east side: the team's own bunks once Starward names them
	# runners (Preston, 2026-10-10: "definitely want runners room"). Sky gives its hero a room in the guild.
	"runners": {"name": "Runners' Room", "w": 14, "h": 10, "door": Vector2i(-1, -1), "landing": Vector2i(1, 5), "hint": "The door leads back to the Hall",
		"solid": [Rect2i(3, 2, 2, 2), Rect2i(8, 2, 2, 2), Rect2i(11, 7, 2, 1), Rect2i(12, 4, 1, 2)],
		"spots": [
			{"id": "bed", "rect": Rect2i(3, 2, 2, 2), "name": "Your Bunk", "what": "Moss and a wool blanket. Rest here and the day ends: the team wakes up whole."},
			{"id": "bunk2", "rect": Rect2i(8, 2, 2, 2), "name": "The Other Bunk", "what": "Already claimed. There's a reedberry on the pillow."},
			{"id": "window", "rect": Rect2i(6, 1, 1, 1), "name": "Window", "what": "The river, and past it the road the flood covered."},
			{"id": "firstrun", "rect": Rect2i(10, 1, 2, 1), "name": "First Run", "what": "The way to Rootbank Warren, inked by hand, with a star where the parcel was found."},
			{"id": "chest", "rect": Rect2i(11, 7, 2, 1), "name": "Runner's Chest", "what": "A satchel strap, a whistle, and two brass Wayline pins."},
			{"id": "pegs", "rect": Rect2i(12, 4, 1, 2), "name": "Coat Pegs", "what": "Two empty pegs, waiting for satchels."}],
		"links": [{"rect": Rect2i(0, 5, 1, 2), "to": "hall_low", "at": Vector2i(28, 6), "facing": "w", "sfx": "door"}]},
	# Starward's chamber, behind the door at the back of the lower floor.
	"chamber": {"name": "Postmaster's Chamber", "w": 17, "h": 11, "door": Vector2i(-1, -1), "landing": Vector2i(8, 8), "hint": "The door leads back down",
		"solid": [Rect2i(7, 3, 3, 2), Rect2i(1, 2, 1, 1), Rect2i(15, 2, 1, 1)],   # 17 wide: tile 8 is the middle
		"spots": [
			{"id": "dais", "rect": Rect2i(7, 3, 3, 2), "name": "The Dais", "what": "Starward's cushion, worn flat in the middle."},
			{"id": "map", "rect": Rect2i(3, 1, 4, 1), "name": "The Whole River", "what": "Every Hollow the Wayline knows, from the springs to the sea. Most of the map is still blank."},
			{"id": "window", "rect": Rect2i(10, 1, 4, 1), "name": "Window", "what": "The whole of Highbank's bank below, and the river past it."},
			{"id": "keepsakes", "rect": Rect2i(1, 2, 1, 1), "name": "Keepsakes", "what": "Old satchels, a cracked lantern, a medal shaped like a star."},
			{"id": "books", "rect": Rect2i(15, 2, 1, 1), "name": "Ledgers", "what": "Every delivery the Hall has ever made, in Wayling's small neat hand."}],
		"links": [{"rect": Rect2i(7, 10, 3, 1), "to": "hall_low", "at": Vector2i(14, 3), "facing": "s", "sfx": "door"}]},
}
const STAIRS_DOWN := Rect2i(14, 10, 2, 2)   # on the Hall's work floor, right of the runner
# The bed (Claude, 2026-10-22, GS-10): the line on the panel when the screen comes back up, and the fade.
const REST_LINE := "Morning. Highbank remembers."
const REST_FADE := 0.35
const REST_HOLD := 0.25   # the dark between the fades: the night
# The key hints, bottom right, key then action in the column style the menus use (W12). The keys are the
# device's (Claude, 2026-10-23): "WASD  walk     E  use" on a keyboard, "Stick  walk     A  use" on a pad.
static func keys_hint() -> String:
	return "%s  walk     %s  use" % [SceneKit.walk_keys(), SceneKit.use_key()]


@export var room_id := "home"
var arrive := Vector2i(-1, -1)   # set when the team comes by stairs or a door from another room
var arrive_facing := "s"
var poll_input := true
var team: Array = []
var busy := false
var panel := {}
var last_sfx := ""   # same UI-sound receipt as the town Storage panel
var grid := PackedByteArray()
var _world: Node2D
var _hud: Node2D
var used_log: Array = []   # spots used, for the checks
# Scenes in rooms (Claude, 2026-10-10): the hooks scripts/town/scene_kit.gd uses, as in hub_town.gd.
var talk: Array = []          # [speaker, line, "form:face"]; E reads on
var cutscene := false
var cam_focus: Variant = null
var npcs: Array = []          # creatures in the room that are not the team
var scene_fx := {}            # a scene's bubbles and props
var force_scenes := false     # the checks set poll_input off; this still lets a scene play
var _labels: Node2D
var _resting := false         # the bed's fade is up: its panel waits until the screen comes back
var rested := false           # the last rest saved the record (the checks read it)
var _tick_frame := {}         # menu sound kind -> the frame it last played


func room() -> Dictionary:
	return ROOMS[room_id]


func _ready() -> void:
	var r := room()
	grid.resize(r["w"] * r["h"])
	for y in r["h"]:
		for x in r["w"]:
			var inside: bool = x >= 1 and x <= r["w"] - 2 and y >= int(r.get("floor_top", 2)) and y <= r["h"] - 2
			grid[y * r["w"] + x] = 1 if inside else 0
	for s in r["solid"]:
		for y in range(s.position.y, s.end.y):
			for x in range(s.position.x, s.end.x):
				grid[y * r["w"] + x] = 0
	if r["door"].x >= 0:
		var exit: Rect2i = r.get("exit_rect", Rect2i(r["door"], Vector2i.ONE))
		for y in range(exit.position.y, exit.end.y):
			for x in range(exit.position.x, exit.end.x):
				grid[y * r["w"] + x] = 1
	for l in r.get("links", []):   # stairs and inner doors are walked onto
		if not _link_ok(l):
			continue
		for y in range(l["rect"].position.y, l["rect"].end.y):
			for x in range(l["rect"].position.x, l["rect"].end.x):
				grid[y * r["w"] + x] = 1
	var view := SubViewport.new()
	view.size = VIEW
	view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	add_child(view)
	var screen := Sprite2D.new()
	screen.texture = view.get_texture()
	screen.centered = false
	screen.scale = Vector2.ONE * SCALE
	screen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(screen)
	_world = Node2D.new()
	view.add_child(_world)
	var dark := ColorRect.new()
	dark.color = Color("#1a1410")
	dark.position = Vector2(-400, -400)
	dark.size = Vector2(r["w"] * T + 800, r["h"] * T + 800)
	_world.add_child(dark)
	var map := Sprite2D.new()
	map.centered = false
	map.texture = StorageArt.shell() if room_id == "storage" else ImageTexture.create_from_image(Painter.paint(room_id, r))
	if room_id == "home":
		preload("res://scripts/town/home_room_art.gd").finish(map)
	elif room_id == "hall":
		preload("res://scripts/town/hall_room_art.gd").finish(map)
	_world.add_child(map)
	if room_id == "storage":
		StorageArt.finish(_world, map)
	if room_id == "hall":
		_guild_desk(map)
	if room_id in ["hall", "hall_low", "chamber", "runners"]:
		preload("res://scripts/town/hall_floors_art.gd").finish(map, room_id)
	_lift_furniture(map)   # LP-29: tall furniture in front of a creature behind it
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud = Node2D.new()
	_hud.draw.connect(_draw_hud)
	layer.add_child(_hud)
	# The team stands just inside the door, in a short line.
	var party: Array = TeamState.data.get("party", [[0, 0], [1, 0]])
	var d: Vector2i = r["door"]
	if d.x < 0 and arrive.x < 0:
		arrive = r.get("landing", Vector2i(r["w"] / 2, r["h"] - 3))   # a room with no town door: its landing, never off the map
	var stands := _arrival_tiles(party.size())
	for k in party.size():
		var e := _make(party[k][0], party[k][1], stands[k])
		e["facing"] = arrive_facing if arrive.x >= 0 else "n"
		_place(e)
		team.append(e)
	preload("res://scripts/ui/game_pause_menu.gd").attach(self)
	_labels = Node2D.new()
	_labels.z_index = 2000
	_labels.draw.connect(func() -> void: SceneKit.draw(self, _labels))
	_world.add_child(_labels)
	if room_id == "chamber" and _record().get("story", {}).get("guild_trial", false):
		var star := SceneKit.spawn(self, "starward", Vector2i(8, 3), "s")
		star["lines"] = _starward_lines()
		star["talk_rect"] = Rect2i(7, 3, 3, 2)   # spoken to across the dais, like a counter
	if GuildScene.pending(self):
		GuildScene.place(self)
		if poll_input or force_scenes:
			(func() -> void: GuildScene.run(self)).call_deferred()
	elif GuildCrew.pending(self) and (poll_input or force_scenes):
		(func() -> void: GuildCrew.run(self)).call_deferred()   # the morning mail call (R3, 2026-10-12)
	else:
		GuildCrew.place(self)   # the crew at their posts


## Where the team stands on arrival (Claude, 2026-10-22, LP-18): through the town door, a short line straight
## up from it; by stairs or an inner door, the leader on the landing and the rest nearest it. Each member gets
## its own open tile that is not a solid rect, the way out, a stair or an inner door, found breadth-first from
## the first tile when the straight line is blocked.
func _arrival_tiles(n: int) -> Array:
	var d: Vector2i = room()["door"]
	var first: Vector2i = arrive if arrive.x >= 0 else d + Vector2i(0, -1)
	var picked: Array = []
	if arrive.x < 0:
		for k in n:
			var t := d + Vector2i(0, -1 - k)
			if not _stand_ok(t, picked):
				break
			picked.append(t)
	var seen := {first: true}
	var queue: Array = [first]
	while picked.size() < n and not queue.is_empty():
		var c: Vector2i = queue.pop_front()
		if _stand_ok(c, picked):
			picked.append(c)
		for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]:
			var nb: Vector2i = c + o
			if not seen.has(nb) and _open(nb):
				seen[nb] = true
				queue.append(nb)
	while picked.size() < n:   # too little floor for the team; no room above is that small
		picked.append(first)
	return picked


func _stand_ok(t: Vector2i, taken: Array) -> bool:
	var d: Vector2i = room()["door"]
	var way_out: Rect2i = room().get("exit_rect", Rect2i(d, Vector2i.ONE))
	return _open(t) and _link_at(t).is_empty() and not (d.x >= 0 and way_out.has_point(t)) and not t in taken


## The team record the town carries (scripts/town/team_state.gd).
func _record() -> Dictionary:
	if TeamState.data.is_empty():
		TeamState.start([[0, 0], [1, 0]])
	return TeamState.data


func _sfx(name: String) -> void:
	var path := "res://assets/audio/sfx/dungeon/%s.wav" % name
	if not ResourceLoader.exists(path):
		return
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.volume_db = -4.0
	p.bus = &"SFX"
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)


func _open(t: Vector2i) -> bool:
	var r := room()
	return t.x >= 0 and t.y >= 0 and t.x < r["w"] and t.y < r["h"] and grid[t.y * r["w"] + t.x] == 1


func _make(line: int, stage: int, pos: Vector2i) -> Dictionary:
	var form: String = Lines.of(line)["forms"][stage][0]
	var node := Node2D.new()
	_world.add_child(node)
	var sprite := Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.add_child(sprite)
	preload("res://scripts/arena/creature_finish.gd").apply(sprite)
	# The town set: every creature half again its dungeon size, so the world reads bigger than a dungeon
	# floor (Preston, 2026-10-10: "they look too small"; built by build_dungeon_set.py --set=town --scale=1.5).
	var set := "town" if ResourceLoader.exists("res://assets/sprites/arena/%s/town/s.png" % form) else ("dungeon" if ResourceLoader.exists("res://assets/sprites/arena/%s/dungeon/s.png" % form) else "small")
	var still := {}
	var walk := {}
	for f in Arena.FACINGS:
		still[f] = load("res://assets/sprites/arena/%s/%s/%s.png" % [form, set, f])
		var frames: Array = []
		for k in 8:
			var p := "res://assets/sprites/arena/%s/%s/walk_%s_f%d.png" % [form, set, f, k]
			if ResourceLoader.exists(p):
				frames.append(load(p))
		walk[f] = frames
	return {"line": line, "stage": stage, "form": form, "pos": pos, "node": node, "sprite": sprite, "still": still, "walk": walk,
		"facing": "s", "walk_t": 0.0, "walk_clock": 0.0}


## The Guildmaster's desk (Preston, 2026-10-10: replace the painted counter, "it doesn't look right", with an
## asset made for the Guildmaster and the scene). The counter is painted out of the Hall picture as floor,
## copied from the stone two tiles below (and from beside the carpet where the carpet ran), and the hand-drawn
## desk (tools/art/guild_desk.py) stands in its place, a row lower, so the picture sits exactly on its solid
## tiles (rows 3 and 4; Preston: "he still goes through it, make it a real obstacle") and row 2 behind it is
## open floor. Creatures sort by their feet (z = y): the desk draws over row 2 (feet 66) and under row 5 (138).
const DESK_AT := Vector2i(168, 70)
const DESK := "res://assets/sprites/world/guild_desk/desk_detail_2026_10_10.png"
const OLD_COUNTER := Rect2i(160, 46, 208, 54)


func _guild_desk(map: Sprite2D) -> void:
	if not FileAccess.file_exists(DESK):
		return
	var img: Image = map.texture.get_image()
	var carpet := Vector2i(226, 302)   # the carpet's columns; stone is taken from beside it there
	for y in range(OLD_COUNTER.position.y, OLD_COUNTER.end.y):
		for x in range(OLD_COUNTER.position.x, OLD_COUNTER.end.x):
			var sx := x - 76 if x >= carpet.x and x < carpet.y else x
			img.set_pixel(x, y, img.get_pixel(sx, y + 52))
	map.texture = ImageTexture.create_from_image(img)
	var mat := map.material as ShaderMaterial
	if mat != null:   # the painted counter's ink outline goes with it
		var mask: Image = preload("res://scripts/town/hall_room_art.gd").mask()
		mask.fill_rect(OLD_COUNTER, Color.BLACK)
		mat.set_shader_parameter("detail_mask", ImageTexture.create_from_image(mask))
	var desk := Sprite2D.new()
	desk.centered = false
	var desk_image := Image.load_from_file(ProjectSettings.globalize_path(DESK))
	desk_image.convert(Image.FORMAT_RGBA8)
	desk.texture = ImageTexture.create_from_image(preload("res://scripts/art/selout.gd").selout(desk_image))
	desk.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var desk_mask := Image.create(desk_image.get_width(),desk_image.get_height(),false,Image.FORMAT_RGBA8)
	desk_mask.fill(Color.WHITE)
	var desk_finish := ShaderMaterial.new()
	desk_finish.shader = preload("res://scripts/dungeon/dungeon_finish.gdshader")
	desk_finish.set_shader_parameter("detail_mask",ImageTexture.create_from_image(desk_mask))
	desk_finish.set_shader_parameter("detail_ink",0.55)
	desk.material = desk_finish
	desk.position = Vector2(DESK_AT)
	desk.z_index = DESK_AT.y + 46   # its front's foot
	_world.add_child(desk)


## Tall furniture in front of a creature behind it (Claude, 2026-10-23, LP-29). The rooms' furniture is part of
## the room picture, so every creature drew over it, even one standing behind a pillar or beside a bed's far end.
## Each solid piece of the room data that is more than one row deep, or whose art stands up past its tiles (the
## Hall's pillars, ferns and benches), gets a copy of its pixels drawn at its base row's depth, the way creatures
## and the Hall's desk sort by their feet: a creature whose feet are on a row above the base row draws under it,
## one on the base row or below draws over it. The copy is the room picture itself through the room's own finish
## (so its pixels are the picture's exactly), clipped to the piece's shape: the room's prop sprites where it has
## them (the Hall, the lower floor, the chamber, the runners' room), else the piece's own tiles (the Home is one
## painted picture). The Storage's props and the Hall's desk are their own sorted sprites already.
const LIFT_FLAT := ["rug", "runner", "rollcall"]   # props that lie flat on the floor, never in front of anyone
const LIFT_REACH := 6   # a prop stands on a piece when its foot is inside the piece's tiles or this far below them
var lifts: Array = []   # {"rect": the solid rect, "z": its depth, "node": the clip}, one per lifted piece (the checks)
static var _lift_shapes := {}   # room id -> [[solid rect, picture rect, shape], ...], cut once a session


func _lift_furniture(map: Sprite2D) -> void:
	if room_id == "storage" or map.texture == null:
		return
	if not _lift_shapes.has(room_id):
		_lift_shapes[room_id] = _furniture_shapes()
	for piece in _lift_shapes[room_id]:
		var rect: Rect2i = piece[0]
		var at: Rect2i = piece[1]
		# The shape, never drawn itself, clips the copy of the picture under it (Godot's clip children).
		var clip := Sprite2D.new()
		clip.centered = false
		clip.texture = ImageTexture.create_from_image(piece[2])
		clip.position = Vector2(at.position)
		clip.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
		clip.z_index = (rect.end.y - 1) * T + int(T * 0.5)   # the base row's middle: feet above it sort under
		var copy := Sprite2D.new()
		copy.centered = false
		copy.texture = map.texture
		copy.region_enabled = true
		copy.region_rect = Rect2(at)
		copy.material = map.material   # the same finish, reading the whole picture, so the pixels match
		clip.add_child(copy)
		_world.add_child(clip)
		lifts.append({"rect": rect, "z": clip.z_index, "node": clip})


## Each piece to lift: [its solid rect, the picture rect its shape covers, the shape (white where the piece is)].
func _furniture_shapes() -> Array:
	var props := _room_props()
	var out: Array = []
	for s in room()["solid"]:
		var rect: Rect2i = s
		if room_id == "hall" and rect == Rect2i(7, 3, 8, 2) and FileAccess.file_exists(DESK):
			continue   # the Guildmaster's desk sorts itself
		var tiles := Rect2i(rect.position * T, rect.size * T)
		var stands: Array = props.filter(func(p: Array) -> bool:
			var pr: Rect2i = p[0]
			var across := mini(pr.end.x, tiles.end.x) - maxi(pr.position.x, tiles.position.x)
			return pr.end.y > tiles.position.y and pr.end.y <= tiles.end.y + LIFT_REACH and across * 2 >= pr.size.x)
		if stands.is_empty():
			if rect.size.y < 2:
				continue   # one row with no art standing above it: nothing of it is ever behind a creature
			var whole := Image.create(tiles.size.x, tiles.size.y, false, Image.FORMAT_RGBA8)
			whole.fill(Color.WHITE)
			out.append([rect, tiles, whole])
			continue
		var at: Rect2i = stands[0][0]
		for p in stands:
			at = at.merge(p[0])
		var shape := Image.create(at.size.x, at.size.y, false, Image.FORMAT_RGBA8)
		for p in stands:
			var pr: Rect2i = p[0]
			var img: Image = p[1]
			for y in mini(pr.size.y, img.get_height()):
				for x in mini(pr.size.x, img.get_width()):
					if img.get_pixel(x, y).a > 0.5:   # the props' soft fringe stays floor
						shape.set_pixel(pr.position.x - at.position.x + x, pr.position.y - at.position.y + y, Color.WHITE)
		out.append([rect, at, shape])
	return out


## The prop sprites painted into this room's picture, with where they were painted: [[rect, Image], ...].
func _room_props() -> Array:
	var out: Array = []
	if room_id == "hall":
		var art := preload("res://scripts/town/hall_room_art.gd")
		if art.available():
			for p in art.PROPS:
				out.append([p[1], art._prop(p[0])])
	var floors := preload("res://scripts/town/hall_floors_art.gd")
	if floors.PROPS.has(room_id) and floors.available(room_id):
		for p in floors.PROPS[room_id]:
			if not LIFT_FLAT.any(func(w: String) -> bool: return String(p[0]).contains(w)):
				out.append([p[1], floors._prop(p)])
	return out


func _px(t: Vector2i) -> Vector2:
	return Vector2(t) * T + Vector2(T * 0.5, T * 0.78)


func _place(e: Dictionary) -> void:
	e["node"].position = _px(e["pos"])
	if e.get("walk_t", 0.0) <= 0.0:
		e["sprite"].texture = e["still"][e["facing"]]
	e["sprite"].position = Vector2(0, -e["sprite"].texture.get_size().y * 0.5 + 4)
	e["node"].z_index = int(e["node"].position.y)


func _facing_of(d: Vector2i) -> String:
	return Arena.FACINGS[DIRS.find(d)] if DIRS.has(d) else "s"


## One step for the leader; the others follow in a chain. Stepping onto the door leaves the room.
func act_move(d: Vector2i) -> void:
	if busy or cutscene or not panel.is_empty():
		return
	var lead: Dictionary = team[0]
	lead["facing"] = _facing_of(d)
	var to: Vector2i = lead["pos"] + d
	if npcs.any(func(n: Dictionary) -> bool: return n["pos"] == to):   # the crew and townsfolk are solid
		_place(lead)
		return
	if not _open(to) or (d.x != 0 and d.y != 0 and (not _open(lead["pos"] + Vector2i(d.x, 0)) or not _open(lead["pos"] + Vector2i(0, d.y)))):
		_place(lead)
		return
	busy = true
	var trail: Array = team.map(func(e: Dictionary) -> Vector2i: return e["pos"])
	lead["pos"] = to
	for k in range(1, team.size()):
		if team[k]["pos"].distance_to(team[k - 1]["pos"]) > 1.5:
			team[k]["facing"] = _facing_of((trail[k - 1] - team[k]["pos"]).clamp(Vector2i(-1, -1), Vector2i(1, 1)))
			team[k]["pos"] = trail[k - 1]
	for e in team:
		if _px(e["pos"]) != e["node"].position:
			e["walk_t"] = STEP_TIME + 0.06
		create_tween().tween_property(e["node"], "position", _px(e["pos"]), STEP_TIME)
	await get_tree().create_timer(STEP_TIME).timeout
	for e in team:
		_place(e)
	busy = false
	if room().get("exit_rect", Rect2i(room()["door"], Vector2i.ONE)).has_point(lead["pos"]):
		leave()
		return
	var link := _link_at(lead["pos"])
	if not link.is_empty():
		go_room(link)


## Use what the leader faces: a spot shows its panel; a second press closes it.
func act_use() -> Dictionary:
	if cutscene:
		return {}
	if panel.get("service", "") == "storage":
		act_store(1)
		return {}
	if not panel.is_empty():
		panel = {}
		return {}
	var lead: Dictionary = team[0]
	var ahead: Vector2i = lead["pos"] + DIRS[Arena.FACINGS.find(lead["facing"])]
	for n in npcs:
		if n.has("lines") and (n["pos"] == ahead or n.get("talk_rect", Rect2i()).has_point(ahead)):
			_chat(n)
			return {"id": "talk_" + String(n["form"])}
	for s in room()["spots"]:
		if s["rect"].has_point(ahead) or s["rect"].has_point(lead["pos"]):
			panel = {"name": "Storage", "service": "storage", "sel": 0, "said": ""} if s.get("service", "") == "storage" else _spot_panel(s)
			used_log.append(s["id"])
			if s["id"] == "bed":
				rest()
			return s
	return {}


## A spot's panel: a copy of the spot, its text swapped for "what_if" once that story flag is set (CR-02),
## and the morning line on a bed (GS-10). Claude, 2026-10-22.
func _spot_panel(s: Dictionary) -> Dictionary:
	var p := s.duplicate()
	var alt: Array = s.get("what_if", [])
	if alt.size() == 2 and _record().get("story", {}).get(String(alt[0]), false):
		p["what"] = String(alt[1])
	if s["id"] == "bed":
		p["what"] = REST_LINE
	return p


## The bed rests the team (Claude, 2026-10-22, GS-10): the screen fades out, the night passes, the record is
## saved, and the screen comes back on the morning line. The town record holds no HP (every run starts at
## full), so waking up whole needs nothing more. The save is made at once, so a check reads it without
## waiting; the fade runs on the tree, so the screen comes back even if the room is gone by then.
func rest() -> void:
	for e in team:
		e["facing"] = "s"
		_place(e)
	rested = TeamState.autosave()
	if not is_inside_tree():
		return
	_resting = true
	_night(get_tree(), self)


static func _night(tree: SceneTree, host: Node) -> void:
	await UI.fade_out(tree, REST_FADE)
	await tree.create_timer(UI.motion_secs(REST_HOLD)).timeout
	if is_instance_valid(host):
		host.set("_resting", false)
	UI.fade_in(tree, REST_FADE)


## The stairs or inner door under `t`, or {}.
func _link_at(t: Vector2i) -> Dictionary:
	for l in room().get("links", []):
		if l["rect"].has_point(t) and _link_ok(l):
			return l
	return {}


## A door the story has not opened yet ("needs" names a story flag, e.g. the runners' room needs "runner").
func _link_ok(l: Dictionary) -> bool:
	return not l.has("needs") or _record().get("story", {}).get(l["needs"], false)


## Down the stairs or through a door: the same team, in the next room, on its landing.
func go_room(link: Dictionary) -> void:
	_sfx(String(link.get("sfx", "door")))
	used_log.append("to_" + String(link["to"]))
	if is_inside_tree() and get_tree().current_scene == self:
		var next: Node = load("res://scenes/town_room.tscn").instantiate()
		next.room_id = link["to"]
		next.arrive = link["at"]
		next.arrive_facing = link["facing"]
		get_tree().change_scene_to_node(next)
	else:
		set_meta("went", link)   # the checks read this instead of leaving the scene


## A word from someone standing in the room (the team turns to them; E reads on).
func _chat(n: Dictionary) -> void:
	cutscene = true
	SceneKit.face(self, n, team[0])
	await SceneKit.say(self, n["lines"])
	cutscene = false


## What the Guildmaster says in the chamber, by where the story is (Claude's drafts for Preston).
func _starward_lines() -> Array:
	var story: Dictionary = _record().get("story", {})
	if story.get("runner", false):
		return [["Starward", "Runners of the Wayline. The river is longer than any map in this room. Go and see it.", "happy"]]
	if String(story.get("parcel", "")) == "stolen":
		return [["Starward", "Rootbank Warren. Gruntle's crew went to ground there. Bring the parcel home.", "determined"]]
	return [["Starward", "The Hall is open to anyone who carries for it.", "normal"]]


## Back out to Highbank, standing on this building's door.
func leave() -> void:
	TeamState.data["arrive_at"] = room()["town_door"]
	if is_inside_tree() and get_tree().current_scene == self:
		var town: Node = load("res://scenes/hub_town.tscn").instantiate()
		TeamState.give_to(town)
		get_tree().change_scene_to_node(town)
	else:
		set_meta("left", true)


func _process(delta: float) -> void:
	if poll_input and not busy:
		_poll()
	var movers: Array = []
	movers.append_array(team)
	movers.append_array(npcs)
	for e in movers:
		if e["walk_t"] > 0.0:
			e["walk_t"] -= delta
			e["walk_clock"] += delta
			var frames: Array = e["walk"].get(e["facing"], [])
			if not frames.is_empty():
				e["sprite"].texture = frames[int(e["walk_clock"] * WALK_FPS) % frames.size()]
			if e["walk_t"] <= 0.0:
				e["sprite"].texture = e["still"][e["facing"]]
	if not team.is_empty():
		var r := room()
		var half := Vector2(VIEW) * 0.5
		var size := Vector2(r["w"], r["h"]) * T
		var focus: Vector2 = (cam_focus if cam_focus != null else team[0]["node"].position + Vector2(0, -12))
		focus = Vector2(size.x * 0.5 if size.x <= VIEW.x else clampf(focus.x, half.x, size.x - half.x),
			size.y * 0.5 if size.y <= VIEW.y else clampf(focus.y, half.y, size.y - half.y))
		_world.position = (half - focus).round()
	_hud.queue_redraw()
	_labels.queue_redraw()


## Every press is an action in the Input Map (Claude, 2026-10-23, factory pass 2: controller support), read
## through ui_style.gd's helpers, as in hub_town.gd: the keyboard keeps E, J or Enter to use, Esc to close, W/S and
## R in the Storage; a pad walks with the stick or D-pad, uses with A or X, closes with B, takes out with Y.
func _poll() -> void:
	if cutscene:   # a scene plays itself; E (or J, Enter, Space) reads its lines
		if not talk.is_empty() and UI.tapped_any(UI.INPUT_ADVANCE):
			if UI.line_done(String(talk[0][1])):
				talk.pop_front()
			else:
				UI.finish_line()   # the first press shows the rest of the line, the next moves on
		return
	if panel.get("service", "") == "storage":
		if UI.tapped(&"move_up"): act_store_move(-1)
		if UI.tapped(&"move_down"): act_store_move(1)
		if UI.tapped(&"take_out"): act_store(-1)
	if UI.tapped_any([&"confirm", &"interact"]):
		act_use()
		return
	if UI.tapped(&"cancel"):
		if not panel.is_empty():
			UI.tick("cancel")   # GS-21: closing a panel sounds like every other back
		panel = {}
	var d := UI.dir8()
	if d != Vector2i.ZERO:
		act_move(d)


func _draw_hud() -> void:
	var h := _hud
	if cutscene:   # a scene: only its lines
		if not talk.is_empty():
			var sl: Array = talk[0]
			var sf: String = String(sl[2]) if sl.size() > 2 else ""
			UI.dialogue(h, Rect2(196, 452, 760, 116), String(sl[0]), String(sl[1]), UI.dialogue_portrait(sf) if sf != "" else null, Time.get_ticks_msec() / 1000.0, 20, sf.get_slice(":", 1) if ":" in sf else "normal")
		return
	UI.panel(h, Rect2(6, 6, 330, 54))
	UI.text(h, Vector2(28, 43), String(room()["name"]), 26, UI.EDGE_LIGHT)
	# What to do next, always on screen (Preston, 2026-10-11: "objective tab so players know where to go").
	var goal: Dictionary = Objective.current(TeamState.data.get("story", {}), TeamState.data.get("beaten", []))
	UI.panel(h, Rect2(6, 64, 600, 34), 0.9)
	UI.text(h, Vector2(26, 87), "Next:  " + String(goal["short"]), 16, UI.TEXT, 570)
	if panel.is_empty():
		_draw_hints(h)
	if panel.get("service", "") == "storage":
		StoragePanel.draw(self, h)
		return
	if not panel.is_empty() and not _resting:
		var box := Rect2(196, 452, 760, 128)
		UI.panel(h, box, 0.95)
		UI.nameplate(h, box.position + Vector2(24, -22), String(panel["name"]))
		h.draw_multiline_string(UI.HEAD, box.position + Vector2(30, 50), String(panel["what"]), HORIZONTAL_ALIGNMENT_LEFT, 700, 18, 3, UI.TEXT)
		UI.next_arrow(h, box.end - Vector2(48, 36), Time.get_ticks_msec() / 1000.0)


## The key hints and where the way out is, bottom right on a see-through panel strip sized to the wider
## line (Claude, 2026-10-22, GS-21). The key line gets the width it needs in the label role (the key-hint
## role), so the column spacing does not drop it to the tight font; the way-out line keeps its 194 px box
## and grows left as before.
func _draw_hints(h: Node2D) -> void:
	var where := String(room().get("hint", "The door leads back out"))
	var keys := keys_hint()
	var keys_w := maxf(194.0, ceilf(UI.width_in(keys, "label")) + 1.0)
	var w := maxf(keys_w, UI.width_in(where, UI.fit(where, "label", 194.0)))
	UI.panel(h, Rect2(1140.0 - w - 20.0, 542, w + 26.0, 48), 0.85)
	UI.text(h, Vector2(1140.0 - keys_w, 562), keys, 14, Color(UI.MUTED, 0.85), keys_w, HORIZONTAL_ALIGNMENT_RIGHT)
	UI.text(h, Vector2(946, 580), where, 14, Color(UI.MUTED, 0.85), 194, HORIZONTAL_ALIGNMENT_RIGHT)


func storage_rows() -> Array:
	return StoragePanel.entries(self)

func act_store(n: int) -> void:
	StoragePanel.store(self, n)

func act_store_move(dy: int) -> void:
	StoragePanel.select_row(self, dy)

## Menu sounds through the shared ticks, on the "UI" bus (Claude, 2026-10-22, GS-21): a kind the ticks do
## not know plays nothing instead of loading a missing file. `last_sfx` stays the receipt the checks read.
## One tick of a kind a frame: two in one frame sound as one, and the tick's first player is not yet in the
## tree then (it joins at the frame's end).
func _ui_sfx(name: String) -> void:
	last_sfx = name
	var now := Engine.get_process_frames()
	if int(_tick_frame.get(name, -1)) == now:
		return
	_tick_frame[name] = now
	UI.tick(name)
