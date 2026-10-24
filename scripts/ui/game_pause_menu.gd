extends CanvasLayer
## Town/Hollow overlay. Pauses the scene tree; never changes a turn, team or dungeon rule.
## Field pages (Claude, 2026-10-10; Preston: "use the synthesis to upgrade and refine Codex's work
## on the menu"). Structure from Explorers of Sky's dungeon menu (Items, Team, Ground, the message
## log under Others) and pokered's start menu (the party, the bag, the options), nothing copied:
## TEAM shows each teammate's level, IQ, health, moves and what it still needs to evolve; BAG
## lists the items (in the Hollow, choosing one closes the menu and uses it as a normal turn);
## FLOOR is the Ground page (floor, turn, lantern, underfoot, the orders); LOG is the last lines.
## Codex's pages and buttons are unchanged; the original is in docs/ui/field-menu-2026-10-10.

const Lines := preload("res://scripts/creatures/lines.gd")
const UI = preload("res://scripts/ui/ui_style.gd")
const DUNGEON = "res://scripts/dungeon/dungeon.gd"   # loaded, not preloaded: dungeon.gd preloads this file
const ArenaData = preload("res://scripts/arena/arena_prototype.gd")
const TeamRecord = preload("res://scripts/town/team_state.gd")
const WAY_NAMES = {"flank": "pincer hits", "ambush": "hits on sleepers", "took": "damage taken", "slam": "slams", "healed": "health restored"}
const HEADINGS = {"goal": "OBJECTIVE", "team": "TEAM", "bag": "BAG", "floor": "FLOOR", "log": "MESSAGE LOG", "options": "OPTIONS", "controls": "CONTROLS", "rebind": "REBIND KEYS"}
# Where Esc, B or Back goes from a page: the main page unless named here (Claude, 2026-10-23, GS-04).
const PARENT_PAGE = {"rebind": "options"}
const PREFS = "user://menu_preferences.cfg"
const TITLE = "res://scenes/creature_opening.tscn"
const ControlsText = preload("res://scripts/ui/controls_text.gd")
const SPEED_NAMES = {1: "Normal", 2: "Fast", 0: "Instant"}   # menu/text_speed, as UI.text_speed() reads it
const SPEED_NEXT = {1: 2, 2: 0, 0: 1}
const FLOOR_W = 532.0   # the Floor page's text width: its 600 px panel less the frame's 34 px each side
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
# Menu sounds go through UI.tick (Claude, 2026-10-22, GS-21): open, close, cursor on a focus change, confirm,
# cancel. `sounds` keeps the kinds this menu played, newest last, for the checks; a page's first focus is quiet.
var sounds: Array[String] = []
var quiet_focus = false
var bag_hint: Label   # the bag page's key line, retold when the device changes

static func attach(scene: Node) -> void:
    if scene.has_node("GamePauseMenu"): return
    var menu = load("res://scripts/ui/game_pause_menu.gd").new()
    menu.name = "GamePauseMenu"
    scene.add_child(menu)

func _ready() -> void:
    layer = 80
    process_mode = Node.PROCESS_MODE_ALWAYS
    hint = _button("")
    hint.name = "OpenMenu"
    hint.position = Vector2(984,586)
    hint.size = Vector2(160,52)
    hint.custom_minimum_size.y = 52
    _place_hint()
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
    # Hints name the device in use: [P] on a keyboard, [Start] on a pad (Claude, 2026-10-23, FEEL-01).
    var prefs = get_node_or_null("/root/InputPrefs")
    if prefs != null: prefs.device_changed.connect(_on_device_changed)

func _hint_words() -> String:
    var k = UI.binding_text("pause")
    return "Menu  [%s]" % k if k != "" else "Menu"

# The corner button keeps its width: "Menu  [P]" (141 px) stays in the button face, a longer key such as
# "[Start]" (207 px) steps down to the label face.
func _place_hint() -> void:
    hint.text = _hint_words()
    var role = UI.fit(hint.text,"button",150.0)   # "Menu  [P]" is 141 px and keeps the button face
    hint.add_theme_font_override("font",UI.font(role))
    hint.add_theme_font_size_override("font_size",UI.type_size(role))

