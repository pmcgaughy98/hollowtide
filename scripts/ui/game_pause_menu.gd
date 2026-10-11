extends CanvasLayer
## Town/Hollow overlay. Pauses the scene tree; never changes a turn, team or dungeon rule.
## Field pages (Claude, 2026-10-10; Preston: "use the synthesis to upgrade and refine Codex's work
## on the menu"). Structure from Explorers of Sky's dungeon menu (Items, Team, Ground, the message
## log under Others) and pokered's start menu (the party, the bag, the options), nothing copied:
## TEAM shows each teammate's level, IQ, health, moves and what it still needs to evolve; BAG
## lists the items (in the Hollow, choosing one closes the menu and uses it as a normal turn);
## FLOOR is the Ground page (floor, turn, lantern, underfoot, the orders); LOG is the last lines.
## Codex's pages and buttons are unchanged; the original is in docs/ui/field-menu-2026-10-10.
const FONT = preload("res://assets/fonts/AlegreyaSansSC-Bold.ttf")
const Lines := preload("res://scripts/creatures/lines.gd")
const UI = preload("res://scripts/ui/ui_style.gd")
const DUNGEON = "res://scripts/dungeon/dungeon.gd"   # loaded, not preloaded: dungeon.gd preloads this file
const ArenaData = preload("res://scripts/arena/arena_prototype.gd")
const TeamRecord = preload("res://scripts/town/team_state.gd")
const WAY_NAMES = {"flank": "pincer hits", "ambush": "hits on sleepers", "took": "damage taken", "slam": "slams", "healed": "health restored"}
const HEADINGS = {"team": "TEAM", "bag": "BAG", "floor": "FLOOR", "log": "MESSAGE LOG"}
const PREFS = "user://menu_preferences.cfg"
const TITLE = "res://scenes/creature_opening.tscn"
var overlay: Control
var hint: Button
var content: VBoxContainer
var page = "main"
var controls: Array[Control] = []
var releasing = false
var transition = false
var motion = false
var status: Label
var music_node: Node
var music_mode = Node.PROCESS_MODE_INHERIT

static func attach(scene: Node) -> void:
    if scene.has_node("GamePauseMenu"): return
    var menu = load("res://scripts/ui/game_pause_menu.gd").new()
    menu.name = "GamePauseMenu"
    scene.add_child(menu)

func _ready() -> void:
    layer = 80
    process_mode = Node.PROCESS_MODE_ALWAYS
    hint = _button("Menu  [P]")
    hint.name = "OpenMenu"
    hint.position = Vector2(984,586)
    hint.size = Vector2(160,52)
    hint.custom_minimum_size.y = 52
    hint.focus_mode = Control.FOCUS_NONE
    hint.pressed.connect(open)
    add_child(hint)
    overlay = Control.new()
    overlay.name = "PauseOverlay"
    overlay.size = Vector2(1152,648)
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(overlay)
    var shade = ColorRect.new()
    shade.size = overlay.size
    shade.color = Color(0.04,0.07,0.05,0.72)
    shade.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.add_child(shade)
    var panel = PanelContainer.new()
    panel.name = "PausePanel"
    panel.position = Vector2(316,58)
    panel.custom_minimum_size = Vector2(520,0)
    # The pixel frame every Hollowtide panel uses (scripts/ui/ui_style.gd, tools/ui/build_frames.py).
    var box = UI.frame("panel").duplicate()
    box.set_content_margin_all(34)
    panel.add_theme_stylebox_override("panel",box)
    overlay.add_child(panel)
    content = VBoxContainer.new()
    content.add_theme_constant_override("separation",10)
    panel.add_child(content)
    overlay.hide()

