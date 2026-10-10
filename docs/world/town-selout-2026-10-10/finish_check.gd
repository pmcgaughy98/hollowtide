extends SceneTree
const W := "D:/dev/hollowtide-town-selout-20261010/"
const Finish := preload("res://scripts/arena/creature_finish.gd")
const Exterior := preload("res://scripts/town/exterior_finish.gd")
const Helper := preload("res://scripts/art/selout.gd")
const Layout := preload("res://scripts/town/town_layout.gd")
const FONT := preload("res://assets/fonts/Silkscreen-Bold.ttf")
var bad := 0
var checks := 0
func _initialize() -> void: _run.call_deferred()
func frames(n: int) -> void:
	for k in n: await process_frame
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: bad += 1
	print("PASS " if ok else "FAIL ",label)
func old(details: float, path := "") -> ShaderMaterial:
	var sh := Shader.new()
	sh.code = "shader_type canvas_item;\nrender_mode unshaded;\n#define SEL_OUT_DETAIL_DEFAULT 0.0\n" + FileAccess.get_file_as_string(W+"originals/scripts/arena/sel_out.gdshaderinc")
	var m := ShaderMaterial.new()
	m.shader = sh
	m.set_shader_parameter("detail_ink",details)
	m.set_shader_parameter("sparkwick_palette",Finish.is_sparkwick(path))
	return m
func viewport(size: Vector2i) -> SubViewport:
	var v := SubViewport.new()
	v.size = size
	v.transparent_bg = true
	v.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(v)
	return v
func sprite(v: SubViewport, pos: Vector2) -> Sprite2D:
	var s := Sprite2D.new()
	s.centered = false
	s.position = pos
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	v.add_child(s)
	return s
