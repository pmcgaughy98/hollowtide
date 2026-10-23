extends Node2D
## Out of the Hollow Mouth, then the walk to Highbank (Claude, 2026-10-11; Preston: "a scene for when they
## escape and then for when they are on their way ... your partner explaining a bit about this world but more
## importantly the courier aspect and the fact he is trying to get into the wayline guild but needs partner").
## The riverbank at dawn: the storm is over and the ruin stands risen. The two of you come off the stone
## walkway and walk down to the south trail while the partner talks (dialogue/road_to_highbank.dialogue), then
## Highbank. Plays once, the first time the Mouth is cleared (dungeon.gd `_go_to_town`).
const Bank := preload("res://scripts/ui/waking_bank.gd")
const Finish := preload("res://scripts/arena/creature_finish.gd")
const Lines := preload("res://scripts/creatures/lines.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const Music := preload("res://scripts/audio/music.gd")
const TALK := preload("res://dialogue/road_to_highbank.dialogue")
const TOWN_SCENE := "res://scenes/hub_town.tscn"
const BOX := Rect2(196, 452, 760, 116)   # the same text box as the flood talk and the rooms
const DAWN := Color(1.0, 0.9, 0.8)       # a warm first light over the bank painting
# Where the leader walks on each "do walk_on()": off the walkway's foot and down to the south trail
# (riverbank_journey.gd: the walkway meets the bank near (240, 82), the trail to Highbank is at (130, 187)).
const PATH := [Vector2(238, 96), Vector2(214, 122), Vector2(188, 146), Vector2(160, 166), Vector2(134, 186)]
const WALK_FPS := 8.0

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
	display.modulate = DAWN
	add_child(display)
	var bank := Bank.new()   # drawn without the river cover: the ruin has risen
	bank.reduce_motion = reduce_motion
	bank.show_actor_shadows = false
	vp.add_child(bank)
	var party: Array = TeamState.data.get("party", [[0, 0], [1, 0]])
	for i in mini(party.size(), 2):
		var form: String = Lines.of(party[i][0]).forms[party[i][1]][0]
		forms.append(form)
		_names.append(load(Lines.of(party[i][0]).forms[party[i][1]][1]).creature_name)
		var s := Sprite2D.new()
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.position = PATH[0] + (Vector2(18, 6) if i == 1 else Vector2.ZERO)
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
	var to: Vector2 = PATH[_stop]
	var d: Vector2 = to - actors[0].position
	_facing = _dir(d)
	var time := d.length() / (60.0 if reduce_motion else 34.0)
	_walking = time
	for i in actors.size():
		var off := Vector2(18, -8) if i == 1 else Vector2.ZERO   # the partner a step behind and to the side
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
	if not leaving and line != null:
		_poll()
	_box.queue_redraw()


## Actions, not keys (Claude, 2026-10-23, factory pass 2): the next line is E, J, Enter or Space as before, or A or
## X on a pad; up and down (W, S, the arrows, the D-pad, the stick) move the choice.
func _poll() -> void:
	if UI.tapped_any(UI.INPUT_ADVANCE):
		advance()
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


func _draw_talk() -> void:
	if line == null or leaving:
		return
	var face: String = line.tags[0] if not line.tags.is_empty() else "normal"
	var tex: Texture2D = null
	if line.character != "" and forms.size() > 1:
		tex = UI.dialogue_portrait(forms[1] + (":" + face if face != "normal" else ""))
	UI.dialogue(_box, BOX, line.character, line.text, tex, _clock, 20, face)
	if line.responses.is_empty() or not UI.line_done(line.text):
		return
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
	await create_tween().tween_property(_veil, "color:a", 1.0, 0.2 if reduce_motion else 0.8).finished
	var town: Node = load(TOWN_SCENE).instantiate()
	TeamState.give_to(town)
	get_tree().change_scene_to_node(town)
