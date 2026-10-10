extends Sprite2D
## Dedicated menu animation frames: fixed canvas, planted anchor, shared menu clock.
var frames:Array[Texture2D]=[]
var feet:=Vector2.ZERO
var anchor:=Vector2.ZERO
var cycle:=3.2
var action_duration:=3.2
var phase:=0.0
var action_delay:=0.0

func setup(form:String,at:Vector2,meta:Dictionary) -> void:
	name=form.capitalize()+"VillageAnimation"
	feet=at
	anchor=Vector2(meta.anchor[0],meta.anchor[1])
	for i in int(meta.frame_count):
		frames.append(load("res://assets/sprites/menu/village_actors_2026_10_09/%s/frame_%02d.png"%[form,i]))
	texture=frames[0]
	set_meta("rest",texture)
	set_meta("feet",feet)
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	centered=false
	scale=Vector2.ONE*2
	position=(feet-anchor*scale).round()
	preload("res://scripts/arena/creature_finish.gd").apply(self)
	if form=="punchybun":
		cycle=5.6
		action_duration=1.2
		action_delay=1.0
	else:
		cycle=3.2
		action_duration=3.2
		phase=0.55

func pose(clock:float,still:bool) -> void:
	var index:=0
	if not still:
		var local:=fposmod(clock+phase,cycle)-action_delay
		if local>=0 and local<action_duration:
			index=mini(frames.size()-1,int(local/action_duration*frames.size()))
	texture=frames[index]
	position=(feet-anchor*scale).round()
