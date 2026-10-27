class_name RouteScene
extends Node2D
## A walk between two places, told while the party walks it (Claude, 2026-10-26, placeholder factory lane S; Preston:
## "they just appear in the town afterwards ... a scene walking through a forest or something where they are talking").
## A side-on strip like the dungeons are data: ROUTES holds each route's length, its parallax layers (each an art slot
## with a coded placeholder at the exact size, scripts/art/slots/route.gd), the props on the trail, and its beats.
## A beat sits at an x on the trail: reaching it plays a title of the route's dialogue (the party keeps strolling
## while a line is up, never past the next beat), a "hold" beat stops the walk and the camera for its lines, and a
## "vista" beat ends the strip on a held view, then the party walks on under a black and the next scene comes up.
## The player walks with the move actions or the pad (UI.dir8) and reads with the usual keys (UI.tapped); Esc, P or
## Start ask "Back to the title?" as the dawn bank (mouth_escape.gd) does. The scene saves nothing of its own.
## The first route is the road up to Highbank (scenes/road_to_highbank.tscn), played once after the dawn bank, the
## first time the Hollow Mouth is cleared. Highbank and the Wayline Tower sit far off on the horizon the whole way,
## faded with distance (aerial perspective: HAZE mixes each far layer toward the sky, lighter, cooler and flatter),
## and grow a little as the party nears the rise.

const UI := preload("res://scripts/ui/ui_style.gd")
const Music := preload("res://scripts/audio/music.gd")
const Finish := preload("res://scripts/arena/creature_finish.gd")
const Lines := preload("res://scripts/creatures/lines.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const SceneKit := preload("res://scripts/town/scene_kit.gd")

const VIEW := Vector2i(384, 216)
const SCALE := 3.0
const BOX := Rect2(196, 452, 760, 116)   # the text box of the dawn bank and the flood talk
const ASK := Rect2(396, 236, 360, 176)   # the "Back to the title?" prompt, as on the dawn bank
const TITLE := "res://scenes/creature_opening.tscn"
const WALK_SPEED := 56.0     # px a second on the trail, the dawn bank's brisk walk
const TALK_SPEED := 38.0     # the stroll while a line is up
const AUTO_SPEED := 168.0    # the checks' autopilot
const FOLLOW_SPEED := 1.35   # a follower catches up this much faster than the walk
const CAM_LEAD := 120.0      # the leader's x on screen while walking east, so the trail ahead shows
const CAM_EASE := 4.0
const GAP := 26.0            # px between each of the party along the trail
const DEPTH := [0, -4, -7, -10]   # each follower a little further up the trail, drawn behind the one ahead
const MIN_X := 24.0
const WALK_FPS := 8.0
const LIFT_STEP := 0.05      # the most one frame takes off the opening black, in seconds (as the dawn bank)
const CHOICE_ARM := 0.3      # seconds an answer list is up before accept takes from it (as the dawn bank)
const HINT_AFTER := 1.2      # seconds standing still, with no line up, before the walk keys show
const LAMP_LIT := Color("#f2c14e")
const LAMP_DARK := Color("#4a4434")
const SMOKE := Color("#dfe1da")
## Aerial perspective: the layer's own colours mixed toward the sky's haze by `amount` (less colour first), and its
## alpha by `alpha` (the river dropping back, the trees opening). Binary-alpha art stays binary.
const HAZE_SHADER := """shader_type canvas_item;
uniform vec3 haze = vec3(0.80, 0.83, 0.85);
uniform float amount = 0.0;
uniform float alpha = 1.0;
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float y = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	vec3 low = mix(c.rgb, vec3(y), amount * 0.6);
	COLOR = vec4(mix(low, haze, amount), c.a * alpha);
}
"""

## Routes as data. Layers are drawn in order; "front" ones over the party. A strip layer tiles and scrolls at
## `parallax` (0 still, 1 with the trail); the far town has its own x, scale and haze from the start of the trail
## to the rise. `drop` [from, to, px] lowers and fades a layer over that stretch of the trail (0 to 1), `open`
## [from, to] fades one out. Beats: `title` in the route's dialogue, `hold` stops the walk for its lines, `vista`
## ends the strip on that slot's held view.
const ROUTES := {
	"road_to_highbank": {
		"talk": "res://dialogue/road_to_highbank.dialogue",
		"music": "morning_call",
		"next": "res://scenes/hub_town.tscn",
		"length": 3900.0,
		"start_x": 64.0,
		"feet_y": 146.0,
		"layers": [
			{"slot": "road.backdrop.sky", "parallax": 0.0},
			{"slot": "road.backdrop.highbank_far", "far": true, "x": [300.0, 236.0], "y": 108.0, "scale": [0.82, 1.0], "haze": [0.5, 0.3]},
			{"slot": "road.backdrop.far", "parallax": 0.12, "haze": 0.45},
			{"slot": "road.backdrop.river", "parallax": 0.3, "haze": 0.2, "drop": [0.05, 0.55, 18.0]},
			{"slot": "road.backdrop.mid", "parallax": 0.45, "haze": 0.1, "open": [0.86, 0.97]},
			{"slot": "road.ground.path", "parallax": 1.0},
			{"slot": "road.backdrop.near", "parallax": 1.35, "front": true},
		],
		"props": [
			{"slot": "road.prop.ferry_sign", "x": 430.0, "y": 141.0},
			{"slot": "road.prop.waymark", "x": 1236.0, "y": 141.0},
			{"slot": "road.prop.lost_parcel", "x": 2016.0, "y": 146.0},
		],
		"beats": [
			{"id": "bluff", "x": 260.0, "title": "trail_bluff"},
			{"id": "tower", "x": 1150.0, "title": "trail_tower"},
			{"id": "parcel", "x": 1984.0, "title": "trail_parcel", "hold": true},
			{"id": "crew", "x": 2700.0, "title": "trail_crew"},
			{"id": "rise", "x": 3500.0, "title": "rise", "vista": "road.backdrop.vista"},
		],
	},
}

@export var route_id := "road_to_highbank"
var route: Dictionary
var autopilot := false   # the checks' walker (pilot_chain_check): walks east and reads every line, the first answer
var line: DialogueLine
var choice := 0
var leaving := false
var asking := false      # the "Back to the title?" prompt is up
var ask_row := 0
var started := false     # the opening black is gone and the party has walked on
var fired: Array[String] = []   # beat ids in the order they played (road_check reads it)
var beat_now := ""       # the beat whose lines are up
var holding := false     # a hold beat or the vista: nobody walks
var in_vista := false
var actors: Array[Sprite2D] = []
var forms: Array[String] = []
var xs: Array[float] = []        # each of the party's x along the trail
var faces: Array[String] = []
var walking: Array[bool] = []
var cam_x := 0.0
var _talk: DialogueResource
var _names: Array[String] = []
var _clock := 0.0
var _idle := 0.0
var _lift := 0.0
var _list_age := -1.0
var _list_of: DialogueLine
var _fetching := false
var _vp: SubViewport
var _strip: Node2D               # props and the party, sorted by their feet
var _layers: Array = []          # [layer data, Sprite2D, ShaderMaterial]
var _props: Array = []           # [prop data, Sprite2D]
var _box: Node2D
var _veil: ColorRect
var _vista: Sprite2D
var _fx: Node2D
var _vista_t := 0.0
var _vista_spec: Dictionary
var _foot := {}                  # texture path -> [Texture2D, foot offset], read once
var _reduce := false

# Read by the dialogue file ({{...}}).
var partner_name: String:
	get: return _names[1] if _names.size() > 1 else "Your partner"


func _ready() -> void:
	get_tree().root.content_scale_size = Vector2i(1152, 648)
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	route = ROUTES.get(route_id, ROUTES["road_to_highbank"])
	_reduce = UI.reduce_motion()
	_talk = load(String(route["talk"]))
	# Highbank's street keeps painting on its worker while the road plays (hub_town.gd bake_ahead; the dawn bank asked
	# first, and a second ask while it paints does nothing).
	if String(route["next"]).ends_with("hub_town.tscn"):
		load("res://scripts/town/hub_town.gd").bake_ahead(get_tree())
	_vp = SubViewport.new()
	_vp.size = VIEW
	_vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_vp)
	var display := Sprite2D.new()
	display.texture = _vp.get_texture()
	display.centered = false
	display.scale = Vector2.ONE * SCALE
	display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(display)
	for layer: Dictionary in route["layers"]:
		if layer.get("front", false):
			continue
		_add_layer(layer)
	_strip = Node2D.new()
	_vp.add_child(_strip)
	for prop: Dictionary in route["props"]:
		var s := Sprite2D.new()
		s.texture = ArtSlots.texture(String(prop["slot"]))
		s.centered = false
		var anchor: Vector2i = ArtSlots.spec(String(prop["slot"])).get("anchor", Vector2i.ZERO)
		s.offset = -Vector2(anchor)
		s.z_index = int(prop["y"])
		_strip.add_child(s)
		_props.append([prop, s])
	var party: Array = TeamState.data.get("party", [[0, 0], [1, 0]])
	for i in mini(party.size(), DEPTH.size()):
		forms.append(String(Lines.of(party[i][0]).forms[party[i][1]][0]))
		_names.append(SceneKit.name_of(int(party[i][0]), int(party[i][1])))
		var s := Sprite2D.new()
		Finish.apply(s, false, forms[i])
		_strip.add_child(s)
		actors.append(s)
		xs.append(-30.0 - GAP * i)   # off the left edge: they walk on as the black lifts
		faces.append("e")
		walking.append(false)
	for layer: Dictionary in route["layers"]:
		if layer.get("front", false):
			_add_layer(layer)
			(_layers[_layers.size() - 1][1] as Sprite2D).z_index = 400   # over the party, whose z is its feet
	_fx = Node2D.new()
	_fx.z_index = 1000
	_fx.draw.connect(_draw_fx)
	_vp.add_child(_fx)
	var ui := CanvasLayer.new()
	add_child(ui)
	_box = Node2D.new()
	_box.draw.connect(_draw_ui)
	ui.add_child(_box)
	_veil = ColorRect.new()
	_veil.size = Vector2(1152, 648)
	_veil.color = Color.BLACK
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(_veil)
	Music.play(get_tree(), String(route.get("music", "")))
	_lift = 0.3 if _reduce else 1.2
	_layout(0.0)
	_walk_on()