func _run() -> void:
	DirAccess.make_dir_recursive_absolute(W+"review/proof")
	var v := viewport(Vector2i(512,160))
	var a := sprite(v,Vector2(4,4))
	var b := sprite(v,Vector2(260,4))
	a.material = old(1.0)
	Exterior.apply(b,true)
	var art: Dictionary = load("res://scripts/town/building_exteriors.gd").SOURCES.duplicate()
	for pair in [["shrine","growth_shrine_painter"],["yard","training_yard_painter"],["board","job_board_painter"],["gate","hollow_mouth_painter"]]:
		art[pair[0]]=load("res://scripts/town/"+pair[1]+".gd").ART
	var alpha_exact := true
	var interior_exact := true
	var changes := 0
	for id in art:
		var tex: Texture2D = load(art[id])
		var raw := tex.get_image()
		a.texture = tex
		b.texture = tex
		await frames(2)
		await RenderingServer.frame_post_draw
		var im := v.get_texture().get_image()
		var changed := 0
		for y in range(raw.get_height()+8):
			for x in 256:
				var c := im.get_pixel(x,y)
				var d := im.get_pixel(x+256,y)
				alpha_exact = alpha_exact and c.a==d.a
				if c!=d: changed+=1
				var p := Vector2i(x-4,y-4)
				if p.x>0 and p.y>0 and p.x<raw.get_width()-1 and p.y<raw.get_height()-1:
					var interior := raw.get_pixelv(p).a>0.5
					for off in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]: interior=interior and raw.get_pixelv(p+off).a>0.5
					if interior: interior_exact=interior_exact and c==d
		check(changed>0,id+" has material-coloured exterior rim")
		changes += changed
		im.save_png(W+"review/proof/"+id+"-native-before-after.png")
	check(alpha_exact,"nine exteriors retain exact rendered alpha and contour thickness")
	check(interior_exact,"every internal window, door, carving and seam pixel exact to black-detail finish")
	print("Outer-rim pixel changes: ",changes)
	# Default shaders compile without the optional branch. Compare actual native pixels.
	var exact := true
	var forms := 0
	a.position = Vector2(4,4)
	b.position = Vector2(260,4)
	Finish.apply(b)
	for form in DirAccess.get_directories_at("res://assets/sprites/arena"):
		var path := "res://assets/sprites/arena/"+form+"/dungeon/s.png"
		if not ResourceLoader.exists(path): continue
		a.texture = load(path)
		b.texture = a.texture
		a.material = old(Finish.crew_detail(path),path)
		await frames(2)
		await RenderingServer.frame_post_draw
		var im := v.get_texture().get_image()
		for y in 64:
			for x in 64: exact=exact and im.get_pixel(x,y)==im.get_pixel(x+256,y)
		forms+=1
	check(forms>=35 and exact,"all installed south-view creature finishes byte-exact, including jade, rivals and Sparkwick")
	# Doors use the wrapper's default path, never the coloured/detail variant.
	Exterior.apply(b)
	check(b.material.shader==Finish.SHADER,"door finish still uses original shared shader")
	v.queue_free()
	await frames(4)
	# Both dungeon painters and their installed masks retain the exact current finish.
	var df := load("res://scripts/dungeon/dungeon_finish.gd")
	var gen := load("res://scripts/hollow/hollow_gen.gd")
	var data: Dictionary = {"w":12,"h":8,"tiles":PackedByteArray(),"stairs":Vector2i(5,4),"rooms":[Rect2i(2,2,8,4)]}
	data.tiles.resize(96)
	for y in 8:
		for x in 12: data.tiles[y*12+x]=gen.WALL if x<2 or x>9 or y<2 or y>5 else gen.FLOOR
	var mv := viewport(Vector2i(576,192))
	a=sprite(mv,Vector2.ZERO)
	b=sprite(mv,Vector2(288,0))
	for look in ["riverbank","ruin","bank","valley"]:
		var painter: Script=load("res://scripts/dungeon/"+{"riverbank":"riverbank_painter.gd","ruin":"ruin_painter.gd","bank":"floor_painter.gd","valley":"valley_painter.gd"}[look])
		var painted: Image=painter.paint(data,24,77)
		a.texture=ImageTexture.create_from_image(painted)
		b.texture=a.texture
		var sh := Shader.new()
		sh.code=FileAccess.get_file_as_string("res://scripts/dungeon/dungeon_finish.gdshader").replace('#include "res://scripts/arena/sel_out.gdshaderinc"',FileAccess.get_file_as_string(W+"originals/scripts/arena/sel_out.gdshaderinc"))
		var mat := ShaderMaterial.new()
		mat.shader=sh
		mat.set_shader_parameter("detail_mask",ImageTexture.create_from_image(df.mask(data,24,look)))
		a.material=mat
		df.apply(b,data,24,look)
		await frames(2)
		await RenderingServer.frame_post_draw
		var rendered := mv.get_texture().get_image()
		check(rendered.get_region(Rect2i(0,0,288,192)).get_data()==rendered.get_region(Rect2i(288,0,288,192)).get_data(),look+" dungeon finish byte-exact to installed ink/mask")
	mv.queue_free()
	await frames(4)
	# Real painter crop: selected wall rim, unchanged paving and masonry inside.
	var ground: Image = load("res://scripts/town/hub_town.gd").paint()
	var place: Dictionary = Layout.PLACES.filter(func(p: Dictionary) -> bool:return p["id"]=="lookout")[0]
	var crop := ground.get_region(Rect2i(place["rect"].position*24-Vector2i(4,4),Vector2i(152,40)))
	var selection := Rect2i(4,4,144,7)
	var bytes := crop.get_data()
	var after := Helper.selout(crop,selection)
	var outside_exact := true
	var inside_exact := true
	var edge_changes := 0
	for y in crop.get_height():
		for x in crop.get_width():
			var p := Vector2i(x,y)
			var c := crop.get_pixelv(p)
			var d := after.get_pixelv(p)
			if not selection.has_point(p):outside_exact=outside_exact and c==d
			elif selection.grow(-1).has_point(p):inside_exact=inside_exact and c==d
			elif c!=d:edge_changes+=1
	check(crop.get_data()==bytes,"helper does not mutate the painter image")
	check(outside_exact and inside_exact and edge_changes>0,"Rect2i helper changes only the Lookout wall rim, preserving paving and interior blocks")
	check(after.get_pixel(20,4).get_luminance()>after.get_pixel(20,10).get_luminance(),"helper lights top-left rim above bottom-right rim")
	var mask := Image.create(crop.get_width(),crop.get_height(),false,Image.FORMAT_RGBA8)
	mask.fill(Color.BLACK)
	mask.fill_rect(selection,Color.WHITE)
	check(Helper.selout(crop,mask).get_data()==after.get_data(),"filled shape mask and rectangle select the same wall")
	crop.save_png(W+"review/proof/lookout-helper-before.png")
	after.save_png(W+"review/proof/lookout-helper-after.png")
	# Three creature A/Bs are native review only. Current finish remains shipped.
	var sheet := viewport(Vector2i(512,288))
	var labels := Node2D.new()
	labels.draw.connect(func():
		labels.draw_rect(Rect2(0,0,512,288),Color("#667d49"))
		labels.draw_string(FONT,Vector2(12,20),"CURRENT INK",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#eee0bf"))
		labels.draw_string(FONT,Vector2(268,20),"SEL-OUT PROPOSAL",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#eee0bf"))
		for i in 3:labels.draw_string(FONT,Vector2(12,88+i*88),["CINDERHIDE","OXBOWARCHON","WHINET"][i],HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("#eee0bf"))
	)
	sheet.add_child(labels)
	for i in 3:
		var form: String = ["cinderhide","oxbowarchon","whinet"][i]
		var path := "res://assets/sprites/arena/"+form+"/dungeon/s.png"
		var left := sprite(sheet,Vector2(112,24+i*88))
		left.texture=load(path)
		left.scale=Vector2(2,2)
		Finish.apply(left)
		var right := sprite(sheet,Vector2(368,24+i*88))
		right.texture=left.texture
		right.scale=left.scale
		Finish.apply(right)
		right.material.shader=Exterior.SHADER
	await frames(4)
	await RenderingServer.frame_post_draw
	sheet.get_texture().get_image().save_png(W+"review/proof/creature-ab-review-only.png")
	sheet.queue_free()
	await frames(4)
	print("RESULT ",checks-bad,"/",checks," checks pass; ",forms," current creature finishes compared")
	quit(1 if bad else 0)
