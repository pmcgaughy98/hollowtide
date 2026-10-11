extends Node2D
## Playable opening proposal: awakening, another survivor, then Highbank.
## Identity and party are passed into the existing town; no save/state rewrite.
const Painter=preload("res://scripts/dungeon/floor_painter.gd")
const Gen=preload("res://scripts/hollow/hollow_gen.gd")
const Finish=preload("res://scripts/arena/creature_finish.gd")
const TITLE=preload("res://assets/fonts/AlegreyaSansSC-Bold.ttf")
const FONT=preload("res://assets/fonts/Silkscreen-Regular.ttf")
const FORMS=["kithflare","tallowroot","rimefin"]
const NAMES=["Kithflare","Tallowroot","Rimefin"]
const SENSES=["A warm spark at the end of your tail.","Roots curl against the damp clay.","Cool water runs along your fins."]
var reduce_motion:=false
var chosen_by_soul:=false # the soul prologue already chose the starter (Claude, 2026-10-10)
var phase:=0
var hero:=0
var partner:=1
var selected:=0
var leaving:=false
var panel:PanelContainer
var title:Label
var prose:Label
var choices:HBoxContainer
var confirm:Button
var back:Button
var cards:Array[Button]=[]
var leader_sprite:Sprite2D
var partner_sprite:Sprite2D
var veil:ColorRect

func _ready() -> void:
	get_tree().root.content_scale_size=Vector2i(1152,648)
	get_tree().root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
	var vp:=SubViewport.new()
	vp.size=Vector2i(384,216)
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	add_child(vp)
	var display:=Sprite2D.new()
	display.texture=vp.get_texture()
	display.centered=false
	display.scale=Vector2.ONE*3
	display.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(display)
	var tiles:=PackedByteArray()
	tiles.resize(16*9)
	tiles.fill(Gen.WALL)
	for y in range(1,8):
		for x in range(2,14):tiles[y*16+x]=Gen.FLOOR
	var d:Dictionary={"w":16,"h":9,"tiles":tiles,"stairs":Vector2i(12,2)}
	var map:=Sprite2D.new()
	map.centered=false
	map.texture=ImageTexture.create_from_image(Painter.paint(d,24,19))
	map.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	vp.add_child(map)
	leader_sprite=actor(vp,Vector2(168,100))
	partner_sprite=actor(vp,Vector2(222,101))
	partner_sprite.hide()
	var ui:=CanvasLayer.new()
	add_child(ui)
	var banner:=label("HOLLOWTIDE   /   THE FIRST VOICE",20)
	banner.position=Vector2(48,24)
	ui.add_child(banner)
	panel=PanelContainer.new()
	panel.position=Vector2(102,338)
	panel.custom_minimum_size=Vector2(948,286)
	var style:=StyleBoxFlat.new()
	style.bg_color=Color("#1f1b36")
	style.border_color=Color("#8e6fb4")
	style.set_border_width_all(3)
	style.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel",style)
	ui.add_child(panel)
	var list:=VBoxContainer.new()
	list.add_theme_constant_override("separation",8)
	panel.add_child(list)
	title=label("",30)
	list.add_child(title)
	prose=label("",22)
	prose.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	prose.custom_minimum_size=Vector2(900,58)
	list.add_child(prose)
	choices=HBoxContainer.new()
	choices.add_theme_constant_override("separation",12)
	list.add_child(choices)
	var actions:=HBoxContainer.new()
	actions.add_theme_constant_override("separation",16)
	list.add_child(actions)
	confirm=button("")
	confirm.custom_minimum_size=Vector2(652,44)
	confirm.pressed.connect(advance)
	actions.add_child(confirm)
	back=button("Back")
	back.custom_minimum_size=Vector2(236,44)
	back.pressed.connect(previous)
	actions.add_child(back)
	veil=ColorRect.new()
	veil.size=Vector2(1152,648)
	veil.color=Color(0,0,0,0)
	veil.mouse_filter=Control.MOUSE_FILTER_IGNORE
	ui.add_child(veil)
	refresh()

func actor(parent:Node,at:Vector2) -> Sprite2D:
	var s:=Sprite2D.new()
	s.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	s.position=at
	Finish.apply(s)
	parent.add_child(s)
	return s

func set_form(s:Sprite2D,index:int) -> void:
	s.texture=load("res://assets/sprites/arena/%s/small/s.png"%FORMS[index])
	var used:=s.texture.get_image().get_used_rect()
	s.offset.y=s.texture.get_height()*0.5-used.end.y