func _on_device_changed(_device: String) -> void:
    _place_hint()
    if not overlay.visible: return
    if page == "controls": show_page("controls")   # its only row is Back, so nothing is lost
    elif page == "bag" and is_instance_valid(bag_hint):
        bag_hint.text = _bag_hint_words(bag_hint.get_meta("empty",false),bag_hint.get_meta("use",false))
        var view = content.get_node_or_null("BagPage")
        if view != null: view.retell()   # its "ENTER  USE" line names the device's key too (Claude, 2026-10-24, LV-21)

func _button(text: String) -> Button:
    var b = Button.new()
    b.text = text
    b.custom_minimum_size = Vector2(0,54)
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

# A message log row with its creature names coloured (`marks`: name -> colour, from the dungeon's log_marks); a row
# with none is a plain label (pass 3 D8, Claude, 2026-10-23).
func _log_row(text: String, marks: Dictionary) -> Control:
    if marks.is_empty(): return _label(text,16)
    var role = UI.role_for(16)
    var r = RichTextLabel.new()
    r.bbcode_enabled = true
    r.fit_content = true
    r.scroll_active = false
    r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    r.custom_minimum_size.x = 470
    r.add_theme_font_override("normal_font",UI.font(role))
    r.add_theme_font_size_override("normal_font_size",UI.type_size(role))
    r.add_theme_color_override("default_color",Color("#fff4e8"))
    r.add_theme_color_override("font_shadow_color",UI.SHADOW)
    r.add_theme_constant_override("shadow_offset_x",int(UI.TYPE[role]["px"]))
    r.add_theme_constant_override("shadow_offset_y",int(UI.TYPE[role]["px"]))
    var out = ""
    var rest = text
    while rest != "":
        var at = -1
        var word = ""
        for w in marks:
            var k = rest.find(String(w))
            if k >= 0 and (at < 0 or k < at):
                at = k
                word = String(w)
        if at < 0:
            out += rest.replace("[","[lb]")
            break
        out += rest.substr(0,at).replace("[","[lb]") + "[color=#%s]%s[/color]" % [Color(marks[word]).to_html(false),word.replace("[","[lb]")]
        rest = rest.substr(at+word.length())
    r.text = out
    content.add_child(r)
    return r

func _action(text: String, id: String, callback: Callable) -> Button:
    var b = _button(text)
    b.name = id
    b.pressed.connect(_pressed_sound.bind(id))
    b.pressed.connect(callback)
    content.add_child(b)
    controls.append(b)
    return b

func _config() -> ConfigFile:
    var c = ConfigFile.new()
    c.load(PREFS)
    return c

func _save(section: String, key: String, value: Variant) -> void:
    # Each pref goes to its own file: text speed to user://game_prefs.cfg, where a title save cannot wipe it (Claude, 2026-10-23, U1).
    var ok = UI.save_pref(section,key,value)
    if status != null: status.text = "Changes are saved automatically." if ok else "Settings could not be saved."

# A volume row (Claude, 2026-10-24, LV-04): the caption and its slider side by side in a framed row that wears
# the same brass as the button rows, panel_focus while the slider has focus. The slider keeps one look in every
# state: its framed track, the filled part up to the value and its pixel grabber (_slider_look).
func _volume(bus: String, key: String, words: String) -> void:
    var c = _config()
    var value = clampf(float(c.get_value("audio",key,100.0)),0,100)
    var row = PanelContainer.new()
    row.name = bus + "Row"
    row.custom_minimum_size.y = 40   # a compact button row's height
    var plain = UI.frame("panel").duplicate()
    var lit = UI.frame("panel_focus").duplicate()
    for sb in [plain,lit]:
        sb.content_margin_top = 3
        sb.content_margin_bottom = 3
    row.add_theme_stylebox_override("panel",plain)
    var line = HBoxContainer.new()
    line.add_theme_constant_override("separation",12)
    row.add_child(line)
    var caption = _label("%s volume   %d%%" % [words,int(value)])
    content.remove_child(caption)
    caption.autowrap_mode = TextServer.AUTOWRAP_OFF
    caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    # Every caption as wide as the widest, so the three sliders start in one column.
    caption.custom_minimum_size.x = ceilf(UI.width_in("Sound effects volume   100%",UI.role_for(22)))
    line.add_child(caption)
    var slider = HSlider.new()
    slider.name = bus + "Volume"
    slider.max_value = 100
    slider.step = 5
    slider.value = value
    slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    slider.focus_mode = Control.FOCUS_ALL
    _slider_look(slider)
    line.add_child(slider)
    slider.focus_entered.connect(func() -> void:
        row.add_theme_stylebox_override("panel",lit)
        caption.add_theme_color_override("font_color",UI.EDGE_LIGHT)
    )
    slider.focus_exited.connect(func() -> void:
        row.add_theme_stylebox_override("panel",plain)
        caption.add_theme_color_override("font_color",UI.TEXT)
    )
    # A step of the slider ticks on the bus it sets, so the new level is heard at once (silent at 0).
    var tick = AudioStreamPlayer.new()
    tick.name = "Tick"
    tick.stream = load(UI.TICKS["cursor"])
    tick.bus = bus
    tick.volume_db = UI.TICK_DB
    slider.add_child(tick)
    content.add_child(row)
    controls.append(slider)
    slider.value_changed.connect(func(v: float) -> void:
        caption.text = "%s volume   %d%%" % [words,int(v)]
        var index = AudioServer.get_bus_index(bus)
        if index >= 0:
            AudioServer.set_bus_mute(index,v <= 0)
            AudioServer.set_bus_volume_db(index,linear_to_db(maxf(v/100,0.001)))
        _save("audio",key,v)
        if tick.is_inside_tree(): tick.play()
    )

