extends Node2D
## Walkable presentation between partner choice and Highbank. No turns, rewards or new save fields.
## Preston: the walkway opens a separate close-up scene immediately after partner choice.
## Claude, 2026-10-22 (factory pass, lane 6): the partner's lines go through the shared text box with its
## name and face, Esc asks before going back to the title, the labels sit on the type roles, and the
## partner walks one tile behind the leader.
## Claude, 2026-10-23 (factory pass 3, story lane): a place card that fades instead of the corner heading, the
## narration in the text box, the keys on Highbank's bottom-right strip, the partner a full step behind, and the
## Hollow loaded during the walk with the screen black before it is built.
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
const TILE=16   # one tile (hollow/hollow_gen.gd TILE): the least a follower stands behind the one ahead
const TRAIL=160   # trail points kept, about a pixel apart: room for three followers at any frame rate
const DUNGEON="res://scenes/dungeon.tscn"   # loaded on a thread while the team walks to the arch (S7)
# The place card (S1): the floor card's gold (dungeon.gd CARD_COL) in the title face, mid-screen, gone by 2.5 s.
# Preston's call P4 picks the words; until then they are the first halves of the old corner headings.
const PLACE_BANK="RIVERBANK"
const PLACE_ARCH="THE HOLLOW"
const CARD_COL=Color(0.95,0.85,0.6)
const PLACE_Y=300.0
# Claude, 2026-10-24 (pass 4 T9, LV-24): the ruin's card sits above the arch, over the ruin's top, so the walk up
# to the arch never passes under it (mid-screen it covered the leader). Same words (Preston's call Q2).
const PLACE_Y_ARCH=96.0
const PLACE_SECS=2.5
const PLACE_FADE=0.6
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
# Claude, 2026-10-23 (S2): narration ("The ground shakes...", a route that would not open) goes in the text box
# with no name plate; the keys sit on a small strip at the bottom right, as on Highbank's streets.
var narration:=""
var follow:Array[Vector2]=[]   # each follower's spot before it is rounded to the pixel (S6)
var step:=float(TILE)          # how far behind the one ahead each follower walks (S6, set in _ready)
var view:SubViewport
var bank:Node2D
var textures:Dictionary={}
# Claude, 2026-10-22 (LP-09, FLOW-15): `line` is the partner's line on screen ("" when none) and the team
# holds still under it; narration has its own `narration` (2026-10-23). `asking` is the "Back to the title?" prompt.
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
		# The Hollow is read from disk on a thread while the team walks up; the arch takes it (S7).
		ResourceLoader.load_threaded_request(DUNGEON)
	else:
		bank=Bank.new();bank.reduce_motion=reduce_motion;bank.show_actor_shadows=false
		view.add_child(bank)
		if from_entrance or returning:leader=Vector2(216,98)
	for i in party.size():
		var form:String=Lines.of(party[i][0]).forms[party[i][1]][0]
		forms.append(form)
		var actor:=Sprite2D.new();actor.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		Finish.apply(actor,false,form);view.add_child(actor);actors.append(actor)
		_set_texture(i,"s",-1)
	step=_follow_step()
	for i in actors.size():
		actors[i].position=leader+Vector2(0,i*step) if entrance or from_entrance or returning else Vector2(168,83) if i==0 else Vector2(222,84+i-1)
		follow.append(actors[i].position)
	if party.size()>1:   # the partner's own name on its name plate, as the dawn walk reads it
		partner_name=load(Lines.of(party[1][0]).forms[party[1][1]][1]).creature_name
	# The trail starts as a line from the leader back to the last follower's spot, so each follower's place
	# (one tile per place in line) is where it already stands (Claude, 2026-10-22, LP-18).
	var tail:Vector2=actors[actors.size()-1].position
	for i in 80:trail.append(leader.lerp(tail,i/79.0))
	var shadows:=preload("res://scripts/ui/journey_shadows.gd").new()
	shadows.actors=actors;view.add_child(shadows)
	var canvas:=CanvasLayer.new();add_child(canvas)
	_box=Node2D.new();_box.draw.connect(_draw_talk);canvas.add_child(_box)
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
	narration="The ground shakes. Something is coming up out of the river..."
	await r.play()
	narration=""
	leaving=false
	_say("That wasn't there before! The water's still rising. Up the stones, now!","surprised")

