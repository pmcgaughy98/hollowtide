extends SceneTree
func _initialize() -> void:
	var painter := load("res://scripts/town/room_painter.gd")
	var rooms := load("res://scripts/town/town_room.gd")
	var img: Image=painter.paint("hall",rooms.ROOMS.hall)
	img.save_png("D:/dev/hollowtide-hall-interior-20261010/hall-layout-reference.png")
	print("Exported exact current Hall layout ",img.get_size())
	quit()
