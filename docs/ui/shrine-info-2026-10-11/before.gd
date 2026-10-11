extends SceneTree
const OUT := "D:/dev/hollowtide-shrine-info-20261011/"
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	root.size=Vector2i(1152,648)
	var state=load("res://scripts/town/team_state.gd")
	state.start([[0,0],[1,0],[2,0],[6,2]])
	var c:Dictionary=load("res://scripts/dungeon/dungeon.gd").get_script_constant_map()
	state.data["story"]={"stone":"installed"}
	state.data["levels"]={0:{"lv":c["EVO_LEVEL"][0]}}
	state.data["growth"]={"0:0":{"kos":c["EVO"][0]["kos"][0],"floors":c["EVO"][0]["floors"][0],"flank":c["EVO"][0]["need"][0]}}
	var town=load(OUT+"originals/hub_town.gd").new()
	town.poll_input=false
	state.give_to(town)
	root.add_child(town)
	for k in 8:await process_frame
	town.team[0]["pos"]=Vector2i(7,12)
	town._place(town.team[0])
	town.act_use()
	for k in 8:await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"before.png")
	for child in root.get_children():child.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	for k in 16:await process_frame
	quit()
