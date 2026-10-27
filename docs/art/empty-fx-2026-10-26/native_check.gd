extends SceneTree
const W := "D:/dev/hollowtide-fx-empty-20261026"
const Team = preload("res://scripts/town/team_state.gd")
var checks: Array = []
var failed := 0
func _initialize() -> void:
	_run.call_deferred()
func check(label: String, good: bool) -> void:
	checks.append({"what": label, "ok": good})
	if not good: failed += 1
	print(label, " -> ", "ok" if good else "FAIL")
func frames(n: int) -> void:
	for i in n: await process_frame
func _run() -> void:
	Team.save_path = W + "/native-profile/private-save.json"
	var sf := FileAccess.open(Team.save_path, FileAccess.WRITE)
	sf.store_string("private FX fixture sentinel"); sf.close()
	var saved := FileAccess.get_sha256(Team.save_path)
	var dg = load("res://scripts/dungeon/dungeon.gd").new()
	var vp := SubViewport.new()
	vp.size = Vector2i(32,32)
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var fx := Node2D.new()
	fx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	vp.add_child(fx)
	dg._fx = fx
	fx.draw.connect(dg._draw_fx)
	for effect in ["sail_slash", "mark_glyph"]:
		var sheet: Array = dg._fx_sheet(effect)
		check(effect + " actual dungeon loader retains 16 frames", sheet.size()==16)
		for i in 16:
			var tex: Texture2D = sheet[i]
			var raw := Image.load_from_file(ProjectSettings.globalize_path("res://assets/sprites/arena/vfx/%s/f%02d.png" % [effect,i]))
			var imported := tex.get_image()
			imported.convert(Image.FORMAT_RGBA8)
			check("%s f%02d imported 32x32 nonempty pixels exact" % [effect,i], imported.get_size()==Vector2i(32,32) and imported.get_used_rect().has_area() and imported.get_data()==raw.get_data())
			dg._vfx.clear()
			dg._vfx.append({"name":effect,"pos":Vector2(16,16),"t":(i+0.25)/16.0,"dur":1.0})
			fx.queue_redraw()
			await frames(2)
			await RenderingServer.frame_post_draw
			var img := vp.get_texture().get_image()
			check("%s f%02d actual dungeon draw visible" % [effect,i], img.get_used_rect().has_area())
			img.save_png(W + "/native-%s-f%02d.png" % [effect,i])
	check("Private save unchanged", FileAccess.get_sha256(Team.save_path)==saved)
	fx.draw.disconnect(dg._draw_fx)
	dg.free(); vp.queue_free(); await frames(3)
	var result := {"total":checks.size(),"failed":failed,"checks":checks}
	var f := FileAccess.open(W+"/native-result.json",FileAccess.WRITE)
	f.store_string(JSON.stringify(result,"  "));f.close()
	print("FX RESULT ",checks.size()," checks / ",failed," failures")
	quit(0 if failed==0 else 1)
