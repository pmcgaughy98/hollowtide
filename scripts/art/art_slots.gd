class_name ArtSlots
extends RefCounted
## The art slot loader (Claude, 2026-10-26, placeholder factory contract; Preston: "placeholder art everywhere except
## creatures", Codex and Grok paint the real art from task lists). Every non-creature picture is a named slot with an
## exact size. A painter asks for `ArtSlots.texture("town.building.home")` instead of holding a path, and gets:
##   1. the coded placeholder, if forcing() is on (HT_FORCE_PLACEHOLDERS=1, --force-placeholders, or the debug toggle);
##   2. the slot's own file under res://assets/slots/<area>/<kind>/, if it is exactly sheet_size;
##   3. the legacy file (today's finished art), if it is its declared size;
##   4. the coded placeholder (PlaceholderPainter).
## A file at the wrong size prints one warning and falls through, so nothing draws at the wrong size and nothing is
## ever painted over real art. Rows live in scripts/art/slots/*.gd (one `const SLOTS` each); this file finds every
## .gd there by itself, so a lane adds a slot file without touching this one. The spec format is
## docs/design/placeholder-factory-2026-10-26/03-spec-format.md section 2; the build plan is 00-BUILD-PLAN.md section 1.
## This file is the frozen contract: lanes call it, they do not edit it.

const SLOT_DIR := "res://scripts/art/slots/"
const ASSET_DIR := "res://assets/slots/"
const PALETTE_DIR := "res://assets/slots/palettes/"
const OWNERS := ["codex", "grok", "claude"]
const STATUSES := ["placeholder", "keep", "candidate", "approved", "installed"]
const FORBID := ["text", "creature", "franchise"]
## Kinds and their defaults (03 section 2.2, plus "landmark": an open-air place canvas such as the Shrine or the Dock,
## which has no door and may fill its rect). A row only writes a field when it differs from its kind.
const KINDS := {
	"building": {"max": 32, "alpha": "binary", "edges": "bottom", "outline": "runtime_rim", "tiling": "none", "drawn_at": 3},
	"landmark": {"max": 32, "alpha": "binary", "edges": "all", "outline": "runtime_rim", "tiling": "none", "drawn_at": 3},
	"room": {"max": 48, "alpha": "opaque", "edges": "all", "outline": "none", "tiling": "none", "drawn_at": 3},
	"ground": {"max": 24, "alpha": "opaque", "edges": "all", "outline": "none", "tiling": "hv", "drawn_at": 3},
	"backdrop": {"max": 48, "alpha": "opaque", "edges": "all", "outline": "none", "tiling": "none", "drawn_at": 3},
	"prop": {"max": 24, "alpha": "binary", "edges": "bottom", "outline": "drawn", "tiling": "none", "drawn_at": 3},
	"lamp": {"max": 24, "alpha": "binary", "edges": "bottom", "outline": "drawn", "tiling": "none", "drawn_at": 3},
	"character": {"max": 24, "alpha": "binary", "edges": "none", "outline": "drawn", "tiling": "none", "drawn_at": 3},
	"hud_piece": {"max": 16, "alpha": "binary", "edges": "none", "outline": "drawn", "tiling": "none", "drawn_at": 3},
	"hud_icon": {"max": 8, "alpha": "binary", "edges": "none", "outline": "drawn", "tiling": "none", "drawn_at": 2},
	"frame9": {"max": 16, "alpha": "binary", "edges": "all", "outline": "drawn", "tiling": "none", "drawn_at": 1},
	"effect": {"max": 12, "alpha": "binary", "edges": "none", "outline": "none", "tiling": "none", "drawn_at": 3},
}
## The scripted checks of 03 section 2.3 each kind gets by default (C6 is added for a tiling slot, C10 and C11 for a
## slot with a door). validate_slot.py runs them; art_slots_check runs C1, C3 and C4 on every placeholder.
const CHECKS := {
	"building": ["C1", "C2", "C3", "C4", "C5", "C7", "C8", "C9", "C12"],
	"landmark": ["C1", "C2", "C3", "C4", "C5", "C9", "C12"],
	"room": ["C1", "C2", "C3", "C4", "C5", "C9"],
	"ground": ["C1", "C2", "C3", "C5", "C9"],
	"backdrop": ["C1", "C2", "C3", "C5", "C9"],
	"prop": ["C1", "C2", "C3", "C4", "C5", "C7", "C8", "C9", "C12"],
	"lamp": ["C1", "C2", "C3", "C4", "C5", "C7", "C8", "C9", "C12"],
	"character": ["C1", "C2", "C3", "C4", "C5", "C7", "C8", "C9"],
	"hud_piece": ["C1", "C2", "C3", "C4", "C5", "C8", "C9"],
	"hud_icon": ["C1", "C2", "C3", "C4", "C5", "C9"],
	"frame9": ["C1", "C2", "C3", "C5", "C13"],
	"effect": ["C1", "C2", "C3", "C4", "C8"],
}

