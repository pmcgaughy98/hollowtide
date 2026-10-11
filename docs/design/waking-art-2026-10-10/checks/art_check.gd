extends SceneTree
const W := "D:/dev/hollowtide-waking-art-20261010/"
const Bank := preload("res://scripts/ui/waking_bank.gd")
const Finish := preload("res://scripts/ui/waking_bank_finish.gd")
var bad := 0
var count := 0
func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
	for k in n:await process_frame
func check(ok: bool, text: String) -> void:
	count+=1
	if not ok:bad+=1
	print("PASS " if ok else "FAIL ",text)
func run() -> void:
	var img:=Bank.detailed_image()
	check(img!=null and img.get_size()==Vector2i(384,216),"detailed art has exact 384x216 native canvas")
	var opaque:=true
	for y in 216:
		for x in 384:
			if img.get_pixel(x,y).a!=1.0:opaque=false
	check(opaque,"background fully opaque with no keying")
	check(Bank.detailed_image(W+"missing.png")==null,"absent art selects the original code fallback")
	var wrong:=Image.create(10,10,false,Image.FORMAT_RGBA8)
	wrong.save_png(W+"wrong-size.png")
	check(Bank.detailed_image(W+"wrong-size.png")==null,"wrong-size art selects the original code fallback")
	var old:Script=load(W+"originals/scripts/ui/waking_bank.gd")
	check(Bank.paint().get_data()==old.paint().get_data(),"original fallback pixels exact")
	var pro:Node=load("res://scenes/creature_prologue.tscn").instantiate()
	pro.hero=1;pro.partner=2;pro.chosen_by_soul=true;pro.reduce_motion=true
	root.add_child(pro);await frames(8)
	check(pro.bank.artwork!=null and pro.bank.background.texture.get_image().get_data()==Finish.finished_image(img).get_data(),"actual waking viewport displays the selected material rim")
	check(pro.bank.background.material is ShaderMaterial and pro.bank.background.material.get_shader_parameter("detail_ink")==0.55,"background uses the shared masked house detail finish")
	check(pro.bank.background.texture_filter==CanvasItem.TEXTURE_FILTER_NEAREST,"native art retains nearest-neighbour pixels")
	check(pro.leader_sprite.position==Vector2(168,83) and pro.partner_sprite.position==Vector2(222,84) and pro.leader_sprite.scale==Vector2.ONE and pro.partner_sprite.scale==Vector2.ONE,"approved actor anchors and sizes unchanged")
	var t:float=pro.bank.clock
	await frames(8)
	check(pro.bank.clock==t,"Reduce Motion still freezes the composition")
	check(pro.bank.water_at(80,40) and not pro.bank.water_at(170,85),"water detection admits river and excludes standing bank")
	var out:=W+"review/after/"
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"):out=W+"review/live/"
	DirAccess.make_dir_recursive_absolute(out)
	await RenderingServer.frame_post_draw
	img.save_png(out+"art-native.png")
	var image:=img.duplicate()
	image.resize(1152,648,Image.INTERPOLATE_NEAREST)
	image.save_png(out+"art-3x.png")
	for n in root.get_children():n.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await frames(12)
	print("ART ",count-bad,"/",count," PASS")
	quit(0 if bad==0 else 1)
