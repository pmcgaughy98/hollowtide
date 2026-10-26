extends "res://scripts/opening_flow.gd"
## Creature-player launch from an original Retro Diffusion village painting.
## Village architecture is a visual proposal; the awakening and dungeon flow remain.
const PROLOGUE = preload("res://scenes/creature_prologue.tscn")
# New Game opens the soul prologue first (Claude, 2026-10-10; Preston: the soul arrives in Hollowtide
# and chooses its creature), which then hands over to PROLOGUE with the starter chosen.
const SOUL = preload("res://scenes/storm_open.tscn")   # Claude, 2026-10-10: the storm cold open plays first, then the soul prologue (Preston)
const VILLAGE = preload("res://assets/sprites/menu/creature_village_2026_10_09.png")
const FRAME_TRIM = preload("res://scripts/ui/title_panel_trim.gd")
const ControlsText := preload("res://scripts/ui/controls_text.gd")
const LEGIBILITY = preload("res://scripts/ui/title_legibility.gdshader")
var _help_panel: PanelContainer
var _help_button: Button
var _help_controls: Array[Control] = []
var _help_scroll: ScrollContainer
var _help_copy: VBoxContainer
var _help_topic := "journey"
var _action_copy: Label
var _input_hint: Label
var _input_device := "keyboard"
var _launch_hint: Label

# Claude, 2026-10-09 (Preston: "wire the rest into the game"): the title plays Preston's Hollowtide
# theme (432 Hz) through the menu's own player, so the options volume still applies.
func _ready() -> void:
	# Keep the authored 16:9 composition intact when the game window changes aspect.
	get_tree().root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
	# Fade the shared town/dungeon player when returning to this local title theme.
	preload("res://scripts/audio/music.gd").play(get_tree(), "")
	super._ready()
	if _music != null:
		var theme: AudioStream = load("res://assets/audio/music/title.mp3")
		if "loop" in theme:
			theme.loop = true
		_music.stream = theme
		_music.play()

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
	var wash := ColorRect.new()
	wash.name="MenuLegibility"
	wash.size=Vector2(1152,648)
	wash.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var treatment := ShaderMaterial.new()
	treatment.shader=LEGIBILITY
	wash.material=treatment
	add_child(wash)
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
	# The launch card belongs to the same forest/gold palette as the village menu.
	(_boot.get_child(0) as ColorRect).color=Color("#161f1b")
	var logo:=_boot.get_node("LaunchWordmark") as TextureRect
	logo.position.x=roundf((1152.0-logo.size.x)*0.5)
	var captions: Array[Label] = []
	for n in _boot.get_children():
		if n is Label:captions.append(n)
	captions[0].text="THE RIVER HAS GONE QUIET."
	captions[0].modulate=Color("#d1bd91")
	_launch_hint=captions[1]
	_launch_hint.modulate=Color("#a4b09a")
	_launch_hint.add_theme_font_override("font",UI.font("label"))
	_launch_hint.add_theme_font_size_override("font_size",UI.type_size("label"))
	_set_input_device(_input_device)

func _label(text:String,size:int=24) -> Label:
	var l := super._label(text,size)
	if size==23:   # the Help section labels use the shared compact role
		l.add_theme_font_override("font",UI.font("label"))
		l.add_theme_font_size_override("font_size",UI.type_size("label"))
	return l

func _panel(node_name:String,at:Vector2,width:float) -> PanelContainer:
	var panel:=super._panel(node_name,at,width)
	var box:=UI.frame("panel").duplicate()
	box.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel",box)
	var trim := FRAME_TRIM.new()
	trim.name="FrameJoinery"
	panel.add_child(trim)
	trim.hide() # Shared frame supplies its own corner studs and joinery.
	return panel

