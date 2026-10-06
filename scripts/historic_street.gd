extends Node2D
## A cached historic street with run-local address observations.
## It shares the original courier dialogue/notes; no new save or reward system.
const TILESET = preload("res://assets/tilesets/route1_rd_2026_10_01/route1_ground_polished.tres")
const SHOP = preload("res://assets/sprites/world/world_linework_2026_10_04/brick_shop.png")
const LEDGER = preload("res://assets/sprites/world/world_linework_2026_10_04/ledger_house.png")
const STREET = preload("res://assets/sprites/world/historic_frontage_2026_10_04/street_pavers.png")
const WORKSHOP = preload("res://assets/sprites/world/historic_frontage_2026_10_04/repair_workshop.png")
const ROWHOMES = preload("res://assets/sprites/world/historic_frontage_2026_10_04/rear_rowhomes.png")
const KEEPER = preload("res://assets/sprites/world/historic_frontage_2026_10_04/workshop_keeper.png")
const MARK = preload("res://assets/sprites/world/route1_rd_2026_10_01/marker.png")
const GROUND = preload("res://assets/sprites/world/route1_landscape_2026_10_03/ground_variation.gdshader")
const CANOPY = preload("res://assets/sprites/world/route1_landing_loop_2026_10_03/canopy_visibility.gdshader")
const FONT = preload("res://assets/fonts/Silkscreen-Regular.ttf")
const SHRUB = preload("res://assets/sprites/world/route1_rd_2026_10_02/bank_shrub_4.png")
const TREES = [
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_north.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_bank_bend.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_east.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_office_grove.png"),
	preload("res://assets/sprites/world/route1_rd_2026_10_02/cottonwood_ridge.png"),
]
const SITES = {"board":Vector2(384,664),"shop":Vector2(544,428),"ledger":Vector2(224,428),"keeper":Vector2(424,438),"homes":Vector2(365,244),"workshop":Vector2(384,428)}
const TREE_POINTS = [
	Vector2(72,160),Vector2(168,160),Vector2(288,168),Vector2(480,168),Vector2(600,160),Vector2(696,184),
	Vector2(72,368),Vector2(696,384),Vector2(80,576),Vector2(688,576),
	Vector2(96,784),Vector2(192,816),Vector2(576,816),Vector2(672,784),
]
var started := false
var lintel_checked := false
var ledger_checked := false
var handoff_verified := false
var last_submitted_number := 0
var _route: Node2D
var _status: Label
var _trees: Array[Sprite2D] = []
func _ready() -> void:
	if get_parent() == get_tree().root:
		call_deferred("_open_journey")
		return
	_route = get_parent().get("route")
	var ground := TileMapLayer.new()
	ground.name="Terrain";ground.tile_set=TILESET
	ground.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;ground.z_index=-10
	var material:=ShaderMaterial.new();material.shader=GROUND;ground.material=material
	for x in 48:
		for y in 56:ground.set_cell(Vector2i(x,y),0,Vector2i(posmod(x*3+y,2),0))
	add_child(ground)
	var street:=Sprite2D.new()
	street.name="HistoricPaving";street.texture=STREET;street.centered=false;street.z_index=-7
	street.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;add_child(street)
	var shop:=_prop("RemodelledBrickShop",SHOP,Vector2(544,400),0.85)
	_solid("ShopFootprint",Rect2(468,336,152,62))
	_prop("PublicLedgerHouse",LEDGER,Vector2(224,400),0.85)
	_solid("LedgerFootprint",Rect2(160,326,128,74))
	# Infill stays behind grounded entrance lanes; the keeper is courier-sized.
	_prop("OccupiedRepairWorkshop",WORKSHOP,Vector2(384,400),0.75)
	_solid("WorkshopFootprint",Rect2(332,326,104,74))
	_prop("UpperFloorRowhomes",ROWHOMES,Vector2(384,224),0.85)
	_solid("RowhomeFootprint",Rect2(307,159,154,65))
	var keeper:=_prop("WorkshopKeeper",KEEPER,Vector2(424,426),0.5)
	_solid("KeeperFeet",Rect2(-4,-4,8,4),keeper)
	# Separate current shop fitting from the retained doorway lintel.
	_sign("CurrentShopAddress","18",Vector2(538,332),8)
	_label("OldShopLintel","6",Vector2(541,363))
	_sign("LedgerCaption","LEDGER",Vector2(212,341),6)
	var board:=_prop("StreetCourierBoard",MARK,Vector2(384,644),0.75)
	_solid("BoardFoot",Rect2(-3,-5,6,5),board)
	_status=_label("AddressBoardStatus","",Vector2(336,604))
	_label("ReturnWaymark","BRANCH / BRIDGE V",Vector2(334,795))
	for i in TREE_POINTS.size():
		var tree:=_prop("HistoricCottonwood%02d"%i,TREES[i%TREES.size()],TREE_POINTS[i])
		_solid("FootCollision",Rect2(-5,-6,10,7),tree)
		var canopy:=ShaderMaterial.new();canopy.shader=CANOPY
		canopy.set_shader_parameter("canopy_opacity",1.0);tree.material=canopy;_trees.append(tree)
	for at in [Vector2(120,456),Vector2(648,456),Vector2(256,600),Vector2(512,600),Vector2(272,776),Vector2(496,776)]:
		_prop("PlantedStreetEdge%d%d"%[int(at.x),int(at.y)],SHRUB,at,0.65)
	for item in [
		["NorthEdge",Rect2(0,-16,768,16)],["WestEdge",Rect2(-16,0,16,896)],
		["EastEdge",Rect2(768,0,16,896)],["SouthWestEdge",Rect2(0,896,344,16)],
		["SouthEastEdge",Rect2(424,896,344,16)]]:
		_solid(item[0],item[1])
	var camera:Camera2D=$Player/Camera2D
	camera.limit_left=0;camera.limit_right=768;camera.limit_top=0;camera.limit_bottom=896
	camera.offset=Vector2.ZERO;camera.position=Vector2(0,-80)
	camera.reset_smoothing()
	_update_board()
