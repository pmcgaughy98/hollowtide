extends Node2D
## Walkable presentation between partner choice and Highbank. No turns, rewards or new save fields.
## Preston: the walkway opens a separate close-up scene immediately after partner choice.
const Bank=preload("res://scripts/ui/waking_bank.gd")
const EntranceFinish=preload("res://scripts/ui/hollow_entrance_finish.gd")
const Finish=preload("res://scripts/arena/creature_finish.gd")
const Lines=preload("res://scripts/creatures/lines.gd")
const TeamState=preload("res://scripts/town/team_state.gd")
const UI=preload("res://scripts/ui/ui_style.gd")
const ENTRANCE_ART="res://assets/sprites/world/waking_bank_2026_10_10/entrance_native.png"
const WALKWAY=Vector2(240,82)
const HIGHBANK=Vector2(130,187)
const ARCH=Vector2(192,118)
const BACK=Vector2(192,200)
var bank_land:=PackedVector2Array([Vector2(48,87),Vector2(138,78),Vector2(248,77),Vector2(331,97),Vector2(346,182),Vector2(310,205),Vector2(48,205),Vector2(25,143)])
var entrance:=false
var reduce_motion:=false
var returning:=false
var from_entrance:=false
var party:Array=[[0,0],[1,0]]
var actors:Array[Sprite2D]=[]
var forms:Array[String]=[]
var trail:Array[Vector2]=[]
var leader:=Vector2(168,83)
var facing:="s"
var clock:=0.0
var leaving:=false
var denied:=false
var status:Label
var hint:Label
var view:SubViewport
var bank:Node2D
var textures:Dictionary={}

func _ready()->void:
	get_tree().root.content_scale_size=Vector2i(1152,648)
	get_tree().root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
	view=SubViewport.new();view.size=Vector2i(384,216)
	view.render_target_update_mode=SubViewport.UPDATE_ALWAYS;add_child(view)
	var display:=Sprite2D.new();display.texture=view.get_texture();display.centered=false
	display.scale=Vector2.ONE*3;display.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;add_child(display)
	if entrance:
		var img:=Bank.detailed_image(ENTRANCE_ART)
		var background:=Sprite2D.new();background.centered=false
		background.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		if img!=null:
			background.texture=ImageTexture.create_from_image(EntranceFinish.finished_image(img))
			EntranceFinish.apply(background,img)
		else:background.texture=ImageTexture.create_from_image(Bank.paint())
		view.add_child(background);leader=Vector2(192,177)
	else:
		bank=Bank.new();bank.reduce_motion=reduce_motion;bank.show_actor_shadows=false
		view.add_child(bank)
		if from_entrance or returning:leader=Vector2(216,98)
	for i in party.size():
		var form:String=Lines.of(party[i][0]).forms[party[i][1]][0]
		forms.append(form)
		var actor:=Sprite2D.new();actor.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		actor.position=leader+Vector2(0,i*12) if entrance or from_entrance or returning else Vector2(168,83) if i==0 else Vector2(222,84+i-1)
		Finish.apply(actor,false,form);view.add_child(actor);actors.append(actor)
		_set_texture(i,"s",-1)
	for i in 80:trail.append(leader)
	var shadows:=preload("res://scripts/ui/journey_shadows.gd").new()
	shadows.actors=actors;view.add_child(shadows)
	var canvas:=CanvasLayer.new();add_child(canvas)
	var heading:=_label("THE HOLLOW  /  RIVER APPROACH" if entrance else "RIVERBANK  /  THE FIRST ROUTE",22)
	heading.position=Vector2(36,20);canvas.add_child(heading)
	var panel:=PanelContainer.new();panel.position=Vector2(24,564);panel.custom_minimum_size=Vector2(1104,66)
	var frame:=UI.frame("panel_dim").duplicate();frame.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel",frame);canvas.add_child(panel)
	hint=_label("",22);panel.add_child(hint)
	status=_label("",22);status.position=Vector2(36,522);canvas.add_child(status)
	_update_hint()

func _label(text:String,size:int)->Label:
	var l:=Label.new();l.text=text;l.add_theme_font_override("font",UI.HEAD)
	l.add_theme_font_size_override("font_size",size);l.add_theme_color_override("font_color",UI.TEXT)
	l.add_theme_color_override("font_shadow_color",Color.BLACK);l.add_theme_constant_override("shadow_offset_x",2);l.add_theme_constant_override("shadow_offset_y",2)
	return l

