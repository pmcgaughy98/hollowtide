extends Node2D
## Rooms inside Highbank's buildings (Claude, 2026-10-10; Preston: "do this for interiors too, I noticed
## main house and courier hall rooms were super small"). Walk in through the Home's or the Wayline Hall's
## door and the team stands in a room at the town's own scale (24 px tiles, the same creatures), painted
## in code like the dungeons (scripts/town/room_painter.gd), with things to use and the door back out.
## Codex's older courier-era rooms (scenes/courier_hall.tscn, courtyard_home.tscn) are untouched.
##   var room = load("res://scenes/town_room.tscn").instantiate(); room.room_id = "home"

const Arena := preload("res://scripts/arena/arena_prototype.gd")
const Lines := preload("res://scripts/creatures/lines.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
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
## blocks walking, and the spots that answer E. The texts are Claude's drafts.
const ROOMS := {
	"home": {"name": "Home", "w": 14, "h": 10, "door": Vector2i(7, 9), "town_door": "home",
		"solid": [Rect2i(1, 2, 3, 2), Rect2i(9, 2, 4, 1), Rect2i(6, 4, 3, 2), Rect2i(1, 7, 2, 2), Rect2i(11, 6, 2, 2)],
		"spots": [
			{"id": "bed", "rect": Rect2i(1, 2, 3, 2), "name": "Moss Bed", "what": "Rest here and the day ends: the team wakes up whole. (Saving comes with the save system.)"},
			{"id": "hearth", "rect": Rect2i(9, 2, 4, 1), "name": "Hearth", "what": "Warm stones and a kettle. The light the house is built round."},
			{"id": "table", "rect": Rect2i(6, 4, 3, 2), "name": "Table", "what": "A lantern, a map of the river, the parcel slip from the first job."},
			{"id": "shelf", "rect": Rect2i(1, 7, 2, 2), "name": "Shelf", "what": "Jars of reedberries and a stack of old Wayline reports."},
			{"id": "plants", "rect": Rect2i(11, 6, 2, 2), "name": "Planters", "what": "Clover and a stubborn fern. Someone waters them."}]},
	"hall": {"name": "Wayline Hall", "w": 22, "h": 14, "door": Vector2i(11, 13), "town_door": "hall",
		"solid": [Rect2i(7, 3, 8, 2), Rect2i(2, 2, 2, 1), Rect2i(18, 2, 2, 1), Rect2i(3, 6, 1, 1), Rect2i(18, 6, 1, 1), Rect2i(3, 10, 1, 1), Rect2i(18, 10, 1, 1),
			Rect2i(1, 8, 1, 3), Rect2i(20, 8, 1, 3), Rect2i(5, 7, 2, 2), Rect2i(15, 7, 2, 2), Rect2i(2, 12, 2, 1), Rect2i(18, 12, 2, 1),
			Rect2i(4, 6, 1, 1), Rect2i(17, 6, 1, 1)],
		"spots": [
			{"id": "counter", "rect": Rect2i(7, 3, 8, 2), "name": "Dispatch Counter", "what": "The dispatcher hands out the board's requests and takes reports. (The Job Board outside lists them.)", "service": "jobs"},
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
	"hall_low": {"name": "Wayline Hall, lower floor", "w": 30, "h": 18, "door": Vector2i(-1, -1), "hint": "Stairs up, bottom right",
		"solid": [Rect2i(9, 5, 1, 1), Rect2i(20, 5, 1, 1), Rect2i(9, 12, 1, 1), Rect2i(20, 12, 1, 1), Rect2i(3, 12, 6, 2),
			Rect2i(12, 2, 1, 1), Rect2i(17, 2, 1, 1), Rect2i(27, 9, 1, 3), Rect2i(1, 8, 1, 2)],
		"spots": [
			{"id": "chamber_door", "rect": Rect2i(14, 1, 2, 1), "name": "Guildmaster's Chamber", "what": "Starward's door."},
			{"id": "rollcall", "rect": Rect2i(12, 7, 6, 4), "name": "Roll-Call Floor", "what": "The Wayline's mark, set in brass. Every morning the crew lines up round it for the day's word."},
			{"id": "duty", "rect": Rect2i(9, 1, 2, 1), "name": "Duty Board", "what": "Today's duties: the door watch, the kitchen, the sweeping. Your names aren't on it yet."},
			{"id": "window_w", "rect": Rect2i(3, 1, 2, 1), "name": "River Window", "what": "The Hall is cut into the bank. Through the glass the river runs a long way down."},
			{"id": "window_e", "rect": Rect2i(25, 1, 2, 1), "name": "River Window", "what": "Rain on the glass, and the far bank green after the flood."},
			{"id": "crew_room", "rect": Rect2i(0, 5, 1, 2), "name": "Crew Room", "what": "Bunks for the Hall's crew. Someone is snoring."},
			{"id": "runners_room", "rect": Rect2i(29, 5, 1, 2), "name": "Runners' Room", "what": "Bunks kept for runners of the Wayline."},
			{"id": "mess", "rect": Rect2i(3, 12, 6, 2), "name": "Mess Hall", "what": "The long table. Supper is at the end of the day, for whoever made it back."},
			{"id": "hatch", "rect": Rect2i(1, 8, 1, 2), "name": "Kitchen Hatch", "what": "Something with river greens in it is simmering."},
			{"id": "shelf", "rect": Rect2i(27, 9, 1, 3), "name": "Supply Shelf", "what": "Rope, lantern oil, spare satchels, a jar of reedberries."}],
		"links": [{"rect": Rect2i(14, 1, 2, 1), "to": "chamber", "at": Vector2i(8, 8), "facing": "n", "sfx": "door"},
			{"rect": Rect2i(25, 13, 2, 2), "to": "hall", "at": Vector2i(13, 10), "facing": "w", "sfx": "stairs"}]},
	# Starward's chamber, behind the door at the back of the lower floor.
	"chamber": {"name": "Guildmaster's Chamber", "w": 16, "h": 11, "door": Vector2i(-1, -1), "hint": "The door leads back down",
		"solid": [Rect2i(7, 3, 3, 2), Rect2i(1, 3, 1, 3), Rect2i(14, 3, 1, 3)],
		"spots": [
			{"id": "dais", "rect": Rect2i(7, 3, 3, 2), "name": "The Dais", "what": "Starward's cushion, worn flat in the middle."},
			{"id": "map", "rect": Rect2i(3, 1, 4, 1), "name": "The Whole River", "what": "Every Hollow the Wayline knows, from the springs to the sea. Most of the map is still blank."},
			{"id": "window", "rect": Rect2i(10, 1, 3, 1), "name": "Window", "what": "The whole of Highbank's bank below, and the river past it."},
			{"id": "keepsakes", "rect": Rect2i(1, 3, 1, 3), "name": "Keepsakes", "what": "Old satchels, a cracked lantern, a medal shaped like a star."},
			{"id": "books", "rect": Rect2i(14, 3, 1, 3), "name": "Ledgers", "what": "Every delivery the Hall has ever made, in Wayling's small neat hand."}],
		"links": [{"rect": Rect2i(7, 10, 2, 1), "to": "hall_low", "at": Vector2i(14, 3), "facing": "s", "sfx": "door"}]},
}
const STAIRS_DOWN := Rect2i(14, 10, 2, 2)   # on the Hall's work floor, right of the runner

@export var room_id := "home"
var arrive := Vector2i(-1, -1)   # set when the team comes by stairs or a door from another room
var arrive_facing := "s"
var poll_input := true
var team: Array = []
var busy := false
var panel := {}
var grid := PackedByteArray()
var _world: Node2D
var _hud: Node2D
var _keys_was := {}
var used_log: Array = []   # spots used, for the checks
# Scenes in rooms (Claude, 2026-10-10): the hooks scripts/town/scene_kit.gd uses, as in hub_town.gd.
var talk: Array = []          # [speaker, line, "form:face"]; E reads on
var cutscene := false
var cam_focus: Variant = null
var npcs: Array = []          # creatures in the room that are not the team
var scene_fx := {}            # a scene's bubbles and props
var force_scenes := false     # the checks set poll_input off; this still lets a scene play
var _labels: Node2D


func room() -> Dictionary:
	return ROOMS[room_id]


func _ready() -> void:
	var r := room()
	grid.resize(r["w"] * r["h"])
	for y in r["h"]:
		for x in r["w"]:
			var inside: bool = x >= 1 and x <= r["w"] - 2 and y >= 2 and y <= r["h"] - 2
			grid[y * r["w"] + x] = 1 if inside else 0
	for s in r["solid"]:
		for y in range(s.position.y, s.end.y):
			for x in range(s.position.x, s.end.x):
				grid[y * r["w"] + x] = 0
	if r["door"].x >= 0:
		grid[r["door"].y * r["w"] + r["door"].x] = 1
	for l in r.get("links", []):   # stairs and inner doors are walked onto
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
	map.texture = ImageTexture.create_from_image(Painter.paint(room_id, r))
	if room_id == "home":
		preload("res://scripts/town/home_room_art.gd").finish(map)
	elif room_id == "hall":
		preload("res://scripts/town/hall_room_art.gd").finish(map)
	_world.add_child(map)
	if room_id == "hall":
		_guild_desk(map)
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud = Node2D.new()
	_hud.draw.connect(_draw_hud)
	layer.add_child(_hud)
	# The team stands just inside the door, in a short line.
	var party: Array = TeamState.data.get("party", [[0, 0], [1, 0]])
	var d: Vector2i = r["door"]
	for k in party.size():
		var at := d + Vector2i(0, -1 - k)
		if k > 0 and not _open(at):
			at = d + Vector2i([1, -1][k % 2], -1)
		if arrive.x >= 0:   # by stairs or an inner door: the leader on the landing, the others beside
			at = arrive
			for o in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, 1)]:
				var t: Vector2i = arrive + o * (1 if k > 0 else 0)
				if _open(t) and not _link_at(t) and team.all(func(e: Dictionary) -> bool: return e["pos"] != t):
					at = t
					break
		var e := _make(party[k][0], party[k][1], at)
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
	if lead["pos"] == room()["door"]:
		leave()
		return
	var link := _link_at(lead["pos"])
	if not link.is_empty():
		go_room(link)


## Use what the leader faces: a spot shows its panel; a second press closes it.
func act_use() -> Dictionary:
	if cutscene:
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
			panel = s
			used_log.append(s["id"])
			if s["id"] == "bed":
				for e in team:
					e["facing"] = "s"
					_place(e)
			return s
	return {}


## The stairs or inner door under `t`, or {}.
func _link_at(t: Vector2i) -> Dictionary:
	for l in room().get("links", []):
		if l["rect"].has_point(t):
			return l
	return {}


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


func _tapped(k: int) -> bool:
	var now := Input.is_key_pressed(k)
	var was: bool = _keys_was.get(k, false)
	_keys_was[k] = now
	return now and not was


func _poll() -> void:
	if cutscene:   # a scene plays itself; E reads its lines
		if not talk.is_empty() and (_tapped(KEY_E) or _tapped(KEY_J) or _tapped(KEY_ENTER) or _tapped(KEY_SPACE)):
			if UI.line_done(String(talk[0][1])):
				talk.pop_front()
			else:
				UI.finish_line()   # the first press shows the rest of the line, the next moves on
		return
	if _tapped(KEY_E) or _tapped(KEY_J) or _tapped(KEY_ENTER):
		act_use()
		return
	if _tapped(KEY_ESCAPE):
		panel = {}
	var d := Vector2i(int(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - int(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)),
		int(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - int(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)))
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
	UI.text(h, Vector2(946, 562), "WASD walk   E use", 14, Color(UI.MUTED, 0.85), 194, HORIZONTAL_ALIGNMENT_RIGHT)
	UI.text(h, Vector2(946, 580), String(room().get("hint", "The door leads back out")), 14, Color(UI.MUTED, 0.85), 194, HORIZONTAL_ALIGNMENT_RIGHT)
	if not panel.is_empty():
		var box := Rect2(196, 452, 760, 128)
		UI.panel(h, box, 0.95)
		UI.nameplate(h, box.position + Vector2(24, -22), String(panel["name"]))
		h.draw_multiline_string(UI.HEAD, box.position + Vector2(30, 50), String(panel["what"]), HORIZONTAL_ALIGNMENT_LEFT, 700, 18, 3, UI.TEXT)
		UI.next_arrow(h, box.end - Vector2(48, 36), Time.get_ticks_msec() / 1000.0)
