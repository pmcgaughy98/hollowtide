extends Node2D
## Crisp unseen cells render after every world effect and before the HUD. The popups draw over it (dungeon.gd _pop_top,
## z 4096; LV-19, D4, Claude, 2026-10-24).
var dungeon: Node2D
func _init(target: Node2D) -> void:
	dungeon=target
	z_index=4095
func _process(_delta: float) -> void: queue_redraw()
func _draw() -> void:
	var origin: Vector2 = -dungeon._world.position
	var t0 := Vector2i(floori(origin.x/24)-1,floori(origin.y/24)-1)
	for y in range(t0.y,t0.y+12):
		for x in range(t0.x,t0.x+19):
			if not dungeon.visible_tiles.has(Vector2i(x,y)):
				draw_rect(Rect2(x*24,y*24,24,24),Color("#080b0e"))