# The slider's parts, drawn a pixel at a time at 1x in the UI colours and shown at 3x like the frames
# (tools/ui/build_frames.py), made once a session (Claude, 2026-10-24, LV-04). The track is a 9-slice: ink rim,
# brass bevel, a sunken moss well. The fill is the lantern's gold, clear over the rim so the frame always shows.
# The grabber is a brass knob with two grip lines. The same parts are given for every state, so focus and hover
# never change the slider itself; the row's frame shows focus.
static var _slider_parts := {}

static func _slider_look(slider: HSlider) -> void:
    if _slider_parts.is_empty():
        var ink = UI.INK
        var brass = {"i": ink, "h": UI.EDGE_LIGHT, "b": UI.EDGE, "l": UI.EDGE.darkened(0.3), "g": UI.EDGE.darkened(0.55)}
        var track = _pixels(PackedStringArray([".iiii.","ihhhhi","ibwwbi","ibddbi","ibddbi","ibddbi","illlli",".iiii."]),
            {"i": ink, "h": UI.EDGE_LIGHT, "b": UI.EDGE, "l": UI.EDGE.darkened(0.3), "w": UI.PANEL.darkened(0.45), "d": UI.PANEL.darkened(0.2)})
        var fill = _pixels(PackedStringArray(["...","...","..F","..f","..f","..d","...","..."]),
            {"F": UI.LIGHT.lightened(0.35), "f": UI.LIGHT, "d": UI.LIGHT.darkened(0.25)})
        var knob = _pixels(PackedStringArray([".iiii.","ihhhbi","ihbbli","ihggli","ihbbli","ihggli","ihbbli","ihbbli","ibllli",".iiii."]),brass)
        var well = StyleBoxTexture.new()
        well.texture = track
        well.texture_margin_left = 6
        well.texture_margin_right = 6
        well.texture_margin_top = 9
        well.texture_margin_bottom = 6
        # The slider draws its track at the style's minimum height: 24 px, 8 pixels of UI art.
        well.content_margin_left = 6
        well.content_margin_right = 6
        well.content_margin_top = 12
        well.content_margin_bottom = 12
        var gold = StyleBoxTexture.new()
        gold.texture = fill
        gold.texture_margin_left = 6
        gold.texture_margin_top = 6
        gold.texture_margin_bottom = 6
        gold.content_margin_top = 12
        gold.content_margin_bottom = 12
        _slider_parts = {"track": well, "fill": gold, "knob": knob}
    slider.add_theme_stylebox_override("slider",_slider_parts["track"])
    for state in ["grabber_area","grabber_area_highlight"]:
        slider.add_theme_stylebox_override(state,_slider_parts["fill"])
    for state in ["grabber","grabber_highlight","grabber_disabled"]:
        slider.add_theme_icon_override(state,_slider_parts["knob"])
    slider.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

# Pixel art from rows of letters, each letter a colour ("." clear), scaled 3x with nearest sampling.
static func _pixels(rows: PackedStringArray, colours: Dictionary) -> ImageTexture:
    var img = Image.create(rows[0].length(),rows.size(),false,Image.FORMAT_RGBA8)
    for y in rows.size():
        for x in rows[y].length():
            var ch = rows[y][x]
            if colours.has(ch): img.set_pixel(x,y,colours[ch])
    img.resize(img.get_width()*3,img.get_height()*3,Image.INTERPOLATE_NEAREST)
    return ImageTexture.create_from_image(img)

