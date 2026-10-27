extends SceneTree
## The art slot registry's check (Claude, 2026-10-26, placeholder factory contract; build plan section 5, 03-spec-format
## section 3.5). Every slot: a unique well-formed id, a known owner and kind, a complete spec (anchor in the cell, door
## box in the wall), doors that clear the pass creature measured from its town/s.png now (C11), the placeholder within
## its colour budget, exactly sheet_size, binary or opaque alpha and clear of forbidden edges (C1, C3, C4), its own
## file under res://assets/slots/, legacy art present at its size, installed hashes matching, nothing in a creature
## folder, and a texture of the declared size whatever the source. Prints "installed X of Y" by area and owner, and the
## hard-coded art paths still written into scripts/.
##   Godot --headless --fixed-fps 30 --path . --script res://tools/debug/art_slots_check.gd
##   HT_FORCE_PLACEHOLDERS=1 ... runs it with every slot forced to its placeholder.

const Layout := preload("res://scripts/town/town_layout.gd")
const SPEC_FIELDS := ["owner", "kind", "status", "file", "size", "drawn_at", "anchor", "states", "palette", "light",
	"outline", "edges", "alpha", "tiling", "brief", "forbid"]
const CREATURE_ROOTS := ["res://assets/sprites/arena/", "res://assets/sprites/creatures/", "res://assets/creatures/"]
const CLAUDE_FRAMES := "res://assets/sprites/ui/frame/"   # Claude's coded 9-slices keep their kit folder
const INSTALLED := "res://docs/design/placeholder-factory-2026-10-26/installed.json"
const SLOTS_JSON := "res://docs/design/placeholder-factory-2026-10-26/slots.json"
const ART_PATH := "res://assets/sprites/(?:world|ui|menu|player|effects)[^\"'\\s)]*"

var fails := 0


func _ok(what: String, good: bool, offenders: Array = []) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1
		for o in offenders.slice(0, 12):
			print("    %s" % str(o))
		if offenders.size() > 12:
			print("    ... and %d more" % (offenders.size() - 12))