func _build_menu() -> void:
	super._build_menu()
	_main_panel.position=Vector2(64,324)
	_main_panel.custom_minimum_size=Vector2(320,0)
	var open_frame := StyleBoxEmpty.new()
	open_frame.set_content_margin_all(16)
	_main_panel.add_theme_stylebox_override("panel",open_frame)
	_main_panel.get_node("FrameJoinery").hide()
	var choices:=_main_panel.get_node("Choices")
	choices.add_theme_constant_override("separation",6)
	var caption:=_label("BEGIN YOUR JOURNEY",20)
	caption.modulate=Color("#d1bd91")
	choices.add_child(caption)
	choices.move_child(caption,0)
	caption.hide()
	_help_button=_button("How to play")
	_help_button.name="HowToPlay"
	_help_button.pressed.connect(_open_help)
	choices.add_child(_help_button)
	# Keep button identities, with How to play immediately before Quit. Use the last button's index
	# since Continue is listed first when a save exists (Claude, 2026-10-12).
	choices.move_child(_help_button,_buttons[_buttons.size()-1].get_index())
	_buttons.append(_help_button)
	for b in _buttons:
		b.custom_minimum_size.y=54
	var rule := ColorRect.new()
	rule.custom_minimum_size=Vector2(0,1)
	rule.color=Color("#706c4c")
	rule.mouse_filter=Control.MOUSE_FILTER_IGNORE
	choices.add_child(rule)
	rule.hide()
	_action_copy=_label("Awaken as a creature. Find your first companion.",18)
	_action_copy.name="SelectedAction"
	_action_copy.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	_action_copy.custom_minimum_size=Vector2(300,42)
	_action_copy.modulate=Color("#d1bd91")
	choices.add_child(_action_copy)
	_action_copy.hide() # Actions read directly; no explanatory card on the title.
	_input_hint=_label("",14)
	_input_hint.name="InputHint"
	_input_hint.modulate=Color("#c4c5ab")
	_input_hint.position=Vector2(80,608)
	_ui.add_child(_input_hint)
	# Laid out from the hint line up, not from a fixed top: with Continue listed first (five rows) the
	# menu ran from 324 to 650 and "Quit" sat on the hint. Four rows keep their old place. Claude, 2026-10-14.
	_main_panel.position.y=menu_top(_buttons.size() + (1 if _save_note != null else 0))   # the save note counts as a row

	for b in _buttons:
		b.focus_entered.connect(_selected_action.bind(b))
		b.mouse_entered.connect(_set_input_device.bind("mouse"))
	_build_help_panel()
	_set_input_device("keyboard")
	var prefs := get_node_or_null("/root/InputPrefs")
	if prefs != null:
		prefs.device_changed.connect(_refresh_help_controls)
		prefs.bindings_changed.connect(_refresh_help_bindings)
	_cursor.color=Color("#e4ca8e")
	_cursor.polygon=PackedVector2Array([Vector2(0,0),Vector2(3,0),Vector2(3,2),Vector2(5,2),Vector2(5,4),Vector2(3,4),Vector2(3,6),Vector2(0,6)])
	# Panels share the village palette and stay clear of the wordmark.
	_quit_panel.custom_minimum_size.x=442
	_quit_panel.position=Vector2(minf(666.0,1136.0-_quit_panel.get_combined_minimum_size().x),312)
	_quit_controls[0].text="Back to title"

func _selected_action(b: Button) -> void:
	if _action_copy == null:return
	_action_copy.text={"NewGame":"Awaken as a creature. Find your first companion.","Options":"Adjust the sound and the title's ambient motion.","HowToPlay":"Learn your way around Highbank and the Hollows.","Quit":"Close Hollowtide. You will confirm before leaving."}.get(String(b.name),"")

func _set_input_device(device: String) -> void:
	_input_device=device
	if _launch_hint != null:
		_launch_hint.text={"keyboard":"Enter to continue","controller":"A to continue","mouse":"Click to continue"}[device]
	if _input_hint == null:return
	_input_hint.text={"keyboard":"Up/Down  Move   Enter  Choose   Esc  Back","controller":"D-pad  Move   A  Choose   B  Back","mouse":"Click to choose   Esc  Back"}[device]