func _button(text: String) -> Button:
    var b = Button.new()
    b.text = text
    b.custom_minimum_size = Vector2(0,54)
    b.add_theme_font_override("font",FONT)
    b.add_theme_font_size_override("font_size",24)
    b.add_theme_color_override("font_color",Color("#fff4e8"))
    b.add_theme_color_override("font_focus_color",Color("#ffe9b0"))
    b.add_theme_color_override("font_hover_color",Color("#ffe9b0"))
    # Buttons wear the same brass frame; the chosen one's brass brightens.
    var box = UI.frame("panel").duplicate()
    box.content_margin_top = 8
    box.content_margin_bottom = 8
    b.add_theme_stylebox_override("normal",box)
    var focused = UI.frame("panel_focus").duplicate()
    focused.content_margin_top = 8
    focused.content_margin_bottom = 8
    for state in ["focus","hover","pressed"]: b.add_theme_stylebox_override(state,focused)
    UI.style_button(b)   # the button face: capitals, gold when chosen, sinks when pressed (Claude, 2026-10-10)
    return b

func _label(text: String, size: int = 22) -> Label:
    var l = Label.new()
    l.text = text
    # Headings in the title face, prose in the body face, small notes as labels (ui_style.gd TYPE).
    var role = "title" if size >= 30 else UI.role_for(size)
    l.add_theme_font_override("font",UI.font(role))
    l.add_theme_font_size_override("font_size",UI.type_size(role))
    l.add_theme_color_override("font_color",Color("#fff4e8"))
    l.add_theme_color_override("font_shadow_color",UI.SHADOW)
    l.add_theme_constant_override("shadow_offset_x",int(UI.TYPE[role]["px"]))
    l.add_theme_constant_override("shadow_offset_y",int(UI.TYPE[role]["px"]))
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    l.custom_minimum_size.x = 470
    content.add_child(l)
    return l

func _action(text: String, id: String, callback: Callable) -> Button:
    var b = _button(text)
    b.name = id
    b.pressed.connect(callback)
    content.add_child(b)
    controls.append(b)
    return b

func _config() -> ConfigFile:
    var c = ConfigFile.new()
    c.load(PREFS)
    return c

func _save(section: String, key: String, value: Variant) -> void:
    var c = _config()
    c.set_value(section,key,value)
    var err = c.save(PREFS)
    if status != null: status.text = "Changes are saved automatically." if err == OK else "Settings could not be saved."

func _volume(bus: String, key: String) -> void:
    var c = _config()
    var value = clampf(float(c.get_value("audio",key,100.0)),0,100)
    var caption = _label("%s volume   %d%%" % [bus,int(value)])
    var slider = HSlider.new()
    slider.name = bus + "Volume"
    slider.max_value = 100
    slider.step = 5
    slider.value = value
    slider.custom_minimum_size = Vector2(0,36)
    slider.focus_mode = Control.FOCUS_ALL
    var ring = Panel.new()
    ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var outline = StyleBoxFlat.new()
    outline.bg_color = Color.TRANSPARENT
    outline.border_color = Color("#e4ca8e")
    outline.set_border_width_all(2)
    ring.add_theme_stylebox_override("panel",outline)
    ring.hide()
    slider.add_child(ring)
    slider.focus_entered.connect(ring.show)
    slider.focus_exited.connect(ring.hide)
    content.add_child(slider)
    controls.append(slider)
    slider.value_changed.connect(func(v: float) -> void:
        caption.text = "%s volume   %d%%" % [bus,int(v)]
        var index = AudioServer.get_bus_index(bus)
        if index >= 0:
            AudioServer.set_bus_mute(index,v <= 0)
            AudioServer.set_bus_volume_db(index,linear_to_db(maxf(v/100,0.001)))
        _save("audio",key,v)
    )

func open() -> void:
    if overlay.visible or transition or get_tree().paused: return
    music_node = get_tree().root.get_node_or_null("HollowtideMusic")
    if is_instance_valid(music_node):
        music_mode = music_node.process_mode
        music_node.process_mode = Node.PROCESS_MODE_ALWAYS
    get_tree().paused = true
    overlay.show()
    hint.hide()
    show_page("main")

