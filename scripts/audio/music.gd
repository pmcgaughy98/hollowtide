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
## Bursts (Claude, 2026-10-26, L7-26): a floor change and its scene could ask for two tracks in one beat (deep_hollow
## then hollow four frames apart, crew_theme and boss_scene in one frame), and both started. A track asked for now
## waits this long; one asked for in that time takes its place, so only the last of a burst starts. A request for
## the track playing or waiting changes nothing. The town's street wait (hub_town.gd MUSIC_SETTLE) comes before this.
const COALESCE := 0.25
const CLOSE_GRACE_MS := 40   # release()'s wait on a window close (Claude, 2026-10-26, pass 8 U7)

static var _inst: Node = null
## Work other scripts leave running on threads when the game closes (Claude, 2026-10-27, pass 9 T1 for A9-01 / H9-12).
## Highbank's warm-up paints rooms and the walkway on worker threads and reads scenes on loader threads after the
## arrival, and a quit during it cut that work off: a window close 0.4 s after arriving printed 7 ERROR lines (scripts
## read half way), and a quit 9 s after arriving ended with exit 139 (a worker still painting as the engine shut down).
## A script with such work hands keep_for a Callable: called with false it says whether the work still runs, called
## with true it waits for all of it, there and then. `closing` (set by release) tells those scripts to start nothing new.
static var closing := false
static var _work: Array[Callable] = []

var current := ""   # the track playing, or the one waiting to start (the checks read it)
var want := ""      # the last track asked for (the town's street music reads it)
var pending_jingle := ""
var last_jingle := ""
var _players: Array[AudioStreamPlayer] = []
var _active := 0
var _jingle: AudioStreamPlayer
var _started := ""   # the track the players last crossfaded to
var _wait := -1.0    # seconds before `current` starts; below 0 when nothing waits


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
		m._ask()


static func jingle(tree: SceneTree, name: String) -> void:
	var m: Node = _node(tree)
	m.pending_jingle = name
	if m.is_inside_tree():
		m._play_jingle()


## Everything let go before the game closes (Claude, 2026-10-26, pass 8 U7 for LH8-10). A verbose quit from the crew den
## (Rootbank Warren's boss floor, the pause menu opened and closed) listed what Godot still held at exit: 11 instances
## and 5 resources, every one a sound still playing (crew_theme.mp3, floor_arrive.wav, shove.wav, menu_close.wav,
## text_blip_0.wav) or its playback. No texture was held. A player stopped first lets go of its stream, so this stops
## every player under the root, then empties the UI's static caches of sounds and pictures (ui_style.gd: the ticks,
## the blips, the icons, the frames, the bar styles and the 3x faces). Called on the window's close request
## (_notification) and by the pause menu's Quit just before get_tree().quit().
static func release(tree: SceneTree) -> void:
	closing = true   # no new thread work after this (T1)
	if tree == null or tree.root == null:
		return
	for kind in ["AudioStreamPlayer", "AudioStreamPlayer2D", "AudioStreamPlayer3D"]:
		for p: Node in tree.root.find_children("*", kind, true, false):
			p.stop()
			p.set("stream", null)
	var ui := preload("res://scripts/ui/ui_style.gd")
	ui.closing = true   # no blip or tick after this
	for cache: Variant in [ui._ticks, ui._blips, ui._icons, ui._boxes, ui._bar_styles, ui._faces3x]:
		cache.clear()


## Thread work to be waited for before the game closes (T1). Kept once per Callable; the node is made if it is not yet,
## since it is the one that hears the window's close and the tree's end. Hand it a script's static method, never a
## lambda: a lambda kept here outlives its script when that script is let go (the town's, in a dungeon), and the engine
## crashed freeing it at exit (exit 139).
static func keep_for(tree: SceneTree, work: Callable) -> void:
	if tree != null:
		_node(tree)
	if not _work.has(work):
		_work.append(work)


## Whether any kept thread work still runs (the pause menu's Quit waits a frame at a time while it does).
static func working() -> bool:
	for w in _work:
		if w.is_valid() and bool(w.call(false)):
			return true
	return false


## Wait for all kept thread work, on this thread, now: the last step before the game ends.
static func finish_work() -> void:
	for w in _work:
		if w.is_valid():
			w.call(true)
	_work.clear()   # all waited for; nothing is held into the engine's exit


## The window's close button: the tree quits at the end of this frame, so the audio thread is given a moment to mix the
## stopped sounds out before the frame's audio update lets them go (no frame can be waited for here). Thread work still
## running is waited for first (T1), and on any other way out (a check's quit, the title's Quit) as the tree lets this
## node go, so no worker or loader thread is cut off by the engine's exit.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and is_inside_tree():
		release(get_tree())
		finish_work()
		OS.delay_msec(CLOSE_GRACE_MS)
	elif what == NOTIFICATION_EXIT_TREE:
		# The tree is ending some other way (a check's or a probe's quit(), a Quit that did not release first): the same
		# release and wait. A quit 1.1 s after arriving left highbank.mp3 held at exit ("1 resources still in use").
		if not closing:
			release(get_tree())
			OS.delay_msec(CLOSE_GRACE_MS)
		finish_work()


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
	_ask()
	if pending_jingle != "":
		_play_jingle()


func _level() -> float:
	return DUCK_DB if _jingle != null and _jingle.playing else BASE_DB


## A request: the track waits COALESCE seconds from the last one asked for, unless it is already the one playing.
func _ask() -> void:
	if want == current:
		return   # playing, or already waiting
	current = want
	_wait = -1.0 if current == _started else COALESCE   # asked back to the track still playing: nothing to start


func _process(delta: float) -> void:
	if _wait < 0.0:
		return
	_wait -= delta
	if _wait <= 0.0:
		_wait = -1.0
		_apply()


func _apply() -> void:
	if current == _started:
		return
	_started = current
	var old: AudioStreamPlayer = _players[_active]
	_active = 1 - _active
	var nu: AudioStreamPlayer = _players[_active]
	var tw := create_tween().set_parallel(true)
	if old.playing:
		tw.tween_property(old, "volume_db", -80.0, FADE)
	if _started != "" and ResourceLoader.exists(DIR % _started):
		var s: AudioStream = load(DIR % _started)
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
	if _started != "":
		create_tween().tween_property(_players[_active], "volume_db", BASE_DB, 0.8)
