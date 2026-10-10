extends SceneTree
## The soul prologue (Claude, 2026-10-10): it plays through by itself (auto), the soul chooses
## Tallowroot, and Codex's prologue opens on waking as Tallowroot with no starter buttons. Stills of
## the confused soul, the river, the choice and the flash in a windowed run.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/soul_prologue_check.gd

const OUT := "res://docs/design/soul-prologue-2026-10-10/"


func _initialize() -> void:
	_run.call_deferred()


func _snap(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var soul: Node2D = load("res://scenes/soul_prologue.tscn").instantiate()
	soul.auto = true
	soul.auto_pick = 1
	root.add_child(soul)
	var taken := {}
	var t0 := Time.get_ticks_msec()
	while not soul.has_meta("handoff") and Time.get_ticks_msec() - t0 < 120000:
		await process_frame
		var key := "%s_%d" % [soul.stage, soul.line]
		if not taken.has(key) and key in ["talk_0", "talk_3", "talk_6", "choose_8", "after_0", "fly_2"]:
			taken[key] = true
			for k in 25:
				await process_frame
			await _snap(key)
	var next: Node = soul.get_meta("handoff", null)
	var ok_hand: bool = next != null and next.hero == 1 and next.chosen_by_soul
	print("Hand-over: chose %s, prologue hero %s, starter already chosen %s -> %s" % [str(soul.chosen), str(next.hero if next else -1), str(next.chosen_by_soul if next else false), "ok" if ok_hand else "WRONG"])
	soul.queue_free()
	root.add_child(next)
	for k in 30:
		await process_frame
	await _snap("wake")
	var buttons: int = next.cards.size()
	var ok_wake: bool = String(next.title.text).contains("You wake beneath the riverbank") and buttons == 0 and String(next.prose.text).contains("Roots")
	print("Waking: '%s' / '%s', starter buttons %d -> %s" % [next.title.text, next.prose.text.replace("\n", " "), buttons, "ok" if ok_wake else "WRONG"])
	print("RESULT: %s" % ("the soul prologue works" if ok_hand and ok_wake else "problems"))
	quit()
