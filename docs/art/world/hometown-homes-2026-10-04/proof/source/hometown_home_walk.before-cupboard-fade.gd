extends SceneTree
const BASE := "C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/hometown-homes-2026-10-04/proof/walk/"
# Installed garden script, scene, interaction and prepared texture contract re-read on 2026-10-04.
# Two transparent pixels surround each unresized native bed and cutting row.
const GARDEN_ACTIVITY_PROPERTY := "garden_activity"
const GARDEN_OFFERED_PROPERTY := "cuttings_offered"
const GARDEN_PLANTED_PROPERTY := "cuttings_planted"
const GARDEN_PLANTS_PROPERTY := "planted_sprites"
const NEIGHBOR_PREFIX := "GARDEN NEIGHBOR"
const OPEN_ROW_PREFIX := "OPEN GARDEN BED"
const PLANTED_ROW_PREFIX := "SHARED CUTTINGS"
const GARDEN_TEXTURE_BASE := "res://assets/sprites/world/hometown_garden_2026_10_04/"
const MAP_BOUNDS := Rect2(0,0,1024,768)
# Art-derived room/gate contract supplied by root, 2026-10-04.
# Re-read the installed room/travel scripts once before a coordinated launch.
const HOME_INTERIOR_CONTRACT_READY := true
const HOME_EXTERIOR_DOOR := Vector2(233,242)
const HOME_EXTERIOR_APPROACH := Vector2(233,280)
const HOME_EXTERIOR_RETURN := Vector2(233,280)
const HOME_INTERIOR_ARRIVAL := Vector2(128,208)
const HOME_INTERIOR_EXIT_APPROACH := Vector2(128,216)
const HOME_INTERIOR_EXIT_GATE := Vector2(128,232)
const HOME_INTERIOR_EXIT_PATH := [Vector2(128,144),HOME_INTERIOR_ARRIVAL,HOME_INTERIOR_EXIT_APPROACH]
const HOME_ROOM_ART_NAMES := ["RoomArt","RouteDecor/RoomStoveFront","RouteDecor/RoomCoatFront","RouteDecor/RoomThresholdFront"]
const HOME_ROOM_INTERACTIONS := [
	{"label":"table","waypoints":[Vector2(128,208),Vector2(128,126),Vector2(152,126)],"at":Vector2(152,112),"prefix":"ROUTE TABLE"},
	{"label":"bed","waypoints":[Vector2(128,126),Vector2(106,126)],"at":Vector2(106,106),"prefix":"REST CORNER"},
	{"label":"stove","waypoints":[Vector2(128,126),Vector2(128,151),Vector2(80,151)],"at":Vector2(66,151),"prefix":"HOME STOVE"},
	{"label":"coat","waypoints":[Vector2(128,190),Vector2(174,190)],"at":Vector2(174,186),"prefix":"TRAVEL HOOK"},
]
# Bounds allow one logical pixel around the art-aligned foot contact; exact
# floats do not stand in for proof of physical slide contacts and preserved state.
const HOME_ROOM_COLLISIONS := [
	{"label":"north-wall","waypoints":[Vector2(128,190),Vector2(128,100)],"action":"move_up","axis":"y","minimum":84.0,"maximum":86.0,"frames":45},
	{"label":"west-wall","waypoints":[Vector2(128,190),Vector2(80,190)],"action":"move_left","axis":"x","minimum":41.0,"maximum":43.0,"frames":45},
	{"label":"east-wall","waypoints":[Vector2(128,190)],"action":"move_right","axis":"x","minimum":214.0,"maximum":216.0,"frames":90},
	{"label":"south-left-wall","waypoints":[Vector2(80,190)],"action":"move_down","axis":"y","minimum":210.0,"maximum":212.0,"frames":45},
	{"label":"south-right-wall","waypoints":[Vector2(80,190),Vector2(128,190),Vector2(188,190)],"action":"move_down","axis":"y","minimum":210.0,"maximum":212.0,"frames":45},
	{"label":"bed","waypoints":[Vector2(188,190),Vector2(128,190),Vector2(128,126),Vector2(110,126),Vector2(110,100)],"action":"move_left","axis":"x","minimum":103.0,"maximum":105.0,"frames":45},
	{"label":"table","waypoints":[Vector2(110,100),Vector2(110,126),Vector2(128,126),Vector2(190,126),Vector2(190,122)],"action":"move_up","axis":"y","minimum":111.0,"maximum":113.0,"frames":45},
	{"label":"stool","waypoints":[Vector2(190,126),Vector2(128,126),Vector2(174,126),Vector2(174,124)],"action":"move_up","axis":"y","minimum":118.0,"maximum":120.0,"frames":45},
	{"label":"stove","waypoints":[Vector2(174,126),Vector2(128,126),Vector2(128,151),Vector2(80,151),Vector2(66,151)],"action":"move_left","axis":"x","minimum":64.0,"maximum":66.0,"frames":45},
	{"label":"woodstack","waypoints":[Vector2(80,151),Vector2(80,190),Vector2(80,172)],"action":"move_left","axis":"x","minimum":63.0,"maximum":65.0,"frames":45},
	{"label":"bedside","waypoints":[Vector2(80,172),Vector2(80,126),Vector2(45,126)],"action":"move_up","axis":"y","minimum":121.0,"maximum":123.0,"frames":45},
	{"label":"coat-cabinet","waypoints":[Vector2(45,126),Vector2(80,126),Vector2(128,126),Vector2(128,190),Vector2(204,190)],"action":"move_up","axis":"y","minimum":184.0,"maximum":186.0,"frames":45},
]
const HOME_ROOM_VIEWS := [
	{"label":"stove-behind","waypoints":[Vector2(204,190),Vector2(128,190),Vector2(128,127),Vector2(48,127)]},
	{"label":"coat-behind","waypoints":[Vector2(128,127),Vector2(128,144),Vector2(208,144)]},
]
const FLAGS := ["pouch_accepted","levee_entrance_read","city_arrival_registered","city_directions_read","delivered","water_mark_observed","heard_calls","marker_restored","report_done","reported_calls","reported_water_mark"]
var journey: Node2D
var route: Node2D
var steps: Array = []
var failed := false
var completed_walk := false
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
var garden_id: int
var initial_party_state: Dictionary = {}
var planted_art_state: Dictionary = {}
var courtyard_home_id: int
var courtyard_home_player_id: int
var courtyard_home_art: Array = []
var home_loop_count := 0
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
func capture(label: String) -> bool:
	await RenderingServer.frame_post_draw
	var output_path:String=BASE+model.to_lower()+"-"+label+".png"
	var frame:Image=root.get_texture().get_image()
	if frame==null or frame.is_empty():
		failed=true
		steps.append({"capture":label,"saved":false,"reason":"missing viewport image"})
		return false
	var save_error:int=frame.save_png(output_path)
	var okay:bool=save_error==OK and FileAccess.file_exists(output_path)
	steps.append({"capture":label,"saved":okay,"save_error":save_error,"path":output_path})
	if not okay:failed=true
	return okay
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
func historic_loop() -> bool:
	var unchanged:=flags()
	if not await path([Vector2(880,512),Vector2(880,64),Vector2(880,24)]):return false
	if not await exit_area("move_up","historic_street"):return false
	var area:Node2D=journey.active_area
	var area_id:=area.get_instance_id()
	if not await panel_check(KEY_P,"_party_panel"):return false
	if not await interaction(Vector2(384,664),"CITY ADDRESS CHECK"):return false
	if not await path([Vector2(416,664),Vector2(416,480),Vector2(384,480)]):return false
	if not await interaction(Vector2(384,428),"REPAIR WORKSHOP"):return false
	await capture("workshop")
	Input.action_press("move_up");await frames(45);release()
	var workshop_collision:bool=player().position.y>=407.9 and player().position.y<429
	steps.append({"workshop_facade_collision":workshop_collision})
	if not workshop_collision:failed=true;return false
	if not await path([Vector2(384,480),Vector2(424,480)]):return false
	if not await interaction(Vector2(424,438),"WORKSHOP KEEPER"):return false
	var no_unearned_observations:bool=not area.lintel_checked and not area.ledger_checked and not area.handoff_verified
	steps.append({"keeper_hint_does_not_grant_observations":no_unearned_observations})
	if not no_unearned_observations:failed=true;return false
	await capture("keeper")
	if not await path([Vector2(424,480),Vector2(656,480),Vector2(656,244),Vector2(365,244)]):return false
	if not await interaction(Vector2(365,244),"RESIDENTIAL DOORSTEP"):return false
	await capture("residential-doorstep")
	Input.action_press("move_up");await frames(35);release()
	var residential_collision:bool=player().position.y>=231.9 and player().position.y<245
	steps.append({"residential_doorway_collision":residential_collision})
	if not residential_collision:failed=true;return false
	if not await path([Vector2(365,244),Vector2(128,244),Vector2(128,480),Vector2(224,480)]):return false
	if not await interaction(Vector2(224,428),"PUBLIC STREET LEDGER"):return false
	await capture("historic-ledger")
	# The visible facade blocks northward walking.
	Input.action_press("move_up");await frames(45);release()
	var facade:bool=player().position.y>=407.9 and player().position.y<429
	steps.append({"historic_ledger_facade_collision":facade})
	if not facade:failed=true;return false
	if not await path([Vector2(224,480),Vector2(544,480)]):return false
	if not await interaction(Vector2(544,428),"REPAIRED SHOP"):return false
	await capture("historic-shop")
	if not await path([Vector2(544,480),Vector2(424,480)]):return false
	if not await interaction(Vector2(424,438),"WORKSHOP KEEPER"):return false
	await key(KEY_E)
	var directs_to_branch:bool=route.get("_body").text.contains("Take the current street address")
	steps.append({"keeper_reflects_checked_addresses":directs_to_branch})
	if not directs_to_branch:failed=true;return false
	await key(KEY_E)
	if not await panel_check(KEY_J,"_notes_panel"):return false
	await key(KEY_J)
	var findings:bool=route.get("_notes_body").text.contains("Shop lintel: old 6") and route.get("_notes_body").text.contains("Ledger: old 6")
	await key(KEY_E)
	steps.append({"historic_findings_in_shared_notes":findings})
	if not findings:failed=true;return false
	if not await path([Vector2(544,480),Vector2(416,480),Vector2(416,704),Vector2(384,784),Vector2(384,866)]):return false
	if not await exit_area("move_down","riverfront"):return false
	if not await path([Vector2(880,512),Vector2(640,512),Vector2(512,456),Vector2(512,400)]):return false
	await key(KEY_E)
	if not route.get("_choices").visible or route.get("_choices").get_child_count()!=2:
		failed=true;return false
	# Choose the incorrect retained lintel first through the ordinary UI.
	await key(KEY_ENTER)
	var wrong:bool=not area.handoff_verified and area.last_submitted_number==6 and route.get("_body").text.contains("handoff is still open")
	steps.append({"wrong_old_number_keeps_activity_open":wrong})
	await capture("historic-wrong-number")
	if not wrong:failed=true;return false
	await key(KEY_E);await key(KEY_E);await key(KEY_DOWN);await key(KEY_ENTER)
	var correct:bool=area.handoff_verified and area.last_submitted_number==18 and flags()==unchanged
	steps.append({"current_number_verifies_handoff":correct,"original_route_flags_exact":flags()==unchanged})
	await capture("historic-handoff")
	if not correct:failed=true;return false
	await key(KEY_E)
	if not await path([Vector2(512,456),Vector2(640,512),Vector2(880,512),Vector2(880,24)]):return false
	if not await exit_area("move_up","historic_street"):return false
	var same:bool=journey.active_area.get_instance_id()==area_id and area.handoff_verified and area.get("_status").text=="18 / VERIFIED"
	steps.append({"cached_historic_area_and_verified_board":same})
	if not same:failed=true;return false
	if not await path([Vector2(416,848),Vector2(416,664),Vector2(416,480),Vector2(424,480)]):return false
	if not await interaction(Vector2(424,438),"WORKSHOP KEEPER"):return false
	await key(KEY_E)
	var verified_keeper:bool=route.get("_body").text.contains("route is marked eighteen")
	steps.append({"keeper_reflects_verified_handoff":verified_keeper})
	if not verified_keeper:failed=true;return false
	await key(KEY_E)
	if not await path([Vector2(424,480),Vector2(112,480),Vector2(112,240),Vector2(104,144),Vector2(72,144)]):return false
	await frames(24)
	var tree:Sprite2D=area.get("_trees")[0]
	var opacity:float=tree.material.get_shader_parameter("canopy_opacity")
	var faded:bool=opacity<=0.351
	steps.append({"historic_canopy_after_return":faded,"opacity":opacity})
	await capture("historic-canopy-after-return")
	if not faded:failed=true;return false
	if not await path([Vector2(104,144),Vector2(104,224)]):return false
	await frames(24)
	var restored:bool=tree.material.get_shader_parameter("canopy_opacity")>=0.999
	steps.append({"historic_canopy_restored":restored})
	if not restored:failed=true;return false
	if not await path([Vector2(112,480),Vector2(168,568),Vector2(184,664),Vector2(304,728),Vector2(384,784),Vector2(384,866)]):return false
	if not await exit_area("move_down","riverfront"):return false
	if not await path([Vector2(880,512),Vector2(816,512)]):return false
	var preserved:bool=flags()==unchanged and root.get_node("PlayerParty").active_member().get_instance_id()==party_id
	steps.append({"historic_complete_loop_preserves_primary_route_and_party":preserved})
	if not preserved:failed=true;return false
	return true