func label(text:String,size:int) -> Label:
	var l:=Label.new()
	l.text=text
	l.add_theme_font_override("font",TITLE)
	l.add_theme_font_size_override("font_size",size)
	l.add_theme_color_override("font_color",Color("#fff4e8"))
	return l

func button(text:String) -> Button:
	var b:=Button.new()
	b.text=text
	b.add_theme_font_override("font",TITLE)
	b.add_theme_font_size_override("font_size",24)
	var style:=StyleBoxFlat.new()
	style.bg_color=Color("#332d4c")
	style.border_color=Color("#8e6fb4")
	style.set_border_width_all(2)
	b.add_theme_stylebox_override("normal",style)
	var focus:=style.duplicate()
	focus.border_color=Color("#7fe3d0")
	focus.set_border_width_all(3)
	b.add_theme_stylebox_override("focus",focus)
	b.add_theme_stylebox_override("hover",focus)
	return b

func refresh() -> void:
	for child in choices.get_children():choices.remove_child(child);child.queue_free()
	cards.clear()
	partner_sprite.visible=phase>0
	set_form(leader_sprite,hero)
	set_form(partner_sprite,partner)
	if phase==0:
		title.text="You wake beneath the riverbank."
		prose.text="The river has gone quiet. You press against the clay and feel...\n"+SENSES[hero]
		confirm.text="This is me"
		back.text="Return to title"
	elif phase==1:
		title.text="A voice answers in the dark."
		prose.text='"You heard the bank give way too? Stay close. There must be a way out."\nWhich survivor do you call back to?'
		confirm.text="Travel with "+NAMES[partner]
		back.text="Back"
	else:
		title.text="You will find a way through together."
		prose.text=NAMES[partner]+" waits beside you. A break in the clay opens onto the path to Highbank.\nFollow the village lights. Watch each other as you go."
		confirm.text="Reach Highbank together"
		back.text="Choose another companion"
	if phase<2 and not (phase==0 and chosen_by_soul):
		for i in 3:
			if phase==1 and i==hero:continue
			var b:=button(NAMES[i])
			b.custom_minimum_size=Vector2(290 if phase==0 else 444,46)
			b.pressed.connect(choose.bind(i))
			choices.add_child(b)
			cards.append(b)
			if i==(hero if phase==0 else partner):b.text="• "+NAMES[i]
	var controls:Array[Control]=[]
	for b in cards:controls.append(b)
	controls.append(confirm);controls.append(back)
	for i in controls.size():
		controls[i].focus_neighbor_left=controls[posmod(i-1,controls.size())].get_path()
		controls[i].focus_neighbor_right=controls[(i+1)%controls.size()].get_path()
		controls[i].focus_neighbor_top=controls[i].focus_neighbor_left
		controls[i].focus_neighbor_bottom=controls[i].focus_neighbor_right
	confirm.grab_focus.call_deferred()

func choose(i:int) -> void:
	if leaving:return
	if phase==0:
		hero=i
		if partner==hero:partner=(hero+1)%3
	else:partner=i
	refresh()

func previous() -> void:
	if leaving:return
	if phase==0:get_tree().change_scene_to_file("res://scenes/creature_opening.tscn")
	else:phase-=1;refresh()

func advance() -> void:
	if leaving:return
	if phase<2:phase+=1;refresh();return
	leaving=true
	confirm.disabled=true
	back.disabled=true
	veil.mouse_filter=Control.MOUSE_FILTER_STOP
	await create_tween().tween_property(veil,"color:a",1.0,0.15 if reduce_motion else 0.5).finished
	# Claude, 2026-10-09 (Preston: "prologue to town to hollow and back"): the day starts in Highbank,
	# and the Mouth of the Hollow there starts the run. The team record carries the choice.
	preload("res://scripts/town/team_state.gd").start([[hero,0],[partner,0]],{"creature_player":FORMS[hero],"opening_companion":FORMS[partner]})
	var dungeon:Node2D=load("res://scenes/hub_town.tscn").instantiate()
	preload("res://scripts/town/team_state.gd").give_to(dungeon)
	var error:=get_tree().change_scene_to_node(dungeon)
	if error!=OK:
		dungeon.free();leaving=false;confirm.disabled=false;back.disabled=false
		veil.color.a=0;veil.mouse_filter=Control.MOUSE_FILTER_IGNORE
		prose.text="Highbank could not open. Your choices are still here."

func _unhandled_input(event:InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		previous()