func _prop(label:String,texture:Texture2D,at:Vector2,ratio:float=1.0) -> Sprite2D:
	var sprite:=Sprite2D.new()
	sprite.name=label;sprite.texture=texture;sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position=at;sprite.scale=Vector2.ONE*ratio
	var used:=texture.get_image().get_used_rect()
	sprite.offset.y=floorf(texture.get_height()*0.5)-used.end.y
	$RouteDecor.add_child(sprite);return sprite
func _solid(label:String,bounds:Rect2,parent:Node=null) -> void:
	var body:=StaticBody2D.new();body.name=label;body.position=bounds.get_center()
	var shape:=CollisionShape2D.new();var rectangle:=RectangleShape2D.new()
	rectangle.size=bounds.size;shape.shape=rectangle;body.add_child(shape)
	(self if parent==null else parent).add_child(body)
func _label(label:String,text:String,at:Vector2) -> Label:
	var caption:=Label.new();caption.name=label;caption.text=text;caption.position=at;caption.z_index=9
	caption.add_theme_font_override("font",FONT);caption.add_theme_font_size_override("font_size",8)
	caption.add_theme_color_override("font_color",Color("#e5ddba"))
	caption.add_theme_color_override("font_outline_color",Color("#293831"))
	caption.add_theme_constant_override("outline_size",1);add_child(caption);return caption
func _sign(label:String,text:String,at:Vector2,size:int) -> Label:
	var ink:=_label(label,text,at)
	ink.add_theme_font_size_override("font_size",size)
	ink.add_theme_color_override("font_color",Color("#49362a"))
	ink.add_theme_constant_override("outline_size",0)
	return ink

func nearest_site() -> String:
	var closest:="";var distance:=28.0
	for site in SITES:
		var gap:float=$Player.position.distance_to(SITES[site])
		if gap<distance:distance=gap;closest=site
	return closest
func interaction_hint() -> String:
	match nearest_site():
		"board":return "E  Read street courier board"
		"shop":return "E  Compare shop doorway numbers"
		"ledger":return "E  Read public street ledger"
		"keeper":return "E  Talk to workshop keeper"
		"homes":return "E  Read residential doorstep notice"
		"workshop":return "E  Look at repair workshop"
	return "WASD / arrows  Move	South lane returns to riverfront"
func interact(_controller:Node2D) -> void:
	match nearest_site():
		"board":visit_board()
		"shop":visit_shop()
		"ledger":visit_ledger()
		"keeper":visit_keeper()
		"homes":visit_homes()
		"workshop":visit_workshop()
func _process(delta:float) -> void:
	var courier:Node2D=$Player
	for tree in _trees:
		var head:=tree.to_local(courier.global_position+Vector2(0,-16))
		var covered:bool=courier.global_position.y<tree.global_position.y-2 and tree.get_rect().has_point(head)
		var current:float=tree.material.get_shader_parameter("canopy_opacity")
		tree.material.set_shader_parameter("canopy_opacity",move_toward(current,0.35 if covered else 1.0,delta*3))

# Prototype resident text uses the existing dialogue panel and local activity.
func visit_keeper() -> void:
	var text := "WORKSHOP KEEPER\nThese buildings get new fittings without losing their old doorways. If a parcel label and a lintel disagree, the public ledger across the street has today's address."
	if lintel_checked and ledger_checked and not handoff_verified:
		text = "WORKSHOP KEEPER\nYou have both versions now. Take the current street address to the courier at the riverfront branch; the older lintel can stay where it is."
	elif handoff_verified:
		text = "WORKSHOP KEEPER\nThe shop route is marked eighteen now. A new fitting is useful, but you do not have to tear out the old stone to keep the street working."
	_route.call("_show_message",text)