func party_state() -> Dictionary:
	var party: Node=root.get_node("PlayerParty")
	var members: Array=[]
	for member in party.caught:
		var known: Array=[]
		for move in member.known: known.append(move.get_instance_id())
		members.append({"member":member.get_instance_id(),"species":member.species.get_instance_id(),"known":known})
	return {"party":party.get_instance_id(),"active_slot":party.active_slot,"members":members}
func original_core() -> Dictionary:
	return {"flags":flags(),"controller":route.get_instance_id(),"player":route.get("player").get_instance_id(),"active_player":player().get_instance_id(),"model":player().chibi_model,"speed":player().speed,"party":party_state(),"objective":route.get("_objective").text,"board":route.get("_board").text,"notes":route.get("_notes_body").text}
func garden_module() -> Node:
	return journey.active_area.get(GARDEN_ACTIVITY_PROPERTY)
func visible_bounds(sprite: Sprite2D) -> Rect2:
	var used:Rect2i=sprite.texture.get_image().get_used_rect()
	var local_top:Vector2=Vector2(used.position)+sprite.offset
	if sprite.centered:local_top-=sprite.texture.get_size()*0.5
	var bounds:=Rect2(sprite.to_global(local_top),Vector2.ZERO)
	for corner in [Vector2.ZERO,Vector2(used.size.x,0),Vector2(0,used.size.y),Vector2(used.size)]:
		bounds=bounds.expand(sprite.to_global(local_top+corner))
	return bounds
