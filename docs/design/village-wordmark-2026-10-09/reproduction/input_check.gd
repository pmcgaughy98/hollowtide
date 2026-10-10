extends SceneTree
const OUT="D:/dev/hollowtide-wordmark-20261009/"
var checks:Array[Dictionary]=[]
var failed:Array[String]=[]
func _initialize() -> void:call_deferred("run")
func verify(s:String,ok:bool) -> void:
	checks.append({"check":s,"passed":ok})
	if not ok:failed.append(s)
	print(s,": ",ok)
func frames(n:int) -> void:
	for i in n:await process_frame
func key(code:Key) -> void:
	var e:=InputEventKey.new();e.keycode=code;e.pressed=true;Input.parse_input_event(e)
	await process_frame
	e=InputEventKey.new();e.keycode=code;e.pressed=false;Input.parse_input_event(e)
	await frames(2)
func click(b:Button) -> void:
	var e:=InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.position=b.get_global_rect().get_center();e.pressed=true;Input.parse_input_event(e)
	await process_frame
	e=InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.position=b.get_global_rect().get_center();e.pressed=false;Input.parse_input_event(e)
	await frames(2)
func run() -> void:
	root.size=Vector2i(1152,648)
	var menu:Node2D=load("res://scenes/creature_opening.tscn").instantiate()
	root.add_child(menu);current_scene=menu
	await frames(2)
	await key(KEY_ENTER);await frames(45)
	verify("Skip input does not also trigger New Game",current_scene==menu and menu._page=="main")
	menu._reduce_motion=true
	await frames(2)
	var at:Vector2=menu.companions[0].position
	await frames(15)
	verify("Reduce motion freezes creature walk-in",at==menu.companions[0].position and menu.companions[0].texture==menu.companions[0].get_meta("rest"))
	await click(menu._buttons[0]);await frames(45)
	var story:Node2D=current_scene
	verify("Mouse New Game reaches creature opening",story.has_method("choose"))
	await click(story.cards[2])
	verify("Mouse chooses Rimefin",story.hero==2)
	await key(KEY_ENTER)
	verify("Keyboard confirms identity",story.phase==1)
	await key(KEY_ESCAPE)
	verify("Escape returns to identity without starting run",story.phase==0 and current_scene==story)
	await key(KEY_ESCAPE);await frames(20)
	verify("Escape from awakening returns to title scene",current_scene.get_script().resource_path.ends_with("creature_opening.gd"))
	var file:=FileAccess.open(OUT+"input-checks.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failed},"  "));file.close()
	current_scene.queue_free();await frames(3)
	quit(0 if failed.is_empty() else 1)
