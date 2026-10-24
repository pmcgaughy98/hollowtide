extends CanvasLayer
## The end card after the first growth (Claude, 2026-10-22, the factory plan's GS-16 and section 9): the
## street fades to black, the title face names what was played, three lines say what comes next, a thank
## you, and E goes back to Highbank with every Hollow open. It sets the story flag pilot_end_seen, so it
## shows once a save; scripts/town/objective.gd reads the same flag for the line after it.
##   if PilotEnd.due(record): await PilotEnd.run(host)
##   PilotEnd.run(host, true)   # from a black already up (the growth scene's), without fading the street out
## The host is hub_town.gd: its cutscene flag holds the street and the HUD, and SceneKit paces the beats.
## With the host's poll_input off (a check) the card reads itself, faster; a check that turns poll_input off while
## the card waits for its key ends the wait the same way.
## The three lines and the thank-you are proposals for Preston to rewrite. His call 7 is open, so the
## presence's line and the feedback address are left off the card.
## Pass 5 (Claude, 2026-10-24, T3 / LV-07): the words sit in the game's framed panel with the team standing over
## them (the big front idles when every member has one, else everyone's Highbank sprite facing out, at one whole
## scale), and an existing track swells in under it; the street's own track comes back with the street. T1 / LV-06:
## the card can start on the growth scene's black, and its last fade eases out so its final step is a small one.

const UI := preload("res://scripts/ui/ui_style.gd")
const SceneKit := preload("res://scripts/town/scene_kit.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const Lines := preload("res://scripts/creatures/lines.gd")
const CreatureIdle := preload("res://scripts/ui/creature_idle.gd")
const CreatureFinish := preload("res://scripts/arena/creature_finish.gd")
const Music := preload("res://scripts/audio/music.gd")
const CARD_NAME := "PilotEnd"
const CARD_LAYER := 100   # over the pause menu (80) and the evolution scene (95), under toasts (105) and fades (110)
const TITLE := "The first stretch of Hollowtide"
const NEXT := [
	"The Hollow goes deeper than the Warden's pond.",
	"More routes are coming, up and down the river.",
	"And the Wayline crew has a lot more to say.",
]
const THANKS := "Thanks for running it."
const KEY_HINT := "%s  Keep running routes"   # the use key of the device in use: E on a keyboard, A on a pad
const TRACK := "evolution_rising_shimmer"   # swells in under the card (Music crossfades over 1.2 s)
const BOX := Rect2(126, 22, 900, 588)       # the card's panel: the title is 795 px wide in the display face
const TEAM_FEET := 200.0                    # the team stands on this line, inside the panel's top
const TEAM_H := 150.0                       # and no taller than this: 3x for most Highbank sprites, as on the street
const TEAM_W := 820.0                       # nor wider, gaps included
const TEAM_GAP := 28.0

var dark := 0.0     # the black over the street
var shown := 0.0    # how far the card is up: 1 the title, 2 to 4 the three lines, 5 the thanks
var key_a := 0.0    # the key line, last
var fade := 1.0     # the whole card, faded out at the end
var host: Node = null
var team_family := ""   # "idle" (the front idles) or "town" (the Highbank sprites); the probes read it
var team_scale := 1
var _canvas: Node2D     # the black
var _card: Node2D       # the panel and the words
var _team: Node2D       # the team's sprites
var _t := 0.0


## Whether the card is still owed on this record: the first growth has happened and it has not shown.
static func due(rec: Dictionary) -> bool:
	return not bool(rec.get("story", {}).get("pilot_end_seen", false))


static func run(host, from_black := false) -> void:
	if not is_instance_valid(host) or not host.is_inside_tree() or host.has_node(CARD_NAME):
		return
	host.cutscene = true
	var card: CanvasLayer = load("res://scripts/town/pilot_end.gd").new()
	card.name = CARD_NAME
	card.layer = CARD_LAYER
	card.host = host
	if from_black:
		card.dark = 1.0
	host.add_child(card)
	var auto: bool = not bool(host.get("poll_input"))
	var pace := 0.25 if auto else 1.0
	Music.play(host.get_tree(), TRACK)
	if not from_black:
		await card._to("dark", 1.0, 0.8 * pace)
	for k in 5:
		if _gone(card):
			return
		await card._to("shown", float(k + 1), 0.6 * pace)
		if _gone(card):
			return
		await SceneKit.wait(host, (0.5 if k == 0 else 0.25) * pace)
	if _gone(card):
		return
	await card._to("key_a", 1.0, 0.4 * pace)
	if _gone(card):
		return
	if auto:
		await SceneKit.wait(host, 0.5 * pace)
	else:
		await card._wait_for_key()
	if _gone(card) or not is_instance_valid(host) or not host.is_inside_tree():
		return
	var rec: Dictionary = host._record()
	var story: Dictionary = rec.get("story", {})
	story["pilot_end_seen"] = true
	rec["story"] = story
	TeamState.autosave()
	UI.tick("confirm")
	# The street comes back under the card's black: its HUD and its track start now, so nothing appears at once when
	# the black is gone; its keys wait for the black to clear (busy).
	host.cutscene = false
	host.set("busy", true)
	if host.has_method("_music_update"):
		host._music_update()
	await card._to("fade", 0.0, 0.6 * pace, true)
	if is_instance_valid(host):
		host.set("busy", false)
	if not _gone(card):
		card.queue_free()


## The card was freed with its host (a check that frees the town mid-card): stop quietly.
static func _gone(card: Node) -> bool:
	return not is_instance_valid(card) or not card.is_inside_tree()


func _ready() -> void:
	_canvas = Node2D.new()
	_canvas.draw.connect(_draw_black)
	add_child(_canvas)
	_card = Node2D.new()
	_card.draw.connect(_draw_card)
	add_child(_card)
	_team = Node2D.new()
	_team.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_team)
	_make_team()
	_apply_alpha()


