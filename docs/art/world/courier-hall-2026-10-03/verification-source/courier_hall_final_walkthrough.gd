extends SceneTree
const BASE := "C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/courier-hall-review/final-trip/"
const FLAGS := ["pouch_accepted","levee_entrance_read","city_arrival_registered","city_directions_read","delivered","water_mark_observed","heard_calls","marker_restored","report_done","reported_calls","reported_water_mark"]
var journey: Node2D
var route: Node2D
var steps: Array = []
var failed := false
var model := "Male"
var party_id: int
var route_id: int
var home_id: int
var hall_id: int
var startup_ms: int
var home_exit_frames := 0
var approach_frames := 0
var relay_walk_frames := 0
var relay_start_frames := 0
var total_walk_frames := 0
func _initialize() -> void:
	if "--female" in OS.get_cmdline_user_args(): model="Female"
	call_deferred("_run")
func frames(count: int) -> void:
	for i in count: await process_frame
func player() -> CharacterBody2D:
	return journey.active_area.get_node("Player")
func flags() -> Dictionary:
	var values: Dictionary={}
	for name in FLAGS: values[name]=route.get(name)
	return values
func key(code: Key) -> void:
	for pressed in [true,false]:
		var event:=InputEventKey.new()
		event.keycode=code;event.physical_keycode=code;event.pressed=pressed
		Input.parse_input_event(event)
		await frames(3)
func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(BASE+model.to_lower()+"-"+label+".png")
func release() -> void:
	for action in ["move_left","move_right","move_up","move_down"]: Input.action_release(action)
func walk(to: Vector2) -> bool:
	var origin:=player().position
	var area: String=journey.active_id
	var stationary:=0
	for tick in 2200:
		if journey.active_id != area or journey.transitioning:
			release();failed=true;return false
		var delta:=to-player().position
		if delta.length()<3:
			release()
			await frames(2)
			steps.append({"walk":str(to),"from":str(origin),"area":area,"frames":tick})
			total_walk_frames+=tick
			return true
		var before:=player().position
		for pair in [["move_left",delta.x< -1.5],["move_right",delta.x>1.5],["move_up",delta.y< -1.5],["move_down",delta.y>1.5]]:
			if pair[1]:Input.action_press(pair[0])
			else:Input.action_release(pair[0])
		await physics_frame
		if player().position.distance_to(before)<0.01: stationary+=1
		else:stationary=0
		if stationary>40: break
	release()
	steps.append({"blocked":str(to),"at":str(player().position),"area":area})
	print("AREA_WALK_BLOCKED ",area," ",to," at ",player().position)
	failed=true
	await capture("blocked")
	return false
func path(points: Array) -> bool:
	for point in points:
		if not await walk(point):return false
	return true
func exit_area(action: String, destination: String) -> bool:
	var source: String=journey.active_id
	var before:=flags()
	Input.action_press(action)
	for i in 140:
		await physics_frame
		if journey.active_id==destination:
			release()
			for j in 100:
				if not journey.transitioning:break
				await physics_frame
			await frames(5)
			var okay: bool=journey.active_id==destination and not journey.transitioning and before==flags() and player().chibi_model==model
			steps.append({"entrance_from":source,"to":destination,"flags_preserved":before==flags(),"selected_model":player().chibi_model,"passed":okay})
			await capture("entrance-"+source+"-to-"+destination)
			if not okay:failed=true
			return okay
	release();failed=true
	steps.append({"entrance_failed":source,"destination":destination,"at":str(player().position)})
	return false
func interaction(at: Vector2, prefix: String, flag: String="") -> bool:
	if not await walk(at):return false
	await key(KEY_E);await frames(4)
	var okay: bool=route.get("_panel").visible and route.get("_body").text.begins_with(prefix)
	if flag!="":okay=okay and route.get(flag)
	steps.append({"interaction":prefix,"at":str(player().position),"passed":okay,"body":route.get("_body").text})
	if not okay:failed=true;await capture("interaction-failed");return false
	await key(KEY_E)
	return true
func panel_check(code: Key, property: String) -> bool:
	var before:=player().position
	await key(code)
	Input.action_press("move_right");await frames(12);release()
	var okay: bool=route.get(property).visible and player().position==before
	await key(KEY_E)
	okay=okay and not route.get(property).visible and player().is_physics_processing()
	steps.append({"panel":property,"movement_frozen_and_resumed":okay,"area":journey.active_id})
	if not okay:failed=true
	return okay
func canopy_check(which: String, expected_faded: bool, label: String) -> bool:
	await frames(22)
	var loop: Node=route.get_node("RiverCrossing/LandingLoop")
	var tree: Sprite2D=loop.get("_landing_tree" if which=="landing" else "_tree")
	var material: ShaderMaterial=loop.get("_landing_material" if which=="landing" else "_canopy_material")
	var opacity: float=material.get_shader_parameter("canopy_opacity")
	var okay: bool=tree.material==material and (opacity<=0.351 if expected_faded else opacity>=0.999)
	steps.append({"canopy":which,"check":label,"opacity":opacity,"material_bound":tree.material==material,"passed":okay})
	if not okay:failed=true
	await capture(label)
	return okay
