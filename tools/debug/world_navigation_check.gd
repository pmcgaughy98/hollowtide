extends "res://tools/debug/first_morning_check.gd"
func _run() -> void:
    root.size = Vector2i(1152,648)
    root.content_scale_size = Vector2i(1152,648)
    var party: Node = root.get_node("PlayerParty")
    party.caught.clear()
    party.active_slot = -1
    journey = load("res://scenes/world_journey.tscn").instantiate()
    journey.begin_first_morning(true)
    root.add_child(journey)
    current_scene = journey
    await frames(35)
    player().position = Vector2(982,512)
    verify("Early departure is blocked through actual gate",not await gate("move_right","route1") and journey.active_id == "hometown")
    verify("Early gate explains hall and preserves empty party",journey.route.get("_panel").visible and party.caught.is_empty())
    await key(KEY_M)
    verify("Map cannot interrupt gate dialogue",not journey.atlas.opened)
    await key(KEY_E)
    verify("Closing gate message restores control",player().is_physics_processing())
    await walk(Vector2(980,512))
    # Direct travel below exercises the map in every existing scene; the separate
    # first-morning and relay checks exercise real entrance movement.
    journey.partner_story.completed = true
    party.add(load("res://data/creatures/001_rimefin.tres"))
    var member: Object = party.active_member()
    for entry in [["courtyard_home",Vector2(128,208)],["courier_hall",Vector2(128,208)],["route1",Vector2(-720,512)],["riverfront",Vector2(320,512)],["historic_street",Vector2(384,848)],["relay_yard",Vector2(48,488)]]:
        journey.travel(entry[0],entry[1],Vector2.RIGHT)
        await frames(50)
        await key(KEY_M)
        verify("Map in "+entry[0],journey.atlas.opened and journey.active_id == entry[0])
        verify("Return guidance in "+entry[0],journey.atlas.first_hop("courtyard_home") != "" or entry[0] == "courtyard_home")
        await key(KEY_ESCAPE)
    verify("All seven places visited once",journey.visited_areas.size() == 7)
    await key(KEY_M)
    await click(journey.atlas._buttons["courtyard_home"])
    await click(journey.atlas._pin_button)
    verify("Distant pin starts with adjacent riverfront",journey.atlas.first_hop("courtyard_home") == "riverfront")
    tag = "region"
    await capture("all-connections")
    await key(KEY_ESCAPE)
    verify("Navigation preserves active member",party.active_member() == member)
    FileAccess.open(OUTPUT+"navigation-checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"  "))
    print("RESULT ",checks.size()," checks / ",failures.size()," failures")
    quit(0 if failures.is_empty() else 1)
