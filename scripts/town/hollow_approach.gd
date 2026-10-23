extends Node2D
## The way to The Hollow (Claude, 2026-10-10; Preston: the risen structure's perspective "wouldn't look right
## entering it from that scene", so an entrance node sits at the start of the stone walkway on the
## riverbank, then a separate scene takes you up to the entrance).
##
## Two stops, both on a 384x216 canvas at 3x like the waking scene (creature_prologue.gd):
##   1. The riverbank: Codex's waking_bank.gd painting. The team walks in from the left to a glowing node
##      where the walkway leaves the bank. Confirm crosses; Back returns to Highbank.
##   2. The entrance: Codex's entrance painting, assets/backgrounds/hollow_entrance.png (a plain stand-in
##      is drawn until that file is in the project). The team walks up the walkway to the door, its light
##      swells, and the run into The Hollow starts.
## The town sends the team here when The Hollow is the next dungeon (hub_town.gd enter_hollow).
##
## Two modes since Preston's opening (2026-10-10: wake in the flood, retreat into the Hollow, a first dungeon
## with no boss, then the theft in town):
##   "flood"    from the waking scene: the team runs from where it woke to the walkway, straight up to the
##              door, no turning back, into the Hollow Mouth (dungeon.gd "mouth", two floors, no boss).
##   "teleport" from town, Mystery Dungeon style: the team arrives in a column of light at the foot of the
##              walkway, Enter or Back to Highbank, then up to the door and into The Hollow.

const Finish := preload("res://scripts/arena/creature_finish.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const Lines := preload("res://scripts/creatures/lines.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const ENTRANCE := "res://assets/sprites/world/waking_bank_2026_10_10/entrance_native.png"
const EntranceFinish := preload("res://scripts/ui/hollow_entrance_finish.gd")
const NODE_AT := Vector2(244, 79)          # the bank end of the stone walkway in waking_bank.gd
const DOOR_AT := Vector2(192, 110)         # the doorway's foot in the entrance painting, at 384x216
const WALK_FPS := 10.0

var party: Array = [[0, 0], [1, 0]]
var auto := false                          # the check confirms by itself
var reduce_motion := false
var stop := "bank"                         # "bank", then "entrance"
var mode := "teleport"                     # "teleport" from town, "flood" from the waking scene
var beam := 0.0                            # the teleport's light, 1 at full and fading to 0
const WOKE_AT := [Vector2(168, 83), Vector2(222, 84)]   # where the waking scene left the two (creature_prologue.gd)
const LANE := [Vector2(0, 0), Vector2(-13, 9), Vector2(13, 10)]
const ARRIVE_Y := 192.0                    # where the teleport sets the team down on the walkway
var ready_to_cross := false
var busy := false
var t := 0.0
var team: Array = []                       # {form, sprite, facing, frames}
var vp: SubViewport
var bank: Node2D
var entrance: Sprite2D
var fx: Node2D
var veil: ColorRect
var prompt: PanelContainer
var prompt_text: Label
var door_glow := 0.0


class QuietBank extends "res://scripts/ui/waking_bank.gd":
	# The waking painting without its two fixed contact shadows; this scene draws shadows under the team.
	func draw_ellipse_shadow(_at: Vector2) -> void:
		pass


func _ready() -> void:
	if not TeamState.data.is_empty():
		party = TeamState.data.get("party", party)
	get_tree().root.content_scale_size = Vector2i(1152, 648)
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	vp = SubViewport.new()
	vp.size = Vector2i(384, 216)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)
	var display := Sprite2D.new()
	display.texture = vp.get_texture()
	display.centered = false
	display.scale = Vector2.ONE * 3
	display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(display)
	bank = QuietBank.new()
	bank.reduce_motion = reduce_motion
	vp.add_child(bank)
	entrance = Sprite2D.new()
	entrance.centered = false
	entrance.hide()
	entrance.texture = _entrance_texture()
	entrance.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	entrance.scale = Vector2(384, 216) / entrance.texture.get_size()
	vp.add_child(entrance)
	fx = Node2D.new()                      # shadows under the team, the node, the door's light
	fx.draw.connect(_draw_fx)
	vp.add_child(fx)
	for k in mini(party.size(), 3):
		var form: String = Lines.of(int(party[k][0]))["forms"][int(party[k][1])][0]
		var s := Sprite2D.new()
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		Finish.apply(s)
		vp.add_child(s)
		team.append({"form": form, "sprite": s, "facing": "e", "frames": {}})
		_face(team[k], "e")
	var ui := CanvasLayer.new()
	add_child(ui)
	prompt = PanelContainer.new()
	prompt.position = Vector2(222, 510)
	prompt.custom_minimum_size = Vector2(708, 0)
	var style: StyleBox = UI.frame("panel_dim").duplicate()
	style.set_content_margin_all(20)
	prompt.add_theme_stylebox_override("panel", style)
	prompt_text = Label.new()
	prompt_text.add_theme_font_override("font", preload("res://assets/fonts/Silkscreen-Regular.ttf"))
	prompt_text.add_theme_font_size_override("font_size", 20)
	prompt_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_child(prompt_text)
	prompt.hide()
	ui.add_child(prompt)
	veil = ColorRect.new()
	veil.size = Vector2(1152, 648)
	veil.color = Color(0, 0, 0, 1)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(veil)
	if mode == "flood":
		_run_bank()
	else:
		_arrive()