func _process(delta: float) -> void:
	_t += delta
	if team_family == "idle":
		for s in _team.get_children():
			s.texture = CreatureIdle.frame_at(s.get_meta("frames"), _t)
	_apply_alpha()
	_canvas.queue_redraw()
	_card.queue_redraw()


## The panel and the team come up with the title and go with the card.
func _apply_alpha() -> void:
	var a := clampf(shown, 0.0, 1.0) * fade
	_card.modulate.a = a
	_team.modulate.a = a


## The team over the words: each member's front idle when every one has one, else each one's Highbank sprite facing
## out (its dungeon sprite when it has no Highbank one), one family for all, at the one whole scale that fits them in
## TEAM_H by TEAM_W, centred, feet on TEAM_FEET. Each wears the house finish, as every creature on screen does.
func _make_team() -> void:
	var forms: Array = []
	var party: Variant = host.get("party") if is_instance_valid(host) else null
	if party is Array:
		for m in party:
			forms.append(String(Lines.of(int(m[0]))["forms"][int(m[1])][0]))
	if forms.is_empty():
		return
	var gaps := TEAM_GAP * (forms.size() - 1)
	team_family = "idle"
	var sets := _team_sets(forms, "idle")   # per form: [frames, drawn box]
	if sets.is_empty() or _tallest(sets) > TEAM_H or _width(sets) > TEAM_W - gaps:
		team_family = "town"
		sets = _team_sets(forms, "town")
	team_scale = clampi(mini(floori(TEAM_H / maxf(1.0, _tallest(sets))), floori((TEAM_W - gaps) / maxf(1.0, _width(sets)))), 1, 3)
	var total := 0.0
	for s in sets:
		total += s[1].size.x * team_scale
	total += TEAM_GAP * (sets.size() - 1)
	var x := 576.0 - total * 0.5
	for i in sets.size():
		var frames: Array = sets[i][0]
		var box: Rect2i = sets[i][1]
		if frames.is_empty():
			continue
		var sp := Sprite2D.new()
		sp.texture = frames[0]
		sp.centered = false
		sp.scale = Vector2.ONE * team_scale
		# The drawn box's bottom left on (x, TEAM_FEET), on whole pixels.
		sp.position = Vector2(x, TEAM_FEET).round() - Vector2(box.position.x, box.end.y) * team_scale
		sp.set_meta("frames", frames)
		CreatureFinish.apply(sp, false, forms[i])
		_team.add_child(sp)
		x += box.size.x * team_scale + TEAM_GAP


