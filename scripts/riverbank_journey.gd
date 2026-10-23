extends Node2D
## Walkable presentation between partner choice and Highbank. No turns, rewards or new save fields.
## Preston: the walkway opens a separate close-up scene immediately after partner choice.
## Claude, 2026-10-22 (factory pass, lane 6): the partner's lines go through the shared text box with its
## name and face, Esc asks before going back to the title, the labels sit on the type roles, and the
## partner walks one tile behind the leader.
const Bank=preload("res://scripts/ui/waking_bank.gd")
const EntranceFinish=preload("res://scripts/ui/hollow_entrance_finish.gd")
const Finish=preload("res://scripts/arena/creature_finish.gd")
const Lines=preload("res://scripts/creatures/lines.gd")
const TeamState=preload("res://scripts/town/team_state.gd")
const UI=preload("res://scripts/ui/ui_style.gd")
const ENTRANCE_ART="res://assets/sprites/world/waking_bank_2026_10_10/entrance_native.png"
const TITLE="res://scenes/creature_opening.tscn"   # where the pause menu's Return to title goes too
const BOX=Rect2(196,452,760,116)   # the same text box as the flood talk and the rooms
const ASK=Rect2(396,236,360,176)   # the "Back to the title?" prompt, mid-screen
const TILE=16   # one tile (hollow/hollow_gen.gd TILE): how far behind the leader the partner walks
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
var hint_panel:PanelContainer
var view:SubViewport
var bank:Node2D
var textures:Dictionary={}
# Claude, 2026-10-22 (LP-09, FLOW-15): `line` is the partner's line on screen ("" when none) and the team
# holds still under it; the status label keeps narration only. `asking` is the "Back to the title?" prompt.
var line:=""
var face:="normal"
var partner_name:="Your partner"
var partner_tex:Texture2D
var asking:=false
var choice:=0
var _box:Node2D
var stepped:=false   # followers hold their spots until the leader's first step (Claude, 2026-10-22, LP-18)

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
		actor.position=leader+Vector2(0,i*TILE) if entrance or from_entrance or returning else Vector2(168,83) if i==0 else Vector2(222,84+i-1)
		Finish.apply(actor,false,form);view.add_child(actor);actors.append(actor)
		_set_texture(i,"s",-1)
	if party.size()>1:   # the partner's own name on its name plate, as the dawn walk reads it
		partner_name=load(Lines.of(party[1][0]).forms[party[1][1]][1]).creature_name
	# The trail starts as a line from the leader back to the last follower's spot, so each follower's place
	# (one tile per place in line) is where it already stands (Claude, 2026-10-22, LP-18).
	var tail:Vector2=actors[actors.size()-1].position
	for i in 80:trail.append(leader.lerp(tail,i/79.0))
	var shadows:=preload("res://scripts/ui/journey_shadows.gd").new()
	shadows.actors=actors;view.add_child(shadows)
	var canvas:=CanvasLayer.new();add_child(canvas)
	var heading:=_label("THE HOLLOW  /  RIVER APPROACH" if entrance else "RIVERBANK  /  THE FIRST ROUTE",30)
	heading.position=Vector2(36,20);canvas.add_child(heading)
	hint_panel=PanelContainer.new();hint_panel.position=Vector2(24,564);hint_panel.custom_minimum_size=Vector2(1104,66)
	var frame:=UI.frame("panel_dim").duplicate();frame.set_content_margin_all(18)
	hint_panel.add_theme_stylebox_override("panel",frame);canvas.add_child(hint_panel)
	hint=_label("",22);hint_panel.add_child(hint)
	status=_label("",22);status.position=Vector2(36,522);canvas.add_child(status)
	_box=Node2D.new();_box.draw.connect(_draw_talk);canvas.add_child(_box)
	_update_hint()
	# Claude, 2026-10-10 (Preston: the ruin and its stone path should rise out of the river, so the team is
	# the first to explore it): the first time, during the flood, it rises before the team can move.
	if not entrance and not from_entrance and not returning and not _mouth_beaten():
		# Still the flood night: the storm's rain keeps falling while the ruin comes up (Preston, 2026-10-11).
		var rain:=preload("res://scripts/effects/storm_rain.gd").new();rain.reduce_motion=reduce_motion
		view.add_child(rain)
		_rise()

func _rise()->void:
	leaving=true
	var r:=preload("res://scripts/ui/hollow_rise.gd").new()
	r.source=bank.background.texture.get_image();r.finish=bank.background.material;r.reduce_motion=reduce_motion
	view.add_child(r);view.move_child(r,bank.get_index()+1)
	status.text="The ground shakes. Something is coming up out of the river..."
	await r.play()
	status.text=""
	leaving=false
	_say("That wasn't there before! The water's still rising. Up the stones, now!","surprised")

