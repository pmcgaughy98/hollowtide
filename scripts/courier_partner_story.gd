extends Node
## First-morning story proposal. Run-local; ownership is committed by PlayerParty.add.
const STARTERS: Array[CreatureData] = [preload("res://data/creatures/103_kithflare.tres"),preload("res://data/creatures/1701_tallowroot.tres"),preload("res://data/creatures/001_rimefin.tres")]
const PORTRAITS: Array[SpriteFrames] = [preload("res://data/portraits/kithflare_front_idle.tres"),preload("res://data/portraits/tallowroot_front_idle.tres"),preload("res://data/portraits/rimefin_front_idle.tres")]
const ACCENTS := [Color("#ffb881"),Color("#bbd991"),Color("#9fd5ef")]
const SPOTS := [Vector2(64,118),Vector2(64,176),Vector2(176,163)]
const RESPONSES := [
    "A loose strap slips from your bundle. Kithflare catches it before it reaches the floor, then waits for you to take the other end. Quick to act; reluctant to stand still.",
    "Tallowroot settles beside you while you retie a bag. It holds the trailing cord in place and waits until the knot is secure. Patient work, done together.",
    "Rimefin watches a damp patch creep toward the outgoing mail. It nudges the nearest bag into your reach. You lift it onto the dry shelf before the water reaches it.",
]
const ROLES := ["EMBER / Quick-footed harasser","BLOOM / Patient field controller","TIDE / Ranged river hunter"]
var journey: Node2D
var reduce_motion := false
var introduced := false
var straps_collected := false
var met: Dictionary = {}
var completed := false
var selected := -1
var _sprites: Array[Sprite2D] = []
var _captions: Array[Label] = []
var _arrival_pending := false
var _clock := 0.0
var _frame := -1

func _ready() -> void:
    name = "FirstMorning"
    journey = get_parent()

func objective() -> String:
    if completed: return ""
    if not introduced: return "FIRST MORNING  /  Meet the dispatcher at the hall"
    if not straps_collected: return "FIRST MORNING  /  Collect spare straps from the sorting shelves"
    if met.size() < 3: return "FIRST MORNING  /  Help with the mail alongside each partner (%d / 3)" % met.size()
    return "FIRST MORNING  /  Return to the partner you want to travel with"

func enter_area(id: String, area: Node2D) -> void:
    if id != "courier_hall" or completed or area.has_node("PartnerGathering"): return
    var marker := Node.new()
    marker.name = "PartnerGathering"
    area.add_child(marker)
    for i in STARTERS.size():
        var sprite := Sprite2D.new()
        sprite.name = STARTERS[i].creature_name+"Waiting"
        sprite.texture = STARTERS[i].idle_frames[0]
        var used := sprite.texture.get_image().get_used_rect()
        var ratio := 36.0/float(used.size.y)
        sprite.scale = Vector2.ONE*ratio
        sprite.offset.y = sprite.texture.get_height()*0.5-used.end.y
        sprite.position = SPOTS[i]
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        area.get_node("RouteDecor").add_child(sprite)
        _sprites.append(sprite)
        var caption := Label.new()
        caption.text = STARTERS[i].creature_name
        caption.position = SPOTS[i]+Vector2(-27,3)
        caption.add_theme_font_override("font",preload("res://assets/fonts/Silkscreen-Regular.ttf"))
        caption.add_theme_font_size_override("font_size",7)
        caption.add_theme_color_override("font_color",ACCENTS[i])
        caption.add_theme_constant_override("outline_size",2)
        area.add_child(caption)
        _captions.append(caption)

func nearest_partner() -> int:
    if journey.active_id != "courier_hall" or completed: return -1
    var player: Node2D = journey.active_area.get_node("Player")
    var nearest := -1
    var distance := 27.0
    for i in SPOTS.size():
        var gap := player.position.distance_to(SPOTS[i])
        if gap < distance: distance = gap; nearest = i
    return nearest

