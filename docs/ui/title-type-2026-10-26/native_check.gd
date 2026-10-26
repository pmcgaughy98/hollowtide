extends SceneTree
const W := "D:/dev/hollowtide-title-type-20261026"
const UI := preload("res://scripts/ui/ui_style.gd")
const Team := preload("res://scripts/town/team_state.gd")
var phase := "before"
var total := 0
var failed := 0
var facts := {}
func _initialize() -> void: _run.call_deferred()
func frames(n: int) -> void:
	for i in n:await process_frame
func check(label: String, ok: bool) -> void:
	total+=1
	if not ok:failed+=1
	print("TYPE_CHECK ",label," -> ","ok" if ok else "FAIL")
func shot(name: String) -> void:
	await frames(3);await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(W+"/native-"+phase+"/"+name+".png")
func buttons(n: Node) -> Array:
	var out:=[]
	if n is Button and n.is_visible_in_tree():out.append(n)
	for c in n.get_children():out.append_array(buttons(c))
	return out
func role_buttons(title: Node, label: String) -> void:
	var bad:=[]
	for b: Button in buttons(title):
		var box: StyleBox=b.get_theme_stylebox("normal")
		if b.get_theme_font("font")!=UI.font("button") or b.get_theme_font_size("font_size")!=UI.type_size("button") or not(box is StyleBoxTexture):bad.append(String(b.name)+" role/frame")
		if b.get_theme_stylebox("focus") is not StyleBoxTexture:bad.append(String(b.name)+" focus frame")
		var room: float=b.size.x-box.get_content_margin(SIDE_LEFT)-box.get_content_margin(SIDE_RIGHT)
		if UI.width_in(b.text,"button")>room+1:bad.append(String(b.name)+" clipped text")
	check(label+" visible buttons use shared type/frames and fit "+str(bad),bad.is_empty())
func in_screen(panel: Control, label: String, bottom := 636.0) -> void:
	var r:=panel.get_global_rect();facts[label]=[r.position.x,r.position.y,r.size.x,r.size.y]
	check(label+" full panel inside screen",r.position.x>=16 and r.position.y>=0 and r.end.x<=1136 and r.end.y<=bottom)