func sprite_state(sprite: Sprite2D) -> Dictionary:
	return {"id":sprite.get_instance_id(),"texture_id":sprite.texture.get_instance_id(),"texture_path":sprite.texture.resource_path,"texture_size":str(sprite.texture.get_size()),"global_position":str(sprite.global_position),"offset":str(sprite.offset),"scale":str(sprite.global_scale),"centered":sprite.centered,"visible":sprite.visible,"bounds":str(visible_bounds(sprite))}
func planted_rows_state() -> Array:
	var rows:Array=[]
	for sprite in garden_module().get(GARDEN_PLANTS_PROPERTY):rows.append(sprite_state(sprite))
	return rows
func garden_art_state() -> Dictionary:
	var decor:Node=journey.active_area.get_node("RouteDecor")
	var left:Node2D=decor.get_node("SharedGardenLeftBed")
	var right:Node2D=decor.get_node("SharedGardenRightBed")
	var existing_rows:Array=[]
	for row in 3:existing_rows.append(sprite_state(left.get_node("ExistingCuttings"+str(row))))
	return {"left_bed_group":left.get_instance_id(),"right_bed_group":right.get_instance_id(),"left_bed":sprite_state(left.get_node("TimberBed")),"right_bed":sprite_state(right.get_node("TimberBed")),"neighbor":sprite_state(decor.get_node("GardenNeighbor")),"notice":sprite_state(decor.get_node("GardenNotice")),"existing_rows":existing_rows,"planted_rows":planted_rows_state()}
