extends RefCounted
## The Wayline Tower from its foot (Claude, 2026-10-26, placeholder factory lane S; Preston: a scene where the two
## are in awe, talking about what couriers are, and a camera pan up the Tower). The first time the two reach Tower
## Rise in the rewired Highbank (v2), they stop at the Tower's doors and the camera pans slowly up the Tower from the
## doors to the beacon, holds there, and comes back down, while the partner talks about what couriers are and do
## (dialogue/tower_reveal.dialogue; every line there is a proposal). Under Reduce motion the camera cuts instead.
## Plays once: the story flag tower_seen is set as it starts, so it never plays again, and never with the switch off.
## It runs inside hub_town.gd (team, talk, cutscene, _world, _view); hub_town calls pending() and run() (lane A's
## hook). Lines are read with the usual keys; the use key with no line up skips the rest of a pan.
## The Tower's size and beacon are lane B's: BuildingTemplate.canvas("hall") and the beacon anchor of the
## town.building.hall slot; without them, a 540 px Tower with its beacon 8 px below its top.

const Layout := preload("res://scripts/town/town_layout.gd")
const SceneKit := preload("res://scripts/town/scene_kit.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const TALK := "res://dialogue/tower_reveal.dialogue"
const AREA := "hall_rise"        # Tower Rise's area id (lane A); the place id stays "hall"
const FLAG := "tower_seen"
const FALLBACK := Vector2i(300, 540)
const SKY := "story.backdrop.tower_sky"
const PAN_UP := 7.0              # seconds from the doors to the beacon: slow, the two looking up with you
const PAN_DOWN := 4.5
const HOLD := 1.2                # at least this long at the top
const MOVE_IN := 0.7             # the camera settling on the doors while the two walk up to them
const FEET_ROOM := 34.0          # the first look this far above the two's feet, so they stand above the text box
const BEACON_DROP := 52.0        # the top look this far below the beacon, so it sits in the upper part of the screen
const SKY_TONES := ["#4f7aa6", "#5d88b2", "#6e96bd", "#82a6c7", "#98b6cf", "#aec6d8", "#c2d4df"]
const SKY_AT := [36, 70, 100, 126, 150, 176]

static var reduce_override := -1   # the checks: 1 forces the cut, 0 forces the pan, -1 reads the player's setting
static var playing := false
static var stage := ""   # where the scene is (the walk, start, climb, top, hold, down, done), for the checks


## Whether the scene should start now: the switch on, the town showing Tower Rise, the flag not set.
static func pending(town) -> bool:
	if playing or not _alive(town) or town.team.is_empty() or town.cutscene:
		return false
	if not Layout.v2() or Layout.area_id() != AREA:
		return false
	return not seen(town)


static func seen(town) -> bool:
	return bool(town._record().get("story", {}).get(FLAG, false))


## Where the Tower stands in the town's world: its foot (the doors' sill, centred), its top row, the beacon, the two
## tiles the two stand on below the doors, and the camera's looks at the doors and at the top.
static func geometry(town) -> Dictionary:
	var t := float(Layout.T)
	var doors: Array = [Vector2i(12, 8), Vector2i(13, 8)]
	var places: Array = Layout.area(Layout.area_id()).get("places", Layout.PLACES)
	for p: Dictionary in places:
		if p.get("id", "") == "hall":
			doors = Layout.door_tiles(p)
	var x0 := 1 << 20
	var x1 := -1
	for d: Vector2i in doors:
		x0 = mini(x0, d.x)
		x1 = maxi(x1, d.x)
	var door_y: int = (doors[0] as Vector2i).y
	var foot := Vector2((x0 + x1 + 1) * 0.5 * t, (door_y + 1) * t)
	var canvas := BuildingTemplate.canvas("hall")
	if canvas.y <= 0:
		canvas = FALLBACK
	var anchors: Dictionary = ArtSlots.spec("town.building.hall").get("anchors", {})
	var b: Vector2i = anchors.get("beacon", Vector2i(canvas.x / 2, 8))
	var top := foot.y - canvas.y
	var beacon := Vector2(foot.x - canvas.x * 0.5 + b.x, top + b.y)
	var feet: float = town._px(Vector2i(x0, door_y + 1)).y
	return {"foot": foot, "top": top, "beacon": beacon, "canvas": canvas, "door": Vector2i(x0, door_y),
		"stand": [Vector2i(x0, door_y + 1), Vector2i(x1 if x1 != x0 else x0 + 1, door_y + 1)],
		"door_look": Vector2(foot.x, feet - FEET_ROOM), "top_look": Vector2(foot.x, beacon.y + BEACON_DROP)}


## The look the town's own camera has now (hub_town.gd _process: the leader, clamped to the area), so the scene
## starts and ends without a jump.
static func town_look(town) -> Vector2:
	var half := Vector2(town.VIEW) * 0.5
	var look: Vector2 = town.team[0]["node"].position + Vector2(0, -12)
	var size: Vector2i = Layout.area(Layout.area_id()).get("size", Vector2i(Layout.W, Layout.H))
	return look.clamp(half, Vector2(size) * float(Layout.T) - half)


static func _reduced() -> bool:
	return UI.reduce_motion() if reduce_override < 0 else reduce_override == 1


static func _alive(town) -> bool:
	return town != null and is_instance_valid(town) and town.is_inside_tree()


## The scene. Not awaited by the town: it holds the town's cutscene flag until it is done.
static func run(town) -> void:
	if playing or not _alive(town) or town.team.is_empty() or seen(town):
		return
	playing = true
	var rec: Dictionary = town._record()
	if not rec.has("story") or rec["story"] == null:
		rec["story"] = {}
	rec["story"][FLAG] = true
	town.cutscene = true
	town.talk.clear()
	var geo := geometry(town)
	var cam := TowerCam.new()
	cam.name = "TowerCam"
	cam.town = town
	cam.look = town_look(town)
	town.add_child(cam)
	var sky := Sprite2D.new()   # behind the town's world: above the area's top edge there is only sky
	sky.name = "TowerSky"
	sky.texture = ArtSlots.texture(SKY)
	sky.centered = false
	town._view.add_child(sky)
	town._view.move_child(sky, 0)
	var glint := Glint.new()
	glint.name = "TowerBeacon"
	glint.position = geo["beacon"]
	glint.still = _reduced()
	town._world.add_child(glint)
	# The two walk up to the doors and look up.
	var stand: Array = geo["stand"]
	var moves: Array = [[town.team[0], stand[0]]]
	if town.team.size() > 1:
		moves.append([town.team[1], stand[1]])
	_pan(cam, geo["door_look"], MOVE_IN)
	stage = "walk"
	await SceneKit.walk_all(town, moves)
	if _alive(town):
		for m: Array in moves:
			SceneKit.face(town, m[0], geo["door"] + Vector2i(0, -1))
	stage = "start"
	await _say(town, "start")
	# Up the Tower from the doors to the beacon, the partner talking on the way.
	var up := _pan(cam, geo["top_look"], PAN_UP)
	stage = "climb"
	await _say(town, "climb")
	await _settle(town, up)
	stage = "top"
	var held: SceneTreeTimer = town.get_tree().create_timer(HOLD) if _alive(town) else null   # game time, so it holds under a check's fixed fps too
	await _say(town, "top")
	stage = "hold"
	if _alive(town) and held != null and held.time_left > 0.0:
		await held.timeout
	# And back down to the two at the doors.
	var down := _pan(cam, town_look(town) if _alive(town) else Vector2.ZERO, PAN_DOWN)
	stage = "down"
	await _say(town, "down")
	await _settle(town, down)
	_end(town, cam, sky, glint)


## Move the camera's look to `to` over `secs`, or cut there under Reduce motion. The tween, or null for a cut.
static func _pan(cam: TowerCam, to: Vector2, secs: float) -> Tween:
	if not is_instance_valid(cam) or not cam.is_inside_tree():
		return null
	if _reduced():
		cam.look = to
		return null
	var tw := cam.create_tween()
	tw.tween_property(cam, "look", to, secs).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	cam.tween = tw
	return tw


static func _settle(town, tw: Tween) -> void:
	while _alive(town) and tw != null and tw.is_valid() and tw.is_running():
		await town.get_tree().process_frame


## A title of the dialogue as the town's lines ([speaker, line, face]), queued and read with the usual keys.
static func _say(town, title: String) -> void:
	if not _alive(town):
		return
	var lines: Array = await lines_of(title)
	if _alive(town) and not lines.is_empty():
		await SceneKit.say(town, lines)


## The lines of one title, the partner as "{partner}" (SceneKit.say puts its name and portrait in), narration with
## no speaker.
static func lines_of(title: String) -> Array:
	var res: DialogueResource = load(TALK)
	var out: Array = []
	if res == null:
		return out
	var cast := Cast.new()
	var dm := RouteScene.dialogue_manager()
	if dm == null:
		return out
	var l: DialogueLine = await dm.get_next_dialogue_line(res, title, [cast])
	var guard := 0
	while l != null and guard < 40:
		var face: String = l.tags[0] if not l.tags.is_empty() else "normal"
		var row: Array = [l.character, l.text]
		if l.character != "" and face != "normal":
			row.append(face)
		out.append(row)
		l = await dm.get_next_dialogue_line(res, l.next_id, [cast])
		guard += 1
	return out


static func _end(town, cam: Node, sky: Node, glint: Node) -> void:
	for n in [cam, sky, glint]:
		if n != null and is_instance_valid(n):
			n.queue_free()
	if _alive(town):
		town.talk.clear()
		town.cam_focus = null
		town.cutscene = false
	playing = false
	stage = "done"


## The camera while the scene plays: run after the town's own _process (process_priority), it sets the world's
## offset to its look, past the area's edges. The use key with no line up ends the pan under way.
class TowerCam extends Node:
	const UIs := preload("res://scripts/ui/ui_style.gd")
	var town: Node
	var look := Vector2.ZERO
	var tween: Tween

	func _init() -> void:
		process_priority = 100

	func _process(_delta: float) -> void:
		if town == null or not is_instance_valid(town) or town._world == null:
			return
		var reading: bool = town.poll_input or town.force_scenes
		if tween != null and tween.is_valid() and tween.is_running() and town.talk.is_empty() and reading \
				and UIs.tapped_any(UIs.INPUT_ADVANCE):
			tween.custom_step(60.0)
		town._world.position = (Vector2(town.VIEW) * 0.5 - look).round()


## The Tower's lantern at the beacon: a warm light that breathes (still under Reduce motion).
class Glint extends Node2D:
	const LAMP := Color("#f2c14e")
	var still := false
	var _t := 0.0

	func _init() -> void:
		z_index = 4000
		z_as_relative = false

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		var a := 0.55 if still else 0.4 + 0.25 * sin(_t * 2.2)
		draw_rect(Rect2(-3, -3, 7, 7), Color(LAMP, a * 0.45))
		draw_rect(Rect2(-1, -1, 3, 3), Color(LAMP, minf(1.0, a + 0.3)))


## What the dialogue file reads ({{partner_name}}): a marker SceneKit.say turns into the partner's name.
class Cast extends RefCounted:
	var partner_name := "{partner}"


## The placeholder for story.backdrop.tower_sky (its row names this): a clear morning sky in bands, a few long thin
## clouds; exactly the slot's sheet_size, opaque.
static func paint_sky(_id: String, spec: Dictionary) -> Image:
	var size: Vector2i = spec.get("sheet_size", Vector2i(384, 216))
	var img := Image.create(maxi(1, size.x), maxi(1, size.y), false, Image.FORMAT_RGBA8)
	RouteScene.sky(img, SKY_TONES, SKY_AT)
	for c in [[40, 58, 120], [230, 96, 110], [120, 142, 90]]:
		var x: int = c[0]
		var y: int = c[1]
		var length: int = c[2]
		img.fill_rect(Rect2i(x + 6, y, length - 14, 1), Color("#e6edf0"))
		img.fill_rect(Rect2i(x, y + 1, length, 1), Color("#e6edf0"))
		img.fill_rect(Rect2i(x + 4, y + 2, length - 10, 1), Color("#c9d6de"))
	return img
