extends SceneTree
## Renders the art slot references a generator paints to, and exports the registry for the Python tools
## (Claude, 2026-10-26, placeholder factory contract; 03-spec-format.md sections 3.1 and 3.3).
##   godot --headless --path . --script res://tools/art/render_slot_refs.gd -- [--id <slot>] [--area <a>]
##       [--owner codex|grok|claude] [--all] [--out <folder>] [--export-only]
## Always writes docs/design/placeholder-factory-2026-10-26/slots.json: every slot's full spec, stamped with
## ArtSlots.registry_hash(), so prepare_slot.py, validate_slot.py and install_slot.py refuse a stale copy.
## Then, per chosen slot (default: the placeholder rows Codex and Grok paint; --all for every row), writes into the
## refs folder: <id>.png (the placeholder at its exact native size: the target), <id>_grid.png (enlarged, pixel and
## tile lines, the foot row, the door box, 9-slice margins, and the pass creature as a flat grey block), <id>_card.png
## (Grok's one image: a style sample of installed house art, the placeholder and the palette strip side by side) and
## <id>.json (its spec), plus palettes/<family>.png swatch strips. No text on any picture: Grok copies labels.
## Run one Godot at a time.

const DOC := "res://docs/design/placeholder-factory-2026-10-26/"
const STYLE := {
	"building": "res://assets/sprites/world/growth_shrine_2026_10_10/shrine_native.png",
	"landmark": "res://assets/sprites/world/growth_shrine_2026_10_10/shrine_native.png",
	"prop": "res://assets/sprites/world/storage_interior_2026_10_14/props/crates.png",
	"lamp": "res://assets/sprites/world/storage_interior_2026_10_14/props/lamp.png",
	"room": "res://assets/sprites/world/home_interior_2026_10_10/home_native.png",
	"ground": "res://assets/sprites/world/world_tiles_2026_10_10/grass_native.png",
	"backdrop": "res://assets/sprites/world/waking_bank_2026_10_10/waking_native.png",
	"hud_piece": "res://assets/sprites/ui/frame/panel.png",
	"hud_icon": "res://assets/sprites/ui/frame/panel.png",
	"frame9": "res://assets/sprites/ui/frame/panel.png",
	"effect": "res://assets/sprites/ui/frame/panel.png",
	"character": "res://assets/sprites/world/growth_shrine_2026_10_10/shrine_native.png",
}
const UI_FRAMES := ["res://assets/sprites/ui/frame/panel.png", "res://assets/sprites/ui/frame/nameplate.png",
	"res://assets/sprites/ui/frame/portrait.png", "res://assets/sprites/ui/frame/arrow.png"]
const BACK := Color("#3a3d40")      # behind transparent pixels in a grid image
const CARD_BACK := Color("#1c1f1c")
const FOOT := Color("#36d6e7")
const DOOR := Color("#ffd23f")
const MARGIN := Color("#ff9a3c")
const BLOCK := Color("#9a9a9a")      # the pass creature, as a flat block, never its art
const CARD_H := 192


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var opt := {"id": "", "area": "", "owner": "", "out": DOC + "refs/"}
	for k in ["id", "area", "owner", "out"]:
		var i := args.find("--" + k)
		if i >= 0 and i + 1 < args.size():
			opt[k] = args[i + 1]
	var every := args.has("--all")
	var out := ProjectSettings.globalize_path(String(opt["out"])).trim_suffix("/") + "/"
	var json_path := ProjectSettings.globalize_path(DOC + "slots.json")
	_export(json_path)
	if args.has("--export-only"):
		quit()
		return
	var chosen: PackedStringArray = []
	for id in ArtSlots.ids():
		var s := ArtSlots.spec(id)
		if opt["id"] != "":
			if id == opt["id"]:
				chosen.append(id)
			continue
		if opt["area"] != "" and not id.begins_with(String(opt["area"]) + "."):
			continue
		if opt["owner"] != "" and String(s["owner"]) != opt["owner"]:
			continue
		if not every and opt["owner"] == "" and (String(s["status"]) != "placeholder" or String(s["owner"]) == "claude"):
			continue
		if not every and opt["owner"] != "" and String(s["status"]) != "placeholder":
			continue
		chosen.append(id)
	if chosen.is_empty():
		print("render_slot_refs: no slot chosen")
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(out + "palettes")
	var families := {}
	for id in chosen:
		var s := ArtSlots.spec(id)
		var target := PlaceholderPainter.paint(id, s)
		target.save_png(out + id + ".png")
		_grid(target, s).save_png(out + id + "_grid.png")
		var fam := String(s["palette"].get("family", ""))
		var strip := _palette_strip(fam, s, families)
		_card(target, s, strip).save_png(out + id + "_card.png")
		var f := FileAccess.open(out + id + ".json", FileAccess.WRITE)
		f.store_string(JSON.stringify(_jsonable(s), "\t", true) + "\n")
		f.close()
	for fam in families:
		(families[fam] as Image).save_png(out + "palettes/" + String(fam) + ".png")
	print("render_slot_refs: %d slots, %d palettes into %s" % [chosen.size(), families.size(), out])
	quit()