func show_page(next: String) -> void:
    page = next
    controls.clear()
    status = null
    for n in content.get_children():
        content.remove_child(n)
        n.queue_free()
    _label(HEADINGS.get(page,"PAUSED"),32)
    var in_hollow = "ents" in get_parent()
    # The party screen (Claude, 2026-10-10) takes the whole overlay; the usual panel steps aside.
    var old_party = overlay.get_node_or_null("PartyScreen")
    if old_party != null:
        overlay.remove_child(old_party)
        old_party.queue_free()
    overlay.get_node("PausePanel").visible = page != "team"
    match page:
        "main":
            _action("Resume","Resume",resume)
            _action("Team","Team",show_page.bind("team"))
            _action("Bag","Bag",show_page.bind("bag"))
            if in_hollow:
                _action("Floor","Floor",show_page.bind("floor"))
                _action("Message log","Log",show_page.bind("log"))
            _action("Options","Options",show_page.bind("options"))
            _action("Controls","Controls",show_page.bind("controls"))
            _action("Return to title","ReturnTitle",show_page.bind("title"))
            _action("Quit Game","Quit",show_page.bind("quit"))
        "options":
            _volume("Master","master")
            _volume("Music","music")
            motion = bool(_config().get_value("menu","reduce_motion",false))
            _action("Reduce menu motion: " + ("On" if motion else "Off"),"ReduceMotion",toggle_motion)
            _action("Back","Back",show_page.bind("main"))
            status = _label("Changes are saved automatically.",18)
        "controls":
            _label("Town: WASD / arrows move. E / J / Enter uses a place.")
            _label("Hollow exploration: WASD / arrows move; Shift turns. J / click attacks; 1-3 use moves. I bag; Z rest; E stairs; T team orders; Tab autopilot.",20)
            _label("Dungeon combat is turn-based. Y / N answers a recruit. The Training Yard is the separate arena mode.",20)
            _label("P / controller Start pauses anywhere. Esc pauses when no dialogue or bag is open. Arrows / D-pad navigate menus; Enter / A chooses; Esc / B goes back.",20)
            _action("Back","Back",show_page.bind("main"))
        "team":
            var party = load("res://scripts/ui/party_screen.gd").new()
            party.name = "PartyScreen"
            party.setup(get_parent())
            overlay.add_child(party)
            var back = _button("Back")
            back.name = "Back"
            back.position = Vector2(950,566)
            back.size = Vector2(130,36)
            back.pressed.connect(show_page.bind("main"))
            party.add_child(back)
            controls.append(back)
        "bag":
            _bag_page()
            _action("Back","Back",show_page.bind("main"))
        "floor":
            _floor_page()
            _action("Back","Back",show_page.bind("main"))
        "log":
            var lines: Array = get_parent().log_lines
            for line in lines.slice(maxi(0,lines.size()-12)):
                _label(line,16)
            if lines.is_empty(): _label("Nothing has happened yet.",18)
            _action("Back","Back",show_page.bind("main"))
        "title", "quit":
            _label("Return to the title?" if page == "title" else "Quit Hollowtide?",26)
            _label("Progress is not saved to disk yet. Leaving ends this session. Resume keeps your current team and floor.")
            _action("Keep exploring","CancelLeave",show_page.bind("main"))
            _action("Return to title" if page == "title" else "Quit Game","ConfirmLeave",leave)
    # Field pages added more rows; keep the dungeon main menu inside the fixed viewport.
    if page == "main" and in_hollow:
        content.add_theme_constant_override("separation",6)
        for b in controls: b.custom_minimum_size.y = 44
    else:
        content.add_theme_constant_override("separation",10)
    for i in controls.size():
        var b = controls[i]
        b.focus_neighbor_top = controls[posmod(i-1,controls.size())].get_path()
        b.focus_neighbor_bottom = controls[(i+1)%controls.size()].get_path()
        b.focus_previous = b.focus_neighbor_top
        b.focus_next = b.focus_neighbor_bottom
        b.focus_neighbor_left = b.get_path()
        b.focus_neighbor_right = b.get_path()
    if not controls.is_empty(): controls[0].grab_focus.call_deferred()

