extends Node2D

## Run-local shared-garden activity in the cached hometown.
## Resident text is a prototype proposal; no quest, inventory, rewards or saves.
## Install after the four prepared native assets are available.
const LANES = preload("res://assets/sprites/world/hometown_garden_2026_10_04/garden_lanes.png")
const BED = preload("res://assets/sprites/world/hometown_garden_2026_10_04/timber_bed.png")
const CUTTINGS = preload("res://assets/sprites/world/hometown_garden_2026_10_04/cuttings_row.png")
const NEIGHBOR = preload("res://assets/sprites/world/hometown_garden_2026_10_04/garden_neighbor.png")
const SITES := {
	"garden_neighbor": Vector2(368, 504),
	"garden_row": Vector2(484, 582),
}
const LEFT_BED := Rect2(377, 518, 54, 50)
const RIGHT_BED := Rect2(457, 518, 54, 50)
const NEIGHBOR_FOOT := Vector2(368, 480)
const NOTICE_FOOT := Vector2(472, 594)
const REACH := 30.0

var cuttings_offered := false
var cuttings_planted := false
var planted_sprites: Array[Sprite2D] = []
var native_bounds: Dictionary = {}
var _area: Node2D
var _decor: Node2D
var _right_bed: Node2D


func _ready() -> void:
	_area = get_parent()
	_decor = _area.get_node("RouteDecor")
	# Prepared 1024x768 transparent surface, using the original soil material.
	var lanes := Sprite2D.new()
	lanes.name = "SharedGardenLanes"
	lanes.texture = LANES
	lanes.centered = false
	lanes.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	lanes.z_index = -6
	add_child(lanes)

	var left_bed := _build_bed("SharedGardenLeftBed", LEFT_BED)
	_add_cuttings_rows(left_bed, "ExistingCuttings")
	_right_bed = _build_bed("SharedGardenRightBed", RIGHT_BED)
	var neighbor := _foot_sprite("GardenNeighbor", NEIGHBOR, NEIGHBOR_FOOT, _decor)
	_solid("NeighborFeet", Rect2(-4, -4, 8, 4), neighbor)
	# Landscape owns the reused notice and its small foot collision.
	# NOTICE_FOOT records the shared layout without adding a duplicate sign.


func _build_bed(label: String, bounds: Rect2) -> Node2D:
	var bed_group := Node2D.new()
	bed_group.name = label
	bed_group.position = Vector2(bounds.position.x + bounds.size.x * 0.5, bounds.end.y)
	# Sort each bed and its plants together against the courier's feet.
	bed_group.y_sort_enabled = false
	_decor.add_child(bed_group)
	_foot_sprite("TimberBed", BED, Vector2.ZERO, bed_group)
	_solid("BedFootprint", Rect2(Vector2(-bounds.size.x * 0.5, -bounds.size.y), bounds.size), bed_group)
	return bed_group


func _add_cuttings_rows(bed_group: Node2D, prefix: String) -> Array[Sprite2D]:
	var rows: Array[Sprite2D] = []
	# Native 38x18 rows fit the 54x50 bed without resampling.
	# Root anchors at y536, y548 and y560; foliage rises above the rear rim.
	for row in range(3):
		var sprite := _foot_sprite(prefix + str(row), CUTTINGS, Vector2(0, -32 + row * 12), bed_group)
		rows.append(sprite)
	return rows


func _foot_sprite(label: String, texture: Texture2D, foot: Vector2, parent: Node2D) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.name = label
	sprite.texture = texture
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = foot
	# Measure visible pixels rather than assuming transparent padding is empty.
	# Integer offsets keep the prepared native art on the logical grid.
	var used: Rect2i = texture.get_image().get_used_rect()
	sprite.offset = Vector2(-floorf(used.position.x + used.size.x * 0.5), -used.end.y)
	parent.add_child(sprite)
	var visible_top_left := sprite.global_position + sprite.offset + Vector2(used.position)
	native_bounds[str(sprite.get_path())] = Rect2(visible_top_left, Vector2(used.size))
	return sprite


func _solid(label: String, bounds: Rect2, parent: Node2D) -> void:
	var body := StaticBody2D.new()
	body.name = label
	body.position = bounds.get_center()
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = bounds.size
	shape.shape = rectangle
	body.add_child(shape)
	parent.add_child(body)


func nearest_site(player_position: Vector2) -> String:
	var closest := ""
	var distance := REACH
	for site in SITES:
		var gap: float = player_position.distance_to(SITES[site])
		if gap < distance:
			distance = gap
			closest = site
	return closest


func hint(site: String) -> String:
	match site:
		"garden_neighbor":
			return "E  Talk to garden neighbor"
		"garden_row":
			if cuttings_planted:
				return "E  Check planted cuttings"
			if cuttings_offered:
				return "E  Plant shared cuttings"
			return "E  Check open garden bed"
		"garden":
			return "E  Read shared garden notice"
	return ""


func interact(site: String, controller: Node2D) -> void:
	match site:
		"garden_neighbor":
			_visit_neighbor(controller)
		"garden_row":
			_visit_open_bed(controller)
		"garden":
			controller.call("_show_message", notice_text())


func _visit_neighbor(controller: Node2D) -> void:
	var text := "GARDEN NEIGHBOR\nThe left bed is planted. We left the right bed open for these spare cuttings. You can plant them from the southern aisle; keep your feet out of the beds."
	if cuttings_planted:
		text = "GARDEN NEIGHBOR\nThose three rows are in. The new cuttings are easy to see against the open soil. Thanks for helping, and keep to the aisles while they settle."
	elif cuttings_offered:
		text = "GARDEN NEIGHBOR\nThe shared cuttings are ready for the open bed on the right. Walk around to its southern edge and leave space between the rows."
	else:
		cuttings_offered = true
	controller.call("_show_message", text)


func _visit_open_bed(controller: Node2D) -> void:
	if cuttings_planted:
		controller.call("_show_message", "SHARED CUTTINGS\nThree fresh rows fill the right bed. The cuttings are still small, with open soil between them. The walking aisles remain clear.")
		return
	if not cuttings_offered:
		controller.call("_show_message", "OPEN GARDEN BED\nThe right bed has room for three rows. The neighbor beside the northern aisle has the shared cuttings; speak to them before planting.")
		return
	# Set state before adding art, so repeated interactions create no duplicates.
	cuttings_planted = true
	planted_sprites = _add_cuttings_rows(_right_bed, "PlantedCuttings")
	controller.call("_show_message", "SHARED CUTTINGS\nYou place the spare cuttings in three spaced rows. Both timber beds are planted now, and the aisles around them are clear.")


func notice_text() -> String:
	if cuttings_planted:
		return "SHARED GARDEN\nBoth timber beds hold cuttings now. Keep to the aisles around and between the beds. The garden neighbor is beside the northern aisle."
	return "SHARED GARDEN\nKeep to the aisles around and between the timber beds. The neighbor beside the northern aisle has spare cuttings for the open bed on the right."