func _run() -> void:
	phase=OS.get_environment("HT_TYPE_PHASE")
	root.size=Vector2i(1152,648);root.content_scale_size=Vector2i(1152,648)
	Team.save_path="user://title-type-private.save"
	DirAccess.make_dir_recursive_absolute(W+"/native-"+phase)
	for saved in [false,true]:
		Team.erase_save()
		if saved:Team.start([[0,0],[1,0]]);Team.save()
		var title=load("res://scenes/creature_opening.tscn").instantiate();root.add_child(title)
		var waited:=0
		while not(title._boot_done and title._page=="main") and waited<300:await process_frame;waited+=1
		check("title opens with save="+str(saved),title._boot_done and title._page=="main")
		in_screen(title._main_panel,"main-save-"+str(saved),608)
		role_buttons(title,"main-save-"+str(saved))
		check("menu hint uses shared label role",title._input_hint.get_theme_font("font")==UI.font("label") and title._input_hint.get_theme_font_size("font_size")==UI.type_size("label"))
		await shot("main-save-"+str(saved))
		if not saved:
			var wm: Image=title._wordmark.texture.get_image()
			wm.convert(Image.FORMAT_RGBA8)
			wm.save_png(W+"/wordmark-"+phase+".png")
			if phase=="after":
				var old=Image.load_from_file(W+"/wordmark-before.png");old.convert(Image.FORMAT_RGBA8)
				check("carved wordmark pixel exact",old.get_data()==wm.get_data())
		title._on_options();await frames(4)
		in_screen(title._options_panel,"options-save-"+str(saved));role_buttons(title,"options")
		var heading: Label=title._options_panel.get_node("Choices").get_child(0)
		check("Options heading uses shared title role",heading.get_theme_font("font")==UI.font("title") and heading.get_theme_font_size("font_size")==UI.type_size("title"))
		await shot("options-save-"+str(saved));title._close_panel();await frames(3)
		title._open_help();await frames(3)
		for topic in ["journey","controls"]:
			title._show_help_topic(topic);await frames(4)
			in_screen(title._help_panel,"help-"+topic+"-save-"+str(saved));role_buttons(title,"help-"+topic)
			check("Help prose uses body and section labels use label",title._help_copy.get_child(0).get_theme_font("font")==UI.font("label") and title._help_copy.get_child(1).get_theme_font("font")==UI.font("body"))
			if not saved:await shot("help-"+topic)
		title._close_panel();await frames(3);title._on_quit();await frames(4)
		in_screen(title._quit_panel,"quit-save-"+str(saved));role_buttons(title,"quit")
		if not saved:await shot("quit")
		title._quit_controls[0].pressed.emit();await frames(3)
		check("Quit cancel returns main",title._page=="main" and not title._leaving)
		title.queue_free();await frames(3)
	Team.erase_save()
	var soul=load("res://scenes/soul_prologue.tscn").instantiate();root.add_child(soul);soul.set_process(false)
	soul.line=4;soul.stage="talk";soul.shown=0;soul._ui.queue_redraw();await frames(4)
	if phase=="before":
		soul.shown=soul._text().length();soul._ui.queue_redraw();await shot("soul-long-line")
	else:
		var text: String=soul._text()
		check("soul dialogue registers full line in shared reader",UI._line["text"]==text)
		var pages:=int(UI._line["pages"])
		check("long soul line has all required pages",pages==ceili(UI._dialogue_rows(text,802.0).size()/2.0) and pages>=2)
		for page in pages:
			soul.advance();soul._ui.queue_redraw();await frames(3)
			check("soul page%d finishes without advancing story"%page,soul.line==4 and UI._line["done"] and int(UI._line["page"])==page)
			await shot("soul-page-"+str(page))
			if page<pages-1:
				soul.advance();soul._ui.queue_redraw();await frames(3)
				check("soul page%d turns without skipping story"%page,soul.line==4 and int(UI._line["page"])==page+1)
		soul.advance();await frames(2)
		check("story advances only after final page",soul.line==5)
		var bad_rows:=[]
		for item in soul.LINES+soul.AFTER:
			var full: String=String(item[0]).replace("{name}","Tallowroot")
			for row in UI._dialogue_rows(full,802.0):
				if UI.width_in(row,"story")>812:bad_rows.append(row)
		check("every soul dialogue row fits story-role page",bad_rows.is_empty())
		var end_y: float=54+UI.font("story").get_height(UI.type_size("story"))+UI.font("story").get_descent(UI.type_size("story"))
		check("two story-role rows stay above dialogue frame bevel",end_y<=110)
	soul.stage="choose";soul.line=8;soul.pick=1;soul.shown=soul._text().length();soul._ui.queue_redraw();await frames(3)
	# The running scene redraws each frame; the frozen capture needs the redraw after completing the prompt.
	soul._ui.queue_redraw();await frames(3)
	if phase=="after":
		check("choice prompt is complete in shared story role",UI._line["text"]==soul._text() and UI._line["done"])
		var bad_cards:=[]
		for k in 3:
			if UI.width_in(soul.NAMES[k],"name")>208 or UI.wrap_text(soul.FEEL[k],268,"body").split("\n").size()>2:bad_cards.append(soul.NAMES[k])
		check("three starter names and descriptions fit their roles",bad_cards.is_empty())
	await shot("starter-cards")
	soul.advance();soul._ui.queue_redraw();await frames(3)
	check("starter choice and resulting story preserved",soul.chosen==1 and soul.stage=="after" and soul._text().begins_with("Tallowroot"))
	if phase=="after":
		soul.auto=true;soul.auto_pick=1;soul.set_process(true)
		var hand_wait:=0
		while not soul.has_meta("handoff") and hand_wait<1500:await process_frame;hand_wait+=1
		var next: Node=soul.get_meta("handoff",null)
		check("native paginated story reaches chosen-creature handoff",next!=null and next.hero==1 and next.chosen_by_soul)
		if next!=null:next.free()
	soul.queue_free();await frames(3)
	for name in ["HollowtideMusic"]:
		var n=root.get_node_or_null(name)
		if n!=null:n.queue_free()
	if is_instance_valid(UI._blip):UI._blip.queue_free()
	await frames(4)
	var result={"phase":phase,"passed":total-failed,"total":total,"failed":failed,"bounds":facts}
	var f=FileAccess.open(W+"/"+phase+"-result.json",FileAccess.WRITE);f.store_string(JSON.stringify(result,"\t"));f.close()
	print("TITLE TYPE RESULT ",JSON.stringify(result))
	quit(0 if phase=="before" or failed==0 else 1)
