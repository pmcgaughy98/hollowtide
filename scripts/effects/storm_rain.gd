extends Node2D
## The flood's rain, the same driven, slantwise rain as the storm opening (storm_open.gd), for the scenes that
## follow it: the riverbank talk and the Hollow rising (Preston, 2026-10-11: "it should still be raining ...
## that's why they have to go in there in the first place"). Drawn in a 384x216 view, with its rain loop.
## Add it as a child of the view, above the ground and the actors.

const SFX := "res://assets/audio/sfx/story/storm_rain.wav"
const SIZE := Vector2(384, 216)

var drops := 260          # a little lighter than the storm opening's 340, so the faces still read
var sound_db := -12.0     # under the dialogue blips
var reduce_motion := false
var _drops: Array = []    # {p, len}
var _splashes: Array = [] # {p, life}
var _wind := 1.0
var _t := 0.0
var _player: AudioStreamPlayer


func _ready() -> void:
	z_index = 100
	for k in drops:
		_drops.append({"p": Vector2(randf() * (SIZE.x + 36.0) - 20.0, randf() * SIZE.y), "len": 4.0 + randf() * 4.0})
	if ResourceLoader.exists(SFX):
		var stream: AudioStream = load(SFX)
		if stream is AudioStreamWAV:
			stream = stream.duplicate()
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			stream.loop_end = int(stream.get_length() * stream.mix_rate)
		_player = AudioStreamPlayer.new()
		_player.stream = stream
		_player.volume_db = sound_db
		_player.bus = &"SFX"   # a world sound: the effects slider, not Master (Claude, 2026-10-22)
		add_child(_player)
		_player.play()


func _process(delta: float) -> void:
	_t += delta
	_wind = lerpf(_wind, 1.0 + 0.3 * sin(_t * 0.7), delta)
	var speed := 0.5 if reduce_motion else 1.0
	for d in _drops:
		d["p"] += Vector2(-110.0 * _wind, 330.0) * delta * speed
		if d["p"].y > SIZE.y or d["p"].x < -20.0:
			if d["p"].y > 90.0 and randf() < 0.35:
				_splashes.append({"p": Vector2(d["p"].x, minf(d["p"].y, SIZE.y - 2.0)), "life": 0.18})
			d["p"] = Vector2(randf() * (SIZE.x + 56.0), -randf() * 30.0)
	for s in _splashes:
		s["life"] -= delta
	_splashes = _splashes.filter(func(s: Dictionary) -> bool: return s["life"] > 0.0)
	queue_redraw()


func _draw() -> void:
	var slant := Vector2(-110.0 * _wind, 330.0).normalized()
	for d in _drops:
		var a: Vector2 = d["p"]
		draw_line(a.round(), (a - slant * float(d["len"])).round(), Color(0.86, 0.92, 1.0, 0.7), 1.0)
	for s in _splashes:
		draw_rect(Rect2(s["p"].round() + Vector2(-1, 0), Vector2(3, 1)), Color(0.85, 0.9, 1.0, 0.5))
