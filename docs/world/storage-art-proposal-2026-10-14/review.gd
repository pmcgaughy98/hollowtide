extends SceneTree
var OUT := "D:/dev/hollowtide-storage-art-20261014/"+("review-packaged/" if OS.get_cmdline_user_args().has("packaged") else "review/")
var checks: Array=[]
var failed:=0
func _initialize() -> void:run.call_deferred()
func frames(n: int) -> void:
	for k in n:await process_frame
func ok(label: String, good: bool) -> void:
	checks.append({"check":label,"ok":good})
	if not good:failed+=1
	print(label," -> ","ok" if good else "FAIL")
func snap(name: String) -> Image:
	await frames(3);await RenderingServer.frame_post_draw
	var image:=root.get_texture().get_image();image.convert(Image.FORMAT_RGBA8);image.save_png(OUT+name+".png")
	return image
func key(code: Key) -> void:
	var event:=InputEventKey.new();event.keycode=code;event.pressed=true;Input.parse_input_event(event)
	await frames(2)
	event=InputEventKey.new();event.keycode=code;event.pressed=false;Input.parse_input_event(event)
	await frames(2)
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT);root.size=Vector2i(1224,936)
	var room: Node2D=load("res://preview.tscn").instantiate();root.add_child(room);current_scene=room;await frames(4)
	var raw:=Image.load_from_file(ProjectSettings.globalize_path("res://art/storage-raw.png"))
	var mask:=Image.load_from_file(ProjectSettings.globalize_path("res://art/detail-mask.png"))
	ok("Native art and mask are 408x312",raw.get_size()==Vector2i(408,312) and mask.get_size()==raw.get_size())
	var finished:=await snap("finished-3x")
	ok("Real review viewport is exact 3x",finished.get_size()==Vector2i(1224,936))
	finished.resize(408,312,Image.INTERPOLATE_NEAREST);finished.save_png(OUT+"finished-native.png")
	await key(KEY_SPACE)
	ok("Space toggles real material off",not room.finish_on and room.sprite.material==null)
	var without:=await snap("raw-3x");without.resize(408,312,Image.INTERPOLATE_NEAREST)
	ok("Unshaded native output equals prepared PNG",without.get_data()==raw.get_data())
	var changed:=0
	var outside:=0
	for y in 312:
		for x in 408:
			if finished.get_pixel(x,y)!=without.get_pixel(x,y):
				changed+=1
				if mask.get_pixel(x,y).r<0.5:outside+=1
	ok("Shared 0.75 shader adds purposeful selected detail",changed>100)
	ok("All unselected quiet floor pixels exact",outside==0)
	await key(KEY_SPACE);await key(KEY_M)
	ok("M toggles real material-mask view",room.mask_on and room.sprite.material==null)
	await snap("mask-3x")
	await key(KEY_M)
	ok("M restores finished art",not room.mask_on and room.finish_on and room.sprite.material!=null)
	room.queue_free();await frames(3)
	FileAccess.open(OUT+"native-checks.json",FileAccess.WRITE).store_string(JSON.stringify({"passed":checks.size()-failed,"total":checks.size(),"shader_changed_pixels":changed,"changed_unselected_pixels":outside,"checks":checks},"  "))
	print("STORAGE NATIVE: %d/%d" % [checks.size()-failed,checks.size()]);quit(0 if failed==0 else 1)