## One layer as a sprite: a strip layer repeats across the view, the far town is one picture.
func _add_layer(layer: Dictionary) -> void:
	var id := String(layer["slot"])
	var s := Sprite2D.new()
	s.texture = ArtSlots.texture(id)
	s.centered = false
	var mat := ShaderMaterial.new()
	mat.shader = _haze_shader()
	s.material = mat
	var spec := ArtSlots.spec(id)
	if layer.get("far", false):
		var anchor: Vector2i = spec.get("anchor", Vector2i.ZERO)
		s.offset = -Vector2(anchor)
	else:
		s.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		s.region_enabled = true
		var place: Vector2i = spec.get("place_at", Vector2i.ZERO)
		s.position = Vector2(place)
	_vp.add_child(s)
	_layers.append([layer, s, mat])


## The Dialogue Manager autoload, found at run time: a check that preloads this script (or tower_reveal.gd, which
## paints with it) compiles it before the autoloads are named, so the autoload's name is not written in the code.
static func dialogue_manager() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	return tree.root.get_node_or_null("DialogueManager") if tree != null else null


static var _shader: Shader
static func _haze_shader() -> Shader:
	if _shader == null:
		_shader = Shader.new()
		_shader.code = HAZE_SHADER
	return _shader


## The party walks on from the left edge while the black lifts; then the trail is the player's.
func _walk_on() -> void:
	var to := float(route["start_x"])
	var secs := 0.5 if _reduce else 1.6
	var tw := create_tween()
	tw.tween_method(func(v: float) -> void: _set_lead(v), xs[0], to, secs)
	await tw.finished
	started = true


func _set_lead(x: float) -> void:
	walking[0] = absf(x - xs[0]) > 0.01
	if x != xs[0]:
		faces[0] = "e" if x > xs[0] else "w"
	xs[0] = x


func _process(delta: float) -> void:
	_clock += delta
	if _lift > 0.0:
		_veil.color.a = maxf(0.0, _veil.color.a - minf(delta, LIFT_STEP) / _lift)
		if _veil.color.a <= 0.0:
			_lift = 0.0
	if in_vista:
		_vista_t += delta
	if not leaving:
		_watch_choices(delta)
		_input_step(delta)
	_follow(delta)
	if not in_vista:
		_camera(delta)
		_layout(_progress())
	_pose()
	_fx.queue_redraw()
	_box.queue_redraw()


## How far along the trail the leader is, 0 at the start to 1 at the last beat.
func _progress() -> float:
	var beats: Array = route["beats"]
	var end := float(beats[beats.size() - 1]["x"])
	return clampf(xs[0] / end, 0.0, 1.0)


## The next beat that has not played, or {} after the last.
func next_beat() -> Dictionary:
	for b: Dictionary in route["beats"]:
		if not fired.has(String(b["id"])):
			return b
	return {}


## Keys and the pad (or the autopilot): lines, the title prompt, then walking.
func _input_step(delta: float) -> void:
	var lead_was := xs[0]
	if not started or _lift > 0.0:
		return   # the walk on from the left edge moves the leader meanwhile
	walking[0] = false
	if autopilot:
		if line != null and Engine.get_process_frames() % 4 == 0:
			UI.finish_line()
			advance()
	elif asking:
		_poll_ask()
		return
	elif UI.tapped_any(["cancel", "pause"]):
		_ask()
		return
	elif line != null:
		_poll_line()
	if in_vista or holding:
		return
	var nb := next_beat()
	var stop: float = float(nb["x"]) if not nb.is_empty() else float(route["length"]) - VIEW.x * 0.5
	var dx := 0.0
	if line != null or _fetching:
		dx = (AUTO_SPEED if autopilot else TALK_SPEED) * delta   # the party strolls while a line is up
		stop -= 6.0   # and stops short of the next beat, which plays once the line is read
	elif autopilot:
		dx = AUTO_SPEED * delta
	else:
		dx = float(UI.dir8().x) * WALK_SPEED * delta
	var x := clampf(xs[0] + dx, MIN_X, maxf(MIN_X, stop))
	if absf(x - xs[0]) > 0.001:
		faces[0] = "e" if x > xs[0] else "w"
	xs[0] = x
	walking[0] = absf(xs[0] - lead_was) > 0.001
	_idle = 0.0 if walking[0] or line != null else _idle + delta
	if line == null and not _fetching and not nb.is_empty() and xs[0] >= float(nb["x"]) - 0.5:
		_fire(nb)