# The team record: the live run in the Hollow, the carried record in town.
func _record() -> Dictionary:
    var s = get_parent()
    if "ents" in s:
        return {"party": s.party, "levels": s.levels, "growth": s.growth, "iq": s.iq, "taught": s.taught, "bag": s.bag}
    return TeamRecord.data

func _move_name(m: String) -> String:
    return ArenaData.MOVES[m]["name"] if ArenaData.MOVES.has(m) else m

func _team_page() -> void:
    var rec = _record()
    var consts = load(DUNGEON).get_script_constant_map()
    var s = get_parent()
    var live: Array = []
    if "ents" in s:
        for e in s.ents:
            if e["team"] == 0: live.append(e)
    var party: Array = rec.get("party",[])
    for k in party.size():
        var ln = int(party[k][0])
        var st = int(party[k][1])
        var form = Lines.of(ln)["forms"][st]
        var lv = int(rec.get("levels",{}).get(ln,{}).get("lv",1))
        var head = "%s   Lv %d   IQ %d" % [String(load(form[1]).creature_name).to_upper(),lv,int(rec.get("iq",{}).get(ln,0))]
        var e: Dictionary = live[k] if k < live.size() else {}
        if not e.is_empty(): head += "   HP %d/%d" % [e["hp"],e["max_hp"]]
        var row = HBoxContainer.new()
        row.add_theme_constant_override("separation",10)
        var face_path = "res://assets/sprites/arena/%s/portrait.png" % form[0]
        if ResourceLoader.exists(face_path):
            var face = TextureRect.new()
            face.texture = load(face_path)
            face.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
            face.custom_minimum_size = Vector2(48,48)
            var frame = PanelContainer.new()
            var fbox = StyleBoxFlat.new()
            fbox.bg_color = Color("#63a9a6")   # the normal face's blue, as ui_style.gd PORTRAIT_BG (Preston, 2026-10-10: not white)
            fbox.border_color = Color("#b69b6d")
            fbox.set_border_width_all(1)
            frame.add_theme_stylebox_override("panel",fbox)
            frame.add_child(face)
            row.add_child(frame)
        var name_label = _label(head + ("   (leads)" if k == 0 else ""),20)
        content.remove_child(name_label)
        name_label.custom_minimum_size.x = 412
        name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        row.add_child(name_label)
        content.add_child(row)
        if st >= 2:
            _label("    Final stage.",16)
        elif consts["EVO"].has(ln):
            var r: Dictionary = consts["EVO"][ln]
            var g: Dictionary = rec.get("growth",{}).get("%d:%d" % [ln,st],{})
            _label("    To evolve: Lv %d/%d, KOs %d/%d, floors %d/%d, %s %d/%d" % [lv,consts["EVO_LEVEL"][st],g.get("kos",0),r["kos"][st],g.get("floors",0),r["floors"][st],WAY_NAMES.get(r["way"],r["way"]),g.get(r["way"],0),r["need"][st]],16)
        var moves: Array = e["moves"] if not e.is_empty() else rec.get("taught",{}).get("%d:%d" % [ln,st],[])
        if not moves.is_empty(): _label("    Moves: " + ", ".join(moves.map(_move_name)),16)
    if party.is_empty(): _label("No team yet.",18)