static var force_toggle := false     # the debug toggle (a key in a debug scene flips it through set_forcing)
static var _rows := {}               # id -> the row exactly as its slot file holds it
static var _origin := {}             # id -> the slot file it came from ("town_rooms")
static var _files: PackedStringArray = []
static var _dupes: PackedStringArray = []
static var _loaded := false
static var _tex := {}                # id -> Texture2D, for the session
static var _src := {}                # id -> "file", "legacy" or "placeholder"
static var _img := {}                # id -> Image (painted placeholders, and images asked for by image())
static var _frames := {}             # "id|state|i" -> AtlasTexture
static var _warned := {}             # id -> true once its wrong-size warning has printed


## The slot files found in SLOT_DIR, sorted ("dungeon.gd", "title.gd", ...). An exported game lists a script as
## "x.gd.remap" or "x.gdc"; both count as "x.gd".
static func slot_files() -> PackedStringArray:
	var out: PackedStringArray = []
	for f in DirAccess.get_files_at(SLOT_DIR):
		var n := f.trim_suffix(".remap")
		if n.ends_with(".gdc"):
			n = n.trim_suffix(".gdc") + ".gd"
		if n.ends_with(".gd") and not out.has(n):
			out.append(n)
	out.sort()
	return out


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	_files = slot_files()
	for f in _files:
		var script: Script = load(SLOT_DIR + f)
		if script == null:
			push_warning("ArtSlots: %s did not load" % f)
			continue
		var rows: Dictionary = script.get_script_constant_map().get("SLOTS", {})
		for id in rows:
			if _rows.has(id):
				_dupes.append("%s (%s and %s)" % [id, _origin[id], f.get_basename()])
				push_warning("ArtSlots: %s is in both %s and %s; the first wins" % [id, _origin[id], f.get_basename()])
				continue
			_rows[id] = rows[id]
			_origin[id] = f.get_basename()


## Drops every cached texture and image (after a file is installed, or the forcing toggle flips). Rows stay loaded.
static func clear_cache() -> void:
	_tex.clear()
	_src.clear()
	_img.clear()
	_frames.clear()


static func has(id: String) -> bool:
	_load()
	return _rows.has(id)


## Ids listed twice across slot files (the first one wins); art_slots_check fails on any.
static func duplicates() -> PackedStringArray:
	_load()
	return _dupes