func _place_cursor() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if _cursor == null:return
	_cursor.visible=_page!="options" and focused is Button and _focus_controls.has(focused) and not _leaving
	if not _cursor.visible:return
	var rect: Rect2=focused.get_global_rect()
	_cursor.position=Vector2(rect.position.x+10,rect.position.y+(rect.size.y-12)*0.5).round()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:_set_input_device("keyboard")
	elif event is InputEventJoypadButton and event.pressed:_set_input_device("controller")
	elif event is InputEventJoypadMotion and absf(event.axis_value)>0.6:_set_input_device("controller")
	elif event is InputEventMouseButton and event.pressed:_set_input_device("mouse")
	elif event is InputEventMouseMotion and event.relative.length()>2:_set_input_device("mouse")
	super._input(event)

func _build_help_panel() -> void:
	_help_panel=_panel("HowToPlay",Vector2(430,120),678)
	var list := _list(_help_panel)
	list.add_child(_label("HOW TO PLAY",30))
	var tabs := HBoxContainer.new()
	tabs.name="Topics"
	tabs.add_theme_constant_override("separation",10)
	list.add_child(tabs)
	for topic in ["journey","controls"]:
		var tab := _button("The journey" if topic=="journey" else "Controls")
		tab.name=topic.capitalize()
		tab.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		tab.toggle_mode=true
		tab.pressed.connect(_show_help_topic.bind(topic))
		tabs.add_child(tab)
		_help_controls.append(tab)
	_help_scroll=ScrollContainer.new()
	_help_scroll.name="GuideScroll"
	_help_scroll.custom_minimum_size=Vector2(630,246)
	_help_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	_help_scroll.follow_focus=true
	_help_scroll.focus_mode=Control.FOCUS_ALL
	UI.style_scroll_bar(_help_scroll.get_v_scroll_bar())
	list.add_child(_help_scroll)
	_help_copy=VBoxContainer.new()
	_help_copy.name="Guide"
	_help_copy.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	_help_copy.add_theme_constant_override("separation",8)
	_help_scroll.add_child(_help_copy)
	var actions := HBoxContainer.new()
	actions.name="Actions"
	actions.add_theme_constant_override("separation",10)
	list.add_child(actions)
	for entry in [["StartNewGame","Start New Game",_on_new_game],["Back","Back",_close_panel]]:
		var b := _button(entry[1])
		b.name=entry[0]
		b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		b.pressed.connect(entry[2])
		if entry[0]=="StartNewGame":
			var primary := UI.frame("panel_focus").duplicate()
			primary.content_margin_top=8
			primary.content_margin_bottom=8
			primary.content_margin_left=40
			b.add_theme_stylebox_override("normal",primary)
		actions.add_child(b)
		_help_controls.append(b)
	_help_controls.append(_help_scroll)
	_show_help_topic("journey")
	_help_panel.hide()

func _show_help_topic(topic: String) -> void:
	var scroll_y := _help_scroll.scroll_vertical if _help_topic==topic else 0
	_help_topic=topic
	for n in _help_copy.get_children():
		_help_copy.remove_child(n)
		n.queue_free()
	for i in 2:
		var tab := _help_controls[i] as Button
		var active: bool = topic==["journey","controls"][i]
		tab.set_pressed_no_signal(active)
		var box := UI.frame("panel_focus" if active else "panel").duplicate()
		box.content_margin_top=8
		box.content_margin_bottom=8
		box.content_margin_left=40
		tab.add_theme_stylebox_override("normal",box)
	var lines: Array
	if topic=="journey":
		lines=[
			["01   A voice beneath the riverbank",23],
			["New Game begins with your awakening. Discover who you are, then answer another survivor. Your companion is met in the story.",20],
			["02   Reach Highbank together",23],
			["Explore the village. The Mouth of the Hollow leads into a dungeon with your chosen team.",20],
			["03   Watch each other's steps",23],
			["Hollows are turn-based: the floor waits for your action. Watch the lantern, look for stairs, and keep your team close.",20]]
	else:
		lines=[[ControlsText.note(UI.last_device()),20]]
		for group in ControlsText.groups(UI.last_device()):
			lines.append([group["head"],23])
			for words in group["lines"]:lines.append([words,20])
			if group["head"]==ControlsText.HOLLOW["head"]:lines.append([ControlsText.TURNS,20])
	for entry in lines:
		var l := _label(entry[0],entry[1])
		l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		if entry[1]==23:l.modulate=Color("#e4ca8e")
		_help_copy.add_child(l)
	_help_scroll.set_deferred("scroll_vertical",scroll_y)
	_help_panel.reset_size.call_deferred()