func _set_texture(index:int,direction:String,frame:int)->void:
	var stem:="walk_%s_f%d"%[direction,frame] if frame>=0 else direction
	var path:="res://assets/sprites/arena/%s/small/%s.png"%[forms[index],stem]
	if not ResourceLoader.exists(path):path="res://assets/sprites/arena/%s/dungeon/%s.png"%[forms[index],stem]
	if not ResourceLoader.exists(path):path="res://assets/sprites/arena/%s/small/s.png"%forms[index]
	if not textures.has(path):textures[path]=load(path)
	var sprite:=actors[index];sprite.texture=textures[path]
	if sprite.texture==null:return
	var used:=sprite.texture.get_image().get_used_rect()
	sprite.offset.y=sprite.texture.get_height()*0.5-used.end.y

func walkable(p:Vector2)->bool:
	if not entrance:return Geometry2D.is_point_in_polygon(p,bank_land)
	return Rect2(101,127,182,51).has_point(p) or Rect2(173,109,38,105).has_point(p)

func _process(delta:float)->void:
	if leaving:return
	var direction:=Input.get_vector("move_left","move_right","move_up","move_down")
	var moved:=false
	if direction.length()>0:
		var next:=leader+direction*48.0*delta
		if walkable(next):
			leader=next;moved=true
			trail.push_front(leader);trail.resize(80)
			facing="e" if direction.x>0.4 else "w" if direction.x< -0.4 else "n" if direction.y<0 else "s"
	clock+=delta
	for i in actors.size():
		if i==0:actors[i].position=leader.round()
		elif moved:actors[i].position=actors[i].position.move_toward(trail[mini(i*12,trail.size()-1)],48.0*delta).round()
		actors[i].z_index=int(actors[i].position.y)
		_set_texture(i,facing,int(clock*10)%8 if moved else -1)
	_update_hint()
	if entrance:
		if leader.distance_to(ARCH)<8 and not denied:_enter_arch()
	else:
		if leader.distance_to(WALKWAY)<10:_travel(true)

func _update_hint()->void:
	if entrance:
		hint.text="WASD / arrows — walk     Esc — return to riverbank"
		if leader.distance_to(ARCH)<30:hint.text="E / Enter — approach the arch     Esc — return to riverbank"
	else:
		hint.text="WASD / arrows — walk     Stone walkway — the Hollow     H — continue to Highbank"
		if leader.distance_to(HIGHBANK)<24:hint.text="E / Enter — take the south trail to Highbank"

func _unhandled_input(event:InputEvent)->void:
	if leaving:return
	if event.is_action_pressed("ui_cancel") and entrance:
		get_viewport().set_input_as_handled();_travel(false)
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if entrance and leader.distance_to(ARCH)<30:_enter_arch()
		elif not entrance and leader.distance_to(WALKWAY)<25:_travel(true)
		elif not entrance and leader.distance_to(HIGHBANK)<24:_town()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_H:
		get_viewport().set_input_as_handled();_town()

func _travel(close_up:bool)->void:
	var scene:Node2D=load("res://scenes/hollow_entrance.tscn" if close_up else "res://scenes/waking_riverbank.tscn").instantiate()
	scene.party=party.duplicate(true);scene.reduce_motion=reduce_motion;scene.returning=returning
	scene.from_entrance=not close_up
	_change(scene)

func _enter_arch()->void:
	# Existing pilot order stays intact: first training route, then the Warden's Hollow.
	if not "first" in TeamState.data.get("beaten",[]):
		denied=true;status.text='Your partner: "Let’s tell Highbank what we found. We can return together."';return
	var dungeon:Node2D=load("res://scenes/dungeon.tscn").instantiate()
	TeamState.give_to(dungeon);dungeon.party=party.duplicate(true)
	dungeon.dungeon="hollow";dungeon.return_to_town=true
	_change(dungeon)

func _town()->void:
	var town:Node2D=load("res://scenes/hub_town.tscn").instantiate()
	TeamState.give_to(town);town.party=party.duplicate(true)
	_change(town)

func _change(scene:Node)->void:
	leaving=true
	var error:=get_tree().change_scene_to_node(scene)
	if error!=OK:
		scene.free();leaving=false;status.text="The route could not open. Your team is still here."
