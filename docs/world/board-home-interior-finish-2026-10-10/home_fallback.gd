extends SceneTree
const W := "D:/dev/hollowtide-board-home-20261010/"
func _initialize() -> void:
	var original := load(W+"originals/scripts/town/room_painter.gd")
	var painter := load("res://scripts/town/room_painter.gd")
	var room := load("res://scripts/town/town_room.gd")
	var before: Image=original.paint("home",room.ROOMS.home)
	var after: Image=painter.paint("home",room.ROOMS.home)
	var ok: bool=before.get_data()==after.get_data()
	print("FALLBACK original Home painter exact" if ok else "FAIL Home fallback")
	var board := load("res://scripts/town/job_board_painter.gd")
	var texture: Texture2D = board._display_texture()
	var source: Texture2D = load(board.ART)
	var board_ok: bool = texture.get_image().get_data()==source.get_image().get_data() and board._visual_scale(texture)==Vector2(2,2) and board._visual_offset(texture)==Vector2(-24,-source.get_image().get_used_rect().end.y)
	print("FALLBACK original enlarged Board exact" if board_ok else "FAIL Board fallback")
	ok=ok and board_ok
	quit(0 if ok else 1)