func _refresh_help_controls(_device: String) -> void:
	if _page=="help" and _help_topic=="controls":_show_help_topic("controls")

func _refresh_help_bindings() -> void:
	_refresh_help_controls(UI.last_device())

func _unhandled_input(event: InputEvent) -> void:
	if _page=="help":
		var step := int(UI.pressed(event,"page_down"))-int(UI.pressed(event,"page_up"))
		if step!=0:
			_help_scroll.scroll_vertical+=step*int(_help_scroll.size.y*0.75)
			get_viewport().set_input_as_handled()
			return
	super._unhandled_input(event)

func _open_help() -> void:
	if not _boot_done or _leaving:return
	_sound(CONFIRM_SOUND)
	_show_page("help",_help_controls[0])

func _show_page(next: String, first: Control) -> void:
	super._show_page(next,first)
	if _help_panel != null:_help_panel.visible=next=="help"
	if _input_hint != null:_input_hint.visible=next=="main"
	if next=="help":_focus_controls.assign(_help_controls)
	elif next=="main" and _help_button != null:
		# The buttons in their listed order with Help just above Quit (Continue may be first; Claude, 2026-10-12).
		var order:Array=_buttons.filter(func(b:Button)->bool:return b!=_help_button)
		order.insert(order.size()-1,_help_button)
		_focus_controls.assign(order)
	for i in _focus_controls.size():
		var c := _focus_controls[i]
		c.focus_neighbor_top=_focus_controls[posmod(i-1,_focus_controls.size())].get_path()
		c.focus_neighbor_bottom=_focus_controls[(i+1)%_focus_controls.size()].get_path()
		c.focus_previous=c.focus_neighbor_top
		c.focus_next=c.focus_neighbor_bottom
		c.focus_neighbor_left=c.get_path()
		c.focus_neighbor_right=c.get_path()
	if next=="help":
		for pair in [[0,1],[2,3]]:
			_help_controls[pair[0]].focus_neighbor_right=_help_controls[pair[1]].get_path()
			_help_controls[pair[1]].focus_neighbor_left=_help_controls[pair[0]].get_path()

func _close_panel() -> void:
	if _page=="help":
		if _leaving or not _boot_done:return
		_sound(CANCEL_SOUND)
		_show_page("main",_help_button)
	else:super._close_panel()

func _build_characters() -> void:
	# The village carries the title scene; Preston removed the foreground creatures.
	pass

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
	var fade := create_tween().set_parallel(true)
	var seconds := 0.2 if _reduce_motion else 0.6
	fade.tween_property(_fade,"color:a",1.0,seconds)
	if _music != null: fade.tween_property(_music,"volume_db",-80.0,seconds)
	await fade.finished
	var scene:=SOUL.instantiate()
	scene.reduce_motion=_reduce_motion
	var error:=get_tree().change_scene_to_node(scene)
	if error!=OK:
		scene.free()
		_leaving=false
		if _music != null: _music.volume_db = music_db
		_fade.color.a=0
		_fade.mouse_filter=Control.MOUSE_FILTER_IGNORE
		_show_page("main",_buttons[0])


## The menu's top for this many rows: its old 324, or higher so it ends 12 px above the hint line at 608.
static func menu_top(rows:int) -> float:
	var tall:=32.0+rows*54.0+maxi(0,rows-1)*6.0
	return minf(324.0,608.0-12.0-tall)