## A beat plays: its title's lines, a hold or the held view.
func _fire(b: Dictionary) -> void:
	fired.append(String(b["id"]))
	beat_now = String(b["id"])
	if b.has("vista"):
		_go_vista(b)
		return
	holding = bool(b.get("hold", false))
	if holding:
		faces[0] = "e"
	_open_talk(String(b["title"]))


func _open_talk(title: String) -> void:
	_fetching = true
	line = await dialogue_manager().get_next_dialogue_line(_talk, title, [self])
	_fetching = false
	if line == null:
		_talk_done()


func _talk_done() -> void:
	beat_now = ""
	holding = false
	if in_vista and not leaving:
		_leave()


## Called from the dialogue (as on the dawn bank): the party walks a stretch further. On the road the lines walk the
## party by themselves, so this is a small step forward and never past the next beat.
func walk_on() -> void:
	var nb := next_beat()
	var stop: float = float(nb["x"]) - 6.0 if not nb.is_empty() else xs[0]
	xs[0] = minf(xs[0] + 24.0, maxf(xs[0], stop))


# ------------------------------------------------------------------------------------------------ lines

func _poll_line() -> void:
	if UI.tapped_any(UI.INPUT_ADVANCE):
		if _choices_armed():
			advance()
	elif _choices_up():
		var d := int(UI.tapped("move_down")) - int(UI.tapped("move_up"))
		if d != 0:
			choice = posmod(choice + d, line.responses.size())
			UI.tick("cursor")


func _choices_up() -> bool:
	return line != null and not line.responses.is_empty() and UI.line_done(line.text)


func _watch_choices(delta: float) -> void:
	if not _choices_up():
		_list_age = -1.0
	elif _list_age < 0.0 or _list_of != line:
		_list_age = 0.0
		_list_of = line
		UI.sync_taps(UI.INPUT_ADVANCE)
	else:
		_list_age += delta


func _choices_armed() -> bool:
	return _list_age < 0.0 or _list_age >= CHOICE_ARM


## The rest of the line, then the next line (or the chosen answer's branch).
func advance() -> void:
	if leaving or line == null or _fetching:
		return
	if not UI.line_done(line.text):
		UI.finish_line()
		return
	var next := line.next_id
	if not line.responses.is_empty():
		next = line.responses[choice].next_id
		UI.tick("confirm")
	choice = 0
	_fetching = true
	line = await dialogue_manager().get_next_dialogue_line(_talk, next, [self])
	_fetching = false
	if line == null:
		_talk_done()


# ------------------------------------------------------------------------------------------------ the title prompt

func _ask() -> void:
	asking = true
	ask_row = 0
	UI.tick("open")


func _poll_ask() -> void:
	if UI.tapped_any(["cancel", "pause"]):
		asking = false
		UI.tick("cancel")
	elif UI.tapped_any(["move_down", "move_up"]):
		ask_row = 1 - ask_row
		UI.tick("cursor")
	elif UI.tapped_any(UI.INPUT_ADVANCE):
		if ask_row == 0:
			asking = false
			UI.tick("cancel")
		else:
			_title()


func _title() -> void:
	leaving = true
	UI.tick("confirm")
	_veil.mouse_filter = Control.MOUSE_FILTER_STOP
	await create_tween().tween_property(_veil, "color:a", 1.0, 0.15 if _reduce else 0.5).finished
	if get_tree().change_scene_to_file(TITLE) != OK:
		leaving = false
		asking = false
		_veil.color.a = 0.0
		_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE


# ------------------------------------------------------------------------------------------------ the party

## Each follower keeps GAP behind the one ahead, on the side it walked from, and catches up a little faster than
## the walk. In the held view the party stands where the view put it.
func _follow(delta: float) -> void:
	if in_vista:
		return
	var speed := (AUTO_SPEED if autopilot else maxf(WALK_SPEED, TALK_SPEED)) * FOLLOW_SPEED
	for i in range(1, xs.size()):
		var side := 1.0 if faces[i - 1] == "e" else -1.0
		var want := xs[i - 1] - GAP * side
		var step := clampf(want - xs[i], -speed * delta, speed * delta)
		walking[i] = absf(step) > 0.05
		if walking[i]:
			faces[i] = "e" if step > 0.0 else "w"
		elif not walking[i - 1]:
			faces[i] = faces[i - 1]
		xs[i] += step


func _camera(delta: float) -> void:
	var want := xs[0] - (CAM_LEAD if faces[0] == "e" else VIEW.x - CAM_LEAD)
	if holding:
		want = cam_x
	want = clampf(want, 0.0, float(route["length"]) - VIEW.x)
	cam_x = lerpf(cam_x, want, 1.0 - exp(-delta * CAM_EASE)) if started else want


## Where every layer, prop and member of the party is drawn for the camera and `p`, the way along the trail.
func _layout(p: float) -> void:
	var cx := roundf(cam_x)
	for entry: Array in _layers:
		var layer: Dictionary = entry[0]
		var s: Sprite2D = entry[1]
		var mat: ShaderMaterial = entry[2]
		var haze: Variant = layer.get("haze", 0.0)
		if layer.get("far", false):
			var xr: Array = layer["x"]
			var sr: Array = layer["scale"]
			var hr: Array = haze
			s.position = Vector2(roundf(lerpf(xr[0], xr[1], p)), float(layer["y"]))
			s.scale = Vector2.ONE * lerpf(sr[0], sr[1], p)
			mat.set_shader_parameter("amount", lerpf(hr[0], hr[1], p))
			continue
		var w := float(s.texture.get_width())
		s.region_rect = Rect2(fposmod(roundf(cx * float(layer.get("parallax", 0.0))), w), 0.0, VIEW.x, s.texture.get_height())
		mat.set_shader_parameter("amount", float(haze))
		var place: Vector2i = ArtSlots.spec(String(layer["slot"])).get("place_at", Vector2i.ZERO)
		if layer.has("drop"):
			var d: Array = layer["drop"]
			var k := smoothstep(float(d[0]), float(d[1]), p)
			s.position.y = roundf(place.y + float(d[2]) * k)
			mat.set_shader_parameter("alpha", 1.0 - k)
		if layer.has("open"):
			var o: Array = layer["open"]
			mat.set_shader_parameter("alpha", 1.0 - smoothstep(float(o[0]), float(o[1]), p))
	for entry: Array in _props:
		var prop: Dictionary = entry[0]
		(entry[1] as Sprite2D).position = Vector2(roundf(float(prop["x"]) - cx), float(prop["y"]))
	var feet := float(route["feet_y"])
	for i in actors.size():
		actors[i].position = Vector2(roundf(xs[i] - cx), feet + DEPTH[i])


