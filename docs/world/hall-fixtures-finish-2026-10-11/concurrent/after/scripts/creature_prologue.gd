extends Node2D
## Opening dialogue: meet the trainee mid-flood, retreat into the Hollow, then Highbank.
## Identity and party are passed into the existing town; no save/state rewrite.
## The lines live in dialogue/flood_bank.dialogue (Godot Dialogue Manager, Preston 2026-10-11: "it just needs a
## bit of refining"). Narration has no name and no portrait, the partner speaks with its own face, and the
## choices sit in a small list over the text box, the way the rooms' talk does (Claude, 2026-10-11).
const Finish=preload("res://scripts/arena/creature_finish.gd")
const UI=preload("res://scripts/ui/ui_style.gd")
const Music=preload("res://scripts/audio/music.gd")
const TALK=preload("res://dialogue/flood_bank.dialogue")
const FORMS=["kithflare","tallowroot","rimefin"]
const NAMES=["Kithflare","Tallowroot","Rimefin"]
const SENSES=["A warm spark at the end of your tail.","Roots curl against the damp clay.","Cool water runs along your fins."]
const BOX:=Rect2(196,452,760,116)   # the same text box as the town rooms
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
var first:=true         # Esc on the opening line goes back to the title
var _box:Node2D
var _clock:=0.0
var _keys_was:={}

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
	Music.play(get_tree(),"rising_water")   # the flood's theme (ElevenLabs, 2026-10-11); carries on through the riverbank
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

func _tapped(k:int) -> bool:
	var now:=Input.is_key_pressed(k)
	var was:bool=_keys_was.get(k,false)
	_keys_was[k]=now
	return now and not was

func _poll() -> void:
	if _tapped(KEY_E) or _tapped(KEY_J) or _tapped(KEY_ENTER) or _tapped(KEY_SPACE):
		advance()
	elif _tapped(KEY_ESCAPE) and first:
		get_tree().change_scene_to_file("res://scenes/creature_opening.tscn")
	elif not line.responses.is_empty() and UI.line_done(line.text):
		var d:=int(_tapped(KEY_S) or _tapped(KEY_DOWN))-int(_tapped(KEY_W) or _tapped(KEY_UP))
		if d!=0:
			choice=posmod(choice+d,line.responses.size())
			_sfx("cursor")

## E: show the rest of the line, then the next line (or the chosen answer's branch).
func advance() -> void:
	if leaving or line==null:return
	if not UI.line_done(line.text):
		UI.finish_line()
		return
	var next:=line.next_id
	if not line.responses.is_empty():
		next=line.responses[choice].next_id
		_sfx("confirm")
	first=false
	choice=0
	line=await DialogueManager.get_next_dialogue_line(TALK,next,[self])
	if line==null:
		_leave()

func _sfx(name:String) -> void:
	var path:="res://assets/audio/sfx/ui/%s.wav"%name
	if not ResourceLoader.exists(path):return
	var p:=AudioStreamPlayer.new()
	p.stream=load(path)
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

## The text box: narration with no name; a speaker with its portrait and face; choices in a small list
## above the box's right end once the line has typed out.
func _draw_talk() -> void:
	if line==null or leaving:return
	var form:=""
	var face:=line.tags[0] if not line.tags.is_empty() else "normal"
	if line.character!="":
		var i:=NAMES.find(line.character)
		if i>=0:form=FORMS[i]+(":"+face if face!="normal" else "")
	var tex:Texture2D=UI.dialogue_portrait(form) if form!="" else null
	UI.dialogue(_box,BOX,line.character,line.text,tex,_clock,20,face)
	if line.responses.is_empty() or not UI.line_done(line.text):return
	var rows:=line.responses.size()
	var r:=Rect2(BOX.end.x-260,BOX.position.y-34-rows*34,260,24+rows*34)
	UI.panel(_box,r,0.95)
	for k in rows:
		var at:=r.position+Vector2(44,34+k*34)
		if k==choice:
			UI.say(_box,at-Vector2(26,0),">","label",UI.EDGE_LIGHT)
		UI.say(_box,at,String(line.responses[k].text),"label",UI.EDGE_LIGHT if k==choice else UI.MUTED)

func _leave() -> void:
	leaving=true
	_box.queue_redraw()
	veil.mouse_filter=Control.MOUSE_FILTER_STOP
	await create_tween().tween_property(veil,"color:a",1.0,0.15 if reduce_motion else 0.5).finished
	# Preston, 2026-10-10: explore this bank and its close-up entrance immediately after choice.
	# The flood blocks Highbank; Claude's riverbank hooks open the boss-free Hollow Mouth.
	preload("res://scripts/town/team_state.gd").start([[hero,0],[partner,0]],{"creature_player":FORMS[hero],"opening_companion":FORMS[partner]})
	var dungeon:Node2D=load("res://scenes/waking_riverbank.tscn").instantiate()
	dungeon.reduce_motion=reduce_motion
	preload("res://scripts/town/team_state.gd").give_to(dungeon)
	var error:=get_tree().change_scene_to_node(dungeon)
	if error!=OK:
		dungeon.free();leaving=false
		veil.color.a=0;veil.mouse_filter=Control.MOUSE_FILTER_IGNORE