func _mouth_beaten()->bool:
	return "mouth" in TeamState.data.get("beaten",[])

## The place card (Claude, 2026-10-23, S1): the floor card's look on the art, the place's name in the title face in
## the floor card's gold over a dark band that softens in three steps (no ruled line), held, then faded out by
## PLACE_SECS. It replaces the corner heading that stayed on screen the whole time.
func _draw_place()->void:
	var a:=1.0 if clock<PLACE_SECS-PLACE_FADE else clampf((PLACE_SECS-clock)/PLACE_FADE,0.0,1.0)
	if a<=0.0:return
	var y:=place_rect().get_center().y
	for k in 3:
		var grow:=8.0*k
		_box.draw_rect(Rect2(0,y-28-grow,1152,56+grow*2),Color(0,0,0,0.22*a))
	UI.say(_box,Vector2(0,y+16),PLACE_ARCH if entrance else PLACE_BANK,"title",Color(CARD_COL,a),1152,HORIZONTAL_ALIGNMENT_CENTER)

## The card's band at its widest, in screen pixels (the checks read it).
func place_rect()->Rect2:
	var y:=PLACE_Y_ARCH if entrance else PLACE_Y
	return Rect2(0,y-44,1152,88)

## One full step (Claude, 2026-10-23, S6): the tallest or widest standing sprite and two pixels, never under a tile,
## so a follower straight behind the leader never has its head over the leader's feet (at a tile they overlapped).
func _follow_step()->float:
	var size:=0
	for a in actors:
		if a.texture!=null:
			var used:=a.texture.get_image().get_used_rect()
			size=maxi(size,maxi(used.size.x,used.size.y))
	return maxf(TILE,size+2)

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
		var seg:=trail[k].distance_to(trail[k+1])
		if seg>=left:return trail[k].lerp(trail[k+1],left/seg) if seg>0.0 else trail[k]
		left-=seg
	return trail[trail.size()-1]

## The leader's new spot onto the trail, about a pixel from the last (Claude, 2026-10-23, S6), so the trail's length
## is the same at any frame rate. When the leader turns back into the line, the trail is laid out straight from the
## leader through the first follower instead, so the followers step back to their places rather than meet the
## leader on the way (the old trail ran back through the leader's own spot).
func _lay_trail()->void:
	if actors.size()>1 and leader.distance_to(follow[1])<step*0.85:
		var away:=follow[1]-leader
		away=away.normalized() if away.length()>0.5 else Vector2.DOWN
		trail.clear()
		for k in int(step*actors.size())+2:trail.append(leader+away*k)
	elif trail.size()>1 and trail[0].distance_to(trail[1])<1.0:trail[0]=leader
	else:
		trail.push_front(leader);trail.resize(TRAIL)

func _process(delta:float)->void:
	clock+=delta
	_box.queue_redraw()
	if leaving or asking or line!="":return
	# The step from UI.dir8 (Claude, 2026-10-23, factory pass 2): keys walk as before (a diagonal at the same speed),
	# and the D-pad or stick walks the eight ways Highbank's streets do.
	var direction:=Vector2(UI.dir8()).normalized()
	var moved:=false
	if direction.length()>0:
		var next:=leader+direction*48.0*delta
		if walkable(next):
			leader=next;moved=true;stepped=true
			_lay_trail()
			facing="e" if direction.x>0.4 else "w" if direction.x< -0.4 else "n" if direction.y<0 else "s"
	for i in actors.size():
		var walking:=moved
		if i==0:actors[i].position=leader.round()
		else:
			# Kept unrounded and drawn rounded (Claude, 2026-10-23): rounding the kept spot each frame held a
			# follower still whenever its step was under half a pixel, as on a 144 Hz screen.
			var before:=follow[i]
			var spot:=_trail_at(i*step)
			if stepped and walkable(spot):follow[i]=follow[i].move_toward(spot,60.0*delta)   # a little quicker than the leader, to take its place back
			walking=follow[i].distance_to(before)>0.01
			actors[i].position=follow[i].round()
		actors[i].z_index=int(actors[i].position.y)
		_set_texture(i,facing,int(clock*10)%8 if walking else -1)
	if entrance:
		if leader.distance_to(ARCH)<8 and not denied:_enter_arch()
	else:
		if leader.distance_to(WALKWAY)<10:_travel(true)

