extends RefCounted
## What the team carries between Highbank and the Hollow (Claude, 2026-10-09; Preston: "do the town
## wiring, prologue to town to hollow and back"). One record that lives while the game runs: the
## prologue starts it, the town hands it to a run, the run hands it back on a clear or a faint.
##
## The save (Claude, 2026-10-12, the pitch kit's "no save system" hole): the same record written to
## one file in the user folder whenever the team arrives in Highbank or sets out from it, and read
## back by Continue on the title. A run in progress is not saved; the genre's "suspend save" for a
## quit mid-dungeon is the next step. The file holds plain data only (store_var without objects),
## so int keys (levels by line) and Vector2i survive, which JSON would lose.

const KEYS := ["party", "roster", "bag", "taught", "growth", "iq", "levels", "pending_learn", "cleared", "faints", "tactic", "jobs", "rank", "beaten", "story"]
const SAVE_PATH := "user://team.save"   # %APPDATA%\Godot\app_userdata\Hollowtide\team.save on Windows
const SAVE_VERSION := 1

static var data := {}
## Where saves go. A check under `--script` that leaves this at SAVE_PATH never touches the real save.
static var save_path := SAVE_PATH
static var last_save_at := 0.0   # unix time of the last successful save this session (the checks read it)
static var restored_from_backup := false   # the last read came from the .bak: the title says so (Preston, 2026-10-22)


## A new game: the team the prologue chose, and nothing else yet.
static func start(party: Array, metas: Dictionary = {}) -> void:
	data = {"party": party.duplicate(true), "metas": metas.duplicate(true)}


## Copy what a dungeon run knows into the record. `news` says how the run ended.
static func take_from(node: Node, news: String) -> void:
	for k in KEYS:
		var v: Variant = node.get(k)
		data[k] = v.duplicate(true) if v is Array or v is Dictionary else v
	data["news"] = news


## Give a new dungeon run (or the town) what the record holds, before it is added to the tree.
static func give_to(node: Node) -> void:
	for k in KEYS:
		if data.has(k) and k in node:
			var v: Variant = data[k]
			node.set(k, v.duplicate(true) if v is Array or v is Dictionary else v)
	for m in data.get("metas", {}):
		node.set_meta(m, data["metas"][m])


## Write the record to disk. False when there is nothing to save or the file could not be written.
## Crash-safe (Claude, 2026-10-22): the record is written whole to <save>.tmp, the save before it is kept as
## <save>.bak, and only then does the .tmp take the save's name. Opening the save itself for writing empties it at
## once, so a crash or power cut mid-write used to leave a cut-short file and the title dropped Continue.
static func save() -> bool:
	if data.is_empty():
		return false
	var tmp := save_path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_warning("TeamState: could not write %s (%s)" % [tmp, error_string(FileAccess.get_open_error())])
		return false
	var record := data.duplicate(true)
	record.erase("news")        # the town has already read these by the time it saves
	record.erase("arrive_at")
	var stored := f.store_var({"version": SAVE_VERSION, "saved": Time.get_unix_time_from_system(), "data": record})
	f.close()
	if not stored:
		push_warning("TeamState: could not finish writing %s" % tmp)
		return false
	var main := ProjectSettings.globalize_path(save_path)
	if FileAccess.file_exists(save_path):
		DirAccess.rename_absolute(main, main + ".bak")   # replaces the older .bak
	var err := DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), main)
	if err != OK:
		push_warning("TeamState: could not move %s into place (%s)" % [tmp, error_string(err)])
		return false
	last_save_at = Time.get_unix_time_from_system()
	return true


## A check (a `--script` run has a script on the main loop) that leaves `save_path` at the real file
## neither writes nor sees the real save: no check overwrites it, and no check's title grows a Continue
## button because Preston has played. A check that wants saves points `save_path` at a file of its own.
static func _real_file_in_a_check() -> bool:
	var loop: MainLoop = Engine.get_main_loop()
	return loop != null and loop.get_script() != null and save_path == SAVE_PATH


## The game's own saves, at Highbank's arrivals and departures.
static func autosave() -> bool:
	if _real_file_in_a_check():
		return false
	return save()


static func has_save() -> bool:
	return not _read().is_empty()   # the save, or its .bak


## A run kept by a quit mid-dungeon (dungeon.suspend()). Continue opens it instead of Highbank, once:
## taking it drops it from the record and saves again, so a run cannot be replayed from the same file.
static func has_suspended() -> bool:
	return data.has("suspend") and data["suspend"] is Dictionary and not data["suspend"].is_empty()


static func take_suspended() -> Dictionary:
	var s: Dictionary = data.get("suspend", {})
	data.erase("suspend")
	autosave()
	return s


## Read the save into the record. False when there is no usable file; the record is left as it was.
static func load_save() -> bool:
	var wrapper := _read()
	if wrapper.is_empty():
		return false
	data = wrapper["data"]
	return true


## What the title can say about the save: who leads, how far the team is, when it was written.
static func summary() -> Dictionary:
	var wrapper := _read()
	if wrapper.is_empty():
		return {}
	var d: Dictionary = wrapper["data"]
	return {"party": d.get("party", []), "cleared": int(d.get("cleared", 0)), "beaten": d.get("beaten", []), "saved": float(wrapper.get("saved", 0.0))}


## Bring an older save up to SAVE_VERSION, one step per bump, so a new version upgrades old saves instead of hiding
## them (the title drops Continue and the next arrival writes over them). Version 1 is the only one so far, so there
## is no step yet. Bump SAVE_VERSION only together with a step here.
static func _migrate(v: Dictionary) -> Dictionary:
	return v


static func erase_save() -> void:
	for path in [save_path, save_path + ".bak", save_path + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


## The save, or its .bak when the save is missing, cut short or unreadable (a crash or power cut between writes).
static func _read() -> Dictionary:
	if _real_file_in_a_check():
		return {}
	for path in [save_path, save_path + ".bak"]:
		var v := _read_file(path)
		if not v.is_empty():
			restored_from_backup = path != save_path
			return v
	return {}


static func _read_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	# store_var writes a 4-byte length, then the value. A file cut short fails this test quietly, where get_var
	# would print an engine ERROR (and run_checks.py counts every engine ERROR as a failed check).
	if f.get_length() < 8 or f.get_32() + 4 != f.get_length():
		f.close()
		return {}
	f.seek(0)
	var v: Variant = f.get_var()
	f.close()
	if v is Dictionary and int(v.get("version", 0)) < SAVE_VERSION:
		v = _migrate(v)
	if not (v is Dictionary) or int(v.get("version", 0)) != SAVE_VERSION or not (v.get("data") is Dictionary) or v["data"].is_empty():
		return {}
	return v
