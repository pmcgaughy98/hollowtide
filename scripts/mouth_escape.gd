extends Node2D
## Out of the Hollow Mouth, then the walk to Highbank (Claude, 2026-10-11; Preston: "a scene for when they
## escape and then for when they are on their way ... your partner explaining a bit about this world but more
## importantly the courier aspect and the fact he is trying to get into the wayline guild but needs partner").
## The riverbank at dawn: the storm is over and the ruin stands risen. The two of you come off the stone
## walkway and walk down to the south trail while the partner talks (dialogue/road_to_highbank.dialogue), then
## Highbank. Plays once, the first time the Mouth is cleared (dungeon.gd `_go_to_town`).
## Claude, 2026-10-23 (factory pass 3, story lane): the morning now looks like the line says (a dawn grade, the
## painting's rain taken out, low mist on the river), the two stay above the text box, and Esc, P or Start ask
## "Back to the title?" as the flood talk and the riverbank do.
const Bank := preload("res://scripts/ui/waking_bank.gd")
const Finish := preload("res://scripts/arena/creature_finish.gd")
const Lines := preload("res://scripts/creatures/lines.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const Music := preload("res://scripts/audio/music.gd")
const TALK := preload("res://dialogue/road_to_highbank.dialogue")
const TOWN_SCENE := "res://scenes/hub_town.tscn"
const BOX := Rect2(196, 452, 760, 116)   # the same text box as the flood talk and the rooms
const ASK := Rect2(396, 236, 360, 176)   # the "Back to the title?" prompt, mid-screen, as on the flood talk
const TITLE := "res://scenes/creature_opening.tscn"   # where Return goes, as from the flood talk and the riverbank
# Where the leader walks on each "do walk_on()": off the walkway's foot and down toward the south trail
# (riverbank_journey.gd: the walkway meets the bank near (240, 82), the trail to Highbank is at (130, 187)).
# Claude, 2026-10-23 (S4): every stop keeps both feet above the text box's top edge (row 150 of the painting,
# 452 on screen) and the partner left of the answer list; the last stretch onto the trail is walked under the
# closing fade, when the box is gone.
const PATH := [Vector2(238, 96), Vector2(212, 114), Vector2(184, 128), Vector2(160, 138), Vector2(136, 146)]
const TRAIL_END := Vector2(134, 186)
const WALK_FPS := 8.0
const DRY_TOP := 60   # the rain streaks are on the clay below the river; the river and the ruin stay as painted
# The dawn grade (Claude, 2026-10-23, S3): the night painting's blacks lifted to a morning grey, a little less colour,
# and a warm light along the far bank, per painting row. It replaces a flat warm tint that only darkened the night.
const DAWN_SHADER := """shader_type canvas_item;
uniform vec3 lift = vec3(0.10, 0.10, 0.11);
uniform vec3 tint = vec3(1.0, 0.95, 0.88);
uniform vec3 glow = vec3(1.0, 0.70, 0.42);
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	vec3 g = lift + c.rgb * (vec3(1.0) - lift);
	float y = dot(g, vec3(0.299, 0.587, 0.114));
	g = mix(vec3(y), g, 0.8) * tint;
	float row = floor(UV.y * 216.0) / 216.0;
	g += glow * 0.14 * (1.0 - smoothstep(0.0, 0.32, row));
	COLOR = vec4(min(g, vec3(1.0)), c.a);
}
"""

var reduce_motion := false
var line: DialogueLine
var choice := 0
var leaving := false
var actors: Array[Sprite2D] = []
var forms: Array[String] = []
var _names: Array[String] = []
var _stop := 0
var _walking := 0.0
var _facing := "s"
var _box: Node2D
var _veil: ColorRect
var _clock := 0.0
var _mist: Sprite2D
var asking := false   # the "Back to the title?" prompt is up (Claude, 2026-10-23, S5)
var ask_row := 0

# Read by the dialogue file ({{...}}).
var partner_name: String:
	get: return _names[1] if _names.size() > 1 else "Your partner"


func _ready() -> void:
	get_tree().root.content_scale_size = Vector2i(1152, 648)
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	var vp := SubViewport.new()
	vp.size = Vector2i(384, 216)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)
	var display := Sprite2D.new()
	display.texture = vp.get_texture()
	display.centered = false
	display.scale = Vector2.ONE * 3
	display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var grade := ShaderMaterial.new()
	grade.shader = Shader.new()
	grade.shader.code = DAWN_SHADER
	display.material = grade
	add_child(display)
	var bank := Bank.new()   # drawn without the river cover: the ruin has risen
	bank.reduce_motion = reduce_motion
	bank.show_actor_shadows = false
	vp.add_child(bank)
	if bank.background != null and bank.background.texture != null:
		bank.background.texture = ImageTexture.create_from_image(dry_image(bank.background.texture.get_image()))
	_mist = Sprite2D.new()
	_mist.centered = false
	_mist.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_mist.texture = ImageTexture.create_from_image(mist_image(bank))
	vp.add_child(_mist)
	var party: Array = TeamState.data.get("party", [[0, 0], [1, 0]])
	for i in mini(party.size(), 2):
		var form: String = Lines.of(party[i][0]).forms[party[i][1]][0]
		forms.append(form)
		_names.append(load(Lines.of(party[i][0]).forms[party[i][1]][1]).creature_name)
		var s := Sprite2D.new()
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.position = PATH[0] + (Vector2(22, 6) if i == 1 else Vector2.ZERO)
		Finish.apply(s, false, form)
		vp.add_child(s)
		actors.append(s)
	_pose()
	var ui := CanvasLayer.new()
	add_child(ui)
	_box = Node2D.new()
	_box.draw.connect(_draw_talk)
	ui.add_child(_box)
	_veil = ColorRect.new()
	_veil.size = Vector2(1152, 648)
	_veil.color = Color.BLACK
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(_veil)
	Music.play(get_tree(), "")   # morning quiet after the storm; the town's music starts in Highbank
	await create_tween().tween_property(_veil, "color:a", 0.0, 0.3 if reduce_motion else 1.2).finished
	line = await DialogueManager.get_next_dialogue_line(TALK, "start", [self])


