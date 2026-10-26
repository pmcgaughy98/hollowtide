extends Node2D
## Opening dialogue: meet the trainee mid-flood, retreat into the Hollow, then Highbank.
## Identity and party are passed into the existing town; no save/state rewrite.
## The lines live in dialogue/flood_bank.dialogue (Godot Dialogue Manager, Preston 2026-10-11: "it just needs a
## bit of refining"). Narration has no name and no portrait, the partner speaks with its own face, and the
## choices sit in a small list over the text box, the way the rooms' talk does (Claude, 2026-10-11).
## Esc on any line asks "Back to the title?" before leaving, and the menu sounds come from UI.tick on the
## "UI" bus (Claude, 2026-10-22, FLOW-15 and FEEL-08).
const Finish=preload("res://scripts/arena/creature_finish.gd")
const UI=preload("res://scripts/ui/ui_style.gd")
const Music=preload("res://scripts/audio/music.gd")
const TALK=preload("res://dialogue/flood_bank.dialogue")
const TITLE="res://scenes/creature_opening.tscn"   # where the pause menu's Return to title goes too
const FORMS=["kithflare","tallowroot","rimefin"]
const NAMES=["Kithflare","Tallowroot","Rimefin"]
const SENSES=["A warm spark at the end of your tail.","Roots curl against the damp clay.","Cool water runs along your fins."]
const BOX:=Rect2(196,452,760,116)   # the same text box as the town rooms
const ASK:=Rect2(396,236,360,176)   # the "Back to the title?" prompt, mid-screen
var reduce_motion:=false
var chosen_by_soul:=false # the soul prologue already chose the starter (Claude, 2026-10-10)
var hero:=0
var partner:=1
var leaving:=false
var leader_sprite:Sprite2D
var partner_sprite:Sprite2D
var veil:ColorRect
var bank:Node2D
var flood_cover:Node2D
var line:DialogueLine   # the line on screen; null when the talk is over
var choice:=0           # the highlighted choice, when the line has some
var asking:=false       # the "Back to the title?" prompt is up (Claude, 2026-10-22, FLOW-15)
var ask_row:=0          # its highlighted row: 0 Resume, 1 Return
var _box:Node2D
var _clock:=0.0

# Read by the dialogue file ({{...}}).
var sense:String:
	get: return SENSES[hero]
var partner_name:String:
	get: return NAMES[partner]
var name_a:String:
	get: return NAMES[_others()[0]]
var name_b:String:
	get: return NAMES[_others()[1]]
var starter_0:String:
	get: return NAMES[0]
var starter_1:String:
	get: return NAMES[1]
var starter_2:String:
	get: return NAMES[2]

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
	# Keep the ruin/path submerged through partner choice. Claude's journey owns the actual rise.
	flood_cover=preload("res://scripts/ui/hollow_rise.gd").new()
	flood_cover.source=bank.background.texture.get_image()
	flood_cover.finish=bank.background.material
	flood_cover.reduce_motion=reduce_motion
	vp.add_child(flood_cover)
	flood_cover.set_process(false)
	leader_sprite=actor(vp,Vector2(168,83))
	partner_sprite=actor(vp,Vector2(222,84))
	partner_sprite.hide()
	bank.companion_visible=false
	set_form(leader_sprite,hero)
	var ui:=CanvasLayer.new()
	add_child(ui)
	_box=Node2D.new()
	_box.draw.connect(_draw_talk)
	ui.add_child(_box)
	veil=ColorRect.new()
	veil.size=Vector2(1152,648)
	veil.color=Color(0,0,0,0)
	veil.mouse_filter=Control.MOUSE_FILTER_IGNORE
	ui.add_child(veil)
	partner=_others()[0]
	# No music on the bank for now, only the storm (Preston, 2026-10-11: the music "would kill that ambience").
	# Rising Water stays installed for later. An empty name fades out whatever the soul scene was playing.
	Music.play(get_tree(),"")
	var rain:=preload("res://scripts/effects/storm_rain.gd").new()
	rain.reduce_motion=reduce_motion
	vp.add_child(rain)
	line=await DialogueManager.get_next_dialogue_line(TALK,"start",[self])

