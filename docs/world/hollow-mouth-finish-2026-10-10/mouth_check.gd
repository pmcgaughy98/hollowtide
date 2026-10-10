extends SceneTree
const OUT := "D:/dev/hollowtide-hollow-mouth-20261010/review/"
const Layout = preload("res://scripts/town/town_layout.gd")
var checks := 0
var bad := 0
func _initialize() -> void: _run.call_deferred()
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: bad += 1
	print("PASS " if ok else "FAIL ", label)
func frames(n: int) -> void:
	for k in n: await process_frame
func key(k: int) -> void:
	var e := InputEventKey.new()
	e.keycode = k
	e.pressed = true
	Input.parse_input_event(e)
	await frames(1)
	e = InputEventKey.new()
	e.keycode = k
	Input.parse_input_event(e)
	await frames(1)
func snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + name + ".png")
func _run() -> void:
	var before: Image = load("D:/dev/hollowtide-hollow-mouth-20261010/baseline_hub.gd").paint()
	var after: Image = load("res://scripts/town/hub_town.gd").paint()
	var outside := 0
	var inside := 0
	var allowed := Rect2i(792,648,50,50)
	var apron := Rect2i(768,624,24,72)
	for y in after.get_height():
		for x in after.get_width():
			if after.get_pixel(x, y) != before.get_pixel(x, y):
				if allowed.has_point(Vector2i(x, y)) or apron.has_point(Vector2i(x, y)): inside += 1
				else: outside += 1
	check(outside == 0 and inside > 100, "ground changes are visible and confined to Hollow Mouth and bounded west approach")
	var Old = load("D:/dev/hollowtide-hollow-mouth-20261010/originals/scripts/town/building_exteriors.gd")
	var New = load("res://scripts/town/building_exteriors.gd")
	for id in ["home", "shop", "hall", "storage", "scrolls"]:
		var p: Dictionary = Layout.PLACES.filter(func(v: Dictionary) -> bool: return v["id"] == id)[0]
		var first: Vector2i = p["door"]
		for tile in Layout.door_tiles(p): first.x = mini(first.x, tile.x)
		var d: Vector2i = (first - p["rect"].position) * 24
		var w: int = Layout.door_tiles(p).size() * 24
		check(New._details(p["rect"].size * 24, d, id, w).get_data() == Old._details(p["rect"].size * 24, d, id, w).get_data(), id + " foundation / sign exact")
		var art: Image = load(New.SOURCES[id]).get_image()
		var same := true
		for k in 3: same = same and New._door_frame(k, art, d, id).get_data() == Old._door_frame(k, art, d, id).get_data()
		check(same, id + " all three entrance frames exact")
	Old = null
	New = null
	var roads_same := true
	for r in Layout.PATHS:
		var px := Rect2i(r.position * 24,r.size * 24)
		for y in range(px.position.y,px.end.y):
			for x in range(px.position.x,px.end.x): roads_same = roads_same and before.get_pixel(x,y) == after.get_pixel(x,y)
	check(roads_same,"all authored town / ferry road pixels stay exact")
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	root.add_child(town)
	await frames(10)
	var view: Node2D = town._building_exteriors
	check(view.buildings.size() == 10 and view.buildings.has("plaza") and view.buildings.has("board") and view.buildings.has("yard") and view.buildings.has("shrine"),"Mouth joins all nine finished service views")
	var b: Dictionary = view.buildings["gate"]
	check(b["base"].position == Vector2(792,648) and b["sprite"].texture.get_size() == Vector2(48,48),"exact original 48x48 Mouth footprint at (33,27)")
	check(b["base"].z_index == 0 and not b.has("door"),"low scour recess draws below creatures, no artificial door")
	check(b["sprite"].material.shader == preload("res://scripts/arena/creature_finish.gdshader") and b["sprite"].material.get_shader_parameter("detail_ink") == 1.0,"same purposeful sel-out detail preset")
	var open := true
	for y in range(27,29):
		for x in range(33,35): open = open and town.open_at(Vector2i(x,y))
	check(open and town.open_at(Vector2i(32,28)),"all four footprint tiles and west approach remain walkable")
	check(Layout.place_at(Vector2i(33,28)).get("id","") == "gate" and Layout.place_at(Vector2i(34,28)).is_empty(),"only unchanged south-west activation tile starts the Hollow")
	var src: Image = b["sprite"].texture.get_image()
	check(src.get_pixel(0,0).a < 0.1 and src.get_pixel(47,47).a < 0.1,"transparent native corners show actual terrace")
	var cleft := 0.0
	var foothold := 0.0
	for y in range(20,28):
		for x in range(20,28): cleft += src.get_pixel(x,y).get_luminance()
	for y in range(33,41):
		for x in range(9,17): foothold += src.get_pixel(x,y).get_luminance()
	check(foothold > cleft + 6.4,"source foothold reads lighter than the descending recess, on entry tile")
	print("Source foothold / cleft mean ",foothold / 64.0," / ",cleft / 64.0)
	var proof := SubViewport.new()
	proof.size = Vector2i(96,48)
	proof.transparent_bg = true
	proof.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(proof)
	for k in 2:
		var s := Sprite2D.new()
		s.centered = false
		s.position.x = k * 48
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.texture = b["sprite"].texture
		preload("res://scripts/arena/creature_finish.gd").apply(s,k == 1)
		proof.add_child(s)
	await frames(3)
	await RenderingServer.frame_post_draw
	var rendered := proof.get_texture().get_image()
	rendered.save_png(OUT + "mouth_native_finish.png")
	var dark := [0,0]
	for k in 2:
		for y in range(5,45):
			for x in range(4,44):
				var c := rendered.get_pixel(x + k * 48,y)
				if c.a > 0.9 and maxf(c.r,maxf(c.g,c.b)) < 0.12: dark[k] += 1
	check(dark[1] > dark[0],"actual native shader strengthens interior stone / root contours")
	print("Native detail ink pixels ",dark)
	proof.queue_free()
	town.team[0]["pos"] = Vector2i(32,27)
	town.team[0]["facing"] = "s"
	town._place(town.team[0])
	await town.act_move(Vector2i.DOWN)
	check(town.team[0]["pos"] == Vector2i(32,28) and not town.has_meta("entered"),"walk reaches approach without starting a run early")
	town.team[0]["facing"] = "e"
	town._place(town.team[0])
	await key(KEY_E)
	check(town.get_meta("entered",false),"native E facing original activation tile still starts entry")
	town.remove_meta("entered")
	town.team[0]["pos"] = Vector2i(33,27)
	town._place(town.team[0])
	await town.act_move(Vector2i.RIGHT)
	check(town.team[0]["pos"] == Vector2i(34,27) and not town.has_meta("entered"),"walk crosses open north rim without starting a run")
	await frames(3)   # Let the last movement tween finish before fixture placement.
	town.team[0]["pos"] = Vector2i(31,28)
	town.team[1]["pos"] = Vector2i(30,28)
	town._place(town.team[0])
	town._place(town.team[1])
	town.set_process(false)
	town._world.position = Vector2(-624,-552)
	town._hud.queue_redraw()
	town._labels.queue_redraw()
	await frames(3)
	await snap("mouth_exterior")
	town.set_process(true)
	town.poll_input = false
	# Real scene transition, including Claude's current carried-job state.
	var State = preload("res://scripts/town/team_state.gd")
	State.start(town.party)
	var carried: Array = [preload("res://scripts/town/jobs.gd").post(7)[0]]
	State.data["jobs"] = carried.duplicate(true)
	State.data["rank"] = preload("res://scripts/town/jobs.gd").RANK_STEPS[1]
	town.team[0]["pos"] = Vector2i(32,28)
	town._place(town.team[0])
	current_scene = town
	await town.act_move(Vector2i.RIGHT)
	await frames(8)
	check(current_scene != null and current_scene.scene_file_path == "res://scenes/dungeon.tscn","walking onto (33,28) changes to actual dungeon scene")
	var dg: Node2D = current_scene
	check(dg.return_to_town and dg.party == [[0,0],[1,0]],"actual run retains party and return-to-town flag")
	check(dg.jobs == carried and dg.rank == State.data["rank"],"actual entrance preserves Claude's carried jobs and rank")
	await snap("dungeon_arrival")
	dg.queue_free()
	await frames(4)
	print("RESULT ",checks," checks, ",bad," failures")
	quit(0 if bad == 0 else 1)