func _entrance_texture() -> Texture2D:
	var img := preload("res://scripts/ui/waking_bank.gd").detailed_image(ENTRANCE)
	if img != null:
		EntranceFinish.apply(entrance, img)
		return ImageTexture.create_from_image(EntranceFinish.finished_image(img))
	return ImageTexture.create_from_image(_stand_in())


## Until the entrance painting is in the project: dark water, the walkway, a lit doorway.
static func _stand_in() -> Image:
	var img := Image.create(384, 216, false, Image.FORMAT_RGBA8)
	img.fill(Color("#173541"))
	img.fill_rect(Rect2i(0, 0, 384, 30), Color("#1d2b25"))
	img.fill_rect(Rect2i(110, 18, 164, 94), Color("#4d5a4c"))
	img.fill_rect(Rect2i(110, 18, 164, 3), Color("#7c8b74"))
	img.fill_rect(Rect2i(176, 62, 32, 48), Color("#0d1412"))
	img.fill_rect(Rect2i(186, 34, 12, 20), Color("#e8e59a"))
	img.fill_rect(Rect2i(132, 50, 8, 26), Color("#d9d98a"))
	img.fill_rect(Rect2i(244, 50, 8, 26), Color("#d9d98a"))
	img.fill_rect(Rect2i(104, 110, 176, 66), Color("#5b4632"))
	img.fill_rect(Rect2i(170, 110, 44, 106), Color("#77806a"))
	for y in range(116, 216, 14):
		img.fill_rect(Rect2i(170, y, 44, 1), Color("#4c5546"))
	return img


func _process(delta: float) -> void:
	t += delta
	for e in team:
		var s: Sprite2D = e["sprite"]
		if e.get("walking", false):
			var fr: Array = e["frames"].get(e["facing"], [])
			if not fr.is_empty():
				_set_tex(s, fr[int(t * WALK_FPS) % fr.size()])
	fx.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if busy or not ready_to_cross:
		return
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		confirm()
	elif event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_back_to_town()


# --- the riverbank ---------------------------------------------------------------------------------

## The flood: from where they woke, a run to the walkway's foot, and straight across. No choice here.
func _run_bank() -> void:
	busy = true
	var spots := [NODE_AT + Vector2(-20, 9), NODE_AT + Vector2(-40, 12), NODE_AT + Vector2(-58, 9)]
	for k in team.size():
		team[k]["sprite"].position = WOKE_AT[k] if k < WOKE_AT.size() else WOKE_AT[0] + Vector2(-24, 4)
	await _fade(0.0)
	for k in team.size():
		_walk(team[k], spots[k], 52.0)   # running, not walking
	await _all()
	_cross()


