extends SceneTree
const W := "D:/dev/hollowtide-board-home-20261010/"
const State := preload("res://scripts/town/team_state.gd")
const Painter := preload("res://scripts/town/room_painter.gd")
const Room := preload("res://scripts/town/town_room.gd")
const Board := preload("res://scripts/town/job_board_painter.gd")
const Home := preload("res://scripts/town/home_room_art.gd")
var bad := 0
var checks := 0
func _initialize() -> void: _run.call_deferred()
func frames(n: int) -> void:
	for k in n: await process_frame
func check(ok: bool,label: String) -> void:
	checks+=1
	if not ok: bad+=1
	print("PASS " if ok else "FAIL ",label)
func key(code: int,pressed: bool) -> void:
	var e := InputEventKey.new()
	e.keycode=code
	e.physical_keycode=code
	e.pressed=pressed
	Input.parse_input_event(e)
func _run() -> void:
	var source: Image=load(Board.ART).get_image()
	var shown: Image=Board._display_texture().get_image()
	var native := Image.load_from_file(ProjectSettings.globalize_path(Board.DISPLAY_ART))
	check(shown.get_data()==native.get_data() and shown.get_size()==Vector2i(96,48),"refined Board retains native 96x48 art and original alpha before shared finish")
	var old_board := load(W+"originals/scripts/town/job_board_painter.gd")
	var markers_exact := true
	for k in 3: markers_exact=markers_exact and Board._marker(k).get_data()==old_board._marker(k).get_data()
	check(markers_exact and source.get_size()==Vector2i(48,24),"original 48x24 source retained and all three reading-pad drawings exact")
	var changed := 0
	var previous := load(W+"originals/scripts/town/room_painter.gd")
	var hall_before: Image=previous.paint("hall",Room.ROOMS.hall)
	var hall_after: Image=Painter.paint("hall",Room.ROOMS.hall)
	check(hall_before.get_data()==hall_after.get_data(),"Claude's entire Hall interior remains pixel-exact")
	var home_before: Image=previous.paint("home",Room.ROOMS.home)
	home_before.save_png(W+"home-layout-reference.png")
	var home_after: Image=Painter.paint("home",Room.ROOMS.home)
	check(home_after.get_size()==Vector2i(336,240) and home_after.get_data()!=home_before.get_data(),"finished Home fits the original 14x10 room at the same 24px grid")
	var door := Rect2i(165,216,30,24)
	check(home_before.get_region(door).get_data()==home_after.get_region(door).get_data(),"original south doorway and daylight drawing exact")
	# Compare actual GPU output against its unshaded art, at native resolution.
	var view := SubViewport.new()
	view.size=Vector2i(336,240)
	view.transparent_bg=true
	view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	var sprite := Sprite2D.new()
	sprite.centered=false
	sprite.texture=ImageTexture.create_from_image(home_after)
	sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	view.add_child(sprite)
	await frames(8)
	await RenderingServer.frame_post_draw
	var raw := view.get_texture().get_image()
	Home.finish(sprite)
	await frames(8)
	await RenderingServer.frame_post_draw
	var inked := view.get_texture().get_image()
	var mask := Home.mask()
	var outside_exact := true
	changed=0
	for y in 240:
		for x in 336:
			if mask.get_pixel(x,y).r<0.5:
				outside_exact=outside_exact and raw.get_pixel(x,y)==inked.get_pixel(x,y)
			elif raw.get_pixel(x,y)!=inked.get_pixel(x,y): changed+=1
	check(outside_exact and changed>500,"native shared outline changes furniture/walls while walking floor/rug/exit stay exact")
	inked.save_png(W+"review/home-finished-native.png")
	view.queue_free()
	await frames(4)
	State.start([[0,0],[1,0]])
	var town: Node2D=load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input=false
	root.add_child(town)
	await frames(8)
	var b: Dictionary=town._building_exteriors.buildings.board
	check(b.sprite.scale==Vector2.ONE and b.sprite.position.x==-24 and b.sprite.position.y+shown.get_used_rect().end.y==source.get_used_rect().end.y,"Board keeps enlarged canvas, original centre/opaque foot with native one-pixel detail")
	check(b.sprite.material.shader.resource_path=="res://scripts/town/exterior_finish.gdshader" and is_equal_approx(b.sprite.material.get_shader_parameter("detail_ink"),1.0),"Board uses material sel-out with full purposeful-building internal ink")
	var display := Rect2(b.base.position+b.sprite.position,Vector2(96,48))
	check(not display.intersects(Rect2(552,144,48,24)) and not display.intersects(Rect2(610,119,19,19)),"Board remains clear of Hall door and guild sign")
	town.team[0].pos=Vector2i(26,8)
	town._place(town.team[0])
	town.poll_input=true
	key(KEY_E,true)
	await frames(4)
	key(KEY_E,false)
	await frames(15)
	check(town.panel.get("service","")=="board" and b.frame==2,"real E opens four requests and activates original reading corners")
	key(KEY_ESCAPE,true)
	await frames(4)
	key(KEY_ESCAPE,false)
	await frames(15)
	check(town.panel.is_empty() and b.frame==0,"real Escape closes Board and restores dormant feedback")
	town.queue_free()
	await frames(4)
	print("FINISH ",checks-bad,"/",checks," PASS")
	quit(0 if bad==0 else 1)
