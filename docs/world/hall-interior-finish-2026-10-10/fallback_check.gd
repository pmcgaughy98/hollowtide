extends SceneTree
const W := "D:/dev/hollowtide-hall-interior-20261010/"
const Painter := preload("res://scripts/town/room_painter.gd")
const Room := preload("res://scripts/town/town_room.gd")
const Art := preload("res://scripts/town/hall_room_art.gd")
func _initialize() -> void:
	var previous := load(W+"originals/scripts/town/room_painter.gd")
	var old: Image=previous.paint("hall",Room.ROOMS.hall)
	var current: Image=Painter.paint("hall",Room.ROOMS.hall)
	var ok := not Art.available() and old.get_data()==current.get_data()
	print("FALLBACK Hall original exact" if ok else "FAIL Hall fallback")
	quit(0 if ok else 1)
