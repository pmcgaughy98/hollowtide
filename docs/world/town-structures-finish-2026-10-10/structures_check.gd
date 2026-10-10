extends SceneTree
const W := "D:/dev/hollowtide-town-structures-20261010/"
const Layout := preload("res://scripts/town/town_layout.gd")
const State := preload("res://scripts/town/team_state.gd")
const Landmarks := preload("res://scripts/town/landmark_exteriors.gd")
const Board := preload("res://scripts/town/job_board_painter.gd")
var bad := 0
var checks := 0
func _initialize() -> void:_run.call_deferred()
func frames(n: int) -> void:
	for k in n:await process_frame
func check(ok: bool,label: String) -> void:
	checks+=1
	if not ok:bad+=1
	print("PASS " if ok else "FAIL ",label)
func key(code: int,pressed: bool) -> void:
	var e := InputEventKey.new()
	e.keycode=code
	e.physical_keycode=code
	e.pressed=pressed
	Input.parse_input_event(e)
func _run() -> void:
	State.start([[0,0],[1,0]])
	var town: Node2D=load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input=false
	root.add_child(town)
	await frames(8)
	check(town._building_exteriors.buildings.size()==13,"all 13 existing town places have a finished exterior view")
	var b: Dictionary=town._building_exteriors.buildings["board"]
	var original: Image=b.sprite.texture.get_image()
	var used := original.get_used_rect()
	check(b.sprite.scale==Vector2(2,2) and original.get_size()==Vector2i(48,24),"original Board artwork displayed at twice its previous width and height")
	check(b.base.position.y+b.sprite.position.y+used.end.y*2==b.base.position.y+used.end.y,"Board's actual opaque foot row stays precisely grounded")
	check(b.sprite.position.x+original.get_width()==original.get_width()/2,"Board remains centred on its original stand")
	var display := Rect2(b.base.position+b.sprite.position,Vector2(original.get_size())*2)
	var hall_door := Rect2(552,144,48,24)
	var hall_sign := Rect2(610,119,19,19)
	check(not display.intersects(hall_door) and not display.intersects(hall_sign),"larger stand stays clear of the two-tile Hall doorway, steps and guild sign")
	var old_board := load(W+"originals/scripts/town/job_board_painter.gd")
	var markers_exact := true
	for k in 3:markers_exact=markers_exact and Board._marker(k).get_data()==old_board._marker(k).get_data()
	check(markers_exact,"all three original reading-pad feedback drawings exact")
	town.team[0]["pos"]=Vector2i(26,8)
	town._place(town.team[0])
	town.poll_input=true
	key(KEY_E,true)
	await frames(4)
	key(KEY_E,false)
	await frames(20)
	check(town.panel.get("service","")=="board" and town.board_rows().size()==4,"real E at the unchanged reading spot opens Claude's four requests")
	check(b.frame==2,"the original reading corners respond when the Board opens")
	key(KEY_ESCAPE,true)
	await frames(4)
	key(KEY_ESCAPE,false)
	await frames(20)
	check(town.panel.is_empty() and b.frame==0,"real Escape closes the Board and restores dormant corners")
	town.poll_input=false
	var protected_gate := Rect2i(166,22,52,52)
	for id in ["lookout","landing","dock"]:
		var p: Dictionary=Landmarks.place(id)
		var view: Dictionary=town._building_exteriors.buildings[id]
		var im := Landmarks.paint(id)
		check(view.base.position==Vector2(p.rect.position*24) and view.base.z_index==0,"%s keeps its exact place and remains below creatures"%id)
		check(view.sprite.material!=null and is_equal_approx(view.shadow.modulate.a,0.22),"%s uses the same detailed exterior finish and contact shadow"%id)
		var count := 0
		var aperture := true
		var local: Vector2i=(p.door-p.rect.position)*24
		for y in im.get_height():
			for x in im.get_width():
				if im.get_pixel(x,y).a>0.5:count+=1
				if Rect2i(local+Vector2i(7,13),Vector2i(10,10)).has_point(Vector2i(x,y)):aperture=aperture and im.get_pixel(x,y).a<0.5
		check(count>100 and count<float(im.get_width()*im.get_height())*0.4,"%s details preserve broad original open floor"%id)
		check(aperture,"%s original activation tile has a clear standing position"%id)
		if id=="landing":
			var gate_clear := true
			for y in range(protected_gate.position.y,protected_gate.end.y):
				for x in range(protected_gate.position.x,protected_gate.end.x):gate_clear=gate_clear and im.get_pixel(x,y).a==0.0
			check(gate_clear,"Landing details do not cover the Hollow Mouth or its approach")
		town.panel={}
		town.team[0]["pos"]=p.door
		town._place(town.team[0])
		var answer: Dictionary=town.act_use()
		check(answer.get("id","")==id,"%s original service still answers E"%id)
	# Other buildings retain every source-backed foundation/sign and entrance drawing.
	var old_ex := load(W+"originals/scripts/town/building_exteriors.gd")
	var ex := load("res://scripts/town/building_exteriors.gd")
	var drawings_exact := true
	var frame_count := 0
	for id in ["home","shop","hall","storage","scrolls"]:
		var p: Dictionary=Layout.PLACES.filter(func(q: Dictionary) -> bool:return q.id==id)[0]
		var d: Vector2i=p.door
		for tile in Layout.door_tiles(p):d.x=mini(d.x,tile.x)
		d=(d-p.rect.position)*24
		var source: Image=load(ex.SOURCES[id]).get_image()
		drawings_exact=drawings_exact and ex._details(p.rect.size*24,d,id,Layout.door_tiles(p).size()*24).get_data()==old_ex._details(p.rect.size*24,d,id,Layout.door_tiles(p).size()*24).get_data()
		for k in 3:
			drawings_exact=drawings_exact and ex._door_frame(k,source,d,id).get_data()==old_ex._door_frame(k,source,d,id).get_data()
			frame_count+=1
	check(drawings_exact and frame_count==15,"all five foundations/signs and fifteen door/hatch drawings exact")
	# Only removal of the old Board's baked shadow changes ground; props sit on a separate layer.
	var current_ground: Image = town.paint()
	var old_art: Image=load(Board.ART).get_image()
	var old_patch := Image.create(48,24,false,Image.FORMAT_RGBA8)
	old_patch.fill(Color("#677c4c"))
	var read_patch := Image.create(24,24,false,Image.FORMAT_RGBA8)
	read_patch.fill(Color("#677c4c"))
	var same_base := current_ground.duplicate() as Image
	var a: Image=old_board.apply(current_ground.duplicate(),old_patch,read_patch)
	var c: Image=Board.apply(same_base,old_patch,read_patch)
	var outside_exact := true
	var box := Rect2i(624,168,51,27)
	for y in c.get_height():
		for x in c.get_width():
			if not box.has_point(Vector2i(x,y)):outside_exact=outside_exact and a.get_pixel(x,y)==c.get_pixel(x,y)
	check(outside_exact,"ground beyond the old Board contact-shadow patch remains exact")
	town.queue_free()
	await frames(4)
	print("RESULT ",checks-bad,"/",checks," structure checks pass")
	quit(1 if bad else 0)