## Each picture: a walk frame while it walks, the still facing the way it last went.
func _pose() -> void:
	for i in actors.size():
		var dir := "res://assets/sprites/arena/%s/small/" % forms[i]
		if not ResourceLoader.exists(dir + "s.png"):
			dir = "res://assets/sprites/arena/%s/dungeon/" % forms[i]   # the Hollow wilds have no small set
		var path := dir + "%s.png" % faces[i]
		if walking[i]:
			var walk := dir + "walk_%s_f%d.png" % [faces[i], int(_clock * WALK_FPS) % 8]
			if ResourceLoader.exists(walk):
				path = walk
		var got: Array = _read(path, dir + "s.png")
		actors[i].texture = got[0]
		actors[i].offset.y = got[1]
		actors[i].z_index = int(actors[i].position.y) + (600 if in_vista else 0)   # over the held view once it is up


## A picture and how far to lift it so its lowest drawn row stands on its position, read once a path.
func _read(path: String, fallback: String) -> Array:
	if _foot.has(path):
		return _foot[path]
	var use := path if ResourceLoader.exists(path) else fallback
	var tex: Texture2D = load(use)
	var off := 0.0
	if tex != null:
		var used := tex.get_image().get_used_rect()
		off = tex.get_height() * 0.5 - used.end.y
	_foot[path] = [tex, off]
	return _foot[path]


# ------------------------------------------------------------------------------------------------ the held view

## The rise: the trees open on the held view, the party stands at its edge, the lamps below go out one by one while
## the lines play; then they walk on down toward the gate under the black.
func _go_vista(b: Dictionary) -> void:
	holding = true
	var id := String(b["vista"])
	_vista_spec = ArtSlots.spec(id)
	_vista = Sprite2D.new()
	_vista.texture = ArtSlots.texture(id)
	_vista.centered = false
	_vista.z_index = 500
	_vista.modulate.a = 0.0
	_vp.add_child(_vista)
	var fade := create_tween()
	fade.tween_property(_vista, "modulate:a", 1.0, 0.05 if _reduce else 0.8)
	await fade.finished
	in_vista = true
	_vista_t = 0.0
	var anchors: Dictionary = _vista_spec.get("anchors", {})
	var spot: Vector2 = Vector2(anchors.get("party", Vector2i(84, 148)))
	for i in actors.size():
		actors[i].position = spot + Vector2(-GAP * i, DEPTH[i])
		faces[i] = "ne"
		walking[i] = false
	_open_talk(String(b["title"]))


## Off the rise toward the gate (as the dawn bank leaves its painting): down to the right, the black down as the
## last of them goes, then the next scene with the team's record.
func _leave() -> void:
	leaving = true
	var secs := 0.4 if _reduce else 2.4
	var lag := 0.14
	for i in actors.size():
		faces[i] = "se"
		walking[i] = true
		var tw := create_tween()
		tw.tween_interval(lag * i)
		tw.tween_property(actors[i], "position", actors[i].position + Vector2(150, 96), secs)
	var fade_secs := 0.2 if _reduce else 0.9
	var all := secs + lag * (actors.size() - 1)
	await create_tween().tween_property(_veil, "color:a", 1.0, fade_secs).set_delay(maxf(0.0, all - fade_secs)).finished
	var next: Node = load(String(route["next"])).instantiate()
	TeamState.give_to(next)
	get_tree().change_scene_to_node(next)


## Over the held view: the street lamps below going out one by one, chimney smoke, the Tower's beacon. On the trail:
## the far Tower's beacon, a pinprick of light.
func _draw_fx() -> void:
	if in_vista:
		var anchors: Dictionary = _vista_spec.get("anchors", {})
		var k := 0
		for key: String in anchors:
			if not key.begins_with("lamp_"):
				continue
			var at: Vector2 = Vector2(anchors[key])
			var lit := _vista_t < 1.6 + k * 1.3
			_fx.draw_rect(Rect2(at - Vector2(1, 1), Vector2(2, 2)), LAMP_LIT if lit else LAMP_DARK)
			if lit:
				_fx.draw_rect(Rect2(at - Vector2(2, 2), Vector2(4, 4)), Color(LAMP_LIT, 0.3))
			k += 1
		for key: String in anchors:
			if not key.begins_with("chimney_"):
				continue
			var top: Vector2 = Vector2(anchors[key])
			for puff in 4:
				var t := fposmod(_vista_t * 0.35 + puff * 0.25 + top.x * 0.013, 1.0) if not _reduce else puff * 0.25
				var at := top + Vector2(roundf(t * 5.0 + sin(t * 6.0 + top.x) * 1.2), -roundf(t * 22.0) - 1.0)
				var size := 1.0 if t < 0.4 else 2.0
				_fx.draw_rect(Rect2(at, Vector2(size, size)), Color(SMOKE, 0.75 * (1.0 - t)))
		var beacon: Vector2 = Vector2(anchors.get("beacon", Vector2i(-10, -10)))
		var pulse := 0.5 if _reduce else 0.35 + 0.25 * sin(_vista_t * 2.4)
		_fx.draw_rect(Rect2(beacon - Vector2(2, 2), Vector2(5, 5)), Color(LAMP_LIT, pulse))
		return
	for entry: Array in _layers:
		var layer: Dictionary = entry[0]
		if not layer.get("far", false):
			continue
		var s: Sprite2D = entry[1]
		var b: Vector2i = ArtSlots.spec(String(layer["slot"])).get("anchors", {}).get("beacon", Vector2i(-1, -1))
		if b.x < 0:
			continue
		var at := (s.position + (Vector2(b) + s.offset) * s.scale).round()
		var a := 0.6 if _reduce else 0.35 + 0.3 * absf(sin(_clock * 1.7))
		_fx.draw_rect(Rect2(at, Vector2.ONE), Color(LAMP_LIT, a))


# ------------------------------------------------------------------------------------------------ the text box

func _draw_ui() -> void:
	if leaving and not asking:
		return
	if line != null:
		var face: String = line.tags[0] if not line.tags.is_empty() else "normal"
		var tex: Texture2D = null
		if line.character != "" and forms.size() > 1:
			tex = UI.dialogue_portrait(forms[1] + (":" + face if face != "normal" else ""))
		UI.dialogue(_box, BOX, line.character, line.text, tex, _clock, 20, face)
		if _choices_up():
			_draw_choices()
	elif started and not holding and not in_vista and _idle >= HINT_AFTER and not autopilot:
		# The walk keys, once the party has stood a moment with nothing to read: the trail goes on to the right.
		var words := "%s  walk" % SceneKit.walk_keys()
		var w := ceilf(UI.width_in(words, "label") + 40.0)
		var r := Rect2(1152 - 24 - w, 648 - 24 - 46, w, 46)
		UI.panel(_box, r, 0.9)
		UI.say(_box, r.position + Vector2(20, 31), words, "label", UI.TEXT)
	if asking:
		UI.panel(_box, ASK, 0.95, true)
		UI.say(_box, ASK.position + Vector2(36, 48), "Back to the title?", "body", UI.TEXT)
		for k in 2:
			var at := ASK.position + Vector2(80, 96 + k * 36)
			if k == ask_row:
				UI.say(_box, at - Vector2(28, 0), ">", "button", UI.EDGE_LIGHT)
			UI.say(_box, at, ["Resume", "Return"][k], "button", UI.EDGE_LIGHT if k == ask_row else UI.MUTED)


