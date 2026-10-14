extends SceneTree
const UI := preload("res://scripts/ui/ui_style.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const Jobs := preload("res://scripts/town/jobs.gd")
const WORK := "D:/dev/hollowtide-parcel-icon-20261014/"
var out: String
var checks: Array = []
var failed := 0
func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
	for k in n: await process_frame
func ok(label: String, good: bool) -> void:
	checks.append({"check":label,"ok":good})
	if not good: failed += 1
	print(label, " -> ", "ok" if good else "FAIL")
func snap(name: String) -> Image:
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	img.save_png(out + name + ".png")
	return img
func matches(frame: Image, icon: Image, at: Vector2i) -> bool:
	for y in icon.get_height():
		for x in icon.get_width():
			if icon.get_pixel(x,y).a == 0.0: continue
			if at.x+x < 0 or at.y+y < 0 or at.x+x >= frame.get_width() or at.y+y >= frame.get_height(): return false
			if frame.get_pixel(at.x+x,at.y+y) != icon.get_pixel(x,y): return false
	return true
func run() -> void:
	out = WORK + ("live/" if OS.get_cmdline_user_args().has("live") else "stage/")
	DirAccess.make_dir_recursive_absolute(out)
	root.size = Vector2i(1152,648)
	var icon := UI.item_icon("parcel")
	ok("Generic item lookup returns Parcel",icon != null)
	if icon == null: quit(1);return
	var original := Image.load_from_file(WORK+"parcel.png")
	ok("Imported 32px RGBA exact",icon.get_image().get_data() == original.get_data() and icon.get_size() == Vector2(32,32))
	ok("Unknown item fallback retained",UI.item_icon("parcel_missing_fixture") == null)
	for item in ["reedberry","lamp_oil","river_stone","rally_seed","scroll:claw"]:
		ok("Existing icon: " + item,UI.item_icon(item) != null)
	# Find a real generated board with a delivery, then take it at the real board.
	var seed_value := 1
	while Jobs.post(seed_value).filter(func(j: Dictionary) -> bool: return j.kind == "delivery").is_empty(): seed_value += 1
	TeamState.start([[0,0],[1,0]])
	TeamState.data["bag"] = {"reedberry":1}
	TeamState.data["cleared"] = seed_value-1
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input=false
	TeamState.give_to(town)
	root.add_child(town);current_scene=town
	await frames(6)
	var board: Dictionary = town.Layout.PLACES.filter(func(p: Dictionary) -> bool: return p.id == "board")[0]
	town.team[0]["pos"] = board.door;town._place(town.team[0]);town.act_use()
	ok("Actual Job Board opens",town.panel.get("service","") == "board")
	var jobs: Array = town.board_rows()
	var choice := -1
	for k in jobs.size():
		if jobs[k].kind == "delivery": choice=k;break
	ok("Generated board has Deliver to request",choice>=0)
	if choice<0:quit(1);return
	var before: Dictionary = TeamState.data.get("bag",{}).duplicate(true)
	town.panel.sel=choice;town.act_board_pick();town.panel.sel=0
	await frames(6)
	ok("Taking delivery puts one Parcel in bag",int(TeamState.data.bag.get("parcel",0))==1 and TeamState.data.jobs.size()==1)
	ok("Board retains taken delivery and unchanged reward",Jobs.is_taken(TeamState.data,town.board_rows()[0]) and town.board_rows()[0].reward=="lamp_oil")
	var frame := await snap("board-delivery-taken")
	ok("Real Board cargo icon rendered pixel exact",matches(frame,original,Vector2i(260,169)))
	var reward: Image = UI.item_icon("lamp_oil").get_image()
	ok("Real Board reward icon still rendered pixel exact",matches(frame,reward,Vector2i(610,173)))
	var menu: CanvasLayer = town.get_node("GamePauseMenu")
	menu.open();menu.show_page("bag");await frames(4)
	var button: Button = menu.content.find_child("Use_parcel",true,false)
	ok("Actual Bag has Parcel row with icon",button!=null and button.icon==icon)
	button.grab_focus();await frames(4)
	var bag: Node = menu.content.find_child("BagPage",true,false)
	ok("Bag selects Parcel and count",bag.selected_kind=="parcel" and bag.item_name.text=="Parcel" and bag.count.text=="x1")
	var enlarged := original.duplicate();enlarged.resize(96,96,Image.INTERPOLATE_NEAREST)
	ok("Bag detail uses exact nearest 3x icon",bag.portrait.texture.get_image().get_data()==enlarged.get_data())
	frame=await snap("bag-parcel-selected")
	var style := button.get_theme_stylebox("focus" if button.has_focus() else "normal")
	var row_icon_at := button.global_position + Vector2(style.get_content_margin(SIDE_LEFT),(button.size.y-32)*0.5)
	ok("Real Bag row icon visible",matches(frame,original,Vector2i(row_icon_at)))
	var rect: Rect2 = bag.portrait.get_global_rect()
	ok("Real Bag detail icon rendered pixel exact",matches(frame,enlarged,Vector2i(rect.position+(rect.size-Vector2(96,96))*0.5)))
	menu.resume();await frames(2)
	town.panel.sel=0;town.act_board_pick();await frames(3)
	ok("Putting delivery back removes cargo without altering other bag items",not TeamState.data.bag.has("parcel") and TeamState.data.bag==before and TeamState.data.jobs.is_empty())
	var music := root.get_node_or_null("HollowtideMusic")
	if music != null: music.queue_free()
	town.queue_free();await frames(4)
	FileAccess.open(out+"checks.json",FileAccess.WRITE).store_string(JSON.stringify({"passed":checks.size()-failed,"total":checks.size(),"board_seed":seed_value,"checks":checks},"  "))
	print("PARCEL: %d/%d" % [checks.size()-failed,checks.size()])
	quit(0 if failed==0 else 1)
