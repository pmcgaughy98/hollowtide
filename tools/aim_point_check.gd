extends SceneTree
## Confirms each flying move names a point that sits on that creature's sprite.


const CREATURES := [
	"res://data/creatures/002_cinderhide.tres",
	"res://data/creatures/101_clinkerhide.tres",
	"res://data/creatures/102_ironvent.tres",
	"res://data/creatures/103_kithflare.tres",
	"res://data/retired_creatures/104_wayburn.tres",
	"res://data/retired_creatures/105_coalcrest.tres",
	"res://data/creatures/106_fusern.tres",
	"res://data/creatures/107_slagglass.tres",
	"res://data/creatures/108_vitrecrag.tres",
]

const EMPTY_AIM := [
	"Cinder Claw",
	"Furnace Roar",
	"Shoulder Drive",
	"Plate Rake",
	"Plate Lunge",
	"Molten Glass",
	"Kingstone Rail",
]


func _init() -> void:
	var named := 0
	for path in CREATURES:
		var creature: CreatureData = load(path)
		var image := creature.sprite.get_image()
		var center := Vector2(image.get_width(), image.get_height()) * 0.5
		for move in creature.moves:
			if move.aim == "":
				continue
			named += 1
			if not creature.aim_points.has(move.aim):
				push_error("%s names %s but %s has no such point" % [move.move_name, move.aim, creature.creature_name])
				quit(1)
				return
			var point: Vector2 = creature.aim_points[move.aim]
			if not _on_body(image, center + point):
				push_error("%s %s %s is off the sprite" % [creature.creature_name, move.aim, point])
				quit(1)
				return
		for key in creature.aim_points.keys():
			var point: Vector2 = creature.aim_points[key]
			if not _on_body(image, center + point):
				push_error("%s point %s %s is off the sprite" % [creature.creature_name, key, point])
				quit(1)
				return
	var beam: MoveData = load("res://data/moves/vitrecrag_molten_beam.tres")
	var cannon: MoveData = load("res://data/moves/vitrecrag_molten_cannon.tres")
	var coal: MoveData = load("res://data/moves/cinderhide_coal_spit.tres")
	if beam.aim != "mouth" or cannon.aim != "mouth" or coal.aim != "vent":
		push_error("beam %s cannon %s coal %s" % [beam.aim, cannon.aim, coal.aim])
		quit(1)
		return
	for move_name in EMPTY_AIM:
		var found := false
		for path in CREATURES:
			var creature: CreatureData = load(path)
			for move in creature.moves:
				if move.move_name != move_name:
					continue
				found = true
				if move.aim != "":
					push_error("%s should keep an empty aim, has %s" % [move_name, move.aim])
					quit(1)
					return
		if not found and move_name == "Kingstone Rail":
			var rail: MoveData = load("res://data/moves/oxbowarchon_kingstone_rail.tres")
			found = true
			if rail.aim != "":
				push_error("Kingstone Rail aim is %s" % rail.aim)
				quit(1)
				return
		if not found:
			push_error("missing %s" % move_name)
			quit(1)
			return
	if named < 28:
		push_error("only %s moves name a point" % named)
		quit(1)
		return
	print("AIM_OK")
	quit(0)


func _on_body(image: Image, pixel: Vector2) -> bool:
	var x := int(round(pixel.x))
	var y := int(round(pixel.y))
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var xx := x + dx
			var yy := y + dy
			if xx < 0 or yy < 0 or xx >= image.get_width() or yy >= image.get_height():
				continue
			if image.get_pixel(xx, yy).a > 0.08:
				return true
	return false