func hint() -> String:
    if completed or journey.active_id != "courier_hall": return ""
    var partner := nearest_partner()
    if partner >= 0 and straps_collected: return "E  Meet " + STARTERS[partner].creature_name
    if journey.active_area.nearest_site() == "sorting" and introduced: return "E  Collect spare straps"
    return ""

func interact() -> bool:
    if completed or journey.active_id != "courier_hall": return false
    var site: String = journey.active_area.nearest_site()
    if site == "dispatch" and not straps_collected:
        introduced = true
        journey.route._show_message("DISPATCHER\nThe old landing missed its morning return mark. I need a courier to take the next pouch and find out why. These three came back with the river crews; none has settled on a travelling partner. Help them with the outgoing mail first. Spare straps are on the shelves to your right.")
        return true
    if introduced and not straps_collected and site == "sorting":
        straps_collected = true
        journey.route._show_message("OUTGOING MAIL\nYou gather the loose straps. Three small helpers are waiting around the room. Work beside each one before deciding who you would trust on the road.")
        return true
    var index := nearest_partner()
    if index >= 0:
        if not straps_collected:
            journey.route._show_message(STARTERS[index].creature_name.to_upper()+"\nThe little helper watches the busy counter. Speak to the dispatcher before joining the morning work.")
        else:
            met[index] = true
            _meeting(index)
        return true
    if site == "dispatch":
        journey.route._show_message("DISPATCHER\nA good route partner is someone you can work with. Spend a moment with each helper, then go back to the one you want beside you. The others will stay here with the river crews.")
        return true
    return false

func _meeting(index: int) -> void:
    var body: String = STARTERS[index].creature_name.to_upper()+"\n"+RESPONSES[index]+"\n"+ROLES[index]
    journey.route._show_message(body)
    if met.size() < 3: return
    var choices: VBoxContainer = journey.route.get("_choices")
    for child in choices.get_children():
        choices.remove_child(child)
        child.queue_free()
    journey.route.get("_body").text = body+"\nYour work is done. Invite this partner to travel with you?"
    for item in [["Travel with "+STARTERS[index].creature_name,true],["Keep meeting the others",false]]:
        var button := Button.new()
        button.text = item[0]
        journey.route._style_route_button(button)
        button.pressed.connect(_answer.bind(index,item[1]))
        choices.add_child(button)
    choices.show()
    choices.get_child(0).grab_focus.call_deferred()

func _answer(index: int, accept: bool) -> void:
    journey.route.get("_choices").hide()
    if not accept:
        journey.route.get("_panel").hide()
        journey.active_area.get_node("Player").set_physics_process(true)
        return
    if completed: return
    if not PlayerParty.add(STARTERS[index]):
        journey.route._show_message("There is no room in your party. Make room before inviting a new partner.")
        return
    selected = index
    completed = true
    _sprites[index].hide()
    _captions[index].hide()
    journey.route._show_message("YOUR FIRST PARTNER\n"+STARTERS[index].creature_name+" leaves its place by the mail and comes to your side. The dispatcher ties a route ribbon to your bag.\n\"Good. Now collect your sealed pouch at the counter. You will face the missing return mark together.\"")
    _arrival_pending = true
    journey.route._refresh_objective()

func _input(event: InputEvent) -> void:
    if not completed and event.is_action_pressed("ui_cancel") and journey.route.get("_choices").visible:
        _answer(0,false)
        get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
    if _arrival_pending and journey.active_id != "courier_hall" and not journey.route.get("_panel").visible:
        _arrival_pending = false
        var welcome := preload("res://scripts/first_partner_arrival.gd").new()
        welcome.creature = STARTERS[selected]
        welcome.portrait_frames = PORTRAITS[selected]
        welcome.accent = ACCENTS[selected]
        welcome.reduce_motion = reduce_motion
        journey.add_child(welcome)
    _clock += delta
    var frame := 0 if reduce_motion else int(_clock*8.0)%8
    if frame == _frame: return
    _frame = frame
    for i in _sprites.size():
        if is_instance_valid(_sprites[i]): _sprites[i].texture = STARTERS[i].idle_frames[frame]