## slots.json: the registry for Python, stamped with its hash.
func _export(path: String) -> void:
	var slots := {}
	for id in ArtSlots.ids():
		slots[id] = _jsonable(ArtSlots.spec(id))
	var doc := {"registry_sha256": ArtSlots.registry_hash(), "slot_files": Array(ArtSlots.slot_files()),
		"count": slots.size(), "slots": slots, "note": "Written by tools/art/render_slot_refs.gd; do not edit. Edit scripts/art/slots/*.gd and export again."}
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(doc, "\t", true) + "\n")
	f.close()
	print("render_slot_refs: slots.json %d slots, registry %s" % [slots.size(), String(doc["registry_sha256"]).substr(0, 12)])


func _grid(target: Image, s: Dictionary) -> Image:
	var w := target.get_width()
	var h := target.get_height()
	var k := 8 if maxi(w, h) <= 64 else (4 if maxi(w, h) <= 256 else 2)
	var creature := _creature_box(s)
	var gap := 4 * k if creature != Vector2i.ZERO else 0
	var out := Image.create(w * k + gap + creature.x * k, maxi(h, creature.y) * k, false, Image.FORMAT_RGBA8)
	out.fill(BACK)
	for y in h:
		for x in w:
			var c := target.get_pixel(x, y)
			if c.a > 0.0:
				out.fill_rect(Rect2i(x * k, y * k, k, k), Color(c, 1.0))
	if k >= 4:   # a faint line per pixel
		for x in w:
			_mix(out, Rect2i(x * k, 0, 1, h * k), Color.BLACK, 0.18)
		for y in h:
			_mix(out, Rect2i(0, y * k, w * k, 1), Color.BLACK, 0.18)
	var size: Vector2i = s["size"]
	for x in range(0, w + 1, 24):   # a strong line every tile
		_mix(out, Rect2i(mini(x * k, w * k - 1), 0, 1, h * k), Color.WHITE, 0.45)
	for y in range(0, h + 1, 24):
		_mix(out, Rect2i(0, mini(y * k, h * k - 1), w * k, 1), Color.WHITE, 0.45)
	for cx in range(size.x, w, size.x):   # cell borders of a sheet
		out.fill_rect(Rect2i(cx * k - 1, 0, 2, h * k), Color.WHITE)
	for cy in range(size.y, h, size.y):
		out.fill_rect(Rect2i(0, cy * k - 1, w * k, 2), Color.WHITE)
	var anchor: Vector2i = s.get("anchor", Vector2i.ZERO)
	if String(s.get("anchor_mode", "")) == "foot":
		for cy in range(0, h, size.y):
			out.fill_rect(Rect2i(0, (cy + anchor.y + 1) * k - 1, w * k, 1), FOOT)
	if s.has("door_px"):
		_box(out, Rect2i(s["door_px"].position * k, s["door_px"].size * k), DOOR)
	if s.has("margins"):
		var m: Array = s["margins"]
		_mix(out, Rect2i(int(m[0]) * k, 0, 1, h * k), MARGIN, 1.0)
		_mix(out, Rect2i((size.x - int(m[2])) * k, 0, 1, h * k), MARGIN, 1.0)
		_mix(out, Rect2i(0, int(m[1]) * k, w * k, 1), MARGIN, 1.0)
		_mix(out, Rect2i(0, (size.y - int(m[3])) * k, w * k, 1), MARGIN, 1.0)
	if creature != Vector2i.ZERO:
		var foot := (anchor.y + 1) if String(s.get("anchor_mode", "")) == "foot" else h
		var top := maxi(0, foot - creature.y)
		out.fill_rect(Rect2i(w * k + gap, top * k, creature.x * k, creature.y * k), BLOCK)
	return out


