extends Node2D

## Oxbowarchon's Kingstone Rail, the part after the release (Preston, 2026-09-29:
## the rails point at the sky, the sphere builds while it braces, then it
## releases). The drawn frames carry the charge and the shot leaving the rails;
## this carries the shot coming back down. Proposal, pending Preston's call on
## what the shot does once it is in the sky:
##   - a held beat of quiet while the opponent trembles, the shot gone overhead,
##   - a glint high above the opponent where it will come from,
##   - the jade slug drops straight down onto the opponent with a trail,
##   - it shatters in an emerald burst as the hit lands.
## Art: the jade dart and emerald burst from Preston's Proestmar effect sheet
## (assets/sprites/effects/preostmar/). The dart is drawn pointing right, so it
## is turned a quarter turn to point down; a quarter turn keeps pixel art exact.
##
## Used as the move's signature_effect: the battle calls erupt() on the release
## frame, with arrive = the seconds until the hit frame. It also sets target
## (the opponent's sprite, which this shakes) and shake (the screen shake).

@export var slug: Texture2D
@export var glint: Texture2D
@export var bursts: Array[Texture2D] = []
## Seconds the slug takes to fall from above the screen onto the opponent.
@export var fall_seconds := 0.16
## Afterimages trailing the falling slug.
@export var trail := 3

var target: Sprite2D
var shake: Callable

var _px := 3.0


func erupt(_start: Vector2, end: Vector2, px: float, arrive: float, _sustain: float) -> void:
	_px = maxf(1.0, px)
	# The battle puts effects under the creatures; the slug falls in front of them.
	get_parent().move_child(self, -1)
	# Where the slug hits: the middle of the opponent's body, not its feet.
	var hit := end - Vector2(0, 14 * _px)
	var fall_at: float = maxf(0.05, arrive - fall_seconds)
	_tremble(fall_at)
	get_tree().create_timer(fall_at * 0.45).timeout.connect(_glint.bind(hit, fall_at * 0.55))
	get_tree().create_timer(fall_at).timeout.connect(_fall.bind(hit))
	get_tree().create_timer(arrive + 1.2).timeout.connect(queue_free)


func _sprite(tex: Texture2D, pos: Vector2, scale_by: float) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.scale = Vector2.ONE * _px * scale_by
	s.position = (pos / _px).round() * _px
	add_child(s)
	return s


## The opponent shivers harder as the shot hangs overhead, then goes still for
## a breath just before it lands.
func _tremble(seconds: float) -> void:
	if not is_instance_valid(target):
		return
	var home: Vector2 = target.position
	var hush: float = minf(0.18, seconds * 0.25)
	var elapsed := 0.0
	var side := 1.0
	while elapsed < seconds - hush:
		var k: float = elapsed / maxf(0.01, seconds - hush)
		if is_instance_valid(target):
			target.position = home + Vector2(roundf(lerpf(0.0, 2.0, k)) * _px * side, 0)
		side = -side
		await get_tree().create_timer(0.05).timeout
		elapsed += 0.05
	if is_instance_valid(target):
		target.position = home


## A twinkle high above the opponent: the shot turning over at the top of its arc.
func _glint(hit: Vector2, seconds: float) -> void:
	if glint == null:
		return
	var g := _sprite(glint, Vector2(hit.x, 40), 1.0)
	g.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(g, "modulate:a", 1.0, seconds * 0.4)
	t.tween_property(g, "scale", Vector2.ONE * _px * 1.5, seconds * 0.6)
	t.parallel().tween_property(g, "modulate:a", 0.0, seconds * 0.6).set_ease(Tween.EASE_IN)
	t.finished.connect(g.queue_free)


## The slug drops out of the sky, afterimages behind it, and shatters on the hit.
func _fall(hit: Vector2) -> void:
	var top := Vector2(hit.x, -slug.get_width() * _px * 2.0)
	var s := _sprite(slug, top, 2.0)
	s.rotation = PI * 0.5  # drawn pointing right; now points down
	var ghosts: Array[Sprite2D] = []
	for i in trail:
		var g := _sprite(slug, top, 2.0)
		g.rotation = PI * 0.5
		g.modulate = Color(0.7, 1.2, 0.9, 0.45 - 0.12 * i)
		ghosts.append(g)
	move_child(s, -1)
	var elapsed := 0.0
	while elapsed < fall_seconds:
		var k: float = elapsed / fall_seconds
		var y: float = lerpf(top.y, hit.y, k * k)  # speeding up as it falls
		s.position = (Vector2(hit.x, y) / _px).round() * _px
		for i in ghosts.size():
			var gy: float = lerpf(top.y, hit.y, maxf(0.0, k - 0.12 * (i + 1)) ** 2)
			ghosts[i].position = (Vector2(hit.x, gy) / _px).round() * _px
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	s.queue_free()
	for g in ghosts:
		g.queue_free()
	if shake.is_valid():
		shake.call(30)
	for tex in bursts:
		var b := _sprite(tex, hit, 3.0)
		await get_tree().create_timer(0.12).timeout
		b.queue_free()
	if not bursts.is_empty():
		var last := _sprite(bursts[-1], hit, 3.0)
		var fade := create_tween()
		fade.tween_property(last, "modulate:a", 0.0, 0.35)
		fade.finished.connect(last.queue_free)