## Called from the dialogue: walk the two of you one stretch further down the bank.
func walk_on() -> void:
	if _stop >= PATH.size() - 1:
		return
	_stop += 1
	_walk_to(PATH[_stop])


## Both of you to `to`, the partner a step behind and to the side; `secs` when the walk must fit a fade.
func _walk_to(to: Vector2, secs := -1.0) -> void:
	var d: Vector2 = to - actors[0].position
	_facing = _dir(d)
	var time := secs if secs > 0.0 else d.length() / (60.0 if reduce_motion else 34.0)
	_walking = time
	for i in actors.size():
		var off := Vector2(22, -8) if i == 1 else Vector2.ZERO   # wide enough that the two do not overlap (2026-10-23)
		create_tween().tween_property(actors[i], "position", to + off, time).set_delay(0.12 * i)


func _dir(d: Vector2) -> String:
	var a := fposmod(rad_to_deg(d.angle()) + 22.5, 360.0)
	return ["e", "se", "s", "sw", "w", "nw", "n", "ne"][int(a / 45.0)]


## Each actor's picture: a walk frame while walking, the standing one facing the way it last went.
func _pose() -> void:
	for i in actors.size():
		var dir := "res://assets/sprites/arena/%s/small/" % forms[i]
		if not ResourceLoader.exists(dir + "s.png"):
			dir = "res://assets/sprites/arena/%s/dungeon/" % forms[i]   # the Hollow wilds have no small set
		var path := dir + "%s.png" % _facing
		if _walking > 0.0:
			var walk := dir + "walk_%s_f%d.png" % [_facing, int(_clock * WALK_FPS) % 8]
			if ResourceLoader.exists(walk):
				path = walk
		if not ResourceLoader.exists(path):
			path = dir + "s.png"
		actors[i].texture = load(path)
		var used := actors[i].texture.get_image().get_used_rect()
		actors[i].offset.y = actors[i].texture.get_height() * 0.5 - used.end.y
		actors[i].z_index = int(actors[i].position.y)


func _process(delta: float) -> void:
	_clock += delta
	_walking = maxf(0.0, _walking - delta)
	_pose()
	if _mist != null and not reduce_motion:
		_mist.modulate.a = 0.85 + 0.15 * sin(_clock * 0.6)   # the mist breathes, slowly
	if not leaving and line != null:
		_poll()
	_box.queue_redraw()