## The pass creature's content box from its town/s.png, read now, so a new creature set re-sizes the block.
func _creature_box(s: Dictionary) -> Vector2i:
	var form := String(s.get("pass_creature", ""))
	if form == "" and String(s["kind"]) in ["building", "room", "landmark"]:
		form = "sparkjab"   # a stage 2 for scale beside rooms and open-air places
	if form == "":
		return Vector2i.ZERO
	var path := "res://assets/sprites/arena/%s/town/s.png" % form
	if not FileAccess.file_exists(path):
		return Vector2i.ZERO
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	var r := img.get_used_rect()
	return r.size


func _card(target: Image, s: Dictionary, strip: Image) -> Image:
	var parts: Array[Image] = []
	var style_path := String(s.get("style_ref", STYLE.get(String(s["kind"]), "")))
	if style_path != "" and FileAccess.file_exists(style_path):
		parts.append(_fit(Image.load_from_file(ProjectSettings.globalize_path(style_path)), CARD_H))
	parts.append(_fit(target, CARD_H))
	if strip != null:
		parts.append(_fit(strip, CARD_H))
	var w := 8
	for p in parts:
		w += p.get_width() + 8
	var card := Image.create(w, CARD_H + 16, false, Image.FORMAT_RGBA8)
	card.fill(CARD_BACK)
	var x := 8
	for p in parts:
		card.blend_rect(p, Rect2i(Vector2i.ZERO, p.get_size()), Vector2i(x, 8 + (CARD_H - p.get_height()) / 2))
		x += p.get_width() + 8
	return card


## Nearest-neighbour scale to fit a height: a whole factor up, or straight down to it.
func _fit(img: Image, hgt: int) -> Image:
	var out := img.duplicate() as Image
	out.convert(Image.FORMAT_RGBA8)
	var f := float(hgt) / float(maxi(1, out.get_height()))
	if f >= 1.0:
		f = floorf(f)
	var w := maxi(1, int(round(out.get_width() * f)))
	var h := maxi(1, int(round(out.get_height() * f)))
	if w > 4 * hgt:   # a long strip (a wall or a river) keeps the card a sane width
		h = maxi(1, int(round(h * 4.0 * hgt / w)))
		w = 4 * hgt
	out.resize(w, h, Image.INTERPOLATE_NEAREST)
	return out


## One swatch strip per palette family (8 x 8 per colour), cut with a fixed median cut, no dithering, from the
## installed art and placeholders of that family. Built once per family per run.
func _palette_strip(fam: String, s: Dictionary, done: Dictionary) -> Image:
	if fam == "" or fam == "as_installed":
		return null
	if done.has(fam):
		return done[fam]
	var budget := 0
	var sources: Array[Image] = []
	for id in ArtSlots.ids():
		var o := ArtSlots.spec(id)
		if String(o["palette"].get("family", "")) != fam:
			continue
		budget = maxi(budget, int(o["palette"].get("max", 0)))
		sources.append(PlaceholderPainter.paint(id, o))
		for key in ["legacy", "legacy_v1"]:
			var p := String(o.get(key, ""))
			if p != "" and FileAccess.file_exists(p):
				sources.append(Image.load_from_file(ProjectSettings.globalize_path(p)))
	if fam.begins_with("room_"):   # a room's family also learns from the room's installed strips
		var room := fam.trim_prefix("room_")
		for id in ArtSlots.ids():
			var o := ArtSlots.spec(id)
			if id.contains("." + room + ".") and String(o["legacy"]) != "" and FileAccess.file_exists(String(o["legacy"])):
				sources.append(Image.load_from_file(ProjectSettings.globalize_path(String(o["legacy"]))))
	if fam == "brass_ui":
		for p in UI_FRAMES:
			if FileAccess.file_exists(p):
				sources.append(Image.load_from_file(ProjectSettings.globalize_path(p)))
	var cols := _median_cut(sources, maxi(1, budget))
	var strip := Image.create(8 * cols.size(), 8, false, Image.FORMAT_RGBA8)
	for i in cols.size():
		strip.fill_rect(Rect2i(i * 8, 0, 8, 8), cols[i])
	done[fam] = strip
	return strip