## Claude, 2026-10-23 (factory pass 2): the hint's keys come from the bindings, the same words as before on a
## keyboard ("WASD / arrows", "E / Enter", "Esc") and the pad's when a pad was used last. H has no pad button, so
## a pad's hint leaves it out; the south trail's own prompt still takes the team to Highbank.
## Claude, 2026-10-23 (factory pass 3, S2): the same words, one line each, for the strip at the bottom right.
func key_lines()->Array[String]:
	var walk:=_walk_keys()+"  walk"
	var use:=_use_keys()
	var back:=UI.binding_text("cancel")+"  return to riverbank"
	if entrance:
		if leader.distance_to(ARCH)<30:return [use+"  approach the arch",back]
		return [walk,back]
	if not _mouth_beaten():
		# Claude, 2026-10-22 (LP-10): during the flood the hint says why Highbank is not on offer; no H key.
		if leader.distance_to(HIGHBANK)<24:return [use+"  try the south trail"]
		return [walk,"The road to Highbank is under water.","The stone walkway is the way."]
	if leader.distance_to(HIGHBANK)<24:return [use+"  take the south trail to Highbank"]
	var lines:Array[String]=[walk,"Stone walkway to the Hollow"]
	if UI.last_device()!="pad":lines.append("H  continue to Highbank")
	return lines

## The keys on a label-role strip in the panel frame, bottom right, as Highbank's streets draw theirs
## (hub_town.gd _draw_key_strip): sized to its longest line, its foot where Highbank's is.
func _draw_keys()->void:
	var lines:=key_lines()
	var w:=0.0
	for s in lines:w=maxf(w,UI.width_in(s,"label"))
	var tall:=22.0+20.0*lines.size()
	var strip:=Rect2(Vector2(1146-w-40,600-tall),Vector2(w+40,tall))
	UI.panel(_box,strip,0.85)
	for k in lines.size():
		UI.say(_box,strip.position+Vector2(20,26+20*k),lines[k],"label",Color(UI.MUTED,0.95))

## "WASD / arrows" with the default keys (the letters as this keyboard prints them), "D-pad / Left stick" on a pad.
func _walk_keys()->String:
	var dirs:=["move_up","move_left","move_down","move_right"]
	var out:=PackedStringArray()
	if UI.last_device()=="pad":
		for b in UI.binding_text("move_up","pad",true).split(" / ",false):out.append(b.trim_suffix(" Up"))
		return " / ".join(out)
	var letters:=""
	var arrows:=0
	for k in dirs.size():
		for b in UI.binding_text(dirs[k],"keyboard",true).split(" / ",false):
			if b==["Up","Left","Down","Right"][k]:arrows+=1
			elif b.length()==1 and letters.length()==k:letters+=b
	if letters.length()==4:out.append(letters)
	if arrows==4:out.append("arrows")
	if out.is_empty():   # rebound past both sets: the first key of each way
		for a in dirs:out.append(UI.binding_text(a,"keyboard"))
		return " ".join(out)
	return " / ".join(out)

## "E / Enter" on a keyboard (interact, then ui_accept's first key), "A" on a pad.
func _use_keys()->String:
	if UI.last_device()=="pad":return UI.binding_text("confirm","pad")
	var out:=PackedStringArray()
	for a in ["interact","ui_accept"]:
		var t:=UI.binding_text(a,"keyboard")
		if t!="" and not out.has(t):out.append(t)
	return " / ".join(out)

## A press that uses what is ahead or moves the partner's line on (Claude, 2026-10-23, factory pass 2): E, Enter or
## Space as before (the number pad's Enter too, through ui_accept), J now as in the dungeon, A or X on a pad.
func _accept(event:InputEvent)->bool:
	for a in UI.INPUT_ADVANCE+["ui_accept"]:
		if UI.pressed(event,a):return true
	return false

