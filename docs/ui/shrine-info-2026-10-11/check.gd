extends SceneTree
const OUT := "D:/dev/hollowtide-shrine-info-20261011/"
const State := preload("res://scripts/town/team_state.gd")
const Info := preload("res://scripts/ui/shrine_info.gd")
var fails := 0
var checks := 0
func _initialize() -> void: _run.call_deferred()
func _frames(n: int) -> void:
	for k in n: await process_frame
func _ok(label: String, good: bool) -> void:
	checks += 1
	if not good: fails += 1
	print("%s -> %s" % [label, "ok" if good else "FAIL"])
func _snap(name: String) -> void:
	await _frames(8)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + name + ".png")
func _key(code: int) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await _frames(2)
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await _frames(2)
func _click(control: Control) -> void:
	var event := InputEventMouseButton.new()
	event.position = control.get_global_rect().get_center()
	event.global_position = event.position
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	Input.parse_input_event(event)
	await _frames(2)
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await _frames(2)
func _run() -> void:
	root.size = Vector2i(1152, 648)
	State.start([[0,0],[1,0],[2,0],[6,2]])
	var c: Dictionary = load("res://scripts/dungeon/dungeon.gd").get_script_constant_map()
	State.data["levels"] = {0:{"lv":int(c["EVO_LEVEL"][0])},1:{"lv":2},2:{"lv":3},6:{"lv":12}}
	State.data["iq"] = {0:7,1:4}
	State.data["growth"] = {"0:0":{"kos":c["EVO"][0]["kos"][0],"floors":c["EVO"][0]["floors"][0],"flank":c["EVO"][0]["need"][0]}}
	State.data["taught"] = {"0:0":["claw","ember_feint","fireball","cinder_claw"]}
	var before := State.data.duplicate(true)
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	State.give_to(town)
	root.add_child(town)
	await _frames(8)
	var shrine: Dictionary = town.Layout.PLACES.filter(func(p):return p["id"]=="shrine")[0]
	town.team[0]["pos"] = shrine["door"]
	town._place(town.team[0])
	town.act_use()
	await _frames(6)
	var view = town.get_node("ShrineInfo")
	_ok("Dormant shrine opens readable team information without evolve action",view.screen.visible and town.panel["service"]=="growth" and view.action.text=="E close")
	_ok("Browsing leaves carried record exact",State.data==before)
	await _snap("dark")
	State.data["story"]={"stone":"installed"}
	town.panel={}
	town.act_use()
	await _frames(6)
	_ok("Initial ready creature keeps original evolve confirmation",town.panel["service"]=="evolve_ask" and town.panel["k"]==0)
	var data: Dictionary = Info.member(State.data,0)
	_ok("Level IQ conditions and taught moves read current sources",data["level"]==c["EVO_LEVEL"][0] and data["iq"]==7 and data["conditions"][1][2]==c["EVO"][0]["kos"][0] and data["moves"]==State.data["taught"]["0:0"])
	_ok("Next form learnset reads current LEARN",data["next_learn"]==c["LEARN"]["sparkwick"])
	await _snap("ready")
	_ok("Awake status updates when same-frame panel is reopened",view.status.text.contains("awake") and view.action.text=="E evolve")
	_ok("All four condition rows fit without scrolling",view.details.size.y<=view.detail_scroll.size.y and view.details.size.x<=view.detail_scroll.size.x)
	_ok("Current team portrait uses shared finish and clipped frame",view.details.get_child(0).get_child(0).get_child(0).clip_contents and view.details.get_child(0).get_child(0).get_child(0).get_child(1).material is ShaderMaterial)
	town.poll_input=true
	await _key(KEY_S)
	_ok("Actual S input browses next member without evolution",view.selected==1 and town.panel["service"]=="growth" and not town.evolving_now)
	await _key(KEY_D)
	_ok("Actual D input opens Moves page",view.tab=="moves")
	await _snap("moves")
	_ok("Unavailable moves read WAITING without becoming known",Info.member(State.data,1)["waiting"]==c["WAITING"]["tallowroot"] and not "burrow" in Info.member(State.data,1)["moves"])
	await _key(KEY_PAGEDOWN)
	_ok("Actual PageDown exposes longer move list",view.detail_scroll.scroll_vertical > 0)
	await _snap("moves_bottom")
	await _click(view.members.get_child(2))
	_ok("Actual mouse click browses team member",view.selected==2)
	await _click(view.tabs.get_child(0))
	_ok("Actual mouse click opens Growth tab",view.tab=="growth")
	view.select(3)
	view._set_tab("growth")
	await _snap("final")
	_ok("Final stage has no evolution conditions or action",Info.member(State.data,3)["conditions"].is_empty() and town.panel["service"]=="growth")
	var pos: Vector2i=town.team[0]["pos"]
	await _key(KEY_W)
	_ok("Browsing blocks town walking",town.team[0]["pos"]==pos)
	town.cutscene=true
	_ok("Existing cutscene keeps input priority over shrine information",not view.poll())
	town.cutscene=false
	await _key(KEY_ESCAPE)
	_ok("Actual Escape closes panel",town.panel.is_empty() and not view.screen.visible)
	town.poll_input=false
	State.data["story"]={"stone":"carried"}
	town.act_use()
	await _frames(6)
	view.select(1)
	_ok("Carried stone confirmation survives browsing",town.panel["service"]=="stone_ask" and view.action.text=="E set stone")
	await _snap("stone")
	view.action.pressed.emit()
	await _frames(125)
	_ok("Existing stone installation completes and hides information panel",town.stone_state()=="installed" and town.panel["service"]=="growth_done" and not view.screen.visible)
	town.panel={}
	town.act_use()
	await _frames(6)
	view.select(1)
	view.select(0)
	_ok("Selecting ready member restores exact evolution target",town.panel["service"]=="evolve_ask" and town.panel["k"]==0)
	view.action.pressed.emit()
	await _frames(480)
	_ok("Existing evolution changes form and preserves move-choice queue",town.party[0]==[0,1] and town.team[0]["form"]=="sparkwick" and State.data["pending_learn"]==[[0,1,"cinder_claw"]])
	town.panel={}
	town.act_use()
	await _frames(6)
	view._set_tab("moves")
	await _snap("pending")
	_ok("Queued choice displayed from pending_learn",Info.member(State.data,0)["pending"]==["cinder_claw"])
	_ok("Native frame stays within viewport",Rect2(Vector2.ZERO,Vector2(root.size)).encloses(view.screen.get_global_rect()) and view.screen.size==Vector2(1056,540))
	_ok("Four member buttons remain within scrollable team list",view.members.get_child_count()==4)
	_ok("Empty team produces safe information state",Info.member({"party":[]},0).is_empty())
	var forms_ok := true
	for ln in range(town.Arena.LINES.size()):
		for st in range(3):
			var probe: Dictionary = Info.member({"party":[[ln,st]]},0)
			forms_ok = forms_ok and not probe["name"].is_empty() and not probe["moves"].is_empty()
	for ln in town.Lines.EXTRA:
		var probe: Dictionary = Info.member({"party":[[ln,0]]},0)
		forms_ok = forms_ok and not probe["final"] and probe["conditions"].is_empty() and probe["next"]==""
	_ok("All existing forms read valid names and moves; unfinished lines avoid final-stage claim",forms_ok)
	print("SHRINE INFO: %d/%d passed" % [checks-fails,checks])
	for child in root.get_children(): child.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await _frames(16)
	quit(1 if fails else 0)
