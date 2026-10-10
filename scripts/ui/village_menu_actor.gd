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
	_apply_village_light()
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

func _apply_village_light() -> void:
	# Keep the shared silhouette/detail finish, then light only these menu actors.
	# The same static palette treatment follows every frame; alpha is unchanged.
	var finish:=material as ShaderMaterial
	finish.set_shader_parameter("outline",Color("#302f21"))
	var lit:=Shader.new()
	var original:String=finish.shader.code
	const OUTPUT="COLOR = c * tint;"
	assert(original.contains(OUTPUT),"Shared creature finish output changed")
	lit.code=original.replace(OUTPUT,"""
	float value = luma(c.rgb);
	vec3 toned = mix(vec3(value), c.rgb, 0.72) * vec3(0.90, 0.84, 0.68);
	vec3 shade = vec3(0.18, 0.20, 0.13);
	vec3 ground = vec3(0.78, 0.65, 0.40);
	vec3 ambient = mix(shade, ground, smoothstep(0.05, 0.94, value));
	// Higher values pick up more ground warmth; charcoal retains its depth.
	c.rgb = mix(toned, ambient, mix(0.18, 0.38, value));
	// Quiet upper-bank light and reflected clay on the underside, in pixel bands.
	float rim = (1.0-step(0.5,n.a)) * step(0.5,c.a) * step(0.22,value);
	c.rgb += vec3(0.045,0.025,0.006) * rim;
	float bounce = step(0.63,UV.y) * step(0.5,c.a);
	c.rgb += vec3(0.018,0.010,0.002) * bounce;
	COLOR = vec4(c.rgb,c.a) * tint;
""")
	finish.shader=lit
