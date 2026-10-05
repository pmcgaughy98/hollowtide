extends SceneTree
const OUT:="C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/area-transition-review/"
func _initialize()->void:call_deferred("_run")
func frames(n:int)->void:
	for i in n:await process_frame
func _run()->void:
	var direct:Node2D=load("res://scenes/first_route_prototype.tscn").instantiate()
	direct.get_node("Player").chibi_model="Female"
	root.add_child(direct);current_scene=direct
	await frames(100)
	var okay:bool=current_scene!=null and current_scene.name=="WorldJourney" and current_scene.get("active_id")=="route1"
	var entered_home:=false
	if okay:
		okay=okay and current_scene.get("active_area").get_node("Player").chibi_model=="Female"
		Input.action_press("move_left")
		for i in 150:
			await physics_frame
			if current_scene.get("active_id")=="hometown":
				Input.action_release("move_left");await frames(35)
				entered_home=current_scene.get("active_area").get_node("Player").chibi_model=="Female"
				break
		Input.action_release("move_left")
	var file:=FileAccess.open(OUT+"direct-launch.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"direct_route_connected":okay,"ordinary_exit_to_home":entered_home,"selected_female_preserved":okay and entered_home,"party_count":root.get_node("PlayerParty").caught.size()},"\t"));file.close();file=null
	print("DIRECT_ROUTE_JOURNEY ",okay," HOME ",entered_home)
	current_scene.queue_free();current_scene=null;direct=null
	await frames(12)
	quit(0 if okay and entered_home else 1)
