extends SceneTree
const W := "D:/dev/hollowtide-recruit-portraits-20261026"
const UI := preload("res://scripts/ui/ui_style.gd")
const Team := preload("res://scripts/town/team_state.gd")
const Forms := ["skimlet", "ozbender", "valvekin"]
var good := 0
var total := 0

func _initialize() -> void:
	_run.call_deferred()

func check(label: String, passed: bool) -> void:
	total += 1
	if passed: good += 1
	print("PORTRAIT_CHECK ", label, " -> ", "ok" if passed else "FAIL")

func frames(n: int) -> void:
	for i in n: await process_frame

func same(tex: Texture2D, expected: Image) -> bool:
	if tex == null: return false
	var img := tex.get_image()
	if img == null: return false
	if img.is_compressed(): img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	expected.convert(Image.FORMAT_RGBA8)
	return img.get_size() == Vector2i(48,48) and img.get_data() == expected.get_data()

func primary(form: String) -> Image:
	var face := UI.dialogue_portrait(form).get_image()
	if face.is_compressed(): face.decompress()
	face.convert(Image.FORMAT_RGBA8)
	var mid: Vector2i=UI.FACE_AT[form]
	var img := face.get_region(Rect2i(mid-Vector2i(12,12),Vector2i(24,24)))
	img.resize(48,48,Image.INTERPOLATE_NEAREST)
	return img

func _run() -> void:
	root.size=Vector2i(1152,648)
	root.content_scale_size=Vector2i(1152,648)
	Team.save_path="user://recruit-portrait-private.save"
	Team.data={"party":[[103,0],[104,0],[105,0]],"levels":{103:{"lv":5,"exp":0},104:{"lv":5,"exp":0},105:{"lv":5,"exp":0}},"growth":{},"iq":{},"taught":{}}
	DirAccess.make_dir_recursive_absolute(W+"/native")
	var dungeon=load("res://scripts/dungeon/dungeon.gd").new()
	for form in Forms:
		var path="res://assets/sprites/arena/%s/portrait.png" % form
		var expected=Image.load_from_file(W+"/prepared/assets/sprites/arena/%s/portrait.png" % form)
		check(form+" imported resource exists",ResourceLoader.exists(path))
		check(form+" imported 48px RGBA exact",same(load(path),expected))
		check(form+" current UI keeps approved dialogue crop",same(UI.portrait_3x(form),primary(form)))
		check(form+" dungeon team row keeps approved dialogue crop",same(dungeon.portrait_of(form),primary(form)))
	var host=Node2D.new()
	root.add_child(host)
	var party=load("res://scripts/ui/party_screen.gd").new()
	host.add_child(party)
	party.setup(host)
	check("three recruited forms build actual Team cards",party.cards.size()==3)
	for i in Forms.size():
		var form=Forms[i]
		check(form+" actual Team card keeps approved dialogue crop",same(party.cards[i]["face"],primary(form)) and party.cards[i]["face_cut"])
		party.sel=i
		party.queue_redraw()
		await frames(5)
		await RenderingServer.frame_post_draw
		check(form+" native Team screenshot saved",root.get_texture().get_image().save_png(W+"/native/team-"+form+".png")==OK)
	party.queue_free()
	await frames(3)
	# Exercise the real fallback without renaming/removing assets: private process cache only.
	var saved_icons := {}
	for form in Forms:
		var key="dialogue/"+form
		saved_icons[key]=UI._icons[key]
		UI._icons[key]=null
		UI._faces3x.erase(form+"@24")
		var expected=Image.load_from_file(W+"/prepared/assets/sprites/arena/%s/portrait.png" % form)
		check(form+" missing-dialogue UI fallback exact",same(UI.portrait_3x(form),expected))
		check(form+" missing-dialogue dungeon fallback exact",same(dungeon.portrait_of(form),expected))
	party=load("res://scripts/ui/party_screen.gd").new()
	host.add_child(party)
	party.setup(host)
	check("fallback Team builds all three recruits",party.cards.size()==3)
	for i in Forms.size():
		var form=Forms[i]
		var expected=Image.load_from_file(W+"/prepared/assets/sprites/arena/%s/portrait.png" % form)
		check(form+" fallback actual Team card exact",same(party.cards[i]["face"],expected) and not party.cards[i]["face_cut"])
		party.sel=i
		party.queue_redraw()
		await frames(5)
		await RenderingServer.frame_post_draw
		check(form+" fallback native Team screenshot saved",root.get_texture().get_image().save_png(W+"/native/fallback-team-"+form+".png")==OK)
	for form in Forms:
		UI._icons["dialogue/"+form]=saved_icons["dialogue/"+form]
		UI._faces3x.erase(form+"@24")
	dungeon.free()
	host.queue_free()
	await frames(4)
	var music=root.get_node_or_null("HollowtideMusic")
	if music!=null: music.queue_free()
	await frames(3)
	print("RECRUIT PORTRAITS: ",good,"/",total)
	quit(0 if good==total else 1)