func _mouth_beaten()->bool:
	return "mouth" in TeamState.data.get("beaten",[])

## A label on the type roles, as game_pause_menu._label does (Claude, 2026-10-22, LP-04): a size of 30 or
## more is a heading in the title face, anything smaller is prose in the body face, both on the pixel grid.
func _label(text:String,size:int)->Label:
	var role:="title" if size>=30 else UI.role_for(size)
	var l:=Label.new();l.text=text;l.add_theme_font_override("font",UI.font(role))
	l.add_theme_font_size_override("font_size",UI.type_size(role));l.add_theme_color_override("font_color",UI.TEXT)
	l.add_theme_color_override("font_shadow_color",UI.SHADOW)
	l.add_theme_constant_override("shadow_offset_x",int(UI.TYPE[role]["px"]));l.add_theme_constant_override("shadow_offset_y",int(UI.TYPE[role]["px"]))
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

## The point `dist` pixels back along the leader's trail (Claude, 2026-10-22, LP-18): measured in pixels, not
## frames, so the partner keeps one tile behind at 30 or 60 fps, and at the arch it stands behind the leader,
## never on the same spot.
func _trail_at(dist:float)->Vector2:
	var left:=dist
	for k in trail.size()-1:
		var step:=trail[k].distance_to(trail[k+1])
		if step>=left:return trail[k].lerp(trail[k+1],left/step) if step>0.0 else trail[k]
		left-=step
	return trail[trail.size()-1]

func _process(delta:float)->void:
	clock+=delta
	_box.queue_redraw()
	if leaving or asking or line!="":return
	var direction:=Input.get_vector("move_left","move_right","move_up","move_down")
	var moved:=false
	if direction.length()>0:
		var next:=leader+direction*48.0*delta
		if walkable(next):
			leader=next;moved=true;stepped=true
			trail.push_front(leader);trail.resize(80)
			facing="e" if direction.x>0.4 else "w" if direction.x< -0.4 else "n" if direction.y<0 else "s"
	for i in actors.size():
		var walking:=moved
		if i==0:actors[i].position=leader.round()
		else:
			var before:=actors[i].position
			if stepped:actors[i].position=actors[i].position.move_toward(_trail_at(i*TILE),48.0*delta).round()
			walking=actors[i].position!=before
		actors[i].z_index=int(actors[i].position.y)
		_set_texture(i,facing,int(clock*10)%8 if walking else -1)
	_update_hint()
	if entrance:
		if leader.distance_to(ARCH)<8 and not denied:_enter_arch()
	else:
		if leader.distance_to(WALKWAY)<10:_travel(true)

func _update_hint()->void:
	if entrance:
		hint.text="WASD / arrows  walk     Esc  return to riverbank"
		if leader.distance_to(ARCH)<30:hint.text="E / Enter  approach the arch     Esc  return to riverbank"
	elif not _mouth_beaten():
		# Claude, 2026-10-22 (LP-10): during the flood the hint says why Highbank is not on offer; no H key.
		hint.text="WASD / arrows  walk     The road to Highbank is under water. The stone walkway is the way."
		if leader.distance_to(HIGHBANK)<24:hint.text="E / Enter  try the south trail"
	else:
		hint.text="WASD / arrows  walk     Stone walkway to the Hollow     H  continue to Highbank"
		if leader.distance_to(HIGHBANK)<24:hint.text="E / Enter  take the south trail to Highbank"

func _unhandled_input(event:InputEvent)->void:
	if leaving:return
	if asking:
		_ask_input(event);return
	var accept:=event.is_action_pressed("interact") or event.is_action_pressed("ui_accept")
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if entrance:_travel(false)
		else:_ask()
	elif line!="":
		# A press under the partner's line shows the rest of it, then puts it away (Claude, 2026-10-22, LP-09).
		if accept:
			get_viewport().set_input_as_handled()
			if UI.line_done(line):_dismiss()
			else:UI.finish_line()
	elif accept:
		get_viewport().set_input_as_handled()
		if entrance and leader.distance_to(ARCH)<30:_enter_arch()
		elif not entrance and leader.distance_to(WALKWAY)<25:_travel(true)
		elif not entrance and leader.distance_to(HIGHBANK)<24:_town()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_H:
		# During the flood H does nothing; the hint says why (Claude, 2026-10-22, LP-10).
		if entrance or not _mouth_beaten():return
		get_viewport().set_input_as_handled();_town()

## The partner speaks in the shared box with its name and face (Claude, 2026-10-22, LP-09). The team holds
## still until the line is put away; the hint strip and the status narration step aside under it.
func _say(text:String,face_tag:="normal")->void:
	line=text;face=face_tag
	partner_tex=UI.dialogue_portrait(forms[1]+(":"+face if face!="normal" else "")) if forms.size()>1 else null
	status.visible=false;hint_panel.visible=false