func actor(parent:Node,at:Vector2) -> Sprite2D:
	var s:=Sprite2D.new()
	s.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	s.position=at
	s.z_index=int(at.y)
	Finish.apply(s)
	parent.add_child(s)
	return s

func set_form(s:Sprite2D,index:int) -> void:
	s.texture=load("res://assets/sprites/arena/%s/small/s.png"%FORMS[index])
	var used:=s.texture.get_image().get_used_rect()
	s.offset.y=s.texture.get_height()*0.5-used.end.y

## The two starters the soul did not take.
func _others() -> Array:
	return [0,1,2].filter(func(i:int) -> bool: return i!=hero)

## Called from the dialogue file.
func pick_hero(i:int) -> void:
	hero=i
	set_form(leader_sprite,hero)
	partner=_others()[0]

func pick_partner(k:int) -> void:
	partner=_others()[k]
	set_form(partner_sprite,partner)
	partner_sprite.show()
	bank.companion_visible=true
	bank.queue_redraw()

func _process(delta:float) -> void:
	if not reduce_motion:_clock+=delta
	if not leaving and line!=null:_poll()
	_box.queue_redraw()

## Actions, not keys (Claude, 2026-10-23, factory pass 2): the next line is E, J, Enter or Space as before, or A or
## X on a pad; Esc or B asks about the title; up and down (W, S, the arrows, the D-pad, the stick) move the choice.
func _poll() -> void:
	if asking:
		_poll_ask()
	elif UI.tapped_any(UI.INPUT_ADVANCE):
		advance()
	elif UI.tapped("cancel"):
		_ask()
	elif not line.responses.is_empty() and UI.line_done(line.text):
		var d:=int(UI.tapped("move_down"))-int(UI.tapped("move_up"))
		if d!=0:
			choice=posmod(choice+d,line.responses.size())
			UI.tick("cursor")

## E: show the rest of the line, then the next line (or the chosen answer's branch).
func advance() -> void:
	if leaving or line==null:return
	if not UI.line_done(line.text):
		UI.finish_line()
		return
	var next:=line.next_id
	if not line.responses.is_empty():
		next=line.responses[choice].next_id
		UI.tick("confirm")
	choice=0
	line=await DialogueManager.get_next_dialogue_line(TALK,next,[self])
	if line==null:
		_leave()

## Esc on any line: "Back to the title?" with Resume and Return (Claude, 2026-10-22, FLOW-15). Nothing is
## saved yet, so Return simply starts the opening over.
func _ask() -> void:
	asking=true
	ask_row=0
	UI.tick("open")

func _poll_ask() -> void:
	if UI.tapped("cancel"):
		asking=false
		UI.tick("cancel")
	elif UI.tapped_any(["move_down","move_up"]):
		ask_row=1-ask_row
		UI.tick("cursor")
	elif UI.tapped_any(UI.INPUT_ADVANCE):
		if ask_row==0:
			asking=false
			UI.tick("cancel")
		else:
			_title()

func _title() -> void:
	leaving=true
	UI.tick("confirm")
	veil.mouse_filter=Control.MOUSE_FILTER_STOP
	await create_tween().tween_property(veil,"color:a",1.0,0.15 if reduce_motion else 0.5).finished
	var error:=get_tree().change_scene_to_file(TITLE)
	if error!=OK:
		leaving=false
		asking=false
		veil.color.a=0;veil.mouse_filter=Control.MOUSE_FILTER_IGNORE