## The answers as the dawn bank draws them: the story role at the line's row height, the list as wide as its longest
## answer and clear of the text box, the highlighted answer on the focus row with the box's arrow pointing at it.
func _draw_choices() -> void:
	var rows := line.responses.size()
	var f := UI.font("story")
	var pitch := f.get_height(UI.type_size("story"))
	var w := 0.0
	for k in rows:
		w = maxf(w, UI.width_in(String(line.responses[k].text), "story"))
	var width := ceilf((w + 72.0) * 0.5) * 2.0
	var tall := 34.0 + rows * pitch
	var r := Rect2(BOX.end.x - width, BOX.position.y - 10 - tall, width, tall)
	UI.panel(_box, r, 0.95)
	var ascent := f.get_ascent(UI.type_size("story"))
	for k in rows:
		var at := r.position + Vector2(44, 44 + k * pitch)
		if k == choice:
			var row := Rect2(r.position.x + 15, at.y - ascent + 3, r.size.x - 30, pitch - 6)
			UI.focus_row(_box, row, 2.0)
			_cursor(Vector2(r.position.x + 21, row.get_center().y), 0.0 if _reduce else _clock)
		UI.say(_box, at, String(line.responses[k].text), "story", UI.EDGE_LIGHT if k == choice else UI.MUTED)


func _cursor(mid: Vector2, t: float) -> void:
	var tex: Texture2D = UI.icon("frame/arrow")
	if tex == null:
		UI.say(_box, Vector2(mid.x, mid.y + 10), ">", "story", UI.EDGE_LIGHT)
		return
	var x := mid.x + 3.0 * float(int(t * 2.0) % 2)
	_box.draw_set_transform(Vector2(x, roundf(mid.y + tex.get_width() * 0.5)), -PI * 0.5, Vector2.ONE)
	_box.draw_texture(tex, Vector2.ZERO)
	_box.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# ================================================================================================ placeholders
# The coded placeholders for the road's slots (scripts/art/slots/route.gd names this as each row's "placeholder"):
# flat shapes in the house colours at exactly the slot's sheet_size, lit from the upper left, binary alpha or opaque
# as the row says, nothing on an edge the row does not allow. Farther layers carry fewer tones and less detail.

const INK := Color("#0b0e11")
const WOOD := Color("#80694a")
const WOOD_LIT := Color("#bba17a")
const WOOD_SHADE := Color("#5f4d36")
const BRASS := Color("#b69b6d")
const BRASS_LIT := Color("#e4ca8e")
const SEAL := Color("#3fa79b")
const SEAL_LIT := Color("#5fc1b4")
const MUD := Color("#5a4836")
const MUD_LIT := Color("#6b563f")
const SHEEN := Color("#8ea3a2")
const SKY_DAWN := ["#4d6582", "#5f7894", "#7a90a6", "#9aa9b4", "#bcbbb2", "#d6baa4", "#e8c69c", "#f2d8a8", "#f6e6c0"]
const SKY_DAWN_AT := [40, 70, 92, 108, 120, 130, 138, 146]
const SKY_RISE := ["#56708e", "#6a84a0", "#879db0", "#a9b5ba", "#cdc6b4", "#e4cba6", "#f0d59f", "#f7e3b5"]
const SKY_RISE_AT := [34, 60, 80, 96, 106, 114, 120]


## The placeholder for one road slot, by the last part of its id; exactly spec.sheet_size.
static func paint_slot(id: String, spec: Dictionary) -> Image:
	var size: Vector2i = spec.get("sheet_size", Vector2i.ONE)
	var img := Image.create(maxi(1, size.x), maxi(1, size.y), false, Image.FORMAT_RGBA8)
	match id.get_slice(".", id.get_slice_count(".") - 1):
		"sky":
			sky(img, SKY_DAWN, SKY_DAWN_AT)
			_cloud(img, 36, 48, 104, Color("#8696a8"), Color("#e2c4a2"))
			_cloud(img, 214, 76, 120, Color("#97a3b0"), Color("#ecca9f"))
			_cloud(img, 18, 96, 70, Color("#a9b0b4"), Color("#efd3a6"))
		"highbank_far":
			_far_town(img, spec)
		"far":
			_hills(img, 52, [4.0, 2.0, 1.0], [2, 5, 11], [0.3, 1.1, 2.0], Color("#93a6aa"), Color("#aebdbf"))
			_hills(img, 41, [3.0, 2.0], [3, 7], [0.5, 2.4], Color("#7f9394"), Color("#92a5a5"))
		"river":
			_river(img)
		"mid":
			_willows(img)
		"path":
			_path(img)
		"near":
			_ferns(img)
		"ferry_sign":
			_ferry_sign(img)
		"waymark":
			_waymark(img)
		"lost_parcel":
			_parcel(img)
		"vista":
			_vista_art(img, spec)
	return img


