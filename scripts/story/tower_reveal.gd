extends RefCounted
## The Wayline Tower from its foot (Claude, 2026-10-26, placeholder factory lane S; Preston: a scene where the two
## are in awe, talking about what couriers are, and a camera pan up the Tower). The first time the two reach Tower
## Rise in the rewired Highbank (v2), they stop at the Tower's doors and the camera climbs the Tower from the doors to
## the Waiting Lamp, holds there, and comes back down, while the partner talks about what couriers are and do
## (dialogue/tower_reveal.dialogue; every line there is a proposal). Under Reduce motion the camera cuts instead.
## Plays once: the story flag tower_seen is set as it starts, so it never plays again, and never with the switch off.
## It runs inside hub_town.gd (team, talk, cutscene, _world, _view); hub_town calls pending() and run() (lane A's
## hook). Lines are read with the usual keys; the use key with no line up skips the rest of a camera move.
##
## 2026-10-27, the approved tower ("ride the climb", docs/design/wayline-tower-2026-10-27/TOWER_DESIGN.md section 8):
## the camera settles on the doors (the look-up lean less TALK_ROOM, so the first line's box sits under the two), then
## climbs in four legs with short pauses while the tower works beside it: the hoist basket comes up with the camera to
## the hoist door, a parcel slides down the chute the other way, a cradle leaves the Reel Deck along a wayline toward
## town and the flood bell swings, and the last leg rises past the Reach to the Waiting Lamp and holds with the vane's
## tip just under the top edge, the box down for the hold and the partner's line after it. Down again in 4.5 s with no
## box up, and the partner's last lines once the camera is back with the two (pass 9); about 15.6 s of camera in all.
## Every height comes from TowerParts' anchors (scripts/town/tower_parts.gd).
## The camera always climbs the TowerParts tower: on v2's Tower Rise the town's own; anywhere else (v1's map, where
## only the checks run the scene) the scene stands one on the Hall's doors and hides the old Hall until it ends.
## Every node the scene adds is freed at its end, and every step checks the town is still there, so a town freed
## mid-scene (a scene change, a check) ends it quietly.
## 2026-10-28 (docs/design/vast-scale-2026-10-27/VAST_SCALE_DESIGN.md): the sky is the hold of the 480-tile Tower, the
## cloud sea under the lamp and the great tree's crown cap in it. The tower the camera climbs is still TowerParts'
## 30-tile one, so from the second leg on the cloud sea shows behind its drum and Reel Deck, where the vast Tower has
## its Low Reel 34 tiles up, far under the clouds. That waits on the town's Tower at the new size and the reveal
## retimed for it (the design's pan, stream, cut on cloud at the collar, hold).

