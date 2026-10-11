extends SceneTree
const W := "D:/dev/hollowtide-waking-art-20261010/"
const Finish := preload("res://scripts/ui/waking_bank_finish.gd")
const Bank := preload("res://scripts/ui/waking_bank.gd")
var count := 0
var bad := 0
func _initialize() -> void: run.call_deferred()
func frames(n:int) -> void:
	for k in n:await process_frame
func check(ok:bool,message:String) -> void:
	count+=1
	if not ok:bad+=1
	print("PASS " if ok else "FAIL ",message)
func canvas(img:Image,finished:bool) -> SubViewport:
	var vp:=SubViewport.new();vp.size=Vector2i(384,216)
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var s:=Sprite2D.new();s.centered=false;s.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	s.texture=ImageTexture.create_from_image(Finish.finished_image(img) if finished else img)
	if finished:Finish.apply(s,img)
	vp.add_child(s)
	return vp
func run() -> void:
	var img:=Bank.detailed_image()
	var mask:=Finish.mask(img)
	var rim:=Finish.finished_image(img)
	var unselected_exact:=true
	var rim_changes:=0
	for y in 216:
		for x in 384:
			if mask.get_pixel(x,y).r<0.5 and rim.get_pixel(x,y)!=img.get_pixel(x,y):unselected_exact=false
			if rim.get_pixel(x,y)!=img.get_pixel(x,y):rim_changes+=1
	check(unselected_exact and rim_changes>0,"material rim changes only selected river-contact pixels: %d"%rim_changes)
	var plain:=canvas(img,false);var ink:=canvas(img,true)
	await frames(8);await RenderingServer.frame_post_draw
	var a:=plain.get_texture().get_image();var b:=ink.get_texture().get_image()
	var outside:=0;var changes:=0;var alpha_exact:=true;var glows_exact:=true
	for y in 216:
		for x in 384:
			var ca:=a.get_pixel(x,y);var cb:=b.get_pixel(x,y)
			if ca.a!=cb.a:alpha_exact=false
			if ca!=cb:
				changes+=1
				if mask.get_pixel(x,y).r<0.5:outside+=1
				if img.get_pixel(x,y).get_luminance()>0.68:glows_exact=false
	check(changes>100 and outside==0,"native GPU finish changes %d selected pixels; %d outside the mask"%[changes,outside])
	check(alpha_exact,"rendered background alpha exact")
	check(glows_exact,"bright Hollow glow pixels exact")
	var protected:=true
	for r in Finish.PADS+Finish.LETTERS:
		for y in range(r.position.y,r.end.y):
			for x in range(r.position.x,r.end.x):
				if a.get_pixel(x,y)!=b.get_pixel(x,y):protected=false
	check(protected,"standing pads and sealed letters retain original rendered pixels")
	var out:=W+"review/after/"
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"):out=W+"review/live/"
	DirAccess.make_dir_recursive_absolute(out)
	mask.save_png(out+"selout-mask.png")
	for item in [["art-before-selout",a],["art-after-selout",b]]:
		var im:Image=item[1]
		im.resize(1152,648,Image.INTERPOLATE_NEAREST)
		im.save_png(out+item[0]+"-3x.png")
	for n in root.get_children():n.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await frames(12)
	print("SEL-OUT ",count-bad,"/",count," PASS")
	quit(0 if bad==0 else 1)