func _initialize() -> void:
	var t0 := Time.get_ticks_msec()
	var ids := ArtSlots.ids()
	var forced := ArtSlots.forcing()
	print("art slots: %d in %d files %s%s" % [ids.size(), ArtSlots.slot_files().size(), str(ArtSlots.slot_files()), " (forcing placeholders)" if forced else ""])
	var id_re := RegEx.create_from_string("^[a-z0-9_]+\\.[a-z0-9_]+\\.[a-z0-9_]+(\\.[a-z0-9_]+)*$")
	var installed := _installed()
	var bad_id: Array = []
	var bad_known: Array = []
	var bad_spec: Array = []
	var bad_door: Array = []
	var bad_template: Array = []
	var bad_budget: Array = []
	var bad_forbid: Array = []
	var bad_ph: Array = []
	var bad_file: Array = []
	var bad_legacy: Array = []
	var bad_hash: Array = []
	var bad_creature: Array = []
	var bad_tex: Array = []
	var bad_source: Array = []
	var files := {}
	var by_src := {}
	var area_tot := {}
	var area_inst := {}
	var owner_tot := {}
	var owner_inst := {}
	var lanes := {}
	var creature_cache := {}
	for id in ids:
		var s := ArtSlots.spec(id)
		var kind := String(s.get("kind", ""))
		var size: Vector2i = s.get("size", Vector2i.ZERO)
		var sheet: Vector2i = s["sheet_size"]
		# Ids, owners and kinds.
		if id_re.search(id) == null or id.get_slice(".", 1) != kind:
			bad_id.append(id)
		if not ArtSlots.OWNERS.has(s.get("owner", "")) or not ArtSlots.KINDS.has(kind) or not ArtSlots.STATUSES.has(s.get("status", "")):
			bad_known.append("%s owner %s kind %s status %s" % [id, s.get("owner"), kind, s.get("status")])
		# A complete spec.
		var missing: Array = []
		for f in SPEC_FIELDS:
			if not s.has(f) or (s[f] is String and String(s[f]) == ""):
				missing.append(f)
		if not missing.is_empty():
			bad_spec.append("%s missing %s" % [id, str(missing)])
		var cell := Rect2i(Vector2i.ZERO, size)
		var anchor: Vector2i = s.get("anchor", Vector2i(-1, -1))
		if size.x <= 0 or size.y <= 0 or not cell.has_point(anchor):
			bad_spec.append("%s anchor %s outside its %s cell" % [id, str(anchor), str(size)])
		for st in s.get("states", {}):
			var v: Array = s["states"][st]
			if v.size() != 2 or int(v[0]) < 1 or int(v[1]) < 0:
				bad_spec.append("%s state %s is not [frames, fps]" % [id, st])
		if kind == "frame9":
			var m: Array = s.get("margins", [])
			if m.size() != 4 or int(m[0]) + int(m[2]) >= size.x or int(m[1]) + int(m[3]) >= size.y:
				bad_spec.append("%s 9-slice margins %s do not fit %s" % [id, str(m), str(size)])
		if s.has("door_px"):
			var d: Rect2i = s["door_px"]
			# The door sits in the wall: inside the cell, its sill on the ground (the foot row, less the 2 px step).
			if not cell.encloses(d) or d.end.y < anchor.y - 3 or d.end.y > anchor.y + 1:
				bad_spec.append("%s door %s not in the wall of %s (foot row %d)" % [id, str(d), str(size), anchor.y])
			if s.has("pass_creature"):   # C11, read from the creature's town set now
				var form := String(s["pass_creature"])
				if not creature_cache.has(form):
					creature_cache[form] = _content(form)
				var c: Vector2i = creature_cache[form]
				var good := c != Vector2i.ZERO and d.size.y >= c.y and float(d.size.x) >= 0.75 * c.x
				if not good:
					bad_door.append("%s door %dx%d vs %s %dx%d" % [id, d.size.x, d.size.y, form, c.x, c.y])
		if kind == "building" and s.has("building_class"):
			var cls := String(s["building_class"])
			if BuildingTemplate.canvas(cls) != size or (s.has("door_px") and BuildingTemplate.door_px(cls) != s["door_px"]):
				bad_template.append("%s class %s: slot %s %s, template %s %s" % [id, cls, str(size), str(s.get("door_px", "")), str(BuildingTemplate.canvas(cls)), str(BuildingTemplate.door_px(cls))])
		var forbid: Array = s.get("forbid", [])
		if not (forbid.has("text") and forbid.has("creature") and forbid.has("franchise")):
			bad_forbid.append(id)
		# The placeholder: exact size, binary or opaque, clear of forbidden edges, within budget (C1, C3, C4, C2).
		var ph := PlaceholderPainter.paint(id, s)
		if ph.get_size() != sheet:
			bad_ph.append("%s placeholder %s, sheet %s" % [id, str(ph.get_size()), str(sheet)])
		else:
			var alpha := ph.detect_alpha()
			if String(s["alpha"]) == "opaque" and alpha != Image.ALPHA_NONE:
				bad_ph.append("%s is opaque but its placeholder has transparency" % id)
			elif String(s["alpha"]) == "binary" and alpha == Image.ALPHA_BLEND:
				bad_ph.append("%s placeholder has partial alpha" % id)
			var touch := _edge_touch(ph, size, PlaceholderPainter.allowed_sides(s["edges"]))
			if touch != "":
				bad_ph.append("%s placeholder touches its %s edge" % [id, touch])
			var budget := int(s["palette"].get("max", 0))
			if budget > 0:
				var n := _colours(ph)
				if n > budget:
					bad_budget.append("%s %d colours, budget %d" % [id, n, budget])
		# Its own file, unshared, outside creature folders; legacy present at its size.
		var file := String(s.get("file", ""))
		var under := file.begins_with(ArtSlots.ASSET_DIR) or (String(s["owner"]) == "claude" and file.begins_with(CLAUDE_FRAMES))
		if not under or not file.ends_with(".png"):
			bad_file.append("%s file %s" % [id, file])
		if files.has(file):
			bad_file.append("%s shares %s with %s" % [id, file, files[file]])
		files[file] = id
		var legacy := String(s.get("legacy", ""))
		if String(s["status"]) == "keep" and legacy == "":
			bad_legacy.append("%s is a keep row with no legacy" % id)
		for pair in [[legacy, sheet], [String(s.get("legacy_v1", "")), s.get("legacy_v1_size", Vector2i.ZERO)]]:
			var p := String(pair[0])
			if p == "":
				continue
			var got := _png_size(p)
			if got != pair[1]:
				bad_legacy.append("%s legacy %s is %s, declared %s" % [id, p, str(got), str(pair[1])])
		for p in [file, legacy, String(s.get("legacy_v1", ""))]:
			for root in CREATURE_ROOTS:
				if p != "" and String(p).begins_with(root):
					bad_creature.append("%s %s" % [id, p])
		# Installed files: hash recorded and matching; a file present with no install record is not allowed.
		var on_disk := FileAccess.file_exists(file)
		if installed.has(id):
			var want := String(installed[id].get("sha256", ""))
			var got_hash := FileAccess.get_sha256(file) if on_disk else ""
			if want == "" or got_hash != want:
				bad_hash.append("%s recorded %s, file %s" % [id, want.substr(0, 12), got_hash.substr(0, 12)])
		elif on_disk and String(s["owner"]) != "claude":
			bad_hash.append("%s has a file at %s with no install record (nothing installs without Preston's yes)" % [id, file])
		# What the game draws: the declared size, from the source the status expects.
		var tex := ArtSlots.texture(id)
		var src := ArtSlots.source(id)
		if Vector2i(tex.get_size()) != sheet:
			bad_tex.append("%s resolves to %s from %s, sheet %s" % [id, str(tex.get_size()), src, str(sheet)])
		var expect := "placeholder"
		if not forced:
			if on_disk and _png_size(file) == sheet:
				expect = "file"
			elif legacy != "":
				expect = "legacy"
		if src != expect:
			bad_source.append("%s source %s, expected %s" % [id, src, expect])
		by_src[src] = int(by_src.get(src, 0)) + 1
		var lane := String(s.get("lane", "?"))
		if not lanes.has(lane):
			lanes[lane] = [0, 0]
		lanes[lane][0 if String(s["status"]) != "keep" else 1] += 1
		var area := String(s["area"]) + "." + kind
		area_tot[area] = int(area_tot.get(area, 0)) + 1
		owner_tot[s["owner"]] = int(owner_tot.get(s["owner"], 0)) + 1
		if installed.has(id) or String(s["status"]) == "installed":
			area_inst[area] = int(area_inst.get(area, 0)) + 1
			owner_inst[s["owner"]] = int(owner_inst.get(s["owner"], 0)) + 1
	_ok("ids: %d unique, well formed, middle part = kind" % ids.size(), bad_id.is_empty() and ArtSlots.duplicates().is_empty(), bad_id + Array(ArtSlots.duplicates()))
	_ok("owners, kinds and statuses known", bad_known.is_empty(), bad_known)
	_ok("specs complete (anchor in the cell, door in the wall, states, margins)", bad_spec.is_empty(), bad_spec)
	_ok("doors clear their pass creature, read from town/s.png (C11)", bad_door.is_empty(), bad_door)
	_ok("building slots match BuildingTemplate's class canvas and door", bad_template.is_empty(), bad_template)
	_ok("forbid holds text, creature, franchise", bad_forbid.is_empty(), bad_forbid)
	_ok("placeholders: exactly sheet_size, binary or opaque alpha, clear of forbidden edges (C1, C3, C4)", bad_ph.is_empty(), bad_ph)
	_ok("placeholders within their colour budget", bad_budget.is_empty(), bad_budget)
	_ok("files: one per slot under res://assets/slots/ (Claude's frames in their kit folder)", bad_file.is_empty(), bad_file)
	_ok("legacy art present at its declared size", bad_legacy.is_empty(), bad_legacy)
	_ok("installed files match their recorded hash", bad_hash.is_empty(), bad_hash)
	_ok("nothing in a creature folder", bad_creature.is_empty(), bad_creature)
	_ok("every slot resolves to a texture of its declared size", bad_tex.is_empty(), bad_tex)
	_ok("every slot draws from the source its status expects", bad_source.is_empty(), bad_source)
	var problems := AreaSchema.validate(Layout.area())
	_ok("today's map (TownLayout.area()) passes AreaSchema.validate", problems.is_empty(), Array(problems))
	# With Highbank v2 on (HT_HIGHBANK_V2=1) the town shows v2's areas and the Hall stands on Tower Rise (lane A, 2026-10-26).
	var town_v2 := Layout.v2()
	_ok("TownLayout answers for the map shown (v2 %s, area %s, area_of(hall) %s, return %s)" % [town_v2, Layout.area_id(), Layout.area_of("hall"), str(Layout.anchor("return", Layout.anchor_area("return")))],
		(Layout.area_id() == Layout.V1_AREA) != town_v2 and Layout.area_of("hall") == ("hall_rise" if town_v2 else Layout.V1_AREA)
		and Layout.anchor("nowhere") == Vector2i(-1, -1) and (town_v2 or Layout.anchor("spawn") == Layout.SPAWN))
	print("sources: %d slots, %d on placeholder, %d on legacy, %d on file" % [ids.size(), int(by_src.get("placeholder", 0)), int(by_src.get("legacy", 0)), int(by_src.get("file", 0))])
	var lane_names := lanes.keys()
	lane_names.sort()
	print("by lane (new / keep): " + ", ".join(lane_names.map(func(l: String) -> String: return "%s %d / %d" % [l, lanes[l][0], lanes[l][1]])))
	print("registry %s; slots.json %s" % [ArtSlots.registry_hash().substr(0, 12), _json_state()])
	var tot_inst := 0
	for k in owner_inst:
		tot_inst += int(owner_inst[k])
	print("installed %d of %d" % [tot_inst, ids.size()])
	var areas := area_tot.keys()
	areas.sort()
	for a in areas:
		print("  installed %d of %d  %s" % [int(area_inst.get(a, 0)), int(area_tot[a]), a])
	for o in ArtSlots.OWNERS:
		print("  installed %d of %d  owner %s" % [int(owner_inst.get(o, 0)), int(owner_tot.get(o, 0)), o])
	print("hard-coded art paths left in scripts/: %s (114 when the plan was written)" % _art_paths())
	print("art_slots_check took %d ms" % (Time.get_ticks_msec() - t0))
	print("RESULT: %s" % ("every slot resolves" if fails == 0 else "%d problems" % fails))
	quit(1 if fails else 0)