## A press while the prompt is up: across from the bank, or up from the walkway's foot.
func confirm() -> void:
	if stop == "bank":
		_cross()
	else:
		_climb()


func _cross() -> void:
	ready_to_cross = false
	busy = true
	prompt.hide()
	await _walk(team[0], NODE_AT + Vector2(0, -2), 30.0)
	await _fade(1.0)
	_run_entrance()


func _back_to_town() -> void:
	ready_to_cross = false
	busy = true
	prompt.hide()
	await _fade(1.0)
	TeamState.data["party"] = party.duplicate(true)
	var town: Node = load("res://scenes/hub_town.tscn").instantiate()
	TeamState.give_to(town)
	if is_inside_tree() and get_tree().current_scene == self:
		get_tree().change_scene_to_node(town)
	else:
		set_meta("left_to", "town")
		town.free()


# --- the entrance ----------------------------------------------------------------------------------

func _run_entrance() -> void:
	stop = "entrance"
	bank.hide()
	entrance.show()
	for k in team.size():
		team[k]["sprite"].position = Vector2(DOOR_AT.x, 238) + LANE[k]
		_face(team[k], "n")
	await _fade(0.0)
	_climb()


## The teleport from town: a column of light on the walkway, the team appears in it, then the choice.
func _arrive() -> void:
	busy = true
	stop = "entrance"
	bank.hide()
	entrance.show()
	for k in team.size():
		team[k]["sprite"].position = Vector2(DOOR_AT.x, ARRIVE_Y) + LANE[k]
		team[k]["sprite"].hide()
		_face(team[k], "n")
	await _fade(0.0)
	var tw := create_tween()
	tw.tween_property(self, "beam", 1.0, 0.15 if reduce_motion else 0.35)
	await tw.finished
	for e in team:
		e["sprite"].show()
	tw = create_tween()
	tw.tween_property(self, "beam", 0.0, 0.2 if reduce_motion else 0.6)
	await tw.finished
	prompt_text.text = "The Hollow.\nEnter?   [Enter]          Back to Highbank   [Esc]"
	prompt.show()
	busy = false
	ready_to_cross = true
	if auto:
		await get_tree().create_timer(0.4).timeout
		confirm()


## Up the walkway to the door, its light swells, and the run starts.
func _climb() -> void:
	ready_to_cross = false
	busy = true
	prompt.hide()
	for k in team.size():
		_walk(team[k], DOOR_AT + Vector2(0, 16) + LANE[k] * 0.6, 40.0 if mode == "flood" else 26.0, 0.82)
	await _all()
	for e in team:
		_face(e, "n")
	var tw := create_tween()
	tw.tween_property(self, "door_glow", 1.0, 0.25 if reduce_motion else 0.8)
	await tw.finished
	await _fade(1.0)
	_enter_dungeon()


func _enter_dungeon() -> void:
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	if TeamState.data.is_empty():
		TeamState.start(party)
	TeamState.data["party"] = party.duplicate(true)
	TeamState.give_to(dg)
	dg.dungeon = "mouth" if mode == "flood" else "hollow"
	dg.return_to_town = true
	if is_inside_tree() and get_tree().current_scene == self:
		get_tree().change_scene_to_node(dg)
	else:
		set_meta("entered", dg.dungeon)   # the check reads this instead of leaving the scene
		dg.free()


# --- moving and drawing ----------------------------------------------------------------------------

func _walk(e: Dictionary, to: Vector2, speed: float, end_scale := 1.0) -> void:
	var s: Sprite2D = e["sprite"]
	var d := to - s.position
	if d.length() < 1.0:
		return
	_face(e, _facing_of(d))
	e["walking"] = true
	var tw := create_tween().set_parallel()
	var secs := d.length() / speed * (0.4 if reduce_motion else 1.0)
	tw.tween_property(s, "position", to, secs)
	if end_scale != s.scale.x:
		tw.tween_property(s, "scale", Vector2.ONE * end_scale, secs)
	await tw.finished
	e["walking"] = false
	_face(e, e["facing"])


