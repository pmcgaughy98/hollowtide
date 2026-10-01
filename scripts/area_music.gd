class_name AreaMusic
extends AudioStreamPlayer

## An area's looping music (Route 1's "Two-Note Call", Preston 2026-09-29).
## It fades in when the area loads, fades out and pauses when a battle starts
## (BattleScreen calls the "area_music" group), and picks up where it left off
## when the battle ends. Plays on the Music bus, which ducks under attack sounds.

## The level under sound effects, in decibels.
@export var level_db: float = -10.0
@export var fade_seconds: float = 0.8

var _tween: Tween


func _ready() -> void:
	# Battles pause the rest of the game; the music keeps running so its fades
	# still happen (otherwise a queued "pause" fired after the battle and left
	# the route silent).
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group(&"area_music")
	bus = &"Music"
	if stream == null:
		return
	if "loop" in stream:
		stream.loop = true
	volume_db = -40.0
	play()
	_fade_to(level_db)


func battle_began() -> void:
	var t := _fade_to(-40.0)
	t.tween_callback(func() -> void: stream_paused = true)


func battle_ended() -> void:
	stream_paused = false
	_fade_to(level_db)


func _fade_to(db: float) -> Tween:
	if _tween != null and _tween.is_valid():
		_tween.kill()  # a fade still running must not undo the new one
	_tween = create_tween()
	_tween.tween_property(self, "volume_db", db, fade_seconds)
	return _tween
