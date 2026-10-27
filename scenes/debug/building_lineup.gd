extends Node2D
## The building lineup (Claude, 2026-10-26, placeholder factory lane B; build plan section 2.2 step 2). Open
## scenes/debug/building_lineup.tscn and press F6. Every building class in BuildingTemplate.CLASSES stands beside
## Codex's current picture for it, with a stage 1, 2 and 3 creature at each door (their town sets, as the town draws
## them), at scale 1.0 (top row) and 1.25 (bottom row), so the building scale (Preston's call 1) can be picked by eye
## before Codex and Grok get their lists. The hall class is the Wayline Tower. Nothing here is saved or changes the game.
##   Arrows or WASD: pan    Mouse wheel or + and -: zoom    1 or 2: the 1.0 or 1.25 row    0: everything
##   T: pan up the Tower at the town's 3x view    F: placeholders forced on or off (what an installed file replaces)

const BT := preload("res://scripts/town/building_template.gd")
const Layout := preload("res://scripts/town/town_layout.gd")
const CreatureFinish := preload("res://scripts/arena/creature_finish.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const T := 24
## Codex's current picture per class: the v1 place whose PNG (its slot's legacy_v1) stands in the town today.
const TODAY := {"cottage": "home", "shop": "shop", "stall": "", "hall": "hall"}
## The template's slot per class (the stall has none until a lot opens; its template is drawn).
const TEMPLATE := {"cottage": "home", "shop": "shop", "stall": "stall", "hall": "hall"}
## One creature per stage; Sparkjab and Galeshear are the single and double doors' pass creatures.
const CREATURES := ["cinderhide", "sparkjab", "galeshear"]
const COL_GAP := 48
const ROW_GAP := 140
const GROUND := Color("#53673e")
const BACKDROP := Color("#24302f")

var _cam: Camera2D
var _world: Node2D
var _hud: Label
var _rows: Array[Rect2] = []
var _all := Rect2()
var _tower: Dictionary = {}   # the 1.0 row's Tower: "door" and "top" in world px
var _tween: Tween
var _font: Font


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	RenderingServer.set_default_clear_color(BACKDROP)
	_font = UI.font("label")   # Silkscreen, drawn at whole multiples of its 8 px design size
	_cam = Camera2D.new()
	_cam.name = "Camera"
	add_child(_cam)
	_cam.make_current()
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud = Label.new()
	_hud.position = Vector2(12, 8)
	_hud.add_theme_font_size_override("font_size", 16)
	_hud.add_theme_color_override("font_color", Color("#fff4e8"))
	_hud.add_theme_color_override("font_outline_color", Color("#0b0e11"))
	_hud.add_theme_constant_override("outline_size", 4)
	layer.add_child(_hud)
	_build()
	_frame(_all)


## Lays both rows out again (after F flips the placeholders).
func _build() -> void:
	if is_instance_valid(_world):
		remove_child(_world)
		_world.queue_free()
	_world = Node2D.new()
	_world.name = "Lineup"
	add_child(_world)
	move_child(_world, 0)
	_rows.clear()
	var top := 0.0
	for s in BT.SCALES:
		var tallest: int = BT.geometry("hall", s)["canvas"].y
		var baseline := top + tallest + 40.0
		_rows.append(_row(float(s), baseline))
		top = baseline + ROW_GAP
	_all = _rows[0]
	for r in _rows:
		_all = _all.merge(r)
	_hud_text()


## One row at scale s, every class standing on `baseline`. Returns the row's bounds.
func _row(s: float, baseline: float) -> Rect2:
	var x := 0.0
	var title_at := Vector2(0, baseline - BT.geometry("hall", s)["canvas"].y - 30)
	for cls in BT.CLASSES:
		var g := BT.geometry(cls, s)
		var today := String(TODAY[cls])
		if today != "":
			x = _today(cls, today, x, baseline) + COL_GAP
		var holder := Node2D.new()
		var base: Vector2i = g["base"]
		holder.position = Vector2(x + BT.EAVE, baseline - base.y * T)
		_world.add_child(holder)
		var b := {"id": TEMPLATE[cls], "class": cls, "base": Rect2i(Vector2i.ZERO, base)}
		var node: Node2D = BT.place_scaled(b, holder, s)
		var size: Vector2i = g["canvas"]
		var door: Rect2i = g["door_px"]
		var mid := x + (float(door.get_center().x) if door.size.x > 0 else size.x / 2.0)
		var heights := _creatures(mid, baseline, door.size.x, String(g["pass_creature"]))
		var where := "template: %s" % (cls if cls != "hall" else "Wayline Tower")
		var line2 := "%dx%d" % [size.x, size.y]
		if door.size.x > 0:
			line2 += "\ndoor %dx%d, %s %dpx" % [door.size.x, door.size.y, g["pass_creature"], heights.get(String(g["pass_creature"]), 0)]
		if cls == "hall":
			line2 += "\n%.2f screens tall" % (size.y / 216.0)
			if is_equal_approx(s, BT.BUILDING_SCALE):
				_tower = {"door": Vector2(x, baseline - size.y) + Vector2(door.get_center()), "top": Vector2(x + BT.TOWER_TOP.x, baseline - size.y + BT._ty(BT.TOWER_TOP.y, size.y, s))}
		var src := ""
		if node != null and node.get_meta("slot", "") != "" and ArtSlots.has(String(node.get_meta("slot"))) and is_equal_approx(s, BT.BUILDING_SCALE):
			src = "\n%s: %s" % [node.get_meta("slot"), ArtSlots.source(String(node.get_meta("slot")))]
		_label(Vector2(x, baseline + 8), "%s\n%s%s" % [where, line2, src])
		x += size.x + COL_GAP
	var ground := ColorRect.new()
	ground.color = GROUND
	ground.position = Vector2(-COL_GAP, baseline)
	ground.size = Vector2(x + COL_GAP, 56)
	ground.z_index = -10
	_world.add_child(ground)
	_label(title_at, "BUILDING_SCALE %.2f%s" % [s, "  (the game's setting)" if is_equal_approx(s, BT.BUILDING_SCALE) else "  (Preston's call 1: walk it, then choose)"], 16)
	return Rect2(Vector2(-COL_GAP, title_at.y - 10), Vector2(x + COL_GAP, baseline + 70 - title_at.y + 10))


## Codex's current picture for a class at x, with the creatures at its door. Returns the x after it.
func _today(cls: String, id: String, x: float, baseline: float) -> float:
	var spec := ArtSlots.spec("town.building." + id)
	var path := String(spec.get("legacy_v1", ""))
	if path == "" or not ResourceLoader.exists(path):
		return x
	var tex: Texture2D = load(path)
	var sprite := Sprite2D.new()
	sprite.centered = false
	sprite.texture = tex
	sprite.position = Vector2(x, baseline - tex.get_height())
	_world.add_child(sprite)
	var place: Dictionary = {}
	for p in Layout.PLACES:
		if p["id"] == id:
			place = p
	var r: Rect2i = place["rect"]
	var tiles: Array = Layout.door_tiles(place)
	var first: Vector2i = tiles[0]
	for t in tiles:
		first.x = mini(first.x, t.x)
	var mid := x + (first.x - r.position.x) * T + tiles.size() * T / 2.0
	var g := BT.geometry(cls)
	var heights := _creatures(mid, baseline, tiles.size() * T - 4, String(g["pass_creature"]))
	_label(Vector2(x, baseline + 8), "today: Codex's %s\n%dx%d\n(v1, unchanged)" % [id, tex.get_width(), tex.get_height()])
	return x + tex.get_width()


## Stands the three creatures at a door whose middle is mid_x: the pass creature in the doorway, the other two either
## side. Returns each one's visible height.
func _creatures(mid_x: float, baseline: float, door_w: int, pass_form: String) -> Dictionary:
	var heights := {}
	var order: Array = CREATURES.duplicate()
	if pass_form in order:
		order.erase(pass_form)
		order.insert(1, pass_form)
	var shapes := {}
	for form in order:
		var path := "res://assets/sprites/arena/%s/town/s.png" % form
		if not ResourceLoader.exists(path):
			continue
		var tex: Texture2D = load(path)
		var used: Rect2i = tex.get_image().get_used_rect()
		shapes[form] = [tex, used]
		heights[form] = used.size.y
	if not shapes.has(String(order[1])):
		return heights
	var centre_w: int = shapes[order[1]][1].size.x
	var xs := {order[1]: mid_x}
	if shapes.has(String(order[0])):
		xs[order[0]] = mid_x - maxf(door_w / 2.0, centre_w / 2.0) - shapes[order[0]][1].size.x / 2.0 - 4
	if shapes.has(String(order[2])):
		xs[order[2]] = mid_x + maxf(door_w / 2.0, centre_w / 2.0) + shapes[order[2]][1].size.x / 2.0 + 4
	for form in xs:
		var tex: Texture2D = shapes[form][0]
		var used: Rect2i = shapes[form][1]
		var sprite := Sprite2D.new()
		sprite.centered = false
		sprite.texture = tex
		sprite.position = Vector2(round(float(xs[form]) - used.get_center().x), baseline - 2 - used.end.y)
		sprite.z_index = 2000
		CreatureFinish.apply(sprite)
		_world.add_child(sprite)
		var tag := "%d: %dpx" % [CREATURES.find(form) + 1, used.size.y]   # stage: visible height
		var k := CREATURES.find(form)
		_label(Vector2(float(xs[form]) - 16, baseline - 2 - used.size.y - 12 - 10 * (2 - k)), tag)   # stacked, so they never overlap
	return heights


func _label(at: Vector2, text: String, size := 8) -> void:
	var l := Label.new()
	l.text = text
	l.position = at
	l.z_index = 2100
	l.add_theme_font_size_override("font_size", size)
	if _font != null:
		l.add_theme_font_override("font", _font)
	l.add_theme_color_override("font_color", Color("#fff4e8"))
	l.add_theme_color_override("font_outline_color", Color("#0b0e11"))
	l.add_theme_constant_override("outline_size", 3)
	_world.add_child(l)


func _frame(r: Rect2) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	var view := get_viewport_rect().size
	var z := minf(view.x / maxf(1.0, r.size.x), view.y / maxf(1.0, r.size.y))
	_cam.zoom = Vector2.ONE * clampf(z, 0.05, 8.0)
	_cam.position = r.get_center()
	_hud_text()


## The pan a story scene at the Tower's foot would make: the town's 3x view on the door, then up to the beacon.
func _pan_tower() -> void:
	if _tower.is_empty():
		return
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_cam.zoom = Vector2.ONE * 3.0 * get_viewport_rect().size.y / 648.0
	_cam.position = _tower["door"]
	_tween = create_tween()
	_tween.tween_interval(0.6)
	_tween.tween_property(_cam, "position", _tower["top"] + Vector2(0, 40), 3.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _hud_text() -> void:
	if _hud == null:
		return
	_hud.text = "Building lineup: today's picture, then the template, stage 1-3 creatures at each door.  zoom %.2f%s\nArrows/WASD pan   wheel or +/- zoom   1 / 2 rows   0 all   T pan up the Tower   F placeholders %s" % [
		_cam.zoom.x if _cam != null else 1.0, "", "forced" if ArtSlots.forcing() else "off"]


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(1.15)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(1.0 / 1.15)
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.keycode:
		KEY_1:
			_frame(_rows[0])
		KEY_2:
			_frame(_rows[mini(1, _rows.size() - 1)])
		KEY_0:
			_frame(_all)
		KEY_T:
			_pan_tower()
		KEY_F:
			ArtSlots.set_forcing(not ArtSlots.force_toggle)
			_build()
		KEY_EQUAL, KEY_PLUS, KEY_KP_ADD:
			_zoom(1.25)
		KEY_MINUS, KEY_KP_SUBTRACT:
			_zoom(0.8)


func _zoom(k: float) -> void:
	_cam.zoom = (_cam.zoom * k).clamp(Vector2.ONE * 0.05, Vector2.ONE * 8.0)
	_hud_text()


func _process(delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		dir.x -= 1
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		dir.x += 1
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		dir.y -= 1
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		dir.y += 1
	if dir != Vector2.ZERO:
		if _tween != null and _tween.is_valid():
			_tween.kill()
		_cam.position += dir.normalized() * 420.0 * delta / _cam.zoom.x
