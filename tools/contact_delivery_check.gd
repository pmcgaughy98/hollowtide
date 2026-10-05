extends SceneTree
## Body strikes lunge. Thrown moves stay projectiles. Damage fields are untouched.


const BODY := {
	"Vent Rake": "res://data/moves/cinderhide_vent_rake.tres",
	"Brow Shear": "res://data/moves/clinkerhide_brow_shear.tres",
	"Crest Ram": "res://data/moves/ironvent_crest_ram.tres",
	"Hex Cut": "res://data/moves/fusern_hex_cut.tres",
	"Tail Brake": "res://data/moves/kithflare_tail_brake.tres",
	"Handoff Dash": "res://data/moves/kithflare_handoff_dash.tres",
	"Plate Rake": "res://data/moves/coalcrest_plate_rake.tres",
}

const THROWN := {
	"Ember Flick": "res://data/moves/cinderhide_ember_flick.tres",
	"Coal Spit": "res://data/moves/cinderhide_coal_spit.tres",
	"Tail Shutter": "res://data/moves/wayburn_tail_shutter.tres",
	"Clinker Toss": "res://data/moves/clinkerhide_clinker_toss.tres",
	"Molten Beam": "res://data/moves/vitrecrag_molten_beam.tres",
	"Furnace Roar": "res://data/moves/ironvent_furnace_roar.tres",
}


func _init() -> void:
	for move_name in BODY:
		var move: MoveData = load(BODY[move_name])
		if move.delivery != MoveData.Delivery.CONTACT:
			push_error("%s is not contact" % move_name)
			quit(1)
			return
		if move.attack_frames.is_empty() == false:
			push_error("%s grew attack frames" % move_name)
			quit(1)
			return
		var effect: Node = move.effect.instantiate()
		var pop: Node = effect.get_node_or_null("Pop")
		if pop == null:
			effect.free()
			push_error("%s has no slash pop" % move_name)
			quit(1)
			return
		effect.free()
	for move_name in THROWN:
		var move: MoveData = load(THROWN[move_name])
		if move.delivery != MoveData.Delivery.PROJECTILE:
			push_error("%s stopped being a projectile" % move_name)
			quit(1)
			return
	var roar: MoveData = load(THROWN["Furnace Roar"])
	if not roar.signature:
		push_error("Furnace Roar lost its ultimate flag")
		quit(1)
		return
	print("CONTACT_OK")
	quit(0)