## Actions, not keys (Claude, 2026-10-23, factory pass 2): the next line is E, J, Enter or Space as before, or A or
## X on a pad; up and down (W, S, the arrows, the D-pad, the stick) move the choice. Esc, P, B or Start ask about
## the title (factory pass 3, S5).
func _poll() -> void:
	if asking:
		_poll_ask()
	elif UI.tapped_any(UI.INPUT_ADVANCE):
		advance()
	elif UI.tapped_any(["cancel", "pause"]):
		_ask()
	elif not line.responses.is_empty() and UI.line_done(line.text):
		var d := int(UI.tapped("move_down")) - int(UI.tapped("move_up"))
		if d != 0:
			choice = posmod(choice + d, line.responses.size())


## E: show the rest of the line, then the next line (or the chosen answer's branch).
func advance() -> void:
	if leaving or line == null:
		return
	if not UI.line_done(line.text):
		UI.finish_line()
		return
	var next := line.next_id
	if not line.responses.is_empty():
		next = line.responses[choice].next_id
	choice = 0
	line = await DialogueManager.get_next_dialogue_line(TALK, next, [self])
	if line == null:
		_leave()


## The "Back to the title?" prompt (Claude, 2026-10-23, S5), the pattern of the flood talk (creature_prologue.gd)
## and the riverbank: Resume or Return. The dawn walk saves nothing of its own; the Mouth's clear is already kept.
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


## Return: the scene's own black, then the title (the flood talk fades the same way).
func _title() -> void:
	leaving = true
	UI.tick("confirm")
	_veil.mouse_filter = Control.MOUSE_FILTER_STOP
	await create_tween().tween_property(_veil, "color:a", 1.0, 0.15 if reduce_motion else 0.5).finished
	var error := get_tree().change_scene_to_file(TITLE)
	if error != OK:
		leaving = false
		asking = false
		_veil.color.a = 0.0
		_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw_talk() -> void:
	if line == null or leaving:
		return
	var face: String = line.tags[0] if not line.tags.is_empty() else "normal"
	var tex: Texture2D = null
	if line.character != "" and forms.size() > 1:
		tex = UI.dialogue_portrait(forms[1] + (":" + face if face != "normal" else ""))
	UI.dialogue(_box, BOX, line.character, line.text, tex, _clock, 20, face)
	if not line.responses.is_empty() and UI.line_done(line.text):
		_draw_choices()
	if asking:
		UI.panel(_box, ASK, 0.95, true)
		UI.say(_box, ASK.position + Vector2(36, 48), "Back to the title?", "body", UI.TEXT)
		for k in 2:
			var at := ASK.position + Vector2(80, 96 + k * 36)
			if k == ask_row:
				UI.say(_box, at - Vector2(28, 0), ">", "button", UI.EDGE_LIGHT)
			UI.say(_box, at, ["Resume", "Return"][k], "button", UI.EDGE_LIGHT if k == ask_row else UI.MUTED)


func _draw_choices() -> void:
	var rows := line.responses.size()
	var r := Rect2(BOX.end.x - 300, BOX.position.y - 34 - rows * 34, 300, 24 + rows * 34)
	UI.panel(_box, r, 0.95)
	for k in rows:
		var at := r.position + Vector2(44, 34 + k * 34)
		if k == choice:
			UI.say(_box, at - Vector2(26, 0), ">", "label", UI.EDGE_LIGHT)
		UI.say(_box, at, String(line.responses[k].text), "label", UI.EDGE_LIGHT if k == choice else UI.MUTED)


func _leave() -> void:
	leaving = true
	var secs := 0.2 if reduce_motion else 0.8
	_walk_to(TRAIL_END, secs)   # onto the south trail as the black comes down (S4)
	await create_tween().tween_property(_veil, "color:a", 1.0, secs).finished
	var town: Node = load(TOWN_SCENE).instantiate()
	TeamState.give_to(town)
	get_tree().change_scene_to_node(town)