func open() -> void:
    if overlay.visible or transition or get_tree().paused: return
    # Pausing ends a dungeon run (Claude, 2026-10-14): it used to carry on after the menu closed.
    var host = get_parent()
    if host != null and "running" in host: host.running = false
    music_node = get_tree().root.get_node_or_null("HollowtideMusic")
    if is_instance_valid(music_node):
        music_mode = music_node.process_mode
        music_node.process_mode = Node.PROCESS_MODE_ALWAYS
    get_tree().paused = true
    overlay.show()
    hint.hide()
    _tick("open")
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
    var panel = overlay.get_node("PausePanel") as PanelContainer
    panel.visible = page != "team"
    # The Floor page is a little wider so its longest value keeps to one line (Claude, 2026-10-24, LV-22).
    panel.position = Vector2(96,42) if page == "bag" else Vector2(196,8) if page == "rebind" else Vector2(276,58) if page == "floor" else Vector2(316,58)
    panel.custom_minimum_size = Vector2(960,0) if page == "bag" else Vector2(760,0) if page == "rebind" else Vector2(600,0) if page == "floor" else Vector2(520,0)
    panel.size = Vector2.ZERO
    match page:
        "main":
            _action("Resume","Resume",resume)
            _action("Objective","Objective",show_page.bind("goal"))
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
            UI.reload_prefs()   # the title's Options may have saved since this menu last read them
            _volume("Master","master","Master")
            _volume("Music","music","Music")
            _volume("SFX","sfx","Sound effects")
            # Screen mode and text speed (Claude, 2026-10-22, GS-01): the same prefs keys the title's Options use.
            _action(_screen_words(),"ScreenMode",toggle_screen)
            _action(_speed_words(),"TextSpeed",cycle_text_speed)
            motion = bool(_config().get_value("menu","reduce_motion",false))
            _action("Reduce motion: " + ("On" if motion else "Off"),"ReduceMotion",toggle_motion)
            # Every key and button can be changed (Claude, 2026-10-23, GS-04): scripts/ui/rebind_page.gd.
            _action("Rebind keys","Rebind",show_page.bind("rebind"))
            _action("Back","Back",show_page.bind("main"))
            status = _label("Changes are saved automatically.",18)
        "controls":
            # One copy of the keys, shared with the opening's help (scripts/ui/controls_text.gd), under the honest
            # line about the controller (Claude, 2026-10-22, LP-03). The keys are the live ones for the device in
            # use, so a rebound key or a pad reads true (Claude, 2026-10-23).
            _label(ControlsText.note(),18).add_theme_color_override("font_color",UI.MUTED)
            for g in ControlsText.groups():
                _label(String(g["head"]),14).add_theme_color_override("font_color",UI.EDGE_LIGHT)
                for line in g["lines"]: _label(String(line),18)
                if g["head"] == ControlsText.HOLLOW["head"]: _label(ControlsText.TURNS,18)
            _action("Back","Back",show_page.bind("main"))
        "rebind":
            var rebind = load("res://scripts/ui/rebind_page.gd").new()
            content.add_child(rebind)
            rebind.setup(self)
            _action("Back","Back",show_page.bind("options"))
        "team":
            var party = load("res://scripts/ui/party_screen.gd").new()
            party.name = "PartyScreen"
            party.setup(get_parent())
            overlay.add_child(party)
            var back = _button("Back")
            back.name = "Back"
            back.position = Vector2(950,566)
            back.size = Vector2(130,36)
            back.pressed.connect(_tick.bind("cancel"))
            back.pressed.connect(show_page.bind("main"))
            party.add_child(back)
            controls.append(back)
        "goal":
            # What to do next and where (Claude, 2026-10-11; Preston: "objective tab so players know where to go").
            var src = get_parent()
            var story: Dictionary = src.story if "ents" in src else TeamRecord.data.get("story",{})
            var beaten: Array = src.beaten if "ents" in src else TeamRecord.data.get("beaten",[])
            # Below in a Hollow, the line leaves out how to get down from town (Claude, 2026-10-24, LV-23).
            var below = String(src.scene_file_path).ends_with("dungeon.tscn")
            var goal: Dictionary = load("res://scripts/town/objective.gd").current(story,beaten,below)
            _label(String(goal["short"]),30)   # the goal itself in the title face (Claude, 2026-10-22, LP-28)
            _label(String(goal["long"]),20)
            _action("Back","Back",show_page.bind("main"))
        "bag":
            _bag_page()
            _action("Back","Back",show_page.bind("main"))
        "floor":
            _floor_page()
            _action("Back","Back",show_page.bind("main"))
        "log":
            # Names in their side's colours, as the message box shows them (pass 3 D8, Claude, 2026-10-23).
            var lines: Array = get_parent().log_lines
            var marks = get_parent().get("log_marks")
            if marks == null: marks = []
            for k in range(maxi(0,lines.size()-12),lines.size()):
                var at = marks.size()-lines.size()+k
                _log_row(String(lines[k]),marks[at] if at >= 0 and at < marks.size() else {})
            if lines.is_empty(): _label("Nothing has happened yet.",18)
            _action("Back","Back",show_page.bind("main"))
        "title", "quit":
            _label("Return to the title?" if page == "title" else "Quit Hollowtide?",26)
            _label("The run is kept. Continue on the title picks it up at the top of this floor, with the team as it stands." if in_hollow else "Highbank is saved. Continue on the title brings you back here.")
            _action("Keep exploring","CancelLeave",show_page.bind("main"))
            _action("Return to title" if page == "title" else "Quit Game","ConfirmLeave",leave)
    # Field pages added more rows; keep the dungeon main menu inside the fixed viewport. Options (three
    # sliders and four rows since the screen and text rows) and Controls are packed the same way, rows
    # 40 px and the gaps a little wider than the main page's (Claude, 2026-10-22). Options has five rows since the
    # Controls row, and the rebinding page's rows are packed the same way (Claude, 2026-10-23).
    if (page == "main" and in_hollow) or page in ["options","controls","rebind"]:
        # Ten rows: the frame's 8 px padding held each row at 49 px whatever its minimum, 658 px in all on a
        # 648 px screen; 3 px padding (the pressed sink kept) lets a row be 40 (Claude, 2026-10-14).
        content.add_theme_constant_override("separation",4 if page == "main" else 6)
        for b in controls:
            if not b is Button: continue   # the sliders keep their own height
            b.custom_minimum_size.y = 40
            for state in ["normal","focus","hover","pressed","hover_pressed","disabled"]:
                if b.has_theme_stylebox_override(state):
                    var sb = b.get_theme_stylebox(state).duplicate()
                    sb.content_margin_top = maxf(0.0,sb.content_margin_top-5.0)
                    sb.content_margin_bottom = maxf(0.0,sb.content_margin_bottom-5.0)
                    b.add_theme_stylebox_override(state,sb)
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
        if not b.focus_entered.is_connected(_on_focus): b.focus_entered.connect(_on_focus)
    panel.reset_size.call_deferred()
    _keep_on_screen.call_deferred(panel)
    _focus_first.call_deferred()