## The full spec of a slot: its kind's defaults, then its own row, then the derived fields (id, area, slot_file,
## sheet_size, frames, rows, palette source, checks). A copy, so a caller cannot change the registry.
static func spec(id: String) -> Dictionary:
	_load()
	if not _rows.has(id):
		return {}
	var row: Dictionary = _rows[id]
	var kind := String(row.get("kind", ""))
	var s := {"id": id, "area": id.get_slice(".", 0), "slot_file": _origin[id], "light": "upper_left",
		"legacy": "", "placeholder": "", "anchor_mode": "top_left", "forbid": FORBID.duplicate()}
	var defaults: Dictionary = KINDS.get(kind, {})
	for k in defaults:
		if k != "max":
			s[k] = defaults[k]
	for k in row:
		s[k] = row[k].duplicate(true) if row[k] is Dictionary or row[k] is Array else row[k]
	for f in FORBID:
		if not (s["forbid"] as Array).has(f):
			(s["forbid"] as Array).append(f)
	var pal: Dictionary = s.get("palette", {})
	if not pal.has("max"):
		pal["max"] = defaults.get("max", 0)
	if not pal.has("lock"):
		pal["lock"] = false
	var fam := String(pal.get("family", ""))
	pal["source"] = "" if fam in ["", "as_installed"] else PALETTE_DIR + fam + ".png"
	s["palette"] = pal
	var states: Dictionary = s.get("states", {"static": [1, 0]})
	s["states"] = states
	var most := 1
	for st in states:
		most = maxi(most, int(states[st][0]))
	s["frames"] = most
	s["rows"] = maxi(1, states.size())
	var size: Vector2i = s.get("size", Vector2i.ZERO)
	s["sheet_size"] = Vector2i(size.x * most, size.y * maxi(1, states.size()))
	if not row.has("checks"):
		var checks: Array = CHECKS.get(kind, ["C1"]).duplicate()
		if String(s.get("tiling", "none")) in ["h", "v", "hv"] and not checks.has("C6"):
			checks.append("C6")
		if s.has("door_px"):
			checks.append("C10")
			if s.has("pass_creature"):
				checks.append("C11")
		checks.sort()
		s["checks"] = checks
	return s


## Slot ids, sorted; owner ("codex", "grok", "claude") and status ("placeholder", "keep", "installed" ...) filter
## when given.
static func ids(owner := "", status := "") -> PackedStringArray:
	_load()
	var out: PackedStringArray = []
	for id in _rows:
		var r: Dictionary = _rows[id]
		if owner != "" and String(r.get("owner", "")) != owner:
			continue
		if status != "" and String(r.get("status", "")) != status:
			continue
		out.append(id)
	out.sort()
	return out


## The whole sheet: one cell wide per frame of its longest state, one cell tall per state.
static func sheet_size(id: String) -> Vector2i:
	var s := spec(id)
	return s.get("sheet_size", Vector2i.ZERO)


## True when every slot should show its placeholder: HT_FORCE_PLACEHOLDERS=1, the --force-placeholders flag, or the
## debug toggle.
static func forcing() -> bool:
	if force_toggle:
		return true
	if OS.get_environment("HT_FORCE_PLACEHOLDERS") == "1":
		return true
	return OS.get_cmdline_args().has("--force-placeholders") or OS.get_cmdline_user_args().has("--force-placeholders")


## Flips the debug toggle and drops the cache, so the next texture() call reflects it.
static func set_forcing(on: bool) -> void:
	force_toggle = on
	clear_cache()


## The texture a painter draws: see the order at the top of this file. Cached for the session.
static func texture(id: String) -> Texture2D:
	if _tex.has(id):
		return _tex[id]
	var s := spec(id)
	if s.is_empty():
		push_error("ArtSlots: no slot named %s" % id)
		return ImageTexture.create_from_image(Image.create(1, 1, false, Image.FORMAT_RGBA8))
	var want: Vector2i = s["sheet_size"]
	var tex: Texture2D = null
	var src := "placeholder"
	if not forcing():
		tex = _load_sized(id, String(s.get("file", "")), want, false)
		if tex != null:
			src = "file"
		elif String(s["legacy"]) != "":
			tex = _load_sized(id, String(s["legacy"]), want, bool(s.get("legacy_misfit", false)))
			if tex != null:
				src = "legacy"
	if tex == null:
		var img := _painted(id, s)
		tex = ImageTexture.create_from_image(img)
	_tex[id] = tex
	_src[id] = src
	return tex


