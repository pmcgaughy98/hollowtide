extends SceneTree
const W := "D:/dev/hollowtide-new-scene-selout-20261010/"
var fails := 0
func _initialize() -> void: run.call_deferred()
func frames(n:int) -> void:
	for k in n:await process_frame
func run() -> void:
	var out:=W+"review/scene-portraits/"
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"):out=W+"review/live-scene-portraits/"
	DirAccess.make_dir_recursive_absolute(out)
	load("res://scripts/town/team_state.gd").start([[0,0],[1,0]])
	for place in ["hub_town","dungeon"]:
		var scene:Node2D=load("res://scenes/"+place+".tscn").instantiate()
		scene.poll_input=false
		if place=="dungeon":scene.floor_seed=4242
		root.add_child(scene)
		await frames(8)
		for form in ["gruntle:angry","starward:worried"]:
			scene.talk=[[form.get_slice(":",0).capitalize(),"Portrait finish verification.",form]]
			await frames(5)
			var layer:Node2D=scene._hud.get_node("CrewPortraitFinish")
			var ok:bool=layer.draws.size()==1 and layer.sprites[0].visible and layer.sprites[0].texture.resource_path.ends_with(form.replace(":","_")+".png")
			if not ok:fails+=1
			print("SCENE ",place," ",form," -> ","ok" if ok else "FAIL")
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(out+place+"-"+form.replace(":","-")+".png")
			scene.talk=[]
			await frames(3)
			if layer.sprites[0].visible:fails+=1
		scene.queue_free()
		await frames(8)
	for child in root.get_children():child.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await frames(12)
	print("PORTRAIT SCENES ","PASS" if fails==0 else "FAIL")
	quit(0 if fails==0 else 1)