static func _r(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	var cut := Rect2i(x, y, w, h).intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	if cut.size.x > 0 and cut.size.y > 0:
		img.fill_rect(cut, c)


static func _p(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
		img.set_pixel(x, y, c)


## A small fixed hash, so every placeholder paints the same each time.
static func _h(n: int) -> int:
	var v := (n * 374761393 + 668265263) & 0x7fffffff
	v = ((v ^ (v >> 13)) * 1274126177) & 0x7fffffff
	return v


## Opaque bands of `tones` from the top, each starting at its row in `at`, with two dithered rows above each step.
static func sky(img: Image, tones: Array, at: Array) -> void:
	var w := img.get_width()
	var h := img.get_height()
	img.fill(Color(String(tones[0])))
	for k in range(1, tones.size()):
		var y0: int = at[k - 1]
		var c := Color(String(tones[k]))
		_r(img, 0, y0, w, h - y0, c)
		for x in w:
			if (x + y0) % 2 == 0:
				_p(img, x, y0 - 1, c)
			if x % 4 == y0 % 4:
				_p(img, x, y0 - 2, c)


## A torn cloud band: a streak with its underside lit by the low sun.
static func _cloud(img: Image, x: int, y: int, length: int, body: Color, lit: Color) -> void:
	_r(img, x + 4, y, length - 10, 1, body)
	_r(img, x, y + 1, length, 1, body)
	_r(img, x + 3, y + 2, length - 8, 1, lit)
	_r(img, x + length / 3, y - 1, length / 4, 1, body)


## A hill line that tiles (whole waves across the width), crowns broken by tree bumps, filled to the bottom.
static func _hills(img: Image, base: int, amp: Array, freq: Array, phase: Array, body: Color, lit: Color) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for x in w:
		var t := TAU * float(x) / float(w)
		var tall := float(base)
		for k in amp.size():
			tall += float(amp[k]) * sin(t * float(freq[k]) + float(phase[k]))
		tall += [0, 1, 2, 1, 0, 1][x % 6]
		var top := clampi(h - int(tall), 1, h - 1)
		_r(img, x, top, 1, h - top, body)
		_p(img, x, top, lit)


## Highbank miles off: a flat bluff with a few roofs, and the Tower over it, a beacon at the top. Few tones.
static func _far_town(img: Image, spec: Dictionary) -> void:
	var bluff := Color("#7d8c96")
	var bluff_lit := Color("#93a2aa")
	var roof := Color("#6c7b88")
	var wall := Color("#8a99a3")
	var tower := Color("#74838f")
	var tower_lit := Color("#a3b1b8")
	var cap := Color("#5f6e7c")
	# The bluff: sloped sides, a flat top at row 74, running off the bottom.
	for y in range(74, 96):
		var inset := maxi(0, 14 - (y - 74))
		_r(img, 8 + inset, y, 144 - inset * 2, 1, bluff)
	_r(img, 22, 74, 116, 1, bluff_lit)
	# Roofs on the bluff top, in two rows.
	for k in 9:
		var x := 26 + k * 12 + (_h(k) % 4)
		var tall := 5 + _h(k + 9) % 4
		_r(img, x, 74 - tall, 8, tall, wall)
		for j in 4:   # a gable, widest at the eaves
			_r(img, x + j, 74 - tall - 1 - j, 8 - j * 2, 1, roof)
	# The Tower: wider at its foot, a cap, a mast and the beacon.
	var b: Vector2i = spec.get("anchors", {}).get("beacon", Vector2i(92, 6))
	for y in range(16, 74):
		var half := 5 + (y - 16) / 24
		_r(img, b.x - half, y, half * 2 + 1, 1, tower)
		_p(img, b.x - half, y, tower_lit)
	_r(img, b.x - 7, 13, 15, 3, cap)
	_r(img, b.x, b.y + 2, 1, 11 - b.y, cap)
	_r(img, b.x - 1, b.y - 1, 3, 3, Color("#c9a24a"))


static func _river(img: Image) -> void:
	var w := img.get_width()
	var bank := Color("#5e6f62")
	var grass := Color("#6f8060")
	var water := Color("#6d8e98")
	var streak := Color("#86a6ad")
	var glint := Color("#d7e5e3")
	_r(img, 0, 2, w, 2, bank)
	for x in range(0, w, 3):
		if _h(x) % 3 == 0:
			_p(img, x, 1, grass)
	_r(img, 0, 4, w, 19, water)
	for k in 26:
		var x := (_h(k) % w)
		var y := 6 + _h(k + 40) % 15
		var length := 6 + _h(k + 80) % 14
		for i in length:
			_p(img, (x + i) % w, y, streak)
	for k in 14:
		_p(img, _h(k + 120) % w, 5 + _h(k + 160) % 16, glint)


## Willows along the trail: crowns with hanging strands, trunks down to the trail, flood debris caught in them.
static func _willows(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var trunk := Color("#4a4434")
	var trunk_lit := Color("#5d5642")
	var trunk_dark := Color("#3b3629")
	var leaf_dark := Color("#44573a")
	var leaf := Color("#566d45")
	var leaf_lit := Color("#6c8452")
	var strand := Color("#5f7a4a")
	var drift := Color("#7a6a52")
	var drift_lit := Color("#8f7d61")
	var reed := Color("#8b7b5c")
	# Undergrowth along the bottom, so the layer tiles without a seam.
	for x in w:
		var top: int = h - 6 - [0, 1, 2, 1, 0, 2, 3, 1][x % 8]
		_r(img, x, top, 1, h - top, leaf_dark)
	for tree in [[70, 34, 40, 25], [262, 38, 36, 24]]:
		var cx: int = tree[0]
		var cy: int = tree[1]
		var rx: int = tree[2]
		var ry: int = tree[3]
		# The trunk, a little lean, roots flared at the foot.
		for y in range(cy, h):
			var lean := (h - y) / 22
			_r(img, cx - 3 + lean, y, 7, 1, trunk)
			_p(img, cx - 3 + lean, y, trunk_lit)
			_p(img, cx + 3 + lean, y, trunk_dark)
		_r(img, cx - 6, h - 3, 13, 3, trunk_dark)
		# The crown: a dome, its upper-left rim and a few dapples lit, darker deep inside.
		var eave := cy + ry / 4
		for y in range(cy - ry, eave + 1):
			var dy := float(y - cy) / float(ry)
			var half := int(rx * sqrt(maxf(0.0, 1.0 - dy * dy)))
			if half <= 0:
				continue
			_r(img, cx - half, y, half * 2 + 1, 1, leaf)
			_r(img, cx - half, y, 2 + maxi(0, int(-dy * 4.0)), 1, leaf_lit)
			if dy > -0.4:   # the shade under the dome, widening toward the eave
				var dark := int(half * 1.5 * clampf((dy + 0.4) / 0.65, 0.0, 1.0))
				_r(img, cx + 3 - dark / 2, y, dark, 1, leaf_dark)
		_r(img, cx - rx / 2, cy - ry, rx, 2, leaf_lit)
		for k in 9:
			var dx := _h(cx + k) % rx - rx / 2 - 6
			var dyp := _h(cx + k + 50) % (ry / 2 + 1)
			_r(img, cx + dx, cy - ry + 3 + dyp, 3, 2, leaf_lit)
		# The weeping curtain: strands from the eave down, uneven, gaps every third column to see through.
		var eave_half := int(rx * sqrt(maxf(0.0, 1.0 - pow(float(eave - cy) / float(ry), 2.0))))
		for sx in range(cx - eave_half, cx + eave_half + 1):
			if (sx - cx) % 3 == 0:
				continue
			var length := 10 + _h(sx * 3) % 26 - absi(sx - cx) / 4
			var c := strand if (sx / 2) % 3 == 0 else (leaf if (sx / 2) % 3 == 1 else leaf_dark)
			_r(img, sx, eave + 1, 1, maxi(3, length), c)
	# Flood debris: a snapped branch in the first tree's fork, driftwood at the second's root, a reed tangle.
	for i in 22:
		_p(img, 58 + i, 52 + i / 4, drift)
		_p(img, 58 + i, 51 + i / 4, drift_lit)
	_r(img, 236, h - 9, 44, 4, drift)
	_r(img, 236, h - 9, 44, 1, drift_lit)
	_r(img, 279, h - 8, 3, 2, INK)
	for i in 9:
		_r(img, 160 + i * 2, h - 12 + (i % 3), 1, 10 - (i % 3), reed)


## The trail from the side: a back verge, a band of mud with ruts and puddles, a grassy slope to the bottom.
static func _path(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var verge := Color("#4b6634")
	var grass := Color("#5d7a3f")
	var tuft := Color("#6a8848")
	var mud := Color("#7a6448")
	var mud_lit := Color("#8a7354")
	var rut := Color("#6a563e")
	var shine := Color("#c4d0cc")
	_r(img, 0, 0, w, 2, verge)
	_r(img, 0, 2, w, 2, grass)
	for x in range(0, w, 2):
		if _h(x + 7) % 3 == 0:
			_p(img, x, 0, tuft)
	_r(img, 0, 4, w, 18, mud)
	for k in 7:
		var x := _h(k + 3) % (w - 20)
		_r(img, x, 5 + _h(k + 30) % 12, 10 + _h(k + 60) % 10, 2, mud_lit)
	for x in w:
		if (x / 4) % 4 != 3:
			_p(img, x, 8, rut)
		if (x / 6) % 4 != 2:
			_p(img, x, 15, rut)
	for pd in [[40, 10, 12], [130, 16, 16]]:
		_r(img, pd[0] + 1, pd[1], pd[2] - 2, 1, shine)
		_r(img, pd[0], pd[1] + 1, pd[2], 2, SHEEN)
	_r(img, 0, 22, w, 2, MUD)
	_r(img, 0, 24, w, 17, Color("#557238"))
	_r(img, 0, 41, w, 20, Color("#48632f"))
	_r(img, 0, 61, w, h - 61, Color("#3e5629"))
	for y in [40, 60]:
		for x in w:
			if (x + y) % 2 == 0:
				_p(img, x, y + 1, Color("#557238") if y == 40 else Color("#48632f"))
	for k in 18:
		var x := _h(k + 90) % w
		var y := 26 + _h(k + 120) % 12
		_p(img, x, y, tuft)
		_p(img, x + 1, y - 1, tuft)


## Near ferns and reeds, the darkest layer, in front of the party.
static func _ferns(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var base := Color("#2d3b29")
	var frond := Color("#3b4f33")
	var tip := Color("#4c663d")
	var stalk := Color("#6f7b48")
	var seed := Color("#8b8455")
	for x in w:
		var top: int = h - 12 - [0, 1, 1, 2, 1, 0][x % 6]
		_r(img, x, top, 1, h - top, base)
	for cx: int in [34, 92, 151, 210, 266, 322]:
		for side: int in [-1, 1]:
			for j in 3:
				var length := 18 + j * 6 - (cx % 3) * 2
				for t in length:
					var x := cx + side * int(t * (0.35 + 0.25 * j))
					var y := 46 - int(t * (1.0 - 0.28 * j)) + int(t * t / (length * 2.4))
					_p(img, x, y, tip if t > length - 4 else frond)
					if t % 2 == 0:
						_p(img, x + side, y + 1, frond)
	for x: int in [40, 44, 47, 100, 104, 160, 222, 226, 280, 330, 334, 371]:
		var top := 8 + (x * 7) % 12
		_r(img, x, top, 1, 46 - top, stalk)
		_r(img, x, top - 3, 1, 3, seed)


static func _ferry_sign(img: Image) -> void:
	var plank := WOOD_LIT
	var plank_lit := Color("#cdb68f")
	var plank_shade := Color("#9a8460")
	var stain := Color("#8f7a58")
	# The post, leaning a little after the flood.
	for y in range(20, 46):
		var x := 18 + (46 - y) / 12
		_p(img, x - 1, y, INK)
		_r(img, x, y, 3, 1, WOOD)
		_p(img, x, y, WOOD_LIT)
		_p(img, x + 2, y, WOOD_SHADE)
		_p(img, x + 3, y, INK)
	# The plank, a corner broken off, the flood line across its lower half, a boat painted on it.
	_r(img, 5, 8, 30, 14, INK)
	_r(img, 6, 9, 28, 12, plank)
	_r(img, 6, 9, 28, 1, plank_lit)
	_r(img, 6, 20, 28, 1, plank_shade)
	_r(img, 6, 17, 28, 3, stain)
	for x in range(6, 34, 3):
		_p(img, x, 16, stain)
	_r(img, 30, 8, 5, 4, Color(0, 0, 0, 0))
	_p(img, 30, 9, INK)
	_p(img, 31, 10, INK)
	_p(img, 32, 11, INK)
	_r(img, 33, 12, 2, 1, INK)
	_r(img, 13, 15, 14, 1, INK)
	_r(img, 14, 16, 12, 1, INK)
	_p(img, 12, 14, INK)
	_p(img, 27, 14, INK)
	_r(img, 19, 10, 1, 5, INK)
	_r(img, 20, 10, 3, 2, INK)
	# Mud at the foot.
	_r(img, 12, 45, 17, 3, MUD)
	_r(img, 13, 44, 15, 1, MUD_LIT)


static func _waymark(img: Image) -> void:
	# The squared post and its brass cap.
	_r(img, 9, 12, 6, 42, INK)
	_r(img, 10, 12, 4, 42, WOOD)
	_r(img, 10, 12, 1, 42, WOOD_LIT)
	_r(img, 13, 12, 1, 42, WOOD_SHADE)
	_r(img, 8, 8, 8, 4, INK)
	_r(img, 9, 9, 6, 2, BRASS)
	_r(img, 9, 9, 6, 1, BRASS_LIT)
	_r(img, 11, 6, 2, 2, BRASS)
	# The arm and its unlit trail lantern.
	_r(img, 14, 14, 7, 3, INK)
	_r(img, 14, 15, 6, 1, WOOD)
	_r(img, 19, 17, 1, 1, INK)
	_r(img, 17, 18, 5, 7, INK)
	_r(img, 18, 19, 3, 4, Color("#8a6a3a"))
	_p(img, 18, 19, Color("#a8854a"))
	# The carved arrow, up the trail, and the courier band.
	_r(img, 10, 28, 3, 1, INK)
	_p(img, 12, 27, INK)
	_p(img, 12, 29, INK)
	_r(img, 10, 34, 4, 3, SEAL)
	_r(img, 10, 34, 4, 1, SEAL_LIT)
	# The foot in the mud and grass.
	_r(img, 6, 53, 12, 3, MUD)
	_r(img, 7, 52, 10, 1, MUD_LIT)
	for x in [6, 8, 15, 17]:
		_p(img, x, 52, Color("#4b6634"))


static func _parcel(img: Image) -> void:
	var wrap := Color("#a88a5c")
	var wrap_lit := Color("#c2a374")
	var wrap_shade := Color("#8a6f48")
	var twine := Color("#3b2f22")
	# The box, tipped onto a corner.
	for y in range(3, 15):
		var shift := (15 - y) / 4
		var x0 := 7 + shift
		_p(img, x0 - 1, y, INK)
		_r(img, x0, y, 18, 1, wrap if y > 5 else wrap_lit)
		_r(img, x0 + 15, y, 3, 1, wrap_shade)
		_p(img, x0 + 18, y, INK)
	_r(img, 9, 2, 19, 1, INK)
	# The twine, dark with river water.
	for y in range(3, 15):
		_p(img, 16 + (15 - y) / 4, y, twine)
	_r(img, 7, 8, 19, 1, twine)
	# Mud over its lower third, with a wet sheen.
	_r(img, 2, 13, 28, 7, MUD)
	_r(img, 3, 12, 26, 1, MUD_LIT)
	_r(img, 4, 14, 6, 1, SHEEN)
	_r(img, 22, 15, 5, 1, SHEEN)


## The rise at first light: the willows open on both sides, Highbank on its bluff below, the Tower over all of it.
## The lamps, chimneys and beacon sit at the row's anchors, which the scene's effects read too.
static func _vista_art(img: Image, spec: Dictionary) -> void:
	var anchors: Dictionary = spec.get("anchors", {})
	sky(img, SKY_RISE, SKY_RISE_AT)
	_cloud(img, 40, 44, 90, Color("#93a3b2"), Color("#ead0a6"))
	_cloud(img, 250, 70, 80, Color("#a6b0b6"), Color("#f0d6a8"))
	# Far hills behind the town, then the bluff it stands on.
	_hill_band(img, 118, 5, Color("#a3b0ae"), Color("#b8c2bc"), 0.7)
	_hill_band(img, 130, 4, Color("#7f9467"), Color("#93a77a"), 1.3)
	var plateau := Color("#6f8455")
	for x in range(130, 384):
		var top := 136 if x >= 190 else 136 + (190 - x) * 2 / 5
		_r(img, x, top, 1, 216 - top, plateau)
	# Houses behind the Tower, the Tower, then the houses in front of it.
	var houses := [[160, 160, 20, 11], [186, 150, 22, 12], [214, 146, 18, 10], [232, 160, 22, 12], [292, 148, 22, 12],
		[316, 160, 18, 10], [338, 150, 24, 12], [196, 172, 22, 11], [322, 178, 24, 11], [258, 182, 22, 10]]
	for hs in houses:
		if int(hs[1]) < 176:
			_house(img, hs)
	_tower(img, Vector2i(anchors.get("beacon", Vector2i(268, 13))), 176)
	for hs in houses:
		if int(hs[1]) >= 176:
			_house(img, hs)
	for key: String in anchors:
		var at: Vector2i = anchors[key]
		if key.begins_with("chimney_"):
			_r(img, at.x - 1, at.y, 3, 7, Color("#6b5d4e"))
			_r(img, at.x - 2, at.y, 5, 1, INK)
		elif key.begins_with("lamp_"):
			_r(img, at.x, at.y + 2, 1, 6, Color("#3b3629"))
			_r(img, at.x - 1, at.y - 1, 2, 2, Color("#4a4434"))
	# The near ridge where the two stand, sloping down toward the town.
	for x in range(0, 214):
		var top := 149 if x <= 120 else 149 + (x - 120) * 7 / 10
		_r(img, x, top, 1, 216 - top, Color("#3e5629"))
		_p(img, x, top, Color("#6a8848"))
		_p(img, x, top + 1, Color("#4b6634"))
	# Willows framing the view, dark against the dawn.
	_dark_tree(img, 18, 30, 34, 30, 12)
	_dark_tree(img, 392, 40, 40, 46, 374)


static func _hill_band(img: Image, base: int, amp: int, body: Color, lit: Color, f: float) -> void:
	for x in img.get_width():
		var top := base + int(amp * sin(x * 0.021 * f + 1.3) + amp * 0.5 * sin(x * 0.067 * f))
		_r(img, x, top, 1, img.get_height() - top, body)
		_p(img, x, top, lit)


static func _house(img: Image, hs: Array) -> void:
	var x: int = hs[0]
	var base: int = hs[1]
	var w: int = hs[2]
	var wall_h: int = hs[3]
	var top := base - wall_h
	_r(img, x, top, w, wall_h, Color("#c9b38e"))
	_r(img, x, top, 1, wall_h, Color("#dcc9a2"))
	_r(img, x + w - 1, top, 1, wall_h, Color("#a8926f"))
	var rise := w / 2 - 1
	for j in rise:
		_r(img, x - 1 + j, top - 1 - j, w + 2 - j * 2, 1, Color("#8e6a50"))
		_p(img, x - 1 + j, top - 1 - j, Color("#a57e5f"))
		_p(img, x + w - j, top - 1 - j, Color("#6f513c"))
	_r(img, x - 1, top, w + 2, 1, Color("#6f513c"))
	for k in range(3, w - 3, 6):
		_r(img, x + k, top + 3, 2, 3, Color("#e2bd72") if (x + k) % 4 != 0 else Color("#6f513c"))


## The Wayline Tower from the rise: river stone, lit on its left, slits up its face, a ledge, a lantern room, the mast.
static func _tower(img: Image, beacon: Vector2i, base: int) -> void:
	var cx := beacon.x
	var stone := Color("#8f805e")
	var lit := Color("#bea986")
	var shade := Color("#6f6349")
	var slit := Color("#3b3629")
	for y in range(30, base):
		var half := 8 + (y - 30) * 4 / (base - 30)
		_r(img, cx - half, y, half * 2 + 1, 1, stone)
		_r(img, cx - half, y, 2, 1, lit)
		_r(img, cx + half - 1, y, 2, 1, shade)
	for y in range(44, base - 10, 18):
		_r(img, cx - 1, y, 2, 5, slit)
	_r(img, cx - 12, 27, 25, 3, shade)
	_r(img, cx - 12, 27, 25, 1, lit)
	_r(img, cx - 7, 19, 15, 8, stone)
	_r(img, cx - 7, 19, 2, 8, lit)
	_r(img, cx - 3, 21, 7, 4, slit)
	_r(img, cx - 9, 17, 19, 2, Color("#5f6e7c"))
	_r(img, cx, beacon.y + 3, 1, 17 - beacon.y - 3, INK)
	_r(img, cx - 2, beacon.y - 2, 5, 5, INK)
	_r(img, cx - 1, beacon.y - 1, 3, 3, LAMP_LIT)


## A dark willow framing the view: crown, strands and trunk to the bottom.
static func _dark_tree(img: Image, cx: int, cy: int, rx: int, ry: int, trunk_x: int) -> void:
	var body := Color("#2f3d2a")
	var mid := Color("#3b4f33")
	var lit := Color("#4c663d")
	_r(img, trunk_x - 4, cy, 9, 216 - cy, body)
	for y in range(maxi(0, cy - ry), cy + ry + 1):
		var dy := float(y - cy) / float(ry)
		var half := int(rx * sqrt(maxf(0.0, 1.0 - dy * dy)))
		_r(img, cx - half, y, half * 2 + 1, 1, mid if dy < 0.2 else body)
		_p(img, cx - half, y, lit)
	for sx in range(cx - rx + 2, cx + rx - 1, 3):
		var dx := float(sx - cx) / float(rx)
		var bottom := cy + int(ry * sqrt(maxf(0.0, 1.0 - dx * dx)))
		_r(img, sx, bottom, 1, 10 + _h(sx) % 26, body if (sx / 3) % 2 == 0 else mid)