func garden_bounds_check(label: String) -> bool:
	var decor:Node=journey.active_area.get_node("RouteDecor")
	var sprites:Array=[decor.get_node("GardenNeighbor"),decor.get_node("GardenNotice")]
	var details:Array=[]
	var okay:bool=true
	for pair in [["SharedGardenLeftBed",Rect2(377,518,54,50),Vector2(404,568)],["SharedGardenRightBed",Rect2(457,518,54,50),Vector2(484,568)]]:
		var bed:Node2D=decor.get_node(pair[0])
		var anchor:Vector2=pair[2]
		var art:Sprite2D=bed.get_node("TimberBed")
		# Dynamically added collision children have engine-generated names.
		# Find the shape by type and reject a missing or ambiguous footprint.
		var footprint_body:Node=bed.get_node_or_null("BedFootprint")
		var collision_shapes:Array=[]
		if footprint_body!=null:
			for child in footprint_body.get_children():
				if child is CollisionShape2D:collision_shapes.append(child)
		if collision_shapes.size()!=1:
			failed=true
			steps.append({"garden_collision_shape_guard":label,"bed":pair[0],"shape_count":collision_shapes.size(),"passed":false})
			return false
		var shape:CollisionShape2D=collision_shapes[0]
		if shape==null or not (shape.shape is RectangleShape2D):
			failed=true
			steps.append({"garden_collision_shape_guard":label,"bed":pair[0],"reason":"missing rectangular shape resource","passed":false})
			return false
		var rectangle:RectangleShape2D=shape.shape
		var footprint:=Rect2(shape.global_position-rectangle.size*0.5,rectangle.size)
		var contract:bool=bed.global_position==anchor and footprint==pair[1] and art.texture.get_size()==Vector2(58,54) and art.texture.get_image().get_used_rect().size==Vector2i(54,50) and art.global_scale==Vector2.ONE and art.texture.resource_path==GARDEN_TEXTURE_BASE+"timber_bed.png"
		details.append({"bed":pair[0],"exact_native_anchor_art_collision":contract,"footprint":str(footprint)})
		okay=okay and contract
		sprites.append(art)
		var row_count:int=0
		for row in 3:
			var row_name:String=("ExistingCuttings" if pair[0]=="SharedGardenLeftBed" else "PlantedCuttings")+str(row)
			if bed.has_node(row_name):
				row_count+=1
				var cutting:Sprite2D=bed.get_node(row_name)
				var row_contract:bool=cutting.global_position==Vector2(anchor.x,536+row*12) and cutting.texture.get_size()==Vector2(42,22) and cutting.texture.get_image().get_used_rect().size==Vector2i(38,18) and cutting.global_scale==Vector2.ONE and cutting.texture.resource_path==GARDEN_TEXTURE_BASE+"cuttings_row.png"
				details.append({"row":row_name,"exact_native_anchor_art":row_contract,"state":sprite_state(cutting)})
				okay=okay and row_contract
				sprites.append(cutting)
		var expected_rows:int=3 if pair[0]=="SharedGardenLeftBed" or garden_module().get(GARDEN_PLANTED_PROPERTY) else 0
		okay=okay and row_count==expected_rows
		details.append({"bed":pair[0],"row_count":row_count,"expected_row_count":expected_rows})
	for sprite in sprites:
		var bounds:=visible_bounds(sprite)
		var fits:bool=bounds.has_area() and MAP_BOUNDS.encloses(bounds)
		okay=okay and fits
		details.append({"sprite":str(sprite.get_path()),"visible_bounds":str(bounds),"all_visible_pixels_inside_map":fits})
	var neighbor:Sprite2D=decor.get_node("GardenNeighbor")
	var notice:Sprite2D=decor.get_node("GardenNotice")
	var anchors:bool=neighbor.global_position==Vector2(368,480) and neighbor.global_scale==Vector2.ONE and notice.global_position==Vector2(472,594)
	okay=okay and anchors
	steps.append({"garden_visible_bounds_check":label,"native_neighbor_notice_anchors":anchors,"details":details,"passed":okay})
	if not okay:failed=true
	return okay
