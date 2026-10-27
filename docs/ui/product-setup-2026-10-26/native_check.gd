extends SceneTree
const W := "D:/dev/hollowtide-product-setup-20261026"
const UI := preload("res://scripts/ui/ui_style.gd")
const Team := preload("res://scripts/town/team_state.gd")
var checks: Array=[]
func _initialize() -> void:_run.call_deferred()
func frames(n: int) -> void:
	for i in n:await process_frame
func check(label: String, good: bool) -> void:
	checks.append({"check":label,"passed":good});print(label,": ","PASS" if good else "FAIL")
func _run() -> void:
	Team.save_path="user://product-setup-private.save";Team.erase_save();Team.start([[0,0]]);Team.save();var saved:=FileAccess.get_sha256(Team.save_path)
	check("Window icon uses Hollowtide PNG",ProjectSettings.get_setting("application/config/icon")=="res://icon.png")
	check("Engine splash image disabled",not ProjectSettings.get_setting("application/boot_splash/show_image"))
	check("Plain splash matches black clear colour",ProjectSettings.get_setting("application/boot_splash/bg_color")==Color.BLACK and ProjectSettings.get_setting("rendering/environment/defaults/default_clear_color")==Color.BLACK)
	check("Campaign entry unchanged",ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/creature_opening.tscn")
	check("Native development helper still loads",root.get_node_or_null("_mcp_game_helper")!=null)
	var im:=Image.load_from_file("res://icon.png");check("Opaque256px app icon loads",im.get_size()==Vector2i(256,256) and im.get_pixel(0,0).a==1.0)
	root.size=Vector2i(1152,648);root.content_scale_size=root.size;root.title="Hollowtide | product check"
	var title: Node=load("res://scenes/creature_opening.tscn").instantiate();root.add_child(title)
	await frames(3);await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(W+"/launch.png")
	for i in 120:
		if title._boot_done:break
		await process_frame
	check("Campaign launches to usable main menu",title._boot_done and title._page=="main" and not title._leaving)
	check("C6 remains off",not title.new_game_confirm_enabled)
	check("Private save unchanged",FileAccess.get_sha256(Team.save_path)==saved)
	await frames(4);await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(W+"/menu.png")
	var marker:=FileAccess.open(W+"/window-ready.json",FileAccess.WRITE);marker.store_string(JSON.stringify({"pid":OS.get_process_id()}));marker.close()
	await frames(180)
	title.queue_free();await frames(6);Team.erase_save()
	if is_instance_valid(UI._blip):UI._blip.free()
	var music:=root.get_node_or_null("HollowtideMusic")
	if music!=null:music.queue_free()
	await frames(5)
	var result:={"total":checks.size(),"checks":checks,"failed":checks.filter(func(c):return not c.passed).size()}
	var f:=FileAccess.open(W+"/native-result.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"  "));f.close();quit(0 if result.failed==0 else 1)
