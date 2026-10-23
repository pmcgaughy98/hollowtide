extends RefCounted
## One unchanged Storage panel and controls shared by the town fallback and painted interior.
const Storage := preload("res://scripts/town/storage.gd")
const UI := preload("res://scripts/ui/ui_style.gd")

static func entries(host: Node) -> Array:
	return Storage.rows(host._record())

static func store(host: Node, n: int) -> void:
	var rows := entries(host)
	if rows.is_empty():
		return
	var k: int = clampi(int(host.panel.get("sel", 0)), 0, rows.size() - 1)
	host.panel["said"] = Storage.move(host._record(), String(rows[k][0]), n)
	host.panel["sel"] = clampi(k, 0, maxi(0, entries(host).size() - 1))
	host._ui_sfx("confirm")

static func select_row(host: Node, dy: int) -> void:
	var n := entries(host).size()
	if n > 0:
		host.panel["sel"] = posmod(int(host.panel.get("sel", 0)) + dy, n)
		host._ui_sfx("cursor")

static func draw(host: Node, h: CanvasItem) -> void:
	var rec: Dictionary = host._record()
	var rows := entries(host)
	var box := Rect2(166, 64, 820, 160 + 40 * maxi(1, rows.size()))
	UI.panel(h, box, 0.95)
	UI.text(h, box.position + Vector2(30, 40), "Storage", 26, UI.EDGE_LIGHT)
	UI.text(h, box.position + Vector2(30, 72), "Kept between runs. Going down loses the bag, never this.", 16, UI.MUTED, 520)
	UI.text(h, box.position + Vector2(30, 72), "Bag %d / %d kinds" % [rec.get("bag", {}).size(), Storage.bag_kinds()], 16, UI.MUTED, box.size.x - 60, HORIZONTAL_ALIGNMENT_RIGHT)
	if rows.is_empty():
		UI.text(h, box.position + Vector2(30, 118), "Nothing in the bag, and nothing kept here yet.", 18, UI.TEXT, box.size.x - 60)
	for k in rows.size():
		var row: Array = rows[k]
		var r := Rect2(box.position + Vector2(24, 94 + k * 40), Vector2(box.size.x - 48, 36))
		var on: bool = k == int(host.panel.get("sel", 0))
		if on:
			h.draw_rect(r, UI.FOCUS)
			h.draw_rect(r, UI.EDGE_LIGHT, false, 2.0)
		var icon := UI.item_icon(String(row[0]))
		if icon != null:
			h.draw_texture(icon, r.position + Vector2(10, 4))
		UI.text(h, r.position + Vector2(52, 25), Storage.item_name(String(row[0])), 19, UI.EDGE_LIGHT if on else UI.TEXT, 380)
		UI.text(h, r.position + Vector2(460, 25), "bag x%d" % int(row[1]), 17, UI.TEXT if int(row[1]) > 0 else UI.MUTED, 150)
		UI.text(h, r.position + Vector2(620, 25), "kept x%d" % int(row[2]), 17, UI.TEXT if int(row[2]) > 0 else UI.MUTED, 150)
	if String(host.panel.get("said", "")) != "":
		UI.text(h, box.end + Vector2(-box.size.x + 30, -44), String(host.panel["said"]), 16, UI.EDGE_LIGHT, box.size.x - 60)
	# Key hints in the column style, key then action (Claude, 2026-10-22, W12).
	UI.text(h, box.end + Vector2(-box.size.x + 30, -20), "W/S  choose     E  put one in     R  take one out     Esc  close", 15, UI.MUTED, box.size.x - 60, HORIZONTAL_ALIGNMENT_RIGHT)