## The text box: narration with no name; a speaker with its portrait and face; choices in a small list
## above the box's right end once the line has typed out; the title prompt over everything when it is up.
func _draw_talk() -> void:
	if line==null or leaving:return
	var form:=""
	var face:=line.tags[0] if not line.tags.is_empty() else "normal"
	if line.character!="":
		var i:=NAMES.find(line.character)
		if i>=0:form=FORMS[i]+(":"+face if face!="normal" else "")
	var tex:Texture2D=UI.dialogue_portrait(form) if form!="" else null
	UI.dialogue(_box,BOX,line.character,line.text,tex,_clock,20,face)
	if not line.responses.is_empty() and UI.line_done(line.text):
		_draw_choices()
	if asking:
		_draw_ask()

## The answers in the line's own face and size (Claude, 2026-10-24, pass 6 S4, LO6-15 and LV-27): the story role at
## the line's pixel scale, one answer to a row at the line's row height, the list as wide as its longest answer and
## clear of the text box. The words do not change.
func _draw_choices() -> void:
	var rows:=line.responses.size()
	var pitch:=UI.font("story").get_height(UI.type_size("story"))   # 40, the line's own row height
	var w:=0.0
	for k in rows:w=maxf(w,UI.width_in(String(line.responses[k].text),"story"))
	var width:=ceilf((w+72.0)*0.5)*2.0   # 44 for the cursor, 28 to the right edge, kept even for the 2x grid
	var tall:=34.0+rows*pitch
	var r:=Rect2(BOX.end.x-width,BOX.position.y-10-tall,width,tall)
	UI.panel(_box,r,0.95)
	for k in rows:
		var at:=r.position+Vector2(44,44+k*pitch)   # the first row's baseline as far down as the box's first line
		if k==choice:
			UI.say(_box,at-Vector2(26,0),">","story",UI.EDGE_LIGHT)
		UI.say(_box,at,String(line.responses[k].text),"story",UI.EDGE_LIGHT if k==choice else UI.MUTED)

func _draw_ask() -> void:
	UI.panel(_box,ASK,0.95,true)
	UI.say(_box,ASK.position+Vector2(36,48),"Back to the title?","body",UI.TEXT)
	for k in 2:
		var at:=ASK.position+Vector2(80,96+k*36)
		if k==ask_row:
			UI.say(_box,at-Vector2(28,0),">","button",UI.EDGE_LIGHT)
		UI.say(_box,at,["Resume","Return"][k],"button",UI.EDGE_LIGHT if k==ask_row else UI.MUTED)

## The room-door fade (Claude, 2026-10-24, pass 6 S1, L6-13): UI's shared black comes down over 0.2 s, the riverbank
## is built under it, and the riverbank lifts the black two frames after it is built (riverbank_journey.gd
## _lift_black, as town_room.gd go_room does), so it no longer pops in from black at full brightness. A check that adds
## this scene as a plain child changes at once.
func _leave() -> void:
	leaving=true
	_box.queue_redraw()
	veil.mouse_filter=Control.MOUSE_FILTER_STOP
	var tree:=get_tree()
	var faded:=tree.current_scene==self
	if faded:await UI.fade_out(tree)
	# Preston, 2026-10-10: explore this bank and its close-up entrance immediately after choice.
	# The flood blocks Highbank; Claude's riverbank hooks open the boss-free Hollow Mouth.
	preload("res://scripts/town/team_state.gd").start([[hero,0],[partner,0]],{"creature_player":FORMS[hero],"opening_companion":FORMS[partner]})
	var dungeon:Node2D=load("res://scenes/waking_riverbank.tscn").instantiate()
	dungeon.reduce_motion=reduce_motion
	preload("res://scripts/town/team_state.gd").give_to(dungeon)
	var error:=tree.change_scene_to_node(dungeon)
	if error!=OK:
		dungeon.free();leaving=false
		veil.color.a=0;veil.mouse_filter=Control.MOUSE_FILTER_IGNORE
		if faded:UI.fade_in(tree)