## The opaque content box of a creature's town set (its south view), or ZERO when the set is missing.
func _content(form: String) -> Vector2i:
	var path := "res://assets/sprites/arena/%s/town/s.png" % form
	if not FileAccess.file_exists(path):
		return Vector2i.ZERO
	return Image.load_from_file(ProjectSettings.globalize_path(path)).get_used_rect().size


func _png_size(path: String) -> Vector2i:
	if not FileAccess.file_exists(path):
		return Vector2i.ZERO
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	return img.get_size() if img != null else Vector2i.ZERO


## The first forbidden side an opaque pixel touches, cell by cell, or "".
func _edge_touch(img: Image, cell: Vector2i, allowed: Array) -> String:
	for cy in range(0, img.get_height(), cell.y):
		for cx in range(0, img.get_width(), cell.x):
			var r := Rect2i(cx, cy, cell.x, cell.y)
			var sides := {"top": [Vector2i(r.position.x, r.position.y), Vector2i(1, 0), cell.x],
				"bottom": [Vector2i(r.position.x, r.end.y - 1), Vector2i(1, 0), cell.x],
				"left": [Vector2i(r.position.x, r.position.y), Vector2i(0, 1), cell.y],
				"right": [Vector2i(r.end.x - 1, r.position.y), Vector2i(0, 1), cell.y]}
			for side in sides:
				if allowed.has(side):
					continue
				var at: Vector2i = sides[side][0]
				for i in int(sides[side][2]):
					if img.get_pixelv(at + sides[side][1] * i).a > 0.0:
						return side
	return ""