func _bag_page() -> void:
    var s = get_parent()
    var bag: Dictionary = _record().get("bag",{})
    var items: Dictionary = load(DUNGEON).get_script_constant_map()["ITEMS"]
    for kind in bag:
        var info: Dictionary = s.item_info(kind) if s.has_method("item_info") else items.get(kind,{"name": kind, "what": ""})
        var text = "%s x%d   %s" % [info["name"],bag[kind],info["what"]]
        if s.has_method("act_use_item"):
            var b = _action(text,"Use_" + String(kind).replace(":","_"),_use_item.bind(kind))
            b.add_theme_font_override("font",UI.font("body"))   # an item row reads as prose
            b.add_theme_font_size_override("font_size",UI.type_size("body"))
        else:
            _label(text,18)
    if bag.is_empty(): _label("The bag is empty.",18)
    elif not s.has_method("act_use_item"): _label("Items are used in the Hollow.",16)

# Choosing an item closes the menu and uses it the way the bag key does: it spends the turn.
func _use_item(kind: String) -> void:
    await resume()
    var s = get_parent()
    if is_instance_valid(s) and not s.busy: s.act_use_item(kind)

func _floor_page() -> void:
    var s = get_parent()
    var lead: Dictionary = s.ents[0]
    _label("B%dF   turn %d" % [s.floor_n,s.turn],22)
    _label("Lantern %d%%" % int(round(100.0 * s.light / s.LIGHT_MAX)),20)
    var under = "nothing"
    if lead["pos"] == s.data["stairs"]: under = "the stairs (E goes down)"
    for t in s.traps:
        if t["pos"] == lead["pos"] and t["seen"]: under = "a %s trap" % t["kind"]
    _label("Underfoot: " + under,20)
    _label("Partners' order: " + s.TACTIC_NAMES[s.tactic] + " (T changes it)",20)
    if s.boss_alive(): _label("%s guards this floor. The stairs are sealed." % s.ents[s.boss]["name"],20)
    if s.monster_sprung: _label("Monster House: " + ("cleared" if s.house_cleared else "still fighting"),20)

func toggle_motion() -> void:
    motion = not motion
    _save("menu","reduce_motion",motion)
    var b = content.get_node("ReduceMotion") as Button
    b.text = "Reduce menu motion: " + ("On" if motion else "Off")

func _restore_music() -> void:
    if is_instance_valid(music_node): music_node.process_mode = music_mode

func resume() -> void:
    if releasing or transition: return
    releasing = true
    # Raw key polling in the game must not see the closing Enter/Escape as a turn.
    while Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_cancel") or Input.is_physical_key_pressed(KEY_P) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        await get_tree().process_frame
    overlay.hide()
    hint.show()
    _restore_music()
    get_tree().paused = false
    releasing = false

func leave() -> void:
    if transition: return
    transition = true
    if page == "quit":
        get_tree().quit()
        return
    _restore_music()
    get_tree().paused = false
    var err = get_tree().change_scene_to_file(TITLE)
    if err != OK:
        transition = false
        get_tree().paused = true
        if is_instance_valid(music_node): music_node.process_mode = Node.PROCESS_MODE_ALWAYS
        show_page("main")
        _label("The title could not open. You can still resume.")

func _has_modal() -> bool:
    var scene = get_parent()
    if "panel" in scene and not scene.panel.is_empty(): return true
    if "asking" in scene and scene.asking >= 0: return true
    if "talk" in scene and not scene.talk.is_empty(): return true
    if "teach_kind" in scene and scene.teach_kind != "": return true
    return "bag_open" in scene and scene.bag_open

func _input(event: InputEvent) -> void:
    if transition or releasing: return
    var p = event is InputEventKey and event.pressed and not event.echo and (event.physical_keycode == KEY_P or event.keycode == KEY_P)
    p = p or (event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START)
    var cancel = event.is_action_pressed("ui_cancel") and not event.is_echo()
    if not p and not cancel: return
    if overlay.visible:
        if page == "main": resume()
        else: show_page("main")
    elif p or not _has_modal(): open()
    else: return
    get_viewport().set_input_as_handled()

func _exit_tree() -> void:
    _restore_music()
    if overlay != null and overlay.visible and get_tree() != null: get_tree().paused = false
