extends SceneTree
## The pause menu's field pages (Claude, 2026-10-10): TEAM, BAG, FLOOR and the MESSAGE LOG in the
## Hollow, TEAM and BAG in town, and an item chosen from BAG used as a real turn.
##   Godot --path . --fixed-fps 30 --script res://tools/debug/field_menu_check.gd


func _initialize() -> void:
	_run.call_deferred()


func _frames(n: int) -> void:
	for k in n:
		await process_frame


func _texts(menu: CanvasLayer) -> String:
	var out: Array[String] = []
	_collect(menu.content, out)
	return " | ".join(out)


# Labels and buttons in page order, including the ones inside a portrait row.
func _collect(node: Node, out: Array[String]) -> void:
	for n in node.get_children():
		if n is Label or n is Button:
			out.append(n.text)
		elif n is Container:
			_collect(n, out)


func _run() -> void:
	var bad := 0
	var dg: Node2D = load("res://scenes/dungeon.tscn").instantiate()
	dg.floor_seed = 4242
	dg.poll_input = false
	dg.party = [[0, 0], [1, 0]]
	root.add_child(dg)
	await _frames(4)
	var menu: CanvasLayer = dg.get_node("GamePauseMenu")
	dg.levels[0] = {"lv": 3, "exp": 0}
	menu.open()
	await _frames(2)
	var main := _texts(menu)
	var ok := main.contains("Team") and main.contains("Bag") and main.contains("Floor") and main.contains("Message log") and main.contains("Options") and main.contains("Quit Game")
	print("Hollow main page: %s -> %s" % [main, "ok" if ok else "WRONG"])
	bad += 0 if ok else 1
	for pg in ["team", "bag", "floor", "log"]:
		menu.show_page(pg)
		await _frames(2)
		var t := _texts(menu)
		var want: bool = {"team": t.contains("KITHFLARE   Lv 3") and t.contains("To evolve: Lv 3/5") and t.contains("Moves:"),
			"bag": t.contains("Reedberry x1"), "floor": t.contains("B1F") and t.contains("Lantern"),
			"log": t.contains("B1F")}[pg]
		print("%s: %s -> %s" % [pg, t, "ok" if want else "WRONG"])
		bad += 0 if want else 1
	# A Reedberry chosen from the bag: the menu closes and the leader eats it as a turn.
	var lead: Dictionary = dg.ents[0]
	lead["hp"] = 10
	var turn0: int = dg.turn
	menu.show_page("bag")
	await _frames(2)
	(menu.content.get_node("Use_reedberry") as Button).pressed.emit()
	await _frames(40)
	ok = not paused and lead["hp"] > 10 and not dg.bag.has("reedberry") and dg.turn > turn0
	print("Use from the bag: paused %s, leader 10 -> %d, berries left %d, turn %d -> %d -> %s" % [str(paused), lead["hp"], dg.bag.get("reedberry", 0), turn0, dg.turn, "ok" if ok else "WRONG"])
	bad += 0 if ok else 1
	dg.queue_free()
	await _frames(4)

	# Town: TEAM and BAG read the carried record.
	var TeamState = load("res://scripts/town/team_state.gd")
	TeamState.start([[0, 0], [1, 0]])
	TeamState.data["levels"] = {0: {"lv": 2, "exp": 5}}
	TeamState.data["bag"] = {"lamp_oil": 2}
	var town: Node2D = load("res://scenes/hub_town.tscn").instantiate()
	town.poll_input = false
	root.add_child(town)
	await _frames(4)
	var tm: CanvasLayer = town.get_node("GamePauseMenu")
	tm.open()
	await _frames(2)
	main = _texts(tm)
	tm.show_page("team")
	await _frames(2)
	var team := _texts(tm)
	tm.show_page("bag")
	await _frames(2)
	var bag := _texts(tm)
	ok = not main.contains("Floor") and team.contains("KITHFLARE   Lv 2") and team.contains("TALLOWROOT") and bag.contains("Lamp Oil x2") and bag.contains("used in the Hollow")
	print("Town: main %s; team %s; bag %s -> %s" % [main, team, bag, "ok" if ok else "WRONG"])
	bad += 0 if ok else 1
	tm.resume()
	await _frames(4)
	town.queue_free()
	print("RESULT: %s" % ("field menu works" if bad == 0 else "%d problems" % bad))
	quit()
