extends SceneTree
const W := "D:/dev/hollowtide-storm-pixels-20261026"
const Team := preload("res://scripts/town/team_state.gd")
var phase := "before"
var checks: Array=[]
var failed:=0
var samples: Array=[]
func _initialize() -> void:_run.call_deferred()
func frames(n: int) -> void:
	for i in n:await process_frame
func check(label: String, good: bool) -> void:
	checks.append({"check":label,"passed":good})
	if not good:failed+=1
	print(label,": ","PASS" if good else "FAIL")
func redraw(s: Node) -> void:
	s.soul.queue_redraw();await frames(3);await RenderingServer.frame_post_draw
func uniform_blocks(im: Image) -> bool:
	# Away from the hint, every native light/world pixel must occupy exactly3x3 view pixels.
	for y in range(150,330,3):
		for x in range(360,660,3):
			var base:=im.get_pixel(x,y)
			for by in 3:
				for bx in 3:
					if im.get_pixel(x+bx,y+by)!=base:return false
	return true
func _run() -> void:
	phase=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(W+"/"+phase)
	root.size=Vector2i(1152,648);root.content_scale_size=root.size
	Team.save_path="user://storm-pixels-private.save";Team.erase_save();Team.data={"party":[[0,0]]};Team.save()
	var saved:=FileAccess.get_sha256(Team.save_path)
	var s: Node=load("res://scenes/storm_open.tscn").instantiate();root.add_child(s);await frames(3)
	s.process_mode=Node.PROCESS_MODE_DISABLED;s._t=0.0;s.soul_at=s.WAKE_AT;s.grey=1.0;s.frozen=true;s.flash=0.0;s._skip_hint.visible=false
	# Static light samples bypass only the paused opening veil, never a production fade.
	for child in s.get_children():
		if child is CanvasLayer:
			for item in child.get_children():
				if item is ColorRect:item.hide()
	s.display.material.set_shader_parameter("grey",1.0);s.display.material.set_shader_parameter("flash",0.0)
	check("Native transparent light layer stays384x216",s.lights.size==Vector2i(384,216) and s.lights.transparent_bg)
	check("Nearest native light layer retained",s.lights.canvas_item_default_texture_filter==Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST)
	for sample in [["hidden",0.0,0.0],["appearing",0.25,0.0],["landed",1.0,0.0],["bloom",2.0,0.0],["peak",3.0,0.0],["reduced-white",3.0,0.4],["normal-white",3.0,1.0]]:
		s.soul_glow=sample[1];s.white=sample[2];await redraw(s)
		var light: Image=s.lights.get_texture().get_image();var full: Image=root.get_texture().get_image()
		light.save_png(W+"/"+phase+"/"+sample[0]+"-native.png");full.save_png(W+"/"+phase+"/"+sample[0]+".png")
		var used:=light.get_used_rect();samples.append({"case":sample[0],"glow":sample[1],"white":sample[2],"used":[used.position.x,used.position.y,used.size.x,used.size.y]})
		check(sample[0]+" pixels stay aligned to native3x grid",uniform_blocks(full))
		if sample[0]=="hidden":check("No soul pixels when glow is zero",used.size==Vector2i.ZERO)
		if sample[0]=="landed":
			check("Light lands around the original waking coordinate",used.has_point(Vector2i(s.WAKE_AT)))
			if phase=="after":
				check("Authored cluster has25x25 native extent",used.size==Vector2i(25,25))
				check("White core is opaque on the native grid",light.get_pixel(168,80).a>0.99)
				check("Stepped corner remains transparent",light.get_pixel(156,68).a<0.01)
				check("Authored halo retains faint pixel at top",light.get_pixel(168,68).a>0.08 and light.get_pixel(168,68).a<0.12)
		if sample[0]=="peak":check("Bloom expands without covering whole viewport",used.size.x>=75 and used.size.x<=85 and used.size.y>=75 and used.size.y<=85)
		if sample[2]>0.0:check(sample[0]+" original full-screen white opacity retained",absf(light.get_pixel(0,0).a-float(sample[2]))<0.01)
	if phase=="after":
		check("Mask rows form a25x25 authored pixel cluster",s.SOUL_PIXELS.size()==25 and s.SOUL_PIXELS.all(func(row: String) -> bool:return row.length()==25))
		check("Exactly four light values and transparent space",s.SOUL_COLOURS.size()==4 and not s.SOUL_COLOURS.has(" "))
	check("Private saved journey bytes unchanged",FileAccess.get_sha256(Team.save_path)==saved)
	# Let the paused cold-open coroutine finish its next leaving check before freeing its owner.
	s.leaving=true;s.process_mode=Node.PROCESS_MODE_INHERIT
	for tween in get_processed_tweens():tween.custom_step(10.0)
	await frames(50);s.queue_free();await frames(4);Team.erase_save()
	var result:={"phase":phase,"total":checks.size(),"failed":failed,"checks":checks,"samples":samples}
	var f:=FileAccess.open(W+"/"+phase+"-result.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"  "));f.close()
	print("STORM PIXELS RESULT ",checks.size()," checks / ",failed," failures");quit(0 if failed==0 else 1)
