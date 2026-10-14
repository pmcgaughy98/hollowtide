extends SceneTree
const TeamState = preload("res://scripts/town/team_state.gd")
const Art = preload("res://scripts/town/storage_room_art.gd")
var OUT = "D:/dev/hollowtide-storage-integration-20261014/"+OS.get_cmdline_user_args()[0]+"/integration/"
var fails=0
var checks=0
func _initialize(): run.call_deferred()
func frames(n):
	for k in n: await process_frame
func ok(label,good):
	checks+=1
	print(label," -> ","ok" if good else "FAIL")
	if not good:fails+=1
func snap(name):
	await frames(4)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+name+".png")
func key(host,k):
	var e=InputEventKey.new();e.keycode=k;e.pressed=true
	Input.parse_input_event(e);host._poll();await frames(2)
	e=InputEventKey.new();e.keycode=k;e.pressed=false
	Input.parse_input_event(e);host._poll();await frames(2)
func walk(room,to):
	var start: Vector2i=room.team[0].pos
	var came={start:start};var q=[start]
	while not q.is_empty():
		var c=q.pop_front()
		for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var n: Vector2i=c+d
			if not came.has(n) and room._open(n):came[n]=c;q.append(n)
	if not came.has(to):return false
	var path=[];var at=to
	while at!=start:path.push_front(at);at=came[at]
	for step in path:
		await room.act_move(step-room.team[0].pos)
		await frames(1)
	return room.team[0].pos==to
func run():
	root.size=Vector2i(1152,648);DirAccess.make_dir_recursive_absolute(OUT)
	TeamState.save_path="user://storage_integration.save";TeamState.erase_save()
	TeamState.start([[0,0],[1,0],[2,0]])
	TeamState.data.bag={"reedberry":2,"lamp_oil":1,"parcel":1}
	TeamState.data.beaten=["mouth","first"]
	var original_party=TeamState.data.party.duplicate(true)
	var town=load("res://scenes/hub_town.tscn").instantiate();town.poll_input=false
	TeamState.give_to(town)
	root.add_child(town);current_scene=town;await frames(6)
	var door=town.Layout.PLACES.filter(func(p):return p.id=="storage")[0]
	town.team[0].pos=door.door+Vector2i.DOWN;town.team[0].facing="n";town._place(town.team[0])
	town.act_use();await frames(8)
	var room=current_scene;room.poll_input=false
	ok("Actual unlocked town door changes to Storage",room.get("room_id")=="storage")
	ok("Native room size and three-tile threshold",room.room().w==17 and room.room().h==13 and room._open(Vector2i(7,12)) and room._open(Vector2i(8,12)) and room._open(Vector2i(9,12)))
	var occupied={};var spawn_ok=true
	for e in room.team:
		spawn_ok=spawn_ok and room._open(e.pos) and not occupied.has(e.pos);occupied[e.pos]=true
	ok("Three-member party spawns on distinct open floor",spawn_ok and room.team.size()==3)
	ok("No keeper or NPC stand-in",room.npcs.is_empty())
	var solids_ok=true
	for rect in room.room().solid:
		for y in range(rect.position.y,rect.end.y):
			for x in range(rect.position.x,rect.end.x):solids_ok=solids_ok and not room._open(Vector2i(x,y))
	ok("Cabinet/counter/crate/basket footprints block movement",solids_ok)
	var reached={Vector2i(8,11):true};var q=[Vector2i(8,11)]
	while not q.is_empty():
		var c=q.pop_front()
		for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var n: Vector2i=c+d
			if room._open(n) and not reached.has(n):reached[n]=true;q.append(n)
	var opened=0
	for y in 13:
		for x in 17:if room._open(Vector2i(x,y)):opened+=1
	ok("All108 open tiles connect to entry and counter",opened==108 and reached.size()==opened and reached.has(Vector2i(8,7)))
	ok("North wall and outside south wall are closed",not room._open(Vector2i(8,2)) and not room._open(Vector2i(6,12)) and not room._open(Vector2i(10,12)))
	await snap("1_entry")
	ok("Actual steps reach counter through clear aisle",await walk(room,Vector2i(8,7)))
	room.team[0].facing="n";room._place(room.team[0]);await key(room,KEY_E)
	ok("E at counter opens original Storage service",room.panel.get("service","")=="storage" and room.storage_rows().size()==3)
	await key(room,KEY_E)
	ok("Real E deposits one and blocks walking while panel open",TeamState.data.stored.get("reedberry",0)==1 and room.team[0].pos==Vector2i(8,7))
	await key(room,KEY_R)
	ok("Real R withdraws it",TeamState.data.bag.get("reedberry",0)==2 and TeamState.data.stored.is_empty())
	await key(room,KEY_S);await key(room,KEY_S);await key(room,KEY_E)
	ok("Real selection keys reach parcel and refusal leaves records intact",room.panel.sel==2 and "carrying" in room.panel.said and TeamState.data.bag.parcel==1 and not TeamState.data.stored.has("parcel"))
	await snap("2_counter_panel")
	await key(room,KEY_ESCAPE)
	ok("Escape closes service panel",room.panel.is_empty())
	ok("Can walk around counter to its back",await walk(room,Vector2i(8,4)))
	var counter=room._world.get_children().filter(func(n):return n is Sprite2D and n.texture.resource_path.ends_with("/counter.png"))[0]
	ok("Counter draws in front of feet behind it",counter.z_index>room.team[0].node.z_index)
	await snap("3_behind_counter")
	await walk(room,Vector2i(8,7))
	ok("Counter draws behind feet at front approach",counter.z_index<room.team[0].node.z_index)
	await snap("4_front_counter")
	TeamState.data.stored={"reedberry":3}
	await walk(room,Vector2i(7,11));await room.act_move(Vector2i.DOWN);await frames(8)
	var returned=current_scene;returned.poll_input=false
	ok("Walking out left threshold returns to town Storage door",returned.scene_file_path.ends_with("hub_town.tscn") and returned.team[0].pos==door.door+Vector2i.DOWN)
	ok("Party and stored record survive round trip",TeamState.data.party==original_party and TeamState.data.stored.reedberry==3 and TeamState.data.bag.reedberry==2)
	await snap("5_returned")
	TeamState.data={}
	ok("Actual room exit autosave persists existing Storage record",TeamState.load_save() and TeamState.data.stored.reedberry==3)
	returned.queue_free();await frames(4)
	# Every threshold tile uses the exit, including the right edge; no town scene needed for this control.
	var edge=load("res://scenes/town_room.tscn").instantiate();edge.room_id="storage";edge.poll_input=false
	root.add_child(edge);await frames(3)
	edge.team[0].pos=Vector2i(9,11);edge._place(edge.team[0]);await edge.act_move(Vector2i.DOWN);await frames(2)
	ok("Right threshold also exits rather than trapping the leader",edge.get_meta("left",false) and TeamState.data.get("arrive_at","")=="storage")
	edge.queue_free();await frames(4)
	TeamState.erase_save()
	var music=root.get_node_or_null("HollowtideMusic")
	if music!=null:music.queue_free()
	await frames(4)
	FileAccess.open(OUT+"checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"fails":fails,"open_tiles":opened},"  "))
	print("STORAGE INTEGRATION: ",checks-fails,"/",checks)
	quit(1 if fails else 0)
