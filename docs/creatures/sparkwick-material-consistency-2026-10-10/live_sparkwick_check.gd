extends SceneTree
const OUT := "D:/dev/hollowtide-sparkwick-20261010/review/"
const Finish := preload("res://scripts/arena/creature_finish.gd")
const Idle := preload("res://scripts/ui/creature_idle.gd")
var checks := 0
var bad := 0
func _initialize() -> void: _run.call_deferred()
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: bad += 1
	print("PASS " if ok else "FAIL ",label)
func frames(n: int) -> void:
	for k in n: await process_frame
func snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+name+".png")
func old_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = "shader_type canvas_item;\nrender_mode unshaded;\n#define SEL_OUT_DETAIL_DEFAULT 0.0\n" + FileAccess.get_file_as_string("D:/dev/hollowtide-sparkwick-20261010/originals/scripts/arena/sel_out.gdshaderinc")
	var mat := ShaderMaterial.new()
	mat.shader = shader
	return mat
func _run() -> void:
	# All eight views and every walking frame in both active size sets, plus large idles.
	var paths: Array[String] = []
	for set in ["dungeon","small"]:
		for f in ["s","se","e","ne","n","nw","w","sw"]:
			paths.append("res://assets/sprites/arena/sparkwick/%s/%s.png" % [set,f])
			for k in 8: paths.append("res://assets/sprites/arena/sparkwick/%s/walk_%s_f%d.png" % [set,f,k])
	for folder in ["idle_2026_10_10/sparkwick_palette_locked","sparkwick_idle_texture_2026_10_06"]:
		for k in 8: paths.append("res://assets/sprites/creatures/%s/f%d.png" % [folder,k])
	for k in 8: paths.append("res://assets/sprites/creatures/sparkwick_idle_texture_2026_10_06/back_f%d.png" % k)
	var proof := SubViewport.new()
	proof.size = Vector2i(480,248)
	proof.transparent_bg = true
	proof.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(proof)
	var left := Sprite2D.new()
	var right := Sprite2D.new()
	for s in [left,right]:
		s.centered = false
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		proof.add_child(s)
	left.position = Vector2(8,8)
	right.position = Vector2(248,8)
	left.material = old_material()
	Finish.apply(right)
	var geometry_same := true
	var muddy_before := 0
	var muddy_after := 0
	var changed := 0
	var lamps_same := true
	var all_enabled := true
	var views := 0
	for path in paths:
		if not ResourceLoader.exists(path): continue
		var tex: Texture2D = load(path)
		left.texture = tex
		right.texture = tex
		await frames(2)
		await RenderingServer.frame_post_draw
		var im := proof.get_texture().get_image()
		var a := im.get_region(Rect2i(0,0,240,248))
		var b := im.get_region(Rect2i(240,0,240,248))
		all_enabled = all_enabled and right.material.get_shader_parameter("sparkwick_palette") == true
		for y in 248:
			for x in 240:
				var c := a.get_pixel(x,y)
				var d := b.get_pixel(x,y)
				geometry_same = geometry_same and c.a == d.a
				if c != d: changed += 1
				var rgb := Vector3i(roundi(c.r*255),roundi(c.g*255),roundi(c.b*255))
				var dest := Vector3i(roundi(d.r*255),roundi(d.g*255),roundi(d.b*255))
				if c.a > 0.5 and rgb in [Vector3i(180,139,91),Vector3i(166,137,105),Vector3i(166,121,85),Vector3i(174,141,96),Vector3i(171,125,84)]: muddy_before += 1
				if d.a > 0.5 and dest in [Vector3i(180,139,91),Vector3i(166,137,105),Vector3i(166,121,85),Vector3i(174,141,96),Vector3i(171,125,84)]: muddy_after += 1
				if c.a > 0.5 and rgb.x >= 245 and rgb.y >= 195 and rgb.z < 110: lamps_same = lamps_same and c == d
		if path.ends_with("palette_locked/f0.png"): im.save_png(OUT+"large-idle-before-after.png")
		if path.ends_with("dungeon/walk_w_f3.png"): im.resize(1440,744,Image.INTERPOLATE_NEAREST);im.save_png(OUT+"walk-before-after-3x.png")
		views += 1
	check(views == 168,"168 actual game/large idle frames rendered, including all eight walking directions")
	check(all_enabled,"palette follows each texture change, including delayed town/dungeon assignments")
	check(geometry_same,"rendered alpha/silhouette exact to existing finish on all 168 frames")
	check(changed > 1000 and muddy_before > 1000 and muddy_after == 0,"desaturated brown material swatches removed in actual GPU renders")
	check(lamps_same,"bright lantern core pixels exact to existing finish")
	print("Frames ",views," changed pixels ",changed," dull material ",muddy_before," -> ",muddy_after)
	# Every other form keeps precisely the prior shader rendering.
	var same := true
	var other_forms := 0
	for name in DirAccess.get_directories_at("res://assets/sprites/arena"):
		if name == "sparkwick" or not ResourceLoader.exists("res://assets/sprites/arena/%s/s.png" % name): continue
		var tex: Texture2D = load("res://assets/sprites/arena/%s/s.png" % name)
		left.texture = tex
		right.texture = tex
		await frames(2)
		await RenderingServer.frame_post_draw
		var im := proof.get_texture().get_image()
		same = same and im.get_region(Rect2i(0,0,240,248)).get_data() == im.get_region(Rect2i(240,0,240,248)).get_data() and right.material.get_shader_parameter("sparkwick_palette") == false
		other_forms += 1
	check(same and other_forms >= 32,"all other creature forms retain byte-exact prior native finish, including jade Oxbowarchon")
	proof.queue_free()
	await frames(3)
	var state = load("res://scripts/town/team_state.gd")
	state.start([[0,1],[1,0]])
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	state.give_to(town)
	root.add_child(town)
	town.poll_input = false
	await frames(8)
	check(town.team[0]["sprite"].material.get_shader_parameter("sparkwick_palette") == true and town.team[1]["sprite"].material.get_shader_parameter("sparkwick_palette") == false,"actual town corrects Sparkwick only")
	town.act_move(Vector2i(1,0))
	await frames(2)
	check("walk_" in town.team[0]["sprite"].texture.resource_path and town.team[0]["sprite"].material.get_shader_parameter("sparkwick_palette") == true,"real town movement keeps the correction while frames advance")
	await frames(8)
	await snap("town-sparkwick")
	var page = load("res://scripts/ui/party_screen.gd").new()
	var layer := CanvasLayer.new()
	layer.layer = 100
	root.add_child(layer)
	layer.add_child(page)
	page.setup(town)
	await frames(8)
	check(page.cards[0]["idle"].size() == 8 and Idle.FPS == 5.0,"Claude's moving eight-frame front idle and 5 FPS retained")
	check(page._sparkwick_art.draws.size() == 2 and page._sparkwick_art.material.get_shader_parameter("sparkwick_palette") == true,"actual summary corrects only Sparkwick headshot and animated art, not its UI")
	var first: Texture2D = page._sparkwick_art.draws[-1]["tex"]
	await snap("summary-sparkwick")
	await frames(12)
	check(page._sparkwick_art.draws[-1]["tex"] != first,"actual summary advances frames while palette remains active")
	page.sel = 1
	await frames(4)
	check(page._sparkwick_art.draws.size() == 1,"switching teammates leaves Tallowroot on its existing draw path")
	layer.queue_free()
	town.queue_free()
	await frames(5)
	var dungeon: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dungeon.poll_input = false
	state.give_to(dungeon)
	root.add_child(dungeon)
	await frames(5)
	check(dungeon.ents[0]["form"] == "sparkwick" and dungeon.ents[0]["sprite"].material.get_shader_parameter("sparkwick_palette") == true,"actual dungeon loads Sparkwick with the same material ramp")
	dungeon.queue_free()
	await frames(5)
	var evolution = load("res://scripts/ui/evolution_scene.gd").new()
	root.add_child(evolution)
	await frames(1)
	var ev: Sprite2D = evolution._sprite("sparkwick")
	var next: Sprite2D = evolution._sprite("stormwick")
	check(ev.material.get_shader_parameter("sparkwick_palette") == true and next.material.get_shader_parameter("sparkwick_palette") == false,"evolution colour correction is limited to Sparkwick; Stormwick unchanged")
	evolution._white(ev,1.0)
	check(ev.material.get_shader_parameter("white") == 1.0,"evolution whitening remains available")
	evolution.queue_free()
	await frames(5)
	print("RESULT ",checks," checks, ",bad," failures")
	quit(1 if bad else 0)
