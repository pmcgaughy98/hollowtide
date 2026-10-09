extends "res://scripts/opening_flow.gd"
## Creature-player launch. The approved dusk composition and settings remain.
const Finish = preload("res://scripts/arena/creature_finish.gd")
const PROLOGUE = preload("res://scenes/creature_prologue.tscn")
var companions: Array[Sprite2D] = []

func _build_characters() -> void:
	for i in 2:
		var actor := Sprite2D.new()
		var form := "kithflare" if i==0 else "tallowroot"
		actor.name = "CreatureLookout"+str(i)
		actor.texture=load("res://assets/sprites/arena/%s/small/se.png" % form)
		actor.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		actor.scale=Vector2.ONE*4
		var used:=actor.texture.get_image().get_used_rect()
		actor.offset.y=actor.texture.get_height()*0.5-used.end.y
		actor.set_meta("feet",Vector2(290+160*i,430+16*i))
		actor.set_meta("rest",actor.texture)
		actor.set_meta("rest_offset",actor.offset)
		var frames:Array[Texture2D]=[]
		var planted:=0.0
		for k in 8:
			var frame:Texture2D=load("res://assets/sprites/arena/%s/small/walk_se_f%d.png"%[form,k])
			frames.append(frame)
			planted=maxf(planted,frame.get_image().get_used_rect().end.y)
		actor.set_meta("walk",frames)
		actor.set_meta("planted",planted)
		actor.position=actor.get_meta("feet")
		Finish.apply(actor)
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
		var feet:Vector2=actor.get_meta("feet")
		actor.position=feet
		if not _reduce_motion and _boot_done and _time<2:
			actor.position.x-=roundf(90.0*maxf(0.0,1.0-_time/2.0))
			actor.texture=actor.get_meta("walk")[int(_time*8)%8]
			actor.offset.y=actor.texture.get_height()*0.5-float(actor.get_meta("planted"))
		else:
			actor.texture=actor.get_meta("rest")
			actor.offset=actor.get_meta("rest_offset")
