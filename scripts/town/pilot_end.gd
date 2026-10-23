extends CanvasLayer
## The end card after the first growth (Claude, 2026-10-22, the factory plan's GS-16 and section 9): the
## street fades to black, the title face names what was played, three lines say what comes next, a thank
## you, and E goes back to Highbank with every Hollow open. It sets the story flag pilot_end_seen, so it
## shows once a save; scripts/town/objective.gd reads the same flag for the line after it.
##   if PilotEnd.due(record): await PilotEnd.run(host)
## The host is hub_town.gd: its cutscene flag holds the street and the HUD, and SceneKit paces the beats.
## With the host's poll_input off (a check) the card reads itself, faster.
## The three lines and the thank-you are proposals for Preston to rewrite. His call 7 is open, so the
## presence's line and the feedback address are left off the card.

const UI := preload("res://scripts/ui/ui_style.gd")
const SceneKit := preload("res://scripts/town/scene_kit.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const CARD_NAME := "PilotEnd"
const CARD_LAYER := 100   # over the pause menu (80) and the evolution scene (95), under toasts (105) and fades (110)
const TITLE := "The first stretch of Hollowtide"
const NEXT := [
	"The Hollow goes deeper than the Warden's pond.",
	"More routes are coming, up and down the river.",
	"And the Wayline crew has a lot more to say.",
]
const THANKS := "Thanks for running it."
const KEY_HINT := "E  Keep running routes"

var dark := 0.0     # the black over the street
var shown := 0.0    # how far the card is up: 1 the title, 2 to 4 the three lines, 5 the thanks
var key_a := 0.0    # the key line, last
var fade := 1.0     # the whole card, faded out at the end
var _canvas: Node2D


## Whether the card is still owed on this record: the first growth has happened and it has not shown.
static func due(rec: Dictionary) -> bool:
	return not bool(rec.get("story", {}).get("pilot_end_seen", false))


static func run(host) -> void:
	if not is_instance_valid(host) or not host.is_inside_tree() or host.has_node(CARD_NAME):
		return
	host.cutscene = true
	var card: CanvasLayer = load("res://scripts/town/pilot_end.gd").new()
	card.name = CARD_NAME
	card.layer = CARD_LAYER
	host.add_child(card)
	var auto: bool = not bool(host.get("poll_input"))
	var pace := 0.25 if auto else 1.0
	await card._to("dark", 1.0, 0.8 * pace)
	for k in 5:
		await card._to("shown", float(k + 1), 0.6 * pace)
		await SceneKit.wait(host, (0.5 if k == 0 else 0.25) * pace)
	await card._to("key_a", 1.0, 0.4 * pace)
	if auto:
		await SceneKit.wait(host, 0.5 * pace)
	else:
		await card._wait_for_key()
	if not is_instance_valid(host) or not host.is_inside_tree():
		return
	var rec: Dictionary = host._record()
	var story: Dictionary = rec.get("story", {})
	story["pilot_end_seen"] = true
	rec["story"] = story
	TeamState.autosave()
	UI.tick("confirm")
	await card._to("fade", 0.0, 0.6 * pace)
	card.queue_free()
	host.cutscene = false


func _ready() -> void:
	_canvas = Node2D.new()
	_canvas.draw.connect(_draw_card)
	add_child(_canvas)


func _process(_delta: float) -> void:
	_canvas.queue_redraw()


## Tween one of the card's values; returns the finished signal to await. Halved under reduce motion.
func _to(prop: String, to: float, secs: float) -> Signal:
	var tw := create_tween()
	tw.tween_property(self, prop, to, UI.motion_secs(secs))
	return tw.finished


## A fresh press of E, J, Enter or the accept button (one still held from closing the growth's line does
## not count), and none while the pause menu is up.
func _wait_for_key() -> void:
	var was := true
	while is_inside_tree():
		await get_tree().process_frame
		if get_tree().paused:
			continue
		var now := Input.is_key_pressed(KEY_E) or Input.is_key_pressed(KEY_J) or Input.is_key_pressed(KEY_ENTER) or Input.is_action_pressed("ui_accept")
		if now and not was:
			return
		was = now


func _draw_card() -> void:
	var c := _canvas
	var view: Vector2 = c.get_viewport_rect().size
	c.draw_rect(Rect2(Vector2.ZERO, view), Color(0, 0, 0, dark * fade))
	var w := 1152.0   # the HUD's frame, as hub_town.gd draws it
	var a := clampf(shown, 0.0, 1.0) * fade
	if a > 0.0:
		UI.say(c, Vector2(0, 214), TITLE, "display", Color(UI.EDGE_LIGHT, a), w, HORIZONTAL_ALIGNMENT_CENTER)
		c.draw_rect(Rect2(Vector2(w * 0.5 - 180, 240), Vector2(360, 2)), Color(UI.EDGE, a * 0.8))
	for k in NEXT.size():
		var la := clampf(shown - 1.0 - k, 0.0, 1.0) * fade
		if la > 0.0:
			UI.say(c, Vector2(0, 318 + 44 * k), NEXT[k], "story", Color(UI.TEXT, la), w, HORIZONTAL_ALIGNMENT_CENTER)
	var ta := clampf(shown - 4.0, 0.0, 1.0) * fade
	if ta > 0.0:
		UI.say(c, Vector2(0, 498), THANKS, "story", Color(UI.EDGE_LIGHT, ta), w, HORIZONTAL_ALIGNMENT_CENTER)
	if key_a > 0.0:
		UI.say(c, Vector2(0, 598), KEY_HINT, "label", Color(UI.MUTED, key_a * fade), w, HORIZONTAL_ALIGNMENT_CENTER)