func _dismiss()->void:
	line="";status.visible=true;hint_panel.visible=true

func _draw_talk()->void:
	if leaving:return
	if line!="":UI.dialogue(_box,BOX,partner_name,line,partner_tex,clock,20,face)
	if asking:
		UI.panel(_box,ASK,0.95,true)
		UI.say(_box,ASK.position+Vector2(36,48),"Back to the title?","body",UI.TEXT)
		for k in 2:
			var at:=ASK.position+Vector2(80,96+k*36)
			if k==choice:UI.say(_box,at-Vector2(28,0),">","button",UI.EDGE_LIGHT)
			UI.say(_box,at,["Resume","Return"][k],"button",UI.EDGE_LIGHT if k==choice else UI.MUTED)

## Esc on the bank: "Back to the title?" with Resume and Return (Claude, 2026-10-22, FLOW-15). The bank
## saves nothing of its own, so Return goes straight to the title.
func _ask()->void:
	asking=true;choice=0;UI.tick("open")

func _ask_close()->void:
	asking=false;UI.tick("cancel")

func _ask_input(event:InputEvent)->void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled();_ask_close()
	elif event.is_action_pressed("move_up") or event.is_action_pressed("move_down"):
		get_viewport().set_input_as_handled();choice=1-choice;UI.tick("cursor")
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if choice==0:_ask_close()
		else:_title()

## Return: a short fade to black on this scene's own layer, then the title (the flood talk fades the same way).
func _title()->void:
	leaving=true;UI.tick("confirm")
	var veil:=ColorRect.new();veil.size=Vector2(1152,648);veil.color=Color(0,0,0,0)
	veil.mouse_filter=Control.MOUSE_FILTER_IGNORE;_box.get_parent().add_child(veil)
	await create_tween().tween_property(veil,"color:a",1.0,0.15 if reduce_motion else 0.5).finished
	var error:=get_tree().change_scene_to_file(TITLE)
	if error!=OK:
		veil.queue_free();leaving=false;asking=false;status.text="The title could not open. Your team is still here."

func _travel(close_up:bool)->void:
	var scene:Node2D=load("res://scenes/hollow_entrance.tscn" if close_up else "res://scenes/waking_riverbank.tscn").instantiate()
	scene.party=party.duplicate(true);scene.reduce_motion=reduce_motion;scene.returning=returning
	scene.from_entrance=not close_up
	_change(scene,"Try the walkway again." if close_up else "Try again.")

func _enter_arch()->void:
	# Claude, 2026-10-10 (Preston: wake in the flood, retreat into the Hollow, a first dungeon with no boss):
	# until it is cleared, the arch is the retreat into the Hollow Mouth (dungeon.gd "mouth").
	if not _mouth_beaten():
		var refuge:Node2D=load("res://scenes/dungeon.tscn").instantiate()
		TeamState.give_to(refuge);refuge.party=party.duplicate(true)
		refuge.dungeon="mouth";refuge.return_to_town=true
		_change(refuge,"Try the arch again.");return
	# Existing pilot order stays intact: first training route, then the Warden's Hollow. After the Mouth the
	# way to the Hollow is Highbank's own (town/hollow_approach.gd) and nothing in the game reopens this
	# scene, only flood_opening_check with `returning`; the lines stay as that path's answer rather than
	# leave the arch dead (Claude, 2026-10-22, LP-10).
	if not "first" in TeamState.data.get("beaten",[]):
		denied=true;_say("Nope. Highbank first. Let's tell them what we found. We can come back together.","determined");return
	var dungeon:Node2D=load("res://scenes/dungeon.tscn").instantiate()
	TeamState.give_to(dungeon);dungeon.party=party.duplicate(true)
	dungeon.dungeon="hollow";dungeon.return_to_town=true
	_change(dungeon,"Try the arch again.")

func _town()->void:
	# Claude, 2026-10-10: during the flood the road to Highbank is under water; the walkway is the way out.
	if not _mouth_beaten():
		_say("The road's under water! The stone path, up to the ruin, now!","surprised");return
	# After the Mouth, Highbank is reached from the dawn walk (mouth_escape.gd); this scene is only reopened
	# by flood_opening_check with `returning`, and this is its way home (Claude, 2026-10-22, LP-10).
	var town:Node2D=load("res://scenes/hub_town.tscn").instantiate()
	TeamState.give_to(town);town.party=party.duplicate(true)
	_change(town,"Try the trail again.")

func _change(scene:Node,retry:String)->void:
	leaving=true
	var error:=get_tree().change_scene_to_node(scene)
	if error!=OK:
		scene.free();leaving=false;status.text="The route could not open. "+retry
