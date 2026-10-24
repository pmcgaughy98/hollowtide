extends SceneTree
## The small faces' crops (Claude, 2026-10-23, factory pass 3: U8 for LO-07). UI.portrait_3x(form) cuts a 24 x 24
## square from a creature's 40 x 40 dialogue face, centred on its FACE_AT row, for the team row, the pause menu's
## team page and the party cards. This checks, for every creature with a dialogue face (the roster's lines, the
## Hollow's extras and the town's faces):
##   1. it has a FACE_AT row, and every FACE_AT row names a face that exists,
##   2. its cut stays inside the face without being pushed back in at an edge,
##   3. the cut sits on the creature: at least MIN_COVER of its pixels are drawn, not background,
##   4. portrait_3x gives a 48 x 48 picture.
## Roster forms with no dialogue face yet use their portrait.png instead; they are listed, not judged.
## Headless, a second or two:
##   Godot --headless --path . --script res://tools/debug/face_crop_check.gd
## With --sheet it also writes a contact sheet: each face at 3x with its cut outlined, and the cut as the game
## shows it, seven to a row in alphabetical order (the order is printed):
##   Godot --headless --path . --script res://tools/debug/face_crop_check.gd -- --sheet=C:/some/folder/faces.png

const UI := preload("res://scripts/ui/ui_style.gd")
const Arena := preload("res://scripts/arena/arena_prototype.gd")
const Lines := preload("res://scripts/creatures/lines.gd")
const FACES := "res://assets/sprites/ui/dialogue/"
const SPAN := 24
const MIN_COVER := 0.45   # a slender head is half background (Stillwade's heron head and beak: 50%); an empty corner is far less

var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(cond: bool, what: String) -> void:
	print(("ok    " if cond else "FAIL  ") + what)
	if not cond:
		fails += 1


## The creatures with a dialogue face (a file without a face name after an underscore), sorted.
func _faces() -> Array:
	var out := []
	for f in DirAccess.get_files_at(FACES):
		if f.ends_with(".png") and not "_" in f:
			out.append(f.get_basename())
	out.sort()
	return out


func _roster() -> Array:
	var out := []
	for i in Arena.LINES.size():
		for f in Arena.LINES[i]["forms"]:
			if not out.has(f[0]):
				out.append(f[0])
	for k in Lines.EXTRA:
		for f in Lines.EXTRA[k]["forms"]:
			if not out.has(f[0]):
				out.append(f[0])
	return out


func _image(tex: Texture2D) -> Image:
	var img: Image = tex.get_image() if tex != null else null
	if img == null or img.is_empty():
		return null
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	return img


func _run() -> void:
	var faces := _faces()
	var roster := _roster()
	var no_face := roster.filter(func(f: String) -> bool: return not faces.has(f))
	var forms: Array = faces.duplicate()
	print("%d dialogue faces; %d roster forms, %d without a dialogue face yet (they use portrait.png): %s" % [faces.size(), roster.size(), no_face.size(), ", ".join(no_face)])
	var no_row := faces.filter(func(f: String) -> bool: return not UI.FACE_AT.has(f))
	_ok(no_row.is_empty() and faces.size() > 0, "every creature with a dialogue face has a FACE_AT row (%d)%s" % [faces.size(), "" if no_row.is_empty() else "; missing: " + ", ".join(no_row)])
	var stale := UI.FACE_AT.keys().filter(func(f: String) -> bool: return not faces.has(f))
	_ok(stale.is_empty(), "every FACE_AT row names a face that exists%s" % ("" if stale.is_empty() else "; no face for: " + ", ".join(stale)))
	var outside := PackedStringArray()
	var thin := PackedStringArray()
	var wrong := PackedStringArray()
	var least := 1.0
	var least_form := ""
	for f: String in forms:
		var img := _image(UI.dialogue_portrait(f))
		if img == null:
			wrong.append(f + " (no image)")
			continue
		var mid: Vector2i = UI.FACE_AT.get(f, Vector2i(20, 18))
		var cut := Rect2i(mid - Vector2i(SPAN / 2, SPAN / 2), Vector2i(SPAN, SPAN))
		if not Rect2i(Vector2i.ZERO, img.get_size()).encloses(cut):
			outside.append("%s %s in %dx%d" % [f, cut, img.get_width(), img.get_height()])
			continue
		var drawn := 0
		for y in range(cut.position.y, cut.end.y):
			for x in range(cut.position.x, cut.end.x):
				if img.get_pixel(x, y).a > 0.5:
					drawn += 1
		var cover := drawn / float(SPAN * SPAN)
		if cover < least:
			least = cover
			least_form = f
		if cover < MIN_COVER:
			thin.append("%s %.0f%%" % [f, cover * 100.0])
		var small := _image(UI.portrait_3x(f, SPAN))
		if small == null or small.get_size() != Vector2i(48, 48):
			wrong.append("%s (%s)" % [f, "none" if small == null else str(small.get_size())])
	_ok(outside.is_empty(), "every cut stays inside its face (%d)%s" % [forms.size(), "" if outside.is_empty() else "; outside: " + ", ".join(outside)])
	_ok(thin.is_empty(), "every cut sits on the creature, at least %.0f%% drawn (the least: %s, %.0f%%)%s" % [MIN_COVER * 100.0, least_form, least * 100.0, "" if thin.is_empty() else "; thin: " + ", ".join(thin)])
	_ok(wrong.is_empty(), "portrait_3x gives every face a 48 x 48 picture%s" % ("" if wrong.is_empty() else "; not so: " + ", ".join(wrong)))
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--sheet="):
			_sheet(forms, a.trim_prefix("--sheet="))
	print("face crops: %s (%d failed)" % ["all ok" if fails == 0 else "FAILED", fails])
	quit(1 if fails > 0 else 0)


