extends SceneTree
const W := "D:/dev/hollowtide-new-scene-selout-20261010/"
const Finish := preload("res://scripts/arena/creature_finish.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const Portraits := preload("res://scripts/ui/crew_portrait_canvas.gd")
var old_finish: Script
var count := 0
var bad := 0
var out := W+"review/after/"
func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
	for k in n: await process_frame
func check(ok: bool, label: String) -> void:
	count+=1
	if not ok: bad+=1
	print("PASS " if ok else "FAIL ",label)
func view(size: Vector2i) -> SubViewport:
	var v:=SubViewport.new();v.size=size;v.transparent_bg=true;v.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(v);return v
func sprite(v: SubViewport, at: Vector2) -> Sprite2D:
	var s:=Sprite2D.new();s.centered=false;s.position=at;s.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	v.add_child(s);return s
func run() -> void:
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"):out=W+"review/live/"
	DirAccess.make_dir_recursive_absolute(out)
	old_finish=load(W+"originals/scripts/arena/creature_finish.gd")
	var baseline:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(W+"baseline.json"))
	var paths:Array[String]=[]
	for form in DirAccess.get_directories_at("res://assets/sprites/arena"):
		var dir:="res://assets/sprites/arena/%s/town/"%form
		if not DirAccess.dir_exists_absolute(dir):continue
		for file in DirAccess.get_files_at(dir):
			if file.ends_with(".png"):paths.append(dir+file)
	for file in DirAccess.get_files_at("res://assets/sprites/arena/gruntle"):
		if file.ends_with(".png"):paths.append("res://assets/sprites/arena/gruntle/"+file)
	var v:=view(Vector2i(5120,1280))
	var left:Array[Sprite2D]=[];var right:Array[Sprite2D]=[]
	for k in 128:
		var at:=Vector2((k%16)*160+8,(k/16)*160+8)
		var a:=sprite(v,at);old_finish.apply(a);left.append(a)
		var b:=sprite(v,at+Vector2(2560,0));Finish.apply(b);right.append(b)
	var alpha_exact:=true;var quiet_exact:=true;var white_exact:=true;var ink:=0;var fits:=true
	for start in range(0,paths.size(),128):
		var size:=mini(128,paths.size()-start)
		for k in 128:
			left[k].visible=k<size;right[k].visible=k<size
			if k>=size:continue
			var tex:Texture2D=load(paths[start+k]);left[k].texture=tex;right[k].texture=tex
			fits=fits and tex.get_width()<=144 and tex.get_height()<=144
		await frames(2);await RenderingServer.frame_post_draw
		var im:=v.get_texture().get_image()
		for k in size:
			var a:=im.get_region(Rect2i((k%16)*160,(k/16)*160,160,160))
			var b:=im.get_region(Rect2i(2560+(k%16)*160,(k/16)*160,160,160))
			if "/gruntle/" not in paths[start+k]:
				quiet_exact=quiet_exact and a.get_data()==b.get_data()
			else:
				for y in 160:
					for x in 160:
						var c:=a.get_pixel(x,y);var d:=b.get_pixel(x,y)
						alpha_exact=alpha_exact and c.a==d.a
						if c.a>0.5 and minf(c.r,minf(c.g,c.b))>0.86:white_exact=white_exact and c==d
						if c!=d:ink+=1
	print("Rendered new town/root textures: ",paths.size())
	check(paths.size()>3500 and fits,"all new town sets and Gruntle rotations rendered at native grid without clipping")
	check(quiet_exact,"every existing form's town finish remains byte-exact, including jade Oxbowarchon and Sparkwick")
	check(alpha_exact and white_exact and ink>50,"Gruntle gains detail ink with identical finished alpha and bright highlights")
	# Dynamic stand-in has no resource path; its known creature identity still gets the finish.
	var image:=Image.load_from_file(ProjectSettings.globalize_path("res://assets/sprites/arena/gruntle/s.png"))
	var dynamic:=ImageTexture.create_from_image(image)
	right[0].texture=dynamic
	Finish.apply(right[0],false,"gruntle")
	check(right[0].material.get_shader_parameter("detail_ink")==0.65,"Gruntle's texture-less NPC fallback keeps its finish")
	right[0].texture=load("res://assets/sprites/arena/sparkwick/town/s.png")
	check(right[0].material.get_shader_parameter("detail_ink")==0.0 and right[0].material.get_shader_parameter("sparkwick_palette"),"texture switch clears rival ink and preserves Sparkwick correction")
	v.queue_free();await frames(4)
	# Actual UI pipeline: the old town had no portrait layer; the new one draws only the creature.
	var pv:=view(Vector2i(512,256));var before:=Node2D.new();var after:=Node2D.new()
	pv.add_child(before);pv.add_child(after);after.position.x=256
	var layer:=Portraits.new();layer.name="CrewPortraitFinish";after.add_child(layer)
	var holder:={"tex":null,"face":"normal"}
	var draw_portrait:=func(c:Node2D):UI.portrait(c,Rect2(42,48,120,120),holder.tex,false,holder.face)
	before.draw.connect(draw_portrait.bind(before))
	after.draw.connect(draw_portrait.bind(after))
	var n:=0;var exact_outside:=true;var exact_marks:=true;var form_materials:=true
	for form in ["gruntle","starward","mirekit","whinet"]:
		for file in DirAccess.get_files_at("res://assets/sprites/ui/dialogue"):
			if not file.ends_with(".png") or not (file==form+".png" or file.begins_with(form+"_")):continue
			if not baseline.has("assets/sprites/ui/dialogue/"+file):continue
			holder.tex=load("res://assets/sprites/ui/dialogue/"+file)
			holder.face=file.get_basename().trim_prefix(form+"_") if file!=form+".png" else "normal"
			layer.clear();before.queue_redraw();after.queue_redraw()
			await frames(3);await RenderingServer.frame_post_draw
			var im:=pv.get_texture().get_image()
			form_materials=form_materials and im.get_pixel(40,36).a>0.5 and im.get_pixel(296,36).a>0.5
			var outside_count:=0
			form_materials=form_materials and layer.sprites.size()>0 and layer.sprites[0].material.get_shader_parameter("detail_ink")== (0.0 if form=="starward" else 0.65)
			for y in 256:
				for x in 256:
					if not Rect2i(42,48,120,120).has_point(Vector2i(x,y)):
						if im.get_pixel(x,y)!=im.get_pixel(x+256,y):outside_count+=1
						exact_outside=exact_outside and im.get_pixel(x,y)==im.get_pixel(x+256,y)
			if outside_count>0:print("OUTSIDE ",file," ",outside_count)
			if holder.face=="angry":
				for p in [Vector2i(136,57),Vector2i(151,60),Vector2i(151,69)]:
					if im.get_pixelv(p)!=im.get_pixelv(p+Vector2i(256,0)):print("MARK ",file," ",p)
					exact_marks=exact_marks and im.get_pixelv(p)==im.get_pixelv(p+Vector2i(256,0))
			if form in ["gruntle","starward"]:im.save_png(out+file.get_basename()+"-portrait-before-after.png")
			n+=1
	check(n>=27 and form_materials,"all installed crew and Starward normal/expression portraits select the proper finish")
	check(exact_outside and exact_marks,"actual GPU frame outside portrait window and emotion marks stay exact; no creature crosses the border")
	check(layer.sprites.size()==1,"portrait pool reuses one sprite across expressions")
	layer.clear();await frames(3)
	check(not layer.sprites[0].visible and layer.draws.is_empty(),"closing dialogue clears the finished portrait without a ghost")
	pv.queue_free();await frames(12)
	print("Portraits rendered: ",n)
	print("SELOUT ",count-bad,"/",count," PASS")
	quit(0 if bad==0 else 1)
