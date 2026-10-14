extends SceneTree
const DIR := "D:/dev/hollowtide-storage-art-20261014/staging/"
const Rim := preload("res://scripts/art/selout.gd")
func _initialize() -> void:
	var plan: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(DIR+"placements.json"))
	var shell:=Image.create(408,312,false,Image.FORMAT_RGBA8);shell.fill(Color.BLACK)
	var wall_mask:=Image.create(408,312,false,Image.FORMAT_RGBA8);wall_mask.fill(Color.BLACK)
	var floor_img:=Image.load_from_file(DIR+"art/components/floor.png")
	shell.blit_rect(floor_img,Rect2i(Vector2i.ZERO,floor_img.get_size()),Vector2i(24,72))
	var pieces: Array=[
		["north",Vector2i(24,0)],["west",Vector2i(0,0)],["east",Vector2i(384,0)],
		["south_left",Vector2i(24,288)],["south_right",Vector2i(240,288)]]
	for piece in pieces:
		var im:=Image.load_from_file(DIR+"art/components/"+piece[0]+".png")
		shell.blit_rect(im,Rect2i(Vector2i.ZERO,im.get_size()),piece[1])
		wall_mask.fill_rect(Rect2i(piece[1],im.get_size()),Color.WHITE)
	shell.save_png(DIR+"art/shell-before-finish.png")
	shell=Rim.selout(shell,wall_mask)
	shell.save_png(DIR+"art/shell.png")
	var combined:=shell.duplicate()
	var mask:=wall_mask.duplicate()
	var cache:={}
	for name in ["cabinet_left","cabinet_right","counter","crates","basket","lamp"]:
		var source:=Image.load_from_file(DIR+"art/pre_finish/"+name+".png")
		var result:=Rim.selout(source)
		result.save_png(DIR+"art/props/"+name+".png")
		cache[name]=result
	for p in plan.instances:
		var img: Image=cache[p.asset]
		var at:=Vector2i(int(p.rect[0]),int(p.rect[1]))
		combined.blend_rect(img,Rect2i(Vector2i.ZERO,img.get_size()),at)
		for y in img.get_height():
			for x in img.get_width():
				if img.get_pixel(x,y).a>0.5:mask.set_pixelv(at+Vector2i(x,y),Color.WHITE)
	combined.save_png(DIR+"art/storage-raw.png");mask.save_png(DIR+"art/detail-mask.png")
	FileAccess.open(DIR+"art/finish.json",FileAccess.WRITE).store_string(JSON.stringify({"cpu_finish":"exact shared scripts/art/selout.gd","detail_ink":0.75,"native_size":[408,312],"prop_count":6,"instances":plan.instances.size()},"  "))
	print("STORAGE FINISH: native shell, six sel-out props, seven instances and bounded shared material mask.")
	quit()