func garden_state() -> Dictionary:
	var module: Node=garden_module()
	return {"module":module.get_instance_id(),"offered":module.get(GARDEN_OFFERED_PROPERTY),"planted":module.get(GARDEN_PLANTED_PROPERTY),"rows":planted_rows_state()}
func garden_dialogue(at: Vector2, prefix: String, label: String) -> bool:
	if not await walk(at):return false
	await key(KEY_J);await key(KEY_E)
	var before:=original_core()
	await key(KEY_E);await frames(4)
	var message:String=route.get("_body").text
	var stopped:=player().position
	Input.action_press("move_right");await frames(12);release()
	var frozen:bool=route.get("_panel").visible and not player().is_physics_processing() and player().position==stopped
	var okay:bool=frozen and message.begins_with(prefix)
	await capture(label)
	await key(KEY_E)
	okay=okay and not route.get("_panel").visible and player().is_physics_processing()
	await key(KEY_J);await key(KEY_E)
	var exact:bool=before==original_core()
	okay=okay and exact
	steps.append({"garden_dialogue":label,"body":message,"at":str(stopped),"panel_froze_and_resumed":frozen and player().is_physics_processing(),"original_controller_flags_party_objective_board_notes_exact":exact,"garden":garden_state(),"passed":okay})
	if not okay:failed=true
	return okay
func garden_visit(first_visit: bool) -> bool:
	var unchanged:=flags()
	if not await path([Vector2(224,336),Vector2(560,336),Vector2(560,512),Vector2(560,616),Vector2(448,616)]):return false
	if not await garden_dialogue(Vector2(448,608),"SHARED GARDEN","garden-notice" if first_visit else "garden-notice-return"):return false
	var module: Node=garden_module()
	if not garden_bounds_check("before-offer" if first_visit else "cached-return"):return false
	if first_visit:
		garden_id=module.get_instance_id()
		var fresh:bool=not module.get(GARDEN_OFFERED_PROPERTY) and not module.get(GARDEN_PLANTED_PROPERTY) and module.get(GARDEN_PLANTS_PROPERTY).is_empty()
		steps.append({"garden_initially_unoffered_unplanted":fresh})
		if not fresh:failed=true;return false
	else:
		var retained:bool=module.get_instance_id()==garden_id and module.get(GARDEN_OFFERED_PROPERTY) and module.get(GARDEN_PLANTED_PROPERTY) and garden_art_state()==planted_art_state
		steps.append({"cached_garden_offering_planting_and_exact_art_retained":retained,"garden":garden_state(),"art":garden_art_state()})
		if not retained:failed=true;return false
	if not await path([Vector2(528,608),Vector2(528,582)]):return false
	if first_visit:
		if not await garden_dialogue(Vector2(484,582),OPEN_ROW_PREFIX,"row-before-cuttings"):return false
		var no_unearned:bool=not module.get(GARDEN_OFFERED_PROPERTY) and not module.get(GARDEN_PLANTED_PROPERTY) and module.get(GARDEN_PLANTS_PROPERTY).is_empty()
		steps.append({"row_cannot_plant_without_cuttings":no_unearned})
		if not no_unearned:failed=true;return false
		Input.action_press("move_up");await frames(45);release()
		var bed_solid:bool=player().position.y>=575.9 and player().position.y<582.1
		steps.append({"garden_right_bed_blocks_entry":bed_solid,"at":str(player().position)})
		if not bed_solid:failed=true;return false
	# The southern perimeter at y584 passes above the reused notice's foot solid.
	# Walk the complete clear perimeter and central aisle through ordinary input.
	if not await path([Vector2(528,584),Vector2(352,584),Vector2(352,504),Vector2(448,504),Vector2(528,504),Vector2(528,584),Vector2(448,584),Vector2(448,504),Vector2(368,504)]):return false
	if not await garden_dialogue(Vector2(368,504),NEIGHBOR_PREFIX,"garden-neighbor" if first_visit else "garden-neighbor-return"):return false
	var offered:bool=module.get(GARDEN_OFFERED_PROPERTY) and (not module.get(GARDEN_PLANTED_PROPERTY) if first_visit else module.get(GARDEN_PLANTED_PROPERTY))
	var neighbor_check:String="neighbor_offers_cuttings_without_planting" if first_visit else "neighbor_acknowledges_cached_planting"
	steps.append({neighbor_check:offered})
	if not offered:failed=true;return false
	if not await path([Vector2(448,504),Vector2(448,592)]):return false
	if not await garden_dialogue(Vector2(484,582),PLANTED_ROW_PREFIX,"garden-planting" if first_visit else "garden-planted-row-return"):return false
	var planted:bool=module.get(GARDEN_OFFERED_PROPERTY) and module.get(GARDEN_PLANTED_PROPERTY)
	var plants: Array=module.get(GARDEN_PLANTS_PROPERTY)
	var visible_plants:bool=plants.size()==3
	for plant in plants:visible_plants=visible_plants and plant.visible and plant.is_inside_tree()
	steps.append({"garden_planting_visible":planted and visible_plants,"visible_cuttings":plants.size(),"original_route_flags_exact":unchanged==flags()})
	if not planted or not visible_plants or unchanged!=flags():failed=true;return false
	if not garden_bounds_check("planted" if first_visit else "planted-cached-return"):return false
	var before_repeat:=garden_state()
	var art_before_repeat:=garden_art_state()
	if not await garden_dialogue(Vector2(484,582),PLANTED_ROW_PREFIX,"garden-planting-repeat" if first_visit else "garden-planted-row-repeat-return"):return false
	var repeat_safe:bool=before_repeat==garden_state() and unchanged==flags() and art_before_repeat==garden_art_state()
	steps.append({"repeat_planting_keeps_exact_rows_textures_positions_and_original_state":repeat_safe})
	if not repeat_safe:failed=true;return false
	if not await path([Vector2(448,592),Vector2(448,504)]):return false
	if not await garden_dialogue(Vector2(368,504),NEIGHBOR_PREFIX,"neighbor-after-planting" if first_visit else "neighbor-after-return"):return false
	if first_visit:planted_art_state=garden_art_state()
	elif planted_art_state!=garden_art_state():failed=true;return false
	if not await path([Vector2(352,504),Vector2(352,584),Vector2(352,616),Vector2(560,616),Vector2(560,512),Vector2(560,336),Vector2(224,336),Vector2(224,280)]):return false
	return true
