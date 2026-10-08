extends SceneTree
## Exports every creature and move resource to JSON for the Unity port (Claude, 2026-10-06).
##   Godot --headless --path . --script res://tools/unity_port/export_data.gd -- <out_dir>
## Writes creatures.json, moves.json and PNG copies of SVG backdrops. The JSON holds every script variable of each resource. Textures,
## audio and other resources become their res:// path; nested sub-resources (camera shots)
## become objects; enums stay numbers. Unity's importer maps res:// to its Assets folder.

func _initialize() -> void:
	var out: String = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(out)
	for kind in [["creatures", "res://data/creatures/"], ["moves", "res://data/moves/"]]:
		var rows: Array = []
		for f in DirAccess.get_files_at(kind[1]):
			if f.ends_with(".tres"):
				var r: Resource = load(kind[1] + f)
				var row: Dictionary = _dump(r)
				row["_file"] = f.get_basename()
				rows.append(row)
		var file := FileAccess.open(out.path_join(kind[0] + ".json"), FileAccess.WRITE)
		file.store_string(JSON.stringify(rows, "\t"))
		print(kind[0], ": ", rows.size())
	_slim(out)
	# Unity has no built-in SVG import: save each SVG backdrop as the PNG Godot draws it.
	DirAccess.make_dir_recursive_absolute(out.path_join("backgrounds"))
	for f in DirAccess.get_files_at("res://assets/backgrounds/"):
		if f.ends_with(".svg"):
			var tex: Texture2D = load("res://assets/backgrounds/" + f)
			tex.get_image().save_png(out.path_join("backgrounds/" + f.get_basename() + ".png"))
			print("backdrop ", f, " ", tex.get_size())
	quit()


func _dump(r: Resource) -> Dictionary:
	var d := {}
	for p in r.get_property_list():
		if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			d[p.name] = _value(r.get(p.name))
	return d


func _value(v: Variant) -> Variant:
	if v is Resource:
		var res: Resource = v
		if res.resource_path != "" and not res.resource_path.contains("::"):
			return res.resource_path
		return _dump(res)
	if v is Array:
		var a: Array = []
		for x in v:
			a.append(_value(x))
		return a
	if v is Dictionary:
		var o := {}
		for k in v:
			o[str(k)] = _value(v[k])
		return o
	if v is Vector2 or v is Vector2i:
		return [v.x, v.y]
	if v is Color:
		return [v.r, v.g, v.b, v.a]
	if v is PackedStringArray or v is PackedFloat32Array or v is PackedInt32Array:
		return Array(v)
	return v


## The Unity importer's input: the fields the port uses so far, in a flat shape
## Unity's JsonUtility reads directly. Art paths are already Unity paths
## (res://assets/ is copied to Assets/Hollowtide/Art/); data links are file names.
func _slim(out: String) -> void:
	var creatures: Array = []
	for f in DirAccess.get_files_at("res://data/creatures/"):
		if not f.ends_with(".tres"):
			continue
		var c: CreatureData = load("res://data/creatures/" + f)
		var moves: Array = []
		for m in c.moves:
			if m != null:
				moves.append(m.resource_path.get_file().get_basename())
		creatures.append({
			"file": f.get_basename(), "id": c.id, "dexNumber": c.dex_number, "creatureName": c.creature_name,
			"description": c.description, "essence": c.essence, "hasSecondEssence": c.has_second_essence,
			"secondEssence": c.second_essence, "sprite": _art(c.sprite), "backSprite": _art(c.back_sprite),
			"battleSize": c.battle_size, "baseHp": c.base_hp, "baseAttack": c.base_attack,
			"baseDefense": c.base_defense, "baseSpeed": c.base_speed, "moves": moves,
			"bodyParts": Array(c.body_parts).map(func(x): return str(x)),
			"evolvesInto": c.evolves_into.resource_path.get_file().get_basename() if c.evolves_into != null else "",
			"idlePeriod": c.idle_period, "idleFrames": Array(c.idle_frames).map(_art),
			"backIdleFrames": Array(c.back_idle_frames).map(_art),
		})
	var moves_out: Array = []
	for f in DirAccess.get_files_at("res://data/moves/"):
		if not f.ends_with(".tres"):
			continue
		var m: Resource = load("res://data/moves/" + f)
		moves_out.append({"file": f.get_basename(), "moveName": m.move_name, "essence": m.essence,
			"power": m.power, "maxUses": m.max_uses, "signature": m.signature,
			"requiredParts": Array(m.required_parts).map(func(x): return str(x))})
	var file := FileAccess.open(out.path_join("unity_data.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"creatures": creatures, "moves": moves_out}, "	"))


func _art(t: Resource) -> String:
	if t == null or t.resource_path == "":
		return ""
	return t.resource_path.replace("res://assets/", "Assets/Hollowtide/Art/").replace(".svg", ".png")
