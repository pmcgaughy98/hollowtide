extends SceneTree
const W := "D:/dev/hollowtide-wilds-selout-20261010/"
const Finish := preload("res://scripts/arena/creature_finish.gd")
const FORMS := ["skimlet","ozbender","valvekin","wayling","swaphoard","pouchbill","inkhoot","cairnshell","crawdukes"]
var old_finish:Script
var checks:=0
var fails:=0
var out:=W+"review/after/"
func _initialize() -> void:run.call_deferred()
func frames(n:int) -> void:
	for k in n:await process_frame
func check(ok:bool,label:String) -> void:
	checks+=1
	if not ok:fails+=1
	print("PASS " if ok else "FAIL ",label)
func sprite(v:SubViewport,at:Vector2,old:bool=false) -> Sprite2D:
	var s:=Sprite2D.new();s.centered=false;s.position=at;s.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	v.add_child(s)
	if old:old_finish.apply(s)
	else:Finish.apply(s)
	return s
func run() -> void:
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"):out=W+"review/live/"
	DirAccess.make_dir_recursive_absolute(out)
	old_finish=load(W+"originals/scripts/arena/creature_finish.gd")
	var v:=SubViewport.new();v.size=Vector2i(6144,1536);v.transparent_bg=true;v.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(v)
	var left:Array[Sprite2D]=[];var right:Array[Sprite2D]=[]
	for k in 128:
		var at:=Vector2((k%16)*192+8,(k/16)*192+8)
		left.append(sprite(v,at,true));right.append(sprite(v,at+Vector2(3072,0)))
	var paths:Array[String]=[]
	var counts:Dictionary={};var alpha_exact:=true;var white_exact:=true;var ink:=0
	for form in FORMS:
		var base:String="res://assets/sprites/arena/"+form+"/"
		for dir in [base,base+"town/",base+"dungeon/"]:
			if not DirAccess.dir_exists_absolute(dir):continue
			for file in DirAccess.get_files_at(dir):
				if file.ends_with(".png"):paths.append(dir+file)
		for file in DirAccess.get_files_at("res://assets/sprites/ui/dialogue"):
			if file==form+".png" or (file.begins_with(form+"_") and file.ends_with(".png")):paths.append("res://assets/sprites/ui/dialogue/"+file)
	for start in range(0,paths.size(),128):
		var size:=mini(128,paths.size()-start)
		for k in 128:
			left[k].visible=k<size;right[k].visible=k<size
			if k<size:left[k].texture=load(paths[start+k]);right[k].texture=left[k].texture
		await frames(3);await RenderingServer.frame_post_draw
		var im:=v.get_texture().get_image()
		for k in size:
			var a:=im.get_region(Rect2i((k%16)*192,(k/16)*192,192,192));var b:=im.get_region(Rect2i(3072+(k%16)*192,(k/16)*192,192,192))
			var form:=paths[start+k].get_base_dir().get_file()
			if form=="dialogue":form=paths[start+k].get_file().get_basename().get_slice("_",0)
			if form in ["town","dungeon"]:form=paths[start+k].get_base_dir().get_base_dir().get_file()
			for y in 192:
				for x in 192:
					var c:=a.get_pixel(x,y);var d:=b.get_pixel(x,y)
					alpha_exact=alpha_exact and c.a==d.a
					if form!="skimlet" and c.a>0.5 and minf(c.r,minf(c.g,c.b))>0.86:white_exact=white_exact and c==d
					if c!=d:ink+=1
			if paths[start+k].ends_with("/s.png") and paths[start+k].get_base_dir().get_file() in FORMS:
				var pair:=Image.create(384,192,false,Image.FORMAT_RGBA8);pair.blit_rect(a,Rect2i(0,0,192,192),Vector2i.ZERO);pair.blit_rect(b,Rect2i(0,0,192,192),Vector2i(192,0));pair.save_png(out+form+"-before-after.png")
	print("New creature textures rendered: ",paths.size())
	check(paths.size()>1000 and ink>1000,"nine new creature sets receive visible detail ink across facings/walks/actions/portraits")
	check(alpha_exact,"finished alpha and silhouettes stay exact across all new textures")
	check(white_exact,"other new creatures' bright highlights remain exact")
	# Three dots on the left leg in the south-facing source; normal eyes/back highlight remain bright.
	left[0].texture=load("res://assets/sprites/arena/skimlet/s.png");right[0].texture=left[0].texture
	await frames(3);await RenderingServer.frame_post_draw
	var im:=v.get_texture().get_image();var dots:=true;var body:=true
	for p in [Vector2i(89,51),Vector2i(89,52),Vector2i(89,53),Vector2i(82,54)]:
		var d:=im.get_pixelv(p+Vector2i(3080,8));dots=dots and maxf(d.r,maxf(d.g,d.b))<0.4
	for p in [Vector2i(62,44),Vector2i(55,63),Vector2i(67,64)]:body=body and im.get_pixelv(p+Vector2i(8,8))==im.get_pixelv(p+Vector2i(3080,8))
	check(dots and body,"Skimlet left-leg dots corrected; eye and central body highlights exact")
	# Every prior form remains exact under the unchanged default parameters.
	var quiet:=true;var n:=0
	for form in DirAccess.get_directories_at("res://assets/sprites/arena"):
		if form in FORMS:continue
		var p:="res://assets/sprites/arena/"+form+"/s.png"
		if not ResourceLoader.exists(p):continue
		left[n].texture=load(p);right[n].texture=left[n].texture;n+=1
	for k in 128:left[k].visible=k<n;right[k].visible=k<n
	await frames(3);await RenderingServer.frame_post_draw
	im=v.get_texture().get_image()
	for k in n:quiet=quiet and im.get_region(Rect2i((k%16)*192,(k/16)*192,192,192)).get_data()==im.get_region(Rect2i(3072+(k%16)*192,(k/16)*192,192,192)).get_data()
	check(quiet,"all older forms stay byte-exact, including Gruntle, Starward, jade Oxbowarchon and Sparkwick")
	right[0].texture=load("res://assets/sprites/arena/skimlet/s.png")
	right[0].texture=load("res://assets/sprites/arena/sparkwick/s.png")
	check(not right[0].material.get_shader_parameter("skimlet_leg_fix") and right[0].material.get_shader_parameter("sparkwick_palette"),"switching clears Skimlet correction and preserves Sparkwick")
	v.queue_free();await frames(4)
	var closeup:=SubViewport.new();closeup.size=Vector2i(768,384);closeup.transparent_bg=true;closeup.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(closeup)
	var a:=sprite(closeup,Vector2.ZERO,true);a.texture=load("res://assets/sprites/arena/skimlet/s.png");a.scale=Vector2(3,3)
	var b:=sprite(closeup,Vector2(384,0));b.texture=a.texture;b.scale=Vector2(3,3)
	await frames(5);await RenderingServer.frame_post_draw
	closeup.get_texture().get_image().save_png(out+"skimlet-leg-before-after-3x.png")
	closeup.queue_free();await frames(12)
	print("NEW FINISH ",checks-fails,"/",checks," PASS")
	quit(0 if fails==0 else 1)