## [frames, drawn box] for each form in one family: "idle" ([] unless every form has a front idle) or "town".
func _team_sets(forms: Array, family: String) -> Array:
	var out: Array = []
	for f in forms:
		var frames: Array = CreatureIdle.frames(f) if family == "idle" else _town_still(f)
		if family == "idle" and frames.is_empty():
			return []
		out.append([frames, CreatureIdle.box(frames) if not frames.is_empty() else Rect2i()])
	return out


func _tallest(sets: Array) -> float:
	var h := 0.0
	for s in sets:
		h = maxf(h, s[1].size.y)
	return h


func _width(sets: Array) -> float:
	var w := 0.0
	for s in sets:
		w += s[1].size.x
	return w


## A form's Highbank sprite facing out (the town set's "s"), else its dungeon one; [] when it has neither.
func _town_still(form: String) -> Array:
	for path in ["res://assets/sprites/arena/%s/town/s.png", "res://assets/sprites/arena/%s/dungeon/s.png"]:
		if ResourceLoader.exists(path % form):
			return [load(path % form)]
	return []


## Tween one of the card's values; returns the finished signal to await. Halved under reduce motion. `ease_out` slows
## it into its end, so the last frame's step is the smallest (the card's last fade, T1).
func _to(prop: String, to: float, secs: float, ease_out := false) -> Signal:
	var tw := create_tween()
	var step := tw.tween_property(self, prop, to, UI.motion_secs(secs))
	if ease_out:
		step.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	return tw.finished


## A fresh press of E, J, Enter or the accept button (one still held from closing the growth's line does
## not count), and none while the pause menu is up. The keys are actions since 2026-10-23 (Claude, factory pass
## 2): the line's advance keys (E, J, Enter, Space; A or X on a pad) and Godot's accept. A host whose poll_input
## goes off meanwhile (a check taking over) ends the wait too.
const KEYS := [&"confirm", &"attack", &"interact", &"ui_accept"]


func _wait_for_key() -> void:
	var was := true
	while is_inside_tree():
		await get_tree().process_frame
		if not is_inside_tree():
			return
		if is_instance_valid(host) and not bool(host.get("poll_input")):
			return
		if get_tree().paused:
			continue
		var now: bool = KEYS.any(func(a: StringName) -> bool: return UI.held(a))
		if now and not was:
			return
		was = now


func _draw_black() -> void:
	var view: Vector2 = _canvas.get_viewport_rect().size
	_canvas.draw_rect(Rect2(Vector2.ZERO, view), Color(0, 0, 0, dark * fade))


## The panel and its words. The node's own alpha brings the panel up with the title and takes it down with the card;
## each line after the title comes up in its turn on top of that.
func _draw_card() -> void:
	var c := _card
	var w := BOX.size.x
	var left := BOX.position.x
	UI.panel(c, BOX, 0.95)
	UI.say(c, Vector2(left, 268), TITLE, "display", UI.EDGE_LIGHT, w, HORIZONTAL_ALIGNMENT_CENTER)
	c.draw_rect(Rect2(Vector2(576 - 180, 288), Vector2(360, 2)), Color(UI.EDGE, 0.8))
	for k in NEXT.size():
		var la := clampf(shown - 1.0 - k, 0.0, 1.0)
		if la > 0.0:
			UI.say(c, Vector2(left, 348 + 44 * k), NEXT[k], "story", Color(UI.TEXT, la), w, HORIZONTAL_ALIGNMENT_CENTER)
	var ta := clampf(shown - 4.0, 0.0, 1.0)
	if ta > 0.0:
		UI.say(c, Vector2(left, 500), THANKS, "story", Color(UI.EDGE_LIGHT, ta), w, HORIZONTAL_ALIGNMENT_CENTER)
	if key_a > 0.0:
		UI.say(c, Vector2(left, 570), KEY_HINT % SceneKit.use_key(), "label", Color(UI.MUTED, key_a), w, HORIZONTAL_ALIGNMENT_CENTER)