func home_original_core() -> Dictionary:
	var values:=original_core()
	# WorldJourney binds its unchanged controller to the currently active courier.
	# Verify that binding separately while comparing the unchanged route/party data.
	values.erase("player");values.erase("active_player")
	return values
func home_art_state() -> Array:
	var output:Array=[]
	for path_name in HOME_ROOM_ART_NAMES:
		var node:Node=journey.active_area.get_node_or_null(path_name)
		if node==null or not (node is Sprite2D):return []
		var sprite:Sprite2D=node
		output.append({"node":path_name,"state":sprite_state(sprite),"z_index":sprite.z_index})
	return output
func home_art_contract() -> bool:
	var details:Array=[]
	var okay:bool=true
	var room_bounds:=Rect2(0,0,256,256)
	for path_name in HOME_ROOM_ART_NAMES:
		var node:Node=journey.active_area.get_node_or_null(path_name)
		if node==null or not (node is Sprite2D):
			failed=true
			steps.append({"home_native_art_contract":false,"reason":"missing expected room sprite","node":path_name})
			return false
		var sprite:Sprite2D=node
		if sprite.texture==null:
			failed=true
			steps.append({"home_native_art_contract":false,"reason":"missing room texture","node":path_name})
			return false
		var fits:bool=room_bounds.encloses(visible_bounds(sprite)) and visible_bounds(sprite).has_area()
		var native:bool=sprite.global_scale==Vector2.ONE and sprite.texture_filter==CanvasItem.TEXTURE_FILTER_NEAREST and sprite.visible
		if path_name=="RoomArt":native=native and sprite.texture.get_size()==Vector2(256,256)
		if path_name=="RouteDecor/RoomStoveFront":native=native and sprite.global_position.y==177
		if path_name=="RouteDecor/RoomCoatFront":native=native and sprite.global_position.y==176
		okay=okay and fits and native
		details.append({"node":path_name,"native_unresized_and_visible":native,"visible_pixels_inside_room":fits,"state":sprite_state(sprite)})
	steps.append({"home_native_art_contract":okay,"visit":home_loop_count,"sprites":details})
	if not okay:failed=true
	return okay
func home_room_view(spec: Dictionary, label: String) -> bool:
	var before:=home_original_core()
	if not await path(spec["waypoints"]):return false
	var okay:bool=journey.active_id=="courtyard_home" and not journey.transitioning and before==home_original_core() and route.get("player")==player() and home_art_state()==courtyard_home_art
	steps.append({"home_foreground_view":spec["label"],"visit":home_loop_count,"at":str(player().position),"original_state_and_native_art_exact":okay,"passed":okay})
	if not okay:failed=true;return false
	return await capture(label)
func home_dialogue(spec: Dictionary, label: String) -> bool:
	if not await path(spec["waypoints"]):return false
	if not await walk(spec["at"]):return false
	await key(KEY_J);await key(KEY_E)
	var before:=home_original_core()
	await key(KEY_E);await frames(4)
	var message:String=route.get("_body").text
	var position_before:=player().position
	Input.action_press("move_right");await frames(12);release()
	var frozen:bool=route.get("_panel").visible and not player().is_physics_processing() and player().position==position_before
	var okay:bool=frozen and message.begins_with(spec["prefix"])
	if not await capture(label):return false
	await key(KEY_E)
	okay=okay and not route.get("_panel").visible and player().is_physics_processing()
	await key(KEY_J);await key(KEY_E)
	var core_exact:bool=before==home_original_core()
	okay=okay and core_exact and route.get("player")==player()
	steps.append({"home_dialogue":spec["label"],"visit":home_loop_count,"body":message,"at":str(position_before),"panel_froze_and_resumed":frozen and player().is_physics_processing(),"original_flags_notes_objective_board_controller_party_exact":core_exact,"active_player_bound":route.get("player")==player(),"passed":okay})
	if not okay:failed=true
	return okay