## The contact sheet for a person to look at: per face, the 40 x 40 face at 3x on the portrait blue with its cut
## outlined in red, then the cut at 2x as portrait_3x makes it.
func _sheet(forms: Array, path: String) -> void:
	var cols := 7
	var cw := 240
	var ch := 136
	var sheet := Image.create(cols * cw + 8, ceili(forms.size() / float(cols)) * ch + 8, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#1d2420"))
	for i in forms.size():
		var f: String = forms[i]
		var at := Vector2i(8 + (i % cols) * cw, 8 + (i / cols) * ch)
		var src := _image(UI.dialogue_portrait(f))
		if src == null:
			continue
		var big := Image.create(src.get_width(), src.get_height(), false, Image.FORMAT_RGBA8)
		big.fill(UI.PORTRAIT_BG)
		big.blend_rect(src, Rect2i(Vector2i.ZERO, src.get_size()), Vector2i.ZERO)
		big.resize(src.get_width() * 3, src.get_height() * 3, Image.INTERPOLATE_NEAREST)
		var mid: Vector2i = UI.FACE_AT.get(f, Vector2i(20, 18))
		var r := Rect2i((mid - Vector2i(SPAN / 2, SPAN / 2)) * 3, Vector2i(SPAN * 3, SPAN * 3))
		for t in 2:
			big.fill_rect(Rect2i(r.position.x, r.position.y + t, r.size.x, 1), Color(1, 0.2, 0.2))
			big.fill_rect(Rect2i(r.position.x, r.end.y - 1 - t, r.size.x, 1), Color(1, 0.2, 0.2))
			big.fill_rect(Rect2i(r.position.x + t, r.position.y, 1, r.size.y), Color(1, 0.2, 0.2))
			big.fill_rect(Rect2i(r.end.x - 1 - t, r.position.y, 1, r.size.y), Color(1, 0.2, 0.2))
		sheet.blit_rect(big, Rect2i(Vector2i.ZERO, big.get_size()), at)
		var small := _image(UI.portrait_3x(f, SPAN))
		if small != null:
			var box := Image.create(small.get_width(), small.get_height(), false, Image.FORMAT_RGBA8)
			box.fill(UI.PORTRAIT_BG)
			box.blend_rect(small, Rect2i(Vector2i.ZERO, small.get_size()), Vector2i.ZERO)
			box.resize(96, 96, Image.INTERPOLATE_NEAREST)
			sheet.blit_rect(box, Rect2i(Vector2i.ZERO, box.get_size()), at + Vector2i(128, 12))
	var err := sheet.save_png(path)
	print("contact sheet: %s (%s), in order: %s" % [path, error_string(err), ", ".join(forms)])
