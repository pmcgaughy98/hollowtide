extends SceneTree
var bad = 0
var checks = 0
var prefix = "D:/dev/hollowtide-bag-finish-20261010/"
func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
    for i in n: await process_frame
func check(ok: bool, what: String) -> void:
    checks += 1
    bad += 0 if ok else 1
    print("%s %s" % ["PASS" if ok else "FAIL",what])
func shot(label: String) -> void:
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(prefix + label + ".png")
func press_action(action: String) -> void:
    var e = InputEventAction.new()
    e.action = action
    e.pressed = true
    Input.parse_input_event(e)
    await frames(1)
    e = InputEventAction.new()
    e.action = action
    Input.parse_input_event(e)
    await frames(2)
func click(button: Button) -> void:
    var e = InputEventMouseButton.new()
    e.position = button.get_global_rect().get_center()
    e.button_index = MOUSE_BUTTON_LEFT
    e.pressed = true
    Input.parse_input_event(e)
    await frames(3)
    e = InputEventMouseButton.new()
    e.position = button.get_global_rect().get_center()
    e.button_index = MOUSE_BUTTON_LEFT
    Input.parse_input_event(e)
    await frames(40)
func run() -> void:
    var dg = load("res://scenes/dungeon.tscn").instantiate()
    dg.floor_seed = 4242
    dg.poll_input = false
    dg.party = [[0,0],[1,0]]
    root.add_child(dg)
    await frames(8)
    dg.bag = {"reedberry":3,"lamp_oil":2,"river_stone":5,"rally_seed":1}
    var initial_bag: Dictionary = dg.bag.duplicate(true)
    var turn0: int = dg.turn
    var menu = dg.get_node("GamePauseMenu")
    menu.open()
    await frames(6)
    await shot("main-after")
    menu.show_page("bag")
    await frames(6)
    var view = menu.content.get_node("BagPage")
    var panel: Control = menu.overlay.get_node("PausePanel")
    check(panel.get_global_rect().end.y <= 648 and panel.get_global_rect().end.x <= 1152,"Bag panel fits viewport")
    check(view.selected_kind == "reedberry","first item selected")
    check(view.portrait.texture.get_size() == Vector2(96,96),"detail icon at native 3x")
    check(view.effect.text == dg.item_info("reedberry")["what"],"effect comes from live rules")
    check(menu.controls.size() == 5,"four items and Back retain focus controls")
    await shot("bag-after")
    await press_action("ui_up")
    check(root.gui_get_focus_owner().name == "Back","D-pad up wraps to Back")
    await press_action("ui_down")
    check(root.gui_get_focus_owner().name == "Use_reedberry","D-pad down wraps to first item")
    await press_action("ui_down")
    check(view.selected_kind == "lamp_oil","keyboard changes item detail")
    var hover = InputEventMouseMotion.new()
    hover.position = view.rows.get_node("Use_river_stone").get_global_rect().get_center()
    Input.parse_input_event(hover)
    await frames(3)
    check(view.selected_kind == "river_stone","mouse hover changes detail")
    check(dg.bag == initial_bag and dg.turn == turn0,"browsing consumes no items or turns")
    dg.ents[0]["hp"] = 10
    await click(view.rows.get_node("Use_reedberry"))
    check(not paused and not menu.overlay.visible,"actual mouse use closes pause menu")
    check(dg.bag.get("reedberry",0) == 2 and dg.ents[0]["hp"] > 10,"one berry used and leader healed")
    check(dg.turn == turn0+1,"mouse use spends exactly one turn")
    # Enough move scrolls to need scrolling, then open the existing teaching panel.
    var moves: Dictionary = load("res://scripts/arena/arena_prototype.gd").MOVES
    dg.bag = {}
    for move in moves.keys().slice(0,16): dg.bag["scroll:"+move] = 1
    var saved: Dictionary = dg.bag.duplicate(true)
    menu.open()
    menu.show_page("bag")
    await frames(6)
    view = menu.content.get_node("BagPage")
    var last: Button = menu.controls[menu.controls.size()-2]
    last.grab_focus()
    await frames(5)
    check(view.scroll.scroll_vertical > 0,"focus scrolls long inventory into view")
    check(view.scroll.get_global_rect().encloses(last.get_global_rect()),"last item is fully visible")
    check(panel.get_global_rect().end.y <= 648,"long inventory stays within viewport")
    check(dg.bag == saved,"focus scrolling preserves inventory")
    await shot("bag-scrolls")
    var all_names_fit = true
    var all_effects_fit = true
    for move in moves:
        dg.bag = {"scroll:"+move:1}
        menu.show_page("bag")
        await frames(3)
        var detail = menu.content.get_node("BagPage")
        all_names_fit = all_names_fit and panel.get_global_rect().end.y <= 648
        all_effects_fit = all_effects_fit and detail.effect.get_global_rect().end.y <= detail.instruction.get_global_rect().position.y
    check(all_names_fit,"all move-scroll names fit the detail panel")
    check(all_effects_fit,"all scroll effects clear the action hint")
    dg.bag = saved
    menu.show_page("bag")
    await frames(5)
    var first: Button = menu.controls[0]
    first.grab_focus()
    await frames(5)
    turn0 = dg.turn
    await click(first)
    check(dg.teach_kind == saved.keys()[0] and not paused,"scroll opens existing learning panel")
    check(dg.turn == turn0 and dg.bag == saved,"reading scroll preserves its existing free preview rule")
    dg.queue_free()
    await frames(12)
    var Team = load("res://scripts/town/team_state.gd")
    Team.start([[0,0],[1,0]])
    Team.data["bag"] = {"lamp_oil":2,"scroll:fireball":1}
    var town = load("res://scenes/hub_town.tscn").instantiate()
    town.poll_input = false
    root.add_child(town)
    await frames(8)
    menu = town.get_node("GamePauseMenu")
    menu.open()
    menu.show_page("bag")
    await frames(6)
    view = menu.content.get_node("BagPage")
    await click(view.rows.get_node("Use_scroll_fireball"))
    check(view.item_name.text == "Ember Shot Scroll","town scroll gets proper move name")
    check(view.instruction.text == "Items are used in the Hollow.","town explains use location")
    check(paused and Team.data["bag"] == {"lamp_oil":2,"scroll:fireball":1},"town click is read only")
    await shot("bag-town")
    Team.data["bag"] = {}
    menu.show_page("bag")
    await frames(6)
    view = menu.content.get_node("BagPage")
    check(menu.controls.size() == 1 and root.gui_get_focus_owner().name == "Back","empty Bag focuses Back")
    check(view.item_name.text == "Nothing carried" and not view.portrait.visible,"empty state has no false item")
    panel = menu.overlay.get_node("PausePanel")
    check(panel.get_global_rect().encloses(view.get_global_rect()) and panel.get_global_rect().encloses(menu.controls[0].get_global_rect()),"empty contents stay inside outer frame")
    await shot("bag-empty")
    Team.data["bag"] = {"unrecognized_test_item":1}
    menu.show_page("bag")
    await frames(6)
    view = menu.content.get_node("BagPage")
    check(view.portrait.texture == null and view.effect.text == "No description available.","missing metadata and icon stay safe")
    menu.show_page("main")
    await frames(6)
    panel = menu.overlay.get_node("PausePanel")
    check(panel.position == Vector2(316,58) and panel.size.x < 600,"Back restores original menu width")
    menu.resume()
    await frames(5)
    town.queue_free()
    await frames(12)
    print("RESULT %d/%d passed" % [checks-bad,checks])
    quit(0 if bad == 0 else 1)