const Layout := preload("res://scripts/town/town_layout.gd")
const SceneKit := preload("res://scripts/town/scene_kit.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const TP := preload("res://scripts/town/tower_parts.gd")
const TALK := "res://dialogue/tower_reveal.dialogue"
const AREA := "hall_rise"        # Tower Rise's area id (lane A); the place id stays "hall"
const FLAG := "tower_seen"
const SKY := "story.backdrop.tower_sky"
const MOVE_IN := 0.7             # the camera settling on the doors while the two walk up to them
## At the doors the camera sits this far below the town's lean view, so the doors and the two stand above the talk box
## (screen rows 452 to 568) while the first line is up (the 2026-10-27 look pass found the box over all of them).
## 66 since pass 9 (W1): the two stand a row further back, so the view comes down one more tile (24 px) with them.
const TALK_ROOM := 66
## The climb's four legs (section 8): the seconds each takes and the pause after it, 8.9 s from the doors to the top.
## Where each one ends is leg_tops().
const LEG_SECS := [1.9, 1.9, 1.4, 2.4]
const LEG_PAUSE := [0.4, 0.4, 0.5, 0.0]
const APEX_ROOM := 10            # at the top the vane's tip sits this far below the screen's top edge
const HOLD := 1.5                # at least this long at the top
const REDUCED_HOLD := 2.5        # under Reduce motion: a cut to the top, at least this long there, a cut back
const PAN_DOWN := 4.5
const PARCEL_SLIDE := 2.4        # the chute parcel's slide, as the tower's own (TowerParts)
## The hoist basket's loop in TowerParts (_run_basket): 1 s resting on the yard, 4 s up, 1 s at the hoist door, 4 s
## down, 10 s round. The first leg jumps it to the moment it leaves the yard and speeds it up to arrive with the camera.
const BASKET_LOOP := 10.0
const BASKET_LEAVES := 1.0
const BASKET_RISE := 4.0
## The sky behind the tower (story.backdrop.tower_sky's placeholder) is the vast-scale mock of the hold
## (docs/design/vast-scale-2026-10-27/final/final_mocks.py hold_backdrop, saved there as slot_tower_sky.png): first
## light seen from the Waiting Lamp, 475 tiles up, a calm cool blue behind the lamp where the hold puts it (192, 127),
## the flat sea of cloud (the cloud layer's top, 360 tiles) from the horizon at y 146 down, and on the left the great
## tree's crown cap breaking it, the same tree as the title's. No tower: the scene draws the town's own over it.
const SKY_PICTURE := "res://assets/placeholders/tower_sky.png"

static var reduce_override := -1   # the checks: 1 forces the cut, 0 forces the climb, -1 reads the player's setting
static var playing := false
static var stage := ""   # where the scene is (walk, start, climb, hold, top, down, back, done), for the checks


## Whether the scene should start now: the switch on, the town showing Tower Rise, the flag not set.
static func pending(town) -> bool:
	if playing or not _alive(town) or town.team.is_empty() or town.cutscene:
		return false
	if not Layout.v2() or Layout.area_id() != AREA:
		return false
	return not seen(town)


static func seen(town) -> bool:
	return _alive(town) and bool(town._record().get("story", {}).get(FLAG, false))


## Where each leg of the climb ends: the screen's top edge in the tower's own px (TowerParts.FRAME, from its top-left;
## in the world it is the tower's origin plus this), each taken from the part that leg is for. On Tower Rise the view
## tops are -84, -226, -322 and -513.
static func leg_tops() -> Array:
	var deck: Rect2i = TP.part("town.building.hall.reel_back").get("rect", Rect2i(88, 198, 225, 93))
	return [
		int(TP.BASKET_HIGH) - 72,     # 420: the drum and the hoist, the basket's stop at the hoist door 72 px down
		int(TP.CHUTE_MOUTH.y) - 66,   # 278: the galleries, the chute's mouth on the walkway 66 px down
		deck.position.y - 16,         # 182: the Reel Deck 16 px down, its lanterns (one dark) and the bell below it
		TP.APEX.y - APEX_ROOM,        # -9: the Reach and the Waiting Lamp, the vane's tip APEX_ROOM px down
	]


## Where the Tower stands in the town's world: the doors' sill (its middle, "foot"), the tower's frame top-left
## ("origin"), the Waiting Lamp's glass ("beacon"), the vane's tip ("apex"; "top" is its row), the two tiles the two
## stand on below the doors, and the camera's looks: at the doors (the lean), at the end of each leg of the climb, and
## at the top (the hold). The tower is the town's own when it stands one, else the one the scene stands on the doors.
## The two stand two rows below the doors, one tile out past each door tile (pass 9 W1, H9-07): side by side on the
## row under the doors, 24 px apart, any two creatures wider than a tile drew over each other, and on Tower Rise the
## tiles one out on that row are the door lamps' (solid). Now they are 72 px apart, more than any two town sprites
## facing north reach across (tower_reveal_check measures every creature's).
static func geometry(town) -> Dictionary:
	var t := float(Layout.T)
	var doors := _doors()
	var x0 := 1 << 20
	var x1 := -1
	for d: Vector2i in doors:
		x0 = mini(x0, d.x)
		x1 = maxi(x1, d.x)
	var door_y: int = (doors[0] as Vector2i).y
	var foot := Vector2((x0 + x1 + 1) * 0.5 * t, (door_y + 1) * t)
	# The tower's frame stands on the sill with its door over the doors' middle: on Tower Rise its top-left is (96, -504).
	var origin := foot - Vector2(TP.DOOR.get_center().x, TP.FRAME.y)
	var own = town_tower(town)
	if own != null:
		origin = (town._world as Node2D).to_local(own.global_position)
	var axis := origin.x + TP.DOOR.get_center().x   # the door axis: the lamp hangs right over it
	var half := float(town.VIEW.y) * 0.5
	var legs: Array = []
	var tops := leg_tops()
	for k in tops.size():
		legs.append({"look": Vector2(axis, origin.y + tops[k] + half), "secs": LEG_SECS[k], "pause": LEG_PAUSE[k]})
	return {"foot": foot, "origin": origin, "beacon": origin + Vector2(TP.BEACON), "apex": origin + Vector2(TP.APEX),
		"top": origin.y + TP.APEX.y, "canvas": TP.FRAME, "door": Vector2i(x0, door_y),
		"stand": [Vector2i(x0 - 1, door_y + 2), Vector2i((x1 if x1 != x0 else x0 + 1) + 1, door_y + 2)],
		# At the doors the view leans up (TowerParts.CAMERA_LEAN) from the middle of the row the two stand on, less
		# TALK_ROOM so the talk box sits under the two, not over them.
		"door_look": Vector2(axis, (door_y + 1.5) * t - TP.CAMERA_LEAN + TALK_ROOM), "legs": legs,
		"top_look": (legs[legs.size() - 1] as Dictionary)["look"]}


## The Hall's door tiles in the area shown: Tower Rise's building, or the place on v1's map.
static func _doors() -> Array:
	var a := Layout.area(Layout.area_id())
	var entries: Array = []
	entries.append_array(a.get("buildings", []))
	entries.append_array(a.get("places", Layout.PLACES))
	for p: Dictionary in entries:
		if String(p.get("id", "")) == "hall" and p.has("door"):
			var d: Variant = p.get("door_tiles", p["door"])
			return d if d is Array else [d]
	return [Vector2i(12, 8), Vector2i(13, 8)]   # Tower Rise's


## The town's own Wayline Tower (v2: the building template hands the hall to TowerParts), or null.
static func town_tower(town) -> Variant:
	var n: Variant = _hall_node(town)
	if n is Node2D and n.has_meta("beacon") and n.is_inside_tree():
		return n
	return null


## The old Hall's picture the town draws instead (v1's map), hidden while the scene's own tower stands there; null
## when the town's hall is already the Tower.
static func _old_hall(town) -> Variant:
	var n: Variant = _hall_node(town)
	if n != null and not (n is Node2D and n.has_meta("beacon")):
		return n
	return null


## Whatever the town drew for the hall: building_exteriors.gd's (v1's picture, or on v2 the template's node), else
## the area's own art for it; null for none.
static func _hall_node(town) -> Variant:
	if not _alive(town):
		return null
	var ext: Variant = town.get("_building_exteriors")
	if is_instance_valid(ext) and "buildings" in ext:
		var b: Variant = ext.buildings.get("hall", {})
		if b is Dictionary and is_instance_valid(b.get("base")):
			return b["base"]
	var art: Variant = town.area_art.get("hall") if "area_art" in town else null
	if is_instance_valid(art) and art is CanvasItem:
		return art
	return null


## The look the town's own camera settles on (hub_town.gd _process: the leader, clamped to the area, raised by the
## look-up at the Tower's doors on Tower Rise), so the pan down hands the camera back without a jump.
static func town_look(town) -> Vector2:
	if not _alive(town) or town.team.is_empty():
		return Vector2.ZERO
	var half := Vector2(town.VIEW) * 0.5
	var look: Vector2 = town.team[0]["node"].position + Vector2(0, -12)
	var size: Vector2i = Layout.area(Layout.area_id()).get("size", Vector2i(Layout.W, Layout.H))
	var head: float = town.headroom() if town.has_method("headroom") else 0.0   # Tower Rise shows the Stack's foot over row 0
	var settled := look.clamp(half - Vector2(0, head), Vector2(size) * float(Layout.T) - half)
	if town.has_method("lean_at_rest"):
		settled.y -= float(town.lean_at_rest())
	return settled


## Where the town's camera is looking this frame, so the scene starts from it without a jump.
static func look_now(town) -> Vector2:
	if not _alive(town):
		return Vector2.ZERO
	return Vector2(town.VIEW) * 0.5 - (town._world as Node2D).position


static func _reduced() -> bool:
	return UI.reduce_motion() if reduce_override < 0 else reduce_override == 1


static func _alive(town) -> bool:
	return town != null and is_instance_valid(town) and town.is_inside_tree()


static func _timer(town, secs: float) -> SceneTreeTimer:
	return town.get_tree().create_timer(secs) if _alive(town) else null


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
	var scene := _stage(town, geo)
	# The two walk up to the doors and look up, the camera settling on the doors.
	var stand: Array = geo["stand"]
	var moves: Array = [[town.team[0], stand[0]]]
	if town.team.size() > 1:
		moves.append([town.team[1], stand[1]])
	_pan(scene["cam"], geo["door_look"], MOVE_IN)
	stage = "walk"
	await SceneKit.walk_all(town, moves)
	if _alive(town):
		# Both look straight up the Tower (north: the town's look-up keeps its lean when control comes back, and facing
		# north no two creatures' town sprites reach 72 px across, so the two never meet).
		for m: Array in moves:
			SceneKit.face(town, m[0], Vector2i((m[1] as Vector2i).x, int(geo["door"].y) - 1))
	stage = "start"
	await _say(town, "start")
	# Up the Tower in four legs, the partner talking on the way. Under Reduce motion a cut to the top, held from the cut.
	var up := _climb(scene, geo)
	var held: SceneTreeTimer = _timer(town, REDUCED_HOLD) if up == null else null
	stage = "climb"
	await _say(town, "climb")
	await _settle(town, up)
	if held == null:
		held = _timer(town, HOLD)   # game time, so it holds under a check's fixed fps too
	# The hold first, with no box up, so the whole crook and the lamp show clear; then the partner's line about it
	# (the 2026-10-27 look pass found the box over the Reach's shaft when the line came on arrival).
	stage = "hold"
	if held != null and held.time_left > 0.0:
		await held.timeout
	stage = "top"
	await _say(town, "top")
	# And back down to the two at the doors, with no box up on the way, then the partner's last lines once the camera
	# is with them (pass 9 W2, H9-03: said as the pan started, the box sat over the galleries all the way down).
	var down := _pan(scene["cam"], town_look(town), PAN_DOWN)
	stage = "down"
	await _settle(town, down)
	stage = "back"
	await _say(town, "down")
	_end(town, scene)


## The scene's own nodes: the camera, the sky behind the town's world, and the tower it climbs (the town's own, or
## one the scene stands on the doors with the old Hall hidden). "made" is everything the scene added, freed at its
## end; "hidden" what it hid, shown again.
static func _stage(town, geo: Dictionary) -> Dictionary:
	var scene := {"made": [], "hidden": [], "bell": false}
	var cam := TowerCam.new()
	cam.name = "TowerCam"
	cam.town = town
	cam.look = look_now(town)
	town.add_child(cam)
	scene["cam"] = cam
	scene["made"].append(cam)
	var sky := Sprite2D.new()   # behind the town's world: above the area's top edge there is only sky
	sky.name = "TowerSky"
	sky.texture = ArtSlots.texture(SKY)
	sky.centered = false
	town._view.add_child(sky)
	town._view.move_child(sky, 0)
	scene["made"].append(sky)
	var tower: Variant = town_tower(town)
	if tower == null:
		var old: Variant = _old_hall(town)
		if old != null and old.visible:
			old.visible = false
			scene["hidden"].append(old)
		var door: Vector2i = geo["door"]
		tower = TP.place(town._world, geo["origin"], {"z": door.y * Layout.T})
		tower.name = "RevealTower"
		scene["made"].append(tower)
	scene["tower"] = tower
	return scene


## Move the camera's look to `to` over `secs`, or cut there under Reduce motion. The tween, or null for a cut.
static func _pan(cam, to: Vector2, secs: float) -> Tween:
	if not is_instance_valid(cam) or not cam.is_inside_tree():
		return null
	if _reduced():
		cam.look = to
		return null
	var tw: Tween = cam.create_tween()
	tw.tween_property(cam, "look", to, secs).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	cam.tween = tw
	return tw


## The climb as one tween on the camera: each leg, its pause, and what the tower does as the camera passes. Under
## Reduce motion a cut to the top instead (null).
static func _climb(scene: Dictionary, geo: Dictionary) -> Tween:
	var cam: Variant = scene.get("cam")
	if not is_instance_valid(cam) or not cam.is_inside_tree():
		return null
	if _reduced():
		cam.look = geo["top_look"]
		return null
	var legs: Array = geo["legs"]
	var tw: Tween = cam.create_tween()
	for k in legs.size():
		var leg: Dictionary = legs[k]
		var secs := float(leg["secs"])
		tw.tween_callback(func() -> void: _leg_starts(scene, k, secs))
		tw.tween_property(cam, "look", leg["look"], secs).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_callback(func() -> void: _leg_ends(scene, k))
		if float(leg["pause"]) > 0.0:
			tw.tween_interval(float(leg["pause"]))
	cam.tween = tw
	return tw


## What the tower does as each leg starts: 0 the basket leaves the yard and comes up beside the camera, 1 a parcel
## slides down the chute, 2 a cradle leaves the Reel Deck toward town and the flood bell swings.
static func _leg_starts(scene: Dictionary, k: int, secs: float) -> void:
	var tower: Variant = scene.get("tower")
	if not is_instance_valid(tower):
		return
	match k:
		0:
			_basket_pace(tower, BASKET_RISE / secs, true)
		1:
			_slide_parcel(scene, tower)
		2:
			_send_cradle(scene, tower)
			TP.set_bell(tower, "swing")
			scene["bell"] = true


## As the first leg ends the basket is at the hoist door and goes back to its own pace.
static func _leg_ends(scene: Dictionary, k: int) -> void:
	var tower: Variant = scene.get("tower")
	if k == 0 and is_instance_valid(tower):
		_basket_pace(tower, 1.0, false)


## The hoist basket's own loop (TowerParts): `leave` jumps it to the moment it leaves the yard; `speed` runs it faster
## (to reach the hoist door with the camera) or at its own pace again (1).
static func _basket_pace(tower, speed: float, leave: bool) -> void:
	var basket: Variant = tower.get_node_or_null("Basket")
	if basket == null or not basket.has_meta("cycle"):
		return
	var loop: Variant = basket.get_meta("cycle")
	if not (loop is Tween) or not loop.is_valid():
		return
	if leave:
		loop.set_speed_scale(1.0)
		var at := fmod(loop.get_total_elapsed_time(), BASKET_LOOP)
		loop.custom_step(fposmod(BASKET_LEAVES - at, BASKET_LOOP))
	loop.set_speed_scale(speed)


## A parcel sliding down the chute from the walkway to the bin while the camera climbs past it the other way (the
## tower's own come every 12 to 20 s). It sits in the chute's place in the draw order, under the gable.
static func _slide_parcel(scene: Dictionary, tower) -> void:
	var parcel := Sprite2D.new()
	parcel.name = "RevealParcel"
	parcel.centered = false
	parcel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parcel.texture = ArtSlots.frame(TP.PARCEL, "oilcloth", 0)
	TP.Finish.apply(parcel, true)   # the rim every tower part has
	var slide := func(t: float) -> void:
		var p: Vector2 = TP.CHUTE_MOUTH.lerp(TP.CHUTE_SPOUT, t)
		parcel.position = Vector2(roundf(p.x) - 5, roundf(p.y) - 6)
	slide.call(0.0)
	tower.add_child(parcel)
	var under: Variant = tower.get_node_or_null("ChuteParcel")
	if under != null:
		tower.move_child(parcel, under.get_index() + 1)
	scene["made"].append(parcel)
	var tw := parcel.create_tween()
	tw.tween_method(slide, 0.0, 1.0, PARCEL_SLIDE).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(parcel.queue_free)


## A cradle leaving the Reel Deck along the wayline that runs down toward town (of the strung lines, the one whose end
## is lowest), riding it out of the picture at the town's own pace (TowerParts: about 45 px a second, 4 to 9 s).
static func _send_cradle(scene: Dictionary, tower) -> void:
	var holder: Variant = tower.get_node_or_null("Waylines")
	if holder == null:
		return
	var line: Line2D = null
	for c in holder.get_children():
		if c is Line2D and not bool(c.get_meta("quiet", false)) and c.points.size() > 1:
			if line == null or c.points[c.points.size() - 1].y > line.points[line.points.size() - 1].y:
				line = c
	if line == null:
		return
	var pts: PackedVector2Array = line.points
	var length := 0.0
	for i in pts.size() - 1:
		length += pts[i].distance_to(pts[i + 1])
	var cradle := Sprite2D.new()
	cradle.name = "RevealCradle"
	cradle.centered = false
	cradle.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	TP.Finish.apply(cradle, true)
	var sway := [ArtSlots.frame(TP.CRADLE, "loaded", 0), ArtSlots.frame(TP.CRADLE, "loaded", 1)]
	var ride := func(t: float) -> void:
		var f := t * (pts.size() - 1)
		var i := mini(int(f), pts.size() - 2)
		var p := pts[i].lerp(pts[i + 1], f - i) - Vector2(0.5, 0.5)   # the line's points sit on pixel centres
		cradle.position = Vector2(roundf(p.x) - 6, roundf(p.y) - 2)
		cradle.texture = sway[int(t * 24.0) % 2]
	ride.call(0.0)
	holder.add_child(cradle)
	scene["made"].append(cradle)
	var tw := cradle.create_tween()
	tw.tween_method(ride, 0.0, 1.0, clampf(length / 45.0, 4.0, 9.0))
	tw.tween_callback(cradle.queue_free)


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


## Puts everything back: frees what the scene added, shows the old Hall again, sets the basket to its own pace and
## the bell at rest, and hands the town back its camera and the player's control. Each node is checked first: the
## town, and all of this with it, may already be gone.
static func _end(town, scene: Dictionary) -> void:
	var tower: Variant = scene.get("tower")
	if is_instance_valid(tower):
		_basket_pace(tower, 1.0, false)
		if bool(scene.get("bell", false)):
			TP.set_bell(tower, "rest")
	for n in scene.get("made", []):
		if is_instance_valid(n):
			n.queue_free()
	for n in scene.get("hidden", []):
		if is_instance_valid(n):
			n.visible = true
	if _alive(town):
		town.talk.clear()
		town.cam_focus = null
		town.cutscene = false
	playing = false
	stage = "done"


## The camera while the scene plays: run after the town's own _process (process_priority), it sets the world's
## offset to its look, past the area's edges. The use key with no line up ends the camera move under way.
class TowerCam extends Node:
	const UIs := preload("res://scripts/ui/ui_style.gd")
	var town: Variant
	var look := Vector2.ZERO
	var tween: Tween

	func _init() -> void:
		process_priority = 100

	func _process(_delta: float) -> void:
		if not is_instance_valid(town) or not is_instance_valid(town._world):
			return
		var reading: bool = town.poll_input or town.force_scenes
		if tween != null and tween.is_valid() and tween.is_running() and town.talk.is_empty() and reading \
				and UIs.tapped_any(UIs.INPUT_ADVANCE):
			tween.custom_step(60.0)
		town._world.position = (Vector2(town.VIEW) * 0.5 - look).round()


## What the dialogue file reads ({{partner_name}}): a marker SceneKit.say turns into the partner's name.
class Cast extends RefCounted:
	var partner_name := "{partner}"


## The placeholder for story.backdrop.tower_sky (its row names this): the hold's backdrop (SKY_PICTURE), exactly the
## slot's sheet_size, opaque. No tower: it is drawn over this.
static func paint_sky(_id: String, spec: Dictionary) -> Image:
	var size: Vector2i = spec.get("sheet_size", Vector2i(384, 216))
	var img := Image.create(maxi(1, size.x), maxi(1, size.y), false, Image.FORMAT_RGBA8)
	var pic := (load(SKY_PICTURE) as Texture2D).get_image()
	pic.convert(Image.FORMAT_RGBA8)
	img.blit_rect(pic, Rect2i(Vector2i.ZERO, pic.get_size()), Vector2i.ZERO)
	return img