# Ten rows in the Hollow still ran the panel 18 px past the bottom at y 58; any page that grows past
# the screen moves up to fit it instead (Claude, 2026-10-14).
func _keep_on_screen(panel: Control) -> void:
    await get_tree().process_frame
    if not is_instance_valid(panel) or not panel.visible: return
    var view_h = 648.0   # the game's fixed canvas, which every screen is laid out on
    if panel.position.y + panel.size.y > view_h - 8.0:
        panel.position.y = maxf(8.0, view_h - 8.0 - panel.size.y)

func _focus_first() -> void:
    # A page can be replaced before its deferred focus runs (open followed by Bag).
    if overlay.visible and not controls.is_empty() and controls[0].is_inside_tree():
        quiet_focus = true   # the page's own first focus is not a cursor move
        controls[0].grab_focus()
        quiet_focus = false

func _on_focus() -> void:
    if not quiet_focus: _tick("cursor")

func _tick(kind: String) -> void:
    sounds.append(kind)
    if sounds.size() > 32: sounds.pop_front()
    UI.tick(kind)

# What a pressed row sounds like: Back and "Keep exploring" cancel, Resume closes (resume() plays it), the
# rest confirm.
func _pressed_sound(id: String) -> void:
    if id == "Resume": return
    _tick("cancel" if id in ["Back","CancelLeave"] else "confirm")

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
        var head = "%s   Lv %d   Sense %d" % [String(load(form[1]).creature_name).to_upper(),lv,int(rec.get("iq",{}).get(ln,0))]
        var e: Dictionary = live[k] if k < live.size() else {}
        if not e.is_empty(): head += "   HP %d/%d" % [e["hp"],e["max_hp"]]
        var row = HBoxContainer.new()
        row.add_theme_constant_override("separation",10)
        # The dialogue face cut at 3x, one pixel size with the dialogue (Claude, 2026-10-23, UI-05).
        var face_tex = UI.portrait_3x(String(form[0]))
        if face_tex != null:
            var face = TextureRect.new()
            face.texture = face_tex
            face.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
            face.custom_minimum_size = Vector2(48,48)
            # The pixel portrait frame round the river-blue well (Claude, 2026-10-22, UI-06; it was a flat box).
            var frame = PanelContainer.new()
            frame.add_theme_stylebox_override("panel",UI.frame("portrait"))
            var well = ColorRect.new()
            well.color = UI.PORTRAIT_BG   # the normal face's blue (Preston, 2026-10-10: not white)
            well.custom_minimum_size = Vector2(48,48)
            well.add_child(face)
            frame.add_child(well)
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
            _label("    To grow: Lv %d/%d, KOs %d/%d, floors %d/%d, %s %d/%d" % [lv,consts["EVO_LEVEL"][st],g.get("kos",0),r["kos"][st],g.get("floors",0),r["floors"][st],WAY_NAMES.get(r["way"],r["way"]),g.get(r["way"],0),r["need"][st]],16)
        var moves: Array = e["moves"] if not e.is_empty() else rec.get("taught",{}).get("%d:%d" % [ln,st],[])
        if not moves.is_empty(): _label("    Moves: " + ", ".join(moves.map(_move_name)),16)
    if party.is_empty(): _label("No team yet.",18)

