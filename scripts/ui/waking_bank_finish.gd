extends RefCounted
## The existing Hollowtide Sprite detail finish, bounded to foreground material and architecture.
## Water, loose letters, glowing seams and the two standing pads stay original.
const SHADER := preload("res://scripts/dungeon/dungeon_finish.gdshader")
const RIM := preload("res://scripts/art/selout.gd")
const PADS := [Rect2i(151,75,34,16),Rect2i(210,77,25,14)]
const LETTERS := [Rect2i(197,77,12,12),Rect2i(235,83,14,13),Rect2i(292,71,16,12)]

static func water(c: Color) -> bool:
	return c.b > c.r*1.25 and c.g > c.r*1.10 and c.b > c.g*0.80

static func mask(img: Image) -> Image:
	var result := Image.create(384,216,false,Image.FORMAT_RGBA8)
	result.fill(Color.BLACK)
	for y in 216:
		for x in 384:
			var p := Vector2i(x,y)
			var c := img.get_pixelv(p)
			# Near-bank strata and roots; keep ordinary clay and open river calm.
			var selected := y>=62 and y<=79
			selected = selected or (x<43 and y>=74) or (x>340 and y>=63)
			selected = selected or Rect2i(263,0,74,49).has_point(p)
			selected = selected or (y>=43 and y<=76 and abs(x-(299-(y-43)*2))<=11)
			if water(c) or c.get_luminance()>0.68: selected=false
			for r in PADS+LETTERS:
				if r.has_point(p):selected=false
			if selected:result.set_pixelv(p,Color.WHITE)
	return result

static func rim_mask(img: Image) -> Image:
	# The actual river-contact silhouette, not the boundary of a rectangle.
	# Only material beside river water participates; this avoids ink seams on open ground.
	var result := Image.create(384,216,false,Image.FORMAT_RGBA8)
	result.fill(Color.BLACK)
	var selected := mask(img)
	for y in range(1,85):
		for x in range(1,383):
			if selected.get_pixel(x,y).r<0.5:continue
			if not water(img.get_pixel(x,y)):result.set_pixel(x,y,Color.WHITE)
	return result

static func finished_image(img: Image) -> Image:
	# Shared material rim helper is gated back to genuine water-contact pixels.
	var material := rim_mask(img)
	var variant := RIM.selout(img,material)
	var result := img.duplicate() as Image
	for y in range(1,85):
		for x in range(1,383):
			if material.get_pixel(x,y).r<0.5:continue
			var contact := false
			for d in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
				if water(img.get_pixelv(Vector2i(x,y)+d)):contact=true
			if contact:result.set_pixel(x,y,variant.get_pixel(x,y))
	return result

static func apply(sprite: Sprite2D, img: Image) -> void:
	apply_mask(sprite,ImageTexture.create_from_image(mask(img)))

## apply() with a mask already made (Claude, 2026-10-26, pass 7 S5): waking_bank.gd keeps its mask's texture for
## the session. Each sprite still gets its own material.
static func apply_mask(sprite: Sprite2D, detail_mask: Texture2D) -> void:
	var material := ShaderMaterial.new()
	material.shader=SHADER
	material.set_shader_parameter("detail_mask",detail_mask)
	material.set_shader_parameter("detail_ink",0.55)
	sprite.material=material
