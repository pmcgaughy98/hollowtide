extends Node2D
## Playable opening proposal: pilot riverbank collapse, a Wayline trainee, then Highbank.
## Identity and party are passed into the existing town; no save/state rewrite.
const Finish=preload("res://scripts/arena/creature_finish.gd")
const UI=preload("res://scripts/ui/ui_style.gd")
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
var dialogue:Node2D
var bank:Node2D

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
	bank=preload("res://scripts/ui/waking_bank.gd").new()
	bank.reduce_motion=reduce_motion
	vp.add_child(bank)
	leader_sprite=actor(vp,Vector2(168,83))
	partner_sprite=actor(vp,Vector2(222,84))
	partner_sprite.hide()
	var ui:=CanvasLayer.new()
	add_child(ui)
	var banner:=label("HOLLOWTIDE   /   THE FIRST VOICE",20)
	banner.position=Vector2(48,24)
	ui.add_child(banner)
	panel=PanelContainer.new()
	panel.position=Vector2(102,468)
	panel.custom_minimum_size=Vector2(948,160)
	var style:=UI.frame("panel_dim").duplicate()
	style.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel",style)
	ui.add_child(panel)
	var list:=VBoxContainer.new()
	list.add_theme_constant_override("separation",8)
	panel.add_child(list)
	title=label("",30)
	title.position=Vector2(270,268)
	ui.add_child(title)
	prose=label("",22)
	prose.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	prose.custom_minimum_size=Vector2(900,58)
	prose.hide() # Remains the story text model; the shared dialogue draws it.
	ui.add_child(prose)
	dialogue=preload("res://scripts/ui/opening_dialogue.gd").new()
	dialogue.source=self
	ui.add_child(dialogue)
	choices=HBoxContainer.new()
	choices.add_theme_constant_override("separation",12)
	list.add_child(choices)
	var actions:=HBoxContainer.new()
	actions.add_theme_constant_override("separation",16)
	list.add_child(actions)
	confirm=button("")
	confirm.custom_minimum_size=Vector2(648,52)
	confirm.pressed.connect(advance)
	actions.add_child(confirm)
	back=button("Back")
	back.custom_minimum_size=Vector2(236,52)
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
	b.custom_minimum_size.y=52
	var style:=UI.frame("panel").duplicate()
	style.content_margin_top=8
	style.content_margin_bottom=8
	b.add_theme_stylebox_override("normal",style)
	var focus:=UI.frame("panel_focus").duplicate()
	focus.content_margin_top=8
	focus.content_margin_bottom=8
	b.add_theme_stylebox_override("focus",focus)
	b.add_theme_stylebox_override("hover",focus)
	return b

func refresh() -> void:
	for child in choices.get_children():choices.remove_child(child);child.queue_free()
	cards.clear()
	partner_sprite.visible=phase>0
	bank.companion_visible=phase>0
	bank.queue_redraw()
	set_form(leader_sprite,hero)
	set_form(partner_sprite,partner)
	# Dialogue proposals for the approved pilot outline; final wording remains Preston's.
	if phase==0:
		title.text="You wake beneath the riverbank."
		prose.text="The bank collapses. Across the river, pale light spills from the rising Hollow.\nYou remember being human. "+SENSES[hero]
		confirm.text="This is me"
		back.text="Return to title"
	elif phase==1:
		title.text="A voice answers in the dark."
		prose.text='"I’m a Wayline trainee, sent to gather mail the river tore loose. Something told me to come down here tonight."\nWhose voice do you answer?'
		confirm.text="Travel with "+NAMES[partner]
		back.text="Back"
	else:
		title.text="You will find a way through together."
		prose.text=NAMES[partner]+' says, "No one runs a route alone. They keep turning me away without a partner."\nYou need a guide. They need a partner. Together, you head for Highbank.'
		confirm.text="Step onto the riverbank"
		back.text="Change partner"
	if phase<2 and not (phase==0 and chosen_by_soul):
		for i in 3:
			if phase==1 and i==hero:continue
			var b:=button(NAMES[i])
			b.custom_minimum_size=Vector2(290 if phase==0 else 444,52)
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
	dialogue.queue_redraw()
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
	# Preston, 2026-10-10: explore this bank and its close-up entrance immediately after choice.
	# Highbank remains the next story stop; the existing team record carries the choice.
	preload("res://scripts/town/team_state.gd").start([[hero,0],[partner,0]],{"creature_player":FORMS[hero],"opening_companion":FORMS[partner]})
	var dungeon:Node2D=load("res://scenes/waking_riverbank.tscn").instantiate()
	dungeon.reduce_motion=reduce_motion
	preload("res://scripts/town/team_state.gd").give_to(dungeon)
	var error:=get_tree().change_scene_to_node(dungeon)
	if error!=OK:
		dungeon.free();leaving=false;confirm.disabled=false;back.disabled=false
		veil.color.a=0;veil.mouse_filter=Control.MOUSE_FILTER_IGNORE
		prose.text="Riverbank could not open. Your choices are still here."

func _unhandled_input(event:InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		previous()
