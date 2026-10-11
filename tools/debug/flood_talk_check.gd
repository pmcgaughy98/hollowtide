extends SceneTree
## The flood talk on the riverbank (Claude, 2026-10-11; Preston: the scene by the riverbank during the flood
## "just needs a bit of refining"). It now reads dialogue/flood_bank.dialogue through Dialogue Manager.
## Checks: narration has no speaker; the choice offers the two starters the soul did not take; picking the
## second makes it the partner, who then speaks with its own name and a face; the talk ends on the
## riverbank with the right party. Windowed it saves a still of each kind of line to
## docs/design/flood-talk-2026-10-11/.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/flood_talk_check.gd

const TeamState := preload("res://scripts/town/team_state.gd")
const UI := preload("res://scripts/ui/ui_style.gd")
const OUT := "res://docs/design/flood-talk-2026-10-11/"
const REC_PACE := 3   # with HT_RECORD set (video takes), each line stays this many times longer
var _pace := REC_PACE if OS.get_environment("HT_RECORD") != "" else 1
var fails := 0


func _initialize() -> void:
	_run.call_deferred()


func _ok(what: String, good: bool) -> void:
	print("%s -> %s" % [what, "ok" if good else "FAIL"])
	if not good:
		fails += 1


func _snap(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	UI.finish_line()
	for k in 3:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


func _frames(n: int) -> void:
	for k in n:
		await process_frame


## Press E until the line is shown whole and moves on.
func _next(p: Node) -> void:
	if _pace > 1 and p.line != null:
		for k in 30 * 8:   # let it type out, as a player would see it
			if UI.line_done(p.line.text):
				break
			await process_frame
		await _frames(50)
	UI.finish_line()
	p.advance()
	await _frames(4)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var p: Node = load("res://scenes/creature_prologue.tscn").instantiate()
	p.hero = 1          # Tallowroot, as if the soul chose it
	p.chosen_by_soul = true
	root.add_child(p)
	current_scene = p
	await _frames(8)
	_ok("Opening line is narration, no speaker (%s)" % p.line.character, p.line != null and p.line.character == "")
	await _snap("1_narration")
	var guard := 0
	while p.line != null and p.line.responses.is_empty() and guard < 10:
		await _next(p)
		guard += 1
	var names: Array = p.line.responses.map(func(r) -> String: return r.text) if p.line != null else []
	_ok("The choice offers the other two starters %s" % str(names), names == ["Kithflare", "Rimefin"])
	await _snap("2_choice")
	p.choice = 1
	await _next(p)
	_ok("Picking the second makes Rimefin the partner (%s)" % p.NAMES[p.partner], p.partner == 2 and p.partner_sprite.visible)
	_ok("The partner speaks with its name and a face (%s, %s)" % [p.line.character, str(p.line.tags)], p.line.character == "Rimefin" and not p.line.tags.is_empty())
	await _snap("3_partner")
	guard = 0
	while p.line != null and guard < 40:
		await _next(p)
		guard += 1
	await _frames(40)
	var party: Array = TeamState.data.get("party", [])
	_ok("The talk ends on the riverbank with Tallowroot and Rimefin (%s, %s)" % [current_scene.scene_file_path.get_file() if current_scene else "none", str(party)],
		current_scene != null and current_scene.scene_file_path.get_file() == "waking_riverbank.tscn" and party == [[1, 0], [2, 0]])
	print("FLOOD TALK: %s" % ("all ok" if fails == 0 else "%d FAILED" % fails))
	quit(1 if fails else 0)
