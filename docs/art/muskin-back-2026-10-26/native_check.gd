extends SceneTree
const W := "D:/dev/hollowtide-muskin-back-20261026"
const Team := preload("res://scripts/town/team_state.gd")
const Kit := preload("res://scripts/town/scene_kit.gd")
const Finish := preload("res://scripts/arena/creature_finish.gd")
var checks: Array = []
var failed := 0
func _initialize() -> void:
	_run.call_deferred()
func check(label: String, good: bool) -> void:
	checks.append({"what":label,"ok":good})
	if not good: failed+=1
	print(label," -> ","ok" if good else "FAIL")
func frames(n: int) -> void:
	for i in n: await process_frame
func picture(path: String) -> Image:
	return Image.load_from_file(path)
func _run() -> void:
	Team.save_path=W+"/native-profile/private-save.json"
	var sf:=FileAccess.open(Team.save_path,FileAccess.WRITE);sf.store_string("private Muskin sentinel");sf.close()
	var saved:=FileAccess.get_sha256(Team.save_path)
	var manifest: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(W+"/installed-files.json"))
	var view:=SubViewport.new();view.size=Vector2i(768,800);view.transparent_bg=true;view.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(view)
	var bg:=ColorRect.new();bg.size=Vector2(768,800);bg.color=Color(0.114,0.125,0.145);view.add_child(bg)
	var k:=0
	for rel: String in manifest:
		var tex: Texture2D=load("res://"+rel)
		var actual:=tex.get_image();actual.convert(Image.FORMAT_RGBA8)
		var expected:=picture(W+"/prepared/"+rel)
		var old:=picture(W+"/originals/"+rel)
		check(rel+" imported pixels match prepared",actual.get_size()==expected.get_size() and actual.get_data()==expected.get_data())
		var colours: Dictionary={};var alpha_same:=actual.get_size()==old.get_size()
		for y in actual.get_height():
			for x in actual.get_width():
				var c:=actual.get_pixel(x,y)
				alpha_same=alpha_same and c.a==old.get_pixel(x,y).a
				if c.a>0:colours[c]=true
		check(rel+" alpha/canvas exact",alpha_same)
		check(rel+" nonempty palette at most 30",colours.size()>0 and colours.size()<=30)
		for side in 2:
			var s:=Sprite2D.new();s.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;s.centered=false
			s.texture=ImageTexture.create_from_image(old) if side==0 else tex;s.scale=Vector2(3,3)
			s.position=Vector2(side*384+(384-actual.get_width()*3)/2,[35,450,600][k]);view.add_child(s);Finish.apply(s)
			check(rel+" shared native shader applied "+str(side),s.material is ShaderMaterial)
		k+=1
	var dg=load("res://scripts/dungeon/dungeon.gd").new()
	var art: Dictionary=dg._load_art("muskin")
	check("Actual dungeon loader resolves north asset",art.still.n.resource_path=="res://assets/sprites/arena/muskin/dungeon/n.png")
	var node:=Node2D.new();var shadow:=Node2D.new();node.add_child(shadow);var sprite:=Sprite2D.new();node.add_child(sprite)
	var e:={"node":node,"sprite":sprite,"form":"muskin","art":art}
	dg._set_tex(e,art.still.n)
	check("Actual dungeon set_tex selects north with original foot row",sprite.texture==art.still.n and dg._foot_row(art.still.n)==dg._count_foot_row(ImageTexture.create_from_image(picture(W+"/originals/assets/sprites/arena/muskin/dungeon/n.png"))))
	var host=load(W+"/mock_town.gd").new();root.add_child(host)
	var npc: Dictionary=Kit.spawn(host,"muskin",Vector2i.ZERO,"n")
	check("Actual town factory selects repaired north",npc.sprite.texture.resource_path=="res://assets/sprites/arena/muskin/town/n.png")
	check("Town factory keeps job-object south idle",npc.still.s.resource_path=="res://assets/sprites/arena/muskin/town/idle_s.png")
	for facing in ["s","se","e","ne","n","nw","w","sw"]:
		check("Town "+facing+" retains eight walk frames",npc.walk[facing].size()==8)
	await frames(4);await RenderingServer.frame_post_draw;view.get_texture().get_image().save_png(W+"/native-before-after.png")
	check("Private save unchanged",FileAccess.get_sha256(Team.save_path)==saved)
	node.free();dg.free();host.queue_free();view.queue_free();await frames(5)
	var f:=FileAccess.open(W+"/native-result.json",FileAccess.WRITE);f.store_string(JSON.stringify({"total":checks.size(),"failed":failed,"checks":checks},"  "));f.close()
	print("MUSKIN RESULT ",checks.size()," checks / ",failed," failures");quit(0 if failed==0 else 1)