func home_room_collision(spec: Dictionary, label: String) -> bool:
	if not await path(spec["waypoints"]):return false
	var before:=home_original_core()
	var start_position:=player().position
	Input.action_press(spec["action"]);await frames(spec["frames"]);release()
	if journey.active_id!="courtyard_home" or journey.transitioning:
		failed=true
		steps.append({"home_collision":spec["label"],"reason":"unexpected doorway crossing","passed":false})
		return false
	var coordinate:float=player().position.x if spec["axis"]=="x" else player().position.y
	var okay:bool=coordinate>=spec["minimum"] and coordinate<=spec["maximum"] and player().get_slide_collision_count()>0 and before==home_original_core() and player().is_physics_processing()
	steps.append({"home_collision":spec["label"],"visit":home_loop_count,"start":str(start_position),"stopped":str(player().position),"slide_contacts":player().get_slide_collision_count(),"original_state_exact":before==home_original_core(),"passed":okay})
	if not okay:failed=true;return false
	if not await capture(label):return false
	return true
func home_loop(first_visit: bool) -> bool:
	if not HOME_INTERIOR_CONTRACT_READY or HOME_ROOM_INTERACTIONS.is_empty() or HOME_ROOM_COLLISIONS.is_empty():
		failed=true
		steps.append({"home_contract_ready":false,"reason":"room contract is disabled or required checks are missing"})
		return false
	if journey.active_id!="hometown":failed=true;return false
	home_loop_count+=1
	await key(KEY_J);await key(KEY_E)
	var before:=home_original_core()
	var exterior_player_id:=player().get_instance_id()
	var garden_before:=garden_state()
	var garden_art_before:=garden_art_state()
	var transition_start:int=journey.transitions.size()
	if not await walk(HOME_EXTERIOR_APPROACH):return false
	if not await exit_area("move_up","courtyard_home"):return false
	var entry_matches:bool=player().position.distance_to(HOME_INTERIOR_ARRIVAL)<0.1 and route.get("player")==player() and player().chibi_model==model and home_original_core()==before
	steps.append({"home_entry":home_loop_count,"door":str(HOME_EXTERIOR_DOOR),"expected_arrival":str(HOME_INTERIOR_ARRIVAL),"actual_arrival":str(player().position),"original_core_exact":home_original_core()==before,"active_player_bound":route.get("player")==player(),"passed":entry_matches})
	if not entry_matches:failed=true;return false
	if not home_art_contract():return false
	if first_visit:
		courtyard_home_id=journey.active_area.get_instance_id()
		courtyard_home_player_id=player().get_instance_id()
		courtyard_home_art=home_art_state()
	else:
		var cached:bool=journey.active_area.get_instance_id()==courtyard_home_id and player().get_instance_id()==courtyard_home_player_id and home_art_state()==courtyard_home_art
		steps.append({"cached_home_interior_player_and_art_exact":cached,"visit":home_loop_count})
		if not cached:failed=true;return false
	if not await capture("home-entry-first" if first_visit else "home-entry-cached-return"):return false
	if not await panel_check(KEY_J,"_notes_panel"):return false
	if not await panel_check(KEY_P,"_party_panel"):return false
	for spec in HOME_ROOM_INTERACTIONS:
		if not await home_dialogue(spec,"home-"+str(spec["label"])+( "-first" if first_visit else "-cached-return")):return false
	for spec in HOME_ROOM_COLLISIONS:
		if not await home_room_collision(spec,"home-collision-"+str(spec["label"])+( "-first" if first_visit else "-cached-return")):return false
	for spec in HOME_ROOM_VIEWS:
		if not await home_room_view(spec,"home-view-"+str(spec["label"])+( "-first" if first_visit else "-cached-return")):return false
	if home_art_state()!=courtyard_home_art:failed=true;return false
	if not await path(HOME_INTERIOR_EXIT_PATH):return false
	if not await exit_area("move_down","hometown"):return false
	var exterior_arrival:bool=player().position.distance_to(HOME_EXTERIOR_RETURN)<0.1
	var before_idle_gates:int=journey.transitions.size()
	await frames(45)
	var no_bounce:bool=journey.active_id=="hometown" and not journey.transitioning and journey.transitions.size()==before_idle_gates
	if not no_bounce:failed=true;return false
	await key(KEY_J);await key(KEY_E)
	var original_exact:bool=home_original_core()==before and player().get_instance_id()==exterior_player_id and journey.active_area.get_instance_id()==home_id and route.get("player")==player() and party_state()==initial_party_state and route.get_instance_id()==route_id
	var garden_exact:bool=garden_state()==garden_before and garden_art_state()==garden_art_before
	var cached_room:bool=journey.cached["courtyard_home"].get_instance_id()==courtyard_home_id and journey.cached["courtyard_home"].get_node("Player").get_instance_id()==courtyard_home_player_id
	var gates:bool=journey.transitions.size()==transition_start+2
	var one_live_area:bool=journey.get_children().filter(func(n:Node)->bool:return n is Node2D).size()==1
	var okay:bool=exterior_arrival and no_bounce and original_exact and garden_exact and cached_room and gates and one_live_area
	steps.append({"home_loop_complete":home_loop_count,"expected_interior_exit_gate":str(HOME_INTERIOR_EXIT_GATE),"exact_exterior_arrival":exterior_arrival,"idle_after_return_no_bounce":no_bounce,"original_flags_notes_objective_board_controller_party_and_home_player_exact":original_exact,"cached_garden_all_art_and_local_state_exact":garden_exact,"cached_interior_and_player_exact":cached_room,"two_real_home_gates":gates,"one_live_area":one_live_area,"passed":okay})
	if not okay:failed=true;return false
	if not await capture("home-exterior-first" if first_visit else "home-exterior-after-full-journey"):return false
	return true