func visit_homes() -> void:
	_route.call("_show_message","RESIDENTIAL DOORSTEP\nA small notice asks delivery runners to knock at each ground-floor door. The separate upstairs curtains and repaired thresholds show that the old row is still lived in.")

func visit_workshop() -> void:
	_route.call("_show_message","REPAIR WORKSHOP\nTools hang in the display windows beneath a worn awning. The keeper is outside, within speaking distance of the doorway.")

func visit_board() -> void:
	started = true
	var text := "CITY ADDRESS CHECK\nThe branch has two address labels for the repaired shop. Compare the old doorway number with the public street ledger, then take the current address back to the city courier."
	if handoff_verified: text = "CITY ADDRESS CHECK\nThe shop handoff is now marked 18. The older lintel remains part of the building; today's courier route uses the street ledger."
	_route.call("_show_message", text)
	_update_board()
	_route.call("_refresh_objective")

func visit_shop() -> void:
	started = true
	lintel_checked = true
	_route.call("_show_message", "REPAIRED SHOP\nThe doorway lintel still carries 6. The new sign above the awning reads 18. The brick frontage is older than this shop's fittings; check the public ledger before choosing a route label.")
	_update_board()
	_route.call("_refresh_objective")

func visit_ledger() -> void:
	started = true
	ledger_checked = true
	_route.call("_show_message", "PUBLIC STREET LEDGER\nOld doorway 6 and current street address 18 refer to the same shop. The street was renumbered; the old lintel was kept. Use 18 for a current courier handoff.")
	_update_board()
	_route.call("_refresh_objective")

func offer_handoff_if_requested() -> bool:
	if not started: return false
	if handoff_verified:
		var report_note:String = "Your first route report is already on the hometown board." if _route.get("report_done") else "Your landing report still goes to the hometown dispatcher."
		_route.call("_show_message", "CITY COURIER\nThe shop route is already marked 18. The ledger and the old doorway agree on the building. " + report_note)
		return true
	if not lintel_checked or not ledger_checked:
		_route.call("_show_message", "CITY COURIER\nCheck both the old shop doorway and the public street ledger before I update the label. Take the northern marked lane into the historic street.")
		return true
	_route.call("_show_message", "CITY COURIER\nWhich number belongs on the current shop handoff?")
	var body: Label = _route.get("_body")
	body.text = "CITY COURIER\nWhich number belongs on the current shop handoff?"
	var choices: VBoxContainer = _route.get("_choices")
	for child in choices.get_children():
		choices.remove_child(child);child.queue_free()
	choices.show()
	for number in [6, 18]:
		var button := Button.new()
		button.text = "Old doorway number: 6" if number == 6 else "Current street address: 18"
		_route.call("_style_route_button", button)
		button.pressed.connect(_record_handoff.bind(number))
		choices.add_child(button)
		if number == 6: button.grab_focus()
	return true

func _record_handoff(number: int) -> void:
	last_submitted_number = number
	var choices: VBoxContainer = _route.get("_choices")
	for child in choices.get_children():
		choices.remove_child(child);child.queue_free()
	choices.hide()
	if number == 18 and lintel_checked and ledger_checked:
		handoff_verified = true
		_route.call("_show_message", "CITY COURIER\nI have marked the shop handoff 18. We can keep the old lintel without sending today's runner to an old address label. The street board now shows the verified route.")
	else:
		_route.call("_show_message", "CITY COURIER\nSix belongs to the old lintel. Today's ledger lists 18. Check the records again if you need to; the handoff is still open.")
	_update_board()
	_route.call("_refresh_objective")

func _update_board() -> void:
	_status.text = "18 / VERIFIED" if handoff_verified else ("REPORT AT BRANCH" if lintel_checked and ledger_checked and started else "ADDRESS CHECK")
	queue_redraw()

func objective_text() -> String:
	if not started: return "HISTORIC STREET  /  Read the street courier board"
	if handoff_verified: return "CITY HANDOFF COMPLETE  /  Shop address verified"
	if lintel_checked and ledger_checked: return "CITY HANDOFF  /  Report at the courier branch"
	return "CITY HANDOFF  /  Compare shop doorway and street ledger"

func board_summary() -> String:
	return "Current address 18 verified" if handoff_verified else "Doorway / ledger comparison open"

func notes_text() -> String:
	if not started and not lintel_checked and not ledger_checked: return ""
	var text := "\nCITY ADDRESS CHECK\n"
	if started: text += "Compare the repaired shop with the public street ledger.\n"
	if lintel_checked: text += "Shop lintel: old 6. New sign: 18.\n"
	if ledger_checked: text += "Ledger: old 6 and current 18 identify the same building.\n"
	if handoff_verified: text += "Reported: use current handoff address 18.\n"
	else: text += "Current handoff has not been verified at the branch.\n"
	return text


func _open_journey() -> void:
	var connected:Node2D=load("res://scenes/world_journey.tscn").instantiate()
	connected.initial_area="historic_street"
	get_tree().root.add_child(connected)
	get_tree().current_scene=connected
	queue_free()
