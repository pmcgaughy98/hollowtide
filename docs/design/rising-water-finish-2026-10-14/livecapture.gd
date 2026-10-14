extends SceneTree
const WORK := "D:/dev/hollowtide-rising-water-20261014/"
var dg: Node2D
func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
	for k in n: await process_frame
func capture(folder: String, name: String) -> void:
	dg._banner.at=-100000 # Private art review: keep the shoreline clear of the rise banner.
	await frames(3);await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(folder+name+"-game.png")
	var old_explored: PackedByteArray = dg.explored.duplicate()
	dg.explored.fill(1)
	var view := SubViewport.new();view.size=dg._map.texture.get_size();view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	var map := Sprite2D.new();map.centered=false;map.texture=dg._map.texture;map.material=dg._map.material;map.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;view.add_child(map)
	var fx := Node2D.new();view.add_child(fx)
	fx.draw.connect(func() -> void:
		var original: Node2D = dg._floor_fx
		dg._floor_fx=fx;dg._draw_water();dg._floor_fx=original)
	await frames(3);await RenderingServer.frame_post_draw
	view.get_texture().get_image().save_png(folder+name+"-native.png")
	view.queue_free();await frames(2);dg.explored=old_explored
func run() -> void:
	var folder := WORK+"live-captures/";DirAccess.make_dir_recursive_absolute(folder)
	root.size=Vector2i(1152,648)
	dg=load("res://scenes/dungeon.tscn").instantiate();dg.dungeon="hollow";dg.floor_seed=1;dg.poll_input=false;dg.party=[[0,0],[1,0]]
	root.add_child(dg);current_scene=dg;await frames(5)
	# Private framing: place the team on the dry bank so the rising row is in view.
	for k in [0,1]:
		dg.ents[k]["pos"]=Vector2i(32+k,17);dg._place(dg.ents[k])
	dg.cam_focus=Vector2(33*24,18*24-12);dg._reveal()
	await frames(60) # Let the normal camera easing settle on the shore before each comparison.
	for t in range(1,10):dg.turn=t;dg._end_turn()
	await capture(folder,"turn09-dry")
	dg.turn=10;dg._end_turn();await capture(folder,"turn10-first-rise")
	dg.turn=20;dg._end_turn();await capture(folder,"turn20-two-rows")
	dg.turn=30;dg._end_turn();await capture(folder,"turn30-ceiling")
	FileAccess.open(folder+"floor-data.bin",FileAccess.WRITE).store_var(dg.data)
	FileAccess.open(folder+"state.json",FileAccess.WRITE).store_string(JSON.stringify({"w":dg.data.w,"h":dg.data.h,"water_base":dg.water_base,"water_max":dg.water_max,"water_rows":dg.water_rows,"tiles":Array(dg.data.tiles)},"  "))
	var music:=root.get_node_or_null("HollowtideMusic")
	if music!=null:music.queue_free()
	dg.queue_free();await frames(4);print("WATER LIVE: dry, first rise, two rows and ceiling captured.");quit()