func _colours(img: Image) -> int:
	var seen := {}
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a > 0.0:
				seen[c.to_rgba32()] = true
	return seen.size()


func _installed() -> Dictionary:
	if not FileAccess.file_exists(INSTALLED):
		return {}
	var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(INSTALLED))
	return d.get("slots", {}) if d is Dictionary else {}


func _json_state() -> String:
	if not FileAccess.file_exists(SLOTS_JSON):
		return "missing (export: tools/art/render_slot_refs.gd -- --export-only)"
	var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(SLOTS_JSON))
	if d is Dictionary and String(d.get("registry_sha256", "")) == ArtSlots.registry_hash():
		return "fresh"
	return "stale: the Python tools refuse it until tools/art/render_slot_refs.gd -- --export-only runs"


## Distinct res://assets/sprites/(world|ui|menu|player|effects) paths written into scripts/, the registry left out.
func _art_paths() -> String:
	var re := RegEx.create_from_string(ART_PATH)
	var seen := {}
	var scripts := 0
	var stack: Array[String] = ["res://scripts/"]
	while not stack.is_empty():
		var dir: String = stack.pop_back()
		if dir == ArtSlots.SLOT_DIR:
			continue
		for d in DirAccess.get_directories_at(dir):
			stack.append(dir + d + "/")
		for f in DirAccess.get_files_at(dir):
			if not f.ends_with(".gd"):
				continue
			var found := re.search_all(FileAccess.get_file_as_string(dir + f))
			if not found.is_empty():
				scripts += 1
			for m in found:
				seen[m.get_string()] = true
	return "%d distinct in %d scripts" % [seen.size(), scripts]
