extends "res://scripts/opening_flow.gd"
## Creature-player launch from an original Retro Diffusion village painting.
## Village architecture is a visual proposal; the awakening and dungeon flow remain.
const Finish = preload("res://scripts/arena/creature_finish.gd")
const PROLOGUE = preload("res://scenes/creature_prologue.tscn")
const VILLAGE = preload("res://assets/sprites/menu/creature_village_2026_10_09.png")
var companions: Array[Sprite2D] = []

func _build_scenery() -> void:
	var town:=Sprite2D.new()
	town.name="CreatureVillage"
	town.texture=VILLAGE
	town.centered=false
	town.scale=Vector2(1152.0/256.0,648.0/144.0)
	town.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(town)
	# Keep the title legible against the willow canopy without shifting the town.
	var shade:=ColorRect.new()
	shade.name="CanopyShade"
	shade.size=Vector2(1152,150)
	shade.color=Color(0.07,0.10,0.10,0.38)
	shade.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	_star_layer=_dots(_draw_stars)
	_windows=Sprite2D.new() # The inherited ambient loop expects this handle.
	add_child(_windows)

func _seed_sparkle() -> void:pass
func _draw_motes(_layer:Node2D) -> void:pass

func _draw_stars(layer:Node2D) -> void:
	# A few fireflies on the banks; the inherited clock stops with Reduce Motion.
	var homes=[Vector2(405,490),Vector2(770,426),Vector2(865,525),Vector2(1020,550),Vector2(482,470),Vector2(735,505)]
	for i in homes.size():
		var glow:float=sin(_time*1.3+i*1.8)
		if glow<0.1:continue
		var p:Vector2=(homes[i]+Vector2(roundf(sin(_time*0.5+i)*5),roundf(cos(_time*0.4+i)*3))).round()
		layer.draw_rect(Rect2(p,Vector2(3,3)),Color(0.9,0.91,0.55,0.45 if glow<0.7 else 0.8))

func _build_rain() -> void:
	super._build_rain()
	_rain.set_shader_parameter("density",0.0)

func _update_life(_delta:float) -> void:
	_update_shine()

func _build_wordmark() -> void:
	_title.hide()
	var vp:=SubViewport.new()
	vp.name="WordmarkCanvas"
	vp.size=Vector2i(384,84)
	vp.transparent_bg=true
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	vp.canvas_item_default_texture_filter=Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_ui.add_child(vp)
	var lettering:=Node2D.new()
	lettering.set_script(preload("res://scripts/ui/hollowtide_wordmark.gd"))
	vp.add_child(lettering)
	_wordmark=TextureRect.new()
	_wordmark.name="Wordmark"
	_wordmark.texture=vp.get_texture()
	_wordmark.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	_wordmark.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	_wordmark.stretch_mode=TextureRect.STRETCH_SCALE
	_wordmark.size=Vector2(768,168)
	_wordmark.position=Vector2(192,0)
	_wordmark.mouse_filter=Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_wordmark)
	_wordmark_home=_wordmark.position

func _update_shine() -> void:pass # Carved lettering stays still and legible.

func _build_boot() -> void:
	super._build_boot()
	var logo:=_boot.get_node("LaunchWordmark") as TextureRect
	logo.position.x=roundf((1152.0-logo.size.x)*0.5)

func _panel(node_name:String,at:Vector2,width:float) -> PanelContainer:
	var panel:=super._panel(node_name,at,width)
	var box:=StyleBoxFlat.new()
	box.bg_color=Color("#242b25")
	box.border_color=Color("#b69b6d")
	box.set_border_width_all(3)
	box.set_content_margin_all(18)
	box.shadow_color=Color(0.04,0.06,0.05,0.5)
	box.shadow_size=4
	box.shadow_offset=Vector2(4,4)
	panel.add_theme_stylebox_override("panel",box)
	return panel

func _button(text:String) -> Button:
	var b:=super._button(text)
	var plain:=StyleBoxFlat.new()
	plain.bg_color=Color("#242b25")
	plain.set_content_margin_all(8)
	plain.content_margin_left=40
	var active:=plain.duplicate() as StyleBoxFlat
	active.bg_color=Color("#3f5140")
	active.border_color=Color("#e4ca8e")
	active.set_border_width_all(2)
	b.add_theme_stylebox_override("normal",plain)
	for state in ["focus","hover","pressed"]:b.add_theme_stylebox_override(state,active)
	return b

func _build_menu() -> void:
	super._build_menu()
	_main_panel.position=Vector2(44,376)
	_main_panel.custom_minimum_size=Vector2(310,0)
	var choices:=_main_panel.get_node("Choices")
	var caption:=_label("BEGIN YOUR JOURNEY",20)
	caption.modulate=Color("#d1bd91")
	choices.add_child(caption)
	choices.move_child(caption,0)
	for b in _buttons:b.custom_minimum_size.y=48
	_cursor.color=Color("#e4ca8e")

func _build_characters() -> void:
	var meta:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/sprites/menu/village_actors_2026_10_09/animations.json"))
	for spec in [["punchybun",Vector2(566,428)],["cinderhide",Vector2(712,436)]]:
		var feet:Vector2=spec[1]
		var shadow:=Polygon2D.new()
		shadow.name=spec[0].capitalize()+"VillageShadow"
		shadow.polygon=PackedVector2Array([Vector2(-31,-3),Vector2(-22,-8),Vector2(20,-8),Vector2(32,-3),Vector2(20,3),Vector2(-21,3)])
		shadow.color=Color(0.16,0.12,0.08,0.22)
		shadow.position=feet
		var soft:=Polygon2D.new()
		soft.name="GroundShade"
		soft.polygon=PackedVector2Array([Vector2(-38,-4),Vector2(-26,-11),Vector2(23,-11),Vector2(40,-4),Vector2(25,6),Vector2(-25,6)])
		soft.color=Color(0.22,0.19,0.10,0.10)
		shadow.add_child(soft)
		add_child(shadow)
		var actor:=Sprite2D.new()
		actor.set_script(preload("res://scripts/ui/village_menu_actor.gd"))
		actor.setup(spec[0],feet,meta[spec[0]])
		add_child(actor)
		companions.append(actor)

func _build_journey_panel() -> void:
	# Kept hidden for the inherited menu contract; New Game goes to the prologue.
	_journey_panel=_panel("CreatureJourney",Vector2(650,180),460)
	var list:=_list(_journey_panel)
	_begin_button=_button("Wake beneath the bank")
	list.add_child(_begin_button)
	_journey_status=_label("")
	list.add_child(_journey_status)

func _poll_route() -> void:pass

func _request_route() -> void:pass # This menu uses the preloaded creature prologue.

func _on_new_game() -> void:
	if _boot_done and not _leaving:_begin_journey()

func _begin_journey() -> void:
	if _leaving or not _boot_done:return
	_leaving=true
	_save_preferences()
	_sound(CONFIRM_SOUND)
	_cursor.hide()
	_fade.mouse_filter=Control.MOUSE_FILTER_STOP
	await create_tween().tween_property(_fade,"color:a",1.0,0.2 if _reduce_motion else 0.6).finished
	var scene:=PROLOGUE.instantiate()
	scene.reduce_motion=_reduce_motion
	var error:=get_tree().change_scene_to_node(scene)
	if error!=OK:
		scene.free()
		_leaving=false
		_fade.color.a=0
		_fade.mouse_filter=Control.MOUSE_FILTER_IGNORE
		_show_page("main",_buttons[0])

func _process(delta:float) -> void:
	super._process(delta)
	for actor in companions:
		actor.pose(_time,_reduce_motion or not _boot_done or _leaving)
