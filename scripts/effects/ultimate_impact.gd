class_name UltimateImpact
extends RefCounted
## The shared layers of a signature move's hit (Preston, 2026-09-30: signatures
## are ultimate moves, the creature's most powerful attack, and the Kingstone
## Rail landing is the bar). Each signature effect calls these with its own
## colours and adds its own drawn pieces on top:
##   omen()   a glowing ground marker under the target that grows until the hit
##   flash()  the whole screen, HUD included, flashes and drops back in steps
##   column() a column of energy between the sky and the target, narrowing away
##   debris() chips and sparks thrown up and falling back under gravity
## Everything is built from whole art pixels (`px` screen pixels each) and
## moves in steps, 12 a second, like drawn frames.
##
## `palette` is four colours, darkest to brightest.

const STEPS := 12.0


static func _snap(pos: Vector2, px: float) -> Vector2:
	return (pos / px).round() * px


static func _block(parent: Node, pos: Vector2, size_px: Vector2, colour: Color, px: float) -> ColorRect:
	var r := ColorRect.new()
	r.color = colour
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.size = size_px.round() * px
	r.position = _snap(pos, px)
	parent.add_child(r)
	return r


## A stepped pixel ellipse on the ground at `feet`, growing from a speck to
## `widest` art pixels across each side over `seconds`, blinking near the end.
## Returns the node; free it at the moment of impact to end the omen.
static func omen(host: Node2D, feet: Vector2, px: float, seconds: float, palette: Array[Color], widest := 56.0) -> Node2D:
	var ground := Node2D.new()
	host.add_child(ground)
	host.move_child(ground, 0)  # under everything else the effect draws
	_grow_omen(ground, feet, px, seconds, palette, widest)
	return ground


static func _grow_omen(ground: Node2D, feet: Vector2, px: float, seconds: float, palette: Array[Color], widest: float) -> void:
	var started: int = Time.get_ticks_msec()
	while is_instance_valid(ground):
		var t: float = (Time.get_ticks_msec() - started) / 1000.0
		var k: float = clampf(t / maxf(0.01, seconds), 0.0, 1.0)
		var half_w: float = roundf(lerpf(3.0, widest, pow(k, 1.5)))
		var half_h: float = maxf(1.0, roundf(half_w * 0.2))
		for c in ground.get_children():
			c.queue_free()
		var blink: bool = k > 0.6 and int(t * STEPS) % 2 == 0
		var alpha: float = lerpf(0.35, 0.8, k) * (1.25 if blink else 1.0)
		for row in range(-int(half_h), int(half_h) + 1):
			var w: float = roundf(half_w * sqrt(maxf(0.0, 1.0 - pow(row / (half_h + 0.5), 2.0))))
			if w < 1.0:
				continue
			var y: float = feet.y + row * px
			if absi(row) == int(half_h):
				# Top and bottom rows: the bright outline all the way across.
				_block(ground, Vector2(feet.x - w * px, y), Vector2(w * 2.0, 1), Color(palette[2], alpha), px)
				continue
			# A dim fill, and a bright outline two art pixels thick at each end.
			_block(ground, Vector2(feet.x - w * px, y), Vector2(w * 2.0, 1), Color(palette[1], alpha * 0.55), px)
			var rim: float = minf(2.0, w)
			_block(ground, Vector2(feet.x - w * px, y), Vector2(rim, 1), Color(palette[2], alpha), px)
			_block(ground, Vector2(feet.x + (w - rim) * px, y), Vector2(rim, 1), Color(palette[2], alpha), px)
		await ground.get_tree().create_timer(1.0 / STEPS).timeout


## The whole screen flashes in `colour` over everything, then drops back in
## three flat steps.
static func flash(host: Node, colour: Color) -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	host.add_child(layer)
	var rect := ColorRect.new()
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(rect)
	var tree := host.get_tree()
	for a in [0.85, 0.5, 0.2]:
		if not is_instance_valid(rect):
			return  # cleared with the host (the camera cut back); nothing left to do
		rect.color = Color(colour, a)
		await tree.create_timer(0.05).timeout
	if is_instance_valid(layer):
		layer.queue_free()


