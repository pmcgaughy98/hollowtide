extends SceneTree
const OUT="D:/dev/hollowtide-hall-door-20261010/review/"
const Layout=preload("res://scripts/town/town_layout.gd")
var passes=0
var failures=0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
	if ok: passes+=1; print("PASS ",label)
	else: failures+=1; push_error(label)
func frames(n: int) -> void:
	for i in n: await process_frame
func key(code: Key) -> void:
	var e:=InputEventKey.new(); e.keycode=code; e.physical_keycode=code; e.pressed=true
	Input.parse_input_event(e); await frames(3)
	e=InputEventKey.new(); e.keycode=code; e.physical_keycode=code; e.pressed=false
	Input.parse_input_event(e); await frames(3)
func run() -> void:
	root.size=Vector2i(1152,648)
	var script=load("res://scripts/town/hub_town.gd")
	var before: Image=load("D:/dev/hollowtide-hall-door-20261010/hall_ground_before.gd").paint(script.paint_blockout())
	var after: Image=script.paint()
	var changed_outside=0
	var bay:=Rect2i(456,24,240,144)
	var approach:=Rect2i(552,168,72,50)
	for y in after.get_height():
		for x in after.get_width():
			if not bay.has_point(Vector2i(x,y)) and not approach.has_point(Vector2i(x,y)) and after.get_pixel(x,y)!=before.get_pixel(x,y): changed_outside+=1
	check(changed_outside==0,"Every pixel outside Hall and approach is exact")
	check(after.get_region(bay).get_data()!=before.get_region(bay).get_data(),"Coherent Hall replaces the rejected insert")
	check(after.get_region(Rect2i(600,168,24,48)).get_data()!=before.get_region(Rect2i(600,168,24,48)).get_data(),"Extra paving strip removed to meet authored two-tile steps")
	check(load("res://assets/sprites/world/wayline_hall_2026_10_10/wayline_hall_native.png").get_size()==Vector2(240,144),"Full Hall fits authored footprint")
	for x in [564,588]:
		var c:=after.get_pixel(x,156)
		check(c.a>0.99 and c.r<0.4 and c.g<0.35,"Door tile centre is dark and opaque at x%d"%x)
	check(script.paint().get_data()==after.get_data(),"Painter is deterministic")
	var town:Node=load("res://scenes/hub_town.tscn").instantiate()
	root.add_child(town); current_scene=town
	await frames(5)
	for x in [23,24]:
		town.poll_input=false; town.panel={}
		town.team[0].pos=Vector2i(x,7); town._place(town.team[0])
		town.team[1].pos=Vector2i(x,8); town._place(town.team[1])
		await town.act_move(Vector2i(0,-1))
		check(town.team[0].pos==Vector2i(x,6),"Real movement enters doorway tile %d"%x)
		town.poll_input=true; await key(KEY_E)
		check(town.panel.get("id","")=="hall","Native E answers Hall from doorway tile %d"%x)
		await frames(4)
		root.get_texture().get_image().save_png(OUT+"hall_service_%d.png"%x)
		town.panel={}; town.poll_input=false
		await town.act_move(Vector2i(0,1))
		check(town.team[0].pos==Vector2i(x,7),"Doorway tile %d exits onto its step"%x)
	check(Layout.door_tiles(Layout.PLACES[0])==[Vector2i(23,6),Vector2i(24,6)],"Claude doorway contract retained")
	town.set_process(false); town._world.position=Vector2(-384,0); town._labels.hide(); town._hud.hide()
	town.get_node("GamePauseMenu").hint.hide(); await frames(5)
	root.get_texture().get_image().save_png(OUT+"hall_front.png")
	after.save_png(OUT+"town_native.png")
	print("ENTRANCE_RESULT passes=%d failures=%d"%[passes,failures])
	town.queue_free(); await frames(45)
	for child in root.get_children(): child.queue_free()
	preload("res://scripts/audio/music.gd")._inst=null
	await frames(4)
	quit.call_deferred(1 if failures else 0)