## The bank painting with its rain taken out (Claude, 2026-10-23, S3). The streaks are pale tan pixels brighter than
## the brown clay on both sides; they, then the paler fringe beside them, take the clay next to them. Only the clay
## below the river is touched, and the source PNG stays as it is.
static func dry_image(src: Image) -> Image:
	var img := src.duplicate() as Image
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	var d := img.get_data()
	var out := d.duplicate()
	var mask := PackedByteArray()
	mask.resize(w * h)
	for y in range(DRY_TOP, h):
		for x in range(2, w - 2):
			var i := (y * w + x) * 4
			if not _streak(d, i):
				continue
			var lg := -1
			var rg := -1
			for k in range(1, 4):
				if lg < 0 and x - k >= 0 and _clay(d, i - 4 * k):
					lg = i - 4 * k
				if rg < 0 and x + k < w and _clay(d, i + 4 * k):
					rg = i + 4 * k
			if lg >= 0 and rg >= 0 and _lum(d, i) >= maxf(_lum(d, lg), _lum(d, rg)) + 28.0:
				mask[y * w + x] = 1
	var fringe: Array[int] = []
	for y in range(DRY_TOP, h - 1):
		for x in range(3, w - 3):
			var m := y * w + x
			if mask[m] == 1 or (mask[m - w - 1] | mask[m - w] | mask[m - w + 1] | mask[m - 1] | mask[m + 1] | mask[m + w - 1] | mask[m + w] | mask[m + w + 1]) == 0:
				continue
			var i := m * 4
			var r := d[i]
			var g := d[i + 1]
			var b := d[i + 2]
			if not (r >= g and g >= b and r >= 0x88 and r - b >= 0x18):
				continue
			var sum := 0.0
			var n := 0
			for k in [-3, -2, 2, 3]:
				var q: int = i + 4 * k
				if _clay(d, q) and not _streak(d, q):
					sum += _lum(d, q)
					n += 1
			if n > 0 and _lum(d, i) >= sum / n + 12.0:
				fringe.append(m)
	for m in fringe:
		mask[m] = 1
	for y in range(DRY_TOP, h):
		for x in w:
			var m := y * w + x
			if mask[m] == 0:
				continue
			var i := m * 4
			var a := -1
			var c := -1
			for k in range(1, 5):
				if a < 0 and x - k >= 0 and mask[m - k] == 0 and _clay(d, i - 4 * k):
					a = i - 4 * k
				if c < 0 and x + k < w and mask[m + k] == 0 and _clay(d, i + 4 * k):
					c = i + 4 * k
			if a < 0 and c < 0:
				continue
			for ch in 3:
				out[i + ch] = (d[a + ch] + d[c + ch]) >> 1 if a >= 0 and c >= 0 else d[(a if a >= 0 else c) + ch]
	return Image.create_from_data(w, h, false, Image.FORMAT_RGBA8, out)


static func _lum(d: PackedByteArray, i: int) -> float:
	return 0.299 * d[i] + 0.587 * d[i + 1] + 0.114 * d[i + 2]


## The bank's brown clay.
static func _clay(d: PackedByteArray, i: int) -> bool:
	var r := d[i]
	var g := d[i + 1]
	var b := d[i + 2]
	return r > g and g > b and r >= 0x40 and r <= 0xa0 and r - b >= 0x18


## A rain streak's pale tan.
static func _streak(d: PackedByteArray, i: int) -> bool:
	var r := d[i]
	var g := d[i + 1]
	var b := d[i + 2]
	return r >= g and g >= b and r >= 0x98 and r - b >= 0x20 and r - b <= 0x70 and g - b >= 0x10


## Low mist on the river (Claude, 2026-10-23, S3): pale and thin, only on the painting's water, thickest against
## both banks, in three steps of see-through so it stays pixel art.
static func mist_image(bank: Bank) -> Image:
	var img := Image.create(384, 216, false, Image.FORMAT_RGBA8)
	var painted := bank.artwork != null
	for x in 384:
		var lo := 6 if painted else Bank.far_bank(x) + 2
		var hi := 72 if painted else Bank.near_bank(x) - 1
		var top := -1
		var bottom := -1
		for y in range(lo, hi):
			if bank.water_at(x, y):
				if top < 0:
					top = y
				bottom = y
		if top < 0:
			continue
		for y in range(top, bottom + 1):
			if not bank.water_at(x, y):
				continue
			var near := 1.0 - clampf(float(mini(y - top, bottom - y)) / 12.0, 0.0, 1.0)
			var drift := 0.5 + 0.5 * sin(x * 0.07 + y * 0.9) * sin(x * 0.019 + 2.1)
			var v := near * (0.55 + 0.45 * drift)
			var a := 0.38 if v > 0.7 else (0.24 if v > 0.45 else (0.12 if v > 0.25 else 0.0))
			if a > 0.0:
				img.set_pixel(x, y, Color(0.86, 0.89, 0.9, a))
	return img
