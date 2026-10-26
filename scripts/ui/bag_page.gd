extends HBoxContainer
## Presentation only. Names/effects come from dungeon.item_info; the pause menu owns use.
const UI = preload("res://scripts/ui/ui_style.gd")
var scroll: ScrollContainer
var rows: VBoxContainer
var portrait: TextureRect
var item_name: Label
var count: Label
var effect: Label
var instruction: Label
var selected_kind = ""
var _shown: Dictionary = {}   # the entry the detail panel shows, so the key hint can be retold
var _can_use = false

func _label(text: String, role: String, color: Color = UI.TEXT) -> Label:
    var label = Label.new()
    label.text = text
    _set_role(label,role)
    label.add_theme_color_override("font_color",color)
    label.add_theme_color_override("font_shadow_color",UI.SHADOW)
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    return label

func _set_role(label: Label, role: String) -> void:
    label.add_theme_font_override("font",UI.font(role))
    label.add_theme_font_size_override("font_size",UI.type_size(role))
    label.add_theme_constant_override("shadow_offset_x",int(UI.TYPE[role]["px"]))
    label.add_theme_constant_override("shadow_offset_y",int(UI.TYPE[role]["px"]))

func setup(entries: Array, can_use: bool, menu: CanvasLayer) -> void:
    name = "BagPage"
    custom_minimum_size.y = 336
    add_theme_constant_override("separation",18)
    scroll = ScrollContainer.new()
    scroll.name = "ItemScroll"
    scroll.custom_minimum_size = Vector2(446,336)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    add_child(scroll)
    # The pixel scrollbar the rebind page and the shrine use, cut from the UI frames (Claude, 2026-10-24, LO6-03; it was
    # flat boxes). Its width is kept clear, so the rows stop at the bar instead of running under it.
    UI.style_scroll_bar(scroll.get_v_scroll_bar())
    rows = VBoxContainer.new()
    rows.name = "ItemRows"
    rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    rows.add_theme_constant_override("separation",8)
    scroll.add_child(rows)
    var panel = PanelContainer.new()
    panel.name = "ItemDetail"
    panel.custom_minimum_size.x = 392
    var frame = UI.frame("panel_dim").duplicate()
    frame.set_content_margin_all(24)
    panel.add_theme_stylebox_override("panel",frame)
    add_child(panel)
    var detail = VBoxContainer.new()
    detail.add_theme_constant_override("separation",10)
    panel.add_child(detail)
    var top = HBoxContainer.new()
    top.add_theme_constant_override("separation",16)
    detail.add_child(top)
    portrait = TextureRect.new()
    portrait.name = "ItemIcon"
    portrait.custom_minimum_size = Vector2(96,96)
    portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    portrait.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
    # Explicit 3x native icon, rather than fitting it to a changing panel ratio.
    portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    top.add_child(portrait)
    var stock = VBoxContainer.new()
    stock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    stock.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    top.add_child(stock)
    stock.add_child(_label("CARRIED","label",UI.MUTED))
    count = _label("","number",UI.EDGE_LIGHT)
    stock.add_child(count)
    item_name = _label("","name",UI.EDGE_LIGHT)
    item_name.name = "ItemName"
    detail.add_child(item_name)
    effect = _label("","body")
    effect.name = "ItemEffect"
    effect.size_flags_vertical = Control.SIZE_EXPAND_FILL
    detail.add_child(effect)
    instruction = _label("","body",UI.MUTED)
    detail.add_child(instruction)
    for entry in entries:
        var button: Button = menu._button("%s x%d" % [entry["name"],entry["count"]])
        button.name = "Use_" + String(entry["kind"]).replace(":","_")
        button.custom_minimum_size.y = 72
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.icon = UI.item_icon(entry["kind"])
        button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        button.add_theme_constant_override("h_separation",16)
        button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
        var role = UI.fit(button.text,"name",328)
        button.add_theme_font_override("font",UI.font(role))
        button.add_theme_font_size_override("font_size",UI.type_size(role))
        rows.add_child(button)
        menu.controls.append(button)
        button.focus_entered.connect(_select.bind(entry,can_use,button,true))
        button.mouse_entered.connect(_select.bind(entry,can_use,button,false))
        if can_use:
            button.pressed.connect(menu._use_item.bind(entry["kind"]))
        else:
            button.pressed.connect(_select.bind(entry,false,button,true))
    if entries.is_empty():
        rows.add_child(_label("The bag is empty.","name",UI.MUTED))
        item_name.text = "Nothing carried"
        effect.text = "Items you pick up on a route will appear here."
        count.text = "0"
        portrait.hide()
    else:
        _select(entries[0],can_use,null,false)

func _select(entry: Dictionary, can_use: bool, button: Button, reveal: bool) -> void:
    selected_kind = entry["kind"]
    var icon = UI.item_icon(selected_kind)
    if icon != null:
        var enlarged = icon.get_image()
        enlarged.resize(96,96,Image.INTERPOLATE_NEAREST)
        portrait.texture = ImageTexture.create_from_image(enlarged)
    else:
        portrait.texture = null
    item_name.text = entry["name"]
    count.text = "x%d" % entry["count"]
    effect.text = entry["what"]
    _shown = entry
    _can_use = can_use
    retell()
    if reveal and button != null:
        scroll.ensure_control_visible.call_deferred(button)

# The key, two spaces, what it does: the house column style for hints (Claude, 2026-10-22, W12). The key is
# ui_accept's, the action these rows answer to, for the device in use (Enter or A); in capitals in the label face,
# as the Hollow's quick bag hint reads ("KEY  USE", D8). The menu calls this again when the device changes
# (Claude, 2026-10-24, LV-21).
func retell() -> void:
    if _shown.is_empty(): return
    if not _can_use:
        _set_role(instruction,"body")
        instruction.text = "Items are used in the Hollow."
        return
    var key = UI.binding_text("ui_accept")
    _set_role(instruction,"label")
    instruction.text = ("%s  learn the move" % key if String(_shown["kind"]).begins_with("scroll:") else "%s  use" % key).to_upper()