func _bag_page() -> void:
    var scene = get_parent()
    var bag: Dictionary = _record().get("bag",{})
    var dungeon = load(DUNGEON)
    var items: Dictionary = dungeon.get_script_constant_map()["ITEMS"]
    # Town reads the same metadata, including scroll body requirements, without starting a run.
    var info_source = scene if scene.has_method("item_info") else dungeon.new()
    var entries: Array = []
    for key in bag:
        var kind = String(key)
        var known = items.has(kind) or (kind.begins_with("scroll:") and ArenaData.MOVES.has(kind.substr(7)))
        var info: Dictionary = info_source.item_info(kind) if known else {"name":kind,"what":"No description available."}
        entries.append({"kind":kind,"count":bag[key],"name":info["name"],"what":info["what"]})
    if info_source != scene: info_source.free()
    var bag_view = load("res://scripts/ui/bag_page.gd").new()
    content.add_child(bag_view)
    bag_view.setup(entries,scene.has_method("act_use_item"),self)
    # Key hints in the house column style: the key, two spaces, what it does (Claude, 2026-10-22, W12). The
    # keys are the device's in use (Claude, 2026-10-23): Arrows, Enter and Esc, or D-pad, A and B. In capitals
    # in the label face, as the Hollow's own key hints read ("KEY  USE", Claude, 2026-10-24, LV-21).
    bag_hint = _label(_bag_hint_words(bag.is_empty(),scene.has_method("act_use_item")),14)
    bag_hint.add_theme_color_override("font_color",UI.MUTED)
    bag_hint.set_meta("empty",bag.is_empty())
    bag_hint.set_meta("use",scene.has_method("act_use_item"))

func _bag_hint_words(empty: bool, can_use: bool) -> String:
    var pad = UI.last_device() == "pad"
    var back = "%s  back" % UI.binding_text("ui_cancel")
    if empty: return back.to_upper()
    var browse = "%s  browse     " % ("D-pad" if pad else "Arrows")
    return (browse + back if not can_use else browse + "%s  use     " % UI.binding_text("ui_accept") + back).to_upper()

# Choosing an item closes the menu and uses it the way the bag key does: it spends the turn.
func _use_item(kind: String) -> void:
    await resume()
    var s = get_parent()
    # A turn still playing when the menu opened finishes first; the item is then the next turn.
    while is_instance_valid(s) and s.busy and not s.cutscene: await get_tree().process_frame
    # A recruit question that turn raised is answered first (a step waits for it too).
    if is_instance_valid(s) and not s.busy and s.asking < 0: s.act_use_item(kind)