## Where texture(id) came from: "file" (an installed slot file), "legacy" (today's finished art) or "placeholder".
static func source(id: String) -> String:
	if not _src.has(id):
		texture(id)
	return String(_src.get(id, "placeholder"))


## The slot's picture as an Image (the placeholder, or the file read from disk), for painters that compose images.
static func image(id: String) -> Image:
	if _img.has(id):
		return _img[id]
	var tex := texture(id)
	var img: Image = null
	match String(_src.get(id, "placeholder")):
		"file":
			img = _read_image(String(spec(id).get("file", "")), tex)
		"legacy":
			img = _read_image(String(spec(id).get("legacy", "")), tex)
	if img == null:
		img = _painted(id, spec(id))
	if img.get_format() != Image.FORMAT_RGBA8:
		img = img.duplicate()
		img.convert(Image.FORMAT_RGBA8)
	_img[id] = img
	return img


## One cell of the sheet: `state` picks the row (the first state when ""), `i` the frame (wraps).
static func frame(id: String, state := "", i := 0) -> Texture2D:
	var key := "%s|%s|%d" % [id, state, i]
	if _frames.has(key):
		return _frames[key]
	var s := spec(id)
	var tex := texture(id)
	if s.is_empty():
		return tex
	var states: Dictionary = s["states"]
	var names := states.keys()
	var row := maxi(0, names.find(state)) if state != "" else 0
	var count := maxi(1, int(states[names[row]][0]))
	var size: Vector2i = s["size"]
	var at := AtlasTexture.new()
	at.atlas = tex
	at.region = Rect2(Vector2((i % count) * size.x, row * size.y), Vector2(size))
	_frames[key] = at
	return at


## SHA-256 of the registry: this file and every slot file, in name order, line ends read as LF, so a Windows and a
## Linux checkout agree. tools/art/*.py compute the same and refuse a slots.json whose stamp differs.
static func registry_hash() -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	var paths: PackedStringArray = ["res://scripts/art/art_slots.gd"]
	for f in slot_files():
		paths.append(SLOT_DIR + f)
	for p in paths:
		ctx.update((p.get_file() + "\n").to_utf8_buffer())
		ctx.update(FileAccess.get_file_as_string(p).replace("\r\n", "\n").to_utf8_buffer())
	return ctx.finish().hex_encode()


## Loads a file only at the wanted size. A wrong size warns once per slot (not for a legacy_misfit legacy) and
## returns null so texture() falls through.
static func _load_sized(id: String, path: String, want: Vector2i, misfit_ok: bool) -> Texture2D:
	if path == "":
		return null
	var tex: Texture2D = null
	if FileAccess.file_exists(path + ".import") and ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	elif FileAccess.file_exists(path):
		# Dropped in but not imported yet (install_slot.py imports after copying): read the PNG itself.
		var img := Image.load_from_file(ProjectSettings.globalize_path(path))
		if img != null and not img.is_empty():
			tex = ImageTexture.create_from_image(img)
	if tex == null:
		return null
	var got := Vector2i(tex.get_size())
	if got != want:
		if not misfit_ok and not _warned.has(id):
			_warned[id] = true
			push_warning("ArtSlots: %s is %dx%d, slot %s wants %dx%d; using the next source" % [path, got.x, got.y, id, want.x, want.y])
		return null
	return tex


static func _read_image(path: String, tex: Texture2D) -> Image:
	if path != "" and FileAccess.file_exists(path):
		var img := Image.load_from_file(ProjectSettings.globalize_path(path))
		if img != null and not img.is_empty():
			return img
	return tex.get_image() if tex != null else null   # an exported game has only the imported texture


static func _painted(id: String, s: Dictionary) -> Image:
	if _img.has(id) and String(_src.get(id, "placeholder")) == "placeholder":
		return _img[id]
	var img: Image = PlaceholderPainter.paint(id, s)
	if String(_src.get(id, "placeholder")) == "placeholder":
		_img[id] = img
	return img
