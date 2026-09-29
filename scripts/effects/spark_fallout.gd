extends Node2D

## The fallout of Ironvent's blowdown (Furnace Roar signature, Preston
## 2026-09-29): clusters of glowing sparks and cinders drift down over the whole
## scene after the vents blow, fading as they fall. Uses the "fallout" piece
## from Preston's blast-furnace blowdown sheet.
##
## Used as a move's signature_effect, so the battle calls erupt() with the same
## arguments as the Molten Glass meltdown; only px and the timing matter here.
## Frees itself when the last cluster has faded.

@export var fallout: Texture2D
@export var clusters := 12
## Seconds over which new clusters appear, and how long each one falls.
@export var spread_seconds := 0.6
@export var fall_seconds := 1.5
## Stage area the clusters start in (they fall from the upper part of the scene).
@export var area := Rect2(80, 40, 1000, 200)


func erupt(_start: Vector2, _end: Vector2, px: float, arrive: float, _sustain: float) -> void:
	if fallout == null:
		queue_free()
		return
	# The battle lays signature effects under the creatures (for ground floods);
	# sparks fall over everything, so move to the top of the stage.
	get_parent().move_child.call_deferred(self, -1)
	for i in clusters:
		var s := Sprite2D.new()
		s.texture = fallout
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.scale = Vector2.ONE * px
		s.flip_h = randf() < 0.5
		# Whole art pixels, so the sparks sit on the same grid as everything else.
		var at := Vector2(randf_range(area.position.x, area.end.x), randf_range(area.position.y, area.end.y))
		s.position = (at / px).round() * px
		# Lit a little brighter than drawn, so the cinders read against a dark sky.
		s.modulate = Color(1.5, 1.3, 1.1, 0.0)
		add_child(s)
		var t := create_tween()
		t.tween_interval(maxf(0.0, arrive) + spread_seconds * float(i) / clusters)
		t.tween_property(s, "modulate:a", 1.0, 0.1)
		# The fall and the fade run together, after the fade-in has finished.
		t.tween_property(s, "position:y", s.position.y + randf_range(60.0, 130.0), fall_seconds)
		t.parallel().tween_property(s, "modulate:a", 0.0, fall_seconds).set_ease(Tween.EASE_IN)
	get_tree().create_timer(arrive + spread_seconds + fall_seconds + 0.3).timeout.connect(queue_free)
