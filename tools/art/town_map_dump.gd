extends SceneTree
## Prints Highbank v2's areas (scripts/world/areas/) as one JSON line for tools/art/town_map.py to draw
## (Claude, 2026-10-28). Rects and tiles become [x, y, w, h] and [x, y].
##   godot --headless --path . --script res://tools/art/town_map_dump.gd

const Areas := preload("res://scripts/world/areas/index.gd")
const Template := preload("res://scripts/town/building_template.gd")


func _init() -> void:
	var out := {"areas": {}, "classes": _plain(Template.CLASSES)}
	for id in Areas.v2_ids():
		out["areas"][id] = _plain(Areas.area(id))
	print("TOWN_MAP_JSON " + JSON.stringify(out))
	quit()


func _plain(v: Variant) -> Variant:
	match typeof(v):
		TYPE_DICTIONARY:
			var d := {}
			for k in v:
				d[str(k)] = _plain(v[k])
			return d
		TYPE_ARRAY:
			return (v as Array).map(_plain)
		TYPE_RECT2I:
			return [v.position.x, v.position.y, v.size.x, v.size.y]
		TYPE_VECTOR2I:
			return [v.x, v.y]
		TYPE_VECTOR2:
			return [v.x, v.y]
		_:
			return v
