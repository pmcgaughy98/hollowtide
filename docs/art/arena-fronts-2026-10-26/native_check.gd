extends SceneTree
const W := "D:/dev/hollowtide-arena-fronts-20261026"
const UI := preload("res://scripts/ui/ui_style.gd")
const Team := preload("res://scripts/town/team_state.gd")
var checks: Array=[]
var failed:=0
func _initialize() -> void:_run.call_deferred()
func frames(n: int) -> void:
	for i in n:await process_frame
func check(label: String, good: bool) -> void:
	checks.append({"check":label,"passed":good})
	if not good:failed+=1
	print(label,": ","PASS" if good else "FAIL")
func _run() -> void:
	root.size=Vector2i(1152,760);root.content_scale_size=root.size
	Team.save_path="user://arena-fronts-private.save";Team.erase_save();Team.start([[0,0],[1,0]]);Team.save();var saved:=FileAccess.get_sha256(Team.save_path)
	var legacy: Script=load(W+"/forced_before.gd");var current: Script=load(W+"/forced_after.gd")
	var manifest: Array=JSON.parse_string(FileAccess.get_file_as_string(W+"/manifest.json"))
	var host: Node=load(W+"/mock_town.gd").new();root.add_child(host)
	var canvas:=CanvasLayer.new();root.add_child(canvas)
	for i in manifest.size():
		var item: Dictionary=manifest[i];var form: String=item.form
		var old: Image=UI.res_image("res://"+item.source);var new: Image=UI.res_image("res://"+item.destination)
		check(form+" raw source and runtime image identical",old!=null and new!=null and old.get_size()==new.get_size() and old.get_data()==new.get_data())
		var pos:=Vector2i((i%4)*2,i/4)
		var before: Dictionary=legacy.make_npc(host,form,pos)
		var after: Dictionary=current.make_npc(host,form,pos+Vector2i(1,0))
		var a: Image=before.sprite.texture.get_image();var b: Image=after.sprite.texture.get_image()
		check(form+" actual forced fallback stays66x66 and nonempty",b.get_size()==Vector2i(66,66) and b.get_used_rect().has_area())
		check(form+" fallback texture pixels unchanged",a.get_data()==b.get_data())
		var label:=Label.new();label.text=form+"  (docs / assets)";label.position=Vector2((i%4)*288+10,(i/4)*188+8)
		label.add_theme_font_override("font",UI.font("body"));label.add_theme_font_size_override("font_size",19);canvas.add_child(label)
	for form in ["gruntle","mirekit","whinet"]:
		var town: String="res://assets/sprites/arena/%s/town/s.png"%form;var dungeon: String="res://assets/sprites/arena/%s/dungeon/s.png"%form
		check(form+" current crew directional set remains available",ResourceLoader.exists(town) or ResourceLoader.exists(dungeon))
	check("Private team save untouched",FileAccess.get_sha256(Team.save_path)==saved)
	await frames(5);await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(W+"/native-fallback-comparison.png")
	host.queue_free();canvas.queue_free();await frames(5);Team.erase_save()
	var result:={"total":checks.size(),"failed":failed,"checks":checks}
	var f:=FileAccess.open(W+"/native-result.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"  "));f.close()
	print("ARENA FRONTS RESULT ",checks.size()," checks / ",failed," failures");quit(0 if failed==0 else 1)
