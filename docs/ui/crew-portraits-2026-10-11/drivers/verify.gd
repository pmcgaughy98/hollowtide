extends SceneTree
const W := "D:/dev/hollowtide-crew-portraits-20261011/"
const UI := preload("res://scripts/ui/ui_style.gd")
const State := preload("res://scripts/town/team_state.gd")
const Finish := preload("res://scripts/arena/creature_finish.gd")
var checks:=0
var fails:=0
var out:=W+"review/stage/"
var rows:Array
var textures:Array[Texture2D]=[]
func _initialize() -> void:_run.call_deferred()
func _frames(n:int) -> void:
	for k in n:await process_frame
func _ok(good:bool,label:String) -> void:
	checks+=1
	if not good:fails+=1
	print(("PASS " if good else "FAIL ")+label)
func _gallery(c:CanvasItem) -> void:
	c.draw_rect(Rect2(0,0,1152,228),Color("#242923"))
	for k in rows.size():
		var x:=22+k*190
		UI.portrait(c,Rect2(x,30,120,120),textures[k],false,"normal")
		UI.text(c,Vector2(x,198),String(rows[k].form).capitalize(),18,UI.TEXT,164)
func _run() -> void:
	if ProjectSettings.globalize_path("res://").to_lower().begins_with("c:/"):out=W+"review/live/"
	DirAccess.make_dir_recursive_absolute(out)
	rows=JSON.parse_string(FileAccess.get_file_as_string(W+"evidence/manifest.json"))
	var outline_total:=0
	for row in rows:
		var tex:=UI.dialogue_portrait(row.form)
		_ok(tex!=null and tex.get_size()==Vector2(40,40),row.form+": normal portrait resolves at townsfolk 40px size")
		if tex==null:quit(1);return
		textures.append(tex)
		var imported:=tex.get_image();imported.convert(Image.FORMAT_RGBA8)
		var png:=Image.load_from_file(W+"prepared/"+row.output);png.convert(Image.FORMAT_RGBA8)
		_ok(imported.get_data()==png.get_data(),row.form+": native import RGBA byte-exact")
		var before:=Image.load_from_file(W+"evidence/before_outline/"+row.form+".png")
		var alpha_exact:=true;var interior_exact:=true;var rim_black:=true;var binary:=true
		for y in 40:
			for x in 40:
				var p:=Vector2i(x,y);var c:=imported.get_pixelv(p);var b:=before.get_pixelv(p)
				alpha_exact=alpha_exact and c.a==b.a
				binary=binary and (c.a==0.0 or c.a==1.0)
				var boundary:=false
				for d in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
					var q:Vector2i=p+d
					if Rect2i(0,0,40,40).has_point(q) and before.get_pixelv(q).a==0.0:boundary=true
				if c!=b:
					if not boundary:interior_exact=false
					if c.r!=0.0 or c.g!=0.0 or c.b!=0.0:rim_black=false
		_ok(alpha_exact and interior_exact and rim_black and binary,row.form+": outline changes only the transparency rim; hard alpha and interiors exact")
		outline_total+=int(row.outline_pixels)
		var fallbacks:=true
		for face in ["happy","joyous","surprised","sad","worried","angry","determined","mischievous"]:
			fallbacks=fallbacks and UI.dialogue_portrait(row.form+":"+face)==tex
		_ok(fallbacks,row.form+": unbuilt expression faces fall back to normal")
	var view:=SubViewport.new();view.size=Vector2i(1152,228);view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	view.canvas_item_default_texture_filter=Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(view)
	var gallery:=Node2D.new();view.add_child(gallery);gallery.draw.connect(_gallery.bind(gallery));gallery.queue_redraw()
	await _frames(4);await RenderingServer.frame_post_draw
	var sheet:=view.get_texture().get_image();sheet.save_png(out+"native-gallery.png")
	for k in rows.size():
		var portrait:=textures[k].get_image();var exact:=true
		for y in 40:
			for x in 40:
				var c:=portrait.get_pixel(x,y)
				if c.a<0.5:continue
				for dy in 3:
					for dx in 3:
						if sheet.get_pixel(22+k*190+x*3+dx,30+y*3+dy)!=c:exact=false
		_ok(exact,rows[k].form+": shared portrait frame renders the opaque pixels at exact nearest 3x")
	view.queue_free();await _frames(4)
	# Existing production post interaction and SceneKit speaker resolution, without script hooks.
	var scenes:={"grubbit":"hall","stillwade":"hall_low","wickglow":"hall_low","muskin":"hall_low","slipjaw":"hall_low","rinsepaw":"hall_low"}
	var approaches:={"grubbit":Vector2i(17,12),"stillwade":Vector2i(4,4),"wickglow":Vector2i(11,4),"muskin":Vector2i(6,12),"slipjaw":Vector2i(2,8),"rinsepaw":Vector2i(2,11)}
	for row in rows:
		State.start([[0,0],[1,0]])
		State.data["story"]={"met_crew":true,"parcel":"stolen","guild_trial":true,"runner":true}
		State.data["rollcall_runs"]=0
		var r:=load("res://scenes/town_room.tscn").instantiate() as Node2D
		r.room_id=scenes[row.form];r.poll_input=false;r.arrive=approaches[row.form];r.arrive_facing="n"
		root.add_child(r);await _frames(8)
		var action:Dictionary=r.act_use();await _frames(3)
		var correct:bool=not r.talk.is_empty() and r.cutscene and action.get("id","")=="talk_"+row.form
		if correct:correct=String(r.talk[0][2])==row.form and UI.dialogue_portrait(r.talk[0][2])==UI.dialogue_portrait(row.form)
		_ok(correct,row.form+": actual NPC post interaction opens its portrait through SceneKit")
		if not r.talk.is_empty():
			UI.finish_line();r._hud.queue_redraw();await _frames(3);await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(out+row.form+"_dialogue.png")
			var gpu:=root.get_texture().get_image();var portrait:=UI.dialogue_portrait(row.form).get_image();var hud_exact:=true
			for y in 40:
				for x in 40:
					var c:=portrait.get_pixel(x,y)
					if c.a<0.5:continue
					if gpu.get_pixel(214+x*3+1,302+y*3+1)!=c:hud_exact=false
			_ok(hud_exact,row.form+": real room dialogue paints the correct portrait inside its frame")
		else:_ok(false,row.form+": real room dialogue paints the correct portrait inside its frame")
		var advances:=0
		while not r.talk.is_empty() and advances<12:
			UI.finish_line();r.talk.pop_front();await _frames(2);advances+=1
		await _frames(3)
		_ok(not r.cutscene and r.talk.is_empty(),row.form+": conversation exits normally")
		r.queue_free();await _frames(6)
	_ok(UI.dialogue_portrait("no_such_crew_form")==null,"Unknown speaker retains the existing null-portrait behavior")
	print("CREW PORTRAITS %d/%d PASS; %d black rim pixels" % [checks-fails,checks,outline_total])
	var file:=FileAccess.open(out+"results.json",FileAccess.WRITE);file.store_string(JSON.stringify({"checks":checks,"passed":checks-fails,"outline_pixels":outline_total,"forms":rows.map(func(r):return r.form)},"\t"));file.close()
	for child in root.get_children():child.queue_free()
	load("res://scripts/audio/music.gd")._inst=null
	await _frames(16);quit(0 if fails==0 else 1)