# The Ground page (Claude, 2026-10-24, LV-22): the dungeon's name as the heading with the floor under it, as its
# place card shows them, then one labelled row each for the turn, the lantern (a bar and its value), what is
# underfoot, the water and the partners' order. The words are the page's own from before.
func _floor_page() -> void:
    var s = get_parent()
    var lead: Dictionary = s.ents[0]
    var head = content.get_child(0) as Label
    if "dungeon" in s and s.DUNGEONS.has(s.dungeon):
        head.text = String(s.DUNGEONS[s.dungeon]["name"]).to_upper()
        var role = UI.fit(head.text,"title",head.custom_minimum_size.x)
        head.add_theme_font_override("font",UI.font(role))
        head.add_theme_font_size_override("font_size",UI.type_size(role))
    var floor_label = _label("B%dF" % s.floor_n,22)
    floor_label.add_theme_font_override("font",UI.font("button"))
    floor_label.add_theme_font_size_override("font_size",UI.type_size("button"))
    floor_label.add_theme_color_override("font_color",UI.EDGE_LIGHT)
    var under = "nothing"
    # The keys named are the live ones for the device in use (Claude, 2026-10-23): E and T, or X and LB on a pad.
    if lead["pos"] == s.data["stairs"]: under = "the stairs (%s goes down)" % UI.binding_text("interact")
    for t in s.traps:
        if t["pos"] == lead["pos"] and t["seen"]: under = "a %s trap" % t["kind"]
    if "water_rows" in s and s.wet(lead["pos"]): under = "water (the lantern's getting wet)"
    var keys = ["Turn","Lantern","Underfoot","Water","Partners' order","The nest"]
    var key_w = 0.0
    for k in keys: key_w = maxf(key_w,UI.width_in(String(k).to_upper(),"label"))
    _floor_row("Turn","%d" % s.turn,key_w)
    var lantern = _floor_row("Lantern","%d%%" % int(round(100.0 * s.light / s.LIGHT_MAX)),key_w,146.0)
    var gauge = Control.new()
    gauge.name = "LanternBar"
    gauge.custom_minimum_size = Vector2(146,lantern.get_child(0).custom_minimum_size.y)
    gauge.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    var frac = clampf(s.light / s.LIGHT_MAX,0.0,1.0)
    gauge.draw.connect(func() -> void: UI.bar(gauge,Rect2(0,roundf((gauge.size.y-9.0)/2.0),gauge.size.x,9),frac,UI.LIGHT))
    lantern.add_child(gauge)
    lantern.move_child(gauge,1)
    _floor_row("Underfoot",under,key_w)
    if "water_rows" in s and s.water_rows > 0: _floor_row("Water","%d rows up from the low end, rising" % s.water_rows if s.water_rows < s.water_max else "%d rows up from the low end, as high as it gets" % s.water_rows,key_w)
    _floor_row("Partners' order",s.TACTIC_NAMES[s.tactic] + " (%s changes it)" % UI.binding_text("tactics"),key_w)
    if s.monster_sprung: _floor_row("The nest","cleared" if s.house_cleared else "still fighting",key_w)
    if s.boss_alive(): _label("%s guards this floor. The stairs are sealed." % s.ents[s.boss]["name"],20)

# One labelled row of the Floor page: the label in the label face, its value in the body face beside it, the
# labels one column wide (`key_w`) so the values line up; `beside` keeps room for a gauge before the value. The
# value is given its width up front: a wrapping label that starts at no width measures itself a word a line tall.
# Returns the row.
func _floor_row(key: String, value: String, key_w: float, beside := 0.0) -> HBoxContainer:
    var row = HBoxContainer.new()
    row.add_theme_constant_override("separation",14)
    var line_h = ceilf(UI.font("body").get_height(UI.type_size("body")))
    var k = _label(key,14)
    content.remove_child(k)
    k.autowrap_mode = TextServer.AUTOWRAP_OFF
    k.custom_minimum_size = Vector2(ceilf(key_w),line_h)
    k.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    k.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
    k.add_theme_color_override("font_color",UI.MUTED)
    row.add_child(k)
    var v = _label(value,20)
    content.remove_child(v)
    v.custom_minimum_size.x = FLOOR_W - ceilf(key_w) - 14.0 - (beside + 14.0 if beside > 0.0 else 0.0)
    v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(v)
    content.add_child(row)
    return row