## A column of energy from the top of the screen down to `bottom_y`, centred on
## `x`: a pale core inside two brighter-to-darker bands, narrowing step by step
## from `widest` art pixels each side until it is gone.
static func column(host: Node2D, x: float, bottom_y: float, px: float, palette: Array[Color], widest := 22.0) -> void:
	var col := Node2D.new()
	host.add_child(col)
	host.move_child(col, 0)
	var tall: float = ceilf(bottom_y / px)
	var tree := host.get_tree()
	for f in [1.0, 0.82, 0.6, 0.36, 0.18, 0.09]:
		if not is_instance_valid(col):
			return  # cleared with the host (the camera cut back)
		for c in col.get_children():
			c.queue_free()
		var half_w: float = widest * f
		for band in [[half_w, palette[1]], [half_w * 0.66, palette[2]], [half_w * 0.3, palette[3]]]:
			var w: float = maxf(1.0, roundf(band[0]))
			_block(col, Vector2(x - w * px, bottom_y - tall * px), Vector2(w * 2.0, tall), Color(band[1], 0.85), px)
		await tree.create_timer(1.0 / STEPS).timeout
	if is_instance_valid(col):
		col.queue_free()


## `count` chips thrown up and out from `at`, falling back under gravity and
## fading. Colours are picked from `colours`; with `pieces`, some chips are
## drawn sprites instead (globs, shards) at `piece_scale`.
static func debris(host: Node2D, at: Vector2, px: float, colours: Array[Color], count := 24,
		pieces: Array[Texture2D] = [], piece_scale := 2) -> void:
	var bits: Array = []
	for i in count:
		var angle: float = lerpf(-PI * 0.95, -PI * 0.05, randf())
		var speed: float = randf_range(9.0, 22.0)  # art pixels per step
		var node: CanvasItem
		if not pieces.is_empty() and i % 3 == 0:
			var s := Sprite2D.new()
			s.texture = pieces.pick_random()
			s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			s.scale = Vector2.ONE * px * piece_scale
			host.add_child(s)
			node = s
		else:
			var size: float = [2.0, 3.0, 3.0, 4.0].pick_random()
			node = _block(host, at, Vector2(size, size), colours.pick_random(), px)
		bits.append({"node": node, "at": at, "v": Vector2(cos(angle), sin(angle)) * speed * px})
	var tree := host.get_tree()
	for step in 14:
		if not is_instance_valid(host):
			return  # cleared with the host (the camera cut back)
		for bit in bits:
			if not is_instance_valid(bit["node"]):
				continue
			bit["v"] += Vector2(0, 4.0 * px)  # gravity
			bit["at"] += bit["v"]
			bit["node"].position = _snap(bit["at"], px)
			if step > 8:
				bit["node"].modulate.a = 1.0 - (step - 8) / 6.0
		await tree.create_timer(1.0 / STEPS).timeout
	for bit in bits:
		if is_instance_valid(bit["node"]):
			bit["node"].queue_free()


## A drawn ring (a shockwave) spreading from `at` by whole sizes and fading.
## `centre_offset` (texture pixels) moves a ring whose middle is not the middle of its art.
static func ring(host: Node2D, tex: Texture2D, at: Vector2, px: float, from_scale: int, steps := 5, delay := 0.0,
		centre_offset := Vector2.ZERO) -> void:
	if tex == null:
		return
	var tree := host.get_tree()
	if delay > 0.0:
		await tree.create_timer(delay).timeout
		if not is_instance_valid(host):
			return
	var r := Sprite2D.new()
	r.texture = tex
	r.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	r.offset = centre_offset
	r.position = _snap(at, px)
	host.add_child(r)
	host.move_child(r, 0)
	for i in steps:
		if not is_instance_valid(r):
			return
		r.scale = Vector2.ONE * px * (from_scale + i)
		r.modulate.a = 1.0 - float(i) / steps
		await tree.create_timer(0.09).timeout
	if is_instance_valid(r):
		r.queue_free()