func _median_cut(sources: Array[Image], n: int) -> Array[Color]:
	var px: Array = []
	for img in sources:
		var im := img.duplicate() as Image
		im.convert(Image.FORMAT_RGBA8)
		var step := maxi(1, int(sqrt(float(im.get_width() * im.get_height()) / 4096.0)))
		for y in range(0, im.get_height(), step):
			for x in range(0, im.get_width(), step):
				var c := im.get_pixel(x, y)
				if c.a > 0.5:
					px.append([c.r8, c.g8, c.b8])
	var boxes: Array = [px]
	while boxes.size() < n:
		var best := -1
		var best_range := 0
		var best_ch := 0
		for i in boxes.size():
			var b: Array = boxes[i]
			if b.size() < 2:
				continue
			for ch in 3:
				var lo := 255
				var hi := 0
				for p in b:
					lo = mini(lo, p[ch])
					hi = maxi(hi, p[ch])
				if hi - lo > best_range:
					best_range = hi - lo
					best = i
					best_ch = ch
		if best < 0 or best_range == 0:
			break
		var box: Array = boxes[best]
		var ch2 := best_ch
		box.sort_custom(func(a: Array, b: Array) -> bool: return a[ch2] < b[ch2] or (a[ch2] == b[ch2] and a[0] + a[1] + a[2] < b[0] + b[1] + b[2]))
		var mid := box.size() / 2
		boxes[best] = box.slice(0, mid)
		boxes.append(box.slice(mid))
	var out: Array[Color] = []
	for b in boxes:
		if b.is_empty():
			continue
		var sum := [0, 0, 0]
		for p in b:
			for ch in 3:
				sum[ch] += p[ch]
		out.append(Color(float(sum[0] / b.size()) / 255.0, float(sum[1] / b.size()) / 255.0, float(sum[2] / b.size()) / 255.0))
	out.sort_custom(func(a: Color, b: Color) -> bool: return a.get_luminance() > b.get_luminance())
	return out


func _mix(img: Image, r: Rect2i, c: Color, k: float) -> void:
	var cut := r.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	for y in range(cut.position.y, cut.end.y):
		for x in range(cut.position.x, cut.end.x):
			img.set_pixel(x, y, img.get_pixel(x, y).lerp(c, k))


func _box(img: Image, r: Rect2i, c: Color) -> void:
	_mix(img, Rect2i(r.position.x, r.position.y, r.size.x, 2), c, 1.0)
	_mix(img, Rect2i(r.position.x, r.end.y - 2, r.size.x, 2), c, 1.0)
	_mix(img, Rect2i(r.position.x, r.position.y, 2, r.size.y), c, 1.0)
	_mix(img, Rect2i(r.end.x - 2, r.position.y, 2, r.size.y), c, 1.0)


static func _jsonable(v: Variant) -> Variant:
	if v is Vector2i:
		return [v.x, v.y]
	if v is Rect2i:
		return [v.position.x, v.position.y, v.size.x, v.size.y]
	if v is Color:
		return "#" + v.to_html(false)
	if v is Dictionary:
		var d := {}
		for k in v:
			d[String(k)] = _jsonable(v[k])
		return d
	if v is Array or v is PackedStringArray:
		var a := []
		for e in v:
			a.append(_jsonable(e))
		return a
	return v
