extends SceneTree
const BASE := "C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/route1-spaced-landing-review/"
const FLAGS := ["pouch_accepted","levee_entrance_read","city_arrival_registered","city_directions_read","delivered","water_mark_observed","heard_calls","marker_restored","report_done","reported_calls","reported_water_mark"]
var journey: Node2D
var route: Node2D
var steps: Array = []
var failed := false
var model := "Male"
var party_id: int
var route_id: int
var home_id: int
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
	journey=load("res://scenes/world_journey.tscn").instantiate()
	journey.initial_area="route1";journey.set_courier_model(model)
	root.add_child(journey);current_scene=journey;route=journey.route
	await frames(45)
	if not await path([Vector2(-640,512),Vector2(-640,336),Vector2(-432,336),Vector2(-432,192),Vector2(48,192),Vector2(184,192),Vector2(272,192),Vector2(306,272),Vector2(344,352),Vector2(304,392),Vector2(276,368),Vector2(240,344)]):
		await finish_encounter(false);return
	var creature: Area2D=route.get_node("CinderhideEncounter")
	var before:=flags()
	var near: bool=creature.get("_player_nearby") and creature.get_node("Prompt").visible
	await capture("hollow-encounter-before")
	await key(KEY_E);await frames(35)
	var battle: CanvasLayer=route.get_node("BattleScreen")
	var okay: bool=near and battle.visible and battle.get("_foe")==creature.get("creature") and player().chibi_model==model and before==flags()
	steps.append({"ordinary_encounter_started":okay,"nearby_prompt":near,"creature_resource_matches":battle.get("_foe")==creature.get("creature"),"quest_flags_preserved":before==flags()})
	await capture("hollow-battle-start")
	await finish_encounter(okay)
func finish_encounter(okay: bool) -> void:
	release()
	var file:=FileAccess.open(BASE+model.to_lower()+"-encounter.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"passed":okay and not failed,"model":model,"ordinary_input_only":true,"test_teleports":0,"quest_overrides":0,"steps":steps},"\t"));file.close();file=null
	print("SPACED_HOLLOW_ENCOUNTER ",model," ",okay and not failed)
	# Unpause only to clean up this isolated review after its final assertion.
	paused=false
	journey.queue_free();current_scene=null;journey=null;route=null
	await frames(12);quit(0 if okay and not failed else 1)
