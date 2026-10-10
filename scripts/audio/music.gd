extends Node
## Hollowtide's music player (Claude, 2026-10-09; Preston: "wire the rest into the game"). One node
## under the scene tree's root, so it survives scene changes (the town, the Hollow and back): each
## place or situation names its track, the player crossfades to it, and jingles (victory, faint,
## evolution, recruit) play over the music while it ducks. It plays on the "Music" bus, so the
## options menu's music volume covers it. Tracks are assets/audio/music/<name>.mp3, all at 432 Hz;
## the music brief (docs/audio/music-brief-2026-10-09.md) says which is which.
##   Music.play(get_tree(), "hollow")      crossfade to a track ("" fades out)
##   Music.jingle(get_tree(), "victory")   play a jingle once over the music

const NODE := "HollowtideMusic"
const DIR := "res://assets/audio/music/%s.mp3"
const BASE_DB := -6.0
const DUCK_DB := -18.0
const FADE := 1.2

static var _inst: Node = null

var current := ""
var want := ""
var pending_jingle := ""
var last_jingle := ""
var _players: Array[AudioStreamPlayer] = []
var _active := 0
var _jingle: AudioStreamPlayer


static func _node(tree: SceneTree) -> Node:
	if _inst == null or not is_instance_valid(_inst):
		_inst = load("res://scripts/audio/music.gd").new()
		_inst.name = NODE
		tree.root.add_child.call_deferred(_inst)   # deferred: a scene may be setting up the root's children
	return _inst


static func play(tree: SceneTree, name: String) -> void:
	var m: Node = _node(tree)
	m.want = name
	if m.is_inside_tree():
		m._apply()


static func jingle(tree: SceneTree, name: String) -> void:
	var m: Node = _node(tree)
	m.pending_jingle = name
	if m.is_inside_tree():
		m._play_jingle()


func _ready() -> void:
	for k in 2:
		var p := AudioStreamPlayer.new()
		p.bus = &"Music"
		p.volume_db = -80.0
		add_child(p)
		_players.append(p)
	_jingle = AudioStreamPlayer.new()
	_jingle.bus = &"Music"
	_jingle.volume_db = BASE_DB
	add_child(_jingle)
	_jingle.finished.connect(_unduck)
	_apply()
	if pending_jingle != "":
		_play_jingle()


func _level() -> float:
	return DUCK_DB if _jingle != null and _jingle.playing else BASE_DB


func _apply() -> void:
	if want == current:
		return
	current = want
	var old: AudioStreamPlayer = _players[_active]
	_active = 1 - _active
	var nu: AudioStreamPlayer = _players[_active]
	var tw := create_tween().set_parallel(true)
	if old.playing:
		tw.tween_property(old, "volume_db", -80.0, FADE)
	if want != "" and ResourceLoader.exists(DIR % want):
		var s: AudioStream = load(DIR % want)
		if "loop" in s:
			s.loop = true
		nu.stream = s
		nu.volume_db = -40.0
		nu.play()
		tw.tween_property(nu, "volume_db", _level(), FADE)
	tw.chain().tween_callback(func() -> void:
		if old != _players[_active]:
			old.stop())


func _play_jingle() -> void:
	var name := pending_jingle
	pending_jingle = ""
	if not ResourceLoader.exists(DIR % name):
		return
	var s: AudioStream = load(DIR % name)
	if "loop" in s:
		s.loop = false
	_jingle.stream = s
	_jingle.play()
	last_jingle = name
	create_tween().tween_property(_players[_active], "volume_db", DUCK_DB, 0.3)


func _unduck() -> void:
	if current != "":
		create_tween().tween_property(_players[_active], "volume_db", BASE_DB, 0.8)
