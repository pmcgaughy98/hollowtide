extends RefCounted
## One unchanged Storage panel and controls shared by the town fallback and painted interior.
## Claude, 2026-10-24 (pass 5, RM1 to RM4): at most ROWS rows show and the list scrolls with the cursor (PgUp and
## PgDn move a page), so the status line and the keys stay inside the frame at any bag size (LV-01); the rows keep
## the order they had when the panel opened and the cursor stays on its kind after a move, so emptying a kind from
## the bag no longer slides the next kind under the cursor (LV-02; the order is taken fresh on the next open); the
## fill is the pause menu's 9-slice made opaque, so nothing behind shows through (LV-03); and a move Storage refuses
## plays the denied sound, not the confirm tick (LV-30).
const Storage := preload("res://scripts/town/storage.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const SceneKit := preload("res://scripts/town/scene_kit.gd")
const ROWS := 7          # rows shown at once: the panel then ends at 64 + 134 + 7 x 40 = 478, well inside 648
const ROW_H := 40.0
## Since pass 7 (Claude, 2026-10-26, T5 / L7-22) the heading is the brass name tab over the frame, as on the Job Board,
## and the panel's lines move up 26 px into the line it left: the note at 46, the first row at TOP.
const TOP := 68.0
const GUTTER := 28.0     # right of the rows, where the scroll arrows sit
static var _solid: StyleBoxTexture = null


## [kind, in the bag, kept here], in the order the rows had when this panel opened (LV-02).
static func entries(host: Node) -> Array:
	var rows := Storage.rows(host._record())
	var panel: Dictionary = host.panel
	if String(panel.get("service", "")) != "storage":
		return rows
	if not panel.has("order"):
		panel["order"] = rows.map(func(r: Array) -> String: return String(r[0]))
	var order: Array = panel["order"]
	var by_kind := {}
	for r in rows:
		by_kind[String(r[0])] = r
	var out: Array = []
	for kind in order:
		if by_kind.has(kind):
			out.append(by_kind[kind])
			by_kind.erase(kind)
	for kind in by_kind:   # a kind that turns up while the panel is open goes last, and stays there
		order.append(kind)
		out.append(by_kind[kind])
	return out


static func store(host: Node, n: int) -> void:
	var rows := entries(host)
	if rows.is_empty():
		return
	var k: int = clampi(int(host.panel.get("sel", 0)), 0, rows.size() - 1)
	var kind := String(rows[k][0])
	var rec: Dictionary = host._record()
	var before := _held(rec, kind)
	host.panel["said"] = Storage.move(rec, kind, n)
	_select(host, kind)
	if _held(rec, kind) == before:   # Storage refused: nothing moved (LV-30)
		host.last_sfx = "denied"
		host._sfx("denied")
	else:
		host._ui_sfx("confirm")


static func select_row(host: Node, dy: int) -> void:
	var n := entries(host).size()
	if n > 0:
		host.panel["sel"] = posmod(int(host.panel.get("sel", 0)) + dy, n)
		_follow(host, n)
		host._ui_sfx("cursor")


## PgUp and PgDn: a page of rows at a time, stopping at either end.
static func page(host: Node, dir: int) -> void:
	var n := entries(host).size()
	if n == 0:
		return
	var was := int(host.panel.get("sel", 0))
	host.panel["sel"] = clampi(was + dir * ROWS, 0, n - 1)
	_follow(host, n)
	if int(host.panel["sel"]) != was:
		host._ui_sfx("cursor")


## What a kind has now, in the bag and kept: [bag, kept].
static func _held(rec: Dictionary, kind: String) -> Array:
	return [int(rec.get("bag", {}).get(kind, 0)), int(rec.get("stored", {}).get(kind, 0))]


## The cursor on `kind`'s row, wherever that row now is.
static func _select(host: Node, kind: String) -> void:
	var rows := entries(host)
	var at := -1
	for i in rows.size():
		if String(rows[i][0]) == kind:
			at = i
	host.panel["sel"] = at if at >= 0 else clampi(int(host.panel.get("sel", 0)), 0, maxi(0, rows.size() - 1))
	_follow(host, rows.size())


## The first row shown: kept where it was unless the cursor has left the window.
static func _top(host: Node, n: int) -> int:
	var sel := int(host.panel.get("sel", 0))
	var top := clampi(int(host.panel.get("top", 0)), 0, maxi(0, n - ROWS))
	if sel < top:
		top = sel
	elif sel >= top + ROWS:
		top = sel - ROWS + 1
	return clampi(top, 0, maxi(0, n - ROWS))


static func _follow(host: Node, n: int) -> void:
	host.panel["top"] = _top(host, n)


## The panel's 9-slice (UI.frame("panel"), as the pause menu draws it) with its woven fill made opaque: the frame's
## pixels are either clear (the corners), opaque (the brass) or 236 alpha (the weave). Made once.
static func _solid_frame() -> StyleBoxTexture:
	if _solid == null:
		var sb := UI.frame("panel").duplicate() as StyleBoxTexture
		var img := UI.res_image(UI.FRAME + "panel.png")
		if img != null:
			for y in img.get_height():
				for x in img.get_width():
					var c := img.get_pixel(x, y)
					if c.a > 0.5 and c.a < 1.0:
						c.a = 1.0
						img.set_pixel(x, y, c)
			sb.texture = ImageTexture.create_from_image(img)
		_solid = sb
	return _solid


static func draw(host: Node, h: CanvasItem) -> void:
	var rec: Dictionary = host._record()
	var rows := entries(host)
	var shown := clampi(rows.size(), 1, ROWS)
	var top := _top(host, rows.size())
	var box := Rect2(166, 64, 820, 134 + ROW_H * shown)
	h.draw_style_box(_solid_frame(), box)
	UI.nameplate(h, box.position + Vector2(28, -22), "Storage", 22)
	UI.text(h, box.position + Vector2(30, 46), "Kept between runs. Going down loses the bag, never this.", 16, UI.MUTED, 520)
	UI.text(h, box.position + Vector2(30, 46), "Bag %d / %d kinds" % [rec.get("bag", {}).size(), Storage.bag_kinds()], 16, UI.MUTED, box.size.x - 60, HORIZONTAL_ALIGNMENT_RIGHT)
	if rows.is_empty():
		UI.text(h, box.position + Vector2(30, TOP + 24), "Nothing in the bag, and nothing kept here yet.", 18, UI.TEXT, box.size.x - 60)
	for slot in mini(ROWS, rows.size() - top):
		var k := top + slot
		var row: Array = rows[k]
		var r := Rect2(box.position + Vector2(24, TOP + slot * ROW_H), Vector2(box.size.x - 48 - GUTTER, 36))
		var on: bool = k == int(host.panel.get("sel", 0))
		if on:
			h.draw_rect(r, UI.FOCUS)
			h.draw_rect(r, UI.EDGE_LIGHT, false, 2.0)
		var icon := UI.item_icon(String(row[0]))
		if icon != null:
			h.draw_texture(icon, r.position + Vector2(10, 4))
		UI.text(h, r.position + Vector2(52, 25), Storage.item_name(String(row[0])), 19, UI.EDGE_LIGHT if on else UI.TEXT, 380)
		UI.text(h, r.position + Vector2(460, 25), "bag x%d" % int(row[1]), 17, UI.TEXT if int(row[1]) > 0 else UI.MUTED, 150)
		UI.text(h, r.position + Vector2(620, 25), "kept x%d" % int(row[2]), 17, UI.TEXT if int(row[2]) > 0 else UI.MUTED, 120)
	# More rows above or below the window: the dialogue's "next" arrow in the gutter, turned up for above.
	var arrow: Texture2D = UI.icon("frame/arrow")
	if arrow != null and rows.size() > ROWS:
		var ax := roundf(box.end.x - 24.0 - (GUTTER + arrow.get_width()) * 0.5)
		if top > 0:
			h.draw_set_transform(Vector2(ax, box.position.y + TOP + 18 + arrow.get_height() * 0.5), 0.0, Vector2(1, -1))
			h.draw_texture(arrow, Vector2.ZERO)
			h.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		if top + ROWS < rows.size():
			h.draw_texture(arrow, Vector2(ax, box.position.y + TOP + (ROWS - 1) * ROW_H + 18 - arrow.get_height() * 0.5))
	if String(host.panel.get("said", "")) != "":
		UI.text(h, box.end + Vector2(-box.size.x + 30, -44), String(host.panel["said"]), 16, UI.EDGE_LIGHT, box.size.x - 60)
	# Key hints in the column style, key then action (Claude, 2026-10-22, W12); the device's keys since 2026-10-23
	# ("W/S  choose     E  put one in     R  take one out     Esc  close" on a keyboard).
	var keys := "%s  choose     %s  put one in     %s  take one out     %s  close" % [SceneKit.pick_keys(), SceneKit.use_key(), UI.binding_text(&"take_out"), UI.binding_text(&"cancel")]
	UI.text(h, box.end + Vector2(-box.size.x + 30, -20), keys, 15, UI.MUTED, box.size.x - 60, HORIZONTAL_ALIGNMENT_RIGHT)