func toggle_motion() -> void:
    motion = not motion
    _save("menu","reduce_motion",motion)
    UI.reload_prefs()   # UI.reduce_motion() reads the new value this session
    var b = content.get_node("ReduceMotion") as Button
    b.text = "Reduce motion: " + ("On" if motion else "Off")

# Screen mode (Claude, 2026-10-22, GS-01): the row and F11 both go through UI.apply_screen_mode, which sets
# the window and saves display/fullscreen; the row reads the window itself, so it never claims a mode it is not in.
func _full_screen() -> bool:
    var mode = DisplayServer.window_get_mode()
    return mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

func _screen_words() -> String:
    return "Screen: " + ("Full screen" if _full_screen() else "Windowed")

func toggle_screen() -> void:
    UI.apply_screen_mode(not _full_screen())
    var b = content.get_node_or_null("ScreenMode") as Button
    if b != null: b.text = _screen_words()

# Text speed (GS-03): Normal, Fast, Instant, round again; UI.typed() reads it.
func _speed_words() -> String:
    return "Text: " + SPEED_NAMES[UI.text_speed()]

func cycle_text_speed() -> void:
    _save("menu","text_speed",SPEED_NEXT[UI.text_speed()])
    UI.reload_prefs()
    var b = content.get_node_or_null("TextSpeed") as Button
    if b != null: b.text = _speed_words()

func _restore_music() -> void:
    if is_instance_valid(music_node): music_node.process_mode = music_mode

func resume() -> void:
    if releasing or transition: return
    releasing = true
    _tick("close")
    # Raw key polling in the game must not see the closing Enter/Escape as a turn. Pause and Back are read as
    # actions, so a rebound key or a pad's Start and B are waited out too (Claude, 2026-10-23).
    while Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_cancel") or UI.held("pause") or UI.held("cancel") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        await get_tree().process_frame
    overlay.hide()
    hint.show()
    _restore_music()
    get_tree().paused = false
    releasing = false

func leave() -> void:
    if transition: return
    transition = true
    # Leaving from Highbank keeps what the town changed since the last arrival (jobs, story), the same save
    # Continue reads (Claude, 2026-10-12). Leaving a run keeps the run: Continue resumes it at the top of
    # its floor, once (dungeon.suspend()). Any room that keeps the team record autosaves the same way, not
    # only the Storage (Claude, 2026-10-22, FLOW-09).
    var host = get_parent()
    if host != null and (host.has_method("enter_hollow") or host.has_method("_record")):
        host._record()
        preload("res://scripts/town/team_state.gd").autosave()
    elif host != null and host.has_method("suspend"):
        host.suspend()
    if page == "quit":
        get_tree().quit()
        return
    # The black fade first, as every other exit of ours (Claude, 2026-10-24, LV-07b): it runs while the tree is
    # still paused, then the title opens under it and it lifts (the title does not lift a fade itself).
    var tree = get_tree()
    await UI.fade_out(tree)
    _restore_music()
    tree.paused = false
    var err = tree.change_scene_to_file(TITLE)
    UI.fade_in(tree)
    if err != OK:
        transition = false
        tree.paused = true
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
    # F11 switches full screen wherever this menu is attached, open or not (Claude, 2026-10-22, GS-01).
    # Pause (P, Start), full screen (F11) and back (Esc, B; the "cancel" action too, so a rebound Back works
    # here) are actions now, read through UI.pressed so the pad's chord rule holds: RB+B rests, it never opens
    # this menu (Claude, 2026-10-23, FEEL-01). The rebinding page takes every press first while it listens.
    if UI.pressed(event,"fullscreen"):
        toggle_screen()
        get_viewport().set_input_as_handled()
        return
    var p = UI.pressed(event,"pause")
    # Open, Back is the engine's ui_cancel as on every menu button (RB+B too); closed, the chord rule decides.
    var cancel = (event.is_action_pressed("ui_cancel") and not event.is_echo()) if overlay.visible else UI.pressed(event,"ui_cancel")
    cancel = UI.pressed(event,"cancel") or cancel
    if not p and not cancel: return
    if overlay.visible:
        if page == "main": resume()
        else:
            _tick("cancel")
            show_page(PARENT_PAGE.get(page,"main"))
    elif p or not _has_modal(): open()
    else: return
    get_viewport().set_input_as_handled()

func _exit_tree() -> void:
    _restore_music()
    if overlay != null and overlay.visible and get_tree() != null: get_tree().paused = false