func _run() -> void:
	var start:=Time.get_ticks_msec()
	journey=load("res://scenes/world_journey.tscn").instantiate()
	journey.set_courier_model(model)
	root.add_child(journey);current_scene=journey
	route=journey.route
	startup_ms=Time.get_ticks_msec()-start
	await frames(45)
	party_id=root.get_node("PlayerParty").active_member().get_instance_id()
	route_id=route.get_instance_id();home_id=journey.active_area.get_instance_id()
	if journey.active_id!="hometown" or player().position!=Vector2(224,280) or player().chibi_model!=model:
		failed=true;finish();return
	await capture("start")
	if not await panel_check(KEY_J,"_notes_panel"):finish();return
	if not await panel_check(KEY_P,"_party_panel"):finish();return
	if not await interaction(Vector2(224,280),"HOME COURTYARD"):finish();return
	# Real movement into the house footprint must stop at the porch.
	Input.action_press("move_up");await frames(45);release()
	var home_collision: bool=player().position.y>=265 and player().position.y<280
	steps.append({"house_collision":home_collision,"at":str(player().position)})
	if not home_collision:failed=true;finish();return
	if not await path([Vector2(224,336),Vector2(560,336),Vector2(560,512),Vector2(768,512)]):finish();return
	if not await walk(Vector2(768,456)):finish();return
	if not await exit_area("move_up","courier_hall"):finish();return
	hall_id=journey.active_area.get_instance_id()
	if not await panel_check(KEY_J,"_notes_panel"):finish();return
	if not await panel_check(KEY_P,"_party_panel"):finish();return
	var before_hall_notices:=flags()
	if not await path([Vector2(72,171),Vector2(72,86)]):finish();return
	if not await interaction(Vector2(72,86),"COURIER BOARD"):finish();return
	if not await path([Vector2(72,171)]):finish();return
	if not await interaction(Vector2(180,171),"SORTING SHELVES"):finish();return
	var notices_safe:bool=before_hall_notices==flags()
	steps.append({"hall_notices_preserve_assignment":notices_safe})
	if not notices_safe:failed=true;finish();return
	if not await interaction(Vector2(132,142),"DISPATCHER","pouch_accepted"):finish();return
	Input.action_press("move_up");await frames(45);release()
	var counter_blocked:bool=player().position.y>=137.9 and player().position.y<143.0
	steps.append({"counter_collision":counter_blocked,"position":str(player().position)})
	if not counter_blocked:failed=true;finish();return
	await capture("hall-counter")
	if not await walk(Vector2(128,224)):finish();return
	if not await exit_area("move_down","hometown"):finish();return
	if not await path([Vector2(768,512),Vector2(976,512),Vector2(976,464)]):finish();return
	Input.action_press("move_right");await frames(50);release()
	var side_blocked: bool=journey.active_id=="hometown" and player().position.x<=1018.1
	steps.append({"entrance_side_wall":side_blocked,"at":str(player().position)})
	if not side_blocked:failed=true;finish();return
	if not await path([Vector2(976,512)]):finish();return
	if not await interaction(Vector2(944,512),"DISPATCH LANE"):finish();return
	if not await walk(Vector2(976,512)):finish();return
	home_exit_frames=total_walk_frames
	if not await exit_area("move_right","route1"):finish();return
	var approach_start:=total_walk_frames
	if not await path([Vector2(-640,512),Vector2(-640,336),Vector2(-432,336),Vector2(-432,192),Vector2(48,192)]):finish();return
	approach_frames=total_walk_frames-approach_start
	if not await interaction(Vector2(64,200),"ROUTE 1","levee_entrance_read"):finish();return
	relay_start_frames=total_walk_frames
	if model=="Male":
		if not await path([Vector2(184,192),Vector2(272,192),Vector2(320,192),Vector2(360,220),Vector2(392,260),Vector2(414,245)]):finish();return
		if not await interaction(Vector2(423,215),"Several old","water_mark_observed"):finish();return
		if not await path([Vector2(410,240),Vector2(402,296),Vector2(430,318),Vector2(430,341),Vector2(427,366),Vector2(414,383),Vector2(395,393),Vector2(344,352)]):finish();return
	else:
		if not await path([Vector2(184,192),Vector2(272,192),Vector2(306,272),Vector2(344,352)]):finish();return
	if not await path([Vector2(318,388),Vector2(320,456)]):finish();return
	var notice_flags:=flags()
	if not await interaction(Vector2(304,454),"OLD LANDING FOOTPATH"):finish();return
	var notice_safe: bool=notice_flags==flags()
	steps.append({"notice_preserves_flags":notice_safe})
	if not notice_safe:failed=true;finish();return
	if not await path([Vector2(354,496),Vector2(378,540)]):finish();return
	if not await interaction(Vector2(398,550),"You slide","delivered"):finish();return
	relay_walk_frames=total_walk_frames-relay_start_frames
	if not await path([Vector2(414,574),Vector2(416,592)]):finish();return
	if model=="Male":
		if not await interaction(Vector2(416,592),"A two-note","heard_calls"):finish();return
	if not await canopy_check("landing",true,"landing-canopy-first"):finish();return
	if not await path([Vector2(420,510)]):finish();return
	if not await canopy_check("landing",false,"landing-canopy-restored"):finish();return
	if not await path([Vector2(424,464),Vector2(424,416)]):finish();return
	if not await path([Vector2(432,416),Vector2(560,416),Vector2(680,416)]):finish();return
	if not await exit_area("move_right","riverfront"):finish();return
	if not await path([Vector2(384,512),Vector2(512,456)]):finish();return
	if not await interaction(Vector2(512,400),"CITY COURIER","city_arrival_registered"):finish();return
	if not await panel_check(KEY_J,"_notes_panel"):finish();return
	if not await path([Vector2(512,456),Vector2(640,512)]):finish();return
	if not await interaction(Vector2(816,512),"CITY ROUTES","city_directions_read"):finish();return
	if not await path([Vector2(384,512),Vector2(320,512),Vector2(32,512)]):finish();return
	if not await exit_area("move_left","route1"):finish();return
	var loop: Node=route.get_node("RiverCrossing/LandingLoop")
	var bound: bool=loop.get("_tree").material==loop.get("_canopy_material") and loop.get("_landing_tree").material==loop.get("_landing_material")
	steps.append({"both_canopies_bound_after_route_return":bound})
	if not bound:failed=true;finish();return
	if not await path([Vector2(424,464),Vector2(420,510),Vector2(416,592)]):finish();return
	if not await canopy_check("landing",true,"landing-canopy-after-return"):finish();return
	if not await path([Vector2(420,510),Vector2(424,464),Vector2(424,416),Vector2(395,393),Vector2(414,383),Vector2(427,366),Vector2(430,341)]):finish();return
	if not await canopy_check("bank",true,"bank-canopy-after-return"):finish();return
	if not await path([Vector2(368,280),Vector2(368,112)]):finish();return
	if not await interaction(Vector2(272,112),"The marker","marker_restored"):finish();return
	if not await path([Vector2(184,112),Vector2(184,192),Vector2(-432,192),Vector2(-432,336),Vector2(-640,336),Vector2(-640,512),Vector2(-740,512)]):finish();return
	if not await exit_area("move_left","hometown"):finish();return
	if not await path([Vector2(768,512),Vector2(768,456)]):finish();return
	if not await exit_area("move_up","courier_hall"):finish();return
	var same_hall:bool=journey.active_area.get_instance_id()==hall_id
	steps.append({"cached_hall_preserved":same_hall})
	if not same_hall:failed=true;finish();return
	if not await walk(Vector2(132,142)):finish();return
	await key(KEY_E);await frames(5)
	var choices: bool=route.get("_choices").visible and route.get("_choices").get_child_count()==(2 if model=="Male" else 1)
	steps.append({"report_choices":choices,"count":route.get("_choices").get_child_count()})
	if not choices:failed=true;finish();return
	if model=="Male":await key(KEY_DOWN)
	await key(KEY_ENTER);await frames(6);await capture("report")
	if not route.report_done or route.reported_calls!=(model=="Male") or route.reported_water_mark!=(model=="Male"):
		failed=true;finish();return
	await key(KEY_E)
	if not await walk(Vector2(128,224)):finish();return
	if not await exit_area("move_down","hometown"):finish();return
	if not await path([Vector2(768,512),Vector2(560,512),Vector2(560,336),Vector2(224,336),Vector2(224,280)]):finish();return
	var preserved: bool=route.get_instance_id()==route_id and journey.active_area.get_instance_id()==home_id and root.get_node("PlayerParty").active_member().get_instance_id()==party_id and root.get_node("PlayerParty").caught.size()==1
	steps.append({"cached_route_and_home_preserved":preserved,"party_member_preserved":preserved,"party_count":root.get_node("PlayerParty").caught.size(),"loaded_area_children":journey.get_children().filter(func(n:Node)->bool:return n is Node2D).size()})
	if not preserved:failed=true
	if not await panel_check(KEY_P,"_party_panel"):finish();return
	await capture("return-home")
	finish()
func finish() -> void:
	release()
	var file:=FileAccess.open(BASE+model.to_lower()+"-walkthrough.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"passed":not failed,"ordinary_input_only":true,"test_teleports":0,"quest_overrides":0,"engine_entrance_arrivals":journey.transitions,"model":model,"startup_ms":startup_ms,"home_walk_frames_before_exit":home_exit_frames,"route_approach_walk_frames":approach_frames,"levee_sign_to_relay_walk_frames":relay_walk_frames,"fixed_fps":60,"flags":flags(),"steps":steps},"\t"))
	file.close();file=null
	print("AREA_ORDINARY_WALK ",model," ",not failed," ",flags())
	call_deferred("_exit",1 if failed else 0)
func _exit(code:int)->void:
	journey.queue_free();current_scene=null
	journey=null;route=null
	await frames(10)
	quit(code)
