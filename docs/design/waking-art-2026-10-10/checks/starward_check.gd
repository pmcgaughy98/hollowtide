extends SceneTree
const W="D:/dev/hollowtide-waking-art-20261010/"
const Finish=preload("res://scripts/arena/creature_finish.gd")
const Old=preload("D:/dev/hollowtide-waking-art-20261010/originals/scripts/arena/creature_finish.gd")
const UI=preload("res://scripts/ui/ui_style.gd")
var out:=W+"review/after/"
var bad:=0
var count:=0
var sprites:Array[Sprite2D]=[]
var paths:Array[String]=[]
var rects:Array[Rect2i]=[]
var sources:Array[Image]=[]
func _initialize()->void:run.call_deferred()
func frames(n:int)->void:
	for k in n:await process_frame
func check(ok:bool,text:String)->void:
	count+=1
	if not ok:bad+=1
	print("PASS " if ok else "FAIL ",text)
func run()->void:
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"):out=W+"review/live/"
	DirAccess.make_dir_recursive_absolute(out)
	var manifest:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(W+"starward-sources.json"))
	for p in manifest:paths.append("res://"+p)
	paths.sort()
	var target_count:=paths.size()
	for p in ["arena/oxbowarchon/small/s.png","arena/kithflare2/small/s.png","arena/gruntle/town/s.png","arena/skimlet/town/s.png","ui/dialogue/gruntle.png","ui/dialogue/mirekit.png","ui/dialogue/whinet.png","ui/dialogue/kithflare.png"]:
		if ResourceLoader.exists("res://assets/sprites/"+p):paths.append("res://assets/sprites/"+p)
	var vp:=SubViewport.new();vp.size=Vector2i(3520,176*ceili(paths.size()/20.0));vp.transparent_bg=true
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	for i in paths.size():
		var tex:Texture2D=load(paths[i]);var img:=tex.get_image();sources.append(img)
		var pos:=Vector2i((i%20)*176+8,(i/20)*176+8)
		var s:=Sprite2D.new();s.centered=false;s.position=pos;s.texture=tex;s.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		Old.apply(s);vp.add_child(s);sprites.append(s);rects.append(Rect2i(pos,img.get_size()))
	await frames(10);await RenderingServer.frame_post_draw
	var before:=vp.get_texture().get_image()
	for sprite in sprites:
		# Disconnect old material watchers before attaching the new helper.
		for c in sprite.texture_changed.get_connections():sprite.texture_changed.disconnect(c.callable)
		Finish.apply(sprite)
	await frames(10);await RenderingServer.frame_post_draw
	var after:=vp.get_texture().get_image()
	var alpha:=true;var highlights:=true;var others:=true;var changed:=0;var internal:=0;var rim:=0;var affected:=0
	for i in paths.size():
		var rect:=rects[i].grow(2);var per_texture:=0
		for y in range(rect.position.y,rect.end.y):
			for x in range(rect.position.x,rect.end.x):
				var a:=before.get_pixel(x,y);var b:=after.get_pixel(x,y)
				if a.a!=b.a:alpha=false
				if a==b:continue
				if i>=target_count:others=false;continue
				changed+=1;per_texture+=1
				if a.get_luminance()>0.86:highlights=false
				var p:=Vector2i(x,y)-rects[i].position;var img:=sources[i]
				if Rect2i(Vector2i.ONE,img.get_size()-Vector2i(2,2)).has_point(p):
					var interior:=img.get_pixelv(p).a>0.5
					for d in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:interior=interior and img.get_pixelv(p+d).a>0.5
					if interior:internal+=1
					else:rim+=1
				else:rim+=1
		if per_texture>0:affected+=1
	check(affected==target_count,"all %d Starward sprites, action frames and portraits receive finish"%target_count)
	check(changed>0 and internal>0 and rim>0,"refined material rim and internal seams: %d rim, %d interior pixels"%[rim,internal])
	check(alpha,"approved silhouette alpha stays exact against original finish")
	check(highlights,"bright cream highlights stay exact")
	check(others,"jade Oxbowarchon, Sparkwick, Gruntle, Skimlet and other portraits remain exact")
	var portrait_index:=paths.find("res://assets/sprites/ui/dialogue/starward.png")
	var fringe_pixels:=0
	if portrait_index>=0:
		var at:=rects[portrait_index].position
		for y in range(1,35):
			for x in range(3,25):
				if y>18 and x>10:continue
				if before.get_pixelv(at+Vector2i(x,y))!=after.get_pixelv(at+Vector2i(x,y)):fringe_pixels+=1
	check(fringe_pixels>0,"portrait head/neck fringe receives refined rim and seam detail: %d pixels"%fringe_pixels)
	# A pooled portrait must restore both shader and detail when it changes identity.
	var pooled:=sprites[0]
	pooled.texture=load("res://assets/sprites/ui/dialogue/starward_worried.png")
	check(pooled.material.shader==Finish.STARWARD_SHADER and pooled.material.get_shader_parameter("detail_ink")==0.55,"emotion portrait activates same Starward preset")
	pooled.texture=load("res://assets/sprites/ui/dialogue/gruntle.png")
	check(pooled.material.shader==Finish.SHADER and pooled.material.get_shader_parameter("detail_ink")==0.65,"pooled portrait restores Gruntle preset")
	var building:=Sprite2D.new();building.texture=load("res://assets/sprites/ui/dialogue/kithflare.png")
	preload("res://scripts/town/exterior_finish.gd").apply(building,true)
	building.texture=load("res://assets/sprites/ui/dialogue/rimefin.png")
	check(building.material.shader==preload("res://scripts/town/exterior_finish.gd").SHADER,"other shader wrappers survive non-Starward texture changes")
	building.free()
	# Native source-pixel crop enlarged only for review.
	for name in ["ui/dialogue/starward.png","ui/dialogue/starward_determined.png","arena/starward/town/s.png","arena/starward/small/s.png"]:
		var i:=paths.find("res://assets/sprites/"+name)
		if i<0:continue
		for entry in [[before,"before"],[after,"after"]]:
			var crop:Image=entry[0].get_region(rects[i].grow(2));crop.resize(crop.get_width()*6,crop.get_height()*6,Image.INTERPOLATE_NEAREST)
			crop.save_png(out+"starward-"+name.replace("/","-").trim_suffix(".png")+"-"+entry[1]+".png")
	before.save_png(out+"starward-atlas-before.png");after.save_png(out+"starward-atlas-after.png")
	for n in root.get_children():n.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await frames(12)
	print("STARWARD ",count-bad,"/",count," PASS");quit(0 if bad==0 else 1)
