extends SceneTree
## One size scale for every creature (Preston 2026-10-05: "the size adjustment
## thing for everybody"). Stage I stands as tall as Cinderhide on the near side
## of a battle, Stage II 1.2x that, Stage III 1.4x. For each creature this finds
## its stage, measures its front art, and picks the battle_size whose zoom lands
## closest to the target, using the same zoom rule as battle_screen.gd.
## Usage: Godot --headless --path . --script res://tools/debug/size_plan.gd [-- apply]
## Without "apply" it only prints the table.

const CREATURE_HEIGHT := 264.0
const STAGE_SCALE := {1: 1.0, 2: 1.2, 3: 1.4}
## Lines whose stages are not linked by evolves_into yet.
const STAGE_OVERRIDE := {"Fusern": 1, "Slagglass": 2, "Vitrecrag": 3}


func _zoom(size: float, canvas_h: float) -> float:
	var target := CREATURE_HEIGHT * size
	if is_equal_approx(size, 1.0):
		return maxf(1.0, roundf(target / canvas_h))
	return maxf(1.0, roundf(target / canvas_h * 2.0) / 2.0)


func _initialize() -> void:
	var apply := OS.get_cmdline_user_args().has("apply")
	var all := CreatureRoster.load_all()
	var stage := {}
	for c in all:
		stage[c.creature_name] = 1
	for c in all:
		var s := 1
		var next: CreatureData = c.evolves_into
		while next != null:
			s += 1
			stage[next.creature_name] = maxi(stage.get(next.creature_name, 1), s)
			next = next.evolves_into
	for n in STAGE_OVERRIDE:
		stage[n] = STAGE_OVERRIDE[n]
	# Walk lines from Stage I upward so each stage can compare with the one before.
	var prev_of := {}
	for c in all:
		if c.evolves_into != null:
			prev_of[c.evolves_into.creature_name] = c.creature_name
	for n in ["Slagglass", "Vitrecrag"]:
		prev_of[n] = {"Slagglass": "Fusern", "Vitrecrag": "Slagglass"}[n]
	all.sort_custom(func(a, b): return stage[a.creature_name] < stage[b.creature_name])
	var shown := {}
	var ref: CreatureData = load("res://data/creatures/002_cinderhide.tres")
	var ref_used := ref.sprite.get_image().get_used_rect()
	var base := ref_used.size.y * _zoom(ref.battle_size, ref.sprite.get_height())
	print("Stage I target %d px (Cinderhide)" % base)
	for c in all:
		var h := float(c.sprite.get_height())
		var used := c.sprite.get_image().get_used_rect().size.y
		var st: int = stage[c.creature_name]
		var target: float = base * STAGE_SCALE[st]
		var now := used * _zoom(c.battle_size, h)
		var best_z := 1.0
		for z2 in range(2, 13):
			var z := z2 / 2.0
			if absf(used * z - target) < absf(used * best_z - target):
				best_z = z
		# Each stage must stand clearly taller (8%+) than the one it evolves from.
		var prev_h: float = shown.get(prev_of.get(c.creature_name, ""), 0.0)
		while used * best_z < prev_h * 1.08 and best_z < 6.0:
			best_z += 0.5
		shown[c.creature_name] = used * best_z
		# The battle_size that gives exactly that zoom; 1.0 itself uses whole steps.
		var size := snappedf(best_z * h / CREATURE_HEIGHT, 0.01)
		if not is_equal_approx(_zoom(size, h), best_z):
			size += 0.01
		print("%-16s stage %d  art %3d px  now %3d px (size %.2f)  ->  %3d px (size %.2f)" % [
			c.creature_name, st, used, now, c.battle_size, used * best_z, size])
		# Only rewrite a creature whose on-screen height actually changes.
		if apply and absf(used * best_z - now) >= 1.0:
			c.battle_size = size
			ResourceSaver.save(c, c.resource_path)
	quit()
