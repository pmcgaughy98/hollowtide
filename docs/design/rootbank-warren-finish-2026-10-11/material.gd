extends SceneTree
const Gen := preload("res://scripts/hollow/hollow_gen.gd")
const Dungeon := preload("res://scripts/dungeon/dungeon.gd")
const Detail := preload("res://scripts/dungeon/rootbank_detail.gd")
const OUT := "D:/dev/hollowtide-rootbank-finish-20261011/material-check.json"
var failures := 0
var checks := 0
var receipts: Array = []
func _initialize() -> void: run.call_deferred()
func ok(label: String, good: bool) -> void:
	checks += 1
	if not good: failures += 1
	print(label, ": ", "ok" if good else "FAIL")
func run() -> void:
	var original: GDScript = load("D:/dev/hollowtide-rootbank-finish-20261011/originals/riverbank_painter.gd")
	for seed_value in [7, 983, 19031]:
		var data := Gen.generate(seed_value, Dungeon.RECIPE)
		var saved := var_to_bytes(data)
		var base: Image = original.paint(data, 24, seed_value)
		var result: Image = Detail.finish(base.duplicate(), data, 24, seed_value)
		var repeat: Image = Detail.finish(base.duplicate(), data, 24, seed_value)
		ok("Seed %d dimensions" % seed_value, result.get_size() == base.get_size())
		ok("Seed %d deterministic" % seed_value, result.get_data() == repeat.get_data())
		ok("Seed %d data untouched" % seed_value, saved == var_to_bytes(data))
		var changed := 0
		var floor_changes := 0
		var transparent := 0
		for y in result.get_height():
			for x in result.get_width():
				var c := result.get_pixel(x,y)
				if c.a != 1.0: transparent += 1
				if c != base.get_pixel(x,y):
					changed += 1
					if data.tiles[(y / 24) * data.w + x / 24] != Gen.WALL: floor_changes += 1
		ok("Seed %d floor and stairs exact" % seed_value, floor_changes == 0)
		ok("Seed %d opaque" % seed_value, transparent == 0)
		ok("Seed %d visible wall finish" % seed_value, changed > 100)
		receipts.append({"seed": seed_value,"changed_wall_pixels":changed,"changed_floor_pixels":floor_changes,"transparent_pixels":transparent})
		var small: Image = original.paint(data, 12, seed_value)
		var small_before := small.get_data()
		ok("Seed %d old tile-size fallback exact" % seed_value, Detail.finish(small,data,12,seed_value).get_data() == small_before)
	FileAccess.open(OUT,FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"seeds":receipts},"  "))
	print("ROOTBANK MATERIAL: %d/%d" % [checks-failures,checks])
	quit(0 if failures == 0 else 1)
