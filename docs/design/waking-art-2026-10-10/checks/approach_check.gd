extends SceneTree
const W="D:/dev/hollowtide-waking-art-20261010/"
var fails:=0
func _initialize()->void:run.call_deferred()
func frames(n:int)->void:
	for k in n:await process_frame
func check(ok:bool,text:String)->void:
	if not ok:fails+=1
	print("PASS " if ok else "FAIL ",text)
func run()->void:
	root.size=Vector2i(1152,648)
	var state:Script=load("res://scripts/town/team_state.gd")
	state.start([[0,0],[1,0]]);state.data["beaten"]=["first"]
	var scene:Node=load("res://scenes/hollow_approach.tscn").instantiate();scene.reduce_motion=true
	change_scene_to_node(scene)
	for frame in 400:
		await process_frame
		if scene.ready_to_cross:break
	check(scene.ready_to_cross,"Claude route reaches its original walkway confirmation")
	check(scene.entrance.texture_filter==CanvasItem.TEXTURE_FILTER_NEAREST and scene.entrance.scale==Vector2.ONE,"close-up uses native nearest art in preserved cinematic")
	check(scene.entrance.material is ShaderMaterial and scene.entrance.material.get_shader_parameter("detail_ink")==0.55,"Claude entrance has shared structure finish")
	var out:=W+"review/live/" if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/") else W+"review/after/"
	DirAccess.make_dir_recursive_absolute(out)
	await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(out+"claude-walkway.png")
	scene._cross()
	for frame in 120:
		await process_frame
		if scene.stop=="entrance":break
	await frames(60);await RenderingServer.frame_post_draw
	if current_scene==scene:root.get_texture().get_image().save_png(out+"claude-entrance-walk.png")
	for frame in 240:
		await process_frame
		if current_scene!=null and current_scene.scene_file_path.ends_with("dungeon.tscn"):break
	check(current_scene!=null and current_scene.scene_file_path.ends_with("dungeon.tscn") and current_scene.dungeon=="hollow","original cinematic walk/cross/door/fade enters Hollow")
	for n in root.get_children():n.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await frames(12);print("APPROACH ART ","PASS" if fails==0 else "FAIL");quit(0 if fails==0 else 1)
