extends SceneTree
const OUT := "D:/dev/hollowtide-crew-dungeon-selout-20261010/review/live/"
const Finish := preload("res://scripts/arena/creature_finish.gd")
const DungeonFinish := preload("res://scripts/dungeon/dungeon_finish.gd")
var bad := 0
var checks := 0
func _initialize() -> void: _run.call_deferred()
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: bad += 1
	print("PASS " if ok else "FAIL ", label)
func frames(n: int) -> void:
	for k in n: await process_frame
func old_material(details := false) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = "shader_type canvas_item;\nrender_mode unshaded;\n#define SEL_OUT_DETAIL_DEFAULT 0.0\n" + FileAccess.get_file_as_string("D:/dev/hollowtide-crew-dungeon-selout-20261010/originals/scripts/arena/sel_out.gdshaderinc")
	var m := ShaderMaterial.new()
	m.shader = shader
	m.set_shader_parameter("detail_ink", 1.0 if details else 0.0)
	return m
func viewport(size: Vector2i) -> SubViewport:
	var v := SubViewport.new()
	v.size = size
	v.transparent_bg = true
	v.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(v)
	return v
func sprite(v: SubViewport, at: Vector2) -> Sprite2D:
	var s := Sprite2D.new()
	s.centered = false
	s.position = at
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	v.add_child(s)
	return s
func snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + name + ".png")
func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var v := viewport(Vector2i(128, 64))
	var a := sprite(v, Vector2(8, 8))
	var b := sprite(v, Vector2(72, 8))
	a.material = old_material()
	Finish.apply(b)
	var alpha_exact := true
	var pale_exact := true
	var count := 0
	var changes := 0
	var ink_added := 0
	var texture_follows := true
	for form in ["mirekit", "whinet"]:
		for size in ["small", "dungeon"]:
			var folder := "res://assets/sprites/arena/%s/%s/" % [form, size]
			for file in DirAccess.get_files_at(folder):
				if not file.ends_with(".png"): continue
				var tex: Texture2D = load(folder + file)
				a.texture = tex
				b.texture = tex
				await frames(2)
				await RenderingServer.frame_post_draw
				var im := v.get_texture().get_image()
				texture_follows = texture_follows and b.material.get_shader_parameter("detail_ink") == 0.65
				for y in 50:
					for x in 50:
						var c := im.get_pixel(x, y)
						var d := im.get_pixel(x + 64, y)
						alpha_exact = alpha_exact and c.a == d.a
						if c.a > 0.5 and minf(c.r, minf(c.g, c.b)) > 0.86: pale_exact = pale_exact and c == d
						if c != d: changes += 1
						if c.a > 0.5 and d.get_luminance() + 0.02 < c.get_luminance(): ink_added += 1
				if size == "dungeon" and file == "s.png":
					im.save_png(OUT + form + "-native-before-after.png")
				count += 1
	check(count == 544, "544 installed rival textures rendered: all facings, walks, attacks, hurts and sleeps")
	check(alpha_exact, "all rendered alpha, thin legs, wings and silhouettes exact to previous finish")
	check(pale_exact, "bright pale fur/wing highlights unchanged")
	check(texture_follows and changes > 100 and ink_added > 100, "new internal contour ink follows every rival texture change")
	print("Textures ", count, " changed pixels ", changes, " deeper ink ", ink_added)
	# A switch away from rivals clears their extra detail; Sparkwick correction still follows texture.
	b.texture = load("res://assets/sprites/arena/sparkwick/dungeon/s.png")
	check(b.material.get_shader_parameter("detail_ink") == 0.0 and b.material.get_shader_parameter("sparkwick_palette") == true, "switch to Sparkwick resets detail and retains its gold material correction")
	v.queue_free()
	await frames(2)
	var big := viewport(Vector2i(1024, 512))
	a = sprite(big, Vector2(4,4))
	b = sprite(big, Vector2(516,4))
	a.material = old_material()
	Finish.apply(b)
	var other_same := true
	var other_count := 0
	for form in DirAccess.get_directories_at("res://assets/sprites/arena"):
		if form in ["mirekit", "whinet"]: continue
		var path := "res://assets/sprites/arena/%s/dungeon/s.png" % form
		if not ResourceLoader.exists(path): continue
		var tex: Texture2D = load(path)
		a.texture = tex
		b.texture = tex
		a.material.set_shader_parameter("sparkwick_palette", Finish.is_sparkwick(path))
		await frames(2)
		await RenderingServer.frame_post_draw
		var im := big.get_texture().get_image()
		other_same = other_same and im.get_region(Rect2i(0,0,512,512)).get_data() == im.get_region(Rect2i(512,0,512,512)).get_data()
		other_count += 1
	check(other_same and other_count > 30, "all other installed forms retain exact native finish, including Sparkwick and darker jade Oxbowarchon")
	print("Unchanged forms ", other_count)
	# The existing purposeful-building detail preset must remain identical.
	var building: Texture2D = load("res://assets/sprites/arena/cinderhide/dungeon/s.png")
	a.texture = building
	b.texture = building
	a.material = old_material(true)
	Finish.apply(b, true)
	await frames(2)
	await RenderingServer.frame_post_draw
	var built := big.get_texture().get_image()
	check(built.get_region(Rect2i(0,0,512,512)).get_data() == built.get_region(Rect2i(512,0,512,512)).get_data(), "existing explicit building detail preset renders byte-exact")
	big.queue_free()
	await frames(2)
	var Gen := load("res://scripts/hollow/hollow_gen.gd")
	var data: Dictionary = {"w": 12,"h": 8,"tiles": PackedByteArray(),"stairs": Vector2i(5,4),"rooms": [Rect2i(2,2,8,4)]}
	data.tiles.resize(96)
	for y in 8:
		for x in 12:
			data.tiles[y*12+x] = Gen.WALL if x < 2 or x > 9 or y < 2 or y > 5 else Gen.FLOOR
	var map_view := viewport(Vector2i(576,192))
	a = sprite(map_view, Vector2.ZERO)
	b = sprite(map_view, Vector2(288,0))
	for look in ["riverbank", "ruin", "bank", "valley"]:
		var painter: Script = load("res://scripts/dungeon/" + ({"riverbank":"riverbank_painter.gd", "ruin":"ruin_painter.gd", "bank":"floor_painter.gd", "valley":"valley_painter.gd"}[look]))
		var im: Image = painter.paint(data,24,77)
		var tex := ImageTexture.create_from_image(im)
		a.texture = tex
		b.texture = tex
		DungeonFinish.apply(b,data,24,look)
		await frames(2)
		await RenderingServer.frame_post_draw
		var rendered := map_view.get_texture().get_image()
		var mask := DungeonFinish.mask(data,24,look)
		var quiet_exact := true
		var map_ink := 0
		for y in 192:
			for x in 288:
				var c := rendered.get_pixel(x,y)
				var d := rendered.get_pixel(x+288,y)
				if mask.get_pixel(x,y).r == 0.0: quiet_exact = quiet_exact and c == d
				elif d.get_luminance() + 0.015 < c.get_luminance(): map_ink += 1
		check(quiet_exact and map_ink > 100, look + " ink defines walls/stairs while every unmasked native floor pixel stays exact")
		rendered.save_png(OUT + look + "-map-before-after.png")
	map_view.queue_free()
	await frames(2)
	# Actual floor changes rebuild the mask and retain boss, scene and stairs interactions.
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.dungeon = "first"; dg.floor_seed = 4242; dg.poll_input = false
	root.add_child(dg)
	await frames(30)
	await snap("dungeon-1-bank")
	check(dg._map.material != null and dg._map.texture.get_size() == Vector2(dg.data.w*24,dg.data.h*24), "actual first floor retains map size and new bounded finish")
	dg.floor_n = 4; dg._build_floor(true)
	await frames(40)
	await snap("dungeon-1-crew")
	check(dg.ents[dg.boss].form == "mirekit" and dg.ents[dg.boss].sprite.material.get_shader_parameter("detail_ink") == 0.65, "actual first boss is the finished Mirekit with Whinet")
	# Both speakers through the actual dialogue pipeline, without modifying story lines.
	for form in ["mirekit", "whinet"]:
		dg.talk = [[form.capitalize(), "Portrait finish verification", form]]
		dg._hud.queue_redraw()
		await frames(3)
		var layer = dg._hud.get_node("CrewPortraitFinish")
		check(layer.draws.size() == 1 and layer.material.get_shader_parameter("detail_ink") == 0.65, "actual " + form + " dialogue portrait uses separate finish layer")
		await snap(form + "-dialogue")
		for face in ["angry", "worried"]:
			dg.talk = [[form.capitalize(), "Emotion mark verification", form + ":" + face]]
			dg._hud.queue_redraw(); await frames(3)
			await RenderingServer.frame_post_draw
			var pixel := root.get_texture().get_image().get_pixel(308, 272) if face == "angry" else root.get_texture().get_image().get_pixel(318, 278)
			var expected := Color("#d8243a") if face == "angry" else Color("#6fb4e8")
			check(Vector3(pixel.r,pixel.g,pixel.b).distance_to(Vector3(expected.r,expected.g,expected.b)) < 0.02, form + " " + face + " mark remains above finished art in native dialogue")
			await snap(form + "-" + face + "-dialogue")
	dg.talk.clear(); dg._hud.queue_redraw(); await frames(3)
	check(dg._hud.get_node("CrewPortraitFinish").draws.is_empty(), "portrait layer clears after dialogue; no ghost image")
	dg.queue_free(); await frames(2)
	var hg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	hg.dungeon = "hollow"; hg.floor_seed = 77; hg.poll_input = false
	root.add_child(hg); await frames(30)
	await snap("dungeon-2-valley")
	hg.floor_n = 2; hg._build_floor(true); await frames(30)
	await snap("dungeon-2-stone")
	check(hg._map.material != null and hg._map.material.get_shader_parameter("detail_mask").get_size() == hg._map.texture.get_size(), "second dungeon's stone floor refreshes its geometry mask")
	hg.floor_n = 3; hg._build_floor(true); await frames(50)
	await snap("dungeon-2-warden")
	check(hg.ents[hg.boss].form == "warden" and hg.cutscene and hg.pond.size != Vector2i.ZERO, "second boss remains Warden with its pond intro")
	hg.queue_free(); await frames(3)
	print("SEL-OUT: ", checks," checks, ",bad," failures")
	quit(0 if bad == 0 else 1)
