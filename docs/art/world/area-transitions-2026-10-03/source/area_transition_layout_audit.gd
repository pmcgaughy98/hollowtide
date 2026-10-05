extends SceneTree
const OUT := "C:/Users/pmcga/Documents/Codex/2026-10-01/referenced-chatgpt-conversation-this-is-an/area-transition-review/"
var journey: Node2D
var checks: Array=[]
func _initialize()->void:call_deferred("_run")
func frames(n:int)->void:
	for i in n:await process_frame
func inspect_area(label:String)->void:
	var area:Node2D=journey.active_area
	var scene_count:=0
	for value in journey.cached.values():
		if value.is_inside_tree():scene_count+=1
	checks.append({"area":label,"one_area_in_tree":scene_count==1,"hud_count":journey.find_children("RouteHUD","CanvasLayer",true,false).size(),"music_count":journey.find_children("RouteMusic","AudioStreamPlayer",true,false).size()})
	var bounds:=Rect2(0,0,1024,768) if label!="route1" else Rect2(-768,0,1472,640)
	for sprite in area.get_node("RouteDecor").get_children():
		if not sprite is Sprite2D:continue
		if not sprite.name.begins_with("Cottonwood") and not sprite.name.begins_with("MeadowCottonwood"):continue
		if label=="route1" and not sprite.name.begins_with("MeadowCottonwood"):continue
		var used:Rect2i=sprite.texture.get_image().get_used_rect()
		var corner: Vector2=Vector2(used.position)-sprite.texture.get_size()*0.5+sprite.offset
		var ink:=Rect2(sprite.position+corner*sprite.scale,Vector2(used.size)*sprite.scale)
		checks.append({"tree":str(sprite.name),"area":label,"complete_ink_in_bounds":bounds.encloses(ink),"ink":str(ink)})
func _run()->void:
	journey=load("res://scenes/world_journey.tscn").instantiate()
	root.add_child(journey);current_scene=journey
	await frames(40)
	inspect_area("hometown")
	journey.travel("route1",Vector2(80,192),Vector2.UP)
	await frames(40)
	inspect_area("route1")
	var bodies:Array=journey.route.get_node("RouteDecor/WaylineOffice").find_children("*","StaticBody2D",true,false)
	checks.append({"old_hall_body_count":bodies.size(),"old_hall_collisions_disabled":not bodies.is_empty() and bodies.all(func(body:StaticBody2D)->bool:return body.collision_layer==0)})
	var courier:CharacterBody2D=journey.active_area.get_node("Player")
	Input.action_press("move_up");await frames(60);Input.action_release("move_up")
	checks.append({"ordinary_walk_through_former_hall":courier.position.y<116,"position":str(courier.position),"review_arrival_used":true})
	journey.travel("riverfront",Vector2(320,512),Vector2.RIGHT)
	await frames(40)
	inspect_area("riverfront")
	var okay:=checks.all(func(c:Dictionary)->bool:
		if c.has("one_area_in_tree"):return c.one_area_in_tree and c.hud_count==1 and c.music_count==1
		if c.has("complete_ink_in_bounds"):return c.complete_ink_in_bounds
		if c.has("old_hall_collisions_disabled"):return c.old_hall_collisions_disabled
		return c.ordinary_walk_through_former_hall
	)
	var file:=FileAccess.open(OUT+"layout-audit.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"passed":okay,"checks":checks},"\t"));file.close();file=null
	print("AREA_LAYOUT_AUDIT ",okay)
	journey.queue_free();journey=null;current_scene=null;courier=null
	await frames(10)
	quit(0 if okay else 1)