func _all() -> void:
	# The walks run side by side; wait until the last one stops.
	await get_tree().process_frame
	while team.any(func(e: Dictionary) -> bool: return e.get("walking", false)):
		await get_tree().process_frame


func _fade(to: float) -> void:
	var tw := create_tween()
	tw.tween_property(veil, "color:a", to, 0.15 if reduce_motion else 0.5)
	await tw.finished


static func _facing_of(d: Vector2) -> String:
	var names := ["e", "se", "s", "sw", "w", "nw", "n", "ne"]
	return names[posmod(int(round(d.angle() / (PI / 4.0))), 8)]


func _face(e: Dictionary, facing: String) -> void:
	e["facing"] = facing
	# The Hollow wilds (Skimlet, Ozbender, Valvekin) have no arena small set: walk them with their dungeon set.
	var dir := "res://assets/sprites/arena/%s/small/" % e["form"]
	if not ResourceLoader.exists(dir + "s.png"):
		dir = "res://assets/sprites/arena/%s/dungeon/" % e["form"]
	if not e["frames"].has(facing):
		var fr: Array = []
		var i := 0
		while ResourceLoader.exists(dir + "walk_%s_f%d.png" % [facing, i]):
			fr.append(load(dir + "walk_%s_f%d.png" % [facing, i]))
			i += 1
		e["frames"][facing] = fr
	var still := dir + "%s.png" % facing
	if ResourceLoader.exists(still):
		_set_tex(e["sprite"], load(still))


func _set_tex(s: Sprite2D, tex: Texture2D) -> void:
	s.texture = tex
	var used := tex.get_image().get_used_rect()
	s.offset.y = tex.get_height() * 0.5 - used.end.y   # feet on the position, as in the waking scene


func _draw_fx() -> void:
	for e in team:
		var p: Vector2 = e["sprite"].position
		var k: float = e["sprite"].scale.x
		fx.draw_rect(Rect2(p - Vector2(8, 1) * k, Vector2(16, 2) * k), Color(0.08, 0.10, 0.08, 0.45))
	if stop == "bank":
		# The node: a pale ring at the walkway's foot that breathes, brighter while you can cross.
		var a := 0.45 + 0.25 * sin(t * 3.0) + (0.2 if ready_to_cross else 0.0)
		fx.draw_arc(NODE_AT, 7.0, 0, TAU, 20, Color(0.93, 0.92, 0.70, a), 1.0)
		fx.draw_arc(NODE_AT, 4.0, 0, TAU, 14, Color(0.75, 0.85, 0.66, a * 0.7), 1.0)
		fx.draw_rect(Rect2(NODE_AT - Vector2(0.5, 0.5), Vector2(1, 1)), Color(1, 1, 0.9, a))
	if beam > 0.0:
		for k in team.size():
			var bp: Vector2 = Vector2(DOOR_AT.x, ARRIVE_Y) + LANE[k]
			fx.draw_rect(Rect2(bp.x - 6, 0, 12, bp.y), Color(0.93, 0.95, 0.78, beam * 0.45))
			fx.draw_rect(Rect2(bp.x - 2, 0, 4, bp.y), Color(1, 1, 0.92, beam * 0.8))
			fx.draw_arc(bp, 9.0 * (1.2 - beam * 0.4), 0, TAU, 20, Color(0.93, 0.92, 0.70, beam), 1.0)
	if stop != "bank" and door_glow > 0.0:
		fx.draw_rect(Rect2(DOOR_AT + Vector2(-17, -46), Vector2(34, 48)), Color(0.95, 0.93, 0.62, door_glow * 0.75))
		fx.draw_rect(Rect2(Vector2.ZERO, Vector2(384, 216)), Color(0.95, 0.93, 0.70, door_glow * 0.35))
