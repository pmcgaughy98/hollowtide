extends Control
## The faint screen (Claude, 2026-10-12; Preston: "if you die right now you have to restart the game. It should
## bring you back to town like Mystery Dungeon. Also the defeat information screen"). Shape taken from several
## games, nothing copied: Explorers of Sky's faint is a story beat that ends back home with carried things lost (its
## manual: levels and moves stay, half the money and some items go); Shiren's adventure log names the floor and what
## did it; Hades sends you home to people who react to how you died; Spelunky and Slay the Spire sum the run up.
## Ours, in the house voice: react first (the partner, with its portrait), then inform (the defeat panel: where you
## fell, what beat you, the turns, what was lost and what is kept), then E carries the team home. Before the town
## exists in the story (the Hollow Mouth), E takes the team back to the bank for another go instead.
## The dungeon builds `info` (dungeon._faint_screen) and hands over with the team record already taken.
const UI := preload("res://scripts/ui/ui_style.gd")
const TeamState := preload("res://scripts/town/team_state.gd")
const TOWN_SCENE := "res://scenes/hub_town.tscn"
const DUNGEON_SCENE := "res://scenes/dungeon.tscn"
const BOX := Rect2(196, 412, 760, 116)        # the dialogue box, where the dungeon draws its lines
const PANEL := Rect2(206, 96, 740, 430)
const GOLD := Color("f2d27a")
const DIM := Color("c9c2b0")

var info := {}
var page := 0        # 0: the partner's word; 1: the defeat panel
var clock := 0.0
var done := false    # the next scene is on its way


func _ready() -> void:
	set_process_unhandled_input(true)


func _process(delta: float) -> void:
	clock += delta
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	var press: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_E, KEY_ENTER, KEY_SPACE, KEY_Z, KEY_KP_ENTER]:
		press = true
	if press:
		advance()


## A press: finish the line typing out, turn to the panel, then go.
func advance() -> void:
	if done:
		return
	if page == 0:
		if not UI.line_done(_word()):
			UI.finish_line()
			return
		page = 1
		return
	go()


## The partner's word: react before informing (docs/design/dialogue-voice-guide.md).
func _word() -> String:
	var lead := String(info.get("leader", "Hey"))
	if String(info.get("partner", "")) == "":
		return "The lantern goes out. Something carries you back the way you came."
	if info.get("to_town", true):
		return "%s! Hey. Hey, stay with me... okay. Okay. I've got you. We're going home." % lead
	return "%s! Hey... okay, you're still here. I've got you. Back to the bank. We'll go again." % lead


func _draw() -> void:
	draw_rect(Rect2(0, 0, 1152, 648), Color.BLACK)
	if page == 0:
		var partner := String(info.get("partner", ""))
		var tex: Texture2D = UI.dialogue_portrait(String(info.get("partner_form", "")) + ":sad") if partner != "" else null
		UI.dialogue(self, BOX, partner, _word(), tex, clock, 20, "sad")
		return
	UI.panel(self, PANEL)
	var to_town: bool = info.get("to_town", true)
	var x := PANEL.position.x + 36
	var w := PANEL.size.x - 72
	UI.text(self, Vector2(x, PANEL.position.y + 28), "CARRIED HOME" if to_town else "BACK TO THE BANK", 30, GOLD, w, HORIZONTAL_ALIGNMENT_CENTER)
	var y := PANEL.position.y + 92
	for row in _rows():
		var s: String = UI.wrap_text(row[0], w, "body")
		UI.text(self, Vector2(x, y), s, 20, row[1], w)
		y += 30 * (s.count("\n") + 1) + 10
	UI.text(self, Vector2(x, PANEL.end.y - 50), "E   %s" % ("Go home" if to_town else "Try again"), 18, GOLD, w, HORIZONTAL_ALIGNMENT_CENTER)
	UI.next_arrow(self, Vector2(PANEL.end.x - 44, PANEL.end.y - 40), clock)


## The defeat panel's lines, from the dungeon's record of the run.
func _rows() -> Array:
	var rows: Array = []
	rows.append(["%s went down on %s of %s." % [info.get("leader", "The leader"), info.get("floor", "B1F"), info.get("dungeon", "the Hollow")], UI.TEXT])
	rows.append(["Beaten by %s after %d turns. Wild creatures downed on the way: %d." % [info.get("fell_to", "the dark"), int(info.get("turns", 0)), int(info.get("downed", 0))], DIM])
	var lost := "Lost: the bag (%d items)." % int(info.get("lost_items", 0))
	var parcels: Array = info.get("lost_parcels", [])
	if not parcels.is_empty():   # the deliveries went with the bag (R4)
		lost = "Lost: the bag (%d items), with the parcel for %s." % [int(info.get("lost_items", 0)), " and ".join(parcels)]
	var recruits: Array = info.get("lost_recruits", [])
	if not recruits.is_empty():
		lost += " The run's recruits went back into the hollow: %s." % ", ".join(recruits)
	rows.append([lost, Color("e6a07a")])
	var kept := "Kept: levels, moves, your partners, and everything the story gave you."
	if not TeamState.data.get("stored", {}).is_empty():   # the Storage never goes down with the bag (R6)
		kept += " What's in Storage is still there."
	rows.append([kept, Color("a9d48a")])
	return rows


## Home to Highbank with the team record, or back into the dungeon's first floor before the town exists.
func go() -> void:
	done = true
	var next: Node
	if info.get("to_town", true):
		next = load(TOWN_SCENE).instantiate()
		TeamState.give_to(next)
	else:
		next = load(DUNGEON_SCENE).instantiate()
		TeamState.give_to(next)
		next.dungeon = String(info.get("dungeon_id", "mouth"))
		next.return_to_town = bool(info.get("return_to_town", true))
		next.replay = bool(info.get("replay", false))
		next.boss_intro = bool(info.get("boss_intro", true))
	if is_inside_tree() and get_tree().current_scene == self:
		get_tree().change_scene_to_node(next)
	else:
		set_meta("went", "town" if info.get("to_town", true) else "dungeon")   # the checks read this
		next.free()
