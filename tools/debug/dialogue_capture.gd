extends SceneTree
## Stills of the pixel-frame dialogue (Claude, 2026-10-10): the boss scene's two speakers with their
## portraits, and the soul prologue's unseen voice and choice cards. Windowed only.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/dialogue_capture.gd

const OUT := "res://docs/ui/dialogue-2026-10-10/"


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))
	print("saved ", name)


func _run() -> void:
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 7
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0], [10, 0]]
	dg.dungeon = "hollow"   # the Warden is the Hollow's boss (2026-10-10)
	dg.boss_intro = false   # straight to the talk; the entrance has its own capture (boss_intro_capture.gd)
	root.add_child(dg)
	await _frames(10)
	dg.floor_n = dg.floors() + 1
	dg._build_floor(true)
	await _frames(60)
	print("talk: ", dg.talk)
	await _snap("boss_partner")
	dg.act_talk()
	await _frames(20)
	await _snap("boss_warden")
	dg.queue_free()
	await _frames(2)
	var soul: Node = load("res://scenes/soul_prologue.tscn").instantiate()
	root.add_child(soul)
	await _frames(240)
	await _snap("soul_talk")
	soul.stage = "choose"
	soul.line = soul.LINES.size() - 1
	await _frames(30)
	await _snap("soul_choose")
	quit()
