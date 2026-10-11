extends SceneTree
const W="D:/dev/hollowtide-waking-art-20261010/"
const Finish=preload("res://scripts/arena/creature_finish.gd")
var fails:=0
func _initialize()->void:run.call_deferred()
func frames(n:int)->void:
	for k in n:await process_frame
func check(ok:bool,text:String)->void:
	if not ok:fails+=1
	print("PASS " if ok else "FAIL ",text)
func run()->void:
	root.size=Vector2i(1152,648)
	load("res://scripts/town/team_state.gd").start([[6,2],[0,0]])
	var town:Node2D=load("res://scenes/hub_town.tscn").instantiate();town.poll_input=false
	load("res://scripts/town/team_state.gd").give_to(town);root.add_child(town);await frames(8)
	var page:Control=load("res://scripts/ui/party_screen.gd").new();root.add_child(page);page.setup(town);await frames(8)
	check(page.cards[0].form=="starward" and page.cards[0].face!=null,"real Team page has Starward headshot")
	check(page._new_creature_art.used==2,"Starward Team headshot and breathing preview both finished")
	for sprite in page._new_creature_art.sprites:
		if sprite.visible:check(sprite.material.shader==Finish.STARWARD_SHADER and sprite.material.get_shader_parameter("detail_ink")==0.55,"Team art receives same Starward rim/detail preset")
	await RenderingServer.frame_post_draw
	var out:=W+"review/live/" if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/") else W+"review/after/"
	DirAccess.make_dir_recursive_absolute(out);root.get_texture().get_image().save_png(out+"starward-team.png")
	page.sel=1;page.queue_redraw();await frames(5)
	check(page._new_creature_art.used==1,"other creature preview stays unchanged; Starward headshot remains finished")
	for n in root.get_children():n.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await frames(12);print("STARWARD TEAM ","PASS" if fails==0 else "FAIL");quit(0 if fails==0 else 1)
