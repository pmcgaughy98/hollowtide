extends SceneTree
const OUT="D:/dev/hollowtide-creature-opening-20261009/"
var failed:Array[String]=[]
var results:Array[Dictionary]=[]
func _initialize() -> void:call_deferred("run")
func frames(n:int) -> void:
	for i in n:await process_frame
func run() -> void:
	for native_art in [false,true]:
		var dg:Node2D=load("res://scenes/dungeon.tscn").instantiate()
		dg.real_time_battles=true # Explicit opt-in probe of the retained optional bridge.
		dg.floor_seed=4242;dg.poll_input=false;dg.party=[[0,1],[1,1]]
		root.add_child(dg)
		await frames(3)
		if not native_art:
			var painter=load("res://scripts/dungeon/floor_painter.gd")
			dg._map.texture=ImageTexture.create_from_image(painter.paint_procedural(dg.data,24,4242))
		var spot:=Vector2i.ZERO
		for room in dg.data.rooms:
			if room.size.x>=7 and room.size.y>=3:spot=room.position+Vector2i(1,1);break
		for e in dg.ents:
			if e.team==1:e.pos=Vector2i(-60,-60);e.awake=false
		dg.ents[0].pos=spot;dg.ents[1].pos=spot+Vector2i(0,1)
		var enemy:Dictionary=dg._make(2,0,1,spot+Vector2i(4,0))
		enemy.awake=true;dg.ents.append(enemy)
		for e in dg.ents:dg._place(e)
		dg.traps.clear();dg._reveal();dg.autopilot=true
		await dg.act_rest()
		await frames(3)
		var started:bool=dg.in_battle and dg._battle!=null
		var same:=false
		var before_hp:=-1
		var after_hp:=-1
		if started:
			var arena:Node2D=dg._battle
			same=arena._map.texture.get_image().get_data()==dg._map.texture.get_image().get_data()
			before_hp=arena._fighters[-1].hp
			await frames(300)
			if is_instance_valid(arena):after_hp=arena._fighters[-1].hp
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OUT+("fight-new.png" if native_art else "fight-original.png"))
		results.append({"new_art":native_art,"battle_started":started,"same_floor_picture":same,"enemy_hp_before":before_hp,"enemy_hp_after_300_frames":after_hp})
		if not started or not same:failed.append("bridge "+str(native_art))
		dg.queue_free();await frames(3)
	var f:=FileAccess.open(OUT+"bridge-checks.json",FileAccess.WRITE)
	f.store_string(JSON.stringify({"results":results,"failures":failed},"  "));f.close()
	print(JSON.stringify(results))
	quit(0 if failed.is_empty() else 1)
