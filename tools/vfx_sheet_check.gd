extends SceneTree
## Confirms the two ultimate VFX sheets are on the live effect scenes.


func _init() -> void:
	var roar: Node = load("res://scenes/effects/ironvent_pressure_field.tscn").instantiate()
	var rail: Node = load("res://scenes/effects/oxbowarchon_sky_rail.tscn").instantiate()
	var roar_sheet: Texture2D = roar.get("geyser_vfx")
	var rail_sheet: Texture2D = rail.get("impact_vfx")
	if roar_sheet == null or rail_sheet == null:
		push_error("VFX sheet missing")
		quit(1)
	if roar_sheet.get_width() != 384 or roar_sheet.get_height() != 384:
		push_error("Furnace Roar sheet is %s" % roar_sheet.get_size())
		quit(1)
	if rail_sheet.get_width() != 384 or rail_sheet.get_height() != 384:
		push_error("Kingstone sheet is %s" % rail_sheet.get_size())
		quit(1)
	roar.free()
	rail.free()
	print("VFX_OK")
	quit(0)