func _unhandled_input(event:InputEvent)->void:
	if leaving:return
	if asking:
		_ask_input(event);return
	var accept:=_accept(event)
	if UI.pressed(event,"cancel"):
		get_viewport().set_input_as_handled()
		if entrance:_travel(false)
		else:_ask()
	elif line!="":
		# A press under the partner's line shows the rest of it, then puts it away (Claude, 2026-10-22, LP-09).
		if accept:
			get_viewport().set_input_as_handled()
			if UI.line_done(line):_dismiss()
			else:UI.finish_line()
	elif narration!="" and accept:
		# A notice in the box (a route that would not open) goes the same way (Claude, 2026-10-23, S2).
		get_viewport().set_input_as_handled()
		if UI.line_done(narration):narration=""
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
## still until the line is put away; the key strip steps aside under it.
func _say(text:String,face_tag:="normal")->void:
	line=text;face=face_tag
	partner_tex=UI.dialogue_portrait(forms[1]+(":"+face if face!="normal" else "")) if forms.size()>1 else null

func _dismiss()->void:
	line=""

## The place card, then the box: the partner's line with its name and face, or narration with no name plate and no
## face (Claude, 2026-10-23, S2), or else the key strip. While the ruin rises the narration stays up.
func _draw_talk()->void:
	_draw_place()
	if leaving:
		if narration!="":UI.dialogue(_box,BOX,"",narration,null,clock,20)
		return
	if line!="":UI.dialogue(_box,BOX,partner_name,line,partner_tex,clock,20,face)
	elif narration!="":UI.dialogue(_box,BOX,"",narration,null,clock,20)
	else:_draw_keys()
	if asking:
		UI.panel(_box,ASK,0.95,true)
		UI.say(_box,ASK.position+Vector2(36,48),"Back to the title?","label",UI.TEXT)   # the prompts' label face (pass 4 T10)
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
	if UI.pressed(event,"cancel"):
		get_viewport().set_input_as_handled();_ask_close()
	elif UI.pressed(event,"move_up") or UI.pressed(event,"move_down"):
		get_viewport().set_input_as_handled();choice=1-choice;UI.tick("cursor")
	elif _accept(event):
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
		veil.queue_free();leaving=false;asking=false;narration="The title could not open. Your team is still here."

func _travel(close_up:bool)->void:
	var scene:Node2D=load("res://scenes/hollow_entrance.tscn" if close_up else "res://scenes/waking_riverbank.tscn").instantiate()
	scene.party=party.duplicate(true);scene.reduce_motion=reduce_motion;scene.returning=returning
	scene.from_entrance=not close_up
	_change(scene,"Try the walkway again." if close_up else "Try again.")

func _enter_arch()->void:
	# Claude, 2026-10-10 (Preston: wake in the flood, retreat into the Hollow, a first dungeon with no boss):
	# until it is cleared, the arch is the retreat into the Hollow Mouth (dungeon.gd "mouth").
	if not _mouth_beaten():
		_into_hollow("mouth");return
	# Existing pilot order stays intact: first training route, then the Warden's Hollow. After the Mouth the
	# way to the Hollow is Highbank's own (town/hollow_approach.gd) and nothing in the game reopens this
	# scene, only flood_opening_check with `returning`; the lines stay as that path's answer rather than
	# leave the arch dead (Claude, 2026-10-22, LP-10).
	if not "first" in TeamState.data.get("beaten",[]):
		denied=true;_say("Nope. Highbank first. Let's tell them what we found. We can come back together.","determined");return
	_into_hollow("hollow")

## Through the arch (Claude, 2026-10-23, S7): the screen fades to black first, then the Hollow loaded during the
## walk is taken and built, so the long build sits under black instead of a frozen last frame; the black lifts off
## the first floor (as hub_town.gd _leave_to does). A check that adds this scene as a plain child changes at once.
func _into_hollow(which:String)->void:
	leaving=true
	var tree:=get_tree()
	var faded:=tree.current_scene==self
	if faded:await UI.fade_out(tree)
	var dungeon:Node2D=_hollow_scene().instantiate()
	TeamState.give_to(dungeon);dungeon.party=party.duplicate(true)
	dungeon.dungeon=which;dungeon.return_to_town=true
	var error:=tree.change_scene_to_node(dungeon)
	if error!=OK:
		dungeon.free();leaving=false;narration="The route could not open. Try the arch again."
	if faded:UI.fade_in(tree)

## The scene the walk started loading, or a plain load when that never started or failed.
func _hollow_scene()->PackedScene:
	if ResourceLoader.load_threaded_get_status(DUNGEON)!=ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		var res:=ResourceLoader.load_threaded_get(DUNGEON)
		if res is PackedScene:return res
	return load(DUNGEON)

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
		scene.free();leaving=false;narration="The route could not open. "+retry
