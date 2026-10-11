extends SceneTree
const OUT := "D:/dev/hollowtide-hall-fixtures-20261011/review/before/"
const State := preload("res://scripts/town/team_state.gd")
func _initialize() -> void: _run.call_deferred()
func _frames(n: int) -> void:
	for k in n: await process_frame
func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	State.start([[0,0],[1,0]])
	State.data["story"]={"met_crew":true,"parcel":"stolen","guild_trial":true,"runner":true}
	for id in ["hall","hall_low","chamber","runners"]:
		var r := load("res://scenes/town_room.tscn").instantiate() as Node2D
		r.room_id=id;r.poll_input=false
		r.arrive={"hall":Vector2i(11,12),"hall_low":Vector2i(24,14),"chamber":Vector2i(8,8),"runners":Vector2i(1,5)}[id]
		root.add_child(r);await _frames(8)
		var map: Sprite2D
		for child in r._world.get_children():
			if child is Sprite2D and child.position==Vector2.ZERO:map=child
		var raw:=map.texture.get_image()
		raw.save_png(OUT+id+"_raw.png")
		var mask: Texture2D=map.material.get_shader_parameter("detail_mask")
		mask.get_image().save_png(OUT+id+"_mask.png")
		var v:=SubViewport.new();v.size=raw.get_size();v.render_target_update_mode=SubViewport.UPDATE_ALWAYS
		v.canvas_item_default_texture_filter=Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		root.add_child(v)
		var s:=Sprite2D.new();s.centered=false;s.texture=map.texture;s.material=map.material;v.add_child(s)
		await _frames(3);await RenderingServer.frame_post_draw
		v.get_texture().get_image().save_png(OUT+id+"_gpu.png")
		r.set_process(false)
		var rv:=r._world.get_parent() as SubViewport
		rv.size=raw.get_size();r._world.position=Vector2.ZERO
		await _frames(3);await RenderingServer.frame_post_draw
		rv.get_texture().get_image().save_png(OUT+id+"_room.png")
		v.queue_free();r.queue_free();await _frames(4)
	for child in root.get_children():child.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await _frames(16);quit()
