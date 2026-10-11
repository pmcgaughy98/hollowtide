extends SceneTree
const W := "D:/dev/hollowtide-wilds-selout-20261010/"
var fails:=0
var out:=W+"review/scene/"
func _initialize() -> void:run.call_deferred()
func frames(n:int) -> void:
	for k in n:await process_frame
func check(ok:bool,label:String) -> void:
	if not ok:fails+=1
	print("PASS " if ok else "FAIL ",label)
func snap(name:String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out+name+".png")
func run() -> void:
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"):out=W+"review/live-scene/"
	DirAccess.make_dir_recursive_absolute(out)
	load("res://scripts/town/team_state.gd").start([[103,0],[104,0],[105,0]])
	var town:Node2D=load("res://scenes/hub_town.tscn").instantiate();town.poll_input=false
	load("res://scripts/town/team_state.gd").give_to(town)
	root.add_child(town)
	await frames(8)
	for e in town.team:check(e["sprite"].material.get_shader_parameter("detail_ink")==0.65,"town "+String(e["form"])+" material")
	var p:Control=load("res://scripts/ui/party_screen.gd").new();root.add_child(p);p.setup(town)
	await frames(6)
	for k in 3:
		p.sel=k;p.queue_redraw();await frames(5)
		check(p._new_creature_art.used==4 and p.cards[k]["face"]!=null,"Team "+String(p.cards[k]["form"])+" finished headshots and breathing preview")
		await snap("team-"+String(p.cards[k]["form"]))
	p.queue_free();await frames(4)
	for form in ["skimlet","ozbender","valvekin","gruntle"]:
		town.talk=[[form.capitalize(),"Finish verification.",form]]
		await frames(5)
		var layer:Node2D=town._hud.get_node("CrewPortraitFinish")
		check(layer.draws.size()==1 and layer.sprites[0].visible and layer.sprites[0].material.get_shader_parameter("detail_ink")==0.65,"dialogue "+form+" keeps finished portrait inside frame")
		await snap("dialogue-"+form)
		town.talk=[];await frames(3)
		check(not layer.sprites[0].visible,"dismiss "+form)
	town.queue_free();await frames(6)
	var dg:Node2D=load("res://scenes/dungeon.tscn").instantiate();dg.poll_input=false;dg.floor_seed=4242;dg.party=[[103,0],[104,0],[105,0]];root.add_child(dg)
	await frames(8)
	for e in dg.ents:
		if e["team"]==0:check(e["sprite"].material.get_shader_parameter("detail_ink")==0.65,"dungeon "+String(e["form"])+" material")
	await snap("dungeon-new-team")
	for child in root.get_children():child.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await frames(12)
	print("NEW SCENES ","PASS" if fails==0 else "FAIL")
	quit(0 if fails==0 else 1)
