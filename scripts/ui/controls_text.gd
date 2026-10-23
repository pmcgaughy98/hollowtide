extends RefCounted
## The controls as the player reads them (Claude, 2026-10-22, the factory contract): one copy for the pause
## menu's Controls page and the opening's help, so the two never drift. The three headed groups are the
## opening's help page (creature_opening.gd) plus the run and message keys added on 2026-10-14.
##   const ControlsText := preload("res://scripts/ui/controls_text.gd")
##   for g in ControlsText.GROUPS: UI.say(self, pos, g["head"], "label", UI.EDGE_LIGHT) ...
## No class_name on purpose: a new global class needs the editor's class cache rebuilt, and the checks run
## headless without it.

const TOWN := {
	"head": "IN HIGHBANK",
	"lines": [
		"WASD / arrows: move. E / J / Enter: use a place.",
	],
}
const HOLLOW := {
	"head": "IN A HOLLOW",
	"lines": [
		"WASD / arrows: step. Shift: turn. J / click: attack. 1-3: moves. I: bag. Z: rest. E: stairs.",
		"Ctrl + direction: run. L: messages.",
		"T: team orders. Tab: autopilot. Y / N: answer a recruit.",
	],
}
const MENUS := {
	"head": "YOUR MENUS",
	"lines": [
		"P / controller Start: pause. Arrows / D-pad: move focus. Enter / A: choose. Esc / B: back. Field movement uses the keyboard.",
	],
}
const GROUPS := [TOWN, HOLLOW, MENUS]
## The honest line over the groups and the rule under IN A HOLLOW (Claude, 2026-10-22, LP-03: GS-05, W07).
## The pause menu's Controls page draws both; the opening's help can draw them the same way.
const NOTE := "Keyboard. A controller works in the menus only for now."
const TURNS := "Fights in a Hollow are turn-based."