func final_route_check() -> bool:
	var expected:Dictionary={}
	for name in FLAGS:expected[name]=true
	for name in ["water_mark_observed","heard_calls","reported_calls","reported_water_mark"]:expected[name]=model=="Male"
	var same:bool=flags()==expected and party_state()==initial_party_state and route.get_instance_id()==route_id and journey.active_area.get_instance_id()==home_id
	var gates:bool=journey.transitions.size()==16 and home_loop_count==2
	var notes:bool=route.get("_notes_body").text.contains("REPORTED") and route.get("_notes_body").text.contains("Empty post")
	var expected_calls:bool=route.get("_notes_body").text.contains("Two-note call")== (model=="Male")
	var expected_water:bool=route.get("_notes_body").text.contains("Undated high-water cuts")== (model=="Male")
	var result:bool=same and gates and notes and expected_calls and expected_water
	steps.append({"expected_final_flags":expected,"exact_final_flags":flags()==expected,"original_party_and_known_moves_exact":party_state()==initial_party_state,"sixteen_real_gate_crossings_and_two_home_loops":gates,"report_notes":notes,"male_or_female_observation_notes":expected_calls and expected_water,"passed":result})
	if not result:failed=true
	return result

func _run() -> void:
	var start:=Time.get_ticks_msec()
	journey=load("res://scenes/world_journey.tscn").instantiate()
	journey.set_courier_model(model)
	root.add_child(journey);current_scene=journey
	route=journey.route
	startup_ms=Time.get_ticks_msec()-start
	await frames(45)
	party_id=root.get_node("PlayerParty").active_member().get_instance_id()
	initial_party_state=party_state()
	route_id=route.get_instance_id();home_id=journey.active_area.get_instance_id()
	if journey.active_id!="hometown" or player().position!=Vector2(224,280) or player().chibi_model!=model:
		failed=true;finish();return
	await capture("start")
	if not await panel_check(KEY_J,"_notes_panel"):finish();return
	if not await panel_check(KEY_P,"_party_panel"):finish();return
	if not await interaction(Vector2(224,280),"HOME COURTYARD"):finish();return
	# The door now enters a real room. Check the facade beside its opening.
	if not await walk(Vector2(196,280)):finish();return
	Input.action_press("move_up");await frames(45);release()
	var home_collision: bool=journey.active_id=="hometown" and player().position.y>=265 and player().position.y<280
	steps.append({"off_door_house_facade_collision":home_collision,"at":str(player().position)})
	if not home_collision:failed=true;finish();return
	if not await walk(Vector2(196,280)):finish();return
	if not await home_loop(true):finish();return
	if not await garden_visit(true):finish();return
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
	if not await historic_loop():finish();return
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
	if not await garden_visit(false):finish();return
	if not await home_loop(false):finish();return
	if not await final_route_check():finish();return
	if not await capture("return-home"):finish();return
	completed_walk=true
	finish()
func finish() -> void:
	# An early coroutine return must never turn into a successful journey.
	failed=failed or not completed_walk
	release()
	var file:=FileAccess.open(BASE+model.to_lower()+"-walkthrough.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"passed":not failed,"completed_walk":completed_walk,"home_loop_count":home_loop_count,"home_contract_ready":HOME_INTERIOR_CONTRACT_READY,"ordinary_input_only":true,"test_teleports":0,"quest_overrides":0,"engine_entrance_arrivals":journey.transitions,"model":model,"startup_ms":startup_ms,"home_walk_frames_before_exit":home_exit_frames,"route_approach_walk_frames":approach_frames,"levee_sign_to_relay_walk_frames":relay_walk_frames,"fixed_fps":60,"flags":flags(),"steps":steps},"\t"))
	file.close();file=null
	print("AREA_ORDINARY_WALK ",model," ",not failed," ",flags())
	call_deferred("_exit",1 if failed else 0)
func _exit(code:int)->void:
	journey.queue_free();current_scene=null
	journey=null;route=null
	await frames(10)
	quit(code)
